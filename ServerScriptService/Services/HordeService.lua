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

local function pressureForCue(judgement, pressure)
    local current = pressure or 0
    if judgement == "Miss" then return 32 end
    if judgement == "PassiveCreep" then return 14 end
    if judgement == "Repair" then return -28 end
    if judgement == "Finish" then return -42 end
    if judgement == "Perfect" then return -20 end
    if judgement == "Good" or judgement == "Audience" then return -10 end
    return current > 50 and -6 or 0
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
        movementCue = horde.movementCue,
        movementEventId = horde.movementEventId or 0,
    }
end

function HordeService:_setMovementCue(horde, cueType, sectorId, strength)
    horde.movementEventId = (horde.movementEventId or 0) + 1
    horde.movementCue = {
        type = cueType,
        sectorId = sectorId or horde.activeSectorId,
        warningSectorId = horde.warningSectorId,
        strength = strength or 1,
        eventId = horde.movementEventId,
    }
end

function HordeService:_broadcast(session, lastJudgement)
    local horde = self.sessions[session.id]
    if not horde or not self.context or not self.context.Remotes or not self.context.Remotes.HordeUpdate then
        return
    end
    horde.eventSerial = (horde.eventSerial or 0) + 1
    horde.movementCue = lastJudgement or horde.lastJudgement
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
        movementEventId = 0,
        movementCue = nil,
        step = 0,
        eventSerial = 0,
        movementCue = "Start",
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
    horde.sectorPressure[sectorId] = math.clamp((horde.sectorPressure[sectorId] or 0) + pressureForCue(judgement, horde.sectorPressure[sectorId]), 0, 100)
    if judgement == "Miss" then
        horde.perfectStreak = 0
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) - math.max(6, math.abs(delta or 8)))
    elseif judgement == "Perfect" then
        horde.perfectStreak = (horde.perfectStreak or 0) + 1
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + 3)
        horde.sectorPressure[sectorId] = math.max(0, (horde.sectorPressure[sectorId] or 0) - 8)
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
    if judgement == "Miss" then
        horde.warningSectorId = sectorId
    end
    local cueStrength = math.clamp(math.abs(delta or 1) / 8, 0.8, 2.4)
    self:_setMovementCue(horde, judgement, sectorId, cueStrength)
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
                    horde.sectorPressure[sectorId] = math.clamp((horde.sectorPressure[sectorId] or 0) + math.max(8, horde.passiveBank * 2.5), 0, 100)
                    self:_setMovementCue(horde, "PassiveCreep", sectorId, 1.15)
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
            horde.sectorPressure[sector.id] = math.max(0, (horde.sectorPressure[sector.id] or 0) - 32)
        end
        horde.activeSectorId = horde.warningSectorId or horde.activeSectorId
        self:_setMovementCue(horde, "Finish", horde.activeSectorId, 2.2)
        self:_broadcast(session, "Finish")
        self.sessions[session.id] = nil
    end
end

function HordeService:RepairSector(player, sectorId, amount)
    amount = amount or 20
    sectorId = tostring(sectorId or ""):gsub("^HordeSector_", "")
    local session = player and self.context and self.context.Services and self.context.Services.SongSessionService:GetSession(player)
    local horde = session and self.sessions[session.id]
    if horde and horde.sectorHealths and horde.sectorHealths[sectorId] ~= nil then
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + amount)
        horde.sectorPressure[sectorId] = math.max(0, (horde.sectorPressure[sectorId] or 0) - amount)
        horde.activeSectorId = sectorId
        horde.warningSectorId = weakestSector(horde.sectorHealths)
        self:_setMovementCue(horde, "Repair", sectorId, math.clamp(amount / 20, 0.8, 2.0))
        session.sectorHealths = horde.sectorHealths
        session.activeSectorId = sectorId
        self:_broadcast(session, "Repair")
    end
    local world = workspace:FindFirstChild("GTH_WorldV2")
    local sector = world and world:FindFirstChild("HordeSector_" .. sectorId, true)
    if sector then
        local health = clampHealth((sector:GetAttribute("Health") or 100) + amount)
        sector:SetAttribute("Health", health)
        sector:SetAttribute("Pressure", math.max(0, (sector:GetAttribute("Pressure") or 0) - amount))
        sector:SetAttribute("LastRepairBy", player and player.UserId or 0)
        sector:SetAttribute("LastRepairAt", os.clock())
        local fence = sector:FindFirstChild("FenceSegment")
        if fence and fence:IsA("BasePart") then fence.Color = Color3.fromRGB(95, 255, 120) end
        local vfx = sector:FindFirstChild("FenceDamageVFX")
        if vfx and vfx:IsA("BasePart") then
            vfx.Color = Color3.fromRGB(80, 255, 140)
            vfx.Transparency = 0.05
        end
        local weak = sector:FindFirstChild("WeakPointMarker")
        if weak and weak:IsA("BasePart") then weak.Color = Color3.fromRGB(80, 255, 140) end
        local siren = sector:FindFirstChild("SirenLight")
        local light = siren and siren:FindFirstChildOfClass("PointLight")
        if light then
            light.Color = Color3.fromRGB(80, 255, 140)
            light.Brightness = 4
        end
        local meter = sector:FindFirstChild("HordePressureMeter")
        if meter and meter:IsA("BasePart") then meter:SetAttribute("Pressure", sector:GetAttribute("Pressure") or 0) end
        task.delay(1.15, function()
            if not sector.Parent then return end
            if vfx and vfx.Parent then
                vfx.Color = Color3.fromRGB(255, 80, 40)
                vfx.Transparency = health < 60 and 0.15 or 0.75
            end
            if light and light.Parent then
                light.Color = Color3.fromRGB(255, 35, 35)
                light.Brightness = health < 35 and 5 or 0
            end
        end)
    end
    return true
end

function HordeService:RemoveSession(sessionOrId)
    local id = type(sessionOrId) == "table" and sessionOrId.id or sessionOrId
    if id then
        self.sessions[id] = nil
    end
end

return HordeService
