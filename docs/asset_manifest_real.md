# Real Asset Manifest

No hardcoded Creator Store asset IDs are trusted or used in current WorldV2 pass.

This manifest records user-supplied live-place asset inventory plus current WorldV2 cleaned/procedural source. Local Studio assets are safer than random Creator Store IDs, but they still require audit before becoming active WorldV2 art.

## Current WorldV2 active art source

| Asset source ID/path | Original import root | Cleaned path | Used path | Scripts quarantined | Purpose |
| --- | --- | --- | --- | ---: | --- |
| Project-owned procedural WorldV2 parts | `ServerScriptService.Services.GameBootstrap.server.lua` | `ReplicatedStorage.ArtAssets.WorldV2_SafeProceduralKit` | `Workspace.GTH_WorldV2` | 0 | Safe circular arena, vendors, horde/fence sectors |

## Live Studio local source candidates

These are listed in the supplied place-file manifest under `Workspace.Unused_MapAssets`, `Workspace.Stage`, and `Workspace.TourBus`. Before use in WorldV2, copy into quarantine/inbox, run `AssetAuditService`, quarantine scripts, then copy clean models into `ReplicatedStorage.ArtAssets`.

### Unactivated package: `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME)`

| Source path | Class | Intended destination | WorldV2 status | Purpose |
| --- | --- | --- | --- | --- |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).Ungroup in MaterialService.Universal` | `MaterialVariant` | `game.MaterialService` | Candidate, audit before activation | Floor material texture |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).Ungroup in MaterialService.Studs` | `MaterialVariant` | `game.MaterialService` | Candidate, audit before activation | Walkway texture |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).Ungroup in MaterialService.Inlet` | `MaterialVariant` | `game.MaterialService` | Candidate, audit before activation | Path texture |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...Atmosphere` | `Atmosphere` | `game.Lighting` | Candidate, audit before activation | Green/orange toxic haze |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...DarkSky` | `Sky` | `game.Lighting` | Candidate, audit before activation | Volcanic skybox |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...Bloom` | `BloomEffect` | `game.Lighting` | Candidate, audit before activation | Neon bloom |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...Blur` | `BlurEffect` | `game.Lighting` | Candidate, audit before activation | Depth blur |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...ColorCorrection` | `ColorCorrectionEffect` | `game.Lighting` | Candidate, audit before activation | Toxic tint |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...DepthOfField` | `DepthOfFieldEffect` | `game.Lighting` | Candidate, audit before activation | Cinematic focus |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...SunRays` | `SunRaysEffect` | `game.Lighting` | Candidate, audit before activation | Solar rays |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).Ungroup in ReplicatedStorage.Waves` | `Folder` | `game.ReplicatedStorage` | Candidate, audit before activation | Sound-wave/effects resources |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).Ungroup in ReplicatedStorage.Remotes` | `Folder` | `game.ReplicatedStorage` | Ignore | Preserve project-owned remotes |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).Ungroup in workspace` | `Folder` | `game.Workspace` | Ignore | Empty folder |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).ungroup in starterpack` | `Folder` | `game.StarterPack` | Ignore | Empty folder |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).ungroup in ServerScriptService` | `Folder` | `game.ServerScriptService` | Ignore | Empty folder |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME).ungroup in startergui` | `Folder` | `game.StarterGui` | Ignore | Empty folder |

### Legacy `Workspace.Stage` art candidates

| Source path | Class | WorldV2 status | Purpose |
| --- | --- | --- | --- |
| `Workspace.Stage.StagePlatform` | `Model` | Candidate; copy/audit before V2 use | Primary stage mesh, 25 meshparts/sub-models |
| `Workspace.Stage.SpeakerStacks` | `Folder` | Candidate; copy/audit before V2 use | `SpeakerStack1` and `SpeakerStack2` thumping speaker models |
| `Workspace.Stage.StoreKiosk` | `Model` | Candidate; copy/audit before V2 use | Register kiosk/cash register meshes |
| `Workspace.Stage.MicrophoneStand` | `Model` | Candidate; copy/audit before V2 use | Metallic microphone stand meshes |
| `Workspace.Stage.StartPrompt` | `Part` | Legacy anchor only; do not use as primary V2 path | Old song selector pad |
| `Workspace.Stage.SingerSpot` | `Part` | Candidate/invisible anchor only | Singer spot pad |
| `Workspace.Stage.AudienceZone` | `Part` | Legacy/invisible anchor only | Old crowd zone trigger |
| `Workspace.Stage.MissionBoard` | `Part` | Legacy anchor only; do not use as primary V2 path | Old missions UI board |
| `Workspace.Stage.UpgradeKiosk` | `Part` | Legacy anchor only; do not use as primary V2 path | Old upgrades UI kiosk |
| `Workspace.Stage.LED panel` | `Part` | Candidate; copy/audit before V2 use | Equalizer wall display panel |
| `Workspace.Stage.BrainrotBackdrop` | `Folder` | Candidate; copy/audit before V2 use | 14 volcano rock meshes and lava mouth parts |
| `Workspace.Stage.Spotlights` | `Folder` | Candidate; copy/audit before V2 use | 8 `GTH_LightPole_*` spotlight poles |
| `Workspace.Stage.CleanSigns` | `Folder` | Candidate SurfaceGui signage only; no duplicate BillboardGui spam | 7 signage parts |

### Brainrot horde templates: `Workspace.Unused_MapAssets`

| Source path | Class | Count | WorldV2 status | Purpose |
| --- | --- | ---: | --- | --- |
| `Workspace.Unused_MapAssets` character models | `Model` | 98 | Candidate; audit each model before active use | Horde/crowd templates |

Key candidate templates: `Sammyni_Spyderini`, `Unclito_Samito`, `Orangutini Ananassini`, `La_Vacca_Saturno_Saturnita`, `Cavallo_Virtuoso`, `Trippi_Troppi`, `Sigma Boy`, `Trenostruzzo_Turbo_3000`, `Boneca Ambalabu`, `Bananita Dolphinita`, `Noobini Pizzanini`, `Burbaloni Loliloli`, `Gattatino Neonino`, `Tim Cheese`, `Tukanno Bananno`.

### Tour bus candidates: `Workspace.TourBus`

| Source path | Class | WorldV2 status | Purpose |
| --- | --- | --- | --- |
| `Workspace.TourBus.BusBody` | `Model` | Candidate; copy/audit before V2 use | Concert tour bus body |
| `Workspace.TourBus.Wheel1` through `Workspace.TourBus.Wheel4` | `Part` | Candidate; copy/audit before V2 use | Cylinder wheels |

## Summary counts

| Metric | Count | Counting rule |
| --- | ---: | --- |
| Current active WorldV2 ArtAssets source models | 1 | `ReplicatedStorage.ArtAssets.WorldV2_SafeProceduralKit` |
| Current active WorldV2 scripts under world | 0 | MCP validation / `WorldValidation` |
| Unactivated package entries | 16 rows / 14 asset-bearing entries per Studio summary | Rows above include ignored empty folders/remotes; user-supplied Studio summary labels 14 package assets |
| Stage candidate rows | 13 | Exact `Workspace.Stage` roots listed above |
| Brainrot horde template models | 98 | Local Studio models under `Workspace.Unused_MapAssets` |
| Tour bus candidate rows | 2 | Bus body + wheel group |
| Total descendants across map assets | 8,710 | Live Studio inventory figure supplied by manifest |

Creator Store candidate IDs from previous prompt remain unaudited and unused. Future imports must enter `ServerStorage.AssetQuarantine` or `Workspace.AssetInbox`, pass audit, quarantine all scripts unless project-owned and rewritten, then copy clean models into `ReplicatedStorage.ArtAssets` before use.
