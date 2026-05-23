local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TourBusService = {}
TourBusService.__index = TourBusService

TourBusService.Upgrades = {
    BiggerSpeakers = { id = "BiggerSpeakers", cost = 120, description = "+Hype gain" },
    SnackStand = { id = "SnackStand", cost = 140, description = "Passive Fans placeholder" },
    PracticeSeat = { id = "PracticeSeat", cost = 130, description = "+XP from retries" },
    MerchBox = { id = "MerchBox", cost = 150, description = "+Fans from audience" },
    RoadCrew = { id = "RoadCrew", cost = 180, description = "Lowers venue fees" },
    NeonWrap = { id = "NeonWrap", cost = 100, description = "Cosmetic bus wrap" },
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
