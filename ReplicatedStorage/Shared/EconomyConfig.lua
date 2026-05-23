local Config = {}

Config.LevelCurve = {
    BaseXP = 120,
    Growth = 1.18,
}

Config.Difficulty = {
    Easy = { baseFans = 45, baseCoins = 35, baseXP = 60, baseTickets = 0, rewardScale = 1.0 },
    Hard = { baseFans = 90, baseCoins = 70, baseXP = 110, baseTickets = 1, rewardScale = 1.5 },
    Extreme = { baseFans = 135, baseCoins = 105, baseXP = 165, baseTickets = 1, rewardScale = 2.25 },
    Brainrot = { baseFans = 190, baseCoins = 145, baseXP = 220, baseTickets = 2, rewardScale = 3.0 },
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

function Config.GetDifficultyProfile(difficulty)
    return Config.Difficulty[difficulty] or Config.Difficulty.Easy
end

return Config
