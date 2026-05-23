local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    end, false, 10000, keyCode)
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
    buttonGui.IgnoreGuiInset = true
    buttonGui.ResetOnSpawn = false
    buttonGui.Enabled = false
    buttonGui.Parent = playerGui

    local baseY = 0.82
    for lane = 1, 4 do
        local button = Instance.new("TextButton")
        button.Name = "Lane" .. lane
        button.Text = Config.Lanes[lane].symbol or Config.Lanes[lane].key
        button.Size = UDim2.new(0.22, 0, 0.12, 0)
        button.Position = UDim2.new(0.05 + ((lane - 1) * 0.23), 0, baseY, 0)
        button.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Parent = buttonGui
        button.Activated:Connect(function()
            fireLane(lane, "Mobile")
        end)
        laneButtons[lane] = button
    end
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
    if rhythmClient and rhythmClient:IsA("ScreenGui") and rhythmClient:GetAttribute("AcceptInput") == true then
        local binder = rhythmClient:FindFirstChild("InputBus")
        if binder and binder:IsA("BindableEvent") then
            binder:Fire(payload)
        end
    end
end)
