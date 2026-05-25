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

local SECTORS = {
    { id = "E", angle = 0 },
    { id = "NE", angle = 45 },
    { id = "N", angle = 90 },
    { id = "NW", angle = 135 },
    { id = "W", angle = 180 },
    { id = "SW", angle = 225 },
    { id = "S", angle = 270 },
    { id = "SE", angle = 315 },
}

local function clampDistance(value)
    return math.clamp(value or 100, 0, 100)
end

local function clampHealth(value)
    return math.clamp(value or 100, 0, 100)
end

local function stateFor(distance)
    if distance <= 0 then return "Disaster" end
    if distance <= 18 then return "Critical" end
    if distance <= 38 then return "Close" end
    if distance <= 68 then return "Approaching" end
    return "Far"
end

local function newSectorState()
    local healths = {}
    local pressure = {}
    for _, sector in ipairs(SECTORS) do
        healths[sector.id] = 100
        pressure[sector.id] = 0
    end
    return healths, pressure
end

local function weakestSector(healths)
    local weakestId = SECTORS[1].id
    local weakest = math.huge
    for _, sector in ipairs(SECTORS) do
        local value = healths[sector.id] or 100
        if value < weakest then
            weakest = value
            weakestId = sector.id
        end
    end
    return weakestId
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
        sectorHealths = horde.sectorHealths,
        activeSectorId = horde.activeSectorId,
        sectorPressure = horde.sectorPressure,
        sectorAngles = horde.sectorAngles,
        warningSectorId = horde.warningSectorId,
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

function HordeService:_pickActiveSector(horde, judgement)
    horde.step = (horde.step or 0) + 1
    if judgement == "Perfect" and horde.warningSectorId then
        return horde.warningSectorId
    end
    local index = ((horde.step - 1) % #SECTORS) + 1
    return SECTORS[index].id
end

function HordeService:StartSession(session)
    if not session then return end
    local healths, pressure = newSectorState()
    local angles = {}
    for _, sector in ipairs(SECTORS) do angles[sector.id] = sector.angle end
    self.sessions[session.id] = {
        distance = 100,
        lastJudgement = "Start",
        disasterMode = false,
        lastBroadcast = 0,
        passiveBank = 0,
        activeSectorId = "N",
        warningSectorId = nil,
        sectorHealths = healths,
        sectorPressure = pressure,
        sectorAngles = angles,
        perfectStreak = 0,
        step = 0,
    }
    session.hordeDistance = 100
    session.hordeState = "Far"
    session.sectorHealths = healths
    session.activeSectorId = "N"
    self:_broadcast(session, "Start")
end

function HordeService:_applySectorJudgement(session, horde, judgement, delta)
    local sectorId = self:_pickActiveSector(horde, judgement)
    horde.activeSectorId = sectorId
    horde.sectorPressure[sectorId] = math.clamp((horde.sectorPressure[sectorId] or 0) + (judgement == "Miss" and 18 or -8), 0, 100)
    if judgement == "Miss" then
        horde.perfectStreak = 0
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) - math.max(6, math.abs(delta or 8)))
    elseif judgement == "Perfect" then
        horde.perfectStreak = (horde.perfectStreak or 0) + 1
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + 3)
        if horde.perfectStreak >= 5 then
            local weak = weakestSector(horde.sectorHealths)
            horde.sectorHealths[weak] = clampHealth((horde.sectorHealths[weak] or 100) + 10)
            horde.warningSectorId = nil
            horde.perfectStreak = 0
        end
    elseif judgement == "Good" or judgement == "Audience" then
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + 1)
    end
    horde.warningSectorId = weakestSector(horde.sectorHealths)
    session.sectorHealths = horde.sectorHealths
    session.activeSectorId = horde.activeSectorId
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
    self:_applySectorJudgement(session, horde, judgement, delta)
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
    self:_applySectorJudgement(session, horde, "Audience", amount or ACTIONS.Audience)
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
                    local sectorId = self:_pickActiveSector(horde, "PassiveCreep")
                    horde.activeSectorId = sectorId
                    horde.sectorPressure[sectorId] = math.clamp((horde.sectorPressure[sectorId] or 0) + horde.passiveBank, 0, 100)
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
        local horde = self.sessions[session.id]
        horde.distance = clampDistance((horde.distance or 100) + 12)
        for _, sector in ipairs(SECTORS) do
            horde.sectorHealths[sector.id] = clampHealth((horde.sectorHealths[sector.id] or 100) + 8)
            horde.sectorPressure[sector.id] = math.max(0, (horde.sectorPressure[sector.id] or 0) - 12)
        end
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
