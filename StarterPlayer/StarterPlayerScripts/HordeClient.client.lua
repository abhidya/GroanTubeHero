local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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

local function tweenCluster(cluster, distance, sectorId)
    if not cluster or not cluster:IsA("Model") then return end
    local sector = getSector(sectorId)
    local angle = tonumber(sector and sector:GetAttribute("AngleDeg")) or 90
    local alpha = math.clamp((distance or 100) / 100, 0, 1)
    local radius = 53 + alpha * 22
    local PolarLayout = require(ReplicatedStorage.Shared.WorldV2.PolarLayout)
    local target = PolarLayout.cframeFacingCenter(radius, angle, 3)
    if currentTweens[cluster] then currentTweens[cluster]:Cancel() end
    local value = Instance.new("CFrameValue")
    value.Value = cluster:GetPivot()
    local conn
    conn = value:GetPropertyChangedSignal("Value"):Connect(function()
        if cluster.Parent then cluster:PivotTo(value.Value) end
    end)
    local tween = TweenService:Create(value, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Value = target })
    currentTweens[cluster] = tween
    tween.Completed:Connect(function()
        if conn then conn:Disconnect() end
        value:Destroy()
        currentTweens[cluster] = nil
    end)
    tween:Play()
end

local function updateSectorVisuals(payload)
    if type(payload.sectorHealths) ~= "table" then return end
    for sectorId, health in pairs(payload.sectorHealths) do
        local sector = getSector(sectorId)
        if sector then
            sector:SetAttribute("Health", health)
            local fence = sector:FindFirstChild("FenceSegment")
            if fence and fence:IsA("BasePart") then
                local t = math.clamp((health or 100) / 100, 0, 1)
                fence.Color = Color3.fromRGB(255 - math.floor(160 * t), 80 + math.floor(175 * t), 80)
            end
            local siren = sector:FindFirstChild("SirenLight")
            local light = siren and siren:FindFirstChildOfClass("PointLight")
            if light then light.Brightness = (health or 100) < 35 and 5 or 0 end
            local vfx = sector:FindFirstChild("FenceDamageVFX")
            if vfx and vfx:IsA("BasePart") then vfx.Transparency = (health or 100) < 60 and 0.15 or 0.75 end
            local meterPart = sector:FindFirstChild("HordePressureMeter")
            if meterPart and meterPart:IsA("BasePart") then
                local pressure = payload.sectorPressure and payload.sectorPressure[sectorId] or (100 - (health or 100))
                meterPart.Size = Vector3.new(2 + math.clamp(pressure / 100, 0, 1) * 8, 1.1, 0.6)
            end
        end
    end
end

local function pulse(color)
    meter.BackgroundColor3 = color
    TweenService:Create(meter, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(12, 14, 28) }):Play()
end

if remotes:FindFirstChild("HordeUpdate") then
    remotes.HordeUpdate.OnClientEvent:Connect(function(payload)
        if type(payload) ~= "table" then return end
        local distance = tonumber(payload.distance) or 100
        local state = payload.state or "Far"
        local sectorId = payload.activeSectorId or "N"
        label.Text = string.format("Brainrot Horde: %s  %d%%  Sector %s", state, math.floor(distance + 0.5), sectorId)
        fill.Size = UDim2.fromScale(1 - math.clamp(distance / 100, 0, 1), 1)
        updateSectorVisuals(payload)
        local cluster = getCluster(sectorId)
        if cluster then
            tweenCluster(cluster, distance, sectorId)
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
