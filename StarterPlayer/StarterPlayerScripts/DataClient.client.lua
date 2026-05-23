local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientState = require(ReplicatedStorage.Shared.ClientState)

local existing = playerGui:FindFirstChild("ProfileGui")
if existing and not existing:IsA("ScreenGui") then
    existing:Destroy()
    existing = nil
end
local screenGui = existing or Instance.new("ScreenGui")
screenGui.Name = "ProfileGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 260, 0, 180)
panel.Position = UDim2.new(1, -280, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
panel.BackgroundTransparency = 0.08
panel.Parent = screenGui

local label = Instance.new("TextLabel")
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, -12, 1, -12)
label.Position = UDim2.new(0, 6, 0, 6)
label.TextWrapped = true
label.TextScaled = true
label.Font = Enum.Font.Gotham
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Text = "Loading profile..."
label.Parent = panel

remotes.DataSnapshot.OnClientEvent:Connect(function(snapshot)
    ClientState.SetSnapshot(snapshot)
    if snapshot then
        label.Text = string.format(
            "Lvl %d\nXP %d\nFans %d\nCoins %d\nTickets %d\nGroanTokens %d",
            snapshot.Level or 1,
            snapshot.XP or 0,
            snapshot.Fans or 0,
            snapshot.Coins or 0,
            snapshot.Tickets or 0,
            snapshot.GroanTokens or 0
        )
    end
end)
