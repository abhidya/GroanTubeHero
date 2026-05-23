local Config = {}

Config.LevelCurve = {
    BaseXP = 120,
    Growth = 1.18,
}

Config.Difficulty = {
    Easy = { baseFans = 45, baseCoins = 35, baseXP = 60, baseTickets = 0, rewardScale = 1.0 },
    Medium = { baseFans = 70, baseCoins = 55, baseXP = 85, baseTickets = 1, rewardScale = 1.2 },
    Hard = { baseFans = 100, baseCoins = 75, baseXP = 120, baseTickets = 1, rewardScale = 1.45 },
}

Config.VenueFees = {
    SchoolStage = 0,
    MallBooth = 0.05,
    NeonArena = 0.10,
    WeddingHall = 0.08,
    SpaceLounge = 0.15,
}

Config.VenueModifiers = {
    SchoolStage = { fans = 1.0, hype = 1.0, tickets = 0 },
    MallBooth = { fans = 1.0, hype = 1.0, tickets = 0.25 },
    NeonArena = { fans = 1.35, hype = 1.0, tickets = 0 },
    WeddingHall = { fans = 1.05, hype = 1.15, tickets = 0 },
    SpaceLounge = { fans = 1.20, hype = 1.05, tickets = 0.4 },
}

function Config.GetXPForLevel(level)
    if level <= 1 then
        return 0
    end
    return math.floor(Config.LevelCurve.BaseXP * ((level - 1) ^ Config.LevelCurve.Growth))
end

function Config.GetDifficultyProfile(songId)
    if songId == "NeonGroan" then
        return Config.Difficulty.Easy
    elseif songId == "RomanticTubeDisaster" then
        return Config.Difficulty.Medium
    end
    return Config.Difficulty.Hard
end

return Config
