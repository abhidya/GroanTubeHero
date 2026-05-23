local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TourBusService = {}
TourBusService.__index = TourBusService

TourBusService.Upgrades = {
    BiggerSpeakers = { id = "BiggerSpeakers", name = "Bigger Speakers", cost = 120, currency = "Coins", max = 5, description = "+Hype gain during performances." },
    SnackStand = { id = "SnackStand", name = "Snack Stand", cost = 140, currency = "Coins", max = 5, description = "Small bonus Fans after completed songs." },
    PracticeSeat = { id = "PracticeSeat", name = "Practice Seat", cost = 130, currency = "Coins", max = 5, description = "+XP from retries and replays." },
    MerchBox = { id = "MerchBox", name = "Merch Box", cost = 150, currency = "Fans", max = 5, description = "+Fans from audience participation." },
    RoadCrew = { id = "RoadCrew", name = "Road Crew", cost = 180, currency = "Coins", max = 5, description = "Reduces venue fees." },
    NeonWrap = { id = "NeonWrap", name = "Neon Wrap", cost = 100, currency = "Fans", max = 3, description = "Cosmetic Tour Bus flex." },
}

function TourBusService:Init(runtimeContext)
    self.context = runtimeContext
end

function TourBusService:GetProfile(profile)
    profile.TourBus = profile.TourBus or {}
    for id in pairs(self.Upgrades) do
        profile.TourBus[id] = profile.TourBus[id] or 0
    end
    return profile.TourBus
end

function TourBusService:GetModifiers(profile)
    local bus = self:GetProfile(profile)
    return {
        hypeGain = bus.BiggerSpeakers or 0,
        passiveFans = bus.SnackStand or 0,
        practiceSeat = bus.PracticeSeat or 0,
        merchBonus = bus.MerchBox or 0,
        roadCrew = bus.RoadCrew or 0,
        neonWrap = bus.NeonWrap or 0,
    }
end

function TourBusService:GetCost(profile, upgradeId)
    local info = self.Upgrades[upgradeId]
    if not info then
        return nil
    end
    local bus = self:GetProfile(profile)
    local current = bus[upgradeId] or 0
    if current >= info.max then
        return nil
    end
    return math.floor((info.cost or 100) * (1.35 ^ current))
end

function TourBusService:PurchaseUpgrade(player, upgradeId)
    local profile = self.context.Services.DataService:GetProfile(player)
    if not profile then
        return false, "NoData"
    end
    local info = self.Upgrades[upgradeId]
    if not info then
        return false, "UnknownTourBusUpgrade"
    end

    local bus = self:GetProfile(profile)
    local current = bus[upgradeId] or 0
    if current >= info.max then
        return false, "Maxed"
    end

    local cost = self:GetCost(profile, upgradeId)
    local currency = info.currency or "Coins"
    if not self.context.Services.DataService:SpendCurrency(player, currency, cost) then
        return false, "InsufficientCurrency"
    end

    bus[upgradeId] = current + 1
    self.context.Services.DataService:SavePlayer(player)
    self.context.Services.DataService:UpdateProfile(player, function(updatedProfile)
        return updatedProfile
    end)
    return true, { upgradeId = upgradeId, level = bus[upgradeId], cost = cost, currency = currency }
end

function TourBusService:ApplyRewardModifiers(profile, rewards, isRetry)
    local bus = self:GetProfile(profile)
    local modified = {
        Fans = rewards.Fans,
        Coins = rewards.Coins,
        XP = rewards.XP,
        Tickets = rewards.Tickets,
    }

    if (bus.BiggerSpeakers or 0) > 0 then
        modified.XP = math.floor(modified.XP + (bus.BiggerSpeakers * 2))
    end
    if (bus.SnackStand or 0) > 0 then
        modified.Fans = math.floor(modified.Fans + bus.SnackStand * 2)
    end
    if isRetry and (bus.PracticeSeat or 0) > 0 then
        modified.XP = math.floor(modified.XP * (1 + (bus.PracticeSeat * 0.05)))
    end
    if (bus.MerchBox or 0) > 0 then
        modified.Fans = math.floor(modified.Fans * (1 + (bus.MerchBox * 0.05)))
    end

    return modified
end

return TourBusService
