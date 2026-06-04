local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "NPCDialogueGui"
gui.IgnoreGuiInset = false
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "DialoguePanel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -28)
panel.Size = UDim2.new(0.78, 0, 0, 92)
panel.BackgroundColor3 = Color3.fromRGB(7, 10, 22)
panel.BackgroundTransparency = 1
panel.Visible = false
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120, 240, 255)
stroke.Thickness = 2
stroke.Transparency = 0.15
stroke.Parent = panel

local speaker = Instance.new("TextLabel")
speaker.Name = "Speaker"
speaker.BackgroundTransparency = 1
speaker.Position = UDim2.new(0, 18, 0, 8)
speaker.Size = UDim2.new(0.42, 0, 0, 22)
speaker.Text = "Crew"
speaker.TextScaled = true
speaker.TextXAlignment = Enum.TextXAlignment.Left
speaker.TextColor3 = Color3.fromRGB(255, 240, 150)
speaker.Font = Enum.Font.GothamBlack
speaker.Parent = panel

local action = Instance.new("TextLabel")
action.Name = "Action"
action.BackgroundTransparency = 1
action.Position = UDim2.new(0.46, 0, 0, 8)
action.Size = UDim2.new(0.50, 0, 0, 22)
action.Text = ""
action.TextScaled = true
action.TextXAlignment = Enum.TextXAlignment.Right
action.TextColor3 = Color3.fromRGB(120, 240, 255)
action.Font = Enum.Font.GothamBold
action.Parent = panel

local text = Instance.new("TextLabel")
text.Name = "DialogueText"
text.BackgroundTransparency = 1
text.Position = UDim2.new(0, 18, 0, 34)
text.Size = UDim2.new(1, -36, 1, -42)
text.TextWrapped = true
text.TextScaled = true
text.TextColor3 = Color3.fromRGB(235, 245, 255)
text.Font = Enum.Font.GothamBold
text.TextXAlignment = Enum.TextXAlignment.Left
text.Parent = panel

local token = 0
local function menuColor(menuName)
    if menuName == "Security" then return Color3.fromRGB(255, 90, 90) end
    if menuName == "Hype" then return Color3.fromRGB(255, 220, 90) end
    if menuName == "TourBus" or menuName == "Tour Bus" then return Color3.fromRGB(255, 115, 220) end
    if menuName == "Missions" then return Color3.fromRGB(120, 200, 95) end
    if menuName == "Tutorial" then return Color3.fromRGB(90, 210, 220) end
    return Color3.fromRGB(120, 240, 255)
end

local function activeSong()
    local rhythmGui = playerGui:FindFirstChild("RhythmGui")
    return rhythmGui and rhythmGui:GetAttribute("SongActive") == true
end

local function show(payload)
    token += 1
    local my = token
    local line = payload
    local menuName = nil
    if type(payload) == "table" then
        line = payload.text
        menuName = payload.menu
        speaker.Text = tostring(payload.speaker or payload.menu or "Crew")
        action.Text = tostring(payload.actionPrompt or "")
    else
        speaker.Text = "Crew"
        action.Text = ""
    end
    stroke.Color = menuColor(menuName)
    panel.Visible = true
    panel.BackgroundTransparency = 0.08
    speaker.TextTransparency = 0
    action.TextTransparency = 0
    text.TextTransparency = 0
    text.Text = tostring(line or "Crew: Keep the stage alive.")
    if activeSong() then
        panel.AnchorPoint = Vector2.new(0.5, 0)
        panel.Position = UDim2.new(0.5, 0, 0, 96)
    else
        panel.AnchorPoint = Vector2.new(0.5, 1)
        panel.Position = UDim2.new(0.5, 0, 1, -28)
    end
    panel.Size = UDim2.new(0.78, 0, 0, 96)
    TweenService:Create(panel, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Size = UDim2.new(0.82, 0, 0, 106) }):Play()
    task.delay(3.2, function()
        if my ~= token then return end
        TweenService:Create(panel, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(speaker, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
        TweenService:Create(action, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
        TweenService:Create(text, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
        task.delay(0.28, function()
            if my == token then panel.Visible = false end
        end)
    end)
end

local remote = remotes:WaitForChild("NPCDialogue", 10)
if remote then
    remote.OnClientEvent:Connect(function(payload)
        show(payload)
    end)
end
