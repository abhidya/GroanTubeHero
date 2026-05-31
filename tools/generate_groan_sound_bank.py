#!/usr/bin/env python3
"""Generate local groan-tube-like WAV upload sources for GroanTubeHero.

The generated files are upload sources only. Roblox runtime playback still uses
rbxassetid:// audio ids placed in the emitted manifest after upload.
"""

from __future__ import annotations

import argparse
import json
import math
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44100


PRESETS = {
    "short_pop": {"duration": 0.28, "start": 470, "end": 360, "wobble": 16, "gain": 0.62},
    "long_slide": {"duration": 0.82, "start": 260, "end": 610, "wobble": 24, "gain": 0.58},
    "rising_wah": {"duration": 0.54, "start": 330, "end": 720, "wobble": 28, "gain": 0.52},
    "falling_wah": {"duration": 0.58, "start": 700, "end": 290, "wobble": 22, "gain": 0.56},
    "wobble_phrase": {"duration": 1.12, "start": 390, "end": 430, "wobble": 55, "gain": 0.50},
    "miss_squeak": {"duration": 0.32, "start": 820, "end": 210, "wobble": 45, "gain": 0.48},
}


def envelope(position: float) -> float:
    attack = min(1.0, position / 0.08)
    release = min(1.0, (1.0 - position) / 0.16)
    return max(0.0, min(attack, release))


def render(path: Path, preset: dict[str, float]) -> None:
    total = max(1, int(preset["duration"] * SAMPLE_RATE))
    phase = 0.0
    frames = bytearray()
    for i in range(total):
        t = i / SAMPLE_RATE
        p = i / max(1, total - 1)
        base_freq = preset["start"] + (preset["end"] - preset["start"]) * p
        wobble = math.sin(2 * math.pi * (5.5 + p * 2.0) * t) * preset["wobble"]
        freq = max(80.0, base_freq + wobble)
        phase += 2 * math.pi * freq / SAMPLE_RATE

        # Hollow plastic-tube color: odd harmonics plus a soft clipped breath layer.
        raw = (
            math.sin(phase)
            + 0.46 * math.sin(phase * 3.01)
            + 0.22 * math.sin(phase * 5.03)
            + 0.08 * math.sin(phase * 9.1)
        )
        breath = math.sin(phase * 0.47 + math.sin(phase * 0.05)) * 0.16
        sample = math.tanh((raw + breath) * 1.45) * envelope(p) * preset["gain"]
        frames.extend(struct.pack("<h", int(max(-1.0, min(1.0, sample)) * 32767)))

    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(bytes(frames))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", default="assets/groans")
    args = parser.parse_args()

    out_dir = Path(args.out_dir)
    entries = {}
    for key, preset in PRESETS.items():
        wav_path = out_dir / f"{key}.wav"
        render(wav_path, preset)
        entries[key] = {
            "localFile": str(wav_path.as_posix()),
            "duration": preset["duration"],
            "robloxAudioId": "rbxassetid://0",
            "usage": "Upload this WAV to Roblox, then replace robloxAudioId with the returned asset id.",
        }

    manifest = {
        "schema": "groan-tube-hero.groan-bank.v1",
        "noMp4": True,
        "generatedFilesAreUploadSourcesOnly": True,
        "sounds": entries,
    }
    manifest_path = out_dir / "groan_sound_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"WROTE {manifest_path} ({len(entries)} sounds)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
