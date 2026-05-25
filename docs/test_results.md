# Test Results

Date: 2026-05-25

| Test | Result | Notes |
| --- | --- | --- |
| `git diff --check` | PASS | No whitespace errors. |
| Static WorldV2 requirement scan | PASS | WorldV2 roots, vendor paths, sector payload compatibility, UIUX API, validation modules all present. |
| Unsafe asset ID scan | PASS | No previous candidate IDs in active Lua; no fake `Search: "..."` comments. |
| Song module count | PASS | 21 playable `ReplicatedStorage.Shared.Chart_LocalAudioSong*.lua`; 18 uked modules under `Shared.UkedCharts`. |
| Studio active-instance freshness check | STALE | Active Studio `GameBootstrap` is old unsynced content (uses V1 `Stage`, `AlwaysOnTop=true`). Runtime validation must run after syncing filesystem project into Studio. |
| `UnitTests.Run()` | WIRED, NOT RUN | UnitTests calls WorldValidation on server; requires synced Roblox play/server runtime. |
| `GameTestHarness.Run()` | WIRED, NOT RUN | Harness prints required WorldV2 counts and runs WorldValidation/UIUXValidation by context; requires synced Roblox runtime. |

Expected WorldV2 source-built counts from current builder:

| Metric | Expected |
| --- | ---: |
| active visible BaseParts | 181 |
| horde sectors | 8 |
| menu vendor prompts | 7 |
| repair prompts | 8 |
| invisible hitboxes | 2 |
| ArtAssets source models | 1 |
| playable songs | 21 |
| uked songs | 18 |
| unsafe candidate asset IDs used | 0 |
