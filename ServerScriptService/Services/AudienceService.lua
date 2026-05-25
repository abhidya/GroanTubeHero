local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local AudienceService = {}
AudienceService.__index = AudienceService

function AudienceService:Init(runtimeContext)
    self.context = runtimeContext
    self.watchers = {}
end

local function isInAudienceZone(character, zonePart)
    if not character or not zonePart then
        return false
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false
    end
    local localPoint = zonePart.CFrame:PointToObjectSpace(root.Position)
    local half = zonePart.Size * 0.5
    return math.abs(localPoint.X) <= half.X and math.abs(localPoint.Y) <= half.Y + 5 and math.abs(localPoint.Z) <= half.Z
end

function AudienceService:RefreshWatcher(player)
    local world = workspace:FindFirstChild("GTH_WorldV2")
    local hitboxes = world and world:FindFirstChild("InvisibleGameplayHitboxes")
    local zone = hitboxes and hitboxes:FindFirstChild("AudienceZone")
    if not zone then
        local stage = workspace:FindFirstChild("Stage")
        zone = stage and stage:FindFirstChild("AudienceZone")
    end
    local inZone = isInAudienceZone(player.Character, zone)
    self.watchers[player.UserId] = inZone and true or nil
    player:SetAttribute("IsAudience", inZone)
    return inZone
end

function AudienceService:IsWatching(player)
    return self.watchers[player.UserId] == true or player:GetAttribute("IsAudience") == true
end

function AudienceService:ApplyAudienceAction(player, payload)
    if not self:IsWatching(player) then
        return false, "NotWatching"
    end
    if type(payload) ~= "table" or type(payload.action) ~= "string" then
        return false, "BadPayload"
    end

    local session = self.context.Services.SongSessionService:GetWatchingSession()
    if not session then
        return false, "NoPerformance"
    end

    local action = payload.action
    local performer = self.context.Services.SongSessionService:GetSessionById(session.id)
    if not performer then
        return false, "MissingPerformer"
    end

    local rewardFans = 2
    local rewardXP = 1
    local hypeBoost = 0
    if action == "Clap" then
        rewardFans = 3
        rewardXP = 2
        hypeBoost = 1
        session.modifiers = session.modifiers or {}
        session.modifiers.clapChain = (session.modifiers.clapChain or 0) + 1
        if session.modifiers.clapChain >= 3 then
            performer.stateData.hype = math.min(100, performer.stateData.hype + 4)
        end
    elseif action == "Cheer" then
        rewardFans = 4
        rewardXP = 2
        hypeBoost = 2
    elseif action == "Encore" then
        rewardFans = 6
        rewardXP = 3
        hypeBoost = 4
        if performer.stateData and performer.stateData.score and performer.stateData.score > 0 then
            local summary = self.context.Services.ScoreService:Finalize(performer)
            if summary.grade == "A" or summary.grade == "S" or summary.grade == "B" then
                hypeBoost = hypeBoost + 3
            end
        end
    elseif action == "Laugh" then
        rewardFans = 1
        rewardXP = 1
        hypeBoost = 0
    elseif action == "Support" then
        rewardFans = 4
        rewardXP = 2
        hypeBoost = 2
    end

    self.context.Services.DataService:Award(player, { Fans = rewardFans, XP = rewardXP })
    performer.stateData.hype = math.min(100, math.max(0, performer.stateData.hype + hypeBoost))
    if self.context.Services.HordeService and (action == "Clap" or action == "Cheer" or action == "Support" or action == "Encore") then
        self.context.Services.HordeService:ApplyAudienceSupport(performer, math.max(1, hypeBoost), "Audience")
    end
    self.context.Services.MissionService:RecordEvent(self.context.Services.DataService:GetProfile(player), "AudienceHelp", 1, { player = player })
    if action == "Cheer" then
        self.context.Services.MissionService:RecordEvent(self.context.Services.DataService:GetProfile(player), "AudienceActionCheer", 1, { player = player })
    end
    return true, {
        fans = rewardFans,
        xp = rewardXP,
        hypeBoost = hypeBoost,
    }
end

return AudienceService
