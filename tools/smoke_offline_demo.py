#!/usr/bin/env python3
"""Hardware-free smoke check for the Groan Tube Hero repo demo path."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "ReplicatedStorage" / "Shared"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"FAIL: {message}")


def read(path: Path) -> str:
    require(path.exists(), f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def parse_chart(path: Path) -> dict[str, object]:
    text = read(path)
    chart_id = re.search(r'Id\s*=\s*"([^"]+)"', text)
    title = re.search(r'Title\s*=\s*"([^"]+)"', text)
    duration = re.search(r"Duration\s*=\s*([0-9.]+)", text)
    lanes = [int(value) for value in re.findall(r"note\([^,\n]+,\s*[0-9.]+,\s*([1-4])", text)]
    require(chart_id is not None, f"{path.name} missing Id")
    require(title is not None, f"{path.name} missing Title")
    require(duration is not None and float(duration.group(1)) > 0, f"{path.name} missing positive Duration")
    require(lanes, f"{path.name} has no parsed lane notes")
    return {
        "id": chart_id.group(1),
        "title": title.group(1),
        "duration": float(duration.group(1)),
        "notes": len(lanes),
        "lanes": sorted(set(lanes)),
    }


def main() -> None:
    project = json.loads(read(ROOT / "default.project.json"))
    for name, node in project["tree"].items():
        if isinstance(node, dict) and "$path" in node:
            require((ROOT / node["$path"]).exists(), f"project path for {name} is missing")

    config_text = read(SHARED / "Config.lua")
    remote_block = re.search(r"Config\.RemoteNames\s*=\s*{(?P<body>.*?)\n}", config_text, re.S)
    require(remote_block is not None, "Config.RemoteNames block missing")
    remotes = re.findall(r'"([^"]+)"', remote_block.group("body"))
    require(len(remotes) >= 12, f"expected at least 12 remotes, found {len(remotes)}")

    charts = sorted(SHARED.glob("Chart_LocalAudioSong*.lua"))
    require(charts, "no local chart modules found")
    parsed = [parse_chart(path) for path in charts]
    require(any(chart["id"] == "LocalAudioSong001" for chart in parsed), "default local chart missing")

    manifest = json.loads(read(ROOT / "assets" / "groans" / "groan_sound_manifest.json"))
    sounds = manifest.get("sounds", {})
    require(len(sounds) >= 4, "groan sound manifest is too small for a demo bank")
    missing_sources = []
    for sound_id, sound in sounds.items():
        local_file = ROOT / sound["localFile"]
        if not local_file.exists():
            missing_sources.append(f"{sound_id}:{sound['localFile']}")

    total_notes = sum(int(chart["notes"]) for chart in parsed)
    first = parsed[0]
    print("OFFLINE DEMO OK")
    print(f"charts={len(parsed)} notes={total_notes} remotes={len(remotes)} groan_sounds={len(sounds)}")
    print(f"default_chart={first['id']} title={first['title']!r} duration={first['duration']}s lanes={first['lanes']}")
    if missing_sources:
        print(f"missing_upload_sources={len(missing_sources)} (manifest kept for Roblox upload mapping; WAV files are not checked in)")
    print("demo_path=Open GroanTubeHero.rbxlx in Studio or review Rojo tree with default.project.json")


if __name__ == "__main__":
    main()
