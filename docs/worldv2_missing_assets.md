# WorldV2 Missing Assets / TODO

## BLOCKED: 500+ audited placed art gate

Current synced Studio place `GroanTubeHero.synced.rbxlx` does **not** contain the imported Studio asset sources needed for the requested final art pass. MCP probe results:

| Required source | Current synced Studio result | Impact |
| --- | --- | --- |
| `Workspace.Unused_MapAssets` | Missing | Cannot audit/place 98 brainrot horde/crowd templates. |
| `Workspace.Stage.StagePlatform` / `SpeakerStacks` / `StoreKiosk` / `MicrophoneStand` / `BrainrotBackdrop` / `Spotlights` | Absent; `Workspace.Stage` is compatibility folder only | Cannot promote real stage/vendor/volcano/speaker assets. |
| `Workspace.TourBus` | Missing during runtime probe | Cannot promote bus/spawn dressing assets. |
| `ReplicatedStorage.ArtAssets` | Only `WorldV2_SafeProceduralKit` exists | No audited final-art library for 500+ placements. |

Do not satisfy this by counting procedural scaffold parts. Required next source change: open/provide a Studio place containing the imported assets from the manifest, or import audited Creator/Studio assets into `Workspace.AssetInbox`/`ServerStorage.AssetQuarantine`, then run quarantine/promotion.

## Required promotion workflow

1. Copy/import source into `ServerStorage.AssetQuarantine` or `Workspace.AssetInbox`.
2. Run `AssetAuditService`.
3. Count scripts, meshes, parts, sounds, emitters, lights, decals, and `SurfaceAppearance` descendants.
4. Quarantine all scripts unless project-owned and rewritten.
5. Copy clean model into `ReplicatedStorage.ArtAssets`.
6. Place clones into `Workspace.GTH_WorldV2` with `AuditedArtAsset=true` and `AssetSourcePath`.
7. Record cleaned path and used path in `docs/asset_manifest_real.md`.
8. Re-run `GameTestHarness.Run()`; pass requires `activePlacedArtInstances >= 500`.
