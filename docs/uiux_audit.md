# UI/UX Interface Audit & Device Acceptance Matrix

Date: 2026-05-25

Skill contract used: `gth-uiux-responsive-menu-audit` (repo skill file not present; performed exact audit directly from repo UI files and validation module).

## Interface inventory and triggers

| Menu | Open trigger | Close trigger | Back trigger | Reopen path | Status |
| --- | --- | --- | --- | --- | --- |
| `NavigationMenu` | lobby restore / spawn | song start hides | N/A | `restoreLobbyState()` | wired |
| `SongSelect` | Navigation button, `OpenSongSelect`, DJ prompt `MenuName=SongSelect` | X / `closeMenu` / Escape | `back()` | nav or DJ prompt | wired |
| `Store` | Navigation button, `Vendor_Store`, `OpenMenu` | X / `closeMenu` / Escape | `back()` | nav or store prompt | wired through `StoreGui` attributes |
| `Upgrades` | Navigation button, `Vendor_UpgradeEngineer`, `OpenMenu` | X / `closeMenu` / Escape | `back()` | nav or upgrade prompt | wired through `StoreGui` tab/attributes |
| `Missions` | Navigation button, `MissionOfficer`, `OpenMenu` | X / `closeMenu` / Escape | `back()` | nav or mission prompt | wired through `StoreGui` tab/attributes |
| `Security` | `SecurityManager`, `OpenMenu` | X / `closeMenu` / Escape | `back()` | security prompt | wired through `StoreGui` tab/attributes |
| `Tutorial` | `TutorialGuide`, `OpenMenu` | X / `closeMenu` / Escape | `back()` | tutorial prompt | wired through `StoreGui` tab/attributes |
| `Hype` | `AudienceHypeManager`, `OpenMenu` | X / `closeMenu` / Escape | `back()` | hype prompt | wired through `AudienceGui` attribute |
| `Results` | `openResults(resultData)` / results mode | Continue / BackToLobby / close | N/A | song finish or controller | wired in validation expectations |
| `Rhythm HUD` | `setGameMode("playing")` / song start | song finish/results/lobby restore | N/A | valid song start | wired |
| Mobile/touch lanes | Rhythm HUD active | song end | N/A | song start | arrow-only lane policy scanned |

## Controller API

`StarterPlayer/StarterPlayerScripts/UIUXMenuController.client.lua` exposes:

- `openMenu(menuName)`
- `closeMenu(menuName)`
- `closeTopMenu()`
- `closeAllMenus()`
- `back()`
- `isMenuOpen(menuName)`
- `setGameMode(mode)`
- `showNavigation()`
- `hideNavigation()`
- `openResults(resultData)`
- `restoreLobbyState()`

It listens for `OpenSongSelect` and `OpenMenu`, and maps ProximityPrompt station names to central menu paths.

## Menu option outcome inventory

The detailed menu option inventory and implementation gap table for the Creator/menu expansion work is captured in `docs/menu_option_inventory_gap_table.md`. It maps each menu option to its current code path, target user story, target visible world/gameplay effect, asset need, validation hook, and downstream gap.

## Device matrix

| Device | Viewport | Validation source | Result |
| --- | ---: | --- | --- |
| Desktop | 1920x1080 | `UIUXValidation.lua` viewport table/static bounds checks | wired; Studio runtime blocked by missing `ReplicatedStorage.Shared` sync |
| Laptop | 1366x768 | `UIUXValidation.lua` viewport table/static bounds checks | wired; Studio runtime blocked by missing `ReplicatedStorage.Shared` sync |
| iPad landscape | 1024x768 | `UIUXValidation.lua` viewport table/static bounds checks | wired; Studio runtime blocked by missing `ReplicatedStorage.Shared` sync |
| iPhone landscape | 844x390 | `UIUXValidation.lua` viewport table/static bounds checks | wired; Studio runtime blocked by missing `ReplicatedStorage.Shared` sync |
| Small phone landscape | 667x375 | `UIUXValidation.lua` viewport table/static bounds checks | wired; Studio runtime blocked by missing `ReplicatedStorage.Shared` sync |

## Assertions covered by `UIUXValidation.lua`

- NavigationMenu visible in lobby.
- SongSelect exists, opens/closes/reopens, has close/back.
- Results exists and has Continue, Choose Another Song, Back to Lobby path.
- Controller API exists.
- Only one major modal open at a time.
- Opening Results closes SongSelect.
- `closeTopMenu()` and `back()` close top modal.
- `restoreLobbyState()` returns NavigationMenu.
- Vendor prompt paths exist for all required stations.
- Close buttons stay inside viewport bounds for configured devices.
- Rhythm highway fits configured viewports.

## Current blocker

Active Studio MCP tree lacks `StarterGui` and `ReplicatedStorage.Shared` source modules, so UIUXValidation cannot be executed inside Studio until project sync. Repo validation code is present and static checks pass.
