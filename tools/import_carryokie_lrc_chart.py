#!/usr/bin/env python3
"""Convert CarryOkie LRC sidecars into GroanTubeHero Lua chart modules.

This importer intentionally does not copy or reference MP4 media. It consumes
only catalog metadata, LRC text/timing, and optional Roblox audio ids.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


LRC_LINE = re.compile(r"^\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\](.*)$")
WORD = re.compile(r"[A-Za-z0-9']+")
GROAN_KEYS = ["short_pop", "long_slide", "rising_wah", "falling_wah", "wobble_phrase"]
DROP_SEGMENTS = {
    "singkine",
    "sing kine",
    "sing mine",
    "singuine",
    "sedan",
    "sede",
    "seaeaue",
    "seaeauee",
    "seaeauwe",
    "er artitg",
    "rar",
    "rari",
    "srdoae",
    "searing",
    "staring",
    "shaing",
    "sha ing",
    "seating",
}
DROP_LINE_PATTERNS = [
    re.compile(r"\bpublishing\b", re.I),
    re.compile(r"\bulvaeus\b|\banderson\b|\bandersson\b", re.I),
    re.compile(r"\bkaraoke\b", re.I),
]


def lua_string(value: object) -> str:
    text = str(value or "")
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'


def lua_bool(value: bool) -> str:
    return "true" if value else "false"


def slug(value: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9]+", "_", value).strip("_")
    return cleaned or "CarryOkieSong"


def parse_lrc(path: Path) -> list[tuple[float, str]]:
    entries: list[tuple[float, str]] = []
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = LRC_LINE.match(raw.strip())
        if not match:
            continue
        minutes, seconds, fraction, text = match.groups()
        millis = int((fraction or "0").ljust(3, "0")[:3])
        time_value = int(minutes) * 60 + int(seconds) + millis / 1000
        text = re.sub(r"\s+", " ", text.replace(" / ", " / ")).strip()
        if text:
            entries.append((time_value, text))
    return entries


def normalize_text(text: str) -> str:
    return " ".join(WORD.findall(text.lower()))


def clean_ocr_text(text: str) -> str:
    pieces = []
    for raw_piece in text.split("/"):
        piece = re.sub(r"\s+", " ", raw_piece).strip(" \\-=.>\"'")
        piece = re.sub(r"\s+\b(?:why|hy|ay|wy|wily|yehy|yay|vwiy)\b$", "", piece, flags=re.I).strip()
        norm = normalize_text(piece)
        if not piece or norm in DROP_SEGMENTS:
            continue
        if norm in {"why", "hy", "ay", "wy", "wily", "yehy", "yay"}:
            continue
        pieces.append(piece)
    return " / ".join(pieces).strip()


def is_noise_line(text: str) -> bool:
    if not text:
        return True
    return any(pattern.search(text) for pattern in DROP_LINE_PATTERNS)


def load_catalog(path: Path, song_id: str) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    for song in data.get("songs", []):
        if song.get("id") == song_id or song.get("songId") == song_id:
            return song
    raise SystemExit(f"song id not found in CarryOkie catalog: {song_id}")


def find_lrc(carryokie_root: Path, song: dict, song_id: str) -> Path:
    candidates = []
    if song.get("lyricsLrcUrl"):
        candidates.append(carryokie_root / str(song["lyricsLrcUrl"]).lstrip("/"))
    candidates.append(carryokie_root / "public" / "lyrics" / "lrc" / f"{song_id}.lrc")
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise SystemExit(f"no LRC found for {song_id}; looked in {', '.join(str(c) for c in candidates)}")


def load_manifest(path: Path | None) -> dict[str, str]:
    if not path or not path.exists():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    sounds = data.get("sounds", {})
    return {
        key: str(value.get("robloxAudioId") or "rbxassetid://0")
        for key, value in sounds.items()
        if isinstance(value, dict)
    }


def build_notes(entries: list[tuple[float, str]], max_notes: int, min_gap: float, manifest: dict[str, str]) -> list[dict]:
    notes = []
    last_norm = ""
    last_time = -999.0
    for time_value, text in entries:
        text = clean_ocr_text(text)
        if is_noise_line(text):
            continue
        norm = normalize_text(text)
        if not norm:
            continue
        if norm == last_norm and time_value - last_time < 8:
            continue
        if time_value - last_time < min_gap:
            continue
        words = WORD.findall(text)
        key = GROAN_KEYS[len(notes) % len(GROAN_KEYS)]
        note = {
            "id": f"carry_{len(notes) + 1:03d}",
            "time": round(time_value, 3),
            "lane": (len(notes) % 4) + 1,
            "lyric": text,
            "word": words[0].lower() if words else "",
            "syllable": words[0][:12].lower() if words else "",
            "groanSoundKey": key,
            "groanAssetId": manifest.get(key, "rbxassetid://0"),
            "groanVolume": 0.82,
            "groanPlaybackSpeed": round(0.92 + (len(notes) % 5) * 0.05, 2),
            "duration": 0.55,
        }
        notes.append(note)
        last_norm = norm
        last_time = time_value
        if len(notes) >= max_notes:
            break
    return notes


def write_chart(path: Path, song: dict, song_id: str, lrc_path: Path, notes: list[dict], backing_audio_id: str) -> None:
    title = song.get("title") or song_id
    artist = song.get("artist") or "CarryOkie"
    duration = float(song.get("duration") or (notes[-1]["time"] + 8 if notes else 30))
    source_video_id = str(song.get("sourceVideoId") or song.get("youtubeId") or "")

    lines = [
        "-- Generated by tools/import_carryokie_lrc_chart.py.",
        "-- MP4 media is intentionally not imported into GroanTubeHero or Roblox.",
        "return {",
        f"    Id = {lua_string('CarryOkie_' + song_id)},",
        f"    Title = {lua_string(title)},",
        f"    Artist = {lua_string(artist)},",
        f"    AudioId = {lua_string(backing_audio_id)},",
        f"    Duration = {duration:.3f},",
        "    LocalTestOnly = true,",
        "    CarryOkieImport = true,",
        f"    CarryOkieSongId = {lua_string(song_id)},",
        f"    SourceVideoId = {lua_string(source_video_id)},",
        f"    LyricsLrcPath = {lua_string(str(lrc_path))},",
        f"    NoMp4Imported = {lua_bool(True)},",
        "    Notes = {",
    ]
    for note in notes:
        lines.append("        {")
        for key in [
            "id",
            "time",
            "lane",
            "lyric",
            "word",
            "syllable",
            "groanSoundKey",
            "groanAssetId",
            "groanVolume",
            "groanPlaybackSpeed",
            "duration",
        ]:
            value = note[key]
            if isinstance(value, str):
                rendered = lua_string(value)
            else:
                rendered = str(value)
            lines.append(f"            {key} = {rendered},")
        lines.append("        },")
    lines.extend(["    },", "}", ""])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--carryokie-root", default="../CarryOkie")
    parser.add_argument("--song-id", required=True)
    parser.add_argument("--out-dir", default="ReplicatedStorage/Shared")
    parser.add_argument("--manifest", default="assets/groans/groan_sound_manifest.json")
    parser.add_argument("--max-notes", type=int, default=80)
    parser.add_argument("--min-gap", type=float, default=1.5)
    parser.add_argument("--backing-audio-id", default="rbxassetid://0")
    args = parser.parse_args()

    carryokie_root = Path(args.carryokie_root).resolve()
    catalog_path = carryokie_root / "public" / "protected" / "catalog.json"
    song = load_catalog(catalog_path, args.song_id)
    lrc_path = find_lrc(carryokie_root, song, args.song_id)
    manifest = load_manifest(Path(args.manifest))
    notes = build_notes(parse_lrc(lrc_path), args.max_notes, args.min_gap, manifest)
    if not notes:
        raise SystemExit(f"LRC produced no playable notes: {lrc_path}")

    output = Path(args.out_dir) / f"Chart_CarryOkie_{slug(args.song_id)}.lua"
    write_chart(output, song, args.song_id, lrc_path, notes, args.backing_audio_id)
    print(f"WROTE {output} ({len(notes)} notes, no MP4 imported)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
