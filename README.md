# Groan Tube Hero

A Roblox Studio foundation for a server-authoritative rhythm RPG/stage-performance game.

## What is included
- 3 original placeholder charts
- server-authoritative rhythm session flow
- score/combo/hype/reward logic
- economy, upgrades, buffs, attacks, missions, audience actions
- DataStore-safe fallback persistence
- runtime-built venue map and UI scaffolding

## How to test in Studio
You can open either:
- `GroanTubeHero.rbxlx` for a Studio-openable place stub, or
- the Rojo source tree via `default.project.json`

1. Open the project with Rojo or copy the folder tree into a Roblox place.
2. Press Play.
3. Walk to the **StartPrompt** near the stage and trigger it.
4. Use **D / F / J / K** or the on-screen mobile buttons.
5. Watch the countdown, note highway, judgement text, score, combo, hype, and end screen.
6. Try the store, upgrade kiosk, mission board, and audience zone.

## Notes
- Placeholder AudioIds are used intentionally.
- The game still runs visually if audio fails to load.
- No external modules, HTTP, or asset imports are required.

## Local chart generation for original / rights-cleared audio

Use `tools/generate_chart_from_audio.py` only with audio you own or have explicit permission to use in Roblox. The tool reads a local WAV/MP3/OGG, estimates simple 4-lane note timings, and writes a Lua chart module. It does **not** copy, encode, import, or ship the audio file; `AudioId` stays `rbxassetid://0` until you upload an allowed Roblox audio asset yourself.

Example:

```bash
python3 tools/generate_chart_from_audio.py ~/Downloads/my-original-song.mp3 \
  --song-id MyOriginalGroan \
  --title "My Original Groan" \
  --difficulty easy \
  --out ReplicatedStorage/Shared/Chart_MyOriginalGroan.lua
```

The generator uses a small hardcoded deterministic lane key (`GROAN_TUBE_EASY_KEY_V1`) so the same audio/timestamps produce stable D/F/J/K lane assignments.
