# Current State Audit - Groan Tube Hero

Date: 2026-05-25

Skill contract used: `gth-current-state-audit` (repo skill file not present; performed exact audit directly from repo files and MCP evidence).

## Current world-generation files/functions

| File | Functions / responsibility |
| --- | --- |
| `ServerScriptService/Services/GameBootstrap.server.lua` | `createRemotes`, `loadServices`, `wireRemotes`, `installWorldV2Diagnostics`, `startWorldV2Atmosphere`; bootstrap now delegates world construction to `WorldV2Builder` |
| `ServerScriptService/Services/WorldV2Builder.lua` | `EnsureAssetRoots`, `ArchiveOldWorld`, `Build`, `RunValidation`; creates `Workspace.GTH_WorldV2`, archives explicit V1 visuals, creates rings/vendors/sectors/hitboxes |
| `ServerScriptService/Services/AssetAuditService.lua` | `EnsureRoots`, `Audit`, `QuarantineScripts`; creates quarantine/inbox/ArtAssets folders and scans suspicious script patterns |
| `ServerScriptService/Services/VendorPromptService.lua` | `Bind`; binds vendor prompts to menu remotes/attributes |
| `ServerScriptService/Services/CircularHordeVisualService.lua` | `ApplyUpdate`; updates sector fence/siren visuals from horde payloads |
| `ReplicatedStorage/Shared/WorldV2/PolarLayout.lua` | `position`, `cframeFacingCenter`, `cframeFacingOut`, `distribute`; polar placement convention |
| `ReplicatedStorage/Shared/WorldV2/WorldV2Config.lua` | root names, ring radii, ArtAssets folders, validation constants |
| `ReplicatedStorage/Shared/WorldV2/AssetRegistry.lua` | exact preferred Studio/ArtAssets paths, required/fallback policy, missing-required reporting |
| `ReplicatedStorage/Shared/WorldV2/VendorDefinitions.lua` | exact vendor station IDs, prompt text, menu names, angles, radii |
| `ReplicatedStorage/Shared/WorldV2/HordeSectorDefinitions.lua` | 8 sector IDs and angles under 0°=East/+X convention |

## Old visible objects designated for archival

| Old path | Archive path | Why archived |
| --- | --- | --- |
| `Workspace.TourBus` | `ServerStorage.WorldArchive.TourBus` | V1/prototype tour bus visual; source candidate only after audit |
| `Workspace.ImportedArenaAssets` | `ServerStorage.WorldArchive.ImportedArenaAssets` | imported/prototype visual root if present |
| `Workspace.Stage.*` except compatibility aliases | `ServerStorage.WorldArchive.<child>` | V1 stage visuals replaced by `Workspace.GTH_WorldV2`; do not use Stage as primary world |
| `Workspace.Stage.StartPrompt`, `StoreKiosk`, `UpgradeKiosk`, `MissionBoard`, `AudienceZone`, `BrainrotHorde.HordeRoot` | invisible `ObjectValue` compatibility aliases | preserved only for old script references |

Never archive: `Camera`, `Terrain`, player characters, `Workspace.Unused_MapAssets`, `Workspace.AssetInbox`, `SpawnLocation` before replacement exists, services/remotes/UI/gameplay logic, or `Workspace.GTH_WorldV2`.

## UI/menu roots found

| Root/file | Purpose |
| --- | --- |
| `StarterGui.RhythmGui` | note highway, SongSelect modal, results frame, navigation menu |
| `StarterGui.StoreGui` | store/upgrades/security/tutorial/settings-style external panel via attributes |
| `StarterGui.UpgradeGui` | upgrade UI root exists in repo |
| `StarterGui.MissionsGui` | missions UI root exists in repo |
| `StarterGui.AudienceGui` | Hype/Audience UI root |
| `StarterGui.ProfileGui` | profile UI |
| `StarterPlayer/StarterPlayerScripts/UIUXMenuController.client.lua` | central menu API and prompt/menu routing |
| `StarterPlayer/StarterPlayerScripts/RhythmClient.client.lua` | rhythm HUD, SongSelect, song start, note input |
| `StarterPlayer/StarterPlayerScripts/StoreClient.client.lua` | StoreGui interactions |
| `StarterPlayer/StarterPlayerScripts/AudienceClient.client.lua` | Audience/Hype client interactions |
| `StarterPlayer/StarterPlayerScripts/HordeClient.client.lua` | horde meter/sector visuals |

## Remotes/events

From `ReplicatedStorage/Shared/Config.lua` and `GameBootstrap.server.lua`:

- `StartSongRequest`: client requests song start.
- `StartSong`: existing compatibility remote name in config.
- `NoteHit`: client sends note-hit candidate payload.
- `NoteJudged`: server/client scoring update flow.
- `ScoreUpdate`: score state update.
- `SongFinished`: song completion/results.
- `UseBuff`, `UseAttack`, `AudienceAction`: gameplay actions.
- `PurchaseItem`, `EquipItem`, `ClaimMission`, `DataSnapshot`: economy/profile/mission flows.
- `OpenSongSelect`: vendor/nav opens SongSelect.
- `OpenMenu`: WorldV2 vendor prompt opens non-SongSelect menus.
- `HordeUpdate`: horde distance/stability + `sectorHealths`, `activeSectorId`, `sectorPressure`, `sectorAngles`, `warningSectorId`.

## Current playable song chart modules

Playable direct `ReplicatedStorage.Shared` modules: `Chart_LocalAudioSong001`, `005`, `008`, `009`, `011`, `015`, `016`, `017`, `018`, `021`, `022`, `024`, `026`, `027`, `028`, `032`, `033`, `036`, `037`, `038`, `039`.

Uked/quarantined chart modules under `ReplicatedStorage.Shared.UkedCharts`: `002`, `003`, `004`, `006`, `007`, `010`, `012`, `013`, `014`, `019`, `020`, `023`, `025`, `029`, `030`, `031`, `034`, `035`.

## Current horde logic

| File | Exact behavior |
| --- | --- |
| `ServerScriptService/Services/HordeService.lua` | keeps old `distance`, `stability`, `state`, `intensity`, `disasterMode`; adds 8-sector `sectorHealths`, `activeSectorId`, `sectorPressure`, `sectorAngles`, `warningSectorId`; miss damages active sector; perfect streak repairs weakest sector; finish repairs all sectors |
| `StarterPlayer/StarterPlayerScripts/HordeClient.client.lua` | reads sector payload if present; animates `Workspace.GTH_WorldV2.HordeRing.HordeSector_*`; does not crash if sector data missing |

## Current bugs found / guarded

| Bug | Status |
| --- | --- |
| `GameBootstrap` used to contain large V1 procedural map generation and Stage-first visuals | Fixed: delegated to `WorldV2Builder`, active world root is `Workspace.GTH_WorldV2` |
| Existing `ensurePart` early-return risk | Guarded by builder-local `part()` that updates size/CFrame/Anchored/CanCollide/Transparency/Material on every call |
| Billboard word-soup risk | Guarded: WorldV2 uses `SurfaceGui` labels; `WorldValidation` rejects unsafe BillboardGui settings |
| AntiExploit latency always-miss risk | Guarded: `ValidateNoteHit` reads/trusts `payload.clientDelta` only inside visual window and latency grace; duplicate/wrong-lane tests exist |
| Old `workspace.Stage` primary prompt paths | Fixed: prompt station definitions use `Workspace.GTH_WorldV2.VendorRing.*` and `AudienceRing.AudienceHypeManager`; Stage has ObjectValue compatibility only |
| Missing repo skill files requested by user | UNKNOWN location; skill names were not present under repo, `~/.codex/skills`, or `~/.agents/skills`; work performed directly against each named skill contract |

## Exact files modified for this pass

See final proof table. Core implementation files: `GameBootstrap.server.lua`, `WorldV2Builder.lua`, `AssetAuditService.lua`, `VendorPromptService.lua`, `CircularHordeVisualService.lua`, `WorldV2Config.lua`, `AssetRegistry.lua`, `VendorDefinitions.lua`, `HordeSectorDefinitions.lua`, `WorldValidation.lua`, `UnitTests.lua`, `UIUXMenuController.client.lua`, and docs.
