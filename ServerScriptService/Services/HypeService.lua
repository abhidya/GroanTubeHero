local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Scoring = require(ReplicatedStorage.Shared.Scoring)

local HypeService = {}
HypeService.__index = HypeService

function HypeService:Init(runtimeContext)
    self.context = runtimeContext
end

function HypeService:GetTier(value)
    return Scoring.GetHypeTier(value)
end

function HypeService:ApplyDelta(session, amount)
    local state = session.stateData
    state.hype = Config.Clamp((state.hype or 0) + amount, Config.Hype.Min, Config.Hype.Max)
    return state.hype
end

function HypeService:ApplyStartBonus(session, profile)
    local amount = 0
    if session.modifiers and session.modifiers.crowdWarmup then
        amount = amount + 10
    end
    amount = amount + (profile.TourBus.BiggerSpeakers or 0) * 2
    return self:ApplyDelta(session, amount)
end

function HypeService:ApplyPerfect(session, profile, note)
    local amount = 5 + (profile.Upgrades.HypeGain or 0)
    if session.modifiers and session.modifiers.dramaBoost then
        amount = amount + 2
    end
    if session.modifiers and session.modifiers.tubeResonance then
        amount = amount + 1
    end
    if profile.TourBus.BiggerSpeakers and profile.TourBus.BiggerSpeakers > 0 then
        amount = amount + 1
    end
    return self:ApplyDelta(session, amount)
end

function HypeService:ApplyGood(session, profile)
    local amount = 2 + math.floor((profile.Upgrades.HypeGain or 0) / 2)
    return self:ApplyDelta(session, amount)
end

function HypeService:ApplyMiss(session, profile)
    local penalty = 6 - (profile.Upgrades.Recovery or 0)
    if penalty < 3 then
        penalty = 3
    end
    return self:ApplyDelta(session, -penalty)
end

function HypeService:ApplyAudienceAction(session, amount)
    return self:ApplyDelta(session, amount)
end

return HypeService
