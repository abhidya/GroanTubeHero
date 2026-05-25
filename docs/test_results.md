# Test Results

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
