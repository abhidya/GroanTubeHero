# Real Asset Manifest

No hardcoded Creator Store asset IDs are trusted or used in current WorldV2 pass.

| Asset source ID/path | Original import root | Cleaned path | Used path | Scripts quarantined | Purpose |
| --- | --- | --- | --- | --- | --- |
| Project-owned procedural WorldV2 parts | ServerScriptService.Services.GameBootstrap.server.lua | ReplicatedStorage.ArtAssets.WorldV2_SafeProceduralKit | Workspace.GTH_WorldV2 | 0 | Safe circular arena, vendors, horde/fence sectors |

Creator Store candidate IDs from previous prompt remain unaudited and unused. Any future import must enter `ServerStorage.AssetQuarantine` or `Workspace.AssetInbox`, pass audit, quarantine scripts, then copy clean models into `ReplicatedStorage.ArtAssets` before use.
