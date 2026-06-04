local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local function setModelPrimaryPart(model)
    if not model or not model:IsA("Model") or model.PrimaryPart then return end
    local firstPart = model:FindFirstChildWhichIsA("BasePart", true)
    if firstPart then model.PrimaryPart = firstPart end
end

local function getSector(sectorId)
    local world = workspace:FindFirstChild("GTH_WorldV2")
    local ring = world and world:FindFirstChild("HordeRing")
    return ring and ring:FindFirstChild("HordeSector_" .. tostring(sectorId or "N")) or nil
end

local function getCluster(sectorId)
    local sector = getSector(sectorId)
    local cluster = sector and sector:FindFirstChild("HordeCluster")
    if cluster and cluster:IsA("Model") then setModelPrimaryPart(cluster) end
    return cluster
end

local function fallbackHordePoints()
    local world = workspace:FindFirstChild("GTH_WorldV2")
    local hitboxes = world and world:FindFirstChild("InvisibleGameplayHitboxes")
    return world, hitboxes
end

local gui = Instance.new("ScreenGui")
gui.Name = "HordeGui"
gui.IgnoreGuiInset = false
gui.ResetOnSpawn = false
gui.Parent = playerGui

local meter = Instance.new("Frame")
meter.Name = "HordeMeter"
meter.AnchorPoint = Vector2.new(0, 0)
meter.Position = UDim2.new(0, 16, 0, 96)
meter.Size = UDim2.new(0, 300, 0, 54)
meter.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
meter.BackgroundTransparency = 0.08
meter.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = meter
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(95, 255, 105)
stroke.Thickness = 2
stroke.Parent = meter

local label = Instance.new("TextLabel")
label.BackgroundTransparency = 1
label.Position = UDim2.new(0, 10, 0, 3)
label.Size = UDim2.new(1, -20, 0, 24)
label.Text = "Brainrot Horde: Far"
label.TextColor3 = Color3.fromRGB(235, 255, 235)
label.Font = Enum.Font.GothamBlack
label.TextScaled = true
label.Parent = meter

local back = Instance.new("Frame")
back.Position = UDim2.new(0, 12, 1, -20)
back.Size = UDim2.new(1, -24, 0, 10)
back.BackgroundColor3 = Color3.fromRGB(45, 40, 50)
back.Parent = meter
local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 6)
backCorner.Parent = back
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
fill.Parent = back
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 6)
fillCorner.Parent = fill

local currentTweens = {}
local idleBases = {}
local clusterCache = {}
local lastClusterScan = 0
local lastNpcActionEventId = nil

local ROOM_HAZARD_CUES = {
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

local ROOM_SUPPORT_CUES = {
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

local function colorForCue(cue)
    local cueName = type(cue) == "table" and cue.type or cue
    if cueName == "Miss" or cueName == "PassiveCreep" or cueName == "CrashSurge" or ROOM_HAZARD_CUES[cueName] then
        return Color3.fromRGB(255, 65, 45)
    elseif cueName == "PerfectPushback" or cueName == "AudiencePushback" or cueName == "EncorePushback" or cueName == "AudienceHeatPushback" or cueName == "SecurityRepair" or cueName == "DJWarning" or ROOM_SUPPORT_CUES[cueName] then
        return Color3.fromRGB(120, 255, 255)
    elseif cueName == "Repair" then
        return Color3.fromRGB(80, 255, 140)
    elseif cueName == "AudienceSupport" or cueName == "AudienceEncore" then
        return Color3.fromRGB(120, 255, 190)
    elseif cueName == "Finish" then
        return Color3.fromRGB(120, 255, 255)
    elseif cueName == "Perfect" then
        return Color3.fromRGB(95, 255, 120)
    elseif cueName == "Good" or cueName == "Audience" then
        return Color3.fromRGB(90, 210, 255)
    end
    return Color3.fromRGB(255, 130, 35)
end

local function cueType(payload)
    local cue = type(payload.movementCue) == "table" and payload.movementCue or nil
    return cue and cue.type or payload.lastJudgement
end

local function cueStrength(payload)
    local cue = type(payload.movementCue) == "table" and payload.movementCue or nil
    return math.clamp(tonumber(cue and cue.strength) or 1, 0.7, 2.5)
end

local function cueRadiusOffset(cueName, strength)
    local scale = strength or 1
    if cueName == "Miss" or cueName == "PassiveCreep" or cueName == "CrashSurge" or ROOM_HAZARD_CUES[cueName] then return -18 * scale end
    if cueName == "PerfectPushback" or cueName == "AudienceHeatPushback" then return 18 * scale end
    if cueName == "AudiencePushback" or cueName == "EncorePushback" or ROOM_SUPPORT_CUES[cueName] then return 20 * scale end
    if cueName == "SecurityRepair" or cueName == "DJWarning" then return 14 * scale end
    if cueName == "Repair" or cueName == "AudienceSupport" then return 10 * scale end
    if cueName == "AudienceEncore" then return 16 * scale end
    if cueName == "Finish" then return 24 * scale end
    if cueName == "Perfect" then return 12 * scale end
    if cueName == "Good" or cueName == "Audience" then return 7 * scale end
    return 0
end

local function addMovementCue(sector, judgement, strength, warningOnly)
    if not sector then return end
    local marker = sector:FindFirstChild("HordeMotionCue")
    if not marker then
        marker = Instance.new("Part")
        marker.Name = "HordeMotionCue"
        marker.Anchored = true
        marker.CanCollide = false
        marker.Shape = Enum.PartType.Ball
        marker.Material = Enum.Material.Neon
        marker.Size = Vector3.new(5, 5, 5)
        marker:SetAttribute("AuditedArtAsset", true)
        marker:SetAttribute("AssetSourcePath", "ProjectOwned/HordeMotionCue")
        marker:SetAttribute("PlacementCategory", "hordeRing")
        marker.Parent = sector
    end
    local angle = tonumber(sector:GetAttribute("AngleDeg")) or 90
    local PolarLayout = require(ReplicatedStorage.Shared.WorldV2.PolarLayout)
    marker.CFrame = PolarLayout.cframeFacingCenter(58, angle, 7)
    marker.Transparency = warningOnly and 0.25 or 0.08
    marker.Color = warningOnly and Color3.fromRGB(255, 205, 60)
        or judgement == "Repair" and Color3.fromRGB(80, 255, 140)
        or judgement == "PerfectPushback" and Color3.fromRGB(120, 255, 255)
        or judgement == "Finish" and Color3.fromRGB(120, 255, 255)
        or judgement == "Miss" and Color3.fromRGB(255, 45, 45)
        or judgement == "PassiveCreep" and Color3.fromRGB(255, 120, 35)
        or Color3.fromRGB(90, 210, 255)
    local pulseSize = warningOnly and 9 or (12 + 4 * (strength or 1))
    TweenService:Create(marker, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), { Size = Vector3.new(pulseSize, pulseSize, pulseSize), Transparency = warningOnly and 0.65 or 0.5 }):Play()
end

local function actionPart(sector, name, shape)
    if not sector then return nil end
    local marker = sector:FindFirstChild(name)
    if not (marker and marker:IsA("BasePart")) then
        if marker then marker:Destroy() end
        marker = Instance.new("Part")
        marker.Name = name
        marker.Anchored = true
        marker.CanCollide = false
        marker.Material = Enum.Material.Neon
        marker:SetAttribute("AuditedArtAsset", true)
        marker:SetAttribute("AssetSourcePath", "ProjectOwned/" .. name)
        marker:SetAttribute("PlacementCategory", "hordeRing")
        marker.Parent = sector
    end
    if shape then marker.Shape = shape end
    return marker
end

local function sectorCFrame(sectorId, radius, height)
    local sector = getSector(sectorId)
    local angle = tonumber(sector and sector:GetAttribute("AngleDeg")) or 90
    local PolarLayout = require(ReplicatedStorage.Shared.WorldV2.PolarLayout)
    return PolarLayout.cframeFacingCenter(radius, angle, height or 5)
end

local function actionNumber(action, key, fallback, minimum, maximum)
    local value = tonumber(type(action) == "table" and action[key] or nil) or fallback
    if minimum ~= nil and maximum ~= nil then
        return math.clamp(value, minimum, maximum)
    elseif minimum ~= nil then
        return math.max(value, minimum)
    elseif maximum ~= nil then
        return math.min(value, maximum)
    end
    return value
end

local function actionInteger(action, key, fallback, minimum, maximum)
    return math.floor(actionNumber(action, key, fallback, minimum, maximum) + 0.5)
end

local function offsetSectorCFrame(sectorId, radius, height, lateralOffset)
    return sectorCFrame(sectorId, radius, height) * CFrame.new(lateralOffset or 0, 0, 0)
end

local function renderNpcAction(payload)
    local action = type(payload.npcAction) == "table" and payload.npcAction or nil
    if not action then return end
    local eventId = action.eventId or payload.movementEventId
    if eventId == lastNpcActionEventId then return end
    lastNpcActionEventId = eventId

    local sectorId = action.sectorId or payload.activeSectorId or "N"
    local sector = getSector(sectorId)
    if not sector then return end
    local strength = math.clamp(tonumber(action.strength) or cueStrength(payload), 0.8, 3.4)
    local kind = tostring(action.kind or "motion")
    local color = colorForCue(action.type or payload.movementCue or payload.lastJudgement)
    local isAttack = kind == "hazard"
    local isSupport = kind == "support" or kind == "pushback" or kind == "repair" or kind == "finish"
    local pathStyle = tostring(action.pathStyle or (isAttack and "horde_lunge" or isSupport and "helper_pushback" or "beat_sway"))
    local laneCount = actionInteger(action, "laneCount", isAttack and 3 or 1, 1, 5)
    local laneSpacing = actionNumber(action, "laneSpacingStuds", 6, 3, 14)
    local windupSeconds = actionNumber(action, "windupSeconds", isAttack and 0.28 or 0.2, 0.08, 0.8)
    local impactSeconds = actionNumber(action, "impactSeconds", isAttack and 0.18 or 0.32, 0.08, 0.8)
    local recoverSeconds = actionNumber(action, "recoverSeconds", 0.38, 0.1, 1.1)
    local originRadius = actionNumber(action, "fromDistance", isAttack and 92 or 42, 28, 120)
    local targetRadius = actionNumber(action, "toDistance", isAttack and 42 or 86, 28, 120)
    local ringRadius = actionNumber(action, "ringRadius", isAttack and targetRadius or (originRadius + targetRadius) / 2, 28, 120)
    local impactRadius = actionNumber(action, "impactRadius", 18 + strength * 5, 10, 42)
    local laneDuration = windupSeconds + impactSeconds + recoverSeconds

    local telegraph = actionPart(sector, "HordeActionTelegraphRing", Enum.PartType.Cylinder)
    if telegraph then
        telegraph.Color = color
        telegraph.CFrame = sectorCFrame(sectorId, ringRadius, 4.05)
        telegraph.Size = Vector3.new(impactRadius * 0.55, 0.18, impactRadius * 0.55)
        telegraph.Transparency = isAttack and 0.18 or 0.28
        TweenService:Create(telegraph, TweenInfo.new(windupSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(impactRadius, 0.18, impactRadius),
            Transparency = isAttack and 0.48 or 0.62,
        }):Play()
        task.delay(laneDuration, function()
            if telegraph.Parent then telegraph.Transparency = 1 end
        end)
    end

    local shockwave = actionPart(sector, "HordeActionShockwave", Enum.PartType.Cylinder)
    if shockwave then
        shockwave.Color = color
        shockwave.CFrame = sectorCFrame(sectorId, ringRadius, 4.2)
        shockwave.Size = Vector3.new(7 + strength, 0.25, 7 + strength)
        shockwave.Transparency = 0.08
        local waveSize = impactRadius + strength * 7
        task.delay(windupSeconds, function()
            if not shockwave.Parent then return end
            shockwave.Transparency = 0.05
            TweenService:Create(shockwave, TweenInfo.new(impactSeconds + recoverSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = Vector3.new(waveSize, 0.25, waveSize),
                Transparency = 0.82,
            }):Play()
        end)
    end

    for laneIndex = 1, laneCount do
        local laneOffset = (laneIndex - ((laneCount + 1) / 2)) * laneSpacing
        local beam = actionPart(sector, (isSupport and "HordeHelperBeam_" or "HordeAttackLane_") .. laneIndex)
        if beam then
            local from = offsetSectorCFrame(sectorId, originRadius, 5.2, laneOffset).Position
            local to = offsetSectorCFrame(sectorId, targetRadius, 5.2, laneOffset).Position
            local midpoint = (from + to) / 2
            local length = (from - to).Magnitude
            beam.Color = color
            beam.Size = Vector3.new(isSupport and 1.2 or 1.6 + strength * 0.18, isSupport and 0.7 or 0.95, length)
            beam.CFrame = CFrame.lookAt(midpoint, to)
            beam.Transparency = isAttack and 0.08 or 0.16
            TweenService:Create(beam, TweenInfo.new(laneDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = 1,
                Size = Vector3.new(0.2, 0.2, length),
            }):Play()
        end
    end

    local actor = actionPart(sector, "HordeActionActorBeacon", Enum.PartType.Ball)
    if actor then
        actor.Color = color
        actor.CFrame = sectorCFrame(sectorId, originRadius, 7.4)
        actor.Size = Vector3.new(3.8, 3.8, 3.8)
        actor.Transparency = 0.05
        actor:SetAttribute("LastNpcActionType", tostring(action.type or ""))
        actor:SetAttribute("LastNpcActionKind", kind)
        actor:SetAttribute("LastNpcActionActorId", tostring(action.actorId or "horde"))
        actor:SetAttribute("LastNpcActionPathStyle", pathStyle)
        local actorTarget = offsetSectorCFrame(sectorId, targetRadius, 7.4, math.sin((tonumber(action.eventId) or 0) * 1.7) * laneSpacing * 0.25)
        TweenService:Create(actor, TweenInfo.new(windupSeconds + impactSeconds, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            CFrame = actorTarget,
            Size = Vector3.new(6.4 + strength, 6.4 + strength, 6.4 + strength),
            Transparency = isAttack and 0.24 or 0.16,
        }):Play()
        task.delay(windupSeconds + impactSeconds, function()
            if not actor.Parent then return end
            TweenService:Create(actor, TweenInfo.new(recoverSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = isAttack and 0.58 or 0.42,
            }):Play()
        end)
    end
end

local function tweenCluster(cluster, distance, sectorId, payload)
    if not cluster or not cluster:IsA("Model") then return end
    local sector = getSector(sectorId)
    local angle = tonumber(sector and sector:GetAttribute("AngleDeg")) or 90
    local alpha = math.clamp((distance or 100) / 100, 0, 1)
    local pressure = sector and tonumber(sector:GetAttribute("Pressure")) or 0
    local cueName = type(payload) == "table" and cueType(payload) or nil
    local strength = type(payload) == "table" and cueStrength(payload) or 1
    local wave = type(payload) == "table" and type(payload.attackWave) == "table" and payload.attackWave or nil
    local npcAction = type(payload) == "table" and type(payload.npcAction) == "table" and payload.npcAction or nil
    if wave and wave.type == "CrashSurge" then
        strength = math.max(strength, math.clamp((tonumber(wave.severity) or 8) / 7, 1.4, 3.4))
        cueName = "CrashSurge"
    elseif wave and (wave.type == "PerfectPushback" or wave.type == "AudiencePushback" or wave.type == "EncorePushback" or wave.type == "AudienceHeatPushback" or wave.type == "SecurityRepair" or wave.type == "DJWarning") then
        strength = math.max(strength, math.clamp((tonumber(wave.severity) or 8) / 6, 1.4, 3.4))
        cueName = wave.type
    end
    local radius = 48 + alpha * 34 - math.clamp(pressure / 100, 0, 1) * 10 + cueRadiusOffset(cueName, strength)
    if npcAction and npcAction.kind == "hazard" then
        local targetDistance = tonumber(npcAction.toDistance)
        local knockbackStuds = tonumber(npcAction.knockbackStuds) or 0
        radius = math.min(radius, targetDistance or radius)
        radius -= knockbackStuds * 0.45
    elseif npcAction and (npcAction.kind == "support" or npcAction.kind == "pushback" or npcAction.kind == "repair") then
        local targetDistance = tonumber(npcAction.toDistance)
        local pushbackStuds = tonumber(npcAction.pushbackStuds) or 0
        radius = math.max(radius, targetDistance or radius)
        radius += pushbackStuds * 0.32
    end
    radius = math.clamp(radius, 30, 112)
    local PolarLayout = require(ReplicatedStorage.Shared.WorldV2.PolarLayout)
    local target = PolarLayout.cframeFacingCenter(radius, angle, 3)
    if npcAction then
        local laneSpacing = tonumber(npcAction.laneSpacingStuds) or 5
        local strafe = math.sin((tonumber(npcAction.eventId) or 0) * 1.7) * math.clamp(strength, 0.8, 3) * laneSpacing * 0.28
        target = target * CFrame.new(strafe, 0, 0)
    end
    if currentTweens[cluster] then currentTweens[cluster]:Cancel() end
    local value = Instance.new("CFrameValue")
    value.Value = cluster:GetPivot()
    local conn
    conn = value:GetPropertyChangedSignal("Value"):Connect(function()
        if cluster.Parent then cluster:PivotTo(value.Value) end
    end)
    local windupSeconds = npcAction and tonumber(npcAction.windupSeconds) or nil
    local impactSeconds = npcAction and tonumber(npcAction.impactSeconds) or nil
    local tweenTime = windupSeconds and impactSeconds and math.clamp(windupSeconds + impactSeconds, 0.16, 0.9)
        or cueName == "Finish" and 0.48
        or cueName == "CrashSurge" and 0.16
        or 0.2
    local easingStyle = npcAction and npcAction.pathStyle == "helper_pushback" and Enum.EasingStyle.Quad or Enum.EasingStyle.Back
    local tween = TweenService:Create(value, TweenInfo.new(tweenTime, easingStyle), { Value = target })
    currentTweens[cluster] = tween
    tween.Completed:Connect(function()
        if conn then conn:Disconnect() end
        value:Destroy()
        currentTweens[cluster] = nil
        idleBases[cluster] = target
    end)
    tween:Play()
end

local function updateSectorVisuals(payload)
    if type(payload.sectorHealths) ~= "table" then return end
    local activeSectorId = tostring(payload.activeSectorId or "")
    local warningSectorId = tostring(payload.warningSectorId or "")
    for sectorId, health in pairs(payload.sectorHealths) do
        local sector = getSector(sectorId)
        if sector then
            local pressure = payload.sectorPressure and payload.sectorPressure[sectorId] or (100 - (health or 100))
            local active = sectorId == payload.activeSectorId
            local warning = sectorId == payload.warningSectorId
            sector:SetAttribute("Health", health)
            local pressure = payload.sectorPressure and payload.sectorPressure[sectorId] or (100 - (health or 100))
            sector:SetAttribute("Pressure", pressure)
            sector:SetAttribute("HordeActive", tostring(sectorId) == activeSectorId)
            sector:SetAttribute("HordeWarning", tostring(sectorId) == warningSectorId)
            local fence = sector:FindFirstChild("FenceSegment")
            if fence and fence:IsA("BasePart") then
                local t = math.clamp((health or 100) / 100, 0, 1)
                if active then
                    fence.Color = colorForCue(payload.movementCue or payload.lastJudgement)
                elseif warning then
                    fence.Color = Color3.fromRGB(255, 45, 75)
                else
                    fence.Color = Color3.fromRGB(255 - math.floor(160 * t), 80 + math.floor(175 * t), 80)
                end
            end
            local siren = sector:FindFirstChild("SirenLight")
            local light = siren and siren:FindFirstChildOfClass("PointLight")
            if light then
                light.Brightness = (tostring(sectorId) == warningSectorId or (health or 100) < 35) and 5 or 0
                light.Color = tostring(sectorId) == activeSectorId and Color3.fromRGB(255, 130, 35) or Color3.fromRGB(255, 35, 35)
            end
            local vfx = sector:FindFirstChild("FenceDamageVFX")
            if vfx and vfx:IsA("BasePart") then
                vfx.Transparency = (tostring(sectorId) == activeSectorId or (health or 100) < 60) and 0.12 or 0.75
                vfx.Color = tostring(sectorId) == warningSectorId and Color3.fromRGB(255, 180, 45) or Color3.fromRGB(255, 80, 40)
            end
            local weak = sector:FindFirstChild("WeakPointMarker")
            if weak and weak:IsA("BasePart") then
                weak.Color = tostring(sectorId) == warningSectorId and Color3.fromRGB(255, 205, 60) or Color3.fromRGB(255, 80, 80)
                weak.Transparency = tostring(sectorId) == warningSectorId and 0.05 or 0.35
            end
            local meterPart = sector:FindFirstChild("HordePressureMeter")
            if meterPart and meterPart:IsA("BasePart") then
                meterPart.Size = Vector3.new(2 + math.clamp(pressure / 100, 0, 1) * 8, 1.1, 0.6)
                meterPart.Color = tostring(sectorId) == activeSectorId and Color3.fromRGB(255, 125, 35) or Color3.fromRGB(255, 55, 55)
            end
        end
    end
end

local function pulse(color)
    meter.BackgroundColor3 = color
    TweenService:Create(meter, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(12, 14, 28) }):Play()
end

local function scanClusters()
    local world = workspace:FindFirstChild("GTH_WorldV2")
    local ring = world and world:FindFirstChild("HordeRing")
    if not ring then return end
    table.clear(clusterCache)
    for _, sector in ipairs(ring:GetChildren()) do
        local cluster = sector:FindFirstChild("HordeCluster")
        if cluster and cluster:IsA("Model") then
            setModelPrimaryPart(cluster)
            table.insert(clusterCache, cluster)
            idleBases[cluster] = idleBases[cluster] or cluster:GetPivot()
        end
    end
end

RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastClusterScan > 2 then
        lastClusterScan = now
        scanClusters()
    end
    for index, cluster in ipairs(clusterCache) do
        if cluster.Parent and not currentTweens[cluster] then
            local base = idleBases[cluster] or cluster:GetPivot()
            local bob = math.sin(now * 2.8 + index * 0.73) * 0.32
            local sway = math.sin(now * 1.7 + index) * math.rad(1.2)
            cluster:PivotTo(base * CFrame.new(0, bob, 0) * CFrame.Angles(0, sway, 0))
        end
    end
end)


if remotes:FindFirstChild("HordeUpdate") then
    remotes.HordeUpdate.OnClientEvent:Connect(function(payload)
        if type(payload) ~= "table" then return end
        local distance = tonumber(payload.distance) or 100
        local state = payload.state or "Far"
        local sectorId = payload.activeSectorId or "N"
        local warningSectorId = payload.warningSectorId or sectorId
        local pressure = tonumber(payload.activeSectorPressure) or (payload.sectorPressure and payload.sectorPressure[sectorId]) or 0
        local assist = type(payload.audienceAssist) == "table" and payload.audienceAssist or nil
        local helper = type(payload.helperEvent) == "table" and payload.helperEvent or nil
        local roomMechanic = type(payload.roomMechanicEvent) == "table" and payload.roomMechanicEvent or nil
        local roomHazard = type(payload.roomHazard) == "table" and payload.roomHazard or nil
        label.Text = helper and string.format("%s: %s at %s", tostring(helper.id), tostring(helper.action), tostring(helper.sectorId))
            or roomMechanic and string.format("%s: %s at %s", tostring(roomMechanic.type), tostring(roomMechanic.action), tostring(roomMechanic.sectorId))
            or roomHazard and string.format("%s: %s at %s", tostring(roomHazard.type), tostring(roomHazard.action), tostring(roomHazard.sectorId))
            or assist and string.format("Brainrot Horde: %s  %d%%  Audience repaired %s", state, math.floor(distance + 0.5), tostring(assist.sectorId))
            or string.format("Brainrot Horde: %s  %d%%  Sector %s  Weak %s", state, math.floor(distance + 0.5), sectorId, warningSectorId)
        fill.Size = UDim2.fromScale(1 - math.clamp(distance / 100, 0, 1), 1)
        fill.BackgroundColor3 = payload.disasterMode and Color3.fromRGB(255, 45, 75) or pressure > 55 and Color3.fromRGB(255, 120, 55) or Color3.fromRGB(255, 80, 80)
        stroke.Color = colorForCue(payload.movementCue or payload.lastJudgement)
        updateSectorVisuals(payload)
        renderNpcAction(payload)
        local sector = getSector(sectorId)
        local judgement = cueType(payload)
        local strength = cueStrength(payload)
        addMovementCue(sector, judgement, strength, false)
        if payload.warningSectorId and payload.warningSectorId ~= sectorId then
            addMovementCue(getSector(payload.warningSectorId), "Warning", 0.8, true)
        end
        local cluster = getCluster(sectorId)
        if cluster then
            tweenCluster(cluster, distance, sectorId, payload)
        else
            fallbackHordePoints()
        end
        if judgement == "Miss" or judgement == "PassiveCreep" or ROOM_HAZARD_CUES[judgement] or payload.disasterMode then
            pulse(Color3.fromRGB(120, 25, 35))
        elseif judgement == "Perfect" or judgement == "Repair" or judgement == "Finish" then
            pulse(Color3.fromRGB(25, 120, 70))
        elseif judgement == "Good" or judgement == "Audience" or judgement == "AudienceSupport" or judgement == "AudienceEncore" or judgement == "AudienceHeatPushback" or judgement == "SecurityRepair" or judgement == "DJWarning" or ROOM_SUPPORT_CUES[judgement] then
            pulse(Color3.fromRGB(30, 75, 120))
        end
    end)
end

if remotes:FindFirstChild("SongFinished") then
    remotes.SongFinished.OnClientEvent:Connect(function(payload)
        scanClusters()
        for _, sectorId in ipairs({ "N", "NE", "E", "SE", "S", "SW", "W", "NW" }) do
            local sector = getSector(sectorId)
            addMovementCue(sector, "Finish", 2.2, false)
            local cluster = getCluster(sectorId)
            if cluster then
                tweenCluster(cluster, 100, sectorId, { lastJudgement = "Finish", movementCue = { type = "Finish", strength = 2.2 } })
            end
        end
    end)
end
