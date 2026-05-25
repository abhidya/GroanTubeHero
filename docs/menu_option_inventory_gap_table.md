# Menu Option Inventory + Gap Table

Date: 2026-05-25
Task lane: `G001-menu-option-inventory` / worker-1

## Scope and sources

This is a repo-code inventory of current menu/UI options and their present outcomes. It is intended to feed the Creator asset expansion lanes by naming the target user story, visible world/gameplay effect, asset need, and validation hook for each option before implementation expands effects or art.

Primary code sources:

- `StarterPlayer/StarterPlayerScripts/UIUXMenuController.client.lua:13-198` — central menu stack, close/back/open routing, prompt mapping, `OpenMenu`/`OpenSongSelect` remotes.
- `StarterPlayer/StarterPlayerScripts/RhythmClient.client.lua:250-291` — lobby `NavigationMenu` buttons.
- `StarterPlayer/StarterPlayerScripts/RhythmClient.client.lua:305-400` — `SongSelectModal`, close/back, difficulty, segment, song cards.
- `StarterPlayer/StarterPlayerScripts/RhythmClient.client.lua:403-441` and `779-799` — `ResultsFrame` actions.
- `StarterPlayer/StarterPlayerScripts/StoreClient.client.lua:56-188` — Store/Progression panel tabs, purchasable cards, informational outcome cards, open/close attributes.
- `StarterPlayer/StarterPlayerScripts/AudienceClient.client.lua:65-105` — Hype/Audience close and crowd callout actions.
- `StarterPlayer/StarterPlayerScripts/DataClient.client.lua:143-227` — welcome/action-bar entry points.
- `ServerScriptService/Services/VendorPromptService.lua:31-112` — world prompt remotes/dialogue/repair outcomes.
- `ReplicatedStorage/Shared/WorldV2/UIUXValidation.lua:144-214` — current validation coverage for modal open/close/back/reopen, prompt paths, and viewport bounds.

## Main interface inventory

| Surface / option | Current open path | Current outcome | Target user story | Target visible world/gameplay effect | Asset need | Existing validation hook | Gap / next owner |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Lobby `Choose Song` | `NavigationMenu` button routes to `SongSelect`; welcome/action-bar `Songs`/`Choose Song` set `OpenSongSelect` | Opens `SongSelectModal`, hides nav, rebuilds song cards | As a player, I can start a run from the lobby without hunting for the stage mic | Stage mic/DJ signage should pulse; horde ring should idle-react to the chosen run | DJ sign, glowing mic state, song-card art thumbnails | `UIUXValidation` opens SongSelect and checks close/back/reopen | Needs per-song preview world effect + thumbnail asset mapping |
| Lobby `Store` | Nav, welcome button, action bar, `Vendor_Store`, `OpenMenu("Store")` | Opens `StoreGui` tab `Tube Sounds`; `LastOutcome` text only | As a player, I can browse sound cosmetics and understand what equipping changes | Equipped tube sound should preview as a speaker/tube prop reaction near stage/vendor | Audited tube/speaker props and UI preview art | Store tab render is code-present; no explicit validation of `LastOutcome`/tab | Needs active world preview/equip effect and validation assertion |
| Lobby `Upgrades` | Nav, welcome button, `Vendor_UpgradeEngineer`, results action, `OpenMenu("Upgrades")` | Opens upgrade cards; purchase fires `PurchaseItem(GameplayUpgrades, id)` | As a player, I can improve future runs and see why each upgrade matters | Upgrade Engineer station should light meters/blueprints for selected upgrade | Upgrade kiosk props/meters/icons | `UIUXValidation` checks prompt path; store card code present | Needs per-upgrade preview effect and post-purchase visual feedback |
| Lobby `Missions` | Nav, action bar, `MissionOfficer`, results action, `OpenMenu("Missions")` | Renders mission progress and Claim button when complete | As a player, I can track gigs and claim rewards from one obvious place | Mission board should flip/check stamps; reward burst should play on claim | Mission board, stamp, ticket/fan/coin icons | prompt path validation; mission render code present | Needs claim-world VFX and mission-board state validation |
| Lobby `Security` | Nav, `SecurityManager`, horde repair prompt `OpenMenu("Security")` | Opens Security informational cards; repair prompt calls `HordeService:RepairSector` then opens Security | As a player, I can understand and react to horde pressure before it spills onto the stage | Fence sector lights/weak markers should reflect selected card or repair result | Fence repair kit, siren/security props, pressure icons | `UIUXValidation` prompt path; world validation checks horde sectors/prompts | Needs menu option to query live sector state and assert visible sector response |
| Lobby `Tutorial` | Nav, `TutorialGuide`, `OpenMenu("Tutorial")` | Opens Tutorial informational cards | As a new player, I can learn song choice, note timing, and rewards in context | Tutorial guide/stage arrows should spotlight the next physical station | Tutorial signs, arrow VFX, guide props | prompt path validation; static cards only | Needs guided step progression/world highlight validation |
| Lobby `Hype` / `Watch` | Nav, action bar Watch, `AudienceHypeManager`, audience zone, results `Hype` | Opens `AudienceGui` if present; fallback Store Hype cards | As a spectator/player, I can send crowd callouts that visibly support the performer | Audience ring should animate for clap/cheer/encore/laugh/support; support should connect to horde pressure theme | Audience crowd variants, callout icons, emote/VFX props | prompt path validation; AudienceGui code present | Needs per-action world effect and validation of `AudienceAction` outcome |
| `Results` Continue | Song finish/controller `openResults`; `ContinueButton` | Hides results and returns nav | As a player, I can acknowledge rewards and return to lobby | Reward summary should settle into wallet/mission board | Reward icon sprites/particles | `UIUXValidation` checks Continue exists | Continue is labeled but does not replay; needs expected-behavior wording or implementation decision |
| `Results` Choose Another Song | `ChooseButton` | Reopens SongSelect | As a player, I can immediately start another run | Results podium should transition back to DJ/song select | Song-select transition VFX | `UIUXValidation` checks button exists | Needs transition/world effect validation |
| `Results` Back to Lobby / X | `BackToLobbyButton`, close X | Hides results and returns nav/close only | As a player, I can exit results safely | Stage returns to idle, horde pressure idle resumes | Idle stage lighting state | `UIUXValidation` checks Back to Lobby path and close bounds | Needs explicit controller-stack validation for results close path |
| `Results` Store / Upgrades / Missions / Hype | Results secondary buttons | Opens matching progression or hype panels | As a player, I can spend or act from the post-run screen | Related vendor/station should glow from post-run selection | Vendor highlight props | Static button wiring present | Needs post-run panel validation and station highlight effect |
| Rhythm HUD touch lanes | Active song shows lane buttons | Touch/click fires note input and lane flash; hit/miss updates judgement | As a mobile player, I can play without a keyboard | Hits should drive lane flashes and horde pushback/miss glitch | Lane color/icon assets | `UIUXValidation` checks highway fits viewport | Current validation does not exercise lane input outcomes |
| Escape / gamepad B | `UIUXMenuController` input handler | Closes top menu | As a player, I can back out predictably | No world effect required beyond returning visible nav | None | controller close/back validation | Needs StoreGui/AudienceGui physical visibility close assertion, because `StoreGui.Open=false` alone is not the same as `panel.Visible=false` in current code |

## Store / Progression tab inventory

| Tab / option group | Current options | Current code outcome | Target UX/world effect | Asset need | Gap |
| --- | --- | --- | --- | --- | --- |
| `Upgrades` | Timing, Hype Gain, Recovery, Stagecraft, Chaos, Focus, Coin Bonus, Audience Power | Cards show level/cost; Buy fires `PurchaseItem` | Kiosk preview meter should show timing window/hype/recovery/etc. before purchase; purchase should animate station | Icons/meters for each upgrade family | Need per-card selected/preview state; Chaos marked Coming Soon but still purchasable code path exists |
| `Tube Sounds` | Default Groan, Squeaky Door Tube | Buy/equip cosmetics through `TubeSounds` | Preview selected tube audio identity and stage speaker/tube prop | Tube/speaker props; audio-safe icons | Needs clear preview/equip feedback and validation of equipped visual |
| `Stage Effects` | Default Glow, Confetti Burst, Smoke Machine Fail | Buy/equip `StageEffects` | Selected effect should preview near stage and trigger on big hits | Confetti/smoke/glow audited emitters/props | Needs world VFX binding to equipped effect |
| `Poses` | Mic Lean, Knee Drop, Point at Crowd | Buy/equip `AvatarPoses` | Pose preview should show performer silhouette/avatar pose | Pose silhouettes/markers | Needs avatar preview or safe placeholder-free pose art |
| `Audience` | Confused Parents, Hyper Kids, Mall Food Court Crowd | Buy/equip `AudiencePacks` | Audience ring should swap visible crowd flavor/title | Audited crowd model variants | Audience title changes if equipped; world crowd variant binding still needs proof |
| `Themes` | School Stage, Neon Arena, Wedding Hall | Buy/equip `StageThemes` | Stage/environment palette and signage should preview/apply | Theme prop/signage kits | Needs active theme preview/apply proof |
| `Missions` | MissionConfig daily/weekly definitions | Claim fires `ClaimMission` only when complete | Completed mission should produce reward burst and board checkmark | Mission board/reward icons | Needs sorted/stable ordering and claim VFX validation |
| `Security` | Fence Repair, Horde Pressure, Battle Readiness info cards | Preview button only changes outcome text | Security card should focus corresponding sector or meter in world | Security icons, sector highlight VFX | Needs live sector data and world focus hooks |
| `Tutorial` | Choose Song, Hit Arrows, Spend Rewards info cards | Preview button changes outcome text | Selecting a step should spotlight corresponding UI/world target | Tutorial guide arrows/signage | Needs guided step state and validation |
| `Hype` | Clap/Cheer, Encore, Support info cards in Store fallback | Preview button changes outcome text | Should either open AudienceGui or preview crowd callout VFX | Callout icons/crowd VFX | Fallback duplicates AudienceGui concepts; decide whether to consolidate |
| `Tour Bus` | Bigger Speakers, Snack Stand, Practice Seat, Merch Box, Road Crew, Neon Wrap | Buy fires `PurchaseItem(TourBus, id)` | Bus should visually upgrade and show benefit tooltips | Bus modules, speakers, merch/snack props, neon wrap | Not exposed through central `UIUXMenuController` major menus/prompt map; action bar/proximity route exists only in `RhythmClient`/`DataClient` |

## Song-select option inventory

| Option | Current outcome | Target UX/world effect | Gap |
| --- | --- | --- | --- |
| Close X | Hides song modal and returns nav | Stage/DJ preview returns idle | Controller close stack and direct `RhythmClient` close are separate paths; validate both |
| Back | Same as close | Same as close | Same as above |
| Difficulty: Easy/Hard/Extreme/Brainrot | Updates local selected difficulty and button colors | Stage/horde threat preview should scale visibly; rewards preview should update | No validation that selected difficulty affects visible metadata beyond card text |
| Segment: 20s/30s/40s/full | Updates selected segment and button colors | Song duration/reward preview should be explicit | No per-segment reward/time visual aside from selected card text |
| Song card Start | Fires `StartSongRequest` with song/difficulty/segment; starts song or reopens on timeout | Stage lights/audio/chart should launch; horde begins active pressure | Existing start path works, but menu inventory needs per-song preview asset IDs/thumbnails before Creator expansion |

## Audience/Hype option inventory

| Option | Current outcome | Target UX/world effect | Gap |
| --- | --- | --- | --- |
| Audience close X | Clears `Open`, hides panel | None beyond panel closing | Needs validation that close works when opened by zone and forced-open paths |
| Clap | Updates hint and fires `AudienceAction({action="Clap"})` | Crowd clap animation and small hype pulse | Needs world VFX proof |
| Cheer | Updates hint and fires `AudienceAction({action="Cheer"})` | Crowd cheer wave and stronger hype pulse | Needs world VFX proof |
| Encore | Updates hint and fires `AudienceAction({action="Encore"})` | Big finish/encore stage ring | Needs world VFX proof |
| Laugh | Updates hint and fires `AudienceAction({action="Laugh"})` | Comic reaction near misses | Needs world VFX proof |
| Support | Updates hint and fires `AudienceAction({action="Support"})` | Hype-support visual tied to horde pressure | Needs horde/audience coupling validation |

## Prioritized gap table for downstream lanes

| Priority | Gap | Why it matters | Suggested validation hook |
| --- | --- | --- | --- |
| P0 | Add validation for Store/Audience actual panel visibility after `UIUXMenuController.openMenu`, `closeMenu`, `closeTopMenu`, and Escape/back paths | `StoreGui:SetAttribute("Open", false)` does not currently prove `StorePanel.Visible=false`; `AudienceGui.Open=false` may not cover zone auto-open | Extend `UIUXValidation.Run()` with StoreGui/AudienceGui panel lookup and open/close assertions |
| P0 | Define world effect contract for each main menu: SongSelect, Store, Upgrades, Missions, Security, Tutorial, Hype, Results | Task goal requires every menu option to have meaningful UI outcome + visible world/gameplay effect | Add `MenuOutcomeValidation` or extend `UIUXValidation` to assert an attribute/event/world marker after opening each menu |
| P1 | Bind Store cosmetic/equipment choices to visible previews/equipped world art | Current cards fire server remotes but inventory cannot prove visible final art impact | Add equipped category attributes under stage/vendor/audience props and validate in Studio Play |
| P1 | Add live Security data/focus from menu cards to horde sectors | Security cards are informational; repair prompt affects horde, but menu cards do not focus/act | Validate selected card sets sector highlight or pressure meter state |
| P1 | Add Tutorial guided-step highlights | Tutorial currently reads as static cards | Validate each Tutorial card highlights DJ, note highway, or store/vendor target |
| P1 | Add Results secondary-action transition effects and expected close semantics | Post-run buttons are important spend/replay paths; Continue label may be ambiguous | Validate result buttons open expected panels and no stale ResultsFrame remains |
| P2 | Add Tour Bus to central controller/prompt inventory or document as separate progression surface | Tour Bus exists as store tab and prompt/action-bar route but not in `majorMenus`/prompt map | Add `TourBus` to controller routes if intended as first-class menu |
| P2 | Stabilize mission tab order | `pairs(MissionConfig.GetAll())` can render daily/weekly in non-deterministic order | Use configured order and validate card count/order |
| P2 | Replace info-only Hype fallback duplication with AudienceGui-open or explicit fallback contract | Two Hype surfaces can diverge | Validate Hype open path always has at least one actionable callout surface |

## Acceptance checklist for follow-up implementation

- Every row in the main inventory has at least one UI assertion and one visible world/gameplay assertion.
- Creator/Studio assets used for final visible effects are audited and script-free before active placement.
- UI close/back/reopen tests cover `SongSelect`, `Store`, `Upgrades`, `Missions`, `Security`, `Tutorial`, `Hype`, `Tour Bus` if first-class, and `Results`.
- Post-run buttons open the intended panel and do not leave overlapping major modals.
- Menu-selected world effects can be observed in Studio Play and summarized in `docs/test_results.md`.
