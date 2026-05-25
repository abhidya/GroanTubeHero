local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local SongCatalog = require(ReplicatedStorage.Shared.SongCatalog)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local function serverNow()
    return workspace.GetServerTimeNow and workspace:GetServerTimeNow() or os.clock()
end

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

local inputFolder = playerGui:FindFirstChild("GroanTubeHeroInput") or Instance.new("Folder")
inputFolder.Name = "GroanTubeHeroInput"
inputFolder.Parent = playerGui
local laneInput = inputFolder:FindFirstChild("LaneInput") or Instance.new("BindableEvent")
laneInput.Name = "LaneInput"
laneInput.Parent = inputFolder

local screenGui = ensureScreenGui("RhythmGui")
screenGui.Enabled = true
screenGui:SetAttribute("SongActive", false)
screenGui:SetAttribute("AcceptInput", false)
screenGui:ClearAllChildren()

local inputBus = Instance.new("BindableEvent")
inputBus.Name = "InputBus"
inputBus.Parent = screenGui

local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundTransparency = 1
root.Size = UDim2.fromScale(1, 1)
root.Parent = screenGui

local scale = Instance.new("UIScale")
scale.Name = "ResponsiveScale"
scale.Scale = 1
scale.Parent = root

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(120, 220, 255)
    s.Thickness = thickness or 2
    s.Transparency = 0.15
    s.Parent = parent
    return s
end

local function makeLabel(parent, name, text, size, pos, color, font)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = pos
    label.Text = text
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.Font = font or Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = parent
    return label
end

local function makeButton(parent, name, text, size, pos, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = pos
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBlack
    button.TextScaled = true
    button.BackgroundColor3 = color or Color3.fromRGB(55, 145, 255)
    button.AutoButtonColor = true
    button.Parent = parent
    corner(button, 12)
    stroke(button, Color3.fromRGB(255, 255, 255), 1)
    return button
end

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, -32, 0, 76)
topBar.Position = UDim2.new(0, 16, 0, 12)
topBar.BackgroundColor3 = Color3.fromRGB(10, 12, 24)
topBar.BackgroundTransparency = 0.08
topBar.Parent = root
corner(topBar, 14)
stroke(topBar, Color3.fromRGB(80, 225, 255), 2)

local songInfo = makeLabel(topBar, "SongInfo", "Groan Tube Hero\nChoose a song at the stage mic", UDim2.new(0.30, 0, 1, -12), UDim2.new(0, 12, 0, 6), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
songInfo.TextXAlignment = Enum.TextXAlignment.Left
local scoreInfo = makeLabel(topBar, "ScoreInfo", "Score 0\nCombo 0  Grade -", UDim2.new(0.30, 0, 1, -12), UDim2.new(0.35, 0, 0, 6), Color3.fromRGB(255, 240, 160), Enum.Font.GothamBlack)
local hypeInfo = makeLabel(topBar, "HypeInfo", "Hype 0\nDead Room", UDim2.new(0.26, 0, 1, -12), UDim2.new(0.70, 0, 0, 6), Color3.fromRGB(120, 255, 180), Enum.Font.GothamBlack)
local hudChooseButton = makeButton(root, "HudChooseSong", "Choose Song", UDim2.new(0, 170, 0, 42), UDim2.new(1, -190, 0, 96), Color3.fromRGB(170, 95, 255))

local highway = Instance.new("Frame")
highway.Name = "NoteHighway"
highway.AnchorPoint = Vector2.new(0.5, 0.5)
highway.Position = UserInputService.TouchEnabled and UDim2.new(0.5, 0, 0.43, 0) or UDim2.new(0.5, 0, 0.53, 0)
highway.Size = UDim2.new(0, 500, 0, 500)
highway.BackgroundColor3 = Color3.fromRGB(14, 14, 28)
highway.BackgroundTransparency = 0.06
highway.Parent = root
corner(highway, 18)
stroke(highway, Color3.fromRGB(120, 210, 255), 3)

local laneX = {0.125, 0.375, 0.625, 0.875}
local laneKeys = {
    Config.Lanes[1].symbol or Config.Lanes[1].key,
    Config.Lanes[2].symbol or Config.Lanes[2].key,
    Config.Lanes[3].symbol or Config.Lanes[3].key,
    Config.Lanes[4].symbol or Config.Lanes[4].key,
}
local openSongSelect
local openStore
local function routeMenu(menuName, fallback)
    local controller = _G.GTH_UIUXMenuController
    if controller and controller.openMenu then
        controller.openMenu(menuName)
    elseif fallback then
        fallback()
    end
end

local laneColors = {
    Color3.fromRGB(80, 210, 255),
    Color3.fromRGB(140, 255, 150),
    Color3.fromRGB(255, 215, 80),
    Color3.fromRGB(255, 110, 210),
}
local laneFlashLayer = Instance.new("Frame")
laneFlashLayer.Name = "LaneFlashLayer"
laneFlashLayer.BackgroundTransparency = 1
laneFlashLayer.Size = UDim2.fromScale(1, 1)
laneFlashLayer.Parent = highway

for lane = 1, 4 do
    local laneFrame = Instance.new("TextButton")
    laneFrame.Name = "Lane" .. lane
    laneFrame.Text = ""
    laneFrame.AutoButtonColor = false
    laneFrame.Size = UDim2.new(0.23, 0, 1, -18)
    laneFrame.Position = UDim2.new((lane - 1) * 0.25 + 0.0125, 0, 0, 9)
    laneFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 50)
    laneFrame.BackgroundTransparency = 0.12
    laneFrame.Parent = highway
    corner(laneFrame, 12)
    laneFrame.Activated:Connect(function()
        local original = laneFrame.BackgroundColor3
        laneFrame.BackgroundColor3 = laneColors[lane]
        TweenService:Create(laneFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { BackgroundColor3 = original }):Play()
        inputBus:Fire({ lane = lane, source = "TouchLane" })
    end)
    makeLabel(laneFrame, "Key", laneKeys[lane], UDim2.new(1, 0, 0, 42), UDim2.new(0, 0, 1, -46), laneColors[lane], Enum.Font.GothamBlack)
end

local hitLine = Instance.new("Frame")
hitLine.Name = "HitLine"
hitLine.Size = UDim2.new(1, -20, 0, 8)
hitLine.Position = UDim2.new(0, 10, 0.78, 0)
hitLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hitLine.Parent = highway
corner(hitLine, 4)
stroke(hitLine, Color3.fromRGB(255, 255, 255), 1)

local songProgressBack = Instance.new("Frame")
songProgressBack.Name = "SongProgressBack"
songProgressBack.Size = UDim2.new(1, -20, 0, 8)
songProgressBack.Position = UDim2.new(0, 10, 0, -16)
songProgressBack.BackgroundColor3 = Color3.fromRGB(40, 45, 70)
songProgressBack.Parent = highway
corner(songProgressBack, 4)
local songProgressFill = Instance.new("Frame")
songProgressFill.Name = "SongProgressFill"
songProgressFill.Size = UDim2.fromScale(0, 1)
songProgressFill.BackgroundColor3 = Color3.fromRGB(120, 255, 180)
songProgressFill.Parent = songProgressBack
corner(songProgressFill, 4)

local judgement = makeLabel(root, "Judgement", "", UDim2.new(0, 520, 0, 82), UDim2.new(0.5, -260, 0.16, 0), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
judgement.TextStrokeTransparency = 0.35
judgement.TextTransparency = 1

local comboFx = makeLabel(root, "ComboStreak", "", UDim2.new(0, 700, 0, 90), UDim2.new(0.5, -350, 0.27, 0), Color3.fromRGB(255, 245, 120), Enum.Font.GothamBlack)
comboFx.TextTransparency = 1

local bottomHint = makeLabel(root, "BottomHint", "Tap/click lanes or press ←  →  ↑  ↓  •  Combo streaks blast the horde!", UDim2.new(1, -40, 0, 44), UDim2.new(0, 20, 0.91, 0), Color3.fromRGB(230, 240, 255), Enum.Font.GothamBold)

local noteLegend = Instance.new("Frame")
noteLegend.Name = "AlwaysVisibleNoteLegend"
noteLegend.Size = UDim2.new(0, 270, 0, 150)
noteLegend.Position = UDim2.new(1, -292, 0, 104)
noteLegend.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
noteLegend.BackgroundTransparency = 0.08
noteLegend.Parent = root
corner(noteLegend, 16)
stroke(noteLegend, Color3.fromRGB(255, 230, 120), 2)
makeLabel(noteLegend, "LegendTitle", "NOTES / LANES", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 8), Color3.fromRGB(255, 245, 150), Enum.Font.GothamBlack)
local legendNames = { "Blue note", "Green note", "Gold note", "Pink note" }
for lane = 1, 4 do
    local chip = Instance.new("Frame")
    chip.Name = "Lane" .. lane .. "Legend"
    chip.Size = UDim2.new(1, -20, 0, 24)
    chip.Position = UDim2.new(0, 10, 0, 34 + ((lane - 1) * 27))
    chip.BackgroundTransparency = 1
    chip.Parent = noteLegend

    local dot = Instance.new("Frame")
    dot.Name = "Color"
    dot.Size = UDim2.new(0, 22, 0, 22)
    dot.Position = UDim2.new(0, 0, 0, 1)
    dot.BackgroundColor3 = laneColors[lane]
    dot.Parent = chip
    corner(dot, 7)

    local text = makeLabel(chip, "Text", string.format("%s  =  %s", laneKeys[lane], legendNames[lane]), UDim2.new(1, -32, 1, 0), UDim2.new(0, 32, 0, 0), Color3.fromRGB(235, 245, 255), Enum.Font.GothamBold)
    text.TextXAlignment = Enum.TextXAlignment.Left
end

local touchMenu = Instance.new("Frame")
touchMenu.Name = "NavigationMenu"
touchMenu.AnchorPoint = Vector2.new(1, 0.5)
touchMenu.Position = UDim2.new(1, -16, 0.52, 0)
touchMenu.Size = UDim2.new(0, 160, 0, 310)
touchMenu.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
touchMenu.BackgroundTransparency = 0.15
touchMenu.Parent = root
corner(touchMenu, 18)
stroke(touchMenu, Color3.fromRGB(170, 95, 255), 2)

local navigationMenuScale = Instance.new("UIScale")
navigationMenuScale.Name = "Scale"
navigationMenuScale.Parent = touchMenu

local touchLayout = Instance.new("UIListLayout")
touchLayout.FillDirection = Enum.FillDirection.Vertical
touchLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
touchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
touchLayout.Padding = UDim.new(0, 8)
touchLayout.Parent = touchMenu

local function makeNavButton(text, onClick, color)
    local btn = makeButton(touchMenu, "NavBtn_" .. text:gsub("%s+", ""), text, UDim2.new(0.88, 0, 0, 40), UDim2.new(0, 0, 0, 0), color)
    btn.Activated:Connect(onClick)
    return btn
end

makeNavButton("Choose Song", function() routeMenu("SongSelect", openSongSelect) end, Color3.fromRGB(170, 95, 255))
makeNavButton("Store", function() routeMenu("Store", function() openStore("Tube Sounds") end) end, Color3.fromRGB(55, 145, 255))
makeNavButton("Upgrades", function() routeMenu("Upgrades", function() openStore("Upgrades") end) end, Color3.fromRGB(255, 175, 70))
makeNavButton("Missions", function() routeMenu("Missions", function() openStore("Missions") end) end, Color3.fromRGB(120, 200, 95))
makeNavButton("Security", function() routeMenu("Security", function() openStore("Security") end) end, Color3.fromRGB(255, 90, 90))
makeNavButton("Tutorial", function() routeMenu("Tutorial", function() openStore("Tutorial") end) end, Color3.fromRGB(90, 210, 220))
makeNavButton("Hype", function()
    local controller = _G.GTH_UIUXMenuController
    if controller and controller.openMenu then controller.openMenu("Hype"); return end
    local audienceGui = playerGui:FindFirstChild("AudienceGui")
    if audienceGui then
        audienceGui:SetAttribute("Open", true)
    end
end, Color3.fromRGB(110, 110, 150))

local function setPerformanceUiVisible(visible)
    topBar.Visible = visible
    highway.Visible = visible
    bottomHint.Visible = visible
    noteLegend.Visible = visible
    judgement.Visible = visible
    touchMenu.Visible = not visible
    hudChooseButton.Visible = not visible
end

setPerformanceUiVisible(false)

local songSelect = Instance.new("Frame")
songSelect.Name = "SongSelectModal"
songSelect.AnchorPoint = Vector2.new(0.5, 0.5)
songSelect.Position = UDim2.fromScale(0.5, 0.5)
songSelect.Size = UDim2.new(0.92, 0, 0.86, 0)
songSelect.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
songSelect.BackgroundTransparency = 0.16
songSelect.Visible = false
songSelect.Parent = root
local songSelectSize = Instance.new("UISizeConstraint")
songSelectSize.Name = "ResponsiveBounds"
songSelectSize.MaxSize = Vector2.new(680, 650)
songSelectSize.MinSize = Vector2.new(320, 280)
songSelectSize.Parent = songSelect
corner(songSelect, 22)
stroke(songSelect, Color3.fromRGB(80, 225, 255), 3)
makeLabel(songSelect, "Title", "Choose a Song", UDim2.new(1, -176, 0, 42), UDim2.new(0, 20, 0, 12), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
local closeSongSelect = makeButton(songSelect, "CloseSongSelect", "X", UDim2.new(0, 50, 0, 46), UDim2.new(1, -64, 0, 14), Color3.fromRGB(255, 95, 95))
closeSongSelect.Activated:Connect(function()
    songSelect.Visible = false
    touchMenu.Visible = true
end)
local backSongSelect = makeButton(songSelect, "BackSongSelect", "Back", UDim2.new(0, 86, 0, 40), UDim2.new(1, -158, 0, 17), Color3.fromRGB(90, 110, 145))
backSongSelect.Activated:Connect(function()
    songSelect.Visible = false
    touchMenu.Visible = true
end)
makeLabel(songSelect, "Subtitle", "Choose song, difficulty, and segment. Local/test audio modules are for local testing only. No copyright infringement intended.", UDim2.new(1, -40, 0, 42), UDim2.new(0, 20, 0, 56), Color3.fromRGB(180, 220, 255), Enum.Font.GothamBold)
local selectedDifficulty = "Easy"
local selectedSegment = "30s"
local selectedSection = "Intro"
local difficultyButtons = {}
local segmentButtons = {}
local function refreshOptionButtons()
    for id, button in pairs(difficultyButtons) do
        button.BackgroundColor3 = (id == selectedDifficulty) and Color3.fromRGB(255, 185, 70) or Color3.fromRGB(45, 55, 85)
    end
    for id, button in pairs(segmentButtons) do
        button.BackgroundColor3 = (id == selectedSegment) and Color3.fromRGB(80, 210, 140) or Color3.fromRGB(45, 55, 85)
    end
end

local optionPanel = Instance.new("Frame")
optionPanel.Name = "DifficultySegmentPicker"
optionPanel.Size = UDim2.new(1, -40, 0, 92)
optionPanel.Position = UDim2.new(0, 20, 0, 104)
optionPanel.BackgroundColor3 = Color3.fromRGB(18, 22, 42)
optionPanel.Parent = songSelect
corner(optionPanel, 14)
stroke(optionPanel, Color3.fromRGB(120, 220, 255), 1)
makeLabel(optionPanel, "DiffLabel", "Difficulty", UDim2.new(0, 120, 0, 28), UDim2.new(0, 10, 0, 8), Color3.fromRGB(255, 245, 160), Enum.Font.GothamBlack)
for i, id in ipairs(Config.DifficultyOrder or { "Easy", "Hard", "Extreme", "Brainrot" }) do
    local button = makeButton(optionPanel, "Difficulty" .. id, id, UDim2.new(0, 96, 0, 28), UDim2.new(0, 112 + (i - 1) * 104, 0, 8), Color3.fromRGB(45, 55, 85))
    difficultyButtons[id] = button
    button.Activated:Connect(function() selectedDifficulty = id; refreshOptionButtons() end)
end
makeLabel(optionPanel, "SegLabel", "Segment", UDim2.new(0, 120, 0, 28), UDim2.new(0, 10, 0, 52), Color3.fromRGB(255, 245, 160), Enum.Font.GothamBlack)
local segmentLabels = { ["20s"] = "20s Quick", ["30s"] = "30s Standard", ["40s"] = "40s Long", ["full"] = "Full" }
for i, id in ipairs(Config.SegmentOrder or { "20s", "30s", "40s", "full" }) do
    local button = makeButton(optionPanel, "Segment" .. id, segmentLabels[id] or id, UDim2.new(0, 116, 0, 28), UDim2.new(0, 112 + (i - 1) * 124, 0, 52), Color3.fromRGB(45, 55, 85))
    segmentButtons[id] = button
    button.Activated:Connect(function() selectedSegment = id; refreshOptionButtons() end)
end
refreshOptionButtons()

local songList = Instance.new("ScrollingFrame")
songList.Name = "SongCards"
songList.BackgroundTransparency = 1
songList.Size = UDim2.new(1, -40, 1, -214)
songList.Position = UDim2.new(0, 20, 0, 204)
songList.ScrollBarThickness = 8
songList.CanvasSize = UDim2.new(0, 0, 0, 0)
songList.AutomaticCanvasSize = Enum.AutomaticSize.Y
songList.Parent = songSelect
local songGrid = Instance.new("UIGridLayout")
songGrid.CellSize = UDim2.new(0, 250, 0, 230)
songGrid.CellPadding = UDim2.new(0, 10, 0, 10)
songGrid.SortOrder = Enum.SortOrder.LayoutOrder
songGrid.Parent = songList

local function applySongSelectResponsiveLayout()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local isShort = viewport.Y <= 430
    local isNarrow = viewport.X <= 900
    local width = math.min(680, math.max(320, math.min(viewport.X - 24, viewport.X * (isNarrow and 0.94 or 0.88))))
    local height = math.min(650, math.max(280, math.min(viewport.Y - 24, viewport.Y * (isShort and 0.92 or 0.86))))
    songSelect.Position = UDim2.fromScale(0.5, 0.5)
    songSelect.Size = UDim2.fromOffset(width, height)
    songSelectSize.MaxSize = Vector2.new(math.min(680, viewport.X - 24), math.min(650, viewport.Y - 24))
    optionPanel.Size = UDim2.new(1, -40, 0, isShort and 76 or 92)
    optionPanel.Position = UDim2.new(0, 20, 0, isShort and 88 or 104)
    songList.Position = UDim2.new(0, 20, 0, isShort and 172 or 204)
    songList.Size = UDim2.new(1, -40, 1, isShort and -184 or -214)
    songGrid.CellSize = isNarrow and UDim2.new(1, -12, 0, isShort and 164 or 190) or UDim2.new(0, 250, 0, 230)
end


local results = Instance.new("Frame")
results.Name = "ResultsFrame"
results.AnchorPoint = Vector2.new(0.5, 0.5)
results.Position = UDim2.fromScale(0.5, 0.5)
results.Size = UDim2.new(0.9, 0, 0.84, 0)
results.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
results.BackgroundTransparency = 0.02
results.Visible = false
results.Parent = root
corner(results, 22)
stroke(results, Color3.fromRGB(255, 230, 120), 3)
local resultsSize = Instance.new("UISizeConstraint")
resultsSize.Name = "ResponsiveBounds"
resultsSize.MinSize = Vector2.new(320, 280)
resultsSize.MaxSize = Vector2.new(620, 520)
resultsSize.Parent = results
local closeResults = makeButton(results, "CloseResults", "X", UDim2.new(0, 50, 0, 46), UDim2.new(1, -64, 0, 14), Color3.fromRGB(255, 95, 95))
closeResults.Activated:Connect(function()
    results.Visible = false
end)
local resultsScroll = Instance.new("ScrollingFrame")
resultsScroll.Name = "ResultsScroll"
resultsScroll.BackgroundTransparency = 1
resultsScroll.Size = UDim2.new(1, -40, 1, -130)
resultsScroll.Position = UDim2.new(0, 20, 0, 16)
resultsScroll.ScrollBarThickness = 8
resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
resultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsScroll.Parent = results
local resultsText = makeLabel(resultsScroll, "ResultsText", "", UDim2.new(1, -16, 0, 560), UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
resultsText.AutomaticSize = Enum.AutomaticSize.Y
resultsText.TextYAlignment = Enum.TextYAlignment.Top
local replayButton = makeButton(results, "ContinueButton", "Continue", UDim2.new(0, 130, 0, 48), UDim2.new(0, 28, 1, -70), Color3.fromRGB(55, 145, 255))
local chooseButton = makeButton(results, "ChooseButton", "Choose Another Song", UDim2.new(0, 210, 0, 48), UDim2.new(0, 172, 1, -70), Color3.fromRGB(170, 95, 255))
local backToLobbyButton = makeButton(results, "BackToLobbyButton", "Back to Lobby", UDim2.new(0, 170, 0, 48), UDim2.new(0, 396, 1, -70), Color3.fromRGB(90, 110, 145))
local storeButton = makeButton(results, "StoreButton", "Store", UDim2.new(0, 90, 0, 40), UDim2.new(0, 28, 1, -118), Color3.fromRGB(255, 175, 70))
local upgradeButton = makeButton(results, "UpgradeButton", "Upgrades", UDim2.new(0, 120, 0, 40), UDim2.new(0, 132, 1, -118), Color3.fromRGB(255, 175, 70))
local missionsButton = makeButton(results, "MissionsButton", "Missions", UDim2.new(0, 112, 0, 40), UDim2.new(0, 266, 1, -118), Color3.fromRGB(120, 200, 95))
local busButton = makeButton(results, "HypeButton", "Hype", UDim2.new(0, 124, 0, 40), UDim2.new(0, 392, 1, -118), Color3.fromRGB(90, 210, 220))

local function applyResultsResponsiveLayout()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local isShort = viewport.Y <= 430
    local isNarrow = viewport.X <= 900
    local width = math.min(620, math.max(320, math.min(viewport.X - 24, viewport.X * (isNarrow and 0.94 or 0.9))))
    local height = math.min(520, math.max(280, math.min(viewport.Y - 24, viewport.Y * (isShort and 0.92 or 0.84))))
    results.Position = UDim2.fromScale(0.5, 0.5)
    results.Size = UDim2.fromOffset(width, height)
    resultsSize.MaxSize = Vector2.new(math.min(620, viewport.X - 24), math.min(520, viewport.Y - 24))
    closeResults.Size = UDim2.fromOffset(isShort and 42 or 50, isShort and 38 or 46)
    closeResults.Position = UDim2.new(1, isShort and -52 or -64, 0, isShort and 10 or 14)
    resultsScroll.Position = UDim2.fromOffset(20, isShort and 14 or 16)
    resultsScroll.Size = UDim2.new(1, -40, 1, isShort and -166 or -130)
    if isNarrow then
        replayButton.Size = UDim2.new(0.31, -10, 0, 42)
        replayButton.Position = UDim2.new(0, 18, 1, -52)
        chooseButton.Size = UDim2.new(0.38, -10, 0, 42)
        chooseButton.Position = UDim2.new(0.31, 18, 1, -52)
        backToLobbyButton.Size = UDim2.new(0.31, -18, 0, 42)
        backToLobbyButton.Position = UDim2.new(0.69, 0, 1, -52)
        storeButton.Size = UDim2.new(0.23, -8, 0, 34)
        storeButton.Position = UDim2.new(0, 18, 1, -94)
        upgradeButton.Size = UDim2.new(0.25, -8, 0, 34)
        upgradeButton.Position = UDim2.new(0.24, 18, 1, -94)
        missionsButton.Size = UDim2.new(0.25, -8, 0, 34)
        missionsButton.Position = UDim2.new(0.50, 18, 1, -94)
        busButton.Size = UDim2.new(0.23, -18, 0, 34)
        busButton.Position = UDim2.new(0.76, 0, 1, -94)
    else
        replayButton.Size = UDim2.new(0, 130, 0, 48)
        replayButton.Position = UDim2.new(0, 28, 1, -70)
        chooseButton.Size = UDim2.new(0, 210, 0, 48)
        chooseButton.Position = UDim2.new(0, 172, 1, -70)
        backToLobbyButton.Size = UDim2.new(0, 170, 0, 48)
        backToLobbyButton.Position = UDim2.new(0, 396, 1, -70)
        storeButton.Size = UDim2.new(0, 90, 0, 40)
        storeButton.Position = UDim2.new(0, 28, 1, -118)
        upgradeButton.Size = UDim2.new(0, 120, 0, 40)
        upgradeButton.Position = UDim2.new(0, 132, 1, -118)
        missionsButton.Size = UDim2.new(0, 112, 0, 40)
        missionsButton.Position = UDim2.new(0, 266, 1, -118)
        busButton.Size = UDim2.new(0, 124, 0, 40)
        busButton.Position = UDim2.new(0, 392, 1, -118)
    end
end
applyResultsResponsiveLayout()

local state = {
    active = false,
    sessionId = nil,
    song = nil,
    startServerTime = 0,
    endServerTime = 0,
    notes = {},
    noteFrames = {},
    lastSongId = Config.DefaultSongId,
    lastVenueId = "SchoolStage",
    lastMode = Config.Modes.Career,
    score = 0,
    combo = 0,
    hype = 0,
    hp = 100,
    downed = false,
    grade = "-",
    lastDifficulty = "Easy",
    lastSegment = "30s",
    lastSegmentSection = "Intro",
    highwayTravelSeconds = Config.SongFlow.HighwayTravelSeconds,
}

local songSound = Instance.new("Sound")
songSound.Name = "SongAudioPipe"
local baseSongVolume = 0.65
songSound.Volume = baseSongVolume
songSound.Looped = false
songSound.Parent = SoundService

local function stopSongAudio()
    songSound:Stop()
    songSound.SoundId = ""
end

local function playSongAudio(song)
    stopSongAudio()
    songSound.Volume = baseSongVolume
    local audioId = song and song.AudioId
    if type(audioId) ~= "string" or audioId == "" or audioId == "rbxassetid://0" then
        songInfo.Text = songInfo.Text .. "\nVisual chart mode — no uploaded audio asset."
        return
    end
    songSound.SoundId = audioId
    local delaySeconds = math.max(0, (state.startServerTime or serverNow()) - serverNow())
    task.delay(delaySeconds, function()
        if state.active and state.song == song and songSound.SoundId == audioId then
            songSound.TimePosition = math.max(0, (song.SegmentStart or 0) + serverNow() - (state.startServerTime or serverNow()))
            songSound:Play()
        end
    end)
end

function openStore(tab)
    if tab == "Hype" then
        local audienceGui = playerGui:FindFirstChild("AudienceGui")
        if audienceGui then audienceGui:SetAttribute("Open", true) end
        return
    end
    local storeGui = playerGui:FindFirstChild("StoreGui")
    if storeGui then
        storeGui.Enabled = true
        storeGui:SetAttribute("Open", true)
        storeGui:SetAttribute("Tab", tab or "Upgrades")
    end
end

local function flashLane(lane, color)
    local flash = Instance.new("Frame")
    flash.Name = "Flash" .. lane
    flash.Size = UDim2.new(0.23, 0, 1, -18)
    flash.Position = UDim2.new((lane - 1) * 0.25 + 0.0125, 0, 0, 9)
    flash.BackgroundColor3 = color
    flash.BackgroundTransparency = 0.2
    flash.Parent = laneFlashLayer
    corner(flash, 12)
    TweenService:Create(flash, TweenInfo.new(0.28, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    task.delay(0.32, function()
        if flash then
            flash:Destroy()
        end
    end)
end

local function showJudgement(text, color)
    judgement.Text = text
    judgement.TextColor3 = color
    judgement.TextTransparency = 0
    judgement.Size = UDim2.new(0, 520, 0, 82)
    TweenService:Create(judgement, TweenInfo.new(0.10, Enum.EasingStyle.Back), { Size = UDim2.new(0, 580, 0, 92) }):Play()
    task.delay(0.10, function()
        if judgement then
            TweenService:Create(judgement, TweenInfo.new(0.35), { TextTransparency = 1, Size = UDim2.new(0, 520, 0, 82) }):Play()
        end
    end)
end

local function updateHud(payload)
    state.score = payload.score or state.score
    state.combo = payload.combo or state.combo
    state.hype = payload.hype or state.hype
    state.hp = payload.hp or state.hp
    state.downed = payload.downed or false
    state.grade = payload.grade or state.grade
    scoreInfo.Text = string.format("Score %d\nCombo %d  Grade %s", state.score, state.combo, state.grade)
    local status = state.hp <= 0 and "Disaster" or state.hp < 40 and "Shaky" or "Stable"
    hypeInfo.Text = string.format("Stability %d%%  Hype %d\n%s • %s", state.hp, state.hype, status, payload.hypeTier or "Build the crowd")
    if state.combo > 0 and state.combo % 5 == 0 then
        comboFx.Text = string.format(state.combo >= 20 and "⚡ %d ENCORE BLAST ⚡" or state.combo >= 10 and "🔥 %d HORDE PUSHBACK 🔥" or "✨ %d COMBO STREAK ✨", state.combo)
        comboFx.TextTransparency = 0
        comboFx.Size = UDim2.new(0, 700, 0, 90)
        TweenService:Create(comboFx, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Size = UDim2.new(0, 780, 0, 104) }):Play()
        task.delay(0.55, function()
            if comboFx then
                comboFx.TextTransparency = 1
                comboFx.Size = UDim2.new(0, 700, 0, 90)
            end
        end)
    end
    if payload.lastDamage and payload.lastDamage > 0 then
        showJudgement("-" .. tostring(payload.lastDamage) .. " Stability", Color3.fromRGB(255, 95, 120))
    end
end

local function clearNotes()
    for _, frame in pairs(state.noteFrames) do
        frame:Destroy()
    end
    state.noteFrames = {}
end

local function createNote(note)
    local frame = Instance.new("Frame")
    frame.Name = note.id
    frame.Size = UDim2.new(0.18, 0, 0, 30)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = laneColors[note.lane] or Color3.new(1, 1, 1)
    frame.Visible = false
    frame.Parent = highway
    corner(frame, 10)
    stroke(frame, Color3.fromRGB(255, 255, 255), 1)
    makeLabel(frame, "Lane", laneKeys[note.lane] or tostring(note.lane), UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(10, 12, 24), Enum.Font.GothamBlack)
    state.noteFrames[note.id] = frame
end

local songMeta = {}

local glitchOverlay = Instance.new("Frame")
glitchOverlay.Name = "MissGlitchOverlay"
glitchOverlay.BackgroundColor3 = Color3.fromRGB(255, 40, 90)
glitchOverlay.BackgroundTransparency = 1
glitchOverlay.Size = UDim2.fromScale(1, 1)
glitchOverlay.ZIndex = 50
glitchOverlay.Parent = root

local function playMissGlitch()
    if not Config.MissGlitch or not Config.MissGlitch.enabled then return end
    songSound.Volume = 0
    glitchOverlay.BackgroundTransparency = 0.68
    local original = highway.Position
    highway.Position = original + UDim2.new(0, math.random(-10, 10), 0, math.random(-6, 6))
    TweenService:Create(glitchOverlay, TweenInfo.new(Config.MissGlitch.duration or 0.25), { BackgroundTransparency = 1 }):Play()
    task.delay(Config.MissGlitch.duration or 0.25, function()
        if highway then highway.Position = original end
    end)
end

local pendingStartToken = 0
local playerSnapshot = {}

local function startSong(songId)
    state.lastSongId = songId
    state.lastDifficulty = selectedDifficulty
    state.lastSegment = selectedSegment
    state.lastSegmentSection = selectedSection
    results.Visible = false
    songSelect.Visible = false
    pendingStartToken = pendingStartToken + 1
    local token = pendingStartToken
    songInfo.Text = "Starting song...\n" .. tostring(songId)
    showJudgement("Starting...", Color3.fromRGB(255, 245, 150))
    remotes.StartSongRequest:FireServer({
        songId = songId,
        difficulty = selectedDifficulty,
        segmentLength = selectedSegment,
        segmentStart = selectedSection,
        mode = state.lastMode,
        venueId = state.lastVenueId,
    })
    task.delay(4, function()
        if token == pendingStartToken and not state.active and not results.Visible then
            songInfo.Text = "Start did not complete\nPick a song again or use the stage mic."
            openSongSelect()
        end
    end)
end

local function buildSongCards()
    for _, child in ipairs(songList:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    local displaySongs = {}
    for _, song in ipairs(SongCatalog.List(false)) do table.insert(displaySongs, song) end
    for _, song in ipairs(SongCatalog.ListLocalTests and SongCatalog.ListLocalTests() or {}) do table.insert(displaySongs, song) end
    for index, song in ipairs(displaySongs) do
        local isLocalTest = song.CatalogGroup == "LocalTest" or song.LocalTestOnly
        local meta = songMeta[song.Id] or { difficulty = isLocalTest and "Local Test Chart" or "Public Demo", description = isLocalTest and "Imported placeholder chart — not for public release." or "Original Groan Tube Hero stage chart.", reward = "Difficulty × Segment" }
        local card = Instance.new("Frame")
        card.Name = song.Id .. "Card"
        card.LayoutOrder = index
        card.Size = UDim2.new(0, 250, 0, 230)
        card.BackgroundColor3 = Color3.fromRGB(24, 28, 48)
        card.Parent = songList
        corner(card, 18)
        stroke(card, laneColors[((index - 1) % 4) + 1] or Color3.fromRGB(120, 220, 255), 2)
        makeLabel(card, "SongTitle", (isLocalTest and "LOCAL TEST: " or "") .. SongCatalog.PrettyTitle(song), UDim2.new(1, -20, 0, 54), UDim2.new(0, 10, 0, 8), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
        makeLabel(card, "Difficulty", meta.difficulty, UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 0, 66), laneColors[((index - 1) % 4) + 1] or Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
        makeLabel(card, "Desc", meta.description .. "\nSelected: " .. selectedDifficulty .. " • " .. selectedSegment .. "\nReward: " .. meta.reward, UDim2.new(1, -20, 0, 88), UDim2.new(0, 10, 0, 98), Color3.fromRGB(215, 225, 255), Enum.Font.GothamBold)
        local start = makeButton(card, "StartButton", "Start", UDim2.new(1, -34, 0, 36), UDim2.new(0, 17, 1, -44), laneColors[((index - 1) % 4) + 1] or Color3.fromRGB(55, 145, 255))
        start.Activated:Connect(function()
            startSong(song.Id)
        end)
    end
end

buildSongCards()

function openSongSelect()
    applySongSelectResponsiveLayout()
    buildSongCards()
    songSelect.Visible = true
    results.Visible = false
    touchMenu.Visible = false
    setPerformanceUiVisible(false)
    refreshOptionButtons()
    songInfo.Text = "Choose a song\nPick difficulty and 20s/30s/40s/Full segment."
end

local function consumeOpenSongSelectAttribute()
    if screenGui:GetAttribute("OpenSongSelect") then
        screenGui:SetAttribute("OpenSongSelect", false)
        openSongSelect()
    end
end

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if songSelect.Visible then applySongSelectResponsiveLayout() end
        if results.Visible then applyResultsResponsiveLayout() end
    end)
end

screenGui:GetAttributeChangedSignal("OpenSongSelect"):Connect(consumeOpenSongSelectAttribute)
consumeOpenSongSelectAttribute()
if remotes:FindFirstChild("OpenSongSelect") then
    remotes.OpenSongSelect.OnClientEvent:Connect(function()
        openSongSelect()
    end)
end

ProximityPromptService.PromptTriggered:Connect(function(prompt)
    if not prompt or not prompt.Parent then return end
    local name = prompt.Parent.Name
    local stationName = prompt.Parent.Parent and prompt.Parent.Parent.Name or name
    if name == "StartPrompt" or name == "Sign_Start" or name == "GlowingStageMicPrompt" or stationName == "DJ_GroanMaster" then
        openSongSelect()
    elseif name == "StoreKiosk" or name == "Sign_Store" or stationName == "Vendor_Store" then
        openStore("Tube Sounds")
    elseif name == "UpgradeKiosk" or name == "Sign_Upgrades" or stationName == "Vendor_UpgradeEngineer" then
        openStore("Upgrades")
    elseif name == "MissionBoard" or name == "Sign_Missions" or stationName == "MissionOfficer" then
        openStore("Missions")
    elseif stationName == "SecurityManager" then
        openStore("Security")
    elseif stationName == "TutorialGuide" then
        openStore("Tutorial")
    elseif name == "BusBody" or name == "TourBus" or name == "Sign_TourBus" then
        openStore("Tour Bus")
    elseif name == "AudienceZone" or name == "AudienceSign" or name == "Sign_Audience" or stationName == "AudienceHypeManager" then
        local audienceGui = playerGui:FindFirstChild("AudienceGui")
        if audienceGui then
            audienceGui:SetAttribute("Open", true)
        end
    end
end)

replayButton.Activated:Connect(function()
    results.Visible = false
    touchMenu.Visible = true
end)
backToLobbyButton.Activated:Connect(function()
    results.Visible = false
    touchMenu.Visible = true
end)
chooseButton.Activated:Connect(openSongSelect)
hudChooseButton.Activated:Connect(openSongSelect)
upgradeButton.Activated:Connect(function()
    openStore("Upgrades")
end)
missionsButton.Activated:Connect(function()
    openStore("Missions")
end)
storeButton.Activated:Connect(function()
    openStore("Tube Sounds")
end)
busButton.Activated:Connect(function()
    openStore("Hype")
end)

inputBus.Event:Connect(function(payload)
    if type(payload) == "number" then
        payload = { lane = payload, source = "Legacy" }
    end
    if type(payload) ~= "table" or not payload.lane then
        return
    end
    if payload.lane then
        flashLane(payload.lane, Color3.fromRGB(60, 70, 100))
    end
    if not state.active or not state.song then
        return
    end

    if screenGui:GetAttribute("SongActive") ~= true or screenGui:GetAttribute("AcceptInput") ~= true then
        return
    end

    local songTime = serverNow() - state.startServerTime
    local targetNote = nil
    local bestDelta = math.huge
    local candidateWindow = Config.ClientHitCandidateWindow or 0.65
    for _, note in ipairs(state.notes) do
        if not note.hit and note.lane == payload.lane then
            local delta = math.abs(songTime - note.time)
            if delta <= candidateWindow and delta < bestDelta then
                bestDelta = delta
                targetNote = note
            end
        end
    end
    if Config.DebugRhythm then
        print("[RhythmDebug][RhythmClient]", "lane", payload.lane, "source", payload.source, "songTime", songTime, "target", targetNote and targetNote.id or "none", "noteTime", targetNote and targetNote.time or "-", "bestDelta", bestDelta)
    end
    if targetNote then
        local clientDelta = songTime - targetNote.time
        remotes.NoteHit:FireServer({
            sessionId = state.sessionId,
            songId = state.song.Id,
            noteId = targetNote.id,
            lane = payload.lane,
            clientSongTime = songTime,
            clientDelta = clientDelta,
        })
    else
        showJudgement("No note!", Color3.fromRGB(255, 120, 120))
    end
end)

remotes.StartSong.OnClientEvent:Connect(function(payload)
    if payload and payload.openSongSelect then
        openSongSelect()
        return
    end
    if type(payload) ~= "table" or not payload.song then
        return
    end

    pendingStartToken = pendingStartToken + 1
    state.active = true
    hudChooseButton.Visible = false
    songSelect.Visible = false
    results.Visible = false
    setPerformanceUiVisible(true)
    state.sessionId = payload.sessionId
    state.song = payload.song
    state.startServerTime = payload.startServerTime or serverNow()
    state.endServerTime = payload.endServerTime or (state.startServerTime + (payload.song.Duration or 30))
    state.notes = payload.song.Notes or {}
    state.score = 0
    state.combo = 0
    state.hype = 0
    state.hp = 100
    state.downed = false
    state.grade = "-"
    state.lastSongId = payload.song.Id
    state.lastDifficulty = payload.difficulty or payload.song.Difficulty or selectedDifficulty
    state.lastSegment = payload.segmentLength or payload.song.SegmentLength or selectedSegment
    state.lastSegmentSection = payload.segmentSection or payload.song.SegmentSection or selectedSection
    state.highwayTravelSeconds = Config.SongFlow.HighwayTravelSeconds / math.max(0.75, ((payload.difficultyConfig and payload.difficultyConfig.noteSpeed) or 1))
    songSelect.Visible = false
    results.Visible = false
    clearNotes()
    for _, note in ipairs(state.notes) do
        note.hit = false
        createNote(note)
    end
    songInfo.Text = string.format("%s\n%s • %s • %s", payload.song.Title, state.lastDifficulty, state.lastSegment, payload.venueId or "School Stage")
    screenGui:SetAttribute("SongActive", true)
    screenGui:SetAttribute("AcceptInput", false)
    local startToken = pendingStartToken
    task.delay(math.max(0, state.startServerTime - serverNow()), function()
        if state.active and pendingStartToken == startToken then
            screenGui:SetAttribute("AcceptInput", true)
        end
    end)
    updateHud({ score = 0, combo = 0, hype = 0, hp = 100, grade = "-", hypeTier = "Dead Room" })
    playSongAudio(payload.song)
end)

remotes.NoteJudged.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then
        return
    end
    for _, note in ipairs(state.notes) do
        if note.id == payload.noteId then
            note.hit = true
            break
        end
    end
    local frame = state.noteFrames[payload.noteId]
    if frame then
        frame:Destroy()
        state.noteFrames[payload.noteId] = nil
    end
    if payload.lane then
        flashLane(payload.lane, laneColors[payload.lane] or Color3.new(1, 1, 1))
    end
    local color = Color3.fromRGB(255, 120, 120)
    if payload.judgement == "Perfect" then
        color = Color3.fromRGB(120, 255, 170)
    elseif payload.judgement == "Good" then
        color = Color3.fromRGB(120, 180, 255)
    end
    showJudgement(payload.judgement or "Miss", color)
    if payload.judgement == "Miss" then
        playMissGlitch()
    elseif payload.judgement == "Perfect" or payload.judgement == "Good" then
        if songSound then
            songSound.Volume = baseSongVolume
        end
    end
end)

remotes.ScoreUpdate.OnClientEvent:Connect(updateHud)
remotes.DataSnapshot.OnClientEvent:Connect(function(snapshot)
    if snapshot then
        playerSnapshot = snapshot
    end
end)

remotes.SongFinished.OnClientEvent:Connect(function(payload)
    state.active = false
    hudChooseButton.Visible = true
    screenGui:SetAttribute("SongActive", false)
    screenGui:SetAttribute("AcceptInput", false)
    stopSongAudio()
    setPerformanceUiVisible(false)
    clearNotes()
    local summary = payload.summary or {}
    local rewards = payload.rewards or {}
    local newBest = rewards.NewBest or rewards.LevelUp or summary.grade == "S"
    resultsText.Text = string.format(
        "%s\n%s • %s • %s\nGrade %s%s   Stability %d%%\nHorde %s %d%%   %s\nScore %d   Accuracy %.1f%%\nPerfect %d   Good %d   Miss %d\nMax Combo %d   Final Hype %d\nMultipliers: Difficulty x%.2f • Segment x%.2f\nVenue Fee -%d Fans\n\nRewards\nFans +%d   Coins +%d\nXP +%d   Tickets +%d\n\n%s",
        payload.song and payload.song.Title or "Song Complete",
        summary.difficulty or state.lastDifficulty or "Easy",
        summary.segmentLabel or state.lastSegment or "30s",
        summary.segmentSection or "Intro",
        summary.grade or "-",
        newBest and "  NEW BEST!" or "",
        summary.hp or 0,
        summary.hordeState or "Far",
        summary.hordeDistance or 100,
        summary.disasterMode and "DISASTER" or "Survived",
        summary.score or 0,
        summary.accuracyPercent or 0,
        summary.perfect or 0,
        summary.good or 0,
        summary.miss or 0,
        summary.maxCombo or 0,
        summary.hype or 0,
        rewards.DifficultyMultiplier or summary.difficultyMultiplier or 1,
        rewards.SegmentMultiplier or summary.segmentMultiplier or 1,
        rewards.VenueFee or 0,
        rewards.Fans or 0,
        rewards.Coins or 0,
        rewards.XP or 0,
        rewards.Tickets or 0,
        "Next: Claim mission rewards, buy Timing, or upgrade the Tour Bus."
    )
    applyResultsResponsiveLayout()
    results.Visible = true
    songInfo.Text = summary.downed and "Song failed — stage stability hit 0\nRetry or buy upgrades." or "Song complete\nReplay, choose another song, or upgrade."
end)

RunService.PreRender:Connect(function()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local factor = math.clamp(math.min(viewport.X / 1280, viewport.Y / 720), 0.48, 1.15)
    scale.Scale = factor
    if navigationMenuScale then
        navigationMenuScale.Scale = factor
    end

    if not state.active or not state.song then
        return
    end
    local songTime = serverNow() - state.startServerTime
    local duration = math.max(1, (state.endServerTime or state.startServerTime + 1) - (state.startServerTime or serverNow()))
    songProgressFill.Size = UDim2.fromScale(math.clamp(songTime / duration, 0, 1), 1)
    if songTime < 0 then
        judgement.TextTransparency = 0
        judgement.Text = tostring(math.ceil(-songTime))
        judgement.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    for _, note in ipairs(state.notes) do
        local frame = state.noteFrames[note.id]
        if frame then
            local progress = 1 - ((note.time - songTime) / (state.highwayTravelSeconds or Config.SongFlow.HighwayTravelSeconds))
            frame.Visible = progress >= -0.05 and progress <= 1.08
            frame.Position = UDim2.new(laneX[note.lane] or 0.5, 0, progress * 0.78, 0)
        end
    end
end)

-- Song select now opens from the stage prompt or Choose Song button so it does not block the game/store view on spawn.
