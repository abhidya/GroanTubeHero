local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientState = require(ReplicatedStorage.Shared.ClientState)

local function ensureScreenGui(name)
    local existing = playerGui:FindFirstChild(name)
    if existing and not existing:IsA("ScreenGui") then
        existing:Destroy()
        existing = nil
    end
    local gui = existing or Instance.new("ScreenGui")
    gui.Name = name
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    return gui
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
end

local function stroke(parent, color)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(120, 220, 255)
    s.Thickness = 2
    s.Transparency = 0.15
    s.Parent = parent
end

local screenGui = ensureScreenGui("ProfileGui")
screenGui:ClearAllChildren()

local hud = Instance.new("Frame")
hud.Name = "PersistentHUD"
hud.Size = UDim2.new(0, 430, 0, 76)
hud.Position = UDim2.new(0, 16, 1, -92)
hud.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
hud.BackgroundTransparency = 0.04
hud.Parent = screenGui
corner(hud, 14)
stroke(hud, Color3.fromRGB(80, 225, 255))

local currency = Instance.new("TextLabel")
currency.Name = "CurrencyLabel"
currency.BackgroundTransparency = 1
currency.Size = UDim2.new(1, -16, 0, 40)
currency.Position = UDim2.new(0, 8, 0, 4)
currency.Text = "Level 1 • XP 0 • Fans 0 • Coins 0 • Tickets 0"
currency.TextColor3 = Color3.fromRGB(255, 255, 255)
currency.Font = Enum.Font.GothamBlack
currency.TextScaled = true
currency.TextXAlignment = Enum.TextXAlignment.Left
currency.Parent = hud

local xpBack = Instance.new("Frame")
xpBack.Name = "XPBarBack"
xpBack.Size = UDim2.new(1, -16, 0, 16)
xpBack.Position = UDim2.new(0, 8, 1, -24)
xpBack.BackgroundColor3 = Color3.fromRGB(35, 38, 58)
xpBack.Parent = hud
corner(xpBack, 8)
local xpFill = Instance.new("Frame")
xpFill.Name = "XPBarFill"
xpFill.Size = UDim2.fromScale(0, 1)
xpFill.BackgroundColor3 = Color3.fromRGB(120, 255, 180)
xpFill.Parent = xpBack
corner(xpFill, 8)

local welcome = Instance.new("Frame")
welcome.Name = "WelcomeCard"
welcome.AnchorPoint = Vector2.new(0, 0)
welcome.Position = UDim2.new(0, 16, 0, 104)
welcome.Size = UDim2.new(0, 390, 0, 300)
welcome.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
welcome.BackgroundTransparency = 0.02
welcome.Parent = screenGui
corner(welcome, 18)
stroke(welcome, Color3.fromRGB(255, 230, 120))

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -24, 0, 46)
title.Position = UDim2.new(0, 12, 0, 10)
title.Text = "Groan Tube Hero"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Parent = welcome

local body = Instance.new("TextLabel")
body.BackgroundTransparency = 1
body.Size = UDim2.new(1, -28, 0, 176)
body.Position = UDim2.new(0, 14, 0, 62)
body.Text = "Hit notes. Make cursed groans. Hype the crowd. Upgrade your stage career.\n\n1. Go to the glowing mic.\n2. Hold E or click Choose Song.\n3. Pick a song.\n4. Hit ← → ↑ ↓ or tap the four buttons.\n5. Build Combo and Hype.\n6. Earn Fans, Coins, XP, and Tickets.\n7. Buy upgrades, stage effects, and Tour Bus bonuses."
body.TextColor3 = Color3.fromRGB(220, 235, 255)
body.Font = Enum.Font.GothamBold
body.TextScaled = true
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Left
body.Parent = welcome

local function makeButton(name, text, x, callback)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 112, 0, 40)
    b.Position = UDim2.new(0, x, 1, -52)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBlack
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(55, 145, 255)
    b.Parent = welcome
    corner(b, 10)
    b.Activated:Connect(callback)
    return b
end

makeButton("PlayButton", "Songs", 14, function()
    local rg = playerGui:FindFirstChild("RhythmGui")
    if rg then
        rg:SetAttribute("OpenSongSelect", true)
        local modal = rg:FindFirstChild("Root") and rg.Root:FindFirstChild("SongSelectModal")
        if modal then modal.Visible = true end
    end
    welcome.Visible = false
end)
makeButton("UpgradesButton", "Upgrades", 138, function()
    local sg = playerGui:FindFirstChild("StoreGui")
    if sg then sg.Enabled = true; sg:SetAttribute("Open", true); sg:SetAttribute("Tab", "Upgrades") end
end)
makeButton("StoreButton", "Store", 262, function()
    local sg = playerGui:FindFirstChild("StoreGui")
    if sg then sg.Enabled = true; sg:SetAttribute("Open", true); sg:SetAttribute("Tab", "Tube Sounds") end
end)

local arrow = Instance.new("TextLabel")
arrow.Name = "StageArrow"
arrow.BackgroundTransparency = 1
arrow.Size = UDim2.new(0, 360, 0, 50)
arrow.Position = UDim2.new(0.5, -180, 0, 92)
arrow.Text = "⬇ GO TO THE GLOWING STAGE MIC ⬇"
arrow.TextColor3 = Color3.fromRGB(255, 245, 120)
arrow.Font = Enum.Font.GothamBlack
arrow.TextScaled = true
arrow.Parent = screenGui
TweenService:Create(arrow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { TextTransparency = 0.35 }):Play()

local function update(snapshot)
    ClientState.SetSnapshot(snapshot)
    local level = snapshot.Level or 1
    local xp = snapshot.XP or 0
    local fans = snapshot.Fans or 0
    local coins = snapshot.Coins or 0
    local tickets = snapshot.Tickets or 0
    currency.Text = string.format("Lvl %d • XP %d • Fans %d • Coins %d • Tickets %d", level, xp, fans, coins, tickets)
    local progress = math.clamp((xp % 120) / 120, 0, 1)
    TweenService:Create(xpFill, TweenInfo.new(0.25), { Size = UDim2.fromScale(progress, 1) }):Play()
end

remotes.DataSnapshot.OnClientEvent:Connect(function(snapshot)
    if snapshot then update(snapshot) end
end)
