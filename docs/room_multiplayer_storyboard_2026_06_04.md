# GroanTubeHero Room Multiplayer Storyboard

Date: 2026-06-04

## Scope

This pass turns the existing volcano rave arena into Room 1 and adds the first
server-authoritative multiplayer room spine:

- shared themed room config with difficulty bands, capacities, rewards, skins,
  boosts, helper NPCs, asset-search slots, and review-space IDs;
- server-owned room queue state, join/leave remotes, level/capacity/min-player
  gates, fill-timer countdown snapshots, and room-decorated song payloads;
- active room-session IDs, participant rosters, team-mode labels, launch/return
  CFrames, room-not-ready song-start gating, and finish/return handling;
- room reward multipliers/bonuses applied in `EconomyService`, plus persisted
  room clears, difficulty awards, skins, boosts, GroanTokens, and helper
  affinity;
- `Workspace.GTH_WorldV2.RoomPortalRing` with eleven readable portal prompts;
- stronger Room 1 horde pushback and attack-wave payloads.
- helper NPC horde actions: `SecurityManager` repairs weak sectors,
  `AudienceHypeManager` converts high hype into pushback, and
  `DJ_GroanMaster` calls weak-sector warnings.

## Room Slate

Room 1 remains the current playable combat room:

| # | Room | Core loop | Capacity | Default difficulty | Reward |
| ---: | --- | --- | ---: | --- | ---: |
| 1 | Brainrot Volcano Horde Rave | lava concert defense + brainrot horde | 4 | Easy | 1.20x |
| 2 | Cyber Arcade Overclock | neon arcade combo pressure | 4 | Hard | 1.28x |
| 3 | Subway Meme Tunnel | platform echo rhythm | 4 | Hard | 1.33x |
| 4 | Haunted Karaoke Theater | ghost choir support | 4 | Hard | 1.38x |
| 5 | Cloudback Idol Arena | sky idol party room | 6 | Hard | 1.42x |
| 6 | Aquarium Bass Drop | bubble shield rhythm | 6 | Extreme | 1.48x |
| 7 | Junkyard Auto-Tune Pit | scrap repair/pushback loop | 6 | Extreme | 1.55x |
| 8 | Neon Food Court Freestyle | mall crowd reward room | 6 | Hard | 1.44x |
| 9 | Moonbase Echo Dome | low-gravity team streaks | 6 | Extreme | 1.62x |
| 10 | Pirate Radio Shipyard | crew-share Brainrot room | 6 | Brainrot | 1.75x |
| 11 | Doomscroll Data Center | viral panel purge and rack cooldown | 6 | Extreme | 1.68x |

Full machine-readable data lives in
`ReplicatedStorage/Shared/WorldV2/RoomConfig.lua`.

Each launch room now declares `MinPlayers`, `FillSeconds`, `TeamMode`,
`Capacity`, difficulty bands, reward multiplier, flat reward bonuses, skin
unlocks, boost IDs, helper NPC roles, asset-search slots, and a review-space ID.
`RoomService` broadcasts `empty`, `waiting`, `countdown`, and `ready` queue
states so the client can show Roblox-standard room readiness rather than a
silent single-player selection.

Ready queues now promote into an active room session. The session keeps a shared
`roomSessionId`, participant list, team mode, per-player status, launch slot,
and return slot. `SongSessionService` asks `RoomService` to prepare queued room
payloads before starting a song; if a player tries to start early, `RoomService`
sends a room-not-ready result instead of silently starting a solo run. Rewards
and session history now preserve `RoomSessionId` and team metadata.

Room song launch now propagates across the active crew instead of starting only
for the requester. `SongSessionService` de-duplicates room launches by
`roomSessionId`, resolves each participant by `UserId`, gives all started
participants one server `sharedStartServerTime`, and stores/sends
`RoomCrewLaunchId` for reward/history/client traceability.

Room helper NPCs now affect the horde loop instead of living only in room
metadata. `HordeService` emits `helperEvent`, keeps helper cooldowns, paints
server-side horde sector health/pressure/cue attributes, and preserves helper
attack-wave cue names for the client. `HordeClient` displays helper actions and
recognizes `SecurityRepair`, `AudienceHeatPushback`, and `DJWarning` waves.

## Expansion Room Backlog

These are storyboarded as future room packs, not committed visible worlds yet:

| # | Room | Core hook | Reward idea |
| ---: | --- | --- | --- |
| 11 | Desert Mirage Festival | sandstorm decoys and heat-wave fakeouts | mirage clone helper |
| 12 | Ice Cream Tundra Rave | slippery lanes and freeze breaks | frost slow-resist boost |
| 13 | Library Shushcore Arena | noise meter becomes the hazard | silence-shield skin set |
| 14 | Toybox Chaos Room | toy trains and block-tower routes | mini-helper NPC |
| 16 | Carnival Clowncore Stage | funhouse mirrors and ticket jackpots | ticket multiplier boost |
| 17 | Ancient Meme Temple | rhythm glyph traps and idol waves | relic treasure bonus |
| 18 | Backrooms Boiler Rave | maze pressure doors and flicker cues | escape-speed boost |
| 19 | Candy Crash Concert | conveyor belts and syrup slow zones | candy coin streak |
| 20 | Storm Chaser Rooftop | lightning-safe zones and storm beats | charge-on-perfect boost |

## Asset-Search Evidence

The live `asset-search` MCP exposed the required v0.7 tools, and cache
preprocessing ran for GroanTubeHero with room themes. Coverage planning was
split into two batches because `plan_game_asset_coverage` caps `max_themes` at
12. The MCP returned the expected Roblox shell requirements: lobby spawn,
guide/upgrade/cosmetic NPC prompts, capacity-limited portals, min/max players,
fill timer, leave-queue UX, session ownership, and return-to-lobby behavior.

The launch-slate preprocess warmed 40 slots. It found some fresh catalog
candidates for broad lobby and Brainrot slots, including `12095414751`
(`ROBLOX R6 Rigs 2.0 Kit + Face pack!`), `9928242954` (`Old Roblox Noob`),
`1473040963` (`ROBLOX Arch`), and `135893392659459`
(`Brainrot Characters Pack (30 Characters + Rigged)`). These are not release
palette commitments: they still need claim, Studio inspection, script audit,
publish-permission review, player-height screenshots, and palette approval.

The live search lane remains sparse/stale for many exact GroanTubeHero room
terms: cyber arcade, subway meme, haunted karaoke, cloud idol, and several
specific hideable/ambience slots returned zero warmed candidates.

Per the project workflow, this pass used repo-local fallback evidence already
recorded in `docs/asset_manifest_real.md` and the asset brain snapshot:

- `concert stage truss speaker lights`
- `cartoon monster npc horde`
- `fan crowd NPC Creator/local lane`
- `vendor kiosk shop counter`
- `security console`
- `tour bus prop`
- `volcano rock lava cliff`
- `neon signs`

No new unchecked Creator Store assets were inserted in this pass. New visible
room portal art is project-owned readable geometry tagged as audited
`ProjectOwned/ReadableWorldV2Art`.

## 2026-06-04 Non-Volcano Room Curation Pass

This follow-up pass used the live `asset-search` MCP only; Roblox Studio search
was not used. The live MCP exposed the v0.7 tools, then produced:

- coverage plan for GroanTubeHero lobby, portals, NPCs, and capacity-limited
  room packs;
- warmed storyboard cache for Cyber Arcade, Subway Meme Tunnel, Haunted Karaoke,
  Aquarium Bass Drop, and Doomscroll Data Center;
- headless assembly plan with six fragment packets using the
  `concert_defense` profile and the coordinator-owned identity policy;
- player-angle playable-space review plan for Room 1, the portal ring, and the
  five inspection-target rooms.

Asset brain snapshot after this pass:

| Field | Count |
| --- | ---: |
| assets | 103 |
| search queries | 12 |
| reviews | 40 |
| inspections | 37 |
| claims | 77 |
| palette assets | 0 |
| publish permission records | 0 |

No new Creator Store assets were inserted, palette-committed, or treated as
release-ready in this pass. All new non-volcano assets below are inspection
shortlists only. They still need Studio geometry measurement, script/source
audit, publish-permission proof, player-height screenshots, visual-risk scoring,
and palette commitment before any placement.

Rejected/shared-veto assets:

| Asset ID | Slot | Reason |
| ---: | --- | --- |
| 36598859 | Haunted Karaoke curtain | legacy working/scripted curtain behavior |
| 357734086 | Haunted Karaoke curtain | open/close scripted imported gameplay |
| 13165974430 | Cyber Arcade shell | FNaF/IP/off-theme risk |
| 4704879208 | Cyber Arcade setpiece | Ms. Pac-Man/Galaga/IP-branded cabinet |
| 431037632 | Subway shell | Toby/Thomas-style IP/off-theme risk |
| 204433772 | Aquarium fish | Nemo/IP-branded fish |
| 11176009122 | Haunted host NPC | Ghostface/IP-branded horror risk |
| 10851288693 | Aquarium fish pack | high triangle count and script-review flag |
| 909995166 | Data Center rack | script-heavy server model |
| 15239190986 | Data Center rack | extreme triangle count |
| 6637698037 | Data Center terminal | description says ripped Bioshock 2 model |
| 133261145814834 | Data Center terminal | Pressure/Urbanshade-branded/off-theme |
| 154643874 | Aquarium fish | off-theme and high-triangle Egg Hunt Baby |
| 11164277522 | Aquarium fish | branded backpack/off-theme |
| 107431547750528 | cross-room ambience | Poppy Playtime/IP-branded audio |
| 9280878 | Subway shell | script-heavy high-triangle track pack |
| 579467441 | Subway shell | script-review accessory pack risk |
| 12131160962 | Subway shell | script-heavy high-triangle station |
| 111644166341307 | Subway shell | Studio inspection found an oversized 85.16 x 26.12 x 218.2 stud station with 1277 base parts and one imported script |

Claimed inspection shortlists:

| Room | Claimed asset IDs |
| --- | --- |
| Cyber Arcade Overclock setpieces | 637807731, 5083929571, 9342944537, 10968103368, 15476061406 |
| Cyber Arcade Overclock portals | 13903220189, 14840309510, 4672044552 |
| Subway Meme Tunnel shell/signage | 228201234, 16422570368, 40117484 |
| Subway Meme Tunnel setpieces | 8314991219, 14609442409, 1957743767 |
| Haunted Karaoke Theater shell | 8297623882, 8297711035, 12531890060, 13951875544 |
| Haunted Karaoke Theater host NPC | 155660821, 6036864116, 2070341625 |
| Aquarium Bass Drop fish/tanks | 5512630914, 10378024631, 7038203367, 11365429086, 1560282339, 734771184, 13345468318, 2073923199 |
| Doomscroll Data Center racks | 10693308533, 138509177498653, 150383271, 125482914900896, 18544107878 |
| Doomscroll Data Center terminals | 207300591, 26783279, 379210270, 3623280668, 3623273000, 152665536 |

Primary candidates recorded as `maybe` reviews:

| Asset ID | Candidate role | Current note |
| ---: | --- | --- |
| 637807731 | Cyber Arcade cabinet anchor | promising generic arcade model; needs Studio proof |
| 13903220189 | Cyber Arcade portal | static visual portal candidate only |
| 111644166341307 | Subway platform | small platform candidate with script-review caveat |
| 8297623882 | Haunted Theater stage | needs scale, curtain, and script audit |
| 155660821 | Haunted host | needs tone review so it stays playful |
| 5512630914 | Aquarium fish | promising generic fish decoration |
| 734771184 | Aquarium tank | promising readable aquarium setpiece |
| 10693308533 | Data Center rack | likely data-center anchor, uninspected |
| 3623280668 | Data Center terminal | low-triangle terminal candidate |

`ReplicatedStorage/Shared/WorldV2/AssetRegistry.lua` now mirrors these as
room-level `SearchCandidates` buckets with
`reviewState = "claimed_maybe_requires_studio_inspection"`.

## 2026-06-04 Studio Asset Lab Pass

Studio was used only for asset inspection by explicit Creator Store asset ID.
No Studio Creator Store search was used. The inspection script loaded assets via
`game:GetObjects("rbxassetid://...")`, disabled and removed imported scripts
before staging visuals, placed inspected candidates in a temporary
`CodexAssetInspectionLab_20260604` folder, captured screenshots, and destroyed
the lab afterward.

Captured lab screenshots:

| Capture ID | Purpose |
| --- | --- |
| `GTH_AssetLab_CandidateGrid_Overview_20260604` | overview grid and scale check |
| `GTH_AssetLab_Row1_PlayerHeight_20260604` | player-height cyber/subway row check |
| `GTH_AssetLab_Row2_PlayerHeight_20260604` | player-height haunted/aquarium row check |
| `GTH_AssetLab_Row3_PlayerHeight_20260604` | player-height aquarium/data-center row check |

Inspection results recorded back into `asset-search`:

| Asset ID | Slot | Size studs | Scripts | Parts | Screenshot verdict | Result |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 637807731 | Cyber Arcade cabinet setpiece | 35.10 x 9.00 x 4.40 | 0 | 89 | pass | usable candidate; verify close-up cabinet readability in room |
| 13903220189 | Cyber Arcade portal dressing | 2.31 x 14.00 x 11.42 | 0 | 3 | fix | clean but narrow; frame/scale before functional portal use |
| 111644166341307 | Subway platform shell | 85.16 x 26.12 x 218.20 | 1 | 1277 | reject | too large/heavy for V1 room slice; rejected in shared brain |
| 8297623882 | Haunted Theater stage | 30.98 x 18.80 x 14.34 | 0 | 49 | pass | promising shell candidate; needs final room lighting/grounding |
| 155660821 | Haunted host NPC | 4.00 x 5.17 x 1.00 | 0 | 7 | fix | readable but tone is spooky; needs playful karaoke treatment |
| 5512630914 | Aquarium fish | 8.04 x 3.64 x 8.83 | 0 | 8 | fix | usable fish candidate; needs closer grouping screenshot |
| 734771184 | Aquarium cylinder tank | 20.72 x 7.93 x 7.90 | 0 | 17 | pass | strong readable aquarium setpiece; watch camera occlusion |
| 10693308533 | Data Center server rack | 4.00 x 14.77 x 4.03 | 0 | 310 | fix | readable but too heavy for repeated cloning without simplification |
| 3623280668 | Data Center terminal | 3.36 x 6.00 x 3.28 | 0 | 3 | pass | lightweight terminal candidate; needs lighting/signage for readability |

The repo-side Subway shortlist now removes `111644166341307` and records it
under `rejectedAfterInspection` in `AssetRegistry.SearchCandidates`.

## 2026-06-04 Room Mechanics Pass

## 2026-06-04 Room Asset Preview Pass

Studio was used only for player-height preview review of already-curated
Creator Store asset IDs. No Studio Creator Store search was used. The temporary
`CodexRoomPreviewStage_20260604` folder loaded the inspected IDs with
`game:GetObjects("rbxassetid://...")`, removed imported scripts, anchored staged
parts, captured review screenshots, recorded the results back into
`asset-search`, and was destroyed before this report was written.

The scoped `plan_playable_space_review` / `validate_playable_space_review`
asset-fix gate passed with `verdict = "signed_off_with_risks"` for four preview
lanes and eight player-height screenshots:

| Preview lane | Capture IDs | Result |
| --- | --- | --- |
| Cyber Arcade | `GTH_RoomAssetPreview_Cyber_Entry_PlayerHeight_Recap3_20260604`, `GTH_RoomAssetPreview_Cyber_Close_PlayerHeight_Recap1_20260604` | pass with minor lab bleed risk |
| Haunted Karaoke | `GTH_RoomAssetPreview_Haunted_ReverseFront_PlayerHeight_20260604`, `GTH_RoomAssetPreview_Haunted_CloseFront_PlayerHeight_20260604` | signed off with orientation risk |
| Aquarium Bass | `GTH_RoomAssetPreview_Aquarium_Entry_PlayerHeight_Recap1_20260604`, `GTH_RoomAssetPreview_Aquarium_Close_PlayerHeight_Recap1_20260604` | pass after fish placement fix |
| Doomscroll Data Center | `GTH_RoomAssetPreview_DataCenter_Entry_PlayerHeight_20260604`, `GTH_RoomAssetPreview_DataCenter_Close_PlayerHeight_20260604` | pass for scale preview, sparse for final room |

Player-angle fixes captured before signoff:

- `637807731` imports as four sane cabinet child models, but the wrapper stacks
  them vertically. The preview arranged those child models into a horizontal
  row and rotated them toward the player path before recapture.
- `8297623882` initially floated with its bottom around 9.65 studs above the
  floor and showed a plain back slab from the wrong side. The preview grounded
  it around 2.05 studs, applied a burgundy/purple treatment to existing curtain
  and backdrop surfaces, and proved the usable front view from the +Z side.
- `5512630914` was too large and sat outside the aquarium. The preview scaled
  it to 0.45 and placed it inside `734771184` before recapture.
- `10693308533` is readable as a server rack but remains a heavy 310-part asset;
  it should be used sparingly with lighter surrounding props.

Latest asset-brain snapshot after the preview writes: 103 assets, 41 reviews,
46 inspections, 77 claims, 0 palette assets, and 0 publish-permission records.
That means these are still not release palette commitments. The next asset work
must either record publish-permission proof and palette decisions or keep these
as preview-only candidates.

## 2026-06-04 Room Mechanics Pass

Non-volcano rooms now have source-owned gameplay mechanics instead of only room
metadata. `HordeService` defines a `ROOM_MECHANICS` table with per-room hazards,
helper triggers, support actions, pressure relief, health repair, and movement
cues. These cues are sent through `roomMechanicEvent` and `roomHazard` payload
fields so the HUD and horde movement can react differently per room.

Implemented room mechanics:

| Room | Miss/passive hazard | Helper/support cues |
| --- | --- | --- |
| Cyber Arcade Overclock | `GlitchSurge` | `PatchBotStabilize`, `ComboCacheCharge` |
| Subway Meme Tunnel | `TrainSurge` | `BuskerTiming`, `ConductorSignal` |
| Haunted Karaoke Theater | `CurtainSlam` | `GhostChoirBackup`, `StageMediumWarning` |
| Aquarium Bass Drop | `FloodSurge` | `BubbleShieldPulse`, `ReefMedicHeal` |
| Junkyard Auto-Tune Pit | `ScrapStorm` | `WrenchRepairChain`, `CranePushback` |
| Neon Food Court Freestyle | `OrderRush` | `SnackRecovery`, `MallCopStun` |
| Moonbase Echo Dome | `GravitySlip` | `OrbitStabilize`, `SatelliteEcho` |
| Pirate Radio Shipyard | `SignalJam` | `CaptainCrewShare`, `DeckhandCannon` |

`HordeClient` now classifies room hazard/support cues with
`ROOM_HAZARD_CUES` and `ROOM_SUPPORT_CUES`, colors room hazards as pressure
surges, treats support cues as pushback, and displays `roomMechanicEvent`
messages in the horde HUD.

Fresh-clone Studio behavior smoke passed for Cyber Arcade:

- miss judgement emitted `roomHazard.type = "GlitchSurge"`;
- the same miss emitted `roomMechanicEvent.type = "GlitchSurge"`;
- with a weak N sector, `PatchBot` emitted
  `roomMechanicEvent.type = "PatchBotStabilize"`;
- PatchBot raised N sector health from 62 to 72 and reduced pressure from 70 to
  46.

Follow-up horde targeting pass replaced the remaining round-robin feel with
server-side sector scoring. `HordeService` now scores sectors from health,
pressure, warning state, judgement type, and room-specific attack/support bias
before choosing the active sector. Payloads include `targeting` and
`targetReason`, and movement cues/attack waves preserve that intent so the
client can animate why an attack or helper action moved.

Focused Studio smoke passed: a Cyber Arcade miss with E-sector pressure at 88
targeted sector `E`, emitted `roomHazard.type = "GlitchSurge"`, kept
`roomHazard.sectorId = "E"`, and reported
`targetReason = "pressure_hotspot_room_bias"`.

## 2026-06-04 NPC Action And Pushback Pass

The horde loop now emits an explicit server-authoritative `npcAction` payload
for hazards, pushbacks, helper support, repairs, finish cues, and beat-motion
events. This lets the client animate NPC intent directly instead of inferring
everything from distance and judgement labels.

Implemented action payload fields:

- `eventId`, `type`, `kind`, `sectorId`, `warningSectorId`, `strength`,
  `targetReason`, `targetScore`, and `startedAt`;
- helper actions add `actorId` and the helper action text;
- `kind` classifies cues as `hazard`, `pushback`, `support`, `repair`, `beat`,
  `finish`, or `motion`.

`HordeClient` now consumes `payload.npcAction` and renders project-owned runtime
markers:

- `HordeActionShockwave` for action pulses;
- `HordeAttackLane` for hazard/attack lanes;
- `HordeHelperBeam` for support, repair, pushback, and finish actions;
- `HordeActionActorBeacon` with last action type/kind/actor attributes.

Cluster motion now reacts to the action kind: hazards lunge inward toward the
stage, support/repair/pushback cues push the horde outward, and each event gets
a small deterministic lateral strafe so repeated attacks no longer look like a
static scale tween.

Fresh Studio clone smoke passed in the active `GroanTubeHero.synced.rbxlx`
instance:

- Cyber Arcade miss emitted `npcAction.kind = "hazard"`,
  `npcAction.type = "GlitchSurge"`, `npcAction.sectorId = "E"`, and
  `targetReason = "pressure_hotspot_room_bias"`;
- PatchBot support emitted `npcAction.kind = "support"`,
  `npcAction.actorId = "PatchBot"`, and
  `npcAction.type = "PatchBotStabilize"`.

Asset-search brain snapshot still reports 103 assets, 41 reviews,
46 inspections, 77 claims, 0 palette assets, and 0 publish-permission records.
Because no release palette is committed yet, these new action visuals are
project-owned runtime VFX only, not Creator Store asset placements.

Scoped player-angle review was refreshed after this pass with the live
`asset-search` v0.7 review tools:

| Space | Capture IDs | Result |
| --- | --- | --- |
| Volcano Rave Horde Ring | `GroanTubeHero_volcano_rave_horde_ring_nw_player`, `GroanTubeHero_volcano_rave_horde_ring_ne_player`, `GroanTubeHero_volcano_rave_horde_ring_sw_player`, `GroanTubeHero_volcano_rave_horde_ring_se_player` | signed off with palette risk |
| Cyber Arcade Overclock | `GroanTubeHero_cyber_arcade_overclock_nw_player`, `GroanTubeHero_cyber_arcade_overclock_ne_player`, `GroanTubeHero_cyber_arcade_overclock_sw_player`, `GroanTubeHero_cyber_arcade_overclock_se_player` | signed off with sparse-art risk |

`validate_playable_space_review` passed for the scoped player-height quadrant
report with verdict `signed_off_with_risks`: two spaces reviewed, eight
screenshots, no unresolved major or blocker findings. Remaining visual risk:
Volcano is readable but over-saturated, and Cyber Arcade is separated and
navigable but still intentionally sparse until inspected Creator Store art is
palette-committed.

## 2026-06-04 Room Encounter Dressing Pass

A fresh `asset-search` MCP preprocessing pass warmed the GroanTubeHero cache for
12 room themes: Volcano, Cyber Arcade, Subway Meme, Haunted Karaoke, Aquarium
Bass, Junkyard Auto-Tune, Neon Food Court, Moonbase Echo, Pirate Radio,
Cloudback Idol, Doomscroll Data Center, and Backrooms Boiler. The exact
Cyber/Subway/Haunted room search terms remain sparse, while Aquarium and generic
lobby/portal slots still return usable candidates. The asset-brain snapshot
after this pass remains at 103 assets, 41 reviews, 46 inspections, 77 claims,
0 palette assets, and 0 publish-permission records, so final room art still
cannot be claimed as release palette.

To make the V1 rooms feel less like empty shells while staying inside the asset
rules, `WorldV2Builder` now adds project-owned encounter dressing to every
generated room:

- `RoomObjectiveStations`: four room-specific console/pad stations labelled
  with the room objective loop;
- `RoomHazardLanes`: four visible warning lanes tagged with the room hazard
  cue, such as `GlitchSurge`, `FloodSurge`, `SignalJam`, or `LavaSurge`;
- `RoomHelperNPCs`: separate visible helper NPC models for every configured
  helper, with role/action labels, `HelperNpcId`, `HelperRole`,
  `HelperAction`, and `NpcMovementPattern = "room_orbit_callout"`;
- `HelperActionLane_*` markers that point helper NPCs back into the active room
  space so helpers read like gameplay support, not static labels.

`WorldValidation` now rejects generated room spaces that are missing objective
stations, hazard lanes, or helper NPC models. Source-contract tests also guard
the new builder artifacts and require every configured room to have at least
one helper NPC.

Fresh Studio smoke used a cloned builder plus cloned `WorldV2Config`,
`RoomConfig`, and `AssetRegistry` to bypass open-Studio `require()` cache. The
generated world had 10 room spaces. Volcano produced 4 objective stations,
4 hazard lanes, and 3 helper NPCs with hazard cue `LavaSurge`. Cyber produced
4 objective stations, 4 hazard lanes, and 2 helper NPCs with hazard cue
`GlitchSurge`.

Scoped player-angle proof shots:

| Space | Capture ID | Result |
| --- | --- | --- |
| Volcano encounter layers | `GroanTubeHero_volcano_encounter_layers_nw_player` | helper/objective/hazard pieces visible, palette still over-saturated |
| Cyber encounter layers | `GroanTubeHero_cyber_encounter_layers_nw_player` | no longer reads as a bare shell; still needs final palette art |

`validate_playable_space_review` passed for this scoped report with verdict
`signed_off_with_risks`: two spaces reviewed, two player-height screenshots,
and no unresolved major/blocker findings.

## 2026-06-04 Room Progression Pass

Room clears now persist beyond a single song result. `DataService` backfills
`RoomProgress`, `Config.DefaultProfile` includes the default room-progress
bucket, and `EconomyService` updates `profile.RoomProgress[roomId]` during
`FinalizeSong`.

Tracked room progression now includes:

- clear count, first clear time, last clear time, best grade, best score, and
  best combo;
- per-difficulty clear records;
- first-clear, difficulty-clear, S-grade, and Brainrot-clear awards;
- room-scoped skin and boost unlock sets;
- helper NPC affinity totals and per-clear affinity-gain payloads;
- GroanToken bonuses for newly earned room awards.

The reward payload now returns `RoomUnlocks` with the room ID/name, difficulty,
first-room-clear flag, new awards, new skins, new boosts, helper affinity gains,
and best grade. This gives the client a concrete hook for post-run award
screens and room helper relationship UI without mixing room cosmetics into the
global cosmetic store.

## 2026-06-04 Room Results UI Pass

The post-song results screen now surfaces room progression instead of hiding it
inside the saved profile. `RhythmClient` formats `RoomUnlocks` into the scrolling
results panel with:

- room name and first-clear callout;
- difficulty clear;
- GroanToken room-award bonus;
- new room awards, skins, and boosts;
- helper NPC affinity gains.

This makes the room loop visible to players after a run: queue into a themed
room, clear the song, see the exact room unlocks, then return to missions,
upgrades, store, or lobby. Source-contract tests now guard the result-screen
formatter and the required payload fields.

## 2026-06-04 Asset Readiness Mirror Pass

The Studio asset-lab evidence is now mirrored in source, not only in docs and
MCP memory. `AssetRegistry.InspectedRoomAssets` records inspected candidates,
sizes, script counts, part counts, visual verdicts, risk scores, and notes for:

- Cyber Arcade Overclock;
- Subway Meme Tunnel;
- Haunted Karaoke Theater;
- Aquarium Bass Drop;
- Doomscroll Data Center.

`AssetRegistry.GetRoomAssetReadiness(roomId)` returns a compact readiness
summary with pass/fix/reject counts, highest visual risk score, palette counts,
publish-permission state, and placement state. After the later inspection-palette
pass, Cyber Arcade, Aquarium Bass Drop, Haunted Karaoke Theater, and Doomscroll
Data Center report committed inspection palettes while still keeping
`publishPermission = "missing"` and
`placementStatus = "palette_committed_pending_permission_and_fragment"`.
Subway Meme Tunnel remains uncommitted because its inspected shell candidate was
rejected.

Runtime consumers now expose that truth:

- `RoomService` includes `assetReadiness` in room snapshots;
- `RoomClient` shows queue-time art readiness such as pass/fix/reject counts and
  `palette N perm missing`;
- `WorldV2Builder` tags room portals and prompts with `RoomAssetVisualStatus`,
  `RoomInspectedAssetCount`, `RoomPassAssetCount`, `RoomFixAssetCount`, and
  `RoomRejectAssetCount`, plus palette and publish-permission metadata.

The next visual gate must use the generated player-angle plan:

- `volcano_rave_room`: NW, NE, SW, SE player-height quadrants plus round/helper
  UI states;
- `multiplayer_room_portals`: entry, center, left, right player-height views
  plus empty/joined/countdown/ready UI states;
- `cyber_arcade_room`, `subway_meme_room`, `haunted_karaoke_room`,
  `aquarium_bass_room`, and `doomscroll_data_center_room`: NW, NE, SW, SE
  player-height captures after inspected assets are actually placed.

## Visual Review

Studio was used after headless validation passed. The active Studio source had
to be rebuilt through a temporary `WorldV2Builder` clone to bypass Roblox
ModuleScript require caching during visual review.

Scoped player-height review passed with:

- validator: `validate_playable_space_review`
- verdict: `player_angle_signed_off`
- spaces reviewed: `volcano_rave_room`, `multiplayer_room_portals`
- screenshots: 6

Captured player-height evidence:

| Space | Capture ID | Result |
| --- | --- | --- |
| Room 1 volcano rave | `GTH_VolcanoRave_NW_PlayerHeight` | pass |
| Room 1 volcano rave | `GTH_VolcanoRave_NE_PlayerHeight` | pass |
| Room 1 volcano rave | `GTH_VolcanoRave_SW_PlayerHeight` | pass |
| Room 1 volcano rave | `GTH_VolcanoRave_SE_PlayerHeight` | pass |
| Room portals | `GTH_RoomPortals_Entry_PlayerHeight_Recap5` | pass with minor risk |
| Room portals | `GTH_RoomPortals_Center_Close_PlayerHeight_Recap2` | pass |
| Room 1 helper state | `GTH_HordeHelper_SecurityRepair_N_PlayerHeight` | pass |

Remaining minor visual risk: far entry view discovers the portal row, but some
individual portal sign text is only readable after approaching. Close
player-height view reads room number, theme, difficulty code, and reward
multiplier.

## Validation Evidence

Latest local gates for this pass:

- `rojo build default.project.json -o /private/tmp/GroanTubeHero-crew-launch.rbxlx`
  passed.
- `git diff --check` passed.
- `python3 tools/validate_blocked_asset_ids.py` passed with
  `blocked_id_count=11`.
- dangerous loader scan found only the audit-pattern list in
  `AssetAuditService`, not active `require(assetId)`, `InsertService:LoadAsset`,
  `loadstring`, or `HttpService:GetAsync/PostAsync/RequestAsync` usage.
- Studio cloned `WorldV2Builder` + cloned `RoomConfig` validation passed with
  ten portal models, no `WorldValidation` errors, Room 1 queue metadata
  (`CrewDefense`, 1 min player, 12 second fill), and Room 10 queue metadata
  (`CrewShare`, 4 min players, 26 second fill).
- Studio cloned `UnitTests` + cloned `RoomConfig` passed: 28 passed, 0 failed,
  including room-session propagation, crew-launch source contracts, and helper
  NPC horde behavior contracts.
- `validate_playable_space_review` passed for the scoped player-height report:
  two spaces, seven screenshots, verdict `player_angle_signed_off`.
- Studio helper visual simulation verified `SecurityManager` emitted
  `helperEvent`, `SecurityRepair` attack wave, `SecurityRepair` movement cue,
  and `SecurityRepair` world-sector cue; the sector moved from 42 health /
  82 pressure to 62 health / 18 pressure.

Additional curation-pass gates after adding the non-volcano inspection
shortlists:

- `validate_fragment_manifest` initially failed the planned evidence fragment
  because the manifest did not declare exactly one root; rerun with
  `single_root = true` passed.
- `git diff --check` passed.
- `python3 tools/validate_blocked_asset_ids.py` passed with
  `blocked_id_count=11`.
- dangerous-loader scan found only the audit-pattern list in
  `ServerScriptService/Services/AssetAuditService.lua`, not active runtime
  `require(assetId)`, `InsertService:LoadAsset`, `loadstring`, or
  `HttpService:GetAsync/PostAsync/RequestAsync` usage.
- `rojo build default.project.json -o /private/tmp/GroanTubeHero-room-curation.rbxlx`
  passed.
- Studio fresh-clone smoke passed for the changed modules:
  `AssetRegistry` exposes Cyber Arcade, Subway, Haunted Karaoke, Aquarium, and
  Doomscroll Data Center buckets with
  `claimed_maybe_requires_studio_inspection`, and `RoomConfig` still reports ten
  rooms with Room 1 as `brainrot_volcano_horde_rave`, min players 1, capacity 4.
- Full cloned Studio `UnitTests` returned 26 passed / 2 failed because Roblox
  `require` cache returned stale already-required `AssetRegistry` and
  `RoomConfig` dependencies in the open Studio session. The fresh-clone smoke
  above bypassed that cache for the changed modules; a Studio reload or cache
  reset is still needed before using the full suite as fresh evidence.
- After the Studio asset lab pass, `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan, and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-asset-lab.rbxlx`
  passed. A focused Studio fresh-clone smoke also confirmed
  `SubwayMemeTunnel` has six active asset IDs, no active
  `111644166341307`, `rejectedAfterInspection` records that asset, and the
  temporary inspection lab folder no longer exists.
- After the asset-readiness mirror pass, `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan, and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-asset-readiness.rbxlx`
  passed. A focused Studio fresh-clone smoke confirmed Cyber Arcade readiness is
  `inspected_with_fixes` with one pass and one fix asset, Subway readiness is
  `candidate_rejected` with one rejected inspected asset, palette commitment is
  still false, publish permission remains missing, and RoomService,
  WorldV2Builder, and RoomClient all expose the readiness fields.
- After the room asset preview pass, `validate_playable_space_review` passed
  with four preview lanes, eight player-height screenshots, and verdict
  `signed_off_with_risks`. The temporary
  `Workspace.CodexRoomPreviewStage_20260604` was destroyed afterward. Fresh
  gates passed: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`,
  dangerous-loader scan (only the `AssetAuditService` audit-pattern list
  matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-room-preview-final.rbxlx`.
- After the horde targeting pass, fresh gates passed: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan (only the
  `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-horde-targeting.rbxlx`.
  A focused Studio clone smoke confirmed Cyber Arcade pressure targeting picked
  the E sector and emitted `GlitchSurge` with
  `pressure_hotspot_room_bias`.
- After the room progression pass, fresh gates passed: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan (only the
  `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-room-progress.rbxlx`.
  Studio source freshness checks confirmed the active `GroanTubeHero.synced.rbxlx`
  instance has `RoomProgress`, `helperAffinityGains`, and
  `testEconomyRoomProgressRewards`. A focused Studio clone smoke confirmed a
  Cyber Arcade Hard A-grade clear persisted clear count, first-clear and
  difficulty awards, two room skins, two room boosts, PatchBot/ArcadeTech helper
  affinity, `RoomUnlocks`, and 2 GroanTokens. Full cloned `UnitTests` still
  reports the known open-Studio require-cache failures for stale
  `AssetRegistry`/`RoomConfig` dependencies; focused fresh-clone checks for
  those dependencies passed.
- The next cache-first room-art pass has a refreshed `plan_headless_assembly`
  packet set for lobby plus Volcano, Cyber Arcade, Subway Meme, Haunted
  Karaoke, Aquarium Bass, and Doomscroll Data Center fragments. The refreshed
  `plan_playable_space_review` queue includes player-height quadrants for those
  same spaces plus the multiplayer portal ring.
- After the room results UI pass, fresh gates passed: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan (only the
  `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-room-results.rbxlx`.
  Studio source smoke confirmed active `RhythmClient` contains
  `formatRoomUnlockSummary`, `RoomUnlocks`, `GroanTokens`,
  `helperAffinityGains`, `newSkins`, and `newBoosts`, and active `UnitTests`
  covers the room-unlock results screen contract.
- After the structural themed-room spaces pass, asset-search MCP v0.7 was used
  for cache preprocessing, asset-brain snapshot export, headless assembly
  planning, and player-angle review planning. The current asset brain still has
  `paletteAssets=0` and `publishPermissions=0`, so the new room spaces are
  deliberately marked `anchor_only_not_palette_committed`, not final Creator
  Store art.
- `RoomConfig.RoomSpaces` now gives every room a dedicated session footprint.
  Room 1 remains the existing Volcano Rave at the central arena; non-volcano
  rooms are moved outside the central WorldV2 radius (`Cyber Arcade` at
  `x=260`, `Subway` at `x=380`, mirrored west/east/south/north rooms) so room
  sessions do not overlap the Volcano dressing.
- `WorldV2Builder` now creates `ThemedRoomSpaces` with one
  `RoomSpace_%02d_<roomId>` model per room. Each model has a playable floor,
  entry/rules signs, structural theme cues, visible backdrop panels, quadrant
  review markers, helper beacon, inspected-asset anchor pads, and asset-search
  slot markers. `InvisibleGameplayHitboxes` also gets four colliding
  `RoomWall_*_<roomId>` boundaries per room.
- `RoomService` now launches participants with
  `RoomConfig.GetLaunchCFrame(session.roomId, participant.slot)`, so non-volcano
  rooms spawn into their dedicated spaces instead of the shared Volcano launch
  pads.
- Fresh gates passed after this pass: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan (only the
  `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-room-spaces.rbxlx`.
- Studio validation used a cloned module graph because the open Studio session
  had stale `require()` caches. The cloned build produced 10 room spaces, no
  `WorldValidation` errors, and confirmed Cyber Arcade's floor at
  `260, 1.55, 0` with four visible backdrop panels and colliding room walls.
- Player-height screenshots captured during the pass:
  `GroanTubeHero_brainrot_volcano_horde_rave_nw_player`,
  `GroanTubeHero_brainrot_volcano_horde_rave_ne_player`,
  `GroanTubeHero_brainrot_volcano_horde_rave_sw_player`,
  `GroanTubeHero_brainrot_volcano_horde_rave_se_player`,
  `GroanTubeHero_cyber_arcade_overclock_nw_player_repositioned`, and
  `GroanTubeHero_moonbase_echo_dome_nw_player_spotcheck`.
- Player-height review finding: the first Cyber Arcade footprint overlapped the
  central Volcano dressing and showed Volcano silhouettes from inside the room.
  The fix was to move non-volcano rooms farther out and retake the Cyber
  player-height shot. Remaining visual risk: rooms are structurally playable
  but still sparse/anchor-only until real Creator Store room art is committed
  and re-reviewed.
- After the NPC action and pushback pass, fresh gates passed:
  `git diff --check`, `python3 tools/validate_blocked_asset_ids.py`,
  dangerous-loader scan (only the `AssetAuditService` audit-pattern list
  matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-npc-actions.rbxlx`.
  A focused Studio clone smoke confirmed the active Studio source contains the
  new `npcAction` payload path plus `renderNpcAction`, `HordeActionShockwave`,
  `HordeHelperBeam`, and `HordeActionActorBeacon`; Cyber Arcade hazard and
  PatchBot support payloads emitted the expected action kind, type, actor, and
  sector metadata.
- The scoped player-angle visual review for Volcano and Cyber passed with
  `signed_off_with_risks`: eight quadrant screenshots, two spaces, and no
  unresolved major/blocker findings. Risks remain minor and visual: Volcano is
  very magenta-heavy, and Cyber Arcade remains sparse until palette art is
  committed.
- After the room encounter dressing pass, fresh gates passed:
  `git diff --check`, `python3 tools/validate_blocked_asset_ids.py`,
  dangerous-loader scan (only the `AssetAuditService` audit-pattern list
  matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-room-encounters.rbxlx`.
  Studio fresh-graph smoke confirmed 10 generated room spaces and verified the
  new encounter layers for Volcano and Cyber. A scoped player-angle review also
  passed with `signed_off_with_risks` using
  `GroanTubeHero_volcano_encounter_layers_nw_player` and
  `GroanTubeHero_cyber_encounter_layers_nw_player`.
- After the room objective interaction pass, the visual objective stations are
  server-bound gameplay prompts instead of decorative props. `RoomService`
  binds `RoomObjectivePrompt` separately from room queue portals so objective
  prompts cannot call `JoinRoom`. Each room-session objective uses a
  session-scoped cooldown and applies one of four effects: `Repair` repairs the
  mapped horde sector, `Pushback` calls audience support, `Boost` adds hype and
  an 8 second score/hype window, and `Encore` applies an encore pushback plus
  bonus surge notes.
- `ScoreService` now consumes `roomObjectiveBoostUntil` on successful hits and
  marks `lastRoomObjectiveBoost`, so room objective boosts are measurable during
  active rhythm play. `WorldValidation` now requires four objective prompts per
  generated room, with `RoomObjectiveEffect` and `RoomObjectiveCooldown`
  metadata. Source-contract tests guard objective binding, portal exclusion,
  horde repair/support hooks, and boost scoring.
- Fresh gates passed for this objective pass: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan (only the
  `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-room-objectives.rbxlx`.
  Studio play validation passed after resetting stale module caches:
  `UnitTests.Run()` returned `passed=30, failed=0`, and
  `GameTestHarness.Run()` returned session `Harness-LocalAudioSong001-12242564`
  with score `4725`, max combo `38`, grade `A`, and `0` misses.
- Studio room-objective smoke confirmed 40 objective prompts across 10 rooms,
  zero unbound objective prompts, zero portal prompts carrying objective IDs,
  and each room has one `Repair`, `Pushback`, `Boost`, and `Encore` prompt with
  a 7 second cooldown.
- Asset-search brain snapshot for this pass remained at 103 assets, 41 reviews,
  46 inspections, 77 claims, 0 palette assets, and 0 publish-permission records.
  That keeps this pass honest: the mechanics and project-owned room scaffolds
  are improved, but final Creator Store room-art palette approval is still open.
- Scoped player-height review used the asset-search playable-space validator
  with clean quadrant captures:
  `GroanTubeHero_volcano_rave_room_nw_player_clean`,
  `GroanTubeHero_volcano_rave_room_ne_player_clean`,
  `GroanTubeHero_volcano_rave_room_sw_player_clean`,
  `GroanTubeHero_volcano_rave_room_se_player_clean`,
  `GroanTubeHero_cyber_arcade_room_nw_player_clean`,
  `GroanTubeHero_cyber_arcade_room_ne_player_clean`,
  `GroanTubeHero_cyber_arcade_room_sw_player_clean`, and
  `GroanTubeHero_cyber_arcade_room_se_player_clean`. Validation passed with
  verdict `player_angle_signed_off`, 2 spaces reviewed, 8 screenshots, and no
  warnings.
- Remaining visual risks from the clean screenshots: Volcano is still highly
  saturated, and the project-owned objective stations are readable but bulky at
  close SW/SE player-height angles. They do not block the center path for this
  objective pass, but should be scaled down or replaced with inspected Creator
  Store art in the next palette pass.
- After the room-board UI pass, `RoomClient` now renders a full scrollable
  `RoomBoardList` instead of a tiny selected-room summary. The board creates one
  `RoomCard_<roomId>` per configured room, shows occupancy, queue state, reward
  multiplier, fan/coin/ticket bonuses, minimum level, and asset-readiness text,
  and exposes a per-card `JoinRoomButton` that fires `JoinRoomRequest` through
  the existing server-authoritative room path. A responsive `UIScale` keeps the
  board usable on smaller viewports.
- Source-contract coverage now guards `RoomBoardList`, `renderRoomCards`,
  per-room cards, `JoinRoomButton`, `JoinRoomRequest`, reward/readiness labels,
  and `RoomBoardResponsiveScale`.
- Fresh headless gates passed for the room-board pass: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan (only the
  `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o /private/tmp/GroanTubeHero-room-board.rbxlx`.
- Studio play smoke confirmed the live board instantiated with 10 room cards,
  10 queue buttons, `RoomBoardResponsiveScale.Scale = 1`, and
  `CanvasSize.Y.Offset = 1000`. `UnitTests.Run()` returned `passed=30,
  failed=0`. A live UI click on
  `RoomCard_brainrot_volcano_horde_rave.JoinRoomButton` queued Room 1 and
  updated the board to `Queued: Volcano Rave`, `1/4 players`, and `crew active
  1`; clicking `LeaveRoom` returned the board to `Rooms`, `0/4 players`, and
  the Room 1 button text `Queue`.
- Room-board screenshots captured in Studio play:
  `GroanTubeHero_room_board_ui_state_play` and
  `GroanTubeHero_room_board_queued_state_play`. Remaining UI risk: the existing
  help/tutorial panel and top menu make the screen busy when the room board is
  open, although the new board itself stays readable and does not overlap the
  central action path.
- After the compact objective-station visual pass, the room objective stations
  were moved farther toward room edges and scaled down for player-height views.
  `WorldV2Builder` now marks them with `RoomObjectivePlayerAngleScale =
  "compact"`, uses compact pads/consoles/status lights, and `WorldValidation`
  rejects generated rooms with objective parts larger than 5 studs.
- A fresh Studio player-view probe confirmed 10 generated room spaces, 40
  compact objective stations, 40 objective prompts, max objective part size
  `4.599999904632568`, and `0` oversized objective parts. Client-context
  `UnitTests.Run()` returned `passed=31, failed=0`; server-only source-contract
  tests were skipped in that command context, so server coverage remains backed
  by source/Rojo validation until the Studio command context exposes
  `ServerScriptService.Services` again.
- The same Studio session no longer showed the previous
  `AudienceService`/`AudienceZone` `CFrame` runtime error after adding
  `ObjectValue` dereference guards to `AudienceService` and `AudienceClient`.
  Remaining console noise appears to be stale/place-only scripts not present in
  the repo source tree (`TestFramework`, `NPCSpawnService`,
  `MapLayoutService`, `RemoteContracts`) plus a forbidden sound asset; this is
  logged as a Studio-place cleanup risk, not a room objective blocker.
- Fresh headless gates passed for the compact objective/audience-zone fix:
  `git diff --check`, `python3 tools/validate_blocked_asset_ids.py`, dangerous
  loader scan (only the `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o
  /private/tmp/GroanTubeHero-audience-zone-fix.rbxlx`.
- Scoped player-height recaptures for the compact-objective fix:
  `GroanTubeHero_volcano_rave_room_sw_player_compact_review`,
  `GroanTubeHero_volcano_rave_room_se_player_compact_review`,
  `GroanTubeHero_cyber_arcade_room_sw_player_compact_review`, and
  `GroanTubeHero_cyber_arcade_room_se_player_compact_review`.
  `validate_playable_space_review` passed with verdict
  `signed_off_with_risks`, 2 spaces reviewed, 4 screenshots, and no warnings.
  Remaining accepted risks: Volcano is still highly saturated, and Cyber Arcade
  remains scaffold/anchor-only until real Creator Store arcade art is
  palette-committed, Studio-inspected, and recaptured.
- Next asset-search MCP pass promoted the first V1 inspection palette from 0 to
  8 committed palette assets. Exact room-name searches such as
  `cyber arcade overclock Roblox map environment room` were mostly too narrow,
  so the curation path pivoted to broader slot queries such as
  `arcade machine neon game cabinet Roblox`, `neon portal arch sci fi doorway
  Roblox`, `aquarium fish tank Roblox`, `theater stage curtain Roblox`, and
  `server rack data center Roblox`. Direct searches for fresh unclaimed
  Aquarium/Theater/Data Center/Subway assets were still sparse, so only
  Studio-inspected pass/fix candidates were committed.
- Committed GroanTubeHero inspection palette slots:
  `cyber_arcade_overclock.setpiece.cabinet_row -> 637807731`,
  `cyber_arcade_overclock.portal.static_neon_door -> 13903220189`,
  `aquarium_bass_drop.setpiece.tank -> 734771184`,
  `aquarium_bass_drop.prop.fish_school -> 5512630914`,
  `haunted_karaoke_theater.setpiece.stage -> 8297623882`,
  `haunted_karaoke_theater.npc.friendly_ghost_host -> 155660821`,
  `doomscroll_data_center.objective.terminal -> 3623280668`, and
  `doomscroll_data_center.setpiece.server_rack -> 10693308533`.
  These are inspection-palette commitments, not release approvals.
- `validate_publish_permissions(project="GroanTubeHero",
  publish_permission_mode="grantable_or_open_use")` correctly failed with
  8/8 missing publish-permission records. Source now mirrors this honestly:
  `AssetRegistry.GetRoomAssetReadiness` reports committed palette counts,
  `publishPermission = "missing"`, and
  `placementStatus = "palette_committed_pending_permission_and_fragment"` for
  Cyber Arcade, Aquarium Bass Drop, Haunted Karaoke Theater, and Doomscroll Data
  Center. Subway remains uncommitted because its inspected station shell was
  rejected as oversized/heavy.
- `plan_headless_assembly(project="GroanTubeHero", assembly_profile =
  "concert_defense")` produced the next four fragment packets for committed
  inspection-palette room art:
  `groantubehero_cyber_arcade_overclock_committed_inspection_palette_room`,
  `groantubehero_aquarium_bass_drop_committed_inspection_palette_room`,
  `groantubehero_haunted_karaoke_theater_committed_inspection_palette_room`,
  and `groantubehero_doomscroll_data_center_committed_inspection_palette_room`.
  These packets are not merged yet; each still needs one root `.rbxm`, a
  validated manifest, dangerous-loader scan, coordinator merge, and player-view
  screenshot review after merge.
- First headless fragment packet is now implemented for Cyber Arcade as an
  intake/anchor fragment:
  `fragments/groantubehero_cyber_arcade_committed_palette.rbxm` with
  `fragments/groantubehero_cyber_arcade_committed_palette.manifest.json`.
  The root is `CommittedPalette_CyberArcadeOverclock`, targets
  `Workspace.GTH_WorldV2.ThemedRoomSpaces`, declares asset IDs `637807731` and
  `13903220189`, and preserves release-blocking metadata:
  `PublishPermission = "missing"`,
  `MissingPublishPermissionCount = 2`, and
  `AssetDeliveryStatus = "blocked_401_without_authenticated_client"`.
- This Cyber fragment deliberately does not pretend to contain final Creator
  Store meshes. Direct Asset Delivery download attempts for `637807731` and
  `13903220189` returned HTTP 401 without an authenticated Roblox client
  context, and the repo has no clean `ReplicatedStorage.ArtAssets` copies for
  those committed room assets. The fragment therefore proves the coordinator
  path and preserves placement/permission intent while keeping final real-asset
  import blocked until authenticated asset bytes or Studio insertion are
  available.
- `validate_fragment_manifest` passed for the Cyber fragment with no warnings.
  The headless merge coordinator also passed:
  `lune run
  /Users/abdulrehmanbhidya/.codex/mcp/RobloxAIDev/scripts/headless_fragment_merge.luau
  --place GroanTubeHero.synced.rbxlx --out
  /private/tmp/GroanTubeHero-cyber-palette-fragment-merged.rbxl --fragment
  fragments/groantubehero_cyber_arcade_committed_palette.manifest.json
  --replace-existing --create-missing-targets --json`. A reload verifier then
  confirmed the merged root under
  `Workspace.GTH_WorldV2.ThemedRoomSpaces`, 5 child instances, and
  `HeadlessAssetIds = 637807731,13903220189`.
- Fresh gates for the fragment pass: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan (only
  the `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o
  /private/tmp/GroanTubeHero-fragment-source-check.rbxlx`.
- 2026-06-04 NPC choreography pass: asset-search MCP v0.7 remained live, and
  `preprocess_storyboard_asset_cache(project="GroanTubeHero",
  warm_search_cache=true)` plus `plan_headless_assembly(...,
  assembly_profile="concert_defense")` both returned current storyboard/headless
  packets. No Roblox Studio Creator Store search was used.
- Horde actions are now more authoritative instead of purely cosmetic:
  `HordeService` builds an explicit `npcAction` choreography contract with
  `attackId`, `pathStyle`, `laneCount`, `windupSeconds`, `impactSeconds`,
  `fromDistance`, `toDistance`, `knockbackStuds`, `pushbackStuds`, and a linked
  `movementCue.npcActionEventId`. Hazard cues such as Cyber Arcade
  `GlitchSurge` lunge inward with multiple lanes and knockback; helper cues such
  as `PatchBotStabilize` push outward with helper lane counts and pushback
  distance.
- `HordeClient` now consumes those authoritative fields for windup rings,
  multi-lane attack/helper beams, actor-beacon movement, and horde-cluster
  radius changes. Helper/support actions move the cluster outward using
  `pushbackStuds`; hazard actions pull it inward using `knockbackStuds`.
- Player-angle review exposed two source-side visual defects in the structural
  room scaffolds. Volcano quadrants were readable but over-saturated by bright
  magenta room backdrops. Cyber Arcade hazard lanes blended cyan and red into
  near-white floor slabs. `WorldV2Builder` now darkens room floors/backdrops,
  softens boundary rails, uses red-tinted hazard lanes with higher transparency,
  and hides oversized top `SurfaceGui` labels on hazard lane parts.
- Studio validation detail: the active Studio place had stale require caches for
  `WorldV2Config`, `AssetRegistry`, `RoomConfig`, and `WorldV2Builder`. Fresh
  cloned module requires plus a live cached-table patch were needed before
  `WorldV2Builder.Build()` produced 10 `ThemedRoomSpaces`. This is a Studio
  live-cache issue; the filesystem source and Rojo build are the authority.
- Scoped player-height screenshots captured for this pass:
  `GroanTubeHero_volcano_rave_room_sw_player_npc_choreo`,
  `GroanTubeHero_volcano_rave_room_se_player_npc_choreo`,
  `GroanTubeHero_volcano_rave_room_nw_player_npc_choreo`,
  `GroanTubeHero_volcano_rave_room_ne_player_npc_choreo`,
  `GroanTubeHero_cyber_arcade_room_sw_player_npc_choreo`,
  `GroanTubeHero_cyber_arcade_room_se_player_npc_choreo`,
  `GroanTubeHero_cyber_arcade_room_nw_player_npc_choreo`,
  `GroanTubeHero_cyber_arcade_room_ne_player_npc_choreo`,
  plus recaptures
  `GroanTubeHero_volcano_rave_room_sw_player_npc_choreo_recap` and
  `GroanTubeHero_cyber_arcade_room_sw_player_npc_choreo_recap2`.
  `validate_playable_space_review` passed cleanly with verdict
  `signed_off_with_risks`, 2 spaces reviewed, 10 screenshots, 3 findings, and no
  warnings. This is scoped player-angle evidence, not full-map final signoff.
- Fresh gates for the NPC choreography/visual cleanup pass: `git diff --check`,
  `python3 tools/validate_blocked_asset_ids.py`, dangerous-loader scan (only the
  `AssetAuditService` audit-pattern list matched), and
  `rojo build default.project.json -o
  /private/tmp/GroanTubeHero-npc-choreo-final.rbxlx`.

## 2026-06-04 Room Objective Progress Pass

This source-only pass kept Studio off the critical path and used the live
`asset-search` MCP for cache/headless/review planning. The v0.7 tool surface was
present, including `preprocess_storyboard_asset_cache`,
`export_asset_brain_snapshot`, `plan_headless_assembly`,
`validate_fragment_manifest`, `plan_playable_space_review`, and
`validate_playable_space_review`; no repo-local fallback MCP was needed.

Cache/headless evidence from this pass:

- `preprocess_storyboard_asset_cache(project="GroanTubeHero",
  warm_search_cache=true, extensive=true)` ran for the lobby plus Brainrot
  Volcano, Cyber Arcade, Subway Meme, Haunted Karaoke, Aquarium, Moonbase,
  Doomscroll Data Center, and Backrooms Beat Maze themes. It returned useful
  broad lobby/volcano candidates but sparse exact results for several highly
  specific room phrases, so no new release-ready art was claimed.
- `export_asset_brain_snapshot(project="GroanTubeHero",
  include_search_cache=true)` reported 103 assets, 12 capped search-query
  summaries, 41 reviews, 46 inspections, 77 claims, 8 palette assets, and 0
  publish-permission records. The zero publish-permission count remains a
  release blocker for final real-art placement.
- `plan_headless_assembly(project="GroanTubeHero",
  assembly_profile="concert_defense")` returned WorldV2 fragment packets for the
  lobby and themed room fragments. The existing Cyber Arcade committed-palette
  fragment manifest still passed `validate_fragment_manifest` with no warnings.
- `lune run scripts/verify_fragment_merge.luau
  /private/tmp/GroanTubeHero-cyber-palette-fragment-merged.rbxl
  Workspace.GTH_WorldV2.ThemedRoomSpaces
  CommittedPalette_CyberArcadeOverclock` passed, confirming the merged
  Cyber fragment root and asset ID metadata remain readable.

Gameplay work from this pass:

- `RoomService` now records shared room objective progress per active room
  session instead of only applying isolated prompt cooldown effects. Active
  sessions track `objectiveProgress`, `objectiveMomentum`, `objectiveCombo`,
  milestone history, last objective, and per-player `objectiveContributions`.
- Room objective uses now return an objective snapshot to clients, update the
  participant's contribution stats, and fire 25/50/75/100 percent milestone
  support. The 100 percent milestone extends the room objective score boost and
  sends an encore-strength horde pushback.
- `RoomClient` now displays active-room objective progress, combo, and momentum
  in the room board and augments objective toasts with progress/milestone
  feedback.
- `UnitTests.lua` source contracts now require the room objective snapshot,
  server-side progress fields, per-player contribution tracking, milestone
  emission, and client objective-progress/milestone UI consumption.

Fresh gates for this pass:

- `git diff --check` passed.
- `python3 tools/validate_blocked_asset_ids.py` passed with
  `blocked_id_count=11`.
- Dangerous-loader scan matched only the intentional
  `ServerScriptService/Services/AssetAuditService.lua` audit-pattern list.
- `rojo build default.project.json -o
  /private/tmp/GroanTubeHero-room-objective-progress.rbxlx` passed.
- `validate_playable_space_review` passed for the recorded Volcano/Cyber
  player-height quadrant review with verdict `signed_off_with_risks`,
  2 spaces, 8 required quadrant screenshots, 3 findings, and no warnings.
  This reused the recorded quadrant screenshot IDs for the source-only mechanics
  pass; fresh Studio play-mode HUD screenshots are still required before final
  v1 signoff because the room board UI text changed.

## 2026-06-04 Room UI Play-Mode Screenshot Pass

This pass used Studio only after the source tree passed headless gates. The open
synced Studio place already had the RoomClient objective-progress source, but
not all later UI patches were synced, so the validated candidate was the Rojo
build output `/private/tmp/GroanTubeHero-room-ui-overlap-fix6.rbxlx` plus
validation-only source sync for the active Studio candidate. The repo source is
the authority.

Captured play-mode UI states:

| UI state | Capture ID | Result |
| --- | --- | --- |
| empty room board | `GTH_room_board_empty_play_ui_clean_20260604` | room board readable; welcome card visible but not covering room board |
| queued/countdown room board | `GTH_room_board_queue_countdown_play_ui_20260604` | `Queued: Volcano Rave`, `1/4 players`, countdown visible |
| active room board | `GTH_room_board_active_objective_zero_play_ui_20260604` | active session visible as `crew active 1 objective 0%` |
| song-active HUD, final clean state | `GTH_room_song_active_hud_compact_clean_no_overlap_play_ui_20260604` | rhythm lanes clear; compact `Volcano Rave objective 0%` chip visible |

Screenshot-driven fixes from this pass:

- Initial song-active HUD capture showed the full room board overlapping the
  rhythm lane legend. `RoomClient` now hides `RoomPanel` when
  `RhythmGui.SongActive` is true and shows a compact `RoomSongStatusChip`
  instead.
- `PlayerGui` can contain duplicate `RhythmGui` names, including folders.
  `RoomClient`, `DataClient`, and `AudienceClient` now bind only the
  `RhythmGui` `ScreenGui` before trusting `SongActive`.
- A second replay found the compact chip retaining an old `RoomSessionReady`
  toast. `RoomClient` now refreshes the chip from the latest room snapshot when
  song-active state begins.
- A third replay found the chip could still show stale countdown text when
  `StartSongRequest` promoted an expired countdown queue into an active room
  session. `RoomService:PrepareSongPayload` now broadcasts immediately when it
  creates a room session during song preparation.
- The welcome card, top action bar, stage arrow, and Audience/Watch panel were
  still crowding rhythm play. `DataClient` hides profile chrome during active
  songs, and `AudienceClient` centralizes panel visibility so forced-open or
  zone-open audience UI is suppressed while `SongActive` is true.

Fresh gates for this pass:

- `git diff --check` passed.
- `python3 tools/validate_blocked_asset_ids.py` passed with
  `blocked_id_count=11`.
- Dangerous-loader scan matched only the intentional
  `ServerScriptService/Services/AssetAuditService.lua` audit-pattern list.
- `rojo build default.project.json -o
  /private/tmp/GroanTubeHero-room-ui-overlap-fix6.rbxlx` passed.
- `validate_playable_space_review` passed for the scoped UI-state report with
  verdict `signed_off_with_risks`, 1 reviewed UI space, 4 screenshots, 4
  findings, and no warnings. This is a scoped UI/HUD review, not full-map final
  signoff.

## 2026-06-04 Committed Palette Fragment Expansion Pass

This pass kept Studio off the critical path and used the live `asset-search`
MCP v0.7 surface plus Lune/Rojo validation. No Roblox Studio search was used.

Current asset-brain snapshot before fragment expansion:

| Field | Count |
| --- | ---: |
| assets | 103 |
| search queries | 0 |
| reviews | 41 |
| inspections | 46 |
| claims | 77 |
| palette assets | 8 |
| publish permission records | 0 |

The committed palette now has one-root intake fragments for four room palettes:

| Room | Root | Manifest | Asset IDs |
| --- | --- | --- | --- |
| Cyber Arcade Overclock | `CommittedPalette_CyberArcadeOverclock` | `fragments/groantubehero_cyber_arcade_committed_palette.manifest.json` | `637807731`, `13903220189` |
| Aquarium Bass Drop | `CommittedPalette_AquariumBassDrop` | `fragments/groantubehero_aquarium_bass_drop_committed_palette.manifest.json` | `734771184`, `5512630914` |
| Haunted Karaoke Theater | `CommittedPalette_HauntedKaraokeTheater` | `fragments/groantubehero_haunted_karaoke_committed_palette.manifest.json` | `8297623882`, `155660821` |
| Doomscroll Data Center | `CommittedPalette_DoomscrollDataCenter` | `fragments/groantubehero_doomscroll_data_center_committed_palette.manifest.json` | `3623280668`, `10693308533` |

Each fragment declares `target_parent =
Workspace.GTH_WorldV2.ThemedRoomSpaces`, `single_root = true`,
`identity_policy.referents = coordinator_remap`, `unique_ids = strip`, and
`history_ids = strip`. Each generated root carries the release-blocking
attributes `PublishPermission = missing`,
`AssetDeliveryStatus = blocked_401_without_authenticated_client`, and
`FragmentContentKind = committed_palette_intake_anchor`.

`validate_fragment_manifest` passed with no errors or warnings for all four
manifests. The headless merge coordinator then merged all four fragments into:

`/private/tmp/GroanTubeHero-committed-palette-fragments-merged.rbxl`

Reload verification passed for all four merged roots:

- `CommittedPalette_CyberArcadeOverclock` with assets
  `637807731,13903220189`;
- `CommittedPalette_AquariumBassDrop` with assets `734771184,5512630914`;
- `CommittedPalette_HauntedKaraokeTheater` with assets
  `8297623882,155660821`;
- `CommittedPalette_DoomscrollDataCenter` with assets
  `3623280668,10693308533`.

Fresh gates for this pass:

- `git diff --check` passed.
- `python3 tools/validate_blocked_asset_ids.py` passed with
  `blocked_id_count=11`.
- Dangerous-loader scan matched only the intentional
  `ServerScriptService/Services/AssetAuditService.lua` audit-pattern list.
- `rojo build default.project.json -o
  /private/tmp/GroanTubeHero-committed-palette-source-check.rbxlx` passed.

This is still an intake/permission-gate layer, not final real-art placement.
The asset-search snapshot has `0` publish-permission records, and authenticated
asset bytes are still unavailable outside a Roblox-authenticated client context.

## 2026-06-04 Source Player-Angle Quadrant Review

After the headless merge and source gates passed, Studio MCP was used for a
source-place visual audit. The validated merged candidate
`/private/tmp/GroanTubeHero-committed-palette-fragments-merged.rbxl` did not
register as a connected Studio MCP instance after two open attempts, so this
pass did not claim merged-fragment visual signoff.

The active Studio instance was `GroanTubeHero.synced.rbxlx`. A read-only audit
confirmed `Workspace.GTH_WorldV2.ThemedRoomSpaces` existed with ten source room
models, palette/readiness attributes for Cyber, Haunted, and Aquarium, and no
standalone `CommittedPalette_*` roots in the active source place.

Player-height quadrant screenshots captured from the active source place:

| Space | Capture IDs |
| --- | --- |
| Cyber Arcade Overclock | `GroanTubeHero_cyber_arcade_overclock_nw_player_source_20260604`, `GroanTubeHero_cyber_arcade_overclock_ne_player_source_20260604`, `GroanTubeHero_cyber_arcade_overclock_sw_player_source_20260604`, `GroanTubeHero_cyber_arcade_overclock_se_player_source_20260604` |
| Aquarium Bass Drop | `GroanTubeHero_aquarium_bass_drop_nw_player_source_20260604`, `GroanTubeHero_aquarium_bass_drop_ne_player_source_20260604`, `GroanTubeHero_aquarium_bass_drop_sw_player_source_20260604`, `GroanTubeHero_aquarium_bass_drop_se_player_source_20260604` |
| Haunted Karaoke Theater | `GroanTubeHero_haunted_karaoke_theater_nw_player_source_20260604`, `GroanTubeHero_haunted_karaoke_theater_ne_player_source_20260604`, `GroanTubeHero_haunted_karaoke_theater_sw_player_source_20260604`, `GroanTubeHero_haunted_karaoke_theater_se_player_source_20260604` |
| Doomscroll Data Center planned anchor | `GroanTubeHero_doomscroll_data_center_nw_player_source_20260604`, `GroanTubeHero_doomscroll_data_center_ne_player_source_20260604`, `GroanTubeHero_doomscroll_data_center_sw_player_source_20260604`, `GroanTubeHero_doomscroll_data_center_se_player_source_20260604` |

`validate_playable_space_review` returned `passed = false`,
`verdict = not_signed_off`, 4 spaces reviewed, 16 screenshots, and 5 findings.
The unresolved findings are accurate:

- Cyber Arcade, Aquarium, and Haunted are navigable and labeled at player
  height, but they still rely on structural/intake markers rather than
  authenticated Creator Store asset bytes.
- Doomscroll Data Center was missing from the active source place; the planned
  anchor screenshots showed void/neighbor geometry instead of a playable room.

Repair applied after the failed source visual gate:

- `ReplicatedStorage/Shared/WorldV2/RoomConfig.lua` now promotes
  `doomscroll_data_center` into the active room slate as Room 11 with a source
  room space at `Vector3.new(380, 3.5, 260)`, queue/session metadata, rewards,
  skins, boosts, helper NPCs, asset-search slots, and review-space ID
  `doomscroll_data_center_room`.
- `ServerScriptService/Services/WorldV2Builder.lua` now gives Doomscroll
  source-room encounter labels and hazard cues: rack cooling, viral panels,
  firewall freeze, cache recovery, and heat overload.
- `ReplicatedStorage/Shared/UnitTests.lua` now asserts Doomscroll is active in
  `RoomConfig`, has an independent source room space, and launches away from
  Room 1.
- `rojo build default.project.json -o
  /private/tmp/GroanTubeHero-doomscroll-room11-final-check.rbxlx` passed.
- `git diff --check`, `python3 tools/validate_blocked_asset_ids.py`, and the
  dangerous-loader scan were rerun after the Room 11 repair. The only dangerous
  loader match remained the intentional `AssetAuditService.lua` audit-pattern
  list.

The Room 11 repair still needs a fresh Studio source-sync/open and recaptured
Doomscroll quadrant screenshots before the Doomscroll visual blocker can be
closed.

## 2026-06-04 Doomscroll Horde Mechanics Pass

This pass turned Doomscroll Data Center from a promoted room shell into an
active horde-mechanics room. The change follows the existing room-specific
`HordeService` pattern and does not add any runtime asset loaders.

Gameplay mechanics added:

- `HeatOverload` hazard: Doomscroll misses/passive creep now overload the hot
  server-rack sector, increase sector pressure, damage sector health, emit
  `roomHazard`, `roomMechanicEvent`, `movementCue`, and authoritative
  `npcAction` payloads, and render as a multi-lane horde lunge.
- `FirewallAdmin` helper: with the `FirewallFreeze` boost/helper, a weak or
  overloaded sector triggers a support action that lowers rack pressure,
  repairs sector health, pushes the horde outward, and records the helper actor
  in the NPC action payload.
- `CacheMedic` helper: with the `CooldownCache` boost/helper, good hits can
  purge popup pressure into cooldown recovery and support pushback.
- `HordeClient` now classifies `HeatOverload` as a room hazard cue and
  `FirewallFreeze` / `CacheRecovery` as room support cues, so Doomscroll
  mechanics do not fall back to generic horde coloring.

Source contracts and behavior tests added in
`ReplicatedStorage/Shared/UnitTests.lua`:

- `HordeService` source must define `HeatOverload`, `FirewallFreeze`, and
  `CacheRecovery`;
- `HordeClient` source must recognize the same Doomscroll cues;
- Doomscroll miss behavior must emit a `HeatOverload` room hazard and hazard
  `npcAction` with multiple lanes and knockback;
- Doomscroll helper behavior must emit a `FirewallFreeze` helper event/support
  `npcAction`, repair the overloaded rack sector, and lower rack pressure.

Fresh gates for this pass:

- `rojo build default.project.json -o
  /private/tmp/GroanTubeHero-doomscroll-horde-mechanics.rbxlx` passed.
- `git diff --check` passed.
- `python3 tools/validate_blocked_asset_ids.py` passed with
  `blocked_id_count=11`.
- Dangerous-loader scan matched only the intentional
  `ServerScriptService/Services/AssetAuditService.lua` audit-pattern list.

Fresh Studio `UnitTests.Run()` was not claimed in this pass because the active
Studio place was not synced with the Room 11/Doomscroll horde source patches.

## 2026-06-04 Crew Roster Launch Repair

The next multiplayer-room pass fixed a launch propagation gap found in the
source path: `SongSessionService:_startRoomCrewSong` was shallow-copying the
starter's prepared payload for every crew member, which meant non-starter
clients could inherit the starter's `roomLaunchSlot` and team metadata.

Changes in this pass:

- `RoomService` now emits a stable `roomCrewKey`, `roomParticipantCount`, and
  `roomParticipantUserIds` with room snapshots, `RoomSessionReady` payloads,
  and decorated song payloads.
- `SongSessionService` now stores and forwards the crew key, participant count,
  participant user-id roster, room min/capacity, and room ready/start times to
  start/finish client payloads.
- Crew launch fanout now marks every participant `playing` before firing song
  starts, then maps each member payload from its own participant record with
  `memberPayload.roomTeamName = participant.teamName` and
  `memberPayload.roomLaunchSlot = participant.slot`.
- `EconomyService` reward and history records now keep `RoomCrewKey` and
  `RoomParticipantCount`, so real two-client room runs can be audited after the
  song finishes.
- `ReplicatedStorage/Shared/UnitTests.lua` now includes source-contract checks
  for the per-participant slot mapping and reward assertions for the new crew
  metadata.

Cache/headless evidence for this pass:

- The live asset-search MCP exposed the v0.7 workflow tools and was used for
  cache preprocessing, brain snapshot export, and headless assembly planning.
- A warmed cache pass for `robot repair rave`, `mini golf meltdown`,
  `castle dungeon drop`, `spaceport security check`, `skatepark echo jam`,
  `doomscroll data center`, and `brainrot volcano horde rave` produced usable
  early candidates for Robot Repair but sparse/empty first-pass results for the
  other new dream-room themes.
- Because the first-pass dream-room cache was not strong enough and had no
  publish-permission records, no new Creator Store assets were inserted or
  claimed as final room art in this pass.
- Existing Cyber Arcade, Aquarium Bass Drop, Haunted Karaoke Theater, and
  Doomscroll Data Center committed-palette manifests were revalidated through
  `validate_fragment_manifest` and passed.
- The headless merge coordinator rebuilt
  `/private/tmp/GroanTubeHero-room-crew-roster-fragments-merged.rbxl` from
  `GroanTubeHero.synced.rbxlx` with the four committed-palette fragments.
  `scripts/verify_fragment_merge.luau` reloaded the merged place and verified
  all four roots plus their asset-id attributes:
  `CommittedPalette_CyberArcadeOverclock`,
  `CommittedPalette_AquariumBassDrop`,
  `CommittedPalette_HauntedKaraokeTheater`, and
  `CommittedPalette_DoomscrollDataCenter`.
- A fresh scoped player-angle review plan was generated for Volcano Rave, Cyber
  Arcade, Aquarium Bass Drop, Haunted Karaoke Theater, and Doomscroll Data
  Center with NW/NE/SW/SE captures for each room. The plan is not a signoff
  because the required Studio screenshots were not recaptured after this source
  patch.

## Not Final Signoff

This is not full-map final signoff. Missing final gates:

- additional UI screenshots across mobile/desktop viewports and reward/results
  states; basic room-board empty/countdown/active/song HUD states were captured
  in the scoped UI pass above;
- full overhead/reverse captures for all playable spaces;
- recaptured source-player-angle screenshots for Room 11 Doomscroll Data Center
  after source sync/build, replacing the void/neighbor captures from the
  pre-repair active Studio place;
- Studio play test for multi-player party behavior with two or more clients;
- two-or-more-client proof that room-session participant status, crew song
  launch, and return handling work under real multiplayer timing;
- publish-permission records for the 8 committed inspection-palette assets;
- authenticated asset bytes or Studio-inserted clean ArtAssets for the 8
  committed inspection-palette assets;
- final real-asset fragment generation/merge for committed room-art palette
  assets. Four committed-palette intake/anchor fragments now merge headlessly
  as coordinator proof, but they intentionally do not contain authenticated
  Creator Store mesh bytes;
- new Creator Store room art import/inspection per uncommitted room, especially
  Subway Meme Tunnel replacement art;
- Studio-place cleanup for stale scripts or place-only bootstrap/tests that are
  not represented in the current Rojo source tree.
