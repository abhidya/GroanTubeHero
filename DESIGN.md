# Design - Groan Tube Hero: WorldV2 Circular Arena

## Source of Truth
- **Status**: Approved Design Specification (Hardened)
- **Last Refreshed**: 2026-05-25
- **Primary Product Surfaces**: Roblox Lobby Circular Arena, Rhythm HUD, Song Select, Results, Store/Upgrades, Missions, Tour Bus, Spectator Area.
- **Evidence Reviewed**: `README.md`, `StarterPlayer/StarterPlayerScripts/RhythmClient.client.lua`, `InputController.client.lua`, `StageFeedbackClient.client.lua`, `DataClient.client.lua`, `AudienceClient.client.lua`, `EngagementClient.client.lua`, `ServerScriptService/Services/GameBootstrap.server.lua`, live Studio stage/horde layout via MCP, Roblox Creator Hub UI/asset guidance, Creator Store searches for volcano, stage lights, and monster horde assets.

## Brand & Aesthetic Guidelines
- **Personality**: Chaotic concert-defense, brainrot horror comedy, loud arcade feedback, premium dark mode visuals with vibrant green/magenta neon glow.
- **Trust Signals**: Responsive arrow-only controls (`← ↓ ↑ →`), a clear hit line, obvious horde radial advancement, closed buttons on all UI cards, and proximity prompts with clear action text.
- **Avoid**: Placeholder/copyright-economy language, alternate key prompts, paid power-ups, admin/lootbox vibes, and giant signs blocking the note highway.

## Product Goals
- **Core Loop**: Player stands at the center performance stage, fights off climbing brainrot monsters with rhythmic hits, and triggers dynamic speaker pulsing, spotlights, and horde pushbacks.
- **Non-Goals**: Karaoke mode, microphone input, pitch detection, copyrighted song economy, or pay-to-win mechanics.
- **Success Signals**: High-fidelity touch and keyboard inputs; clear visual feedback showing horde retreat/advance; combo streaks feeling exciting; clean responsive UI scaling.

---

## Circular Arena Layout (WorldV2)
The physical map is constructed as a concentric polar arena centered at the `StagePlatform` `(0, 10.17, 0)`. Rectangular coordinates are replaced by radial coordinates to create a 360-degree combat stage.

```text
Radius 0–18      StagePlatform Performance Zone / Note Highway Focus
Radius 20–34     Circular Stage Deck (Speaker stacks, DJ booth, mic stand, spotlights, lasers)
Radius 36–48     Inner Player Walkway & NPC Vendor Kiosks
Radius 50–58     Security Fence Ring (8 modular fence segments)
Radius 60–82     Horde Pressure Ring (8 radial spawn and climbing lanes)
Radius 84–105    Audience and VIP Spectator Ring (Bleachers, seats, VIP lounge, Tour Bus)
Radius 110–150   Volcanic Cliffs & Atmosphere Enclosure (Fog generators, lava pools)
```

### Polar Placement Coordinate Convention
All coordinate placement must use this explicit angular convention:
- **0°**: East / +X
- **45°**: Northeast / +X, +Z
- **90°**: North / +Z
- **135°**: Northwest / -X, +Z
- **180°**: West / -X
- **225°**: Southwest / -X, -Z
- **270°**: South / -Z
- **315°**: Southeast / +X, -Z

Helper equations:
```lua
local function polar(radius, angleDeg, y)
    local a = math.rad(angleDeg)
    return Vector3.new(math.cos(a) * radius, y, math.sin(a) * radius)
end

local function faceCenter(cfPosition)
    return CFrame.lookAt(cfPosition, Vector3.new(0, cfPosition.Y, 0))
end
```

---

## 8-Sector Horde Pressure System
The arena is divided into 8 sectors matching the polar coordinates: `E` (0°), `NE` (45°), `N` (90°), `NW` (135°), `W` (180°), `SW` (225°), `S` (270°), `SE` (315°).

### Sector Visual Hierarchy
Each sector is located under `Workspace.GTH_WorldV2.HordeRing.HordeSector_[SectorName]` and must contain these exact sub-objects:
- `FenceSegment` (Mesh model representing the barricade)
- `FenceDamageVFX` (Particle emitter for impact effects)
- `SecurityLight` (PointLight cast on the sector walkway)
- `SirenLight` (Alarm bulb model)
- `HordeCluster` (Folder/Model containing 5-10 lightweight visual monster rigs)
- `HordePressureMeter` (SurfaceGui displaying stability / health)
- `WeakPointMarker` (Visual mesh indicator)
- `RepairPromptAnchor` (Part holding repair prompts)

### Gameplay Mechanics
- Missing notes reduces the fence health of the currently pressured sector.
- As health falls, the sector's horde cluster advances radially:
  `currentPos = polar(82 - (1 - health/100) * 32, angle, stageTopY)`
- Good hits push the nearest horde cluster back.
- Perfect streaks repair the weakest fence sector.
- Low stability (<30%) triggers flashing red warning sirens and fence shaking.
- Song completion pushes all horde clusters back and resets all sectors.

---

## Audited Asset Sourcing Workflow
To prevent security vulnerabilities (backdoors, remote executions), all external assets must be audited before installation.

### Safety Verification Rules
1. **Asset Quarantine**: All newly imported Creator Store models must be downloaded into `ServerStorage.AssetQuarantine` or `Workspace.AssetInbox` first. They cannot be placed in the active world until scanned.
2. **Audit Check**: Run `AssetAuditService` to scan for type `Script`, `LocalScript`, or `ModuleScript`.
3. **Malicious API Flags**: Quarantine any script using:
   - `require(assetId)`
   - `loadstring`
   - `LinkedSource`
   - `InsertService` or `AssetService`
4. **Copy clean model**: Once verified script-free, copy visual nodes (MeshPart, ParticleEmitter, PointLight, SurfaceAppearance, Sound) to `ReplicatedStorage.ArtAssets`.

### Active Asset Registry
- **Stage Platform**: `ReplicatedStorage.ArtAssets.Stage.StagePlatform` (Mesh)
- **Speaker Towers**: `ReplicatedStorage.ArtAssets.Stage.Speaker` (Mesh)
- **Classic Drum Kit**: Asset ID `rbxassetid://33866728` (Audited Model)
- **Guitar Amplifiers**: Asset IDs `rbxassetid://102586922975375` & `rbxassetid://77407520836149` (Audited Models)
- **Concert Spotlights**: Asset ID `rbxassetid://4568232546` (Audited Model)
- **Overhead Trusses**: Asset ID `rbxassetid://9336505787` (Audited Model)
- **Lava Floor Plates**: Asset ID `rbxassetid://77944906937375` (Audited Mesh)
- **Fences / Barricades**: Asset ID `rbxassetid://7985176404` (Audited Model)
- **Stadium Seats**: Asset ID `rbxassetid://6810383674` (Audited Model)
- **Nuclear Silo Centerpiece**: Asset ID `rbxassetid://86284878579506` (Audited Model)

*Note: Visual fallback block parts are prohibited. If an asset is missing or blocked, keep it invisible with a TODO in docs.*

---

## Idempotent Archiving Rules
Do not blindly archive everything outside of `GTH_WorldV2`.
- **Preserved Roots**: Camera, Terrain, live player characters, `Unused_MapAssets` directories, and spawn locations must remain untouched.
- **Archived Targets**: Move only specific V1 visual parts (rectangular `HordeLane`, block kiosks, cylinder wheels, duplicate billboard spam, block volcanoes, raw grey parts) to `ServerStorage.WorldArchive`.
- **Visual Deactivation**: Set `Transparency = 1`, `CanCollide = false`, and disable all Billboards/Lights/Emitters inside archived structures.

---

## NPC & Vendor User Stories
Every NPC kiosk represents a physical model set under `Workspace.GTH_WorldV2.VendorRing` and faces the center stage.

1. **DJ_GroanMaster (Song Select)**
   - *User Story*: "As a player, I want to walk up to the DJ booth and press E to browse the song catalog so I can start a rhythmic defense round."
   - *Interact Node*: `Workspace.GTH_WorldV2.VendorRing.DJ_GroanMaster` (ProximityPrompt)
2. **Vendor_Store (Shop)**
   - *User Story*: "As a player, I want to approach the register and talk to the shopkeeper to buy new groan tube cosmetics and weapon skins."
   - *Interact Node*: `Workspace.GTH_WorldV2.VendorRing.Vendor_Store` (ProximityPrompt)
3. **Vendor_UpgradeEngineer (Upgrades)**
   - *User Story*: "As a player, I want to access the upgrade terminal to enhance my fence health and speaker blast power."
   - *Interact Node*: `Workspace.GTH_WorldV2.VendorRing.Vendor_UpgradeEngineer` (ProximityPrompt)
4. **Vendor_MissionOfficer (Missions)**
   - *User Story*: "As a player, I want to inspect the bulletin board to track my active daily quests and claim rewards."
   - *Interact Node*: `Workspace.GTH_WorldV2.VendorRing.MissionOfficer` (ProximityPrompt)
5. **SecurityManager (Sectors)**
   - *User Story*: "As a player, I want to talk to the security guard to check the safety status of each sector fence."
   - *Interact Node*: `Workspace.GTH_WorldV2.VendorRing.SecurityManager` (ProximityPrompt)
6. **TutorialGuide (Help)**
   - *User Story*: "As a new player, I want to talk to the guide near the spawn point to get a quick visual tutorial on arrow-only key inputs."
   - *Interact Node*: `Workspace.GTH_WorldV2.VendorRing.TutorialGuide` (ProximityPrompt)

---

## Centralized UI/UX Menu Controller
All menu panels must be bound to a centralized client-side controller: `StarterPlayer.StarterPlayerScripts.UIUXMenuController.client.lua`.

### UI UX Stack Rules
- **Game Modes**: Supports `lobby`, `songSelect`, `playing`, `results`, and `spectating`.
- **Modal Limit**: Only one major modal can be open at a time (e.g. opening Store automatically closes Song Select).
- **Navigation Controls**: The `NavigationMenu` must always reappear in the lobby when no other modal is active.
- **Escape Key**: Pressing `ESC` on desktop closes the top modal.
- **Responsive Layouts**: Modals must scale using `UIScale` and fit landscape viewports for mobile (iPhone `844x390`) and tablet (iPad `1024x768`) without clipping title bars or hiding close (`X`) or back buttons.
