local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local existing = playerGui:FindFirstChild("AudienceGui")
if existing and not existing:IsA("ScreenGui") then
    existing:Destroy()
    existing = nil
end
local screenGui = existing or Instance.new("ScreenGui")
screenGui.Name = "AudienceGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Visible = false
panel.Size = UDim2.new(0, 240, 0, 220)
panel.Position = UDim2.new(1, -260, 0.12, 0)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
panel.BackgroundTransparency = 0.05
panel.Parent = screenGui

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 4)
title.Text = "Audience"
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = panel

local buttons = { "Clap", "Cheer", "Encore", "Laugh", "Support" }
local buttonFrames = {}
for i, action in ipairs(buttons) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.85, 0, 0, 30)
    button.Position = UDim2.new(0.075, 0, 0, 40 + ((i - 1) * 34))
    button.Text = action
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = panel
    button.MouseButton1Click:Connect(function()
        remotes.AudienceAction:FireServer({ action = action })
    end)
    buttonFrames[action] = button
end

local function updateVisibility()
    local stage = workspace:FindFirstChild("Stage")
    local zone = stage and stage:FindFirstChild("AudienceZone")
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local watching = false
    if zone and root then
        local localPoint = zone.CFrame:PointToObjectSpace(root.Position)
        local half = zone.Size * 0.5
        watching = math.abs(localPoint.X) <= half.X and math.abs(localPoint.Y) <= half.Y + 5 and math.abs(localPoint.Z) <= half.Z
    end
    panel.Visible = watching and not UserInputService.TouchEnabled or watching
end

task.spawn(function()
    while true do
        updateVisibility()
        task.wait(0.5)
    end
end)

remotes.DataSnapshot.OnClientEvent:Connect(function(snapshot)
    local equipped = snapshot and snapshot.Equipped
    if equipped and equipped.AudiencePacks then
        title.Text = "Audience: " .. tostring(equipped.AudiencePacks)
    end
end)
