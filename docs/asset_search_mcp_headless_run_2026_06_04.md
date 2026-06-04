# Asset-Search MCP Headless Run - 2026-06-04

## Outcome

The live `asset-search` MCP exposed the required v0.7 tools and was used for
cache preprocessing, inspection-memory updates, palette commits, manifest
validation, and player-angle review planning.

Headless output was written outside the repo:

- `/private/tmp/groan-headless-20260604T0132Z/GroanTubeHero.mcp-hotfix.asset-evidence.rbxl`
- `/private/tmp/groan-headless-20260604T0132Z/GroanTubeHero_AssetSearchEvidence.rbxm`
- `/private/tmp/groan-headless-20260604T0132Z/GroanTubeHero_AssetSearchEvidence.manifest.json`

The fragment is metadata/evidence only. It adds no visible world props, scripts,
runtime loaders, or unaudited Creator Store content.

## Asset-Search Palette

Committed project: `groan-tube-hero`

- `worldv2.stage.concert_rig` -> `84533917908730`
- `worldv2.horde.monster_npc` -> `148933335`
- `worldv2.volcano.cliff_lava` -> `7979344076`
- `worldv2.vendor.kiosk` -> `14660776730`
- `worldv2.stage.truss` -> `5564827474`
- `worldv2.lighting.concert_lights` -> `85589657655640`
- `worldv2.vendor.cash_register` -> `13086664189`
- `worldv2.security.console` -> `144012624`
- `worldv2.tour_bus.prop` -> `3215211735`
- `worldv2.audience.cartoon_npc` -> `8220780721`
- `worldv2.volcano.lava_rock` -> `907464004`
- `worldv2.signage.neon` -> `18849541324`

Rejected in shared MCP memory:

- `101846227525981` because existing visual audit found an oversized/off-theme
  stadium slab near spawn.

## Validation

- `validate_fragment_manifest`: passed, no warnings.
- Lune coordinator merge: passed with `--replace-existing --create-missing-targets`.
- Lune deserialize check: `palette=12`, `rejected=1`, `scripts=0`.
- Dangerous-loader scan against the merged place/model: no matches.
- Rojo source build:
  `/private/tmp/groan-headless-20260604T0132Z/GroanTubeHero.rojo-built.rbxlx`
  built successfully.

## Remaining Blocker

Studio opened the candidate file, but Studio MCP continued to report only the
old `eggBreakers3.rbxl` instance. No player-height screenshots were captured.

`validate_playable_space_review` correctly failed with `verdict=not_signed_off`
because the stage circle, vendor ring, horde ring, and tour-bus spawn path still
need player-angle screenshot evidence from the correct active Studio place.
