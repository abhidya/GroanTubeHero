local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local function ensure(parent, className, name)
    local found = parent:FindFirstChild(name)
    if found then return found end
    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = parent
    return instance
end

local function setModelPrimaryPart(model)
    if not model or not model:IsA("Model") then return end
    if model.PrimaryPart then return end
    local firstPart = model:FindFirstChildWhichIsA("BasePart", true)
    if firstPart then
        model.PrimaryPart = firstPart
    end
end

local function convertFolderRoot(hordeFolder)
    local root = hordeFolder:FindFirstChild("HordeRoot")
    if root and root:IsA("Folder") then
        local oldFolder = root
        local model = Instance.new("Model")
        model.Name = "HordeRoot"
        model.Parent = hordeFolder
        for _, child in ipairs(oldFolder:GetChildren()) do
            child.Parent = model
            if child:IsA("BasePart") then
                child.Anchored = true
                child.CanCollide = false
            elseif child:IsA("Model") then
                for _, part in ipairs(child:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                        part.CanCollide = false
                    end
                end
            end
        end
        oldFolder:Destroy()
        root = model
    end
    if root and root:IsA("Model") then
        setModelPrimaryPart(root)
    end
    return root
end

local function ensureStageHorde()
    local stage = workspace:FindFirstChild("Stage") or ensure(workspace, "Folder", "Stage")
    local hordeFolder = ensure(stage, "Folder", "BrainrotHorde")
    local root = convertFolderRoot(hordeFolder)
    if not root then
        root = Instance.new("Model")
        root.Name = "HordeRoot"
        root.Parent = hordeFolder
        for i = 1, 12 do
            local part = Instance.new("Part")
            part.Name = "Brainrot" .. i
            part.Anchored = true
            part.CanCollide = false
            part.Size = Vector3.new(2.2, 4 + (i % 3), 2.2)
            part.Color = Color3.fromRGB(95, 255, 105)
            part.Material = Enum.Material.Neon
            part.CFrame = CFrame.new(((i - 1) % 4 - 1.5) * 4, 4, math.floor((i - 1) / 4) * 4)
            part.Parent = root
        end
        setModelPrimaryPart(root)
    end
    local far = hordeFolder:FindFirstChild("HordeFarPoint") or Instance.new("Part")
    far.Name = "HordeFarPoint"
    far.Anchored = true
    far.CanCollide = false
    far.Transparency = 1
    far.Size = Vector3.new(2, 2, 2)
    far.CFrame = CFrame.new(0, 4, -70)
    far.Parent = hordeFolder
    local near = hordeFolder:FindFirstChild("HordeNearStagePoint") or Instance.new("Part")
    near.Name = "HordeNearStagePoint"
    near.Anchored = true
    near.CanCollide = false
    near.Transparency = 1
    near.Size = Vector3.new(2, 2, 2)
    near.CFrame = CFrame.new(0, 4, -16)
    near.Parent = hordeFolder
    return root, far, near
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

local root, farPoint, nearPoint = ensureStageHorde()
local currentTween
local modelTweenValue
local modelTweenConn
local function moveHorde(distance)
    root, farPoint, nearPoint = ensureStageHorde()
    local alpha = 1 - math.clamp((distance or 100) / 100, 0, 1)
    local cf = farPoint.CFrame:Lerp(nearPoint.CFrame, alpha)
    if root:IsA("Model") then
        if currentTween then currentTween:Cancel() end
        if modelTweenConn then modelTweenConn:Disconnect() end
        if modelTweenValue then modelTweenValue:Destroy() end
        modelTweenValue = Instance.new("CFrameValue")
        modelTweenValue.Value = root:GetPivot()
        modelTweenConn = modelTweenValue:GetPropertyChangedSignal("Value"):Connect(function()
            if root then root:PivotTo(modelTweenValue.Value) end
        end)
        currentTween = TweenService:Create(modelTweenValue, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Value = cf })
        currentTween:Play()
    elseif root:IsA("BasePart") then
        if currentTween then currentTween:Cancel() end
        currentTween = TweenService:Create(root, TweenInfo.new(0.22, Enum.EasingStyle.Back), { CFrame = cf })
        currentTween:Play()
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
        label.Text = string.format("Brainrot Horde: %s  %d%%", state, math.floor(distance + 0.5))
        fill.Size = UDim2.fromScale(1 - math.clamp(distance / 100, 0, 1), 1)
        moveHorde(distance)
        if payload.lastJudgement == "Miss" or payload.disasterMode then
            pulse(Color3.fromRGB(120, 25, 35))
        elseif payload.lastJudgement == "Perfect" then
            pulse(Color3.fromRGB(25, 120, 70))
        elseif payload.lastJudgement == "Good" or payload.lastJudgement == "Audience" then
            pulse(Color3.fromRGB(30, 75, 120))
        end
    end)
end
