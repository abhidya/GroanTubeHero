local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
screenGui.IgnoreGuiInset = false
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
end

local function button(parent, name, text, size, position, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = size
    b.Position = position
    b.Text = text
    b.Font = Enum.Font.GothamBlack
    b.TextScaled = true
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BackgroundColor3 = color or Color3.fromRGB(55, 145, 255)
    b.Parent = parent
    corner(b, 10)
    return b
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Visible = false
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Size = UDim2.new(0, 300, 0, 270)
panel.Position = UDim2.new(1, -24, 0.48, 0)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
panel.BackgroundTransparency = 0.05
panel.Parent = screenGui
corner(panel, 18)
local panelScale = Instance.new("UIScale")
panelScale.Name = "ResponsiveScale"
panelScale.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -64, 0, 40)
title.Position = UDim2.new(0, 14, 0, 8)
title.Text = "Audience / Watch"
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = panel

local close = button(panel, "Close", "X", UDim2.new(0, 42, 0, 38), UDim2.new(1, -52, 0, 10), Color3.fromRGB(255, 95, 95))
local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1, -28, 0, 42)
hint.Position = UDim2.new(0, 14, 0, 48)
hint.Text = "Cheer the performer. Watch horde/stage action."
hint.TextScaled = true
hint.TextWrapped = true
hint.Font = Enum.Font.GothamBold
hint.TextColor3 = Color3.fromRGB(220, 235, 255)
hint.Parent = panel

local actions = { "Clap", "Cheer", "Encore", "Laugh", "Support" }
for i, action in ipairs(actions) do
    local col = ((i - 1) % 2)
    local row = math.floor((i - 1) / 2)
    local b = button(panel, action .. "Button", action, UDim2.new(0.44, -8, 0, 44), UDim2.new(0.06 + col * 0.47, 0, 0, 102 + row * 52), Color3.fromRGB(40, 40, 70))
    b.Activated:Connect(function()
        remotes.AudienceAction:FireServer({ action = action })
    end)
end

local forcedOpen = false
close.Activated:Connect(function()
    forcedOpen = false
    screenGui:SetAttribute("Open", false)
    panel.Visible = false
end)

screenGui:GetAttributeChangedSignal("Open"):Connect(function()
    if screenGui:GetAttribute("Open") then
        forcedOpen = true
        panel.Visible = true
    end
end)

local function inAudienceZone()
    local stage = workspace:FindFirstChild("Stage")
    local zone = stage and stage:FindFirstChild("AudienceZone")
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not zone or not root then return false end
    local localPoint = zone.CFrame:PointToObjectSpace(root.Position)
    local half = zone.Size * 0.5
    return math.abs(localPoint.X) <= half.X and math.abs(localPoint.Y) <= half.Y + 5 and math.abs(localPoint.Z) <= half.Z
end

local lastZone = false
task.spawn(function()
    while true do
        lastZone = inAudienceZone()
        panel.Visible = forcedOpen or lastZone
        task.wait(0.5)
    end
end)

RunService.RenderStepped:Connect(function()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    panelScale.Scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 560), 0.72, 1.08)
end)

remotes.DataSnapshot.OnClientEvent:Connect(function(snapshot)
    local equipped = snapshot and snapshot.Equipped
    if equipped and equipped.AudiencePacks then
        title.Text = "Audience / Watch: " .. tostring(equipped.AudiencePacks)
    end
end)
