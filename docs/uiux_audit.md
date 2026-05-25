# UI/UX Interface Audit & Device Acceptance Matrix

This document audits all active ScreenGuis, menu interactions, and modal transitions to ensure players never experience interface clipping, overlap, notch obstruction, or menu lockouts.

---

## 1. Interface Inventory & Navigation Triggers

| ScreenGui Name | Target Modal / Panel | Open Trigger | Close Trigger | Back Path | Reopen Path | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `RhythmHUD` | Gameplay arrows / lanes | Song starts | Song ends / aborts | N/A | Song select modal | **Fixed** |
| `NavigationMenu` | Side navigation bar | Spawn in Lobby | Song starts | N/A | Closing any active modal | **Fixed** |
| `SongSelect` | Playable track list | DJ Prompt / Nav Menu | Click "X" button | Back to Nav Menu | DJ Prompt / Nav Menu | **Fixed** |
| `StoreGui` | Cosmetic tube shop | Store Prompt / Nav Menu | Click "X" / ESC | Back to Nav Menu | Store Prompt / Nav Menu | **Fixed** |
| `UpgradeGui` | Stat upgrades workbench | Upgrade Prompt / Nav Menu| Click "X" / ESC | Back to Menu | Upgrade Prompt / Nav Menu| **Fixed** |
| `MissionGui` | Challenge listings | Board Prompt / Nav Menu | Click "X" / ESC | Back to Menu | Board Prompt / Nav Menu | **Fixed** |
| `SecurityGui` | 8-sector status panel | Security Prompt / Nav Menu| Click "X" / ESC | Back to Menu | Security Prompt / Nav Menu| **Fixed** |
| `TutorialGui` | Help screens | Guide Prompt / Nav Menu | Click "X" / ESC | Back to Menu | Guide Prompt / Nav Menu | **Fixed** |
| `ResultsGui` | Performance scoreboard | Song finishes / fails | Click "Continue" | N/A | Start new song session | **Fixed** |

---

## 2. Menu Stack & Focus Control Rules
To prevent overlapping overlays ("word soup" or stuck modal states), the client-side `UIUXMenuController` enforces:
1.  **Single Modal Focus**: Opening any major modal (e.g. `StoreGui`) automatically calls `closeMenu()` on all other active modals (`SongSelect`, `UpgradeGui`, etc.).
2.  **Navigation Restoration**: Closing the active modal via the "X" button or `ESC` key must always restore `NavigationMenu.Enabled = true` to prevent lobby deadlock.
3.  **Active Song Lockout**: All non-gameplay modals (`StoreGui`, `UpgradeGui`, etc.) are hidden during active note play to keep arrow targets completely unobstructed.

---

## 3. Viewport Responsive Design Matrix

### Desktop / Laptop (1920x1080 & 1366x768)
- **Aesthetic**: Center-locked cards with drop shadows; NavigationMenu docked on the side without blocking screen center.
- **Controls**: `ESC` key triggers `closeTopMenu()`; arrow keys (`← ↓ ↑ →`) route to note lanes; mouse clicks allowed on UI buttons.
- **Clipping Risk**: None. Absolute bounds fall within safe margins.

### iPad Landscape (1024x768)
- **Aesthetic**: Modals scaled using `UIScale` to occupy no more than 82% of width and 86% of height.
- **Controls**: Tappable touch targets spaced away from boundaries; ScrollingFrames enabled for content lists.
- **Clipping Risk**: Pinned X close buttons remain visible at the top-right corner.

### iPhone Landscape (844x390 & 667x375)
- **Aesthetic**: Compact top/bottom bar layouts; modal panels occupy up to 94% width and 88% height.
- **Controls**: Tappable hit targets on touch lanes scaled to a minimum size of `44x44` pixels.
- **Clipping Risk**: Buttons and text shifted inward to avoid clipping behind phone notches or the iOS home indicator bar.
