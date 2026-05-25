local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local HordeService = {}
HordeService.__index = HordeService

local ACTIONS = {
    Perfect = 7,
    Good = 3,
    Miss = -8,
    Audience = 2,
}

local function clampDistance(value)
    return math.clamp(value or 100, 0, 100)
end

local function stateFor(distance)
    if distance <= 0 then return "Disaster" end
    if distance <= 18 then return "Critical" end
    if distance <= 38 then return "Close" end
    if distance <= 68 then return "Approaching" end
    return "Far"
end

function HordeService:Init(runtimeContext)
    self.context = runtimeContext
    self.sessions = {}
end

function HordeService:_payload(session, horde, lastJudgement)
    return {
        performerUserId = session.playerId,
        sessionId = session.id,
        distance = math.floor((horde.distance or 100) * 10 + 0.5) / 10,
        stability = session.stateData and session.stateData.hp or 100,
        state = stateFor(horde.distance),
        intensity = 1 - ((horde.distance or 100) / 100),
        lastJudgement = lastJudgement or horde.lastJudgement,
        disasterMode = (horde.distance or 100) <= 0,
    }
end

function HordeService:_broadcast(session, lastJudgement)
    local horde = self.sessions[session.id]
    if not horde or not self.context or not self.context.Remotes or not self.context.Remotes.HordeUpdate then
        return
    end
    local payload = self:_payload(session, horde, lastJudgement)
    self.context.Remotes.HordeUpdate:FireAllClients(payload)
end

function HordeService:StartSession(session)
    if not session then return end
    self.sessions[session.id] = {
        distance = 100,
        lastJudgement = "Start",
        disasterMode = false,
        lastBroadcast = 0,
        passiveBank = 0,
    }
    session.hordeDistance = 100
    session.hordeState = "Far"
    self:_broadcast(session, "Start")
end

function HordeService:ApplyJudgement(session, judgement)
    if not session then return nil end
    local horde = self.sessions[session.id]
    if not horde then
        self:StartSession(session)
        horde = self.sessions[session.id]
    end
    local delta = ACTIONS[judgement] or 0
    if judgement == "Miss" then
        local diff = session.difficultyConfig or Config.Difficulties[session.difficulty or "Easy"] or Config.Difficulties.Easy
        delta = -(diff.hordeMissAdvance or diff.hpDamageMiss or 8)
    end
    horde.distance = clampDistance((horde.distance or 100) + delta)
    horde.lastJudgement = judgement
    horde.disasterMode = horde.distance <= 0
    session.hordeDistance = horde.distance
    session.hordeState = stateFor(horde.distance)
    session.disasterMode = horde.disasterMode
    self:_broadcast(session, judgement)
    return horde.distance
end

function HordeService:ApplyAudienceSupport(session, amount, action)
    if not session then return nil end
    local horde = self.sessions[session.id]
    if not horde then
        self:StartSession(session)
        horde = self.sessions[session.id]
    end
    horde.distance = clampDistance((horde.distance or 100) + (amount or ACTIONS.Audience))
    horde.lastJudgement = action or "Audience"
    session.hordeDistance = horde.distance
    session.hordeState = stateFor(horde.distance)
    self:_broadcast(session, action or "Audience")
    return horde.distance
end

function HordeService:Update(dt)
    for sessionId, horde in pairs(self.sessions) do
        local session = self.context.Services.SongSessionService:GetSessionById(sessionId)
        if not session or session.state == "Finished" then
            self.sessions[sessionId] = nil
        elseif session.state == "Playing" then
            local diffId = session.difficulty or "Easy"
            if diffId == "Brainrot" then
                horde.passiveBank = (horde.passiveBank or 0) + (dt or 0) * 1.8
                if horde.passiveBank >= 1 then
                    horde.distance = clampDistance(horde.distance - horde.passiveBank)
                    horde.passiveBank = 0
                    session.hordeDistance = horde.distance
                    session.hordeState = stateFor(horde.distance)
                    session.disasterMode = horde.distance <= 0
                    self:_broadcast(session, "PassiveCreep")
                end
            end
        end
    end
end

function HordeService:FinishSession(session)
    if session and self.sessions[session.id] then
        self:_broadcast(session, "Finish")
        self.sessions[session.id] = nil
    end
end

function HordeService:RemoveSession(sessionOrId)
    local id = type(sessionOrId) == "table" and sessionOrId.id or sessionOrId
    if id then
        self.sessions[id] = nil
    end
end

return HordeService
