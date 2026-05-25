# Roblox Studio Asset Manifest - Groan Tube Hero

This manifest inventories all visual assets discovered in the live Roblox Studio place file under `Workspace.Unused_MapAssets`, `Workspace.Stage`, and `Workspace.TourBus`.

---

## 1. Unactivated Package: `Workspace.Unused_MapAssets.OPEN ME! (READ THE READ ME)`

These assets are currently imported in the place file but are inactive. They must be programmatically moved (ungrouped) on server startup to their respective Roblox services.

| Instance Path | Class Name | Destination Service | Status / Notes |
| :--- | :--- | :--- | :--- |
| `OPEN ME! (READ THE READ ME).Ungroup in MaterialService.Universal` | `MaterialVariant` | `game.MaterialService` | **Used** (Sets floor material textures) |
| `OPEN ME! (READ THE READ ME).Ungroup in MaterialService.Studs` | `MaterialVariant` | `game.MaterialService` | **Used** (Sets walkway texture) |
| `OPEN ME! (READ THE READ ME).Ungroup in MaterialService.Inlet` | `MaterialVariant` | `game.MaterialService` | **Used** (Sets path texture) |
| `OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...Atmosphere` | `Atmosphere` | `game.Lighting` | **Used** (Creates green/orange toxic haze) |
| `OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...DarkSky` | `Sky` | `game.Lighting` | **Used** (Replaces daytime skybox with volcanic sky) |
| `OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...Bloom` | `BloomEffect` | `game.Lighting` | **Used** (Increases glow bloom for neons) |
| `OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...Blur` | `BlurEffect` | `game.Lighting` | **Used** (Depth blur) |
| `OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...ColorCorrection` | `ColorCorrectionEffect` | `game.Lighting` | **Used** (Toxic tint correction) |
| `OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...DepthOfField` | `DepthOfFieldEffect` | `game.Lighting` | **Used** (Cinematic focus) |
| `OPEN ME! (READ THE READ ME).(DELETE YOUR OLD LIGHTING...).This is the new lighting...SunRays` | `SunRaysEffect` | `game.Lighting` | **Used** (Dynamic solar rays) |
| `OPEN ME! (READ THE READ ME).Ungroup in ReplicatedStorage.Waves` | `Folder` | `game.ReplicatedStorage` | **Used** (Custom sound wave/effects resources) |
| `OPEN ME! (READ THE READ ME).Ungroup in ReplicatedStorage.Remotes` | `Folder` | `game.ReplicatedStorage` | **Ignored** (We preserve existing remotes) |
| `OPEN ME! (READ THE READ ME).Ungroup in workspace` | `Folder` | `game.Workspace` | **Ignored** (Empty folder) |
| `OPEN ME! (READ THE READ ME).ungroup in starterpack` | `Folder` | `game.StarterPack` | **Ignored** (Empty folder) |
| `OPEN ME! (READ THE READ ME).ungroup in ServerScriptService` | `Folder` | `game.ServerScriptService` | **Ignored** (Empty folder) |
| `OPEN ME! (READ THE READ ME).ungroup in startergui` | `Folder` | `game.StarterGui` | **Ignored** (Empty folder) |

---

## 2. Active Stage Components: `Workspace.Stage`

These assets compose the performance arena. Some are custom models, others are procedural parts that must have their positions corrected dynamically.

| Instance Path | Class Name | Destination Service | Status / Notes |
| :--- | :--- | :--- | :--- |
| `Workspace.Stage.StagePlatform` | `Model` | `Workspace.Stage` | **Used** (Primary stage mesh containing 25 meshparts/sub-models) |
| `Workspace.Stage.SpeakerStacks` | `Folder` | `Workspace.Stage` | **Used** (Contains `SpeakerStack1` and `SpeakerStack2` thumping models) |
| `Workspace.Stage.StoreKiosk` | `Model` | `Workspace.Stage` | **Used** (Register kiosk model with cash register meshes) |
| `Workspace.Stage.MicrophoneStand` | `Model` | `Workspace.Stage` | **Used** (Mic stand model with metallic meshes) |
| `Workspace.Stage.StartPrompt` | `Part` | `Workspace.Stage` | **Used** (Interactive song-selector neon pad) |
| `Workspace.Stage.SingerSpot` | `Part` | `Workspace.Stage` | **Used** (Neon pad showing singer spot) |
| `Workspace.Stage.AudienceZone` | `Part` | `Workspace.Stage` | **Used** (Forcefield part enclosing crowd zone) |
| `Workspace.Stage.MissionBoard` | `Part` | `Workspace.Stage` | **Used** (Board to click for missions UI) |
| `Workspace.Stage.UpgradeKiosk` | `Part` | `Workspace.Stage` | **Used** (Kiosk to click for upgrades UI) |
| `Workspace.Stage.LED panel` | `Part` | `Workspace.Stage` | **Used** (Equalizer wall display panel behind stage) |
| `Workspace.Stage.BrainrotBackdrop` | `Folder` | `Workspace.Stage` | **Used** (Contains 14 Volcano rock meshes and lava mouth parts) |
| `Workspace.Stage.Spotlights` | `Folder` | `Workspace.Stage` | **Used** (Contains 8 light poles `GTH_LightPole_1` to `8` with spotlights) |
| `Workspace.Stage.CleanSigns` | `Folder` | `Workspace.Stage` | **Used** (Contains 7 signage parts with SurfaceGuis) |

---

## 3. Brainrot Horde Templates: `Workspace.Unused_MapAssets`

These 98 custom imported mesh models are templates used at runtime to spawn the advancing horde.

*   **Total Character Models**: 98 unique templates.
*   **Key Templates**:
    *   `Sammyni_Spyderini` (Spider model with rig/joints)
    *   `Unclito_Samito` (Noob-like character mesh)
    *   `Orangutini Ananassini` (Orangutan mesh)
    *   `La_Vacca_Saturno_Saturnita` (Cow model)
    *   `Cavallo_Virtuoso` (Horse model)
    *   `Trippi_Troppi` (Trippy character mesh)
    *   `Sigma Boy` (Boy model)
    *   `Trenostruzzo_Turbo_3000` (Train/Ostrich mesh)
    *   `Boneca Ambalabu` (Doll model)
    *   `Bananita Dolphinita` (Banana-dolphin mesh)
    *   `Noobini Pizzanini` (Pizza noob mesh)
    *   `Burbaloni Loliloli` (Bubble character mesh)
    *   `Gattatino Neonino` (Neon cat mesh)
    *   `Tim Cheese` (Mouse mesh)
    *   `Tukanno Bananno` (Toucan mesh)

---

## 4. Tour Bus Components: `Workspace.TourBus`

| Instance Path | Class Name | Destination Service | Status / Notes |
| :--- | :--- | :--- | :--- |
| `Workspace.TourBus.BusBody` | `Model` | `Workspace.TourBus` | **Used** (Concert tour bus body model) |
| `Workspace.TourBus.Wheel1` to `Wheel4` | `Part` | `Workspace.TourBus` | **Used** (Cylinder wheel parts) |

---

## 5. Summary statistics
*   **Total active stage models/parts**: 19
*   **Total unactivated package assets in "OPEN ME!"**: 14
*   **Total brainrot horde templates**: 98
*   **Total descendants across all map assets**: 8,710
