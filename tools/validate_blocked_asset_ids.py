#!/usr/bin/env python3
"""Fail if known unpublishable Roblox asset IDs appear in project files.

The blocked IDs are assembled from chunks so this validator does not contain
the forbidden literals it searches for.
"""

from __future__ import annotations

import sys
import zipfile
from pathlib import Path


BLOCKED_ID_PARTS = [
    ("735", "299", "1158"),
    ("710", "212", "0648"),
    ("710", "214", "8177"),
    ("526", "352", "6264"),
    ("710", "211", "6848"),
    ("710", "211", "3706"),
    ("735", "288", "4774"),
    ("735", "257", "7687"),
    ("484", "982", "8561"),
    ("735", "276", "2667"),
    ("735", "270", "4626"),
]

BLOCKED_IDS = ["".join(parts) for parts in BLOCKED_ID_PARTS]
SKIP_DIRS = {".git", ".omx", "__pycache__"}


def should_skip(path: Path) -> bool:
    return any(part in SKIP_DIRS for part in path.parts)


def scan_bytes(label: str, data: bytes, failures: list[str]) -> None:
    for asset_id in BLOCKED_IDS:
        if asset_id.encode("ascii") in data:
            failures.append(f"{label}: blocked asset id {asset_id}")


def scan_file(path: Path, failures: list[str]) -> None:
    try:
        data = path.read_bytes()
    except OSError as exc:
        failures.append(f"{path}: read failed: {exc}")
        return

    scan_bytes(str(path), data, failures)

    if path.suffix.lower() == ".zip":
        try:
            with zipfile.ZipFile(path) as archive:
                for member in archive.namelist():
                    if member.endswith("/"):
                        continue
                    scan_bytes(f"{path}!{member}", archive.read(member), failures)
        except zipfile.BadZipFile:
            return


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    failures: list[str] = []
    for path in root.rglob("*"):
        if should_skip(path) or not path.is_file():
            continue
        scan_file(path, failures)

    if failures:
        print("[BlockedAssetIdValidation] FAIL")
        for failure in failures:
            print(failure)
        return 1

    print("[BlockedAssetIdValidation] PASS")
    print(f"scanned_root={root}")
    print(f"blocked_id_count={len(BLOCKED_IDS)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
