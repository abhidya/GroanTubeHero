# GroanTubeHero Themed Room Dreamboard

Date: 2026-06-04

This is a design dreamboard only. No Creator Store asset IDs are claimed or
palette-committed here. Each room is written as an asset-search-ready concept
with multiplayer session behavior, difficulty scaling, rewards, skins, boosts,
bonuses, and helper NPC hooks.

2026-06-04 implementation note: the first eleven rooms in this document now have
source-side multiplayer room configs and structural `ThemedRoomSpaces` anchors.
Those spaces are playable scaffolds for queues/session launches and
player-height review, not final room art. Final dressing still requires
asset-search MCP curation, publish-permission review, Studio inspection, and
player-height screenshot signoff.

## Multiplayer Room Rules

- Session size: default 1 to 4 players, with room-specific caps only when the
  objective needs more bodies.
- Queue behavior: lobby portal, join/leave prompt, fill countdown, level gate,
  difficulty vote, and return-to-lobby teleport.
- Team behavior: room sessions own their participants and rewards; no global team
  state should leak between rooms.
- Difficulty ladder: Chill, Standard, Sweaty, Extreme, Brainrot.
- Reward ladder: first clear badge, difficulty badge, room currency bonus,
  themed skin unlock, helper NPC perk, and rare title for Brainrot clears.
- Boost policy: boosts should accelerate score, combo recovery, or utility. They
  should not make older rooms obsolete or feel pay-to-win.
- Asset-search slots per room: room shell, portal, setpiece anchor, helper NPC,
  hazard or objective prop, small prop pack, ambience, reward/cosmetic prop.

## Launch Expansion Shortlist

These are the strongest room concepts to prioritize after the current Brainrot
Volcano Horde Rave room.

| Room | Difficulty | Multiplayer hook | Rewards | Helper NPC | Search slots |
| --- | --- | --- | --- | --- | --- |
| Cyber Arcade Overclock | Level 3, Standard to Extreme | Players split between cabinet defense, battery carry, and combo terminal repairs. | Pixel Hoodie skin, Overclock Combo boost, Arcade Ace title. | Glitch Janitor clears corrupted tiles and resets one failed terminal. | arcade room, arcade cabinet, neon portal, repair terminal, pixel signage |
| Subway Meme Tunnel | Level 5, Standard to Brainrot | Hold platforms while waves arrive from track lanes; teammates rotate signal switches. | Metro Jacket skin, Rush Hour coin bonus, Platform Legend badge. | Signal Captain warns which lane surges next. | subway platform, train shell, ticket kiosk, tunnel signage, signal light |
| Haunted Karaoke Theater | Level 7, Sweaty to Brainrot | One player performs callouts while others protect stage speakers and curtain levers. | Phantom Mic skin, Echo Shield boost, Midnight Encore badge. | Curtain Stagehand repairs speaker stacks and marks hidden hazards. | theater stage, curtain, ghost host, microphone stand, spooky lighting |
| Aquarium Bass Drop | Level 9, Chill to Extreme | Team keeps bubble generators alive while rhythm zones flood and drain. | Bubble Visor skin, Oxygen Combo boost, Deep Bass badge. | Bubble Tech restores safe zones and highlights failing pumps. | aquarium tunnel, fish props, glass wall, pump console, underwater ambience |
| Moonbase Echo Dome | Level 12, Sweaty to Brainrot | Low-gravity note lanes and shared oxygen relays; players must sync pressure doors. | Lunar Helmet skin, Gravity Skip boost, Orbit Crew title. | Orbit Mechanic stabilizes one oxygen relay each wave. | moonbase room, sci-fi dome, airlock portal, oxygen tank, rover prop |
| Neon Food Court Freestyle | Level 14, Standard to Extreme | Players defend order counters and deliver beat tokens under crowd pressure. | Neon Apron skin, Combo Meal bonus, Food Court Flex badge. | Snack Producer converts perfect streaks into temporary shields. | mall food court, counter props, neon sign pack, tray props, vendor NPC |
| Junkyard Auto-Tune Pit | Level 16, Sweaty to Brainrot | Scrap lanes spawn hazards; players rebuild broken speakers from collected parts. | Chrome Jacket skin, Scrap Shield boost, Auto-Tune Survivor badge. | Scrap Mechanic repairs one barricade and upgrades speaker durability. | junkyard, scrap pile, garage stage, broken speaker, repair robot |
| Pirate Radio Shipyard | Level 18, Standard to Brainrot | Crew controls broadcast towers while moving across docks and cargo stacks. | Broadcaster Coat skin, Signal Boost bonus, Shipyard DJ title. | Radio Engineer boosts tower range and reveals jammed channels. | dockyard, cargo crates, radio tower, ship deck, storm lights |
| Cloudback Idol Arena | Level 20, Chill to Extreme | Floating platforms drift; players vote rotating chorus lanes and protect idol plinths. | Cloud Cape skin, Idol Streak boost, Sky Stage badge. | Chorus Coach locks one platform in place during a surge. | floating arena, cloud platform, idol stage, golden mic, sky portal |
| Doomscroll Data Center | Level 22, Sweaty to Brainrot | Players cool server racks and purge viral panels before heat overloads the room. | Firewall Hoodie skin, Cache Burst boost, Data Detox badge. | Firewall Admin freezes one overloaded server rack. | data center, server rack, cable floor, terminal wall, warning lights |
| Backrooms Boiler Rave | Level 24, Extreme to Brainrot | Maze-like pressure valves; players must regroup at safe beats or lose combo heat. | Boiler Mask skin, Pressure Release boost, Liminal Survivor title. | Valve Operator pings the nearest safe valve route. | yellow hallway, boiler room, pipe pack, valve prop, flickering light |
| Ancient Meme Temple | Level 26, Sweaty to Brainrot | Teams activate relic drums in sequence while traps scramble note lanes. | Relic Crown skin, Rune Combo bonus, Temple Roaster badge. | Relic Keeper reveals the next safe activation order. | temple room, stone altar, relic props, torch lighting, rune portal |

## Full Room Dreamboard

| Room | Core fantasy | Main objective | Signature hazard | Award and cosmetic | Helper NPC |
| --- | --- | --- | --- | --- | --- |
| Brainrot Volcano Horde Rave | Existing Room 1, lava-stage chaos and horde pressure. | Defend stage sectors and survive escalating beat waves. | Lava surges and crowd pressure spikes. | Molten Mic badge, Lava Shades skin. | Security Manager, Audience Hype Manager, DJ GroanMaster. |
| Cyber Arcade Overclock | A neon arcade that keeps crashing mid-song. | Repair cabinets and keep combo terminals online. | Corrupted floor tiles scramble note lanes. | Pixel Hoodie, Arcade Ace title. | Glitch Janitor. |
| Subway Meme Tunnel | Underground platform rave with incoming rush waves. | Hold signal posts and rotate platform defense. | Track-lane surge warnings. | Metro Jacket, Platform Legend badge. | Signal Captain. |
| Haunted Karaoke Theater | Stage fright becomes a room mechanic. | Protect speakers while hitting call-and-response prompts. | Curtains slam shut and cut sight lines. | Phantom Mic, Midnight Encore badge. | Curtain Stagehand. |
| Aquarium Bass Drop | Underwater club with rising rhythm floods. | Maintain bubble generators and bass pumps. | Flooded lanes slow movement and dampen score gain. | Bubble Visor, Deep Bass badge. | Bubble Tech. |
| Moonbase Echo Dome | Low-gravity stage inside a lunar performance dome. | Sync oxygen relays and defend airlock controls. | Gravity pulses launch players off ideal routes. | Lunar Helmet, Orbit Crew title. | Orbit Mechanic. |
| Neon Food Court Freestyle | Mall counter chaos turned into a rhythm battle. | Deliver beat tokens between counters. | Spill zones and order-rush timers. | Neon Apron, Combo Meal bonus. | Snack Producer. |
| Junkyard Auto-Tune Pit | Scrap-metal concert floor with rebuildable speakers. | Gather parts and repair broken sound towers. | Magnet storms pull scrap across lanes. | Chrome Jacket, Scrap Shield boost. | Scrap Mechanic. |
| Pirate Radio Shipyard | Illegal broadcast party across docks and towers. | Keep antennas powered and avoid jam zones. | Signal jammers and dock fog. | Broadcaster Coat, Shipyard DJ title. | Radio Engineer. |
| Cloudback Idol Arena | Floating pop arena with platform choreography. | Keep idol plinths active while platforms move. | Cloud drift separates teammates. | Cloud Cape, Sky Stage badge. | Chorus Coach. |
| Doomscroll Data Center | Server-room panic where brainrot is literal overload. | Cool racks and purge viral panels. | Heat overload locks room quadrants. | Firewall Hoodie, Data Detox badge. | Firewall Admin. |
| Backrooms Boiler Rave | Liminal hallway maze with boiler pressure beats. | Turn valves in order and regroup at safe beats. | Wrong turns build pressure and spawn extra waves. | Boiler Mask, Liminal Survivor title. | Valve Operator. |
| Ancient Meme Temple | Relic trial built around sequence memory. | Activate relic drums in the shown order. | Trap tiles invert controls or dim the room. | Relic Crown, Temple Roaster badge. | Relic Keeper. |
| Desert Mirage Festival | Heat-haze festival where fake pickups bait players. | Find real oasis speakers and power the stage. | Mirage decoys waste interaction time. | Mirage Visor, Oasis Encore badge. | Shade Vendor. |
| Ice Cream Tundra Rave | Frozen dessert plaza with slippery rhythm lanes. | Melt frozen speakers without overheating them. | Ice slides and sudden freeze bursts. | Sprinkle Parka, Frost Combo boost. | Chill Technician. |
| Library Shushcore Arena | Quiet-mode arena where loud mistakes wake penalties. | Hit silent-beat prompts and shelve lyric fragments. | Noise meter punishes missed streaks. | Quiet Crown, Shushcore Scholar title. | Librarian of Vibes. |
| Toybox Chaos Room | Oversized toy-stage with switchable lanes. | Build a giant combo tower from collected blocks. | Falling blocks reshape the path. | Block Party Backpack, Tower Streak boost. | Toy Engineer. |
| Carnival Clowncore Stage | Neon fairground performance with rotating booths. | Win booth mini-objectives to charge the main stage. | Spinning platforms and misdirection signs. | Carnival Jacket, Midway Master badge. | Booth Barker. |
| Storm Chaser Rooftop | Rooftop stage during a lightning show. | Ground lightning rods and keep speakers powered. | Lightning zones and wind gust knockback. | Storm Coat, Thunder Combo bonus. | Rooftop Rigger. |
| Mirror Mall of Fame | Reflective mall where decoy lanes copy player moves. | Identify real prompts among mirror duplicates. | Fake note paths drain combo if followed. | Mirror Shades, Fame Loop title. | Reflection Stylist. |
| Clocktower Loop Lab | Time-loop arena with rewinding objectives. | Lock gears before the room resets. | Time rewind returns props and hazards to prior states. | Gear Cloak, Loop Breaker badge. | Clocksmith. |
| Crystal Cave Bass Mine | Underground stage with resonant crystals. | Tune crystals to amplify the chorus. | Wrong resonance causes area bursts. | Crystal Mic, Resonance Boost. | Cave Tuner. |
| Airport Delay Disco | Terminal party trapped in endless boarding calls. | Route players through gates and clear baggage jams. | Wrong gate sends players back to checkpoint. | Boarding Pass Badge, Delay-Proof Jacket. | Gate Producer. |
| Cosmic Laundromat | Spinning washer portals and clean-combo chaos. | Load beat tokens into correct machines. | Spin cycles rotate room exits and hazards. | Fresh Fit skin, Spin Cycle boost. | Washroom DJ. |
| Courtroom Roast Battle | Judge-stage where verdicts become rhythm modifiers. | Present evidence prompts and survive roast waves. | Bad objections stun a lane. | Verdict Robe, Roast Counsel title. | Beat Bailiff. |
| Museum of Viral Relics | Exhibit hall of fake-famous artifacts. | Protect relic displays and tag counterfeit props. | Cursed exhibits swap objectives. | Curator Jacket, Relic Hunter badge. | Exhibit Curator. |
| Spaceport Security Check | Sci-fi checkpoint with scanning rhythm gates. | Clear contraband props before launch countdown. | Scanner beams freeze players in place. | Spaceport Vest, Launch Ready badge. | Checkpoint Officer. |
| Builder Yard Beatdown | Construction-yard stage with moving lifts. | Assemble speaker scaffolds while avoiding work zones. | Crane shadows telegraph falling hazards. | Hardhat Skin, Scaffold Streak boost. | Build Foreman. |
| Candy Factory Clout Drop | Bright factory where sweets become timing hazards. | Package combo crates and keep conveyor lanes clean. | Sticky floor patches slow rotations. | Sugar Rush Jacket, Conveyor Champ badge. | Factory Mixer. |
| Rooftop Newsroom Rave | Broadcast studio on a skyline roof. | Keep cameras live and feed headline prompts. | Breaking-news flashes change objectives. | Anchor Blazer, Prime Time title. | Camera Producer. |
| Snowglobe Static Stage | Shaken-globe room with visibility bursts. | Stabilize globe generators and clear static zones. | Snow bursts hide path markers. | Globe Goggles, Static Clear boost. | Globe Keeper. |
| Laser Tag Lair | Arena lanes double as rhythm paths. | Capture laser towers and defend team color zones. | Laser sweeps force timed dodges. | Laser Vest, Zone Capture badge. | Arena Referee. |
| Detention Detour Stage | After-hours school stage with rule-breaking bonuses. | Pass notes between desks to charge the chorus. | Bell rings reset active desks. | Detention Hoodie, Hall Pass bonus. | Hall Monitor DJ. |

## Reward And Boost Patterns

Use these as repeatable room reward templates:

- First Clear: room badge plus 250 to 500 Coins.
- Difficulty Clear: title, trail, or emote tied to the room.
- Brainrot Clear: rare room skin plus a weekly leaderboard multiplier.
- Team Bonus: all present players get a shared bonus if no one disconnects or
  abandons during the final phase.
- Helper Bond: repeated clears level up that room helper NPC and unlock a minor
  utility perk in the room only.
- Cosmetic Set: head item, jacket, aura/trail, and room-themed victory pose.

Boost ideas:

- Combo Buffer: protects one missed note per phase.
- Heat Vent: reduces horde pressure or hazard intensity.
- Coin Echo: duplicates a small part of team-earned room currency.
- Revival Beat: revives a downed teammate if the team lands a shared streak.
- Portal Priority: shortens queue fill timer when friends are grouped.
- Helper Call: lets the room helper trigger once earlier than normal.

## Brainrot Helper NPC Roster

These NPCs should be room-scoped helpers, not global always-on advantages.

| Helper NPC | Role | Best rooms |
| --- | --- | --- |
| Queue Captain | Speeds up ready checks and fills solo players into open rooms. | Lobby, all rooms |
| Skin Tailor | Lets players preview and equip room cosmetics. | Lobby, fashion-heavy rooms |
| Boost Clerk | Sells temporary room-safe boosts and shows cooldowns. | Lobby, all rooms |
| Glitch Janitor | Clears corrupted tiles and restores one terminal. | Cyber Arcade, Data Center |
| Signal Captain | Calls out incoming lane danger. | Subway, Shipyard, Airport |
| Curtain Stagehand | Repairs speakers and opens blocked sight lines. | Theater, Idol Arena |
| Bubble Tech | Restores safe zones and bubble generators. | Aquarium |
| Orbit Mechanic | Stabilizes low-gravity relays. | Moonbase, Spaceport |
| Snack Producer | Turns streaks into brief shields. | Food Court, Candy Factory |
| Scrap Mechanic | Rebuilds barricades and speaker towers. | Junkyard, Builder Yard |
| Firewall Admin | Freezes overloads and purges viral panels. | Data Center |
| Valve Operator | Reveals safe valve paths under pressure. | Boiler Rave |
| Relic Keeper | Shows sequence memory hints. | Temple, Museum |
| Clocksmith | Slows or cancels one room rewind. | Clocktower |
| Beat Bailiff | Blocks one bad objection penalty. | Courtroom |

## Next Asset-Search Pass

For the next curation pass, prioritize a vertical slice rather than searching
all rooms at once:

1. Cyber Arcade Overclock
2. Subway Meme Tunnel
3. Haunted Karaoke Theater
4. Aquarium Bass Drop
5. Doomscroll Data Center

Recommended slot queries:

- Cyber Arcade Overclock: `Roblox arcade room neon arcade machines game room`,
  `arcade machine neon game cabinet Roblox`, `neon portal arch sci fi doorway Roblox`.
- Subway Meme Tunnel: `Roblox subway station platform train tunnel`,
  `subway train platform ticket kiosk Roblox`, `rail signal light Roblox`.
- Haunted Karaoke Theater: `theater stage curtain Roblox`,
  `haunted theater stage Roblox`, `ghost host NPC Roblox`, `microphone stand Roblox`.
- Aquarium Bass Drop: `aquarium tunnel underwater fish Roblox`,
  `fish pack Roblox`, `glass tunnel aquarium Roblox`, `bubble generator Roblox`.
- Doomscroll Data Center: `server rack data center Roblox`,
  `computer terminal room Roblox`, `neon warning light Roblox`, `cable floor Roblox`.
