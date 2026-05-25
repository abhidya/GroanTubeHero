local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Folder & BindableEvent for input piping
local inputFolder = playerGui:FindFirstChild("GroanTubeHeroInput") or Instance.new("Folder")
inputFolder.Name = "GroanTubeHeroInput"
inputFolder.Parent = playerGui

local laneInput = inputFolder:FindFirstChild("LaneInput") or Instance.new("BindableEvent")
laneInput.Name = "LaneInput"
laneInput.Parent = inputFolder

local Config = require(ReplicatedStorage.Shared.Config)

local buttonGui
local inputBar
local rotateLabel
local keyToLane = {}
local laneButtons = {}
local lastFireAtByLane = {}

for lane = 1, 4 do
    local keyName = Config.Lanes[lane].key
    local keyCode = Enum.KeyCode[keyName]
    if keyCode then
        keyToLane[keyCode] = lane
    end
end

local function rhythmGui()
    local rg = playerGui:FindFirstChild("RhythmGui")
    return (rg and rg:IsA("ScreenGui")) and rg or nil
end

local function isSongActive()
    local rg = rhythmGui()
    return rg and rg:GetAttribute("SongActive") == true
end

local function isAcceptInput()
    local rg = rhythmGui()
    return rg and rg:GetAttribute("SongActive") == true and rg:GetAttribute("AcceptInput") == true
end

local function fireLane(lane, source, keyCodeName)
    local t = workspace.GetServerTimeNow and workspace:GetServerTimeNow() or os.clock()
    if lastFireAtByLane[lane] and (t - lastFireAtByLane[lane]) < 0.055 then
        return
    end
    lastFireAtByLane[lane] = t
    local rg = rhythmGui()
    if Config.DebugRhythm then
        print("[RhythmDebug][InputController]", "lane", lane, "source", source, "keyCode", keyCodeName, "SongActive", rg and rg:GetAttribute("SongActive"), "AcceptInput", rg and rg:GetAttribute("AcceptInput"))
    end
    laneInput:Fire({
        lane = lane,
        source = source,
        time = t,
        keyCode = keyCodeName,
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
        if state == Enum.UserInputState.Begin and isAcceptInput() then
            fireLane(lane, "KeyboardAction", keyCode.Name)
        end
        return Enum.ContextActionResult.Sink
    end, false, 10001, keyCode)
end

for lane = 1, 4 do
    bindLane("GroanTubeHeroLane" .. lane, lane)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isSongActive() or not isAcceptInput() then
        return
    end
    local lane = keyToLane[input.KeyCode]
    if lane then
        fireLane(lane, gameProcessed and "KeyboardFallbackProcessed" or "KeyboardFallback", input.KeyCode.Name)
    end
end)

local function setButtonsVisible(visible)
    if buttonGui then
        -- Enable buttons on touch devices, and always in Studio for easy testing
        local showOnMobile = UserInputService.TouchEnabled
        local showInStudio = RunService:IsStudio()
        buttonGui.Enabled = visible and (showOnMobile or showInStudio)
    end
end

local laneColors = {
    Color3.fromRGB(80, 210, 255),  -- Blue (Lane 1)
    Color3.fromRGB(140, 255, 150), -- Green (Lane 2)
    Color3.fromRGB(255, 215, 80),  -- Gold (Lane 3)
    Color3.fromRGB(255, 110, 210), -- Pink (Lane 4)
}

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

    -- Bottom Center Input Bar Container
    inputBar = Instance.new("Frame")
    inputBar.Name = "BottomArrowInputBar"
    inputBar.AnchorPoint = Vector2.new(0.5, 1)
    inputBar.Size = UDim2.fromOffset(560, 100)
    inputBar.Position = UDim2.new(0.5, 0, 1, -15) -- Safe area margin from bottom edge (clear of Home Indicator)
    inputBar.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
    inputBar.BackgroundTransparency = 0.15
    inputBar.BorderSizePixel = 0
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
    aspect.AspectRatio = 5.6
    aspect.AspectType = Enum.AspectType.FitWithinMaxSize
    aspect.Parent = inputBar

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0.025, 0)
    layout.Parent = inputBar

    for lane = 1, 4 do
        -- Frame wrapper to allow smooth button scaling without shifting list siblings
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Name = "LaneFrame" .. lane
        buttonFrame.Size = UDim2.fromOffset(82, 82)
        buttonFrame.BackgroundTransparency = 1
        buttonFrame.Parent = inputBar

        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.AnchorPoint = Vector2.new(0.5, 0.5)
        button.Position = UDim2.fromScale(0.5, 0.5)
        button.Size = UDim2.fromOffset(82, 82)
        button.Text = Config.Lanes[lane].symbol or Config.Lanes[lane].key
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBlack
        button.BackgroundColor3 = Color3.fromRGB(24, 28, 52)
        button.BackgroundTransparency = 0.3
        button.AutoButtonColor = false
        button.ZIndex = 10
        button.Parent = buttonFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0) -- Circular buttons
        corner.Parent = button

        local stroke = Instance.new("UIStroke")
        stroke.Color = laneColors[lane]
        stroke.Thickness = 3
        stroke.Transparency = 0.15
        stroke.Parent = button

        local textSize = Instance.new("UITextSizeConstraint")
        textSize.MinTextSize = 30
        textSize.MaxTextSize = 72
        textSize.Parent = button

        -- Press / Release visual micro-animations
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                    Size = UDim2.fromOffset(72, 72),
                    BackgroundTransparency = 0.05
                }):Play()
            end
        end)

        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
                    Size = UDim2.fromOffset(82, 82),
                    BackgroundTransparency = 0.3
                }):Play()
            end
        end)

        button.Activated:Connect(function()
            if isAcceptInput() then
                fireLane(lane, "Mobile", Config.Lanes[lane].key)
            end
        end)

        laneButtons[lane] = button
    end

    -- Orientation warning label (if user holds device in portrait, ask to rotate)
    rotateLabel = Instance.new("TextLabel")
    rotateLabel.Name = "RotateDevice"
    rotateLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    rotateLabel.Position = UDim2.fromScale(0.5, 0.5)
    rotateLabel.Size = UDim2.new(0.82, 0, 0.22, 0)
    rotateLabel.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
    rotateLabel.Text = "Rotate device to Landscape mode"
    rotateLabel.TextColor3 = Color3.fromRGB(255, 245, 150)
    rotateLabel.Font = Enum.Font.GothamBlack
    rotateLabel.TextScaled = true
    rotateLabel.Visible = false
    rotateLabel.Parent = buttonGui

    local rotateCorner = Instance.new("UICorner")
    rotateCorner.CornerRadius = UDim.new(0, 18)
    rotateCorner.Parent = rotateLabel

    local rotateStroke = Instance.new("UIStroke")
    rotateStroke.Color = Color3.fromRGB(255, 110, 210)
    rotateStroke.Thickness = 2
    rotateStroke.Parent = rotateLabel

    local function updateResponsive()
        local cam = workspace.CurrentCamera
        local viewport = cam and cam.ViewportSize or Vector2.new(1280, 720)
        local portrait = viewport.Y > viewport.X

        rotateLabel.Visible = portrait and buttonGui.Enabled
        inputBar.Visible = not portrait

        local minSide = math.min(viewport.X, viewport.Y)
        scale.Scale = math.clamp(minSide / 720, 0.70, 1.25)
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

laneInput.Event:Connect(function(payload, legacySource)
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
