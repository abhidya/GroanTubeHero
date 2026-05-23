local AttackConfig = {}

AttackConfig.Attacks = {
    VoiceCrack = { id = "VoiceCrack", cost = 30, cooldown = 12, battleOnly = true, description = "Opponent next miss costs extra Hype." },
    SpotlightDrift = { id = "SpotlightDrift", cost = 25, cooldown = 14, battleOnly = true, description = "Opponent highway shifts slightly for 2 seconds." },
    BooWave = { id = "BooWave", cost = 25, cooldown = 14, battleOnly = true, description = "Opponent Hype gain reduced for 5 seconds." },
    TubeWarp = { id = "TubeWarp", cost = 20, cooldown = 10, battleOnly = true, description = "One upcoming note visually wobbles." },
    MicFeedback = { id = "MicFeedback", cost = 20, cooldown = 12, battleOnly = true, description = "Brief screen pulse; Focus reduces it." },
    AwkwardSilence = { id = "AwkwardSilence", cost = 20, cooldown = 14, battleOnly = true, description = "Opponent crowd effects disabled for 4 seconds." },
    Heckle = { id = "Heckle", cost = 20, cooldown = 10, battleOnly = true, description = "Cosmetic distraction + small Hype damage." },
    TomatoSplash = { id = "TomatoSplash", cost = 20, cooldown = 12, battleOnly = true, description = "Short visual splat; never fully covers notes." },
}

function AttackConfig.Get(attackId)
    return AttackConfig.Attacks[attackId]
end

return AttackConfig
