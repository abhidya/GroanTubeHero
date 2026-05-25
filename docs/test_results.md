# Test Results

Date: 2026-05-25

## Post-team Studio MCP live Play rerun — 2026-05-25

| Test | Result | Notes |
| --- | --- | --- |
| Direct Studio MCP reconnect | PASS | `StudioMCP --stdio` listed active Studio `Groan Tube Hero` (`659903e1-c39b-46a7-820b-0b7623a1305f`). |
| Studio Play start/stop | PASS | `start_stop_play` stopped edit mode, started Play, ran validation after Play boot, then stopped cleanly. |
| `WorldValidation.Run()` in Play | PASS | `ok=true`; activePlacedArtInstances `14778`; scripts under WorldV2 `0`; visible placeholder violations `0`; unaudited placements `0`; missing required assets `0`. |
| `UnitTests.Run()` in Play | PASS | `failed=0`, `passed=14`. |
| `GameTestHarness.Run()` in Play | PASS | Session `Harness-LocalAudioSong001-3952445`; score `4725`; max combo `38`; grade `A`; misses `0`. |
| Horde/fence runtime visual proof | PASS | `massBrainrotNPCModels=512`, `visibleHordeParts=3680`, `visibleHordeFigureBlocks=0`, `visibleFenceParts=2608`. |
| Bad sound asset scan | PASS | `badSoundCount=0` for `rbxassetid://3144620759`. |
| Billboard safety scan | PASS | `billboardUnsafe=0`. |

### Post-team Studio MCP counts

| Count | Value |
| --- | ---: |
| Active WorldV2 Models | 2548 |
| Active WorldV2 MeshParts | 80 |
| Active visible BaseParts | 14778 |
| Active placed art instances | 14778 |
| Stage/core art | 412 |
| Lighting/trusses art | 1408 |
| Vendor ring art | 2591 |
| Fence ring art | 2608 |
| Horde ring art | 3680 |
| Audience ring art | 3338 |
| Volcano outer ring art | 80 |
| Tour bus/spawn art | 661 |
| Mass brainrot NPC models | 512 |
| Invisible hitboxes | 6 |
| Vendor prompts | 16 |
| Horde sectors | 8 |
| Scripts under `Workspace.GTH_WorldV2` | 0 |
| Visible placeholder violations | 0 |
| Unaudited visible placements | 0 |


## Post-team finish pass validation — 2026-05-25

| Test | Result | Notes |
| --- | --- | --- |
| OMX team `groantubehero-finish-3df4a4b5` | PASS | 7/7 tasks completed; worker commits merged for prompt repair, horde movement, UI outcomes, validation gates, and script-free world audit. |
| Vendor prompt repair path | PASS | `VendorPromptService.lua` now defines `fireDialogue`, sends `NPCDialogue`, preserves `OpenSongSelect`/`OpenMenu`, and calls `HordeService:RepairSector` after repair dialogue. |
| Menu option outcomes | PASS | Store/Upgrades/Missions/Security/Tutorial/Hype/Tour Bus tabs now show a visible outcome banner or action card; undefined `showOutcome` merge bug removed. |
| Horde movement polish | PASS | `HordeService`/`HordeClient` preserve old payload fields and add `movementCue`, `movementEventId`, stronger active-sector push/pull, warning sector visuals, repair cues, and finish beatback. |
| `rojo build default.project.json --output /private/tmp/GroanTubeHero-postteam-fixed.rbxlx` | PASS | Built latest repo scripts successfully without `rojo serve`. |
| `git diff --check` | PASS | No whitespace/conflict-marker errors after team merge and UI hotfix. |
| Conflict-marker/undefined outcome scan | PASS | `rg 'showOutcome|<<<<<<<|=======' StarterPlayer ServerScriptService ReplicatedStorage` returned no matches. |
| Studio MCP post-team runtime | PASS | Superseded by the live Play rerun above: `WorldValidation.Run()`, `UnitTests.Run()`, and `GameTestHarness.Run()` all passed through Studio MCP after reconnect. |
| Luau CLI syntax | NOT CONFIGURED | No `luau`/`lune` executable in PATH; system `luac` is Lua 5.1 and rejects valid Luau operators such as `+=`, so it is not a valid parser for this repo. |


## Latest validation summary — direct Studio MCP live Play PASS

| Test | Result | Notes |
| --- | --- | --- |
| Direct Roblox Studio MCP | PASS | Connected through `StudioMCP --stdio`; active Studio set to `GroanTubeHero.synced.rbxlx` (`659903e1-c39b-46a7-820b-0b7623a1305f`). |
| Rojo build | PASS | `rojo build default.project.json -o /private/tmp/GroanTubeHero-billboardfix.rbxlx` completed. |
| `git diff --check` | PASS | No whitespace errors after current horde/fence/billboard fix. |
| Bad audio asset scan | PASS | `rbxassetid://3144620759` removed from live Studio validation path and repo/zip scans; runtime `badSoundCount=0`. |
| Studio source sync | PASS | Live `WorldV2Builder.Source` contains `local hordeTemplates = collectHordeCharacterTemplates(...)` and BillboardGui clamp (`MaxDistance <= 40`). |
| Play start/stop | PASS | MCP `start_stop_play` started and stopped Studio Play cleanly. |
| `WorldValidation.Run()` in Play | PASS | `ok=true`; no placeholder, unaudited placement, script-under-world, or billboard violations. |
| `UnitTests.Run()` in Play | PASS | `failed=0`, `passed=13`. |
| `GameTestHarness.Run()` in Play | PASS | Session `Harness-LocalAudioSong001-1936522`; 38 note simulation; summary score `4725`, max combo `38`, grade `A`, misses `0`. |
| Horde visual runtime | PASS | `massBrainrotNPCModels=512`, `visibleHordeParts=3680`, `visibleHordeFigureBlocks=0`; orange procedural horde blocks not visible. |
| Fence visual runtime | PASS | `visibleFenceParts=2608`; fence ring is visible in Play. |
| Unsafe BillboardGui runtime | PASS | `billboardUnsafe=0` after clamping imported tour bus BillboardGuis to `AlwaysOnTop=false`, `MaxDistance<=40`. |

### Latest direct Studio MCP counts

| Count | Value |
| --- | ---: |
| Active WorldV2 Models | 2548 |
| Active WorldV2 MeshParts | 80 |
| Active WorldV2 visible BaseParts | 14778 |
| Active placed art instances | 14778 |
| Stage/core art | 412 |
| Lighting/trusses art | 1408 |
| Vendor ring art | 2591 |
| Fence ring art | 2608 |
| Horde ring art | 3680 |
| Audience ring art | 3338 |
| Volcano outer ring art | 80 |
| Tour bus/spawn art | 661 |
| Mass brainrot NPC models | 512 |
| Visible procedural `HordeFigure_*` blocks | 0 |
| Invisible hitboxes | 6 |
| Vendor prompts | 16 |
| Horde sectors | 8 |
| Scripts under `Workspace.GTH_WorldV2` | 0 |
| Missing required assets | 0 |
| Visible placeholder violations | 0 |
| Unaudited visible placements | 0 |
| Unsafe BillboardGui count | 0 |

## Latest validation summary — Rojo synced, playable placement repaired

| Test | Result | Notes |
| --- | --- | --- |
| Rojo serve | PASS | `rojo` listening on `127.0.0.1:34872`; active Studio is `GroanTubeHero.synced.rbxlx`. |
| Studio script sync | PASS | MCP `script_read` confirmed latest `WorldV2Builder` has `ProjectOwned/ReadableWorldV2Art`, `GlowingStageMicPrompt`, AssetInbox hiding, and spawn `0,2,-30`; `HordeService.RepairSector` and repair prompt binding are present. |
| `git diff --check` | PASS | Run after readable placement/playability fix. |
| `rojo build default.project.json -o /private/tmp/GroanTubeHero.verify.rbxlx` | PASS | Built latest synced repo. |
| `rojo build default.project.json -o GroanTubeHero.synced.repo-built.rbxlx` | PASS | Packaged latest repo scripts into a reproducible rbxlx evidence file. |
| Studio edit-mode `WorldValidation.Run()` | PASS | `activePlacedArtInstances=1370`, `visibleBaseParts=1370`, `stageCore=141`, `vendorRing=90`, `fenceRing=64`, `hordeRing=481`, `audienceRing=219`, `volcanoOuterRing=196`, `tourBusAndSpawn=43`, placeholders=0, unaudited placements=0. |
| Studio play movement to mic | PASS | Humanoid `MoveTo(0,3,0)` reached within `1.89` studs; floor material `Slate`; player did not fall. |
| Glowing stage mic prompt | PASS | Prompt path `Workspace.GTH_WorldV2.StageCircle.GlowingStageMicPrompt.ProximityPrompt`; action `Choose Song`; menu `SongSelect`; distance from player `1.93`; enabled=true. |
| `require(ReplicatedStorage.Shared.UnitTests).Run()` in Studio | PASS | `failed=0`, `passed=11`. |
| `require(ReplicatedStorage.Shared.GameTestHarness).Run()` in Studio | PASS | Harness returned valid song session and result summary; simulated note judgments completed. |
| Screenshot evidence | PASS | Captured `WorldV2_Play_MicReachable_ClearFloor`; view shows reachable glowing mic prompt, circular stage/fence/horde ring, vendors, no AssetInbox wall. |
| Studio Cmd+S save | BLOCKED | MCP has no save-place tool; `game:SavePlace()` failed because placeID is not valid; GUI `osascript` Cmd+S failed due macOS Accessibility denial. |


## 2026-05-25 fall-through hotfix

| Check | Result | Notes |
| --- | --- | --- |
| WorldV2 physics lock | PASS | `WorldV2Builder` locks every `Workspace.GTH_WorldV2` BasePart anchored on build; fresh play reported `PhysicsLockedParts=7126`. |
| Spawn safety | PASS | `GameBootstrap.server.lua` now teleports spawned characters to `Workspace.GTH_WorldV2.SpawnLocation` and rescues Y < -20 for the first 20 seconds. |
| Studio play no-fall check | PASS | After 3 seconds in play: character `Y=5.724`, state `Running`, floor material `Neon`; `SafeWalkableConcertFloor` anchored/collidable; spawn anchored. |
| Move to stage mic | PASS | Humanoid `MoveTo(0,3,0)` ended `distance=0.69` from mic/stage center, `Y=9.22`, state `Running`; did not fall through. |
| UnitTests after hotfix | PASS | Studio `UnitTests.Run()` returned `failed=0`, `passed=11`. |
| GameTestHarness after hotfix | PASS | Studio `GameTestHarness.Run()` returned session `Harness-LocalAudioSong001-4336577`. |
| OMX team runtime | BLOCKED | `omx team 4:executor ...` failed with `Team mode requires running inside tmux current leader pane`; native subagents used for sidecar audit instead. |

## Current counts from fresh Studio validation

| Count | Value |
| --- | ---: |
| Active WorldV2 Models | 878 |
| Active WorldV2 MeshParts | 89 |
| Active WorldV2 visible BaseParts | 1370 |
| Active placed art instances | 1370 |
| Stage/core art | 141 |
| Lighting/trusses art | 136 |
| Vendor ring art | 90 |
| Fence ring art | 64 |
| Horde ring art | 481 |
| Audience ring art | 219 |
| Volcano outer ring art | 196 |
| Tour bus/spawn art | 43 |
| Invisible hitboxes | 42 |
| Quarantined scripts | 63 |
| Horde sectors | 8 |
| Missing required assets | 0 |
| Visible placeholder violations | 0 |
| Unaudited visible placements | 0 |

---

Date: 2026-05-25

## Latest validation summary — synced Studio + 500 placed-art gate

| Test | Result | Notes |
| --- | --- | --- |
| Active Studio target | PASS | MCP active place `GroanTubeHero.synced.rbxlx`; `ReplicatedStorage.Shared`, `UnitTests`, `GameTestHarness`, `WorldV2` modules present after Rojo sync. |
| `git diff --check` | PASS | Run after UI/result responsive fixes and placement-gate hardening. |
| `rojo build default.project.json -o /private/tmp/GroanTubeHero.verify.rbxlx` | PASS | Built synced project successfully. |
| `require(ReplicatedStorage.Shared.UnitTests).Run()` in Studio | PASS | `failed=0`, `passed=11`. |
| `UIUXValidation.Run()` in Studio | PASS | Desktop, laptop, iPad, iPhone, and small-phone viewport checks passed after SongSelect/Results responsive fixes. |
| `WorldValidation.Run()` in Studio | BLOCKED | New 500+ audited art gate correctly fails: activePlacedArtInstances=0; required=500; synced place has no `Workspace.Unused_MapAssets` or real imported Stage/TourBus asset sources to promote. |
| `GameTestHarness.Run()` in Studio | BLOCKED | Harness now runs WorldValidation in all contexts and fails on the same 500+ audited art gate; gameplay simulation still builds/hits notes before the asset gate. |

## Latest synced Studio asset-source probe

| Source | Result | Evidence |
| --- | --- | --- |
| `Workspace.Unused_MapAssets` | MISSING | MCP `SyncAssetSourceProbe.unused.missing=true`. |
| `Workspace.TourBus` | MISSING in play | MCP `SyncAssetSourceProbe.tour.missing=true`. |
| `Workspace.Stage` imported art | ABSENT | MCP Stage exists only as compatibility folder: 6 children, 0 BaseParts, 0 MeshParts, 0 Models. |
| `ReplicatedStorage.ArtAssets` | PRESENT but insufficient | 1 model (`WorldV2_SafeProceduralKit`), 0 BaseParts, 0 MeshParts, 0 scripts. |
| `Workspace.GTH_WorldV2` | PRESENT | 15 Models, 229 BaseParts, 0 MeshParts, 0 scripts; current visible world is procedural scaffold, not countable final audited art. |

## 500+ placement gate counts

| Category | Required | Actual | Result |
| --- | ---: | ---: | --- |
| stageCore | 60 | 0 | FAIL |
| lightingAndTrusses | 80 | 0 | FAIL |
| vendorRing | 60 | 0 | FAIL |
| fenceRing | 64 | 0 | FAIL |
| hordeRing | 160 | 0 | FAIL |
| audienceRing | 80 | 0 | FAIL |
| volcanoOuterRing | 80 | 0 | FAIL |
| tourBusAndSpawn | 30 | 0 | FAIL |
| total activePlacedArtInstances | 500 | 0 | FAIL |
| scriptsUnderWorldV2 | 0 | 0 | PASS |
| visible placeholder violations | 0 | 0 | PASS |

## Exact blocker

Final 500+ asset requirement is blocked by missing audited source assets in the synced Studio place. The pasted manifest lists useful assets under `Workspace.Unused_MapAssets`, `Workspace.Stage`, and `Workspace.TourBus`, but MCP against active `GroanTubeHero.synced.rbxlx` shows those imported assets are absent. I did not fake counts with procedural blocks, invisible helpers, generated NPC boxes, or unaudited Creator Store IDs.

---

Date: 2026-05-25

## Latest validation summary

| Test | Result | Notes |
| --- | --- | --- |
| `git diff --check` | PASS | Run after current WorldV2/module/docs pass. |
| Static arrow-only scan | PASS | No forbidden four-letter rhythm-key labels or letter-key lane bindings found under repo code/docs scan. |
| Static slop/asset scan | PASS | No fake asset-search comments, no inflated unique-asset claim, no unsafe candidate Creator Store IDs in active docs/code scan. |
| Song module count | PASS | 21 playable direct `ReplicatedStorage.Shared.Chart_LocalAudioSong*.lua`; 18 uked modules under `Shared.UkedCharts`. |
| Studio MCP tree access | PASS | Active Studio `GroanTubeHro` reachable via MCP. |
| Studio MCP edit-mode WorldV2 validation | PASS | `ok=true`; roots present; 8 sectors; all required sector children; all vendor prompts; 0 scripts under world; 0 placeholder violations; 0 billboard violations; 0 missing required assets. |
| Studio MCP play validation | PASS | Play started; live check `ok=true`, sectors=8, prompts=15, visible=208, scripts=0, placeholders=0, missing=0; play stopped cleanly. |
| Screenshot | PASS | Captured `WorldV2_Final_Proof_208parts`; shows circular stage/fence/horde/volcano ring and vendor/crowd stations. |
| `require(ReplicatedStorage.Shared.UnitTests).Run()` in Studio | BLOCKED | Active MCP Studio is not synced with repo modules: `ReplicatedStorage.Shared` missing in current Studio tree, so UnitTests cannot be required there. Repo file is present and expanded. |
| `require(ReplicatedStorage.Shared.GameTestHarness).Run()` in Studio | BLOCKED | Same Studio sync blocker: `ReplicatedStorage.Shared` missing. Direct MCP validation covers world facts; harness requires Rojo/project sync into Studio. |
| Selene | NOT CONFIGURED | `selene` command not found. |
| StyLua | NOT CONFIGURED | `stylua` command not found. |
| Rojo | NOT CONFIGURED | `rojo` command not found. |

## Latest counts from Studio MCP

| Count | Value |
| --- | ---: |
| Active WorldV2 Models | 15 |
| Active WorldV2 MeshParts | 0 |
| Active WorldV2 visible BaseParts | 208 |
| Invisible hitboxes | 6 |
| ArtAssets source models | 1 |
| Quarantined scripts | 0 |
| Vendor prompts | 15 live / 7 required station prompts |
| Horde sectors | 8 |
| Missing required assets | 0 |
| Visible placeholder violations | 0 |
| Billboard violations | 0 |
| Scripts under `Workspace.GTH_WorldV2` | 0 |
| Playable songs | 21 |
| Uked songs | 18 |

## Studio MCP proof details

| Check | Result | Evidence |
| --- | --- | --- |
| World roots | PASS | `ArenaCore`, `StageCircle`, `InnerPlayerRing`, `VendorRing`, `FenceRing`, `HordeRing`, `AudienceRing`, `VolcanoOuterRing`, `OuterVolcanoRing`, `LightingAnchors`, `InvisibleGameplayHitboxes`, `CompatibilityAdapters` all present. |
| Vendors | PASS | `DJ_GroanMaster`, `Vendor_Store`, `Vendor_UpgradeEngineer`, `MissionOfficer`, `SecurityManager`, `TutorialGuide`, `AudienceHypeManager` all exist with prompts and `MenuName` attributes. |
| Horde sectors | PASS | N/NE/E/SE/S/SW/W/NW exist; each has `FenceSegment`, `FenceDamageVFX`, `SecurityLight`, `SirenLight`, `HordeCluster`, `HordePressureMeter`, `WeakPointMarker`; `HordeCluster:PivotTo()` works. |
| Asset roots | PASS | `ServerStorage.AssetQuarantine`, `ServerStorage.WorldArchive`, `Workspace.AssetInbox`, `ReplicatedStorage.ArtAssets`, and ArtAssets category folders exist in repo builder/Studio runtime. |
| Active world scripts | PASS | 0 `Script`, `LocalScript`, or `ModuleScript` descendants under `Workspace.GTH_WorldV2`. |
| Placeholder policy | PASS | 0 visible `Part`/`Block`/`Circle`/`Cylinder`/`Temp`/`Debug` placeholder violations. |

## Known blocker

Active Studio MCP tree is not synced with repo source modules (`ReplicatedStorage.Shared` absent), so module-based Studio commands for `UnitTests.Run()` and `GameTestHarness.Run()` are blocked until the Rojo/project sync or equivalent Studio import runs. Direct MCP Luau validation was run against the live DataModel and passed for WorldV2 structure/counts.

## 2026-05-25 SongSelect clipping fix

| Check | Result | Notes |
| --- | --- | --- |
| SongSelect layout patch | PASS | `SongSelectModal` now centered with `AnchorPoint=(0.5,0.5)`, responsive size, `UISizeConstraint`, and viewport-aware compact layout. |
| Studio runtime bounds | PASS | Play-mode MCP check for player `blazimann`: modal `pos=622,123 size=782,747 viewport=1762,922`; close button `pos=1330,139 size=57,52`; both inside viewport. |
| Device formula check | PASS | Desktop 1920x1080, laptop 1366x768, iPad 1024x768, iPhone 844x390, small phone 667x375 all report modalInside=true and closeInside=true. |
| Screenshot | PASS | Captured `SongSelect_Responsive_Fixed`; menu is visible and not clipped off bottom-right. |
## 2026-05-25 Creator Store MCP asset sprint

| Test | Result | Notes |
| --- | --- | --- |
| Creator Store search/import | PASS | Imported 5 candidate assets via MCP search/insert into Studio: concert stage/truss/lights, cartoon horde, volcano rocks, stadium crowd/seats, vendor kiosk. |
| Asset quarantine | PASS | Quarantined 63 scripts from imported assets; suspicious keyword findings=0 in scanned sources. |
| Clean ArtAssets promotion | PASS | Clean visual-only copies placed under `ReplicatedStorage.ArtAssets.{Stage,Horde,Volcano,Audience,Vendors}`. |
| Procedural scaffold hiding | PASS | Runtime hid 192 non-audited scaffold parts once audited art count exceeded 500. |
| `WorldValidation.Run()` | PASS | activePlacedArtInstances=2248; scripts under world=0; placeholders=0; unaudited placements=0; autogen blank excluded=0. |
| `GameTestHarness.Run()` | PASS | Harness completed after WorldValidation and simulated playable song run. |
| `UnitTests.Run()` | PASS | failed=0, passed=11. |
| `UIUXValidation.Run()` | PASS | Desktop/laptop/iPad/iPhone/small-phone viewports pass. |
| Screenshot | PASS | Captured `WorldV2_2248_AuditedArt_PASS_NoStadiumWall`. |

### Asset placement validation counts

| Category | Required | Actual | Result |
| --- | ---: | ---: | --- |
| stageCore | 60 | 318 | PASS |
| lightingAndTrusses | 80 | 318 | PASS |
| vendorRing | 60 | 103 | PASS |
| fenceRing | 64 | 318 | PASS |
| hordeRing | 160 | 896 | PASS |
| audienceRing | 80 | 112 | PASS |
| volcanoOuterRing | 80 | 80 | PASS |
| tourBusAndSpawn | 30 | 103 | PASS |
| total activePlacedArtInstances | 500 | 2248 | PASS |
| visible placeholder violations | 0 | 0 | PASS |
| unaudited asset placements | 0 | 0 | PASS |
| scripts under WorldV2 | 0 | 0 | PASS |

---

## 2026-05-25 Phase X repair + placement validation — LATEST

| Test | Result | Notes |
| --- | --- | --- |
| Rojo serve sync | PASS | Active Studio `GroanTubeHero.synced.rbxlx`; source probes found latest `WorldV2Builder`, `VendorPromptService`, `HordeService`, `UIUXMenuController`, `RhythmClient`, and `GameTestHarness` patches synced. |
| `git diff --check` | PASS | No whitespace errors after Phase X fixes. |
| `rojo build default.project.json -o /private/tmp/GroanTubeHero.verify.rbxlx` | PASS | Project builds successfully. |
| Fresh WorldV2 rebuild | PASS | `WorldV2Builder.Build()` now destroys stale `Workspace.GTH_WorldV2` before rebuilding, removing bad/stale placements. |
| No-fall play check | PASS | Play runtime player `blazimann`: `HumanoidState=Running`, `Y=5.72`, `SafeWalkableConcertFloor.Anchored=true`, `CanCollide=true`, `PhysicsLockedParts=4490`. |
| Glowing mic prompt | PASS | `Workspace.GTH_WorldV2.StageCircle.GlowingStageMicPrompt.ProximityPrompt` has `ActionText=Choose Song`, `MenuName=SongSelect`, `WorldV2Bound=true`, `MaxActivationDistance=24`; screenshot `WorldV2_Play_GlowingMic_Reachable_NoFall`. |
| Repair prompts | PASS | All 8 sectors have `Repair Fence` prompts on `InvisibleHitbox_RepairPromptAnchor`, `WorldV2RepairBound=true`, `MaxActivationDistance=28`. |
| Horde movement capability | PASS | All 8 `HordeCluster` roots are Models and `PivotTo()` movement check succeeded for N/NE/E/SE/S/SW/W/NW. |
| `require(ReplicatedStorage.Shared.UnitTests).Run()` | PASS | Fresh Studio runtime: `failed=0`, `passed=11`. |
| `require(ReplicatedStorage.Shared.GameTestHarness).Run()` | PASS | Fresh clone run returned `Harness-LocalAudioSong001-5693508`, 38 notes. |
| `WorldValidation.Run()` | PASS | 8 sectors, 16 prompts, no placeholder violations, no unaudited placements, no scripts under WorldV2. |
| `UIUXValidation.Run(player)` | PASS | Runtime player UI validation returned `ok=true`. |
| Screenshot evidence | PASS | Captured `WorldV2_Play_GlowingMic_Reachable_NoFall`; shows reachable mic prompt, dark arena, visible vendors/lights/stage. |

### Latest AssetPlacementValidation counts

| Category | Required | Actual | Result |
| --- | ---: | ---: | --- |
| stageCore | 60 | 412 | PASS |
| lightingAndTrusses | 80 | 1408 | PASS |
| vendorRing | 60 | 672 | PASS |
| fenceRing | 64 | 64 | PASS |
| hordeRing | 160 | 1312 | PASS |
| audienceRing | 80 | 272 | PASS |
| volcanoOuterRing | 80 | 272 | PASS |
| tourBusAndSpawn | 30 | 43 | PASS |
| total activePlacedArtInstances | 500 | 4455 | PASS |
| visible placeholder violations | 0 | 0 | PASS |
| unaudited visible placements | 0 | 0 | PASS |
| scripts under `Workspace.GTH_WorldV2` | 0 | 0 | PASS |
| missing required assets | 0 | 0 | PASS |

### Latest runtime counts

| Count | Value |
| --- | ---: |
| Active WorldV2 Models | 750 |
| Active WorldV2 MeshParts | 80 |
| Active WorldV2 visible BaseParts | 4455 |
| Active placed art instances | 4455 |
| Invisible hitboxes | 6 |
| Vendor prompts | 16 |
| Horde sectors | 8 |
| ArtAssets audit scripts | 0 |
| ArtAssets audit MeshParts | 19 |
| ArtAssets audit parts | 3597 |
| ArtAssets audit decals | 321 |
| ArtAssets audit lights | 21 |
| Visible placeholder violations | 0 |
| Unaudited visible placements | 0 |

---

## 2026-05-25 Phase X NPC / horde visual repair — latest

| Check | Result | Notes |
| --- | --- | --- |
| OMX team runtime | BLOCKED | `$team` / `omx team` retried and still failed: `Team mode requires running inside tmux current leader pane`; direct Studio MCP execution continued. |
| Real NPC/vendor additions | PASS | Added audited `Audited_RoleNPC_*` model clones for DJ, Store, Upgrades, Missions, Security, Tutorial, Hype/Audience and TourBus manager. |
| Store/upgrade/mission/station assets | PASS | Added audited kiosk/prop clones per station: `Audited_Kiosk_*`, `Audited_RoleProps_Left_*`, `Audited_RoleProps_Right_*`. |
| Brainrot horde fixed | PASS | Replaced visible block `HordeFigure_*` parts with 4 audited brainrot NPC packs per sector: `Audited_BrainrotHordeNPCPack_<sector>_1..4`. |
| Block/autogen horde hidden | PASS | `HordeFigure_*`, `HordeEyeGlow_*`, block NPC parts, block vendor counters/decks, block crowd silhouettes, primitive tour bus body/wheels hidden; latest `HiddenAutogenLookingScaffoldParts=797`. |
| Imported prompt/nameplate soup removed | PASS | Cloned art strips `Script`, `LocalScript`, `ModuleScript`, `ProximityPrompt`, `ClickDetector`; disables imported `BillboardGui`/`SurfaceGui`; sets all imported Humanoid name/health display distance to none. Runtime humanoids=780, bad nameplates=0. |
| Studio WorldValidation | PASS | `activePlacedArtInstances=12963`, scripts under WorldV2=0, placeholder violations=0, unaudited placements=0. |
| Play no-fall check | PASS | Runtime player `blazimann`: `Y=5.72`, `HumanoidState=Running`. |
| GameTestHarness | PASS | Fresh clone run returned `Harness-LocalAudioSong001-545048`, 38 notes. |
| UnitTests | PASS | `failed=0`, `passed=11`. |
| UIUXValidation | PASS | Runtime player UI validation returned `ok=true`. |
| Screenshot | PASS | Captured `WorldV2_Play_NPCs_NoNameplates_12963_PASS`. |

### Latest Phase X counts

| Metric | Value |
| --- | ---: |
| activePlacedArtInstances | 12963 |
| visible BaseParts | 12963 |
| WorldV2 Models | 2611 |
| MeshParts | 80 |
| hordeRing placed art | 3680 |
| vendorRing placed art | 2508 |
| audienceRing placed art | 1762 |
| fenceRing placed art | 2544 |
| tourBusAndSpawn placed art | 569 |
| horde sectors | 8 |
| prompts | 16 |
| scripts under WorldV2 | 0 |
| visible placeholder violations | 0 |
| visible block/autogen horde/NPC/crowd/tourbus violations sampled | 0 |
