local BuffConfig = {}

BuffConfig.CareerBuffs = {
    SecondWind = { id = "SecondWind", cost = 35, cooldown = 30, category = "Career", description = "First miss after 20 combo does not break combo." },
    CrowdWarmup = { id = "CrowdWarmup", cost = 25, cooldown = 0, category = "Career", description = "Start with 10 Hype." },
    EncoreEnergy = { id = "EncoreEnergy", cost = 40, cooldown = 45, category = "Career", description = "+10% Fans if the final section is clean." },
    SteadyHands = { id = "SteadyHands", cost = 30, cooldown = 20, category = "Career", description = "Slightly wider Good window." },
    DramaBoost = { id = "DramaBoost", cost = 30, cooldown = 20, category = "Career", description = "Perfects give more Hype." },
    TubeSolo = { id = "TubeSolo", cost = 30, cooldown = 20, category = "Career", description = "Chorus Perfects give extra score." },
}

BuffConfig.InSongBuffs = {
    DeepBreath = { id = "DeepBreath", cost = 20, cooldown = 18, category = "InSong", description = "Next miss does not reset combo." },
    CrowdCall = { id = "CrowdCall", cost = 20, cooldown = 16, category = "InSong", description = "Instant +15 Hype." },
    StageFocus = { id = "StageFocus", cost = 25, cooldown = 22, category = "InSong", description = "Immune to next attack or debuff." },
    EncoreSurge = { id = "EncoreSurge", cost = 30, cooldown = 30, category = "InSong", description = "+20% score for next 10 notes." },
    TubeResonance = { id = "TubeResonance", cost = 25, cooldown = 18, category = "InSong", description = "Perfects restore Hype for 5 seconds." },
    CleanRun = { id = "CleanRun", cost = 25, cooldown = 20, category = "InSong", description = "Bonus Fans if no more misses this section." },
}

function BuffConfig.Get(buffId)
    return BuffConfig.CareerBuffs[buffId] or BuffConfig.InSongBuffs[buffId]
end

return BuffConfig
