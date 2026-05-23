local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MissionConfig = require(ReplicatedStorage.Shared.MissionConfig)

local MissionService = {}
MissionService.__index = MissionService

function MissionService:Init(runtimeContext)
    self.context = runtimeContext
end

local function ensureProgress(store, list)
    for _, definition in ipairs(list) do
        local existing = store[definition.id]
        if type(existing) ~= "table" then
            existing = { progress = 0, completed = false, claimed = false }
            store[definition.id] = existing
        end
        existing.progress = tonumber(existing.progress) or 0
        existing.claimed = existing.claimed == true
        existing.completed = existing.claimed or existing.completed == true or existing.progress >= definition.target
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
    local changed = { completed = 0, progressed = 0, Fans = 0, Coins = 0, XP = 0, Tickets = 0 }
    local function process(listKey, definitions)
        local store = profile.Missions[listKey]
        for _, definition in ipairs(definitions) do
            if definition.event == eventName then
                local progress = store[definition.id]
                if progress and not progress.claimed and not progress.completed then
                    progress.progress = math.min(definition.target, (progress.progress or 0) + amount)
                    changed.progressed += 1
                    if progress.progress >= definition.target then
                        progress.completed = true
                        changed.completed += 1
                    end
                end
            end
        end
    end

    process("Daily", MissionConfig.Daily)
    process("Weekly", MissionConfig.Weekly)
    if changed.progressed > 0 and self.context and self.context.Services and self.context.Services.DataService and context and context.player then
        self.context.Services.DataService:UpdateProfile(context.player, function(updatedProfile)
            return updatedProfile
        end)
    end
    return changed
end

local function findMission(missionId)
    for listKey, definitions in pairs(MissionConfig.GetAll()) do
        for _, definition in ipairs(definitions) do
            if definition.id == missionId then
                return listKey, definition
            end
        end
    end
    return nil, nil
end

function MissionService:ClaimMission(player, missionId)
    local profile = self.context.Services.DataService:GetProfile(player)
    if not profile then
        return false, "NoData"
    end
    self:EnsureProfile(profile)

    local listKey, definition = findMission(missionId)
    if not definition then
        return false, "UnknownMission"
    end

    local state = profile.Missions[listKey] and profile.Missions[listKey][missionId]
    if not state then
        return false, "MissingMission"
    end
    if state.claimed then
        return false, "AlreadyClaimed"
    end
    if not state.completed and (state.progress or 0) < definition.target then
        return false, "Incomplete"
    end

    state.completed = true
    state.claimed = true
    local rewards = {
        Fans = definition.rewardFans or 0,
        Coins = definition.rewardCoins or 0,
        XP = definition.rewardXP or 0,
        Tickets = definition.rewardTickets or 0,
    }
    self.context.Services.DataService:Award(player, rewards)
    self.context.Services.DataService:SavePlayer(player)
    self.context.Services.DataService:UpdateProfile(player, function(updatedProfile)
        return updatedProfile
    end)
    return true, rewards
end

function MissionService:GetSnapshot(profile)
    self:EnsureProfile(profile)
    return profile.Missions
end

return MissionService
