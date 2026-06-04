local RoomConfig = {}

RoomConfig.DefaultRoomId = "brainrot_volcano_horde_rave"

RoomConfig.Session = {
    LaunchLookAt = Vector3.new(0, 3.5, 0),
    ReturnLookAt = Vector3.new(0, 4, -94),
    LaunchPads = {
        Vector3.new(-9, 5.5, -8),
        Vector3.new(9, 5.5, -8),
        Vector3.new(-14, 5.5, 2),
        Vector3.new(14, 5.5, 2),
        Vector3.new(-8, 5.5, 12),
        Vector3.new(8, 5.5, 12),
    },
    ReturnPads = {
        Vector3.new(-10, 5.5, -82),
        Vector3.new(10, 5.5, -82),
        Vector3.new(-24, 5.5, -82),
        Vector3.new(24, 5.5, -82),
        Vector3.new(-34, 5.5, -100),
        Vector3.new(34, 5.5, -100),
    },
}

RoomConfig.RoomSpaces = {
    brainrot_volcano_horde_rave = {
        Center = Vector3.new(0, 3.5, 0),
        Size = Vector3.new(96, 24, 96),
        Entry = Vector3.new(0, 5.5, -42),
        LookAt = Vector3.new(0, 3.5, 0),
    },
    cyber_arcade_overclock = {
        Center = Vector3.new(260, 3.5, 0),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(260, 5.5, -36),
        LookAt = Vector3.new(260, 3.5, 0),
    },
    subway_meme_tunnel = {
        Center = Vector3.new(380, 3.5, 0),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(380, 5.5, -36),
        LookAt = Vector3.new(380, 3.5, 0),
    },
    haunted_karaoke_theater = {
        Center = Vector3.new(-260, 3.5, 0),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(-260, 5.5, -36),
        LookAt = Vector3.new(-260, 3.5, 0),
    },
    cloudback_idol_arena = {
        Center = Vector3.new(-380, 3.5, 0),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(-380, 5.5, -36),
        LookAt = Vector3.new(-380, 3.5, 0),
    },
    aquarium_bass_drop = {
        Center = Vector3.new(0, 3.5, 260),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(0, 5.5, 224),
        LookAt = Vector3.new(0, 3.5, 260),
    },
    junkyard_autotune_pit = {
        Center = Vector3.new(260, 3.5, 260),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(260, 5.5, 224),
        LookAt = Vector3.new(260, 3.5, 260),
    },
    neon_food_court_freestyle = {
        Center = Vector3.new(-260, 3.5, 260),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(-260, 5.5, 224),
        LookAt = Vector3.new(-260, 3.5, 260),
    },
    moonbase_echo_dome = {
        Center = Vector3.new(260, 3.5, -340),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(260, 5.5, -304),
        LookAt = Vector3.new(260, 3.5, -340),
    },
    pirate_radio_shipyard = {
        Center = Vector3.new(-260, 3.5, -340),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(-260, 5.5, -304),
        LookAt = Vector3.new(-260, 3.5, -340),
    },
    doomscroll_data_center = {
        Center = Vector3.new(380, 3.5, 260),
        Size = Vector3.new(72, 22, 72),
        Entry = Vector3.new(380, 5.5, 224),
        LookAt = Vector3.new(380, 3.5, 260),
    },
}

RoomConfig.Rooms = {
    {
        Id = "brainrot_volcano_horde_rave",
        Index = 1,
        Name = "Brainrot Volcano Horde Rave",
        ShortName = "Volcano Rave",
        Theme = "lava concert defense, brainrot horde, neon rave",
        Status = "open",
        MinLevel = 1,
        MinPlayers = 1,
        Capacity = 4,
        FillSeconds = 12,
        TeamMode = "CrewDefense",
        RecommendedPlayers = "1-4",
        DifficultyOrder = { "Easy", "Hard", "Extreme", "Brainrot" },
        DefaultDifficulty = "Easy",
        RewardMultiplier = 1.20,
        Bonuses = { Fans = 10, Coins = 6, XP = 12, Tickets = 0 },
        SkinUnlocks = { "Lava Mic Wrap", "Cursed Rave Jacket", "Magma Speaker Trail" },
        Boosts = { "LavaEncore", "HordePushback", "AudienceHeat" },
        HelperNPCs = {
            { Id = "DJ_GroanMaster", Role = "host", Action = "starts songs and calls horde warnings" },
            { Id = "SecurityManager", Role = "defense", Action = "repairs weak fence sectors" },
            { Id = "AudienceHypeManager", Role = "support", Action = "turns hype into sector pushback" },
        },
        AssetSearchSlots = {
            "concert stage truss speaker lights",
            "cartoon monster npc horde",
            "volcano rock lava cliff",
            "neon signs",
        },
        ReviewSpaceId = "volcano_rave_room",
        Palette = {
            Primary = Color3.fromRGB(255, 78, 45),
            Secondary = Color3.fromRGB(255, 70, 215),
            Accent = Color3.fromRGB(100, 245, 255),
        },
    },
    {
        Id = "cyber_arcade_overclock",
        Index = 2,
        Name = "Cyber Arcade Overclock",
        ShortName = "Cyber Arcade",
        Theme = "arcade cabinets, glitch lanes, neon boss screens",
        Status = "open",
        MinLevel = 2,
        MinPlayers = 2,
        Capacity = 4,
        FillSeconds = 18,
        TeamMode = "ComboCrew",
        RecommendedPlayers = "2-4",
        DifficultyOrder = { "Easy", "Hard", "Extreme" },
        DefaultDifficulty = "Hard",
        RewardMultiplier = 1.28,
        Bonuses = { Fans = 14, Coins = 12, XP = 18, Tickets = 0 },
        SkinUnlocks = { "Pixel Visor", "Arcade Arrow Skin", "CRT Speaker Stack" },
        Boosts = { "ComboCache", "LanePreview", "CoinJackpot" },
        HelperNPCs = {
            { Id = "ArcadeTech", Role = "boost", Action = "charges combo caches after streaks" },
            { Id = "PatchBot", Role = "repair", Action = "stabilizes fakeout lanes" },
        },
        AssetSearchSlots = {
            "arcade machine neon game room",
            "neon arrow signs",
            "cyber console",
            "speaker lights",
        },
        ReviewSpaceId = "cyber_arcade_room",
        Palette = {
            Primary = Color3.fromRGB(80, 225, 255),
            Secondary = Color3.fromRGB(120, 90, 255),
            Accent = Color3.fromRGB(255, 230, 90),
        },
    },
    {
        Id = "subway_meme_tunnel",
        Index = 3,
        Name = "Subway Meme Tunnel",
        ShortName = "Subway Meme",
        Theme = "train platform, buskers, tunnel echo, meme posters",
        Status = "open",
        MinLevel = 3,
        MinPlayers = 2,
        Capacity = 4,
        FillSeconds = 18,
        TeamMode = "PlatformCrew",
        RecommendedPlayers = "2-4",
        DifficultyOrder = { "Hard", "Extreme" },
        DefaultDifficulty = "Hard",
        RewardMultiplier = 1.33,
        Bonuses = { Fans = 18, Coins = 10, XP = 22, Tickets = 1 },
        SkinUnlocks = { "Metro Jacket", "Graffiti Lane Skin", "Train Horn Groan" },
        Boosts = { "EchoTiming", "PlatformDash", "FareBonus" },
        HelperNPCs = {
            { Id = "BuskerBuddy", Role = "timing", Action = "widens one rough phrase per run" },
            { Id = "ConductorCrew", Role = "queue", Action = "keeps party members grouped" },
        },
        AssetSearchSlots = {
            "subway train station platform",
            "graffiti neon sign",
            "ticket kiosk",
            "street performer npc",
        },
        ReviewSpaceId = "subway_meme_room",
        Palette = {
            Primary = Color3.fromRGB(255, 205, 60),
            Secondary = Color3.fromRGB(60, 85, 110),
            Accent = Color3.fromRGB(255, 80, 120),
        },
    },
    {
        Id = "haunted_karaoke_theater",
        Index = 4,
        Name = "Haunted Karaoke Theater",
        ShortName = "Haunted Karaoke",
        Theme = "ghost choir, velvet stage, floating lyric cards",
        Status = "open",
        MinLevel = 4,
        MinPlayers = 2,
        Capacity = 4,
        FillSeconds = 20,
        TeamMode = "ChoirDefense",
        RecommendedPlayers = "2-4",
        DifficultyOrder = { "Hard", "Extreme", "Brainrot" },
        DefaultDifficulty = "Hard",
        RewardMultiplier = 1.38,
        Bonuses = { Fans = 20, Coins = 12, XP = 26, Tickets = 1 },
        SkinUnlocks = { "Ghost Mic", "Velvet Cape", "Spectral Spotlight" },
        Boosts = { "GhostBackup", "HauntShield", "EncoreHaunt" },
        HelperNPCs = {
            { Id = "GhostChoir", Role = "support", Action = "backs up clean streaks" },
            { Id = "StageMedium", Role = "defense", Action = "warns before cursed sections" },
        },
        AssetSearchSlots = {
            "haunted theater stage",
            "ghost npc character",
            "karaoke microphone stand",
            "velvet curtain",
        },
        ReviewSpaceId = "haunted_karaoke_room",
        Palette = {
            Primary = Color3.fromRGB(120, 255, 190),
            Secondary = Color3.fromRGB(80, 50, 120),
            Accent = Color3.fromRGB(255, 245, 180),
        },
    },
    {
        Id = "cloudback_idol_arena",
        Index = 5,
        Name = "Cloudback Idol Arena",
        ShortName = "Cloud Idol",
        Theme = "sky island idol stage, cloud crowd, angel synths",
        Status = "open",
        MinLevel = 5,
        MinPlayers = 3,
        Capacity = 6,
        FillSeconds = 22,
        TeamMode = "IdolSquad",
        RecommendedPlayers = "3-6",
        DifficultyOrder = { "Easy", "Hard", "Extreme" },
        DefaultDifficulty = "Hard",
        RewardMultiplier = 1.42,
        Bonuses = { Fans = 24, Coins = 14, XP = 28, Tickets = 1 },
        SkinUnlocks = { "Cloud Sneakers", "Halo Equalizer", "Idol Jacket" },
        Boosts = { "AirLift", "CloudCombo", "SoftLanding" },
        HelperNPCs = {
            { Id = "CloudIdol", Role = "host", Action = "boosts fans on A/S grade" },
            { Id = "StageAngel", Role = "rescue", Action = "softens one near-fail miss chain" },
        },
        AssetSearchSlots = {
            "sky island stage",
            "cloud platform",
            "idol npc",
            "concert crowd",
        },
        ReviewSpaceId = "cloudback_idol_room",
        Palette = {
            Primary = Color3.fromRGB(165, 235, 255),
            Secondary = Color3.fromRGB(255, 180, 235),
            Accent = Color3.fromRGB(255, 240, 120),
        },
    },
    {
        Id = "aquarium_bass_drop",
        Index = 6,
        Name = "Aquarium Bass Drop",
        ShortName = "Aquarium Bass",
        Theme = "glass tunnel, fish silhouettes, bubble speakers",
        Status = "open",
        MinLevel = 6,
        MinPlayers = 3,
        Capacity = 6,
        FillSeconds = 22,
        TeamMode = "ShieldSquad",
        RecommendedPlayers = "3-6",
        DifficultyOrder = { "Hard", "Extreme" },
        DefaultDifficulty = "Extreme",
        RewardMultiplier = 1.48,
        Bonuses = { Fans = 26, Coins = 18, XP = 34, Tickets = 1 },
        SkinUnlocks = { "Bubble Mic", "Fishbowl Helmet", "Aqua Lane Skin" },
        Boosts = { "BubbleShield", "BassCurrent", "PearlPayout" },
        HelperNPCs = {
            { Id = "BubbleDJ", Role = "host", Action = "adds bubble shields on streaks" },
            { Id = "ReefMedic", Role = "repair", Action = "heals the weakest performer" },
        },
        AssetSearchSlots = {
            "aquarium tunnel",
            "fish pack",
            "bubble speaker",
            "underwater stage",
        },
        ReviewSpaceId = "aquarium_bass_room",
        Palette = {
            Primary = Color3.fromRGB(50, 180, 255),
            Secondary = Color3.fromRGB(40, 80, 145),
            Accent = Color3.fromRGB(120, 255, 210),
        },
    },
    {
        Id = "junkyard_autotune_pit",
        Index = 7,
        Name = "Junkyard Auto-Tune Pit",
        ShortName = "Junkyard Pit",
        Theme = "scrap cars, speakers welded to cranes, metal percussion",
        Status = "open",
        MinLevel = 7,
        MinPlayers = 3,
        Capacity = 6,
        FillSeconds = 24,
        TeamMode = "RepairCrew",
        RecommendedPlayers = "3-6",
        DifficultyOrder = { "Extreme", "Brainrot" },
        DefaultDifficulty = "Extreme",
        RewardMultiplier = 1.55,
        Bonuses = { Fans = 30, Coins = 24, XP = 40, Tickets = 1 },
        SkinUnlocks = { "Scrap Guitar", "Weld Mask", "Chrome Groan Trail" },
        Boosts = { "ScrapShield", "RepairChain", "MetalCombo" },
        HelperNPCs = {
            { Id = "WrenchDJ", Role = "repair", Action = "converts repair streaks into bonus coins" },
            { Id = "CraneOperator", Role = "defense", Action = "pushes the horde back after clean sections" },
        },
        AssetSearchSlots = {
            "wrecked car",
            "junkyard props",
            "industrial crane",
            "metal speaker stage",
        },
        ReviewSpaceId = "junkyard_autotune_room",
        Palette = {
            Primary = Color3.fromRGB(210, 95, 45),
            Secondary = Color3.fromRGB(70, 80, 82),
            Accent = Color3.fromRGB(255, 210, 85),
        },
    },
    {
        Id = "neon_food_court_freestyle",
        Index = 8,
        Name = "Neon Food Court Freestyle",
        ShortName = "Food Court",
        Theme = "mall food stalls, glowing trays, chaotic crowd chants",
        Status = "open",
        MinLevel = 8,
        MinPlayers = 3,
        Capacity = 6,
        FillSeconds = 22,
        TeamMode = "TipJarCrew",
        RecommendedPlayers = "3-6",
        DifficultyOrder = { "Easy", "Hard", "Extreme" },
        DefaultDifficulty = "Hard",
        RewardMultiplier = 1.44,
        Bonuses = { Fans = 22, Coins = 26, XP = 32, Tickets = 1 },
        SkinUnlocks = { "Sauce Hoodie", "Tray Shield", "Soda Pop Speaker" },
        Boosts = { "SnackRecovery", "TipJar", "CrowdOrder" },
        HelperNPCs = {
            { Id = "SnackRunner", Role = "support", Action = "feeds recovery boosts between sections" },
            { Id = "MallCop", Role = "defense", Action = "stuns one horde surge per run" },
        },
        AssetSearchSlots = {
            "food court kiosk",
            "mall neon sign",
            "cash register",
            "restaurant table props",
        },
        ReviewSpaceId = "neon_food_court_room",
        Palette = {
            Primary = Color3.fromRGB(255, 120, 80),
            Secondary = Color3.fromRGB(255, 220, 90),
            Accent = Color3.fromRGB(80, 235, 210),
        },
    },
    {
        Id = "moonbase_echo_dome",
        Index = 9,
        Name = "Moonbase Echo Dome",
        ShortName = "Moonbase",
        Theme = "low-gravity dome, lunar crowd, satellite speakers",
        Status = "open",
        MinLevel = 9,
        MinPlayers = 4,
        Capacity = 6,
        FillSeconds = 24,
        TeamMode = "OrbitCrew",
        RecommendedPlayers = "4-6",
        DifficultyOrder = { "Hard", "Extreme", "Brainrot" },
        DefaultDifficulty = "Extreme",
        RewardMultiplier = 1.62,
        Bonuses = { Fans = 34, Coins = 24, XP = 46, Tickets = 2 },
        SkinUnlocks = { "Moon Boots", "Satellite Mic", "Vacuum Glow" },
        Boosts = { "LowGravityGrace", "EchoEncore", "OrbitCombo" },
        HelperNPCs = {
            { Id = "AstroRoadie", Role = "queue", Action = "keeps large parties synchronized" },
            { Id = "SatelliteSinger", Role = "support", Action = "copies one perfect streak to teammates" },
        },
        AssetSearchSlots = {
            "moonbase dome",
            "satellite dish",
            "space concert stage",
            "astronaut npc",
        },
        ReviewSpaceId = "moonbase_echo_room",
        Palette = {
            Primary = Color3.fromRGB(180, 200, 255),
            Secondary = Color3.fromRGB(45, 50, 90),
            Accent = Color3.fromRGB(120, 255, 255),
        },
    },
    {
        Id = "pirate_radio_shipyard",
        Index = 10,
        Name = "Pirate Radio Shipyard",
        ShortName = "Pirate Radio",
        Theme = "dockside pirate radio, ship masts, storm speakers",
        Status = "open",
        MinLevel = 10,
        MinPlayers = 4,
        Capacity = 6,
        FillSeconds = 26,
        TeamMode = "CrewShare",
        RecommendedPlayers = "4-6",
        DifficultyOrder = { "Extreme", "Brainrot" },
        DefaultDifficulty = "Brainrot",
        RewardMultiplier = 1.75,
        Bonuses = { Fans = 40, Coins = 34, XP = 58, Tickets = 2 },
        SkinUnlocks = { "Captain Mic", "Storm Sail Cape", "Radio Mast Trail" },
        Boosts = { "StormEncore", "CrewShare", "TreasurePayout" },
        HelperNPCs = {
            { Id = "CaptainGroanbeard", Role = "host", Action = "shares bonus rewards across the crew" },
            { Id = "DeckhandDJ", Role = "defense", Action = "fires cannon pushbacks at the active horde sector" },
        },
        AssetSearchSlots = {
            "pirate ship dock",
            "radio tower mast",
            "storm speaker",
            "dock crate props",
        },
        ReviewSpaceId = "pirate_radio_room",
        Palette = {
            Primary = Color3.fromRGB(55, 130, 170),
            Secondary = Color3.fromRGB(125, 75, 45),
            Accent = Color3.fromRGB(255, 220, 105),
        },
    },
    {
        Id = "doomscroll_data_center",
        Index = 11,
        Name = "Doomscroll Data Center",
        ShortName = "Doomscroll Core",
        Theme = "viral server racks, overheating terminals, cooldown panic",
        Status = "open",
        MinLevel = 11,
        MinPlayers = 3,
        Capacity = 6,
        FillSeconds = 24,
        TeamMode = "FirewallCrew",
        RecommendedPlayers = "3-6",
        DifficultyOrder = { "Hard", "Extreme", "Brainrot" },
        DefaultDifficulty = "Extreme",
        RewardMultiplier = 1.68,
        Bonuses = { Fans = 36, Coins = 28, XP = 52, Tickets = 2 },
        SkinUnlocks = { "Firewall Hoodie", "Cache Burst Trail", "Data Detox Visor" },
        Boosts = { "FirewallFreeze", "CooldownCache", "HeatVent" },
        HelperNPCs = {
            { Id = "FirewallAdmin", Role = "control", Action = "freezes one overloaded rack per phase" },
            { Id = "CacheMedic", Role = "support", Action = "turns purge streaks into cooldown recovery" },
        },
        AssetSearchSlots = {
            "server rack data center Roblox",
            "computer terminal Roblox",
            "warning light neon Roblox",
            "cable floor server room Roblox",
        },
        ReviewSpaceId = "doomscroll_data_center_room",
        Palette = {
            Primary = Color3.fromRGB(95, 255, 170),
            Secondary = Color3.fromRGB(30, 38, 52),
            Accent = Color3.fromRGB(255, 80, 130),
        },
    },
}

local byId = {}
for _, room in ipairs(RoomConfig.Rooms) do
    byId[room.Id] = room
end

local function copyArray(values)
    local out = {}
    for i, value in ipairs(values or {}) do
        out[i] = value
    end
    return out
end

function RoomConfig.GetRooms()
    return RoomConfig.Rooms
end

function RoomConfig.GetRoom(roomId)
    return byId[roomId] or byId[RoomConfig.DefaultRoomId]
end

function RoomConfig.GetDefaultRoom()
    return byId[RoomConfig.DefaultRoomId]
end

function RoomConfig.IsDifficultyAllowed(room, difficulty)
    if not room then return false end
    for _, allowed in ipairs(room.DifficultyOrder or {}) do
        if allowed == difficulty then return true end
    end
    return false
end

function RoomConfig.GetDifficulty(room, requestedDifficulty)
    if RoomConfig.IsDifficultyAllowed(room, requestedDifficulty) then
        return requestedDifficulty
    end
    return room and room.DefaultDifficulty or "Easy"
end

function RoomConfig.BuildRewardSummary(room)
    room = room or RoomConfig.GetDefaultRoom()
    return {
        multiplier = room.RewardMultiplier or 1,
        bonuses = room.Bonuses or {},
        skinUnlocks = copyArray(room.SkinUnlocks),
        boosts = copyArray(room.Boosts),
    }
end

local function cframeFromPad(pads, lookAt, slotIndex)
    local index = ((tonumber(slotIndex) or 1) - 1) % #pads + 1
    local position = pads[index]
    return CFrame.lookAt(position, lookAt)
end

local launchOffsets = {
    Vector3.new(-9, 2, -8),
    Vector3.new(9, 2, -8),
    Vector3.new(-14, 2, 2),
    Vector3.new(14, 2, 2),
    Vector3.new(-8, 2, 12),
    Vector3.new(8, 2, 12),
}

function RoomConfig.GetRoomSpace(roomId)
    local id = type(roomId) == "table" and roomId.Id or roomId
    return RoomConfig.RoomSpaces[id] or RoomConfig.RoomSpaces[RoomConfig.DefaultRoomId]
end

function RoomConfig.GetLaunchCFrame(roomIdOrSlot, slotIndex)
    if type(roomIdOrSlot) == "number" and slotIndex == nil then
        return cframeFromPad(RoomConfig.Session.LaunchPads, RoomConfig.Session.LaunchLookAt, roomIdOrSlot)
    end
    local roomId = type(roomIdOrSlot) == "table" and roomIdOrSlot.Id or roomIdOrSlot
    if roomId == nil or roomId == RoomConfig.DefaultRoomId then
        return cframeFromPad(RoomConfig.Session.LaunchPads, RoomConfig.Session.LaunchLookAt, slotIndex)
    end
    local space = RoomConfig.GetRoomSpace(roomId)
    local index = ((tonumber(slotIndex) or 1) - 1) % #launchOffsets + 1
    local position = space.Center + launchOffsets[index]
    return CFrame.lookAt(position, space.LookAt)
end

function RoomConfig.GetReturnCFrame(roomIdOrSlot, slotIndex)
    if type(roomIdOrSlot) == "number" and slotIndex == nil then
        return cframeFromPad(RoomConfig.Session.ReturnPads, RoomConfig.Session.ReturnLookAt, roomIdOrSlot)
    end
    return cframeFromPad(RoomConfig.Session.ReturnPads, RoomConfig.Session.ReturnLookAt, slotIndex)
end

function RoomConfig.GetAssetSearchSlots()
    local slots = {}
    for _, room in ipairs(RoomConfig.Rooms) do
        for _, query in ipairs(room.AssetSearchSlots or {}) do
            table.insert(slots, {
                roomId = room.Id,
                roomName = room.Name,
                query = query,
            })
        end
    end
    return slots
end

function RoomConfig.GetReviewSpaces()
    local spaces = {}
    for _, room in ipairs(RoomConfig.Rooms) do
        table.insert(spaces, {
            id = room.ReviewSpaceId,
            roomId = room.Id,
            name = room.Name,
            status = room.Status,
            center = RoomConfig.GetRoomSpace(room.Id).Center,
            size = RoomConfig.GetRoomSpace(room.Id).Size,
            entry = RoomConfig.GetRoomSpace(room.Id).Entry,
            lookAt = RoomConfig.GetRoomSpace(room.Id).LookAt,
        })
    end
    return spaces
end

return RoomConfig
