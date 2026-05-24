local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local laneFolder = playerGui:FindFirstChild("GroanTubeHeroInput") or Instance.new("Folder")
laneFolder.Name = "GroanTubeHeroInput"
laneFolder.Parent = playerGui

local channel = laneFolder:FindFirstChild("LaneInput") or Instance.new("BindableEvent")
channel.Name = "LaneInput"
channel.Parent = laneFolder

local Config = require(ReplicatedStorage.Shared.Config)

local laneButtons = {}
local buttonGui
local inputBar
local rotateLabel
local keyToLane = {}

for lane = 1, 4 do
    local keyName = Config.Lanes[lane].key
    local keyCode = Enum.KeyCode[keyName]
    if keyCode then
        keyToLane[keyCode] = lane
    end
end

local function isSongActive()
    local rhythmGui = playerGui:FindFirstChild("RhythmGui")
    return rhythmGui and rhythmGui:IsA("ScreenGui") and rhythmGui:GetAttribute("SongActive") == true
end

local function fireLane(lane, source)
    local button = laneButtons[lane]
    if button then
        local original = button.BackgroundColor3
        button.BackgroundColor3 = Color3.fromRGB(255, 245, 120)
        TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { BackgroundColor3 = original }):Play()
    end
    channel:Fire({
        lane = lane,
        source = source,
        time = workspace.GetServerTimeNow and workspace:GetServerTimeNow() or os.clock(),
    })
end

local function bindLane(name, lane)
    local keyCode = Enum.KeyCode[Config.Lanes[lane].key]
    if not keyCode then
        warn("Groan Tube Hero: bad lane key", lane, Config.Lanes[lane].key)
        return
    end

    ContextActionService:BindActionAtPriority(name, function(_, state)
        if not isSongActive() then
            return Enum.ContextActionResult.Pass
        end
        if state == Enum.UserInputState.Begin then
            fireLane(lane, "KeyboardAction")
        end
        return Enum.ContextActionResult.Sink
    end, false, 10001, keyCode)
end

for lane = 1, 4 do
    bindLane("GroanTubeHeroLane" .. lane, lane)
end

-- ContextActionService handles most cases, but Roblox camera/controller scripts can
-- still consume arrows in some Studio states. This direct fallback guarantees arrows
-- become hits while the song is active.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isSongActive() then
        return
    end
    local lane = keyToLane[input.KeyCode]
    if lane then
        fireLane(lane, gameProcessed and "KeyboardFallbackProcessed" or "KeyboardFallback")
    end
end)

local function setButtonsVisible(visible)
    if buttonGui then
        buttonGui.Enabled = visible
    end
end

local function createMobileButtons()
    if buttonGui then
        return buttonGui
    end
    buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "GroanTubeHeroMobileInput"
    buttonGui.IgnoreGuiInset = false
    buttonGui.ResetOnSpawn = false
    buttonGui.Enabled = false
    buttonGui.Parent = playerGui

    inputBar = Instance.new("Frame")
    inputBar.Name = "BottomArrowInputBar"
    inputBar.AnchorPoint = Vector2.new(0.5, 1)
    inputBar.Position = UDim2.new(0.5, 0, 0.96, -8)
    inputBar.Size = UDim2.new(0.54, 0, 0.18, 0)
    inputBar.BackgroundColor3 = Color3.fromRGB(6, 8, 18)
    inputBar.BackgroundTransparency = 0.08
    inputBar.Parent = buttonGui
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 18)
    barCorner.Parent = inputBar
    local barStroke = Instance.new("UIStroke")
    barStroke.Color = Color3.fromRGB(120, 220, 255)
    barStroke.Thickness = 2
    barStroke.Transparency = 0.15
    barStroke.Parent = inputBar
    local scale = Instance.new("UIScale")
    scale.Name = "ResponsiveScale"
    scale.Parent = inputBar
    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 5.4
    aspect.AspectType = Enum.AspectType.FitWithinMaxSize
    aspect.Parent = inputBar
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0.025, 0)
    layout.Parent = inputBar

    for lane = 1, 4 do
        local button = Instance.new("TextButton")
        button.Name = "Lane" .. lane
        button.Text = Config.Lanes[lane].symbol or Config.Lanes[lane].key
        button.Size = UDim2.new(0.225, 0, 0.82, 0)
        button.BackgroundColor3 = Color3.fromRGB(24, 28, 52)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBlack
        button.AutoButtonColor = false
        button.ZIndex = 10
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = button
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 2
        stroke.Transparency = 0.25
        stroke.Parent = button
        button.Parent = inputBar
        local textSize = Instance.new("UITextSizeConstraint")
        textSize.MinTextSize = 30
        textSize.MaxTextSize = 72
        textSize.Parent = button
        button.Activated:Connect(function()
            fireLane(lane, "Mobile")
        end)
        laneButtons[lane] = button
    end

    rotateLabel = Instance.new("TextLabel")
    rotateLabel.Name = "RotateDevice"
    rotateLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    rotateLabel.Position = UDim2.fromScale(0.5, 0.5)
    rotateLabel.Size = UDim2.new(0.82, 0, 0.22, 0)
    rotateLabel.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
    rotateLabel.Text = "Rotate device for rhythm controls"
    rotateLabel.TextColor3 = Color3.fromRGB(255, 245, 150)
    rotateLabel.Font = Enum.Font.GothamBlack
    rotateLabel.TextScaled = true
    rotateLabel.Visible = false
    rotateLabel.Parent = buttonGui
    local rotateCorner = Instance.new("UICorner")
    rotateCorner.CornerRadius = UDim.new(0, 18)
    rotateCorner.Parent = rotateLabel

    local function updateResponsive()
        local cam = workspace.CurrentCamera
        local viewport = cam and cam.ViewportSize or Vector2.new(1280, 720)
        local portrait = viewport.Y > viewport.X
        rotateLabel.Visible = portrait and buttonGui.Enabled
        inputBar.Visible = not portrait
        local minSide = math.min(viewport.X, viewport.Y)
        scale.Scale = math.clamp(minSide / 720, 0.82, 1.18)
    end
    RunService.RenderStepped:Connect(updateResponsive)
    updateResponsive()
    return buttonGui
end

createMobileButtons()

local function watchRhythmGui(gui)
    if not gui or not gui:IsA("ScreenGui") then
        return
    end
    setButtonsVisible(gui:GetAttribute("SongActive") == true)
    gui:GetAttributeChangedSignal("SongActive"):Connect(function()
        setButtonsVisible(gui:GetAttribute("SongActive") == true)
    end)
end

local existingRhythm = playerGui:FindFirstChild("RhythmGui")
if existingRhythm then
    watchRhythmGui(existingRhythm)
end
playerGui.ChildAdded:Connect(function(child)
    if child.Name == "RhythmGui" then
        watchRhythmGui(child)
    end
end)

channel.Event:Connect(function(payload, legacySource)
    if type(payload) == "number" then
        payload = {
            lane = payload,
            source = legacySource or "Legacy",
            time = workspace.GetServerTimeNow and workspace:GetServerTimeNow() or os.clock(),
        }
    end
    if type(payload) ~= "table" or not payload.lane then
        return
    end

    local rhythmClient = playerGui:FindFirstChild("RhythmGui")
    if rhythmClient and rhythmClient:IsA("ScreenGui") and rhythmClient:GetAttribute("SongActive") == true and rhythmClient:GetAttribute("AcceptInput") == true then
        local binder = rhythmClient:FindFirstChild("InputBus")
        if binder and binder:IsA("BindableEvent") then
            binder:Fire(payload)
        end
    end
end)
