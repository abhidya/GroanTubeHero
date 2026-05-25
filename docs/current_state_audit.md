# Current State Audit - Groan Tube Hero

This document records legacy V1 place structure and how it maps into hardened `WorldV2`. `Workspace.GTH_WorldV2` is primary active rebuild root; legacy `Workspace.Stage` paths are source/compatibility only.

---

## 1. Live Studio Roots Observed

- `Workspace.GTH_WorldV2`: current circular WorldV2 root built/validated by MCP.
- `Workspace.Stage`: legacy V1 stage art and anchors; not primary WorldV2 structure.
- `Workspace.TourBus`: legacy tour bus art source candidate.
- `Workspace.Unused_MapAssets`: imported local package assets and 98 brainrot template models.

---

## 2. Legacy Objects Designated for Archival / Compatibility

Archive only explicit V1/placeholder visuals, not every Workspace child outside WorldV2.

| Legacy path | Disposition | Reason |
| --- | --- | --- |
| `Workspace.Stage.ArenaFloor` | Archive/hide if present | Rectangular generated floor |
| `Workspace.Stage.LavaMoat` | Archive/hide if present | Placeholder moat block |
| `Workspace.Stage.StageTopGlow` | Archive/hide if present | Procedural neon indicator plate |
| `Workspace.Stage.HordeLane` | Archive/hide if present | Single rectangular horde lane |
| `Workspace.Stage.BrainrotClimbRamp` | Archive/hide if present | Blocky V1 ramp |
| `Workspace.Stage.StoreKiosk` / `UpgradeKiosk` / `MissionBoard` | Copy/audit useful art or keep invisible compatibility anchors only | Old primary vendor paths replaced by `Workspace.GTH_WorldV2.VendorRing.*` |
| `Workspace.Stage.SpeakerStacks` | Source candidate only | Copy/audit before V2 art use |
| `Workspace.Stage.AudienceZone` | Invisible trigger/compat only | Old crowd zone visual not primary V2 audience ring |
| `Workspace.Stage.CleanSigns` | Source signage candidate only | Avoid duplicate BillboardGui spam |
| `Workspace.Stage.Spotlights` | Source candidate only | Copy/audit before V2 art use |

Never archive: `Camera`, `Terrain`, player characters, `Workspace.Unused_MapAssets`, `Workspace.AssetInbox`, `SpawnLocation` until replacement spawn exists, active runtime folders, or `Workspace.GTH_WorldV2`.

---

## 3. UI/Menu Hierarchy Audit

Active screen interfaces reside under `StarterGui` / `PlayerGui`:

- `RhythmHUD`: gameplay note highway and touch lanes.
- `NavigationMenu`: lobby menu buttons.
- `SongSelect`: playable chart list.
- `StoreGui`: shop interface.
- `UpgradeGui`: upgrade interface.
- `MissionGui`: mission interface.
- Optional/created menus: `SecurityGui`, `TutorialGui`, `HypeGui`, `ResultsGui`, `SettingsGui`, `PauseGui` when present.

`StarterPlayer.StarterPlayerScripts.UIUXMenuController.client.lua` is central controller. Required API: `openMenu`, `closeMenu`, `closeTopMenu`, `closeAllMenus`, `back`, `isMenuOpen`, `setGameMode`, `showNavigation`, `hideNavigation`, `openResults`, `restoreLobbyState`.

---

## 4. Network Remotes & Event Mapping

Communication uses `ReplicatedStorage.Remotes`:

- `StartSong` (`RemoteFunction`): client starts a chart session.
- `NoteJudged` (`RemoteEvent`): server broadcasts scoring judgements.
- `HordeUpdate` (`RemoteEvent`): server broadcasts horde state. WorldV2 payload adds `sectorHealths`, `activeSectorId`, and sector pressure data while preserving old distance/stability compatibility fields.
- `SongComplete` (`RemoteEvent`): server signals chart completion.

---

## 5. Local Asset Sources Available For Audit

These are real place-file sources, not Creator Store IDs:

- `Workspace.Stage.StagePlatform`: textured stage mesh candidate.
- `Workspace.Stage.SpeakerStacks.SpeakerStack1` and `SpeakerStack2`: speaker model candidates.
- `Workspace.Stage.MicrophoneStand`: microphone stand candidate.
- `Workspace.Stage.BrainrotBackdrop`: volcano/cliff candidate meshes.
- `Workspace.Unused_MapAssets`: 98 brainrot character template candidates.
- `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME)`: MaterialService, Lighting, and Waves package candidates.
- `Workspace.TourBus`: bus body/wheel candidates.

Rule: copy local candidates into `ServerStorage.AssetQuarantine` or `Workspace.AssetInbox`, run `AssetAuditService`, quarantine scripts, then publish clean copy under `ReplicatedStorage.ArtAssets`. Until then, they are source candidates, not active WorldV2 proof counts.

---

## 6. Known Codebase Bugs Addressed / Guarded

1. `AntiExploitService.lua`: timing validation must account for client/network offset; do not regress into always-miss behavior.
2. `GameBootstrap.server.lua`: `ensurePart` must update existing runtime anchors instead of early-returning stale CFrames/sizes.
3. `GameBootstrap.server.lua`: `createBillboard` must keep `AlwaysOnTop=false`, `MaxDistance<=40`, and avoid duplicate label spam.
4. `HordeClient.client.lua`: horde visuals should respect server sector data and not force V1 under-stage placement.
5. `RhythmClient.client.lua` / `UIUXMenuController.client.lua`: closing modals must restore NavigationMenu in lobby and never trap user.

---

## 7. Modified Codebase Files For WorldV2

- `ServerScriptService/Services/GameBootstrap.server.lua`
- `ServerScriptService/Services/HordeService.lua`
- `ServerScriptService/Services/AntiExploitService.lua`
- `ReplicatedStorage/Shared/SongCatalog.lua`
- `StarterPlayer/StarterPlayerScripts/UIUXMenuController.client.lua`
- `StarterPlayer/StarterPlayerScripts/RhythmClient.client.lua`
- `StarterPlayer/StarterPlayerScripts/HordeClient.client.lua`
- `ReplicatedStorage/Shared/WorldV2/PolarLayout.lua`
- `ReplicatedStorage/Shared/WorldV2/AssetAuditService.lua`
- `ReplicatedStorage/Shared/WorldV2/WorldValidation.lua`
- `ReplicatedStorage/Shared/WorldV2/UIUXValidation.lua`
- `ReplicatedStorage/Shared/UnitTests.lua`
- `ReplicatedStorage/Shared/GameTestHarness.lua`
