local Config = {}

Config.Upgrades = {
    Timing = { max = 5, baseCost = 120, growth = 1.35, perLevel = { goodWindow = 0.01 } },
    HypeGain = { max = 5, baseCost = 150, growth = 1.38, perLevel = { hypeOnHit = 0.08 } },
    Recovery = { max = 5, baseCost = 150, growth = 1.40, perLevel = { missPenaltyReduction = 0.10 } },
    Stagecraft = { max = 5, baseCost = 170, growth = 1.42, perLevel = { stageFans = 0.08 } },
    Chaos = { max = 5, baseCost = 180, growth = 1.45, perLevel = { battlePotency = 0.10 } },
    Focus = { max = 5, baseCost = 180, growth = 1.40, perLevel = { debuffReduction = 0.10 } },
    CoinBonus = { max = 5, baseCost = 160, growth = 1.37, perLevel = { coinBonus = 0.08 } },
    AudiencePower = { max = 5, baseCost = 160, growth = 1.36, perLevel = { audiencePower = 0.08 } },
}

function Config.GetCost(upgradeId, currentLevel)
    local info = Config.Upgrades[upgradeId]
    if not info then
        return nil
    end
    return math.floor(info.baseCost * (info.growth ^ currentLevel))
end

return Config
