local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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
    gui.IgnoreGuiInset = false
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
local welcomeScale = Instance.new("UIScale")
welcomeScale.Name = "ResponsiveScale"
welcomeScale.Parent = welcome
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

local closeWelcome = Instance.new("TextButton")
closeWelcome.Name = "CloseWelcome"
closeWelcome.Size = UDim2.new(0, 40, 0, 36)
closeWelcome.Position = UDim2.new(1, -50, 0, 12)
closeWelcome.Text = "X"
closeWelcome.TextColor3 = Color3.new(1, 1, 1)
closeWelcome.Font = Enum.Font.GothamBlack
closeWelcome.TextScaled = true
closeWelcome.BackgroundColor3 = Color3.fromRGB(255, 95, 95)
closeWelcome.Parent = welcome
corner(closeWelcome, 10)
closeWelcome.Activated:Connect(function() welcome.Visible = false end)

local body = Instance.new("TextLabel")
body.BackgroundTransparency = 1
body.Size = UDim2.new(1, -28, 0, 176)
body.Position = UDim2.new(0, 14, 0, 62)
body.Text = "Hit notes. Make cursed groans. Hype the crowd. Upgrade your stage career.\n\n1. Tap Choose Song or use the glowing mic.\n2. Pick a song, difficulty, and segment length.\n3. Press ← → ↑ ↓ or tap/click the matching lanes.\n4. Build Combo, Hype, and keep Stability alive.\n5. Earn Fans, Coins, XP, and Tickets.\n6. Buy upgrades, stage effects, and Tour Bus bonuses."
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

local actionBar = Instance.new("Frame")
actionBar.Name = "TouchActionBar"
actionBar.AnchorPoint = Vector2.new(0.5, 0)
actionBar.Position = UDim2.new(0.5, 0, 0, 12)
actionBar.Size = UDim2.new(0, 720, 0, 52)
actionBar.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
actionBar.BackgroundTransparency = 0.08
actionBar.Parent = screenGui
corner(actionBar, 14)
stroke(actionBar, Color3.fromRGB(80, 225, 255))
local actionScale = Instance.new("UIScale")
actionScale.Name = "ResponsiveScale"
actionScale.Parent = actionBar
local actionLayout = Instance.new("UIListLayout")
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
actionLayout.Padding = UDim.new(0, 8)
actionLayout.Parent = actionBar
local actionPad = Instance.new("UIPadding")
actionPad.PaddingLeft = UDim.new(0, 8)
actionPad.PaddingRight = UDim.new(0, 8)
actionPad.Parent = actionBar

local function actionButton(name, text, callback)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 108, 0, 38)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBlack
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(45, 55, 85)
    b.Parent = actionBar
    corner(b, 10)
    b.Activated:Connect(callback)
    return b
end

local function openStoreTab(tab)
    local sg = playerGui:FindFirstChild("StoreGui")
    if sg then
        sg.Enabled = true
        sg:SetAttribute("Open", true)
        sg:SetAttribute("Tab", tab)
    end
end

local function openSongs()
    local rg = playerGui:FindFirstChild("RhythmGui")
    if rg then
        rg:SetAttribute("OpenSongSelect", true)
        local modal = rg:FindFirstChild("Root") and rg.Root:FindFirstChild("SongSelectModal")
        if modal then modal.Visible = true end
    end
    welcome.Visible = false
end

actionButton("ChooseSong", "Choose Song", openSongs)
actionButton("Store", "Store", function() openStoreTab("Tube Sounds") end)
actionButton("Missions", "Missions", function() openStoreTab("Missions") end)
actionButton("TourBus", "Tour Bus", function() openStoreTab("Tour Bus") end)
actionButton("Watch", "Watch", function()
    local ag = playerGui:FindFirstChild("AudienceGui")
    if ag then ag:SetAttribute("Open", true) end
end)
actionButton("Help", "Help", function() welcome.Visible = true end)

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

RunService.RenderStepped:Connect(function()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local scale = math.clamp(math.min(viewport.X / 1180, viewport.Y / 680), 0.68, 1.06)
    actionScale.Scale = scale
    welcomeScale.Scale = math.clamp(math.min(viewport.X / 760, viewport.Y / 560), 0.72, 1)
    hud.Size = UDim2.new(0, math.clamp(viewport.X * 0.34, 320, 430), 0, 76)
end)

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
