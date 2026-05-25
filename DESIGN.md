# Design

## Source of truth
- Status: Draft
- Last refreshed: 2026-05-25
- Primary product surfaces: Roblox lobby arena, rhythm HUD, song select, results, store/upgrades, missions, tour bus, audience/watch.
- Evidence reviewed: `README.md`, `StarterPlayer/StarterPlayerScripts/RhythmClient.client.lua`, `InputController.client.lua`, `StageFeedbackClient.client.lua`, `DataClient.client.lua`, `AudienceClient.client.lua`, `EngagementClient.client.lua`, `ServerScriptService/Services/GameBootstrap.server.lua`, live Studio stage/horde layout via MCP, Roblox Creator Hub UI/asset guidance, Creator Store searches for volcano, stage lights, and monster horde assets.

## Brand
- Personality: chaotic concert-defense, brainrot horror comedy, loud arcade feedback.
- Trust signals: arrow-only controls, clear hit line, obvious horde movement, no mystery buttons, close buttons on cards.
- Avoid: placeholder/copyright-economy language, alternate key prompts, paid power, admin/gold/lootbox vibes, unreadable giant signs blocking play.

## Product goals
- Goals: player stands center stage, fights climbing brainrot horde with music, sees combo/lighting/horde reaction every few seconds.
- Non-goals: karaoke, microphone, pitch detection, copyrighted song economy, pay-to-win.
- Success signals: touch + keyboard hit notes reliably; horde visibly advances/retreats; combo streak feels exciting; all cards can close.

## Personas and jobs
- Primary personas: Roblox rhythm players, mobile/touch players, casual players drawn to absurd brainrot visuals.
- User jobs: pick song fast, understand controls, hit notes, survive horde, collect rewards, upgrade, replay.
- Key contexts of use: desktop keyboard, mobile/touch screen, short 20–40 second demo sessions.

## Information architecture
- Primary navigation: HUD buttons plus physical kiosks.
- Core screens: Help/Tutorial, Song Select, Rhythm HUD, Results, Store/Upgrades, Missions, Tour Bus, Watch.
- Content hierarchy: gameplay first; progression second; audience/watch side-zone; debug/dev content hidden.

## Design principles
- Principle 1: Stage story readable at glance — raised center performer, ramping horde, enclosed volcano arena, no open cloud void.
- Principle 2: Every hit creates feedback — lane flash, judgement, combo pop, lights, horde movement.
- Tradeoffs: favor readable arcade clarity over realistic map clutter.

## Visual language
- Color: lava orange/red danger, cyan stage safety, green brainrot, purple audience/watch.
- Typography: bold GothamBlack signs/HUD, short labels.
- Spacing/layout rhythm: stage-relative placement from actual StagePlatform bounds, large touch targets, high contrast, no overlapping 3D text.
- Shape/radius/elevation: rounded HUD cards, neon stage panels, raised center platform.
- Motion: notes descend to hit line; horde tweens ramp-to-stage; lights flash on streaks/misses.
- Imagery/iconography: arrow symbols only for controls; brainrot asset clones as horde, stripped of scripts; volcanic walls, toxic fog banks, trusses, and lava moat close the arena silhouette.


## Creator asset research notes
- Creator Store searches reviewed: low-poly volcano/backdrop props, concert stage lights, and low-poly monster/horde characters.
- Asset rule: prefer mesh/model visuals only; any inserted Creator Store model must be inspected, anchored, stripped of scripts/remotes/prompts, and placed under `Workspace.Stage.BrainrotBackdrop` or `Workspace.Stage.BrainrotHorde.HordeRoot`.
- Safety rule: avoid Marketplace scripts because the game ban list and Roblox Creator Store guidance reject remote package loaders, dynamic string execution, service-based insertion, linked sources, and obfuscated code.
- Current implementation choice: use safe procedural volcano/horde/stage feedback first; curate visual-only assets later when they can be reviewed in Studio without adding mystery scripts.

## Components
- Existing components to reuse: `RhythmGui`, `InputController`, `StageFeedbackClient`, `AudienceGui`, `StoreGui`, `MissionGui`.
- New/changed components: clickable/tappable lane columns, combo streak banner, smaller map signs, brighter horde, side audience zone, ArenaEnclosure generated from stage bounds.
- Variants and states: Perfect/Good/Miss, combo milestones, Disaster, horde Far/Approaching/Close/Critical.
- Token/component ownership: Roblox instances created in client scripts and `GameBootstrap.server.lua`; no external UI libs.

## Accessibility
- Target standard: practical Roblox readability.
- Keyboard/focus behavior: arrow keys only; gameplay arrows sink camera movement while song active.
- Contrast/readability: bright arrows, thick hit line, high-contrast HUD.
- Screen-reader semantics: Roblox limited; text must be readable visually.
- Reduced motion and sensory considerations: keep flashes short; avoid permanent camera shake/audio duck.

## Responsive behavior
- Supported breakpoints/devices: desktop and touch/mobile.
- Layout adaptations: touch lanes occupy full note columns; mobile buttons/lane taps trigger same path.
- Touch/hover differences: click/tap lane column as notes hit line; no hover-dependent gameplay.

## Interaction states
- Loading: song select stays usable; visual chart mode if audio absent.
- Empty: invalid songs hidden; local/test list only if valid.
- Error: no fake hit sent when no candidate note.
- Success: combo pop, lane flash, horde pushback, lights.
- Disabled: input ignored outside active song.
- Offline/slow network, if applicable: no HTTP dependency.

## Content voice
- Tone: short, arcade, urgent.
- Terminology: “brainrot horde,” “Stability,” “Hype,” “combo streak,” “tap/click lanes.”
- Microcopy rules: arrows only (`← → ↑ ↓`); no alternate key names; no paid-power/download promises.

## Implementation constraints
- Framework/styling system: Roblox Luau instances, no external modules, no `require(assetId)`, no HTTP.
- Design-token constraints: use existing `Config`, lane colors, `GothamBlack`; generated map props derive from StagePlatform bounding box, not hardcoded cloud coordinates.
- Performance constraints: tween anchored horde visuals; no NPC pathfinding.
- Compatibility constraints: Studio/live place must preserve current systems.
- Test/screenshot expectations: Studio Play smoke; verify touch lane buttons, X buttons, title cleanup, horde visibility, no errors.

## Open questions
- [ ] Which imported brainrot assets are best hero horde models? Owner: designer/dev. Impact: visual polish.
- [ ] Final music rights for uploaded audio IDs. Owner: creator. Impact: public release naming/visibility.
