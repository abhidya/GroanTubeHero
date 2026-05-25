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

## 2026-05-25 synced Studio asset-source status

MCP validation against active `GroanTubeHero.synced.rbxlx` found the manifest-listed local source assets are not present in the synced DataModel:

| Source path | MCP status | Promotion status |
| --- | --- | --- |
| `Workspace.Unused_MapAssets` | Missing | Blocked; cannot audit/promote horde/crowd templates. |
| `Workspace.Stage.StagePlatform` and other imported Stage art | Absent from active Stage; Stage is compatibility folder only | Blocked; cannot audit/promote stage/vendor/speaker/volcano assets. |
| `Workspace.TourBus` | Missing in runtime probe | Blocked; cannot audit/promote tour bus dressing. |
| `ReplicatedStorage.ArtAssets.WorldV2_SafeProceduralKit` | Present | Project-owned scaffold only; not countable toward final 500 audited placed art requirement. |

No Creator Store asset IDs were imported or trusted in this pass. No scripts were promoted into active `Workspace.GTH_WorldV2`.

## 2026-05-25 Creator Store MCP promoted assets

| Source asset ID/path | Cleaned ArtAssets path | Used WorldV2 path | Scripts quarantined | Counted art parts | Purpose |
| --- | --- | --- | ---: | ---: | --- |
| Creator Store `84533917908730` from query `concert stage truss speaker lights` | `ReplicatedStorage.ArtAssets.Stage.Clean_ConcertStageTrussSpeakerLights` | `Workspace.GTH_WorldV2.StageCircle.Audited_StageCore_ConcertRig`; `LightingAnchors.Audited_Lighting_TrussRig_N`; `FenceRing.Audited_FenceRing_BarricadeRig` | 0 | 954 | stage core, truss/lights, fence dressing |
| Creator Store `148933335` from query `cartoon monster npc horde` | `ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde` | 8 horde sector `Audited_HordeMonsterPack_*`; `AudienceRing.Audited_Audience_CrowdMonsterPack` | 45 | 1008 | horde and crowd characters |
| Creator Store `7979344076` from query `volcano rock lava cliff` | `ReplicatedStorage.ArtAssets.Volcano.Clean_VolcanoRockLavaCliff` | `VolcanoOuterRing.Audited_VolcanoCliff_1..8` | 0 | 80 | volcanic outer ring |
| Creator Store `101846227525981` from query `stadium crowd seats` | `ReplicatedStorage.ArtAssets.Audience.Clean_StadiumCrowdSeats` | Imported then hidden/excluded from active count because it looked like a giant football stadium slab near spawn | 16 | 0 active | rejected/hidden after visual audit |
| Creator Store `14660776730` from query `vendor kiosk shop counter` | `ReplicatedStorage.ArtAssets.Vendors.Clean_VendorKioskShopCounter` | `VendorRing.Audited_VendorRing_KioskSet`; `Workspace.GTH_WorldV2.Audited_TourBusSpawn_PathDressing` | 2 | 206 | vendor ring and spawn/path dressing |

Total scripts quarantined from imported assets: 63. Active `Workspace.GTH_WorldV2` script descendants after validation: 0.

## 2026-05-25 Phase X latest placement manifest update

Latest runtime proof uses clean visual models already promoted into `ReplicatedStorage.ArtAssets`; no script descendants exist under active `Workspace.GTH_WorldV2`.

| Source asset ID/path | Cleaned ArtAssets path | Used WorldV2 path | Scripts under clean copy | Latest counted active art parts | Purpose |
| --- | --- | --- | ---: | ---: | --- |
| Creator Store `84533917908730` from prior audited import `concert stage truss speaker lights` | `ReplicatedStorage.ArtAssets.Stage.Clean_ConcertStageTrussSpeakerLights` | `Workspace.GTH_WorldV2.StageCircle.Audited_Stage_ConcertRig_Fitted`; `LightingAnchors.Audited_Lighting_ConcertRig_1..4` | 0 | 1580 | stage core and concert light/truss dressing |
| Creator Store `148933335` from prior audited import `cartoon monster npc horde` | `ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde` | 8 sector `HordeCluster.Audited_HordePack_*` | 0 | 896 | horde monster clusters, visible sector pressure |
| Creator Store `7979344076` from prior audited import `volcano rock lava cliff` | `ReplicatedStorage.ArtAssets.Volcano.Clean_VolcanoRockLavaCliff` | `VolcanoOuterRing.Audited_VolcanoCliff_1..8` | 0 | 80 | volcanic/lava horizon ring |
| Creator Store `14660776730` from prior audited import `vendor kiosk shop counter` | `ReplicatedStorage.ArtAssets.Vendors.Clean_VendorKioskShopCounter` | `VendorRing.*.Audited_Kiosk_*`; `AudienceRing.AudienceHypeManager.Audited_Kiosk_AudienceHypeManager` | 0 | 721 | vendor/store/upgrade/mission/security/tutorial/hype stations |
| Project-authored `CursedLavaBackplane` | `ServerScriptService.Services.WorldV2Builder.lua` | `Workspace.GTH_WorldV2.ArenaCore.CursedLavaBackplane` | 0 | 1 | dark ground/fall-safety plane hiding blue void from player view |

Rejected/hidden source remains: `ReplicatedStorage.ArtAssets.Audience.Clean_StadiumCrowdSeats` is retained as clean ArtAssets source but not actively placed because visual audit showed bad scale/placement risk.

## 2026-05-25 Phase X NPC / horde visual repair manifest

| Source asset ID/path | Cleaned ArtAssets path | Used WorldV2 path | Scripts under active clone | Purpose |
| --- | --- | --- | ---: | --- |
| `ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde` | same clean ArtAssets path | `VendorRing.*.Audited_RoleNPC_*`; `AudienceRing.AudienceHypeManager.Audited_RoleNPC_AudienceHypeManager`; `TourBusAndSpawnDressing.Audited_TourBusManagerNPC` | 0 | Visible brainrot NPCs for all major stations. |
| `ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde` | same clean ArtAssets path | `HordeRing.HordeSector_*.HordeCluster.Audited_BrainrotHordeNPCPack_*_1..4` | 0 | Replaces procedural block horde monsters with audited brainrot NPC packs. |
| `ReplicatedStorage.ArtAssets.Vendors.Clean_VendorKioskShopCounter` | same clean ArtAssets path | `VendorRing.*.Audited_RoleProps_Left_*`; `VendorRing.*.Audited_RoleProps_Right_*`; `TourBusAndSpawnDressing.Audited_BackstageMerchProps` | 0 | Store/Upgrade/Mission/Security/Tutorial/Hype prop dressing. |
| `ReplicatedStorage.ArtAssets.Stage.Clean_ConcertStageTrussSpeakerLights` | same clean ArtAssets path | `FenceRing.Audited_FenceBarricadeRig_1..8`; `TourBusAndSpawnDressing.Audited_BackstageDepotRig` | 0 | Fence/security dressing and backstage/tour area dressing. |

Sanitization: cloned art now removes imported `ProximityPrompt`/`ClickDetector`, destroys scripts/modules, disables imported Billboard/Surface GUIs, and hides imported Humanoid name/health displays.
