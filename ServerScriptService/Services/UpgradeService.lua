local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local UpgradeConfig = require(ReplicatedStorage.Shared.UpgradeConfig)

local UpgradeService = {}
UpgradeService.__index = UpgradeService

function UpgradeService:Init(runtimeContext)
    self.context = runtimeContext
end

function UpgradeService:GetUpgradeLevel(profile, upgradeId)
    profile.Upgrades = profile.Upgrades or {}
    return profile.Upgrades[upgradeId] or 0
end

function UpgradeService:GetCost(profile, upgradeId)
    local current = self:GetUpgradeLevel(profile, upgradeId)
    local info = UpgradeConfig.Upgrades[upgradeId]
    if not info then
        return nil
    end
    if current >= info.max then
        return nil
    end
    return UpgradeConfig.GetCost(upgradeId, current)
end

function UpgradeService:PurchaseUpgrade(player, upgradeId)
    local profile = self.context.Services.DataService:GetProfile(player)
    if not profile then
        return false, "NoData"
    end

    local info = UpgradeConfig.Upgrades[upgradeId]
    if not info then
        return false, "UnknownUpgrade"
    end

    local current = self:GetUpgradeLevel(profile, upgradeId)
    if current >= info.max then
        return false, "CapReached"
    end

    local cost = self:GetCost(profile, upgradeId)
    if not cost then
        return false, "NoCost"
    end

    if not self.context.Services.DataService:SpendCurrency(player, "Coins", cost) then
        return false, "InsufficientCoins"
    end

    profile.Upgrades[upgradeId] = current + 1
    self.context.Services.DataService:SavePlayer(player)
    self.context.Services.DataService:UpdateProfile(player, function(updatedProfile)
        return updatedProfile
    end)
    return true, {
        upgradeId = upgradeId,
        level = profile.Upgrades[upgradeId],
        cost = cost,
    }
end

function UpgradeService:GetSessionBonus(profile, mode)
    if mode == Config.Modes.Pure then
        return {
            goodWindow = 0,
            hypeGain = 0,
            recovery = 0,
            stagecraft = 0,
            chaos = 0,
            focus = 0,
            coinBonus = 0,
            audiencePower = 0,
        }
    end

    profile.Upgrades = profile.Upgrades or {}
    return {
        goodWindow = (profile.Upgrades.Timing or 0) * 0.005,
        hypeGain = (profile.Upgrades.HypeGain or 0) * 0.05,
        recovery = (profile.Upgrades.Recovery or 0) * 0.10,
        stagecraft = (profile.Upgrades.Stagecraft or 0) * 0.08,
        chaos = (profile.Upgrades.Chaos or 0) * 0.10,
        focus = (profile.Upgrades.Focus or 0) * 0.10,
        coinBonus = (profile.Upgrades.CoinBonus or 0) * 0.08,
        audiencePower = (profile.Upgrades.AudiencePower or 0) * 0.08,
    }
end

return UpgradeService
