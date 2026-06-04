Runtime owner: `StarterPlayer/StarterPlayerScripts/AudienceClient.client.lua`.

The runtime `AudienceGui` opens when the player is inside the audience hitbox or
when `UIUXMenuController.openMenu("Hype")` sets the `Open` attribute.

Gameplay contract:
- Audience actions call the `AudienceAction` remote.
- `Support` and `Encore` now feed explicit horde sector relief back through
  `HordeUpdate.audienceAssist`.

Validation:
- `ReplicatedStorage/Shared/WorldV2/UIUXValidation.lua`
- `ReplicatedStorage/Shared/UnitTests.lua`
