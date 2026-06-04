Runtime owner: `StarterPlayer/StarterPlayerScripts/RhythmClient.client.lua`.

The static `StarterGui.RhythmGui` folder is only a sync anchor. The runtime
client builds `RhythmGui`, `SongSelectModal`, `ResultsFrame`, the note highway,
and the lobby navigation menu in `PlayerGui`.

Open/close contract:
- `OpenSongSelect` remote and the DJ mic route through `UIUXMenuController.openMenu("SongSelect")`.
- Results, replay, lobby, store, mission, upgrade, and hype buttons route through
  `UIUXMenuController` when available.
- `SongActive` and `AcceptInput` attributes gate lane input and external UI.

Validation:
- `ReplicatedStorage/Shared/WorldV2/UIUXValidation.lua`
- `ReplicatedStorage/Shared/UnitTests.lua`
