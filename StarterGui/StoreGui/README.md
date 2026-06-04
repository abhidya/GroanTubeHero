Runtime owner: `StarterPlayer/StarterPlayerScripts/StoreClient.client.lua`.

The runtime `StoreGui` contains Store, Upgrades, Missions, Security, Tutorial,
and Tour Bus tabs. `UIUXMenuController` opens it by setting `Tab`,
`FocusMessage`, and `Open` attributes on the player `StoreGui`.

Close contract:
- `CloseRequested` hides the panel.
- `LastOutcome` records the latest visible result text for validation.

Validation:
- `ReplicatedStorage/Shared/WorldV2/UIUXValidation.lua`
- `ReplicatedStorage/Shared/UnitTests.lua`
