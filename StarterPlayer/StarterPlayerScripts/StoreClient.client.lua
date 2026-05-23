local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local screenGui = playerGui:FindFirstChild("StoreGui") or Instance.new("ScreenGui")
screenGui.Name = "StoreGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 420, 0, 320)
panel.Position = UDim2.new(0, 20, 1, -340)
panel.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
panel.BackgroundTransparency = 0.08
panel.Visible = false
panel.Parent = screenGui

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 36)
title.Text = "Store"
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -50)
list.Position = UDim2.new(0, 10, 0, 42)
list.CanvasSize = UDim2.new(0, 0, 0, 600)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 8
list.Parent = panel

local function row(y, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 42)
    button.Position = UDim2.new(0, 5, 0, y)
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = list
    button.Activated:Connect(callback)
    return button
end

row(0, "Open/Close Store", function()
    panel.Visible = not panel.Visible
end)
row(52, "Buy Neon Groan TubeSound", function()
    remotes.PurchaseItem:FireServer({ category = "TubeSounds", itemId = "NeonGroan" })
end)
row(104, "Equip Neon Groan TubeSound", function()
    remotes.EquipItem:FireServer({ category = "TubeSounds", itemId = "NeonGroan" })
end)
row(156, "Buy Purple Rift Stage", function()
    remotes.PurchaseItem:FireServer({ category = "StageEffects", itemId = "PurpleRift" })
end)
row(208, "Equip Purple Rift Stage", function()
    remotes.EquipItem:FireServer({ category = "StageEffects", itemId = "PurpleRift" })
end)
row(260, "Buy Career Buff: Second Wind", function()
    remotes.PurchaseItem:FireServer({ category = "Buffs", itemId = "SecondWind" })
end)
row(312, "Buy Upgrade: Timing", function()
    remotes.PurchaseItem:FireServer({ category = "GameplayUpgrades", itemId = "Timing" })
end)

remotes.DataSnapshot.OnClientEvent:Connect(function(snapshot)
    if snapshot and snapshot.Equipped then
        title.Text = string.format("Store | Coins %d | Fans %d", snapshot.Coins or 0, snapshot.Fans or 0)
    end
end)
