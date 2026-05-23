local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MissionConfig = require(ReplicatedStorage.Shared.MissionConfig)

local MissionService = {}
MissionService.__index = MissionService

function MissionService:Init(runtimeContext)
    self.context = runtimeContext
end

local function ensureProgress(store, list)
    for _, definition in ipairs(list) do
        store[definition.id] = store[definition.id] or { progress = 0, claimed = false }
    end
end

function MissionService:EnsureProfile(profile)
    profile.Missions = profile.Missions or {}
    profile.Missions.Daily = profile.Missions.Daily or {}
    profile.Missions.Weekly = profile.Missions.Weekly or {}
    profile.Missions.Completed = profile.Missions.Completed or {}
    ensureProgress(profile.Missions.Daily, MissionConfig.Daily)
    ensureProgress(profile.Missions.Weekly, MissionConfig.Weekly)
end

function MissionService:ResetIfNeeded(profile)
    self:EnsureProfile(profile)
    local nowStamp = os.time()
    local resetStamp = profile.Missions.ResetStamp or 0
    if resetStamp == 0 or nowStamp - resetStamp >= 86400 then
        profile.Missions.Daily = {}
        ensureProgress(profile.Missions.Daily, MissionConfig.Daily)
        profile.Missions.ResetStamp = nowStamp
    end
end

function MissionService:RecordEvent(profile, eventName, amount, context)
    self:EnsureProfile(profile)
    amount = amount or 1
    local completeRewards = { Fans = 0, Coins = 0, XP = 0, Tickets = 0 }
    local function process(listKey, definitions)
        local store = profile.Missions[listKey]
        for _, definition in ipairs(definitions) do
            if definition.event == eventName then
                local progress = store[definition.id]
                if progress and not progress.claimed then
                    progress.progress = math.min(definition.target, (progress.progress or 0) + amount)
                    if progress.progress >= definition.target then
                        progress.claimed = true
                        completeRewards.Fans = completeRewards.Fans + (definition.rewardFans or 0)
                        completeRewards.Coins = completeRewards.Coins + (definition.rewardCoins or 0)
                        completeRewards.XP = completeRewards.XP + (definition.rewardXP or 0)
                    end
                end
            end
        end
    end

    process("Daily", MissionConfig.Daily)
    process("Weekly", MissionConfig.Weekly)
    if self.context and self.context.Services and self.context.Services.DataService then
        if completeRewards.Fans > 0 or completeRewards.Coins > 0 or completeRewards.XP > 0 then
            self.context.Services.DataService:Award(context.player, completeRewards)
        end
    end
    return completeRewards
end

function MissionService:GetSnapshot(profile)
    self:EnsureProfile(profile)
    return profile.Missions
end

return MissionService
