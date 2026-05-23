#!/usr/bin/env python3
"""Generate a Groan Tube Hero 4-lane placeholder chart from rights-cleared audio.

This tool is intentionally local-only: it reads an audio file you own or have
permission to use, estimates simple onset timings, and writes a Lua chart module.
It does not copy/encode/import audio into Roblox. Set AudioId in Roblox after you
upload your own allowed audio, or leave it as rbxassetid://0 for visual play.
"""
from __future__ import annotations

import argparse
import math
import shutil
import subprocess
import tempfile
import wave
from pathlib import Path

LANE_SYMBOLS = {1: "Left", 2: "Right", 3: "Up", 4: "Down"}


def decode_to_wav(src: Path, dst: Path) -> None:
    if src.suffix.lower() == ".wav":
        dst.write_bytes(src.read_bytes())
        return
    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        raise SystemExit("MP3/OGG decoding needs ffmpeg installed. Convert to WAV or install ffmpeg.")
    subprocess.run(
        [ffmpeg, "-y", "-v", "error", "-i", str(src), "-ac", "1", "-ar", "22050", str(dst)],
        check=True,
    )


def read_mono(path: Path) -> tuple[int, list[float]]:
    with wave.open(str(path), "rb") as w:
        rate = w.getframerate()
        channels = w.getnchannels()
        width = w.getsampwidth()
        raw = w.readframes(w.getnframes())
    if width != 2:
        raise SystemExit("Decoded WAV must be 16-bit PCM; ffmpeg path should produce that automatically.")
    vals = []
    step = 2 * channels
    for i in range(0, len(raw), step):
        total = 0
        for ch in range(channels):
            sample = int.from_bytes(raw[i + ch * 2 : i + ch * 2 + 2], "little", signed=True)
            total += sample / 32768.0
        vals.append(total / channels)
    return rate, vals


def zero_crossing_rate(values: list[float]) -> float:
    if len(values) < 2:
        return 0.0
    crossings = 0
    prev = values[0]
    for sample in values[1:]:
        if (prev < 0 <= sample) or (prev >= 0 > sample):
            crossings += 1
        prev = sample
    return crossings / (len(values) - 1)


def estimate_onsets(rate: int, samples: list[float], difficulty: str) -> list[dict[str, float]]:
    frame = max(256, int(rate * 0.046))
    hop = max(128, int(rate * 0.023))
    energies: list[float] = []
    zcrs: list[float] = []
    for start in range(0, max(0, len(samples) - frame), hop):
        window = samples[start : start + frame]
        e = sum(abs(x) for x in window) / frame
        energies.append(e)
        zcrs.append(zero_crossing_rate(window))
    if len(energies) < 8:
        return []
    flux = [max(0.0, energies[i] - energies[i - 1]) for i in range(1, len(energies))]
    sorted_flux = sorted(flux)
    pct = {"easy": 0.82, "normal": 0.76, "hard": 0.70}.get(difficulty, 0.82)
    threshold = sorted_flux[int(len(sorted_flux) * pct)] if sorted_flux else 0.01
    min_gap = {"easy": 0.55, "normal": 0.38, "hard": 0.28}.get(difficulty, 0.55)
    onsets: list[dict[str, float]] = []
    last = -999.0
    for i in range(1, len(flux) - 1):
        if flux[i] >= threshold and flux[i] >= flux[i - 1] and flux[i] >= flux[i + 1]:
            t = (i * hop) / rate
            if t >= 1.0 and t - last >= min_gap:
                onsets.append({
                    "time": round(t, 3),
                    "energy": energies[i],
                    "flux": flux[i],
                    "zcr": zcrs[i],
                })
                last = t
    max_notes = {"easy": 70, "normal": 110, "hard": 150}.get(difficulty, 70)
    return onsets[:max_notes]


def lane_for(onset: dict[str, float], previous_lane: int | None) -> int:
    """Pick lanes from audio features, not a fixed L/R/U/D cycle.

    Low/noisy hits lean left/right, bright/transient hits lean up/down. A small
    anti-repeat rule keeps charts readable without forcing all songs into the
    same pattern.
    """
    zcr = onset["zcr"]
    flux = onset["flux"]
    energy = onset["energy"]
    if zcr > 0.18 and flux > energy * 0.65:
        lane = 3
    elif zcr > 0.12:
        lane = 4
    elif flux > energy * 0.50:
        lane = 2
    else:
        lane = 1
    if previous_lane == lane:
        lane = (lane % 4) + 1
    return lane


def lua_string(s: str) -> str:
    return "\"" + s.replace("\\", "\\\\").replace('"', '\\"') + "\""


def write_chart(
    out: Path,
    song_id: str,
    title: str,
    difficulty: str,
    duration: float,
    notes: list[dict[str, float]],
    audio_id: str,
) -> None:
    lines = [
        "local function note(id, timeValue, lane, groan, pose, lightCue, crowdCue)",
        "    return { id = id, time = timeValue, lane = lane, groan = groan, pose = pose, lightCue = lightCue, crowdCue = crowdCue }",
        "end",
        "",
        "return {",
        f"    Id = {lua_string(song_id)},",
        f"    Title = {lua_string(title)},",
        "    Artist = \"Original / Rights-Cleared Local Audio\",",
        f"    AudioId = {lua_string(audio_id)}, -- Roblox audio asset you own/have rights to use",
        "    BPM = 120,",
        "    Offset = 0,",
        f"    Duration = {duration:.2f},",
        "    Sections = {",
        f"        {{ name = \"Intro\", start = 0, finish = {duration * 0.25:.2f} }},",
        f"        {{ name = \"Verse\", start = {duration * 0.25:.2f}, finish = {duration * 0.55:.2f} }},",
        f"        {{ name = \"Chorus\", start = {duration * 0.55:.2f}, finish = {duration * 0.85:.2f} }},",
        f"        {{ name = \"Outro\", start = {duration * 0.85:.2f}, finish = {duration:.2f} }},",
        "    },",
        "    Notes = {",
    ]
    cues = [("Soft Groan", "Lean Left", "Cyan", "Clap"), ("Clean Groan", "Wide Stance", "Blue", "Cheer"), ("Big Groan", "Point", "Purple", "Cheer"), ("Final Groan", "Final Pose", "Gold", "Encore")]
    previous_lane = None
    for i, onset in enumerate(notes, 1):
        t = onset["time"]
        lane = lane_for(onset, previous_lane)
        previous_lane = lane
        groan, pose, light, crowd = cues[min(len(cues) - 1, int((t / max(duration, 1)) * len(cues)))]
        lines.append(f"        note(\"{song_id}-{i:03d}\", {t:.3f}, {lane}, \"{groan}\", \"{pose}\", \"{light}\", \"{crowd}\"), -- {LANE_SYMBOLS[lane]}")
    lines += ["    },", "}", ""]
    out.write_text("\n".join(lines))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("audio", type=Path, nargs="?", help="Rights-cleared audio file to analyze")
    ap.add_argument("--batch-dir", type=Path, help="Process every mp3/wav/ogg in a folder")
    ap.add_argument("--song-id")
    ap.add_argument("--title")
    ap.add_argument("--difficulty", choices=["easy", "normal", "hard"], default="easy")
    ap.add_argument("--audio-id", default="rbxassetid://0", help="Roblox audio asset id to pipe at runtime")
    ap.add_argument("--out", type=Path, required=True, help="Output chart module path or output directory in --batch-dir mode")
    args = ap.parse_args()

    def process_one(audio_path: Path, out_path: Path, song_id: str, title: str) -> None:
        with tempfile.TemporaryDirectory() as td:
            wav = Path(td) / "decoded.wav"
            decode_to_wav(audio_path, wav)
            rate, samples = read_mono(wav)
            duration = len(samples) / rate
            notes = estimate_onsets(rate, samples, args.difficulty)
        write_chart(out_path, song_id, title, args.difficulty, duration, notes, args.audio_id)
        lanes = []
        previous_lane = None
        for note in notes[:12]:
            lane = lane_for(note, previous_lane)
            previous_lane = lane
            lanes.append(str(lane))
        print(f"wrote {out_path} with {len(notes)} audio-derived notes over {duration:.2f}s; first lanes {','.join(lanes)}")

    if args.batch_dir:
        args.out.mkdir(parents=True, exist_ok=True)
        files = sorted(p for p in args.batch_dir.iterdir() if p.suffix.lower() in {".mp3", ".wav", ".ogg"})
        for index, audio_path in enumerate(files, 1):
            stem = audio_path.stem
            song_id = f"LocalAudioSong{index:03d}"
            title = stem.split(" - ", 1)[-1].rsplit("[", 1)[0].replace("_", " ").strip() or song_id
            process_one(audio_path, args.out / f"Chart_{song_id}.lua", song_id, title)
        return

    if not args.audio or not args.song_id or not args.title:
        raise SystemExit("single-file mode requires audio, --song-id, and --title")
    process_one(args.audio, args.out, args.song_id, args.title)


if __name__ == "__main__":
    main()
