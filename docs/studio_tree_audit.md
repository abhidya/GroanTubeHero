# Roblox Studio MCP Real Tree Audit

Date: 2026-05-25

Skill contract used: `roblox-studio-mcp-real-tree` (repo skill file not present; performed Studio MCP tree inspection directly).

## Active Studio instance

| Field | Value |
| --- | --- |
| Studio name | `GroanTubeHro` |
| Studio id | `278b5d57-5a96-4e4a-bac2-2c786790558e` |
| MCP access | CONFIRMED via `execute_luau` |

## Service roots inspected by MCP

| Root | Exists | Child summary / notes |
| --- | --- | --- |
| `Workspace` | yes | 4 children at inspection time: `Stage`, `Terrain`, `GTH_WorldV2`, `Camera` |
| `Workspace.Stage` | yes | Folder; 5 descendants; compatibility/minimal state in active Studio |
| `Workspace.TourBus` | no in current active MCP tree | user-supplied place manifest lists it as source inventory; not present in active MCP session |
| `Workspace.Unused_MapAssets` | no in current active MCP tree | user-supplied place manifest lists it as source inventory; not present in active MCP session |
| `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME)` | no in current active MCP tree | user-supplied manifest source candidate; not present in active MCP session |
| `Lighting` | yes | `ColorGrading`, `Bloom` at inspection time |
| `MaterialService` | yes | no children at inspection time |
| `StarterGui` | yes | no children in active MCP tree at inspection time |
| `ReplicatedStorage` | yes | `ArtAssets` only in active MCP tree at inspection time |
| `ServerStorage` | yes | `WorldArchive`, `AssetQuarantine` |

## Active MCP world counts

| Path | ClassName | Models | MeshParts | BaseParts | Scripts | LocalScripts | ModuleScripts | Descendants |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `Workspace.GTH_WorldV2` | `Model` | 15 | 0 | 208 | 0 | 0 | 0 | latest MCP validation |
| `Workspace.Stage` | `Folder` | 0 | 0 | 0 | 0 | 0 | 0 | 5 |
| `ReplicatedStorage.ArtAssets` | `Folder` | 1 | 0 | 0 | 0 | 0 | 0 | 1 |
| `ServerStorage.AssetQuarantine` | `Folder` | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `ServerStorage.WorldArchive` | `Folder` | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

## Important interpretation

The active MCP Studio tree is a minimal WorldV2/compat state. Latest direct WorldV2 validation reports 15 models, 0 MeshParts, 208 visible BaseParts, 6 invisible hitboxes, 15 prompts, 8 horde sectors, 0 scripts, and 0 placeholder violations. and does **not** expose the larger supplied place-file inventory (`Workspace.Unused_MapAssets`, `Workspace.TourBus`, OPEN ME package). Therefore:

- `docs/asset_manifest_real.md` records the supplied manifest as source inventory.
- Current live MCP proof uses only objects actually visible in active Studio.
- No active WorldV2 proof depends on unavailable Studio paths.
- Any future use of supplied local assets still requires quarantine/audit before placement in `ReplicatedStorage.ArtAssets`.
