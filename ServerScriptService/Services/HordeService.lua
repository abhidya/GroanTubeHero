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

local HAZARD_CUES = {
    CrashSurge = true,
    PassiveCreep = true,
    GlitchSurge = true,
    TrainSurge = true,
    CurtainSlam = true,
    FloodSurge = true,
    ScrapStorm = true,
    OrderRush = true,
    GravitySlip = true,
    SignalJam = true,
    HeatOverload = true,
}

local PUSHBACK_CUES = {
    PerfectPushback = true,
    AudiencePushback = true,
    EncorePushback = true,
    AudienceHeatPushback = true,
    SecurityRepair = true,
    DJWarning = true,
}

local SUPPORT_CUES = {
    PatchBotStabilize = true,
    ComboCacheCharge = true,
    BuskerTiming = true,
    ConductorSignal = true,
    GhostChoirBackup = true,
    StageMediumWarning = true,
    BubbleShieldPulse = true,
    ReefMedicHeal = true,
    WrenchRepairChain = true,
    CranePushback = true,
    SnackRecovery = true,
    MallCopStun = true,
    OrbitStabilize = true,
    SatelliteEcho = true,
    CaptainCrewShare = true,
    DeckhandCannon = true,
    FirewallFreeze = true,
    CacheRecovery = true,
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

local function sectorOrdinal(sectorId)
    for index, sector in ipairs(SECTORS) do
        if sector.id == sectorId then
            return index
        end
    end
    return 1
end

local function listHasSector(list, sectorId)
    for _, value in ipairs(list or {}) do
        if value == sectorId then
            return true
        end
    end
    return false
end

local function pressureForCue(judgement, pressure)
    local current = pressure or 0
    if judgement == "Miss" then return 32 end
    if judgement == "PassiveCreep" then return 14 end
    if judgement == "Repair" then return -28 end
    if judgement == "Finish" then return -42 end
    if judgement == "PerfectPushback" then return -34 end
    if judgement == "Perfect" then return -20 end
    if judgement == "Good" or judgement == "Audience" then return -10 end
    return current > 50 and -6 or 0
end

local function sessionHasBoost(session, boostId)
    for _, boost in ipairs((session and session.roomBoosts) or {}) do
        if boost == boostId then return true end
    end
    return false
end

local function sessionHasHelper(session, helperId)
    for _, helper in ipairs((session and session.roomHelperNPCs) or {}) do
        if helper.Id == helperId then return true end
    end
    return false
end

local ROOM_MECHANICS = {
    cyber_arcade_overclock = {
        targetBias = { attack = { "E", "NE" }, creep = { "SE", "E" }, support = { "N", "NE" } },
        hazard = { cue = "GlitchSurge", pressure = 18, healthDamage = 3, cooldown = 5, action = "glitch tiles surged" },
        helpers = {
            { id = "PatchBot", trigger = "weak", cue = "PatchBotStabilize", action = "stabilized fakeout lanes", pressureRelief = 24, healthRepair = 10, distanceRelief = 3, cooldown = 8, thresholdPressure = 48, thresholdHealth = 70 },
            { id = "ArcadeTech", boost = "ComboCache", trigger = "streak", cue = "ComboCacheCharge", action = "charged the combo cache", pressureRelief = 14, healthRepair = 5, distanceRelief = 6, cooldown = 9, streak = 3 },
        },
    },
    subway_meme_tunnel = {
        targetBias = { attack = { "E", "W" }, creep = { "NE", "SW" }, support = { "N", "S" } },
        hazard = { cue = "TrainSurge", pressure = 22, healthDamage = 4, cooldown = 5, action = "rush train surged" },
        helpers = {
            { id = "BuskerBuddy", trigger = "good", cue = "BuskerTiming", action = "widened the rough phrase", pressureRelief = 15, healthRepair = 3, distanceRelief = 4, cooldown = 8 },
            { id = "ConductorCrew", boost = "PlatformDash", trigger = "weak", cue = "ConductorSignal", action = "called a safe platform lane", pressureRelief = 20, healthRepair = 6, distanceRelief = 2, cooldown = 10, thresholdPressure = 55, thresholdHealth = 68 },
        },
    },
    haunted_karaoke_theater = {
        targetBias = { attack = { "N", "NW" }, creep = { "W", "NE" }, support = { "N", "NW" } },
        hazard = { cue = "CurtainSlam", pressure = 18, healthDamage = 3, cooldown = 6, action = "cursed curtains slammed" },
        helpers = {
            { id = "GhostChoir", boost = "GhostBackup", trigger = "streak", cue = "GhostChoirBackup", action = "backed up the chorus", pressureRelief = 18, healthRepair = 4, distanceRelief = 7, cooldown = 9, streak = 2 },
            { id = "StageMedium", trigger = "weak", cue = "StageMediumWarning", action = "warned before the cursed section", pressureRelief = 18, healthRepair = 5, distanceRelief = 2, cooldown = 10, thresholdPressure = 58, thresholdHealth = 66 },
        },
    },
    aquarium_bass_drop = {
        targetBias = { attack = { "S", "SE" }, creep = { "SW", "S" }, support = { "N", "NE" } },
        hazard = { cue = "FloodSurge", pressure = 20, healthDamage = 4, cooldown = 6, action = "bass flood surged" },
        helpers = {
            { id = "BubbleDJ", boost = "BubbleShield", trigger = "good", cue = "BubbleShieldPulse", action = "pulsed bubble shields", pressureRelief = 18, healthRepair = 5, distanceRelief = 5, cooldown = 8 },
            { id = "ReefMedic", trigger = "weak", cue = "ReefMedicHeal", action = "healed the weakest performer lane", pressureRelief = 20, healthRepair = 13, distanceRelief = 2, cooldown = 11, thresholdPressure = 50, thresholdHealth = 72 },
        },
    },
    junkyard_autotune_pit = {
        targetBias = { attack = { "W", "SW" }, creep = { "S", "W" }, support = { "E", "NE" } },
        hazard = { cue = "ScrapStorm", pressure = 24, healthDamage = 5, cooldown = 6, action = "scrap storm rolled in" },
        helpers = {
            { id = "WrenchDJ", boost = "RepairChain", trigger = "weak", cue = "WrenchRepairChain", action = "chained speaker repairs", pressureRelief = 24, healthRepair = 14, distanceRelief = 2, cooldown = 9, thresholdPressure = 54, thresholdHealth = 70 },
            { id = "CraneOperator", trigger = "streak", cue = "CranePushback", action = "swung the crane pushback", pressureRelief = 18, healthRepair = 5, distanceRelief = 8, cooldown = 10, streak = 3 },
        },
    },
    neon_food_court_freestyle = {
        targetBias = { attack = { "SE", "E" }, creep = { "S", "SE" }, support = { "N", "W" } },
        hazard = { cue = "OrderRush", pressure = 17, healthDamage = 2, cooldown = 5, action = "order rush jammed the lanes" },
        helpers = {
            { id = "SnackRunner", boost = "SnackRecovery", trigger = "good", cue = "SnackRecovery", action = "fed recovery boosts", pressureRelief = 12, healthRepair = 6, distanceRelief = 4, cooldown = 7 },
            { id = "MallCop", trigger = "weak", cue = "MallCopStun", action = "stunned the crowd surge", pressureRelief = 24, healthRepair = 5, distanceRelief = 2, cooldown = 11, thresholdPressure = 58, thresholdHealth = 64 },
        },
    },
    moonbase_echo_dome = {
        targetBias = { attack = { "NE", "NW" }, creep = { "N", "SE" }, support = { "S", "SW" } },
        hazard = { cue = "GravitySlip", pressure = 21, healthDamage = 3, cooldown = 6, action = "gravity pulse slipped the lanes" },
        helpers = {
            { id = "AstroRoadie", boost = "LowGravityGrace", trigger = "weak", cue = "OrbitStabilize", action = "stabilized the oxygen relay", pressureRelief = 22, healthRepair = 8, distanceRelief = 3, cooldown = 10, thresholdPressure = 52, thresholdHealth = 70 },
            { id = "SatelliteSinger", boost = "EchoEncore", trigger = "streak", cue = "SatelliteEcho", action = "copied the perfect streak", pressureRelief = 18, healthRepair = 4, distanceRelief = 9, cooldown = 10, streak = 3 },
        },
    },
    pirate_radio_shipyard = {
        targetBias = { attack = { "W", "NW" }, creep = { "SW", "W" }, support = { "E", "SE" } },
        hazard = { cue = "SignalJam", pressure = 24, healthDamage = 5, cooldown = 5, action = "signal jammer hit the tower" },
        helpers = {
            { id = "CaptainGroanbeard", boost = "CrewShare", trigger = "good", cue = "CaptainCrewShare", action = "shared crew bonus pressure relief", pressureRelief = 18, healthRepair = 5, distanceRelief = 5, cooldown = 9 },
            { id = "DeckhandDJ", boost = "StormEncore", trigger = "weak", cue = "DeckhandCannon", action = "fired cannon pushback", pressureRelief = 30, healthRepair = 8, distanceRelief = 4, cooldown = 10, thresholdPressure = 55, thresholdHealth = 68 },
        },
    },
    doomscroll_data_center = {
        targetBias = { attack = { "E", "SE" }, creep = { "NE", "E" }, support = { "W", "NW" } },
        hazard = { cue = "HeatOverload", pressure = 23, healthDamage = 4, cooldown = 5, action = "viral heat overloaded the rack" },
        helpers = {
            { id = "FirewallAdmin", boost = "FirewallFreeze", trigger = "weak", cue = "FirewallFreeze", action = "froze the overloaded rack", pressureRelief = 30, healthRepair = 8, distanceRelief = 3, cooldown = 10, thresholdPressure = 54, thresholdHealth = 68 },
            { id = "CacheMedic", boost = "CooldownCache", trigger = "good", cue = "CacheRecovery", action = "purged popups into cooldown recovery", pressureRelief = 16, healthRepair = 5, distanceRelief = 6, cooldown = 8 },
        },
    },
}

local function biasForJudgement(mechanic, judgement)
    local targetBias = mechanic and mechanic.targetBias
    if not targetBias then
        return nil, nil
    end
    if judgement == "PassiveCreep" then
        return targetBias.creep or targetBias.attack, "creep"
    end
    if judgement == "Miss" then
        return targetBias.attack, "attack"
    end
    if judgement == "Perfect" or judgement == "Good" or judgement == "Audience" then
        return targetBias.support, "support"
    end
    return targetBias.attack, "default"
end

local function scoreSectorTarget(horde, sectorId, judgement, biasList)
    local health = horde.sectorHealths and horde.sectorHealths[sectorId] or 100
    local pressure = horde.sectorPressure and horde.sectorPressure[sectorId] or 0
    local score = (100 - health) * 0.72 + pressure * 0.68
    local reason = "balanced_pressure"

    if pressure >= 65 then
        score += 18
        reason = "pressure_hotspot"
    end
    if health <= 52 then
        score += 16
        reason = pressure >= 65 and "weak_pressure_hotspot" or "weak_sector"
    end
    if sectorId == horde.warningSectorId then
        score += 20
        reason = "warning_sector"
    end
    if listHasSector(biasList, sectorId) then
        score += 14
        reason = reason .. "_room_bias"
    end
    if judgement == "Miss" or judgement == "PassiveCreep" then
        score += pressure * 0.16
    elseif judgement == "Perfect" or judgement == "Good" or judgement == "Audience" then
        score += (100 - health) * 0.12
    end
    score += (9 - sectorOrdinal(sectorId)) * 0.01
    return score, reason
end

local function setTargeting(horde, sectorId, reason, score, biasName, judgement)
    horde.lastTargeting = {
        sectorId = sectorId,
        reason = reason,
        score = math.floor((score or 0) * 10 + 0.5) / 10,
        bias = biasName,
        judgement = judgement,
    }
end

local function helperReady(horde, helperId, cooldownSeconds)
    horde.helperCooldowns = horde.helperCooldowns or {}
    local nowTime = os.clock()
    local lastAt = horde.helperCooldowns[helperId] or -math.huge
    if nowTime - lastAt < cooldownSeconds then
        return false
    end
    horde.helperCooldowns[helperId] = nowTime
    return true
end

local function actionKindForCue(cueType)
    local cueName = tostring(cueType or "")
    if HAZARD_CUES[cueName] then
        return "hazard"
    end
    if PUSHBACK_CUES[cueName] then
        return "pushback"
    end
    if SUPPORT_CUES[cueName] then
        return "support"
    end
    if cueName == "Repair" then
        return "repair"
    end
    if cueName == "Perfect" or cueName == "Good" or cueName == "Audience" then
        return "beat"
    end
    if cueName == "Finish" then
        return "finish"
    end
    return "motion"
end

local function roundedTenths(value)
    return math.floor((value or 0) * 10 + 0.5) / 10
end

local function actionChoreography(cueType, kind, strength, details)
    local cueName = tostring(cueType or "")
    local actionKind = tostring(kind or actionKindForCue(cueType))
    local power = math.clamp(tonumber(strength) or 1, 0.7, 3.6)
    local isHazard = actionKind == "hazard"
    local isSupport = actionKind == "support" or actionKind == "pushback" or actionKind == "repair" or actionKind == "finish"
    local isFinisher = actionKind == "finish" or cueName == "Finish"
    local pathStyle = isHazard and "horde_lunge"
        or isFinisher and "full_ring_clear"
        or isSupport and "helper_pushback"
        or "beat_sway"
    local laneCount = isHazard and math.clamp(math.floor(power + 2.2), 2, 5)
        or isSupport and math.clamp(math.floor(power + 1.4), 1, 4)
        or 1
    local fromDistance = isHazard and (92 + power * 3)
        or isSupport and (38 - power)
        or 58
    local toDistance = isHazard and (50 - power * 5.5)
        or isSupport and (74 + power * 7.5)
        or 58
    local knockbackStuds = isHazard and (5 + power * 4.5) or 0
    local pushbackStuds = isSupport and (10 + power * 6) or 0
    local choreography = {
        pathStyle = pathStyle,
        laneCount = laneCount,
        laneSpacingStuds = roundedTenths(5 + power * 1.6),
        windupSeconds = roundedTenths(isHazard and math.max(0.18, 0.48 - power * 0.06) or 0.22),
        impactSeconds = roundedTenths(isHazard and math.max(0.12, 0.28 - power * 0.03) or 0.36),
        recoverSeconds = roundedTenths(isHazard and 0.34 or 0.44),
        beatIntensity = roundedTenths(power),
        fromDistance = roundedTenths(fromDistance),
        toDistance = roundedTenths(toDistance),
        ringRadius = roundedTenths(isHazard and toDistance or fromDistance + (toDistance - fromDistance) * 0.65),
        impactRadius = roundedTenths(14 + power * 6),
        knockbackStuds = roundedTenths(knockbackStuds),
        pushbackStuds = roundedTenths(pushbackStuds),
        comboWindow = roundedTenths(isHazard and math.max(0.32, 0.78 - power * 0.08) or 1.05),
    }
    for key, value in pairs(details or {}) do
        choreography[key] = value
    end
    return choreography
end

function HordeService:Init(runtimeContext)
    self.context = runtimeContext
    self.sessions = {}
end

function HordeService:_payload(session, horde, lastJudgement)
    local activeSectorId = horde.activeSectorId
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
        activeSectorId = activeSectorId,
        sectorPressure = horde.sectorPressure,
        activeSectorPressure = horde.sectorPressure and activeSectorId and horde.sectorPressure[activeSectorId] or 0,
        sectorAngles = horde.sectorAngles,
        warningSectorId = horde.warningSectorId,
        audienceAssist = horde.audienceAssist,
        movementCue = horde.movementCue,
        movementEventId = horde.movementEventId or 0,
        attackWave = horde.attackWave,
        helperEvent = horde.helperEvent,
        roomMechanicEvent = horde.roomMechanicEvent,
        roomHazard = horde.roomHazard,
        npcAction = horde.npcAction,
        targeting = horde.lastTargeting,
        targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
        roomId = session.roomId,
        roomName = session.roomName,
    }
end

function HordeService:_paintWorldSector(sectorId, health, pressure, cueType)
    local world = workspace:FindFirstChild("GTH_WorldV2")
    local sector = world and world:FindFirstChild("HordeSector_" .. tostring(sectorId), true)
    if not sector then return end
    sector:SetAttribute("Health", clampHealth(health))
    sector:SetAttribute("Pressure", math.clamp(pressure or 0, 0, 100))
    sector:SetAttribute("LastHordeCue", cueType or "State")
    sector:SetAttribute("LastHordeCueAt", os.clock())
    local urgent = (pressure or 0) >= 65 or (health or 100) <= 35 or cueType == "CrashSurge"
    local pushback = cueType == "PerfectPushback" or cueType == "SecurityRepair" or cueType == "AudienceHeatPushback" or cueType == "DJWarning"

    local fence = sector:FindFirstChild("FenceSegment")
    if fence and fence:IsA("BasePart") then
        if urgent then
            fence.Color = Color3.fromRGB(255, 45, 45)
        elseif pushback then
            fence.Color = Color3.fromRGB(95, 255, 180)
        else
            fence.Color = Color3.fromRGB(255, 135, 70)
        end
    end

    local vfx = sector:FindFirstChild("FenceDamageVFX")
    if vfx and vfx:IsA("BasePart") then
        vfx.Transparency = urgent and 0.05 or pushback and 0.18 or 0.45
        vfx.Color = pushback and Color3.fromRGB(80, 255, 180) or Color3.fromRGB(255, 80, 40)
    end

    local weak = sector:FindFirstChild("WeakPointMarker")
    if weak and weak:IsA("BasePart") then
        weak.Transparency = urgent and 0.02 or 0.32
        weak.Color = pushback and Color3.fromRGB(80, 255, 180) or Color3.fromRGB(255, 205, 60)
    end

    local meter = sector:FindFirstChild("HordePressureMeter")
    if meter and meter:IsA("BasePart") then
        meter:SetAttribute("Pressure", math.clamp(pressure or 0, 0, 100))
        meter.Size = Vector3.new(2 + math.clamp((pressure or 0) / 100, 0, 1) * 8, 1.1, 0.6)
        meter.Color = pushback and Color3.fromRGB(80, 255, 180) or Color3.fromRGB(255, 110, 40)
    end

    local security = sector:FindFirstChild("SecurityLight")
    local securityLight = security and security:FindFirstChildOfClass("PointLight")
    if securityLight then
        securityLight.Brightness = pushback and 5 or urgent and 3.5 or 1.2
        securityLight.Color = pushback and Color3.fromRGB(80, 255, 180) or Color3.fromRGB(150, 220, 255)
    end

    local siren = sector:FindFirstChild("SirenLight")
    local sirenLight = siren and siren:FindFirstChildOfClass("PointLight")
    if sirenLight then
        sirenLight.Brightness = urgent and 5 or 0
        sirenLight.Color = Color3.fromRGB(255, 35, 35)
    end
end

function HordeService:_paintWorldState(horde, cueType)
    if not horde or not horde.sectorHealths then return end
    for sectorId, health in pairs(horde.sectorHealths) do
        local pressure = horde.sectorPressure and horde.sectorPressure[sectorId] or 0
        self:_paintWorldSector(sectorId, health, pressure, sectorId == horde.activeSectorId and cueType or "State")
    end
end

function HordeService:_setHelperEvent(horde, helperId, action, sectorId, amount)
    horde.helperEventSerial = (horde.helperEventSerial or 0) + 1
    horde.helperEvent = {
        id = helperId,
        action = action,
        sectorId = sectorId,
        amount = amount,
        eventId = horde.helperEventSerial,
        startedAt = os.clock(),
        targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
    }
    if horde.npcAction then
        horde.npcAction.actorId = helperId
        horde.npcAction.action = action
        horde.npcAction.kind = SUPPORT_CUES[horde.npcAction.type] and "support" or horde.npcAction.kind
    end
end

function HordeService:_setRoomMechanicEvent(horde, roomId, cueType, action, sectorId, amount, helperId)
    horde.roomMechanicSerial = (horde.roomMechanicSerial or 0) + 1
    horde.roomMechanicEvent = {
        roomId = roomId,
        type = cueType,
        action = action,
        sectorId = sectorId,
        amount = amount,
        helperId = helperId,
        eventId = horde.roomMechanicSerial,
        startedAt = os.clock(),
        targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
    }
end

function HordeService:_setNpcAction(horde, cueType, sectorId, strength, details)
    horde.npcActionSerial = (horde.npcActionSerial or 0) + 1
    local kind = actionKindForCue(cueType)
    local choreography = actionChoreography(cueType, kind, strength, details)
    horde.npcAction = {
        eventId = horde.npcActionSerial,
        attackId = string.format("%s_%s_%d", tostring(cueType or "Action"), tostring(sectorId or horde.activeSectorId or "N"), horde.npcActionSerial),
        type = cueType,
        kind = kind,
        sectorId = sectorId or horde.activeSectorId,
        warningSectorId = horde.warningSectorId,
        strength = strength or 1,
        pathStyle = choreography.pathStyle,
        laneCount = choreography.laneCount,
        laneSpacingStuds = choreography.laneSpacingStuds,
        windupSeconds = choreography.windupSeconds,
        impactSeconds = choreography.impactSeconds,
        recoverSeconds = choreography.recoverSeconds,
        beatIntensity = choreography.beatIntensity,
        fromDistance = choreography.fromDistance,
        toDistance = choreography.toDistance,
        ringRadius = choreography.ringRadius,
        impactRadius = choreography.impactRadius,
        knockbackStuds = choreography.knockbackStuds,
        pushbackStuds = choreography.pushbackStuds,
        comboWindow = choreography.comboWindow,
        choreography = choreography,
        targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
        targetScore = horde.lastTargeting and horde.lastTargeting.score or nil,
        startedAt = os.clock(),
    }
    return horde.npcAction
end

function HordeService:_applyRoomHazard(session, horde, mechanic, sectorId)
    local hazard = mechanic and mechanic.hazard
    if not hazard or not helperReady(horde, "RoomHazard_" .. tostring(hazard.cue), hazard.cooldown or 6) then
        return false
    end
    local pressure = hazard.pressure or 0
    local damage = hazard.healthDamage or 0
    horde.sectorPressure[sectorId] = math.clamp((horde.sectorPressure[sectorId] or 0) + pressure, 0, 100)
    horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) - damage)
    horde.warningSectorId = sectorId
    horde.roomHazard = {
        roomId = session.roomId,
        type = hazard.cue,
        action = hazard.action,
        sectorId = sectorId,
        severity = pressure,
        pressure = horde.sectorPressure[sectorId],
        targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
    }
    horde.attackWave = {
        type = hazard.cue,
        sectorId = sectorId,
        severity = pressure,
        pressure = horde.sectorPressure[sectorId],
        targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
    }
    self:_setMovementCue(horde, hazard.cue, sectorId, math.clamp((pressure + damage) / 10, 1.0, 3.2))
    self:_setRoomMechanicEvent(horde, session.roomId, hazard.cue, hazard.action, sectorId, pressure, nil)
    self:_paintWorldSector(sectorId, horde.sectorHealths[sectorId], horde.sectorPressure[sectorId], hazard.cue)
    return true
end

local function roomHelperTriggered(helper, judgement, horde, weakHealth, weakPressure)
    if helper.trigger == "weak" then
        return weakHealth <= (helper.thresholdHealth or 70) or weakPressure >= (helper.thresholdPressure or 55)
    end
    if helper.trigger == "streak" then
        return judgement == "Perfect" and (horde.perfectStreak or 0) >= (helper.streak or 3)
    end
    if helper.trigger == "good" then
        return judgement == "Perfect" or judgement == "Good"
    end
    if helper.trigger == "miss" then
        return judgement == "Miss" or judgement == "PassiveCreep"
    end
    return false
end

function HordeService:_applyRoomMechanics(session, horde, judgement)
    local mechanic = session and ROOM_MECHANICS[session.roomId]
    if not mechanic or not horde then return end

    local activeSector = horde.activeSectorId or weakestSector(horde.sectorHealths)
    if judgement == "Miss" or judgement == "PassiveCreep" then
        self:_applyRoomHazard(session, horde, mechanic, activeSector)
    end

    local weak = weakestSector(horde.sectorHealths)
    local weakHealth = horde.sectorHealths[weak] or 100
    local weakPressure = horde.sectorPressure[weak] or 0
    for _, helper in ipairs(mechanic.helpers or {}) do
        if sessionHasHelper(session, helper.id)
            and (not helper.boost or sessionHasBoost(session, helper.boost))
            and roomHelperTriggered(helper, judgement, horde, weakHealth, weakPressure)
            and helperReady(horde, "RoomHelper_" .. helper.id, helper.cooldown or 9)
        then
            local sectorId = helper.trigger == "streak" and (horde.warningSectorId or activeSector) or weak
            local pressureRelief = helper.pressureRelief or 0
            local healthRepair = helper.healthRepair or 0
            local distanceRelief = helper.distanceRelief or 0
            horde.distance = clampDistance((horde.distance or 100) + distanceRelief)
            horde.sectorPressure[sectorId] = math.max(0, (horde.sectorPressure[sectorId] or 0) - pressureRelief)
            horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + healthRepair)
            horde.activeSectorId = sectorId
            horde.warningSectorId = weakestSector(horde.sectorHealths)
            local severity = math.max(distanceRelief, pressureRelief, healthRepair)
            setTargeting(horde, sectorId, "room_helper_" .. helper.id, severity, "helper", judgement)
            horde.attackWave = {
                type = helper.cue,
                sectorId = sectorId,
                severity = severity,
                pressure = horde.sectorPressure[sectorId],
                targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
            }
            self:_setMovementCue(horde, helper.cue, sectorId, math.clamp(severity / 8, 1.0, 3.0))
            self:_setHelperEvent(horde, helper.id, helper.action, sectorId, severity)
            self:_setRoomMechanicEvent(horde, session.roomId, helper.cue, helper.action, sectorId, severity, helper.id)
            self:_paintWorldSector(sectorId, horde.sectorHealths[sectorId], horde.sectorPressure[sectorId], helper.cue)
            return
        end
    end
end

function HordeService:_applyHelperNPCs(session, horde, judgement)
    if not horde then return end
    local weak = weakestSector(horde.sectorHealths)
    local weakHealth = horde.sectorHealths[weak] or 100
    local weakPressure = horde.sectorPressure[weak] or 0

    if sessionHasHelper(session, "SecurityManager") and (weakHealth <= 58 or weakPressure >= 70) and helperReady(horde, "SecurityManager", 8) then
        local repair = sessionHasBoost(session, "HordePushback") and 14 or 9
        horde.sectorHealths[weak] = clampHealth(weakHealth + repair)
        horde.sectorPressure[weak] = math.max(0, weakPressure - repair * 2)
        horde.warningSectorId = weakestSector(horde.sectorHealths)
        horde.activeSectorId = weak
        setTargeting(horde, weak, "helper_security_repair", repair, "helper", judgement)
        horde.attackWave = {
            type = "SecurityRepair",
            sectorId = weak,
            severity = repair,
            pressure = horde.sectorPressure[weak],
            targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
        }
        self:_setMovementCue(horde, "SecurityRepair", weak, math.clamp(repair / 7, 1.0, 2.8))
        self:_setHelperEvent(horde, "SecurityManager", "repaired weak fence", weak, repair)
        self:_paintWorldSector(weak, horde.sectorHealths[weak], horde.sectorPressure[weak], "SecurityRepair")
        return
    end

    if sessionHasHelper(session, "AudienceHypeManager") and sessionHasBoost(session, "AudienceHeat") and (session.stateData and (session.stateData.hype or 0) >= 65) and (judgement == "Perfect" or judgement == "Good") and helperReady(horde, "AudienceHypeManager", 10) then
        local sectorId = horde.warningSectorId or weak
        local relief = judgement == "Perfect" and 10 or 6
        horde.distance = clampDistance((horde.distance or 100) + relief)
        horde.sectorPressure[sectorId] = math.max(0, (horde.sectorPressure[sectorId] or 0) - relief * 2)
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + math.floor(relief / 2))
        horde.activeSectorId = sectorId
        setTargeting(horde, sectorId, "helper_audience_pushback", relief, "helper", judgement)
        horde.attackWave = {
            type = "AudienceHeatPushback",
            sectorId = sectorId,
            severity = relief,
            pressure = horde.sectorPressure[sectorId],
            targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
        }
        self:_setMovementCue(horde, "AudienceHeatPushback", sectorId, math.clamp(relief / 5, 1.0, 2.8))
        self:_setHelperEvent(horde, "AudienceHypeManager", "converted hype into pushback", sectorId, relief)
        self:_paintWorldSector(sectorId, horde.sectorHealths[sectorId], horde.sectorPressure[sectorId], "AudienceHeatPushback")
        return
    end

    if sessionHasHelper(session, "DJ_GroanMaster") and judgement == "Perfect" and (horde.perfectStreak or 0) >= 3 and helperReady(horde, "DJ_GroanMaster", 7) then
        local sectorId = horde.warningSectorId or weak
        local relief = 7
        horde.sectorPressure[sectorId] = math.max(0, (horde.sectorPressure[sectorId] or 0) - 14)
        horde.activeSectorId = sectorId
        horde.warningSectorId = sectorId
        setTargeting(horde, sectorId, "helper_dj_warning", relief, "helper", judgement)
        horde.attackWave = {
            type = "DJWarning",
            sectorId = sectorId,
            severity = relief,
            pressure = horde.sectorPressure[sectorId],
            targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
        }
        self:_setMovementCue(horde, "DJWarning", sectorId, 1.6)
        self:_setHelperEvent(horde, "DJ_GroanMaster", "called the weak sector", sectorId, relief)
        self:_paintWorldSector(sectorId, horde.sectorHealths[sectorId], horde.sectorPressure[sectorId], "DJWarning")
    end
end

function HordeService:_setMovementCue(horde, cueType, sectorId, strength, details)
    horde.movementEventId = (horde.movementEventId or 0) + 1
    local npcAction = self:_setNpcAction(horde, cueType, sectorId or horde.activeSectorId, strength or 1, details)
    horde.movementCue = {
        type = cueType,
        sectorId = sectorId or horde.activeSectorId,
        warningSectorId = horde.warningSectorId,
        strength = strength or 1,
        eventId = horde.movementEventId,
        npcActionEventId = npcAction and npcAction.eventId or nil,
        pathStyle = npcAction and npcAction.pathStyle or nil,
        laneCount = npcAction and npcAction.laneCount or nil,
        windupSeconds = npcAction and npcAction.windupSeconds or nil,
        impactSeconds = npcAction and npcAction.impactSeconds or nil,
        knockbackStuds = npcAction and npcAction.knockbackStuds or nil,
        pushbackStuds = npcAction and npcAction.pushbackStuds or nil,
        attackWave = horde.attackWave,
        targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
        targetScore = horde.lastTargeting and horde.lastTargeting.score or nil,
        startedAt = os.clock(),
    }
end

function HordeService:_broadcast(session, lastJudgement)
    local horde = self.sessions[session.id]
    if not horde or not self.context or not self.context.Remotes or not self.context.Remotes.HordeUpdate then
        return
    end
    horde.eventSerial = (horde.eventSerial or 0) + 1
    local payload = self:_payload(session, horde, lastJudgement)
    self.context.Remotes.HordeUpdate:FireAllClients(payload)
end

function HordeService:_pickActiveSector(session, horde, judgement)
    horde.step = (horde.step or 0) + 1
    if judgement == "Perfect" and horde.warningSectorId then
        setTargeting(horde, horde.warningSectorId, "perfect_pushback_warning", 100, "support", judgement)
        return horde.warningSectorId
    end
    local mechanic = session and ROOM_MECHANICS[session.roomId]
    local biasList, biasName = biasForJudgement(mechanic, judgement)
    local bestId = SECTORS[1].id
    local bestScore = -math.huge
    local bestReason = "round_robin_fallback"
    for _, sector in ipairs(SECTORS) do
        local score, reason = scoreSectorTarget(horde, sector.id, judgement, biasList)
        if score > bestScore then
            bestId = sector.id
            bestScore = score
            bestReason = reason
        end
    end
    if bestScore < 1 then
        local index = ((horde.step - 1) % #SECTORS) + 1
        bestId = SECTORS[index].id
        bestReason = "round_robin_fallback"
    end
    setTargeting(horde, bestId, bestReason, bestScore, biasName, judgement)
    return bestId
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
        step = 0,
        eventSerial = 0,
        attackWave = nil,
        helperEvent = nil,
        roomMechanicEvent = nil,
        roomHazard = nil,
        npcAction = nil,
        movementCue = { type = "Start", strength = 1, eventId = 0 },
        audienceAssist = nil,
    }
    session.hordeDistance = 100
    session.hordeState = "Far"
    session.sectorHealths = healths
    session.activeSectorId = "N"
    self:_broadcast(session, "Start")
end

function HordeService:_applySectorJudgement(session, horde, judgement, delta)
    local sectorId = self:_pickActiveSector(session, horde, judgement)
    horde.activeSectorId = sectorId
    horde.sectorPressure[sectorId] = math.clamp((horde.sectorPressure[sectorId] or 0) + pressureForCue(judgement, horde.sectorPressure[sectorId]), 0, 100)
    if judgement == "Miss" then
        horde.perfectStreak = 0
        local severity = math.max(6, math.abs(delta or 8))
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) - severity)
        horde.attackWave = {
            type = "CrashSurge",
            sectorId = sectorId,
            severity = severity,
            pressure = horde.sectorPressure[sectorId],
            targetReason = horde.lastTargeting and horde.lastTargeting.reason or nil,
        }
    elseif judgement == "Perfect" then
        horde.perfectStreak = (horde.perfectStreak or 0) + 1
        local pushbackBoost = sessionHasBoost(session, "HordePushback")
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + (pushbackBoost and 6 or 3))
        horde.sectorPressure[sectorId] = math.max(0, (horde.sectorPressure[sectorId] or 0) - (pushbackBoost and 16 or 8))
        horde.attackWave = pushbackBoost and {
            type = "PerfectPushback",
            sectorId = sectorId,
            severity = 10 + (horde.perfectStreak or 0),
            pressure = horde.sectorPressure[sectorId],
        } or nil
        if horde.perfectStreak >= 5 then
            local weak = weakestSector(horde.sectorHealths)
            horde.sectorHealths[weak] = clampHealth((horde.sectorHealths[weak] or 100) + (pushbackBoost and 16 or 10))
            horde.warningSectorId = nil
            horde.perfectStreak = 0
        end
    elseif judgement == "Good" or judgement == "Audience" then
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + 1)
        horde.attackWave = nil
    end
    horde.warningSectorId = weakestSector(horde.sectorHealths)
    if judgement == "Miss" then
        horde.warningSectorId = sectorId
    end
    local cueName = judgement
    if judgement == "Perfect" and horde.attackWave and horde.attackWave.type == "PerfectPushback" then
        cueName = "PerfectPushback"
    end
    local cueStrength = math.clamp(math.abs(delta or 1) / 7, 0.9, 3.2)
    self:_setMovementCue(horde, cueName, sectorId, cueStrength)
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
    horde.audienceAssist = nil
    horde.helperEvent = nil
    horde.roomMechanicEvent = nil
    horde.roomHazard = nil
    horde.npcAction = nil
    local delta = ACTIONS[judgement] or 0
    if judgement == "Miss" then
        local diff = session.difficultyConfig or Config.Difficulties[session.difficulty or "Easy"] or Config.Difficulties.Easy
        delta = -(diff.hordeMissAdvance or diff.hpDamageMiss or 8)
        local focusLevel = session.modifiers and tonumber(session.modifiers.focusReduction) or 0
        if focusLevel > 0 then
            delta = math.ceil(delta * (1 - math.min(0.25, focusLevel * 0.04)))
        end
    elseif judgement == "Perfect" and sessionHasBoost(session, "HordePushback") then
        delta += 4
    elseif judgement == "Good" and sessionHasBoost(session, "HordePushback") then
        delta += 2
    end
    horde.distance = clampDistance((horde.distance or 100) + delta)
    horde.lastJudgement = judgement
    horde.disasterMode = horde.distance <= 0
    self:_applySectorJudgement(session, horde, judgement, delta)
    self:_applyRoomMechanics(session, horde, judgement)
    self:_applyHelperNPCs(session, horde, judgement)
    session.hordeDistance = horde.distance
    session.hordeState = stateFor(horde.distance)
    session.disasterMode = horde.disasterMode
    local visualCue = horde.attackWave and horde.attackWave.type or judgement
    self:_paintWorldState(horde, visualCue)
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
    local assistSectorId = horde.warningSectorId or weakestSector(horde.sectorHealths)
    horde.helperEvent = nil
    horde.roomMechanicEvent = nil
    horde.roomHazard = nil
    horde.npcAction = nil
    horde.distance = clampDistance((horde.distance or 100) + (amount or ACTIONS.Audience))
    horde.lastJudgement = action or "Audience"
    self:_applySectorJudgement(session, horde, "Audience", amount or ACTIONS.Audience)
    if action == "Support" or action == "Encore" then
        local sectorId = assistSectorId
        local relief = math.max(3, amount or ACTIONS.Audience)
        horde.sectorHealths[sectorId] = clampHealth((horde.sectorHealths[sectorId] or 100) + relief)
        horde.sectorPressure[sectorId] = math.max(0, (horde.sectorPressure[sectorId] or 0) - (12 + relief * 2))
        horde.activeSectorId = sectorId
        horde.warningSectorId = weakestSector(horde.sectorHealths)
        horde.audienceAssist = {
            action = action,
            sectorId = sectorId,
            relief = relief,
        }
        horde.attackWave = {
            type = action == "Encore" and "EncorePushback" or "AudiencePushback",
            sectorId = sectorId,
            severity = relief,
            pressure = horde.sectorPressure[sectorId],
        }
        self:_setMovementCue(horde, action == "Encore" and "AudienceEncore" or "AudienceSupport", sectorId, math.clamp(relief / 3, 0.9, 2.5))
    else
        horde.audienceAssist = nil
        horde.attackWave = nil
    end
    session.hordeDistance = horde.distance
    session.hordeState = stateFor(horde.distance)
    local visualCue = horde.attackWave and horde.attackWave.type or action or "Audience"
    self:_paintWorldState(horde, visualCue)
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
                    local sectorId = self:_pickActiveSector(session, horde, "PassiveCreep")
                    horde.activeSectorId = sectorId
                    horde.sectorPressure[sectorId] = math.clamp((horde.sectorPressure[sectorId] or 0) + math.max(8, horde.passiveBank * 2.5), 0, 100)
                    self:_setMovementCue(horde, "PassiveCreep", sectorId, 1.15)
                    horde.passiveBank = 0
                    horde.audienceAssist = nil
                    horde.helperEvent = nil
                    horde.roomMechanicEvent = nil
                    horde.roomHazard = nil
                    horde.npcAction = nil
                    self:_applyRoomMechanics(session, horde, "PassiveCreep")
                    self:_applyHelperNPCs(session, horde, "PassiveCreep")
                    session.hordeDistance = horde.distance
                    session.hordeState = stateFor(horde.distance)
                    session.disasterMode = horde.distance <= 0
                    local visualCue = horde.attackWave and horde.attackWave.type or "PassiveCreep"
                    self:_paintWorldState(horde, visualCue)
                    self:_broadcast(session, "PassiveCreep")
                end
            end
        end
    end
end

function HordeService:FinishSession(session)
    if session and self.sessions[session.id] then
        local horde = self.sessions[session.id]
        horde.audienceAssist = nil
        horde.helperEvent = nil
        horde.roomMechanicEvent = nil
        horde.roomHazard = nil
        horde.npcAction = nil
        horde.distance = clampDistance((horde.distance or 100) + 12)
        for _, sector in ipairs(SECTORS) do
            horde.sectorHealths[sector.id] = clampHealth((horde.sectorHealths[sector.id] or 100) + 8)
            horde.sectorPressure[sector.id] = math.max(0, (horde.sectorPressure[sector.id] or 0) - 32)
        end
        horde.activeSectorId = horde.warningSectorId or horde.activeSectorId
        self:_setMovementCue(horde, "Finish", horde.activeSectorId, 2.2)
        self:_paintWorldState(horde, "Finish")
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
        horde.audienceAssist = nil
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
