# WorldV2 Missing Assets / TODO

No unaudited external Creator Store asset slots are active. Current active WorldV2 build uses safe project-owned procedural props only.

Local Studio source candidates now documented in `docs/asset_manifest_real.md` can replace procedural props after audit:

- Vendor/NPC stations: copy/audit `Workspace.Stage.StoreKiosk`, `Workspace.Stage.MicrophoneStand`, and related stage props.
- Speakers/stage dressing: copy/audit `Workspace.Stage.SpeakerStacks` and `Workspace.Stage.StagePlatform` submodels.
- Volcanic enclosure: copy/audit `Workspace.Stage.BrainrotBackdrop` and package Lighting/Material variants.
- Horde/crowd art: audit selected models from 98 `Workspace.Unused_MapAssets` brainrot templates.
- Tour dressing: copy/audit `Workspace.TourBus.BusBody` and wheels if used outside active play space.

Required before any candidate becomes active WorldV2 art:

1. Copy/import into `ServerStorage.AssetQuarantine` or `Workspace.AssetInbox`.
2. Run `AssetAuditService`.
3. Count scripts, meshes, parts, sounds, emitters, lights, decals, and `SurfaceAppearance` descendants.
4. Quarantine all scripts unless project-owned and rewritten.
5. Copy clean model into `ReplicatedStorage.ArtAssets`.
6. Record cleaned path and used path in `docs/asset_manifest_real.md`.
