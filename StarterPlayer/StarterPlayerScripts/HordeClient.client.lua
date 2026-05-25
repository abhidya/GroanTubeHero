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
local lastEventSerial = 0
local function colorForCue(judgement)
    if judgement == "Repair" or judgement == "Finish" or judgement == "Perfect" then
        return Color3.fromRGB(80, 255, 140)
    end
    if judgement == "Miss" or judgement == "PassiveCreep" then
        return Color3.fromRGB(255, 45, 75)
    end
    return Color3.fromRGB(90, 210, 255)
end

local function addMovementCue(sector, judgement, pressure)
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
    marker.Transparency = 0.08
    marker.Color = colorForCue(judgement)
    local scale = 12 + math.clamp((pressure or 0) / 100, 0, 1) * 10
    TweenService:Create(marker, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), { Size = Vector3.new(scale, scale, scale), Transparency = 0.55 }):Play()
end

local function tweenCluster(cluster, distance, sectorId, judgement, pressure)
    if not cluster or not cluster:IsA("Model") then return end
    local sector = getSector(sectorId)
    local angle = tonumber(sector and sector:GetAttribute("AngleDeg")) or 90
    local alpha = math.clamp((distance or 100) / 100, 0, 1)
    pressure = pressure or (sector and tonumber(sector:GetAttribute("Pressure")) or 0)
    local impulse = 0
    if judgement == "Miss" or judgement == "PassiveCreep" then
        impulse = -10
    elseif judgement == "Repair" or judgement == "Perfect" then
        impulse = 8
    elseif judgement == "Finish" then
        impulse = 18
    end
    local radius = 48 + alpha * 34 - math.clamp(pressure / 100, 0, 1) * 14 + impulse
    local PolarLayout = require(ReplicatedStorage.Shared.WorldV2.PolarLayout)
    local target = PolarLayout.cframeFacingCenter(radius, angle, 3)
    if currentTweens[cluster] then currentTweens[cluster]:Cancel() end
    local value = Instance.new("CFrameValue")
    value.Value = cluster:GetPivot()
    local conn
    conn = value:GetPropertyChangedSignal("Value"):Connect(function()
        if cluster.Parent then cluster:PivotTo(value.Value) end
    end)
    local tweenTime = (judgement == "Miss" or judgement == "PassiveCreep") and 0.16 or 0.28
    local tween = TweenService:Create(value, TweenInfo.new(tweenTime, Enum.EasingStyle.Back), { Value = target })
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
    for sectorId, health in pairs(payload.sectorHealths) do
        local sector = getSector(sectorId)
        if sector then
            local pressure = payload.sectorPressure and payload.sectorPressure[sectorId] or (100 - (health or 100))
            local active = sectorId == payload.activeSectorId
            local warning = sectorId == payload.warningSectorId
            sector:SetAttribute("Health", health)
            sector:SetAttribute("Pressure", pressure)
            local fence = sector:FindFirstChild("FenceSegment")
            if fence and fence:IsA("BasePart") then
                local t = math.clamp((health or 100) / 100, 0, 1)
                if active then
                    fence.Color = colorForCue(payload.lastJudgement or payload.movementCue)
                elseif warning then
                    fence.Color = Color3.fromRGB(255, 45, 75)
                else
                    fence.Color = Color3.fromRGB(255 - math.floor(160 * t), 80 + math.floor(175 * t), 80)
                end
            end
            local siren = sector:FindFirstChild("SirenLight")
            local light = siren and siren:FindFirstChildOfClass("PointLight")
            if light then
                light.Color = active and colorForCue(payload.lastJudgement or payload.movementCue) or Color3.fromRGB(255, 35, 35)
                light.Brightness = active and 5 or warning and 3.5 or (health or 100) < 35 and 5 or 0
            end
            local vfx = sector:FindFirstChild("FenceDamageVFX")
            if vfx and vfx:IsA("BasePart") then
                vfx.Color = active and colorForCue(payload.lastJudgement or payload.movementCue) or Color3.fromRGB(255, 80, 40)
                vfx.Transparency = active and 0.05 or (health or 100) < 60 and 0.15 or 0.75
            end
            local weak = sector:FindFirstChild("WeakPointMarker")
            if weak and weak:IsA("BasePart") then
                weak.Color = warning and Color3.fromRGB(255, 45, 75) or active and colorForCue(payload.lastJudgement or payload.movementCue) or Color3.fromRGB(235, 245, 255)
            end
            local meterPart = sector:FindFirstChild("HordePressureMeter")
            if meterPart and meterPart:IsA("BasePart") then
                meterPart.Size = Vector3.new(2 + math.clamp(pressure / 100, 0, 1) * 8, 1.1, 0.6)
                meterPart.Color = pressure > 55 and Color3.fromRGB(255, 45, 75) or active and colorForCue(payload.lastJudgement or payload.movementCue) or Color3.fromRGB(255, 230, 90)
            end
            for _, child in ipairs(sector:GetChildren()) do
                if child:IsA("BasePart") and tostring(child.Name):match("^SectorWarningSpike_") then
                    child.Color = warning and Color3.fromRGB(255, 45, 75) or active and colorForCue(payload.lastJudgement or payload.movementCue) or Color3.fromRGB(90, 210, 255)
                    child.Transparency = warning and 0.05 or active and 0.15 or 0.45
                end
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
        label.Text = string.format("Brainrot Horde: %s  %d%%  Sector %s  Weak %s", state, math.floor(distance + 0.5), sectorId, warningSectorId)
        fill.Size = UDim2.fromScale(1 - math.clamp(distance / 100, 0, 1), 1)
        fill.BackgroundColor3 = payload.disasterMode and Color3.fromRGB(255, 45, 75) or pressure > 55 and Color3.fromRGB(255, 120, 55) or Color3.fromRGB(255, 80, 80)
        stroke.Color = colorForCue(payload.lastJudgement or payload.movementCue)
        updateSectorVisuals(payload)
        local sector = getSector(sectorId)
        local eventSerial = tonumber(payload.eventSerial)
        if eventSerial == nil or eventSerial ~= lastEventSerial then
            lastEventSerial = eventSerial or lastEventSerial
            addMovementCue(sector, payload.lastJudgement or payload.movementCue, pressure)
            if warningSectorId ~= sectorId then
                local warningPressure = (payload.sectorPressure and payload.sectorPressure[warningSectorId]) or pressure
                addMovementCue(getSector(warningSectorId), "Miss", warningPressure)
            end
        end
        local cluster = getCluster(sectorId)
        if cluster then
            tweenCluster(cluster, distance, sectorId, payload.lastJudgement or payload.movementCue, pressure)
        else
            fallbackHordePoints()
        end
        if payload.lastJudgement == "Miss" or payload.disasterMode then
            pulse(Color3.fromRGB(120, 25, 35))
        elseif payload.lastJudgement == "Perfect" then
            pulse(Color3.fromRGB(25, 120, 70))
        elseif payload.lastJudgement == "Good" or payload.lastJudgement == "Audience" then
            pulse(Color3.fromRGB(30, 75, 120))
        end
    end)
end

if remotes:FindFirstChild("SongFinished") then
    remotes.SongFinished.OnClientEvent:Connect(function(payload)
        scanClusters()
        for _, sectorId in ipairs({ "N", "NE", "E", "SE", "S", "SW", "W", "NW" }) do
            local sector = getSector(sectorId)
            addMovementCue(sector, "Finish", 0)
            local cluster = getCluster(sectorId)
            if cluster then
                tweenCluster(cluster, 100, sectorId, "Finish", 0)
            end
        end
    end)
end
