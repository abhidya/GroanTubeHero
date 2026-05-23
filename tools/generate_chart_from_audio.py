#!/usr/bin/env python3
"""Generate a Groan Tube Hero 4-lane placeholder chart from rights-cleared audio.

This tool is intentionally local-only: it reads an audio file you own or have
permission to use, estimates simple onset timings, and writes a Lua chart module.
It does not copy/encode/import audio into Roblox. Set AudioId in Roblox after you
upload your own allowed audio, or leave it as rbxassetid://0 for visual play.
"""
from __future__ import annotations

import argparse
import hashlib
import math
import shutil
import subprocess
import tempfile
import wave
from pathlib import Path

EASY_LANE_KEY = "GROAN_TUBE_EASY_KEY_V1"  # small deterministic key for lane spread


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


def estimate_onsets(rate: int, samples: list[float], difficulty: str) -> list[float]:
    frame = max(256, int(rate * 0.046))
    hop = max(128, int(rate * 0.023))
    energies = []
    for start in range(0, max(0, len(samples) - frame), hop):
        e = sum(abs(x) for x in samples[start : start + frame]) / frame
        energies.append(e)
    if len(energies) < 8:
        return []
    flux = [max(0.0, energies[i] - energies[i - 1]) for i in range(1, len(energies))]
    sorted_flux = sorted(flux)
    pct = {"easy": 0.82, "normal": 0.76, "hard": 0.70}.get(difficulty, 0.82)
    threshold = sorted_flux[int(len(sorted_flux) * pct)] if sorted_flux else 0.01
    min_gap = {"easy": 0.55, "normal": 0.38, "hard": 0.28}.get(difficulty, 0.55)
    onsets: list[float] = []
    last = -999.0
    for i in range(1, len(flux) - 1):
        if flux[i] >= threshold and flux[i] >= flux[i - 1] and flux[i] >= flux[i + 1]:
            t = (i * hop) / rate
            if t >= 1.0 and t - last >= min_gap:
                onsets.append(round(t, 3))
                last = t
    max_notes = {"easy": 70, "normal": 110, "hard": 150}.get(difficulty, 70)
    return onsets[:max_notes]


def lane_for(song_id: str, index: int, t: float) -> int:
    digest = hashlib.sha1(f"{EASY_LANE_KEY}:{song_id}:{index}:{round(t,2)}".encode()).digest()
    return (digest[0] % 4) + 1


def lua_string(s: str) -> str:
    return "\"" + s.replace("\\", "\\\\").replace('"', '\\"') + "\""


def write_chart(out: Path, song_id: str, title: str, difficulty: str, duration: float, notes: list[float]) -> None:
    lines = [
        "local function note(id, timeValue, lane, groan, pose, lightCue, crowdCue)",
        "    return { id = id, time = timeValue, lane = lane, groan = groan, pose = pose, lightCue = lightCue, crowdCue = crowdCue }",
        "end",
        "",
        "return {",
        f"    Id = {lua_string(song_id)},",
        f"    Title = {lua_string(title)},",
        "    Artist = \"Original / Rights-Cleared Local Audio\",",
        "    AudioId = \"rbxassetid://0\", -- replace only with audio you own/have rights to upload",
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
    for i, t in enumerate(notes, 1):
        groan, pose, light, crowd = cues[min(len(cues) - 1, int((t / max(duration, 1)) * len(cues)))]
        lines.append(f"        note(\"{song_id}-{i:03d}\", {t:.3f}, {lane_for(song_id, i, t)}, \"{groan}\", \"{pose}\", \"{light}\", \"{crowd}\"),")
    lines += ["    },", "}", ""]
    out.write_text("\n".join(lines))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("audio", type=Path)
    ap.add_argument("--song-id", required=True)
    ap.add_argument("--title", required=True)
    ap.add_argument("--difficulty", choices=["easy", "normal", "hard"], default="easy")
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    with tempfile.TemporaryDirectory() as td:
        wav = Path(td) / "decoded.wav"
        decode_to_wav(args.audio, wav)
        rate, samples = read_mono(wav)
        duration = len(samples) / rate
        notes = estimate_onsets(rate, samples, args.difficulty)
    write_chart(args.out, args.song_id, args.title, args.difficulty, duration, notes)
    print(f"wrote {args.out} with {len(notes)} notes over {duration:.2f}s")


if __name__ == "__main__":
    main()
