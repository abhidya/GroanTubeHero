local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

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
    gui.IgnoreGuiInset = true
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
screenGui:SetAttribute("AcceptInput", true)
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
highway.Position = UDim2.new(0.5, 0, 0.53, 0)
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
    local laneFrame = Instance.new("Frame")
    laneFrame.Name = "Lane" .. lane
    laneFrame.Size = UDim2.new(0.23, 0, 1, -18)
    laneFrame.Position = UDim2.new((lane - 1) * 0.25 + 0.0125, 0, 0, 9)
    laneFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 50)
    laneFrame.BackgroundTransparency = 0.12
    laneFrame.Parent = highway
    corner(laneFrame, 12)
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

local judgement = makeLabel(root, "Judgement", "", UDim2.new(0, 520, 0, 82), UDim2.new(0.5, -260, 0.16, 0), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
judgement.TextStrokeTransparency = 0.35
judgement.TextTransparency = 1

local bottomHint = makeLabel(root, "BottomHint", "Hit ←  →  ↑  ↓  •  Arrow keys are captured during songs  •  Build Combo + Hype!", UDim2.new(1, -40, 0, 44), UDim2.new(0, 20, 0.91, 0), Color3.fromRGB(230, 240, 255), Enum.Font.GothamBold)

local noteLegend = Instance.new("Frame")
noteLegend.Name = "AlwaysVisibleNoteLegend"
noteLegend.Size = UDim2.new(0, 270, 0, 150)
noteLegend.Position = UDim2.new(1, -292, 0, 104)
noteLegend.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
noteLegend.BackgroundTransparency = 0.08
noteLegend.Parent = root
corner(noteLegend, 16)
stroke(noteLegend, Color3.fromRGB(255, 230, 120), 2)
makeLabel(noteLegend, "LegendTitle", "NOTES / KEYS", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 8), Color3.fromRGB(255, 245, 150), Enum.Font.GothamBlack)
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

local function setPerformanceUiVisible(visible)
    topBar.Visible = visible
    highway.Visible = visible
    bottomHint.Visible = visible
    noteLegend.Visible = visible
    judgement.Visible = visible
end

setPerformanceUiVisible(false)

local songSelect = Instance.new("Frame")
songSelect.Name = "SongSelectModal"
songSelect.AnchorPoint = Vector2.new(1, 0.5)
songSelect.Position = UDim2.new(1, -18, 0.55, 0)
songSelect.Size = UDim2.new(0, 520, 0, 560)
songSelect.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
songSelect.BackgroundTransparency = 0.16
songSelect.Visible = false
songSelect.Parent = root
corner(songSelect, 22)
stroke(songSelect, Color3.fromRGB(80, 225, 255), 3)
makeLabel(songSelect, "Title", "Song List", UDim2.new(1, -40, 0, 42), UDim2.new(0, 20, 0, 12), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
makeLabel(songSelect, "Subtitle", "Pick a stage song. Visual charts work even without uploaded audio assets.", UDim2.new(1, -40, 0, 42), UDim2.new(0, 20, 0, 56), Color3.fromRGB(180, 220, 255), Enum.Font.GothamBold)
local songList = Instance.new("ScrollingFrame")
songList.Name = "SongCards"
songList.BackgroundTransparency = 1
songList.Size = UDim2.new(1, -40, 1, -116)
songList.Position = UDim2.new(0, 20, 0, 104)
songList.ScrollBarThickness = 8
songList.CanvasSize = UDim2.new(0, 0, 0, 0)
songList.AutomaticCanvasSize = Enum.AutomaticSize.Y
songList.Parent = songSelect
local songGrid = Instance.new("UIGridLayout")
songGrid.CellSize = UDim2.new(0, 220, 0, 210)
songGrid.CellPadding = UDim2.new(0, 12, 0, 12)
songGrid.SortOrder = Enum.SortOrder.LayoutOrder
songGrid.Parent = songList

local results = Instance.new("Frame")
results.Name = "ResultsFrame"
results.AnchorPoint = Vector2.new(0.5, 0.5)
results.Position = UDim2.new(0.5, 0, 0.5, 0)
results.Size = UDim2.new(0, 620, 0, 460)
results.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
results.BackgroundTransparency = 0.02
results.Visible = false
results.Parent = root
corner(results, 22)
stroke(results, Color3.fromRGB(255, 230, 120), 3)
local resultsText = makeLabel(results, "ResultsText", "", UDim2.new(1, -40, 1, -130), UDim2.new(0, 20, 0, 16), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
local replayButton = makeButton(results, "ReplayButton", "Replay", UDim2.new(0, 130, 0, 48), UDim2.new(0, 28, 1, -70), Color3.fromRGB(55, 145, 255))
local chooseButton = makeButton(results, "ChooseButton", "Choose Song", UDim2.new(0, 170, 0, 48), UDim2.new(0, 172, 1, -70), Color3.fromRGB(170, 95, 255))
local storeButton = makeButton(results, "StoreButton", "Store", UDim2.new(0, 90, 0, 48), UDim2.new(0, 356, 1, -70), Color3.fromRGB(255, 175, 70))
local upgradeButton = makeButton(results, "UpgradeButton", "Upgrades", UDim2.new(0, 120, 0, 48), UDim2.new(0, 456, 1, -70), Color3.fromRGB(255, 175, 70))
local missionsButton = makeButton(results, "MissionsButton", "Missions", UDim2.new(0, 112, 0, 40), UDim2.new(0, 28, 1, -118), Color3.fromRGB(120, 200, 95))
local busButton = makeButton(results, "TourBusButton", "Tour Bus", UDim2.new(0, 124, 0, 40), UDim2.new(0, 152, 1, -118), Color3.fromRGB(90, 210, 220))

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
}

local songSound = Instance.new("Sound")
songSound.Name = "SongAudioPipe"
songSound.Volume = 0.65
songSound.Looped = false
songSound.Parent = SoundService

local function stopSongAudio()
    songSound:Stop()
    songSound.SoundId = ""
end

local function playSongAudio(song)
    stopSongAudio()
    local audioId = song and song.AudioId
    if type(audioId) ~= "string" or audioId == "" or audioId == "rbxassetid://0" then
        songInfo.Text = songInfo.Text .. "\nVisual chart mode — no uploaded audio asset."
        return
    end
    songSound.SoundId = audioId
    local delaySeconds = math.max(0, (state.startServerTime or serverNow()) - serverNow())
    task.delay(delaySeconds, function()
        if state.active and state.song == song and songSound.SoundId == audioId then
            songSound.TimePosition = math.max(0, serverNow() - (state.startServerTime or serverNow()))
            songSound:Play()
        end
    end)
end

local function openStore(tab)
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
    hypeInfo.Text = string.format("HP %d  Hype %d\n%s", state.hp, state.hype, payload.hypeTier or "Build the crowd")
    if payload.lastDamage and payload.lastDamage > 0 then
        showJudgement("-" .. tostring(payload.lastDamage) .. " HP", Color3.fromRGB(255, 95, 120))
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

local songMeta = {
    NeonGroan = { difficulty = "Easy", description = "Learn the basics.", reward = "~45 Fans / 35 Coins / 60 XP" },
    RomanticTubeDisaster = { difficulty = "Normal", description = "Dramatic groans and big chorus moments.", reward = "~70 Fans / 55 Coins / 85 XP" },
    MallBalladButWrong = { difficulty = "Hard", description = "Awkward pauses and cursed timing.", reward = "~100 Fans / 75 Coins / 120 XP" },
}

local pendingStartToken = 0
local playerSnapshot = {}
local openSongSelect

local function startSong(songId)
    state.lastSongId = songId
    results.Visible = false
    songSelect.Visible = false
    pendingStartToken = pendingStartToken + 1
    local token = pendingStartToken
    songInfo.Text = "Starting song...\n" .. tostring(songId)
    showJudgement("Starting...", Color3.fromRGB(255, 245, 150))
    remotes.StartSongRequest:FireServer({ songId = songId, mode = state.lastMode, venueId = state.lastVenueId })
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
    for index, song in ipairs(SongCatalog.List()) do
        local meta = songMeta[song.Id] or { difficulty = "Normal", description = "Stage performance chart.", reward = "Rewards after song" }
        local card = Instance.new("Frame")
        card.Name = song.Id .. "Card"
        card.LayoutOrder = index
        card.Size = UDim2.new(0, 220, 0, 210)
        card.BackgroundColor3 = Color3.fromRGB(24, 28, 48)
        card.Parent = songList
        corner(card, 18)
        stroke(card, laneColors[((index - 1) % 4) + 1] or Color3.fromRGB(120, 220, 255), 2)
        makeLabel(card, "SongTitle", song.Title, UDim2.new(1, -20, 0, 46), UDim2.new(0, 10, 0, 10), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
        makeLabel(card, "Difficulty", meta.difficulty, UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 60), laneColors[((index - 1) % 4) + 1] or Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack)
        makeLabel(card, "Desc", meta.description .. "\nRewards: " .. meta.reward, UDim2.new(1, -20, 0, 72), UDim2.new(0, 10, 0, 92), Color3.fromRGB(215, 225, 255), Enum.Font.GothamBold)
        local start = makeButton(card, "StartButton", "Start", UDim2.new(1, -34, 0, 38), UDim2.new(0, 17, 1, -48), laneColors[((index - 1) % 4) + 1] or Color3.fromRGB(55, 145, 255))
        start.Activated:Connect(function()
            startSong(song.Id)
        end)
    end
end

buildSongCards()

function openSongSelect()
    buildSongCards()
    songSelect.Visible = true
    results.Visible = false
    setPerformanceUiVisible(false)
    songInfo.Text = "Choose a song\nStart with Neon Groan if new."
end

local function consumeOpenSongSelectAttribute()
    if screenGui:GetAttribute("OpenSongSelect") then
        screenGui:SetAttribute("OpenSongSelect", false)
        openSongSelect()
    end
end

screenGui:GetAttributeChangedSignal("OpenSongSelect"):Connect(consumeOpenSongSelectAttribute)
consumeOpenSongSelectAttribute()
if remotes:FindFirstChild("OpenSongSelect") then
    remotes.OpenSongSelect.OnClientEvent:Connect(function()
        openSongSelect()
    end)
end

replayButton.Activated:Connect(function()
    startSong(state.lastSongId)
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
    openStore("Tour Bus")
end)

inputBus.Event:Connect(function(payload)
    if type(payload) == "number" then
        payload = { lane = payload, source = "Legacy" }
    end
    if type(payload) ~= "table" or not payload.lane then
        return
    end
    if not state.active or not state.song then
        return
    end

    local songTime = serverNow() - state.startServerTime
    local targetNote = nil
    local bestDelta = math.huge
    for _, note in ipairs(state.notes) do
        if not note.hit and note.lane == payload.lane then
            local delta = math.abs(songTime - note.time)
            if delta < bestDelta then
                bestDelta = delta
                targetNote = note
            end
        end
    end
    if targetNote then
        remotes.NoteHit:FireServer({
            songId = state.song.Id,
            noteId = targetNote.id,
            lane = payload.lane,
            songTime = songTime,
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
    songSelect.Visible = false
    results.Visible = false
    clearNotes()
    for _, note in ipairs(state.notes) do
        note.hit = false
        createNote(note)
    end
    songInfo.Text = string.format("%s\n%s • %s", payload.song.Title, songMeta[payload.song.Id] and songMeta[payload.song.Id].difficulty or "Normal", payload.venueId or "School Stage")
    screenGui:SetAttribute("SongActive", true)
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
    stopSongAudio()
    setPerformanceUiVisible(false)
    clearNotes()
    local summary = payload.summary or {}
    local rewards = payload.rewards or {}
    local newBest = rewards.NewBest or rewards.LevelUp or summary.grade == "S"
    resultsText.Text = string.format(
        "%s\nGrade %s%s   HP %d\nScore %d   Accuracy %.1f%%\nPerfect %d   Good %d   Miss %d\nMax Combo %d   Final Hype %d\n\nRewards\nFans +%d   Coins +%d\nXP +%d   Tickets +%d\n\n%s",
        payload.song and payload.song.Title or "Song Complete",
        summary.grade or "-",
        newBest and "  NEW BEST!" or "",
        summary.hp or 0,
        summary.score or 0,
        summary.accuracyPercent or 0,
        summary.perfect or 0,
        summary.good or 0,
        summary.miss or 0,
        summary.maxCombo or 0,
        summary.hype or 0,
        rewards.Fans or 0,
        rewards.Coins or 0,
        rewards.XP or 0,
        rewards.Tickets or 0,
        "Next: Claim mission rewards, buy Timing, or upgrade the Tour Bus."
    )
    results.Visible = true
    songInfo.Text = summary.downed and "Song failed — stage stability hit 0\nRetry or buy upgrades." or "Song complete\nReplay, choose another song, or upgrade."
end)

RunService.PreRender:Connect(function()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    scale.Scale = math.clamp(math.min(viewport.X / 1280, viewport.Y / 720), 0.78, 1.15)

    if not state.active or not state.song then
        return
    end
    local songTime = serverNow() - state.startServerTime
    if songTime < 0 then
        judgement.TextTransparency = 0
        judgement.Text = tostring(math.ceil(-songTime))
        judgement.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    for _, note in ipairs(state.notes) do
        local frame = state.noteFrames[note.id]
        if frame then
            local progress = 1 - ((note.time - songTime) / Config.SongFlow.HighwayTravelSeconds)
            frame.Visible = progress >= -0.05 and progress <= 1.08
            frame.Position = UDim2.new(laneX[note.lane] or 0.5, 0, math.clamp(progress, 0, 1) * 0.78, 0)
        end
    end
end)

-- Song select now opens from the stage prompt or Choose Song button so it does not block the game/store view on spawn.
