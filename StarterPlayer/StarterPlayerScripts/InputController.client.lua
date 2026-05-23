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

local function fireLane(lane, source)
    channel:Fire({
        lane = lane,
        source = source,
        time = workspace.GetServerTimeNow and workspace:GetServerTimeNow() or os.clock(),
    })
end

local function bindLane(name, lane)
    ContextActionService:BindAction(name, function(_, state)
        if state == Enum.UserInputState.Begin then
            fireLane(lane, "Keyboard")
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode[Config.Lanes[lane].key])
end

for lane = 1, 4 do
    bindLane("GroanTubeHeroLane" .. lane, lane)
end

local function createMobileButtons()
    if buttonGui then
        return buttonGui
    end
    buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "GroanTubeHeroMobileInput"
    buttonGui.IgnoreGuiInset = true
    buttonGui.ResetOnSpawn = false
    buttonGui.Parent = playerGui

    local baseY = 0.82
    for lane = 1, 4 do
        local button = Instance.new("TextButton")
        button.Name = "Lane" .. lane
        button.Text = Config.Lanes[lane].key
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

-- Always create the four large lane buttons. Desktop players get visible hints,
-- mobile players get tappable controls outside the Roblox thumbstick/jump area.
createMobileButtons()

ReplicatedStorage:GetAttributeChangedSignal("GroanTubeHeroReady"):Connect(function()
    if UserInputService.TouchEnabled and not buttonGui then
        createMobileButtons()
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
