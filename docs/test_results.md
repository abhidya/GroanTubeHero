# Test Results

Date: 2026-05-25

| Test | Result | Notes |
| --- | --- | --- |
| `git diff --check` | PASS | Run after WorldV2 remaining-phase edits. |
| Static WorldV2 requirement scan | PASS | WorldV2 roots, vendor paths, sector payload compatibility, UIUX API, validation modules present. |
| Unsafe asset ID scan | PASS | No previous candidate Creator Store IDs in active Lua; no fake search-placeholder comments. |
| Song module count | PASS | 21 playable `ReplicatedStorage.Shared.Chart_LocalAudioSong*.lua`; 18 uked modules under `Shared.UkedCharts`. |
| Studio MCP load | PASS | Loaded active `Workspace.GTH_WorldV2` via MCP with 8 sectors, 15 prompts, 166 visible BaseParts, 0 scripts, 0 placeholders. |
| Studio MCP Play validation | PASS | Play started; validation returned 8 sectors, 15 prompts, 166 visible BaseParts, 0 scripts, 0 placeholders. |
| Studio MCP Stop validation | PASS | Stop returned edit mode; `GTH_WorldV2` still exists with 8 sectors; screenshot `WorldV2_After_Stop` captured. |
| `UnitTests.Run()` | WIRED | Includes `testWorldV2Validation`, horde PivotTo, song counts, title cleanup, AntiExploit, and AssetAuditService fixture. Runs in Roblox runtime. |
| `GameTestHarness.Run()` | WIRED | Runs UnitTests, simulated chart run, server WorldValidation counts, and client UIUXValidation when client context exists. |
| `WorldValidation` | WIRED | Asserts roots, vendors/prompts, 8 sectors, script-free world, Billboard limits, placeholder violations, required ArtAssets, AssetAuditService counts. |
| `UIUXValidation` | WIRED | Asserts controller API, modal open/close/reopen/back paths, prompt station existence, results buttons, viewport close-button fit, rhythm highway fit. |

Expected WorldV2 source-built counts from current builder/runtime proof:

| Metric | Expected / Last MCP proof |
| --- | ---: |
| active WorldV2 models | 15 |
| active WorldV2 MeshParts | 0 |
| active visible BaseParts | 166 |
| horde sectors | 8 |
| menu + repair prompts | 15 |
| invisible hitboxes | 2 |
| ArtAssets source models | 1 |
| quarantined scripts | 0 |
| visible placeholder violations | 0 |
| unsafe candidate asset IDs used | 0 |
| playable songs | 21 |
| uked songs | 18 |

## 2026-05-25 Remaining phases hardening

| Check | Result | Evidence |
| --- | --- | --- |
| Team worker messages | PASS | `worldv2-remaining-pha-968c0d36`: worker-2 completed no-edit guard; worker-1 captured static/MCP verification before hanging on subagent wait; leader reconciled task with fresh evidence. |
| `WorldValidation` client safety | PASS | `ServerStorage` access is now gated behind `RunService:IsServer()` so client-side harness requires do not hard-error. |
| Active unsafe candidate asset IDs | PASS | Static scan over repo source/docs excluding `.omx`, worktrees, and manifest/missing-asset docs found 0 active references to the rejected candidate IDs. |
| Static integration scan | PASS | Required ArtAssets, audit counts, diagnostics BindableFunction, UIUX controller simulation, UnitTests fixture, and GameTestHarness audit prints all present. |
| Studio MCP edit-mode validation | PASS | `ok=true`, roots=8, sectors=8, sectorChildren=56, prompts=7+, models=15, visibleBaseParts=166, scripts=0, placeholders=0, artAssetSources=1, missingRequiredAssets=0. |
| Studio MCP play/stop validation | PASS | Play started; live check `ok=true`, sectors=8, prompts=15, visibleBaseParts=166, scripts=0, placeholders=0, missingRequiredAssets=0; play stopped cleanly. |
| Screenshot | PASS | `WorldV2_Remaining_Phases_Final` shows circular arena, fence ring, 8 surrounding sector stations/cliffs. |

Latest counts from Studio MCP:

| Count | Value |
| --- | ---: |
| Active WorldV2 Models | 15 |
| Active WorldV2 MeshParts | 0 |
| Active WorldV2 visible BaseParts | 166 |
| Invisible hitboxes | 2 |
| ArtAssets source models | 1 |
| Quarantined/audit scripts | 0 |
| Vendor prompts | 15 live / 7 required station prompts |
| Horde sectors | 8 |
| Missing required assets | 0 |
| Visible placeholder violations | 0 |
| Playable songs | 21 |
| Uked songs | 18 |

## 2026-05-25 Asset manifest doc hardening

| Check | Result | Notes |
| --- | --- | --- |
| Manifest integration | PASS | `docs/asset_manifest_real.md` now records supplied `Workspace.Unused_MapAssets`, `Workspace.Stage`, and `Workspace.TourBus` source candidates plus active `WorldV2_SafeProceduralKit`. |
| Audit-policy wording | PASS | Local place-file assets are candidate sources only until copied to quarantine/inbox, audited, script-quarantined, and published to `ReplicatedStorage.ArtAssets`. |
| Stale docs scan | PASS | No stale-runtime marker, wired-not-run marker, old `181` visible-part count, inflated unique-asset claim, or fake search-placeholder strings remain in docs/design scan. |
| Current active Studio source check | INFO | Active MCP Studio currently has minimal WorldV2/compat state and does not expose the supplied `Workspace.Unused_MapAssets` / `Workspace.TourBus` inventory; manifest rows are therefore treated as user-supplied source inventory, not current MCP runtime proof. |
