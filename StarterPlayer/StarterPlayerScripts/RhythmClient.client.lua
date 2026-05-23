local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local SongCatalog = require(ReplicatedStorage.Shared.SongCatalog)
local ClientState = require(ReplicatedStorage.Shared.ClientState)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local inputFolder = playerGui:FindFirstChild("GroanTubeHeroInput") or Instance.new("Folder")
inputFolder.Name = "GroanTubeHeroInput"
inputFolder.Parent = playerGui

local laneInput = inputFolder:FindFirstChild("LaneInput") or Instance.new("BindableEvent")
laneInput.Name = "LaneInput"
laneInput.Parent = inputFolder

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

local screenGui = ensureScreenGui("RhythmGui")
screenGui.Name = "RhythmGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui:SetAttribute("AcceptInput", true)

local inputBus = screenGui:FindFirstChild("InputBus") or Instance.new("BindableEvent")
inputBus.Name = "InputBus"
inputBus.Parent = screenGui

ClientState.SetUi(screenGui)

local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundTransparency = 1
root.Size = UDim2.fromScale(1, 1)
root.Parent = screenGui

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
topBar.BackgroundTransparency = 0.15
topBar.Parent = root

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(0.45, 0, 1, 0)
titleLabel.Position = UDim2.new(0.02, 0, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "Groan Tube Hero"
titleLabel.Parent = topBar

local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Size = UDim2.new(0.48, 0, 1, 0)
statusLabel.Position = UDim2.new(0.5, 0, 0, 0)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(160, 220, 255)
statusLabel.Text = "Ready"
statusLabel.Parent = topBar

local hud = Instance.new("Frame")
hud.Name = "HUD"
hud.BackgroundTransparency = 0.2
hud.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
hud.BorderSizePixel = 0
hud.Size = UDim2.new(0, 320, 0, 130)
hud.Position = UDim2.new(0, 18, 0, 74)
hud.Parent = root

local function makeHudRow(y, name)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -16, 0, 24)
    label.Position = UDim2.new(0, 8, 0, y)
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = name .. ": 0"
    label.Parent = hud
    return label
end

local scoreLabel = makeHudRow(6, "Score")
local comboLabel = makeHudRow(32, "Combo")
local hypeLabel = makeHudRow(58, "Hype")
local gradeLabel = makeHudRow(84, "Grade")
local powerLabel = makeHudRow(110, "Power")

local noteLayer = Instance.new("Frame")
noteLayer.Name = "NoteLayer"
noteLayer.BackgroundTransparency = 1
noteLayer.Size = UDim2.fromScale(1, 1)
noteLayer.Parent = root

local highway = Instance.new("Frame")
highway.Name = "Highway"
highway.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
highway.BackgroundTransparency = 0.15
highway.BorderSizePixel = 0
highway.AnchorPoint = Vector2.new(0.5, 0.5)
highway.Position = UDim2.new(0.52, 0, 0.5, 0)
highway.Size = UDim2.new(0, 420, 0, 440)
highway.Parent = noteLayer

local hitLine = Instance.new("Frame")
hitLine.Name = "HitLine"
hitLine.BorderSizePixel = 0
hitLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hitLine.BackgroundTransparency = 0.15
hitLine.Position = UDim2.new(0, 0, 0.78, 0)
hitLine.Size = UDim2.new(1, 0, 0, 4)
hitLine.Parent = highway

local laneFlashFrame = Instance.new("Frame")
laneFlashFrame.Name = "LaneFlash"
laneFlashFrame.BackgroundTransparency = 1
laneFlashFrame.Size = UDim2.new(1, 0, 1, 0)
laneFlashFrame.Parent = highway

local noteFrames = {}
local laneColumns = {
    UDim2.new(0.02, 0, 0, 0),
    UDim2.new(0.27, 0, 0, 0),
    UDim2.new(0.52, 0, 0, 0),
    UDim2.new(0.77, 0, 0, 0),
}

for lane = 1, 4 do
    local laneFrame = Instance.new("Frame")
    laneFrame.Name = "Lane" .. lane
    laneFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    laneFrame.BackgroundTransparency = 0.35
    laneFrame.BorderSizePixel = 0
    laneFrame.Size = UDim2.new(0.21, 0, 1, 0)
    laneFrame.Position = laneColumns[lane]
    laneFrame.Parent = highway
end

local judgementBanner = Instance.new("TextLabel")
judgementBanner.Name = "Judgement"
judgementBanner.BackgroundTransparency = 1
judgementBanner.AnchorPoint = Vector2.new(0.5, 0.5)
judgementBanner.Position = UDim2.new(0.52, 0, 0.25, 0)
judgementBanner.Size = UDim2.new(0, 400, 0, 70)
judgementBanner.Font = Enum.Font.GothamBlack
judgementBanner.TextScaled = true
judgementBanner.TextColor3 = Color3.fromRGB(255, 255, 255)
judgementBanner.TextStrokeTransparency = 0.25
judgementBanner.Text = ""
judgementBanner.Parent = noteLayer

local resultFrame = Instance.new("Frame")
resultFrame.Name = "Results"
resultFrame.Visible = false
resultFrame.AnchorPoint = Vector2.new(0.5, 0.5)
resultFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
resultFrame.Size = UDim2.new(0, 420, 0, 320)
resultFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
resultFrame.BackgroundTransparency = 0.05
resultFrame.Parent = root

local resultTitle = Instance.new("TextLabel")
resultTitle.BackgroundTransparency = 1
resultTitle.Size = UDim2.new(1, -20, 0, 50)
resultTitle.Position = UDim2.new(0, 10, 0, 10)
resultTitle.Font = Enum.Font.GothamBlack
resultTitle.TextScaled = true
resultTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
resultTitle.Text = "Results"
resultTitle.Parent = resultFrame

local resultText = Instance.new("TextLabel")
resultText.BackgroundTransparency = 1
resultText.Size = UDim2.new(1, -20, 0, 180)
resultText.Position = UDim2.new(0, 10, 0, 60)
resultText.Font = Enum.Font.Gotham
resultText.TextWrapped = true
resultText.TextScaled = true
resultText.TextColor3 = Color3.fromRGB(220, 220, 240)
resultText.Text = ""
resultText.Parent = resultFrame

local replayButton = Instance.new("TextButton")
replayButton.Text = "Replay"
replayButton.Size = UDim2.new(0, 140, 0, 48)
replayButton.Position = UDim2.new(0.5, -150, 1, -64)
replayButton.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
replayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
replayButton.Font = Enum.Font.GothamBlack
replayButton.TextScaled = true
replayButton.Parent = resultFrame

local closeButton = Instance.new("TextButton")
closeButton.Text = "Close"
closeButton.Size = UDim2.new(0, 140, 0, 48)
closeButton.Position = UDim2.new(0.5, 10, 1, -64)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBlack
closeButton.TextScaled = true
closeButton.Parent = resultFrame

local countdownLabel = Instance.new("TextLabel")
countdownLabel.BackgroundTransparency = 1
countdownLabel.AnchorPoint = Vector2.new(0.5, 0.5)
countdownLabel.Position = UDim2.new(0.52, 0, 0.4, 0)
countdownLabel.Size = UDim2.new(0, 260, 0, 70)
countdownLabel.Font = Enum.Font.GothamBlack
countdownLabel.TextScaled = true
countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countdownLabel.Text = ""
countdownLabel.Parent = noteLayer

local songState = {
    active = false,
    sessionId = nil,
    song = nil,
    startServerTime = 0,
    countdownEndTime = 0,
    endServerTime = 0,
    notes = {},
    activeNotes = {},
    noteTemplate = nil,
    localStart = 0,
    mode = Config.Modes.Career,
    replaySongId = Config.DefaultSongId,
    replayVenueId = "SchoolStage",
    replayMode = Config.Modes.Career,
}

local currentSnapshot
ClientState.SetSnapshot = ClientState.SetSnapshot or function(snapshot)
    currentSnapshot = snapshot
end
ClientState.GetSnapshot = ClientState.GetSnapshot or function()
    return currentSnapshot
end

local function getLocalTime()
    if workspace.GetServerTimeNow then
        return workspace:GetServerTimeNow()
    end
    return os.clock()
end

local function clearNotes()
    for _, frame in pairs(noteFrames) do
        frame:Destroy()
    end
    noteFrames = {}
end

local function createNoteFrame(note)
    local frame = Instance.new("Frame")
    frame.Name = note.id
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0.18, 0, 0, 26)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Parent = highway

    local bar = Instance.new("TextLabel")
    bar.BackgroundTransparency = 1
    bar.Size = UDim2.fromScale(1, 1)
    bar.Font = Enum.Font.GothamBold
    bar.TextScaled = true
    bar.TextColor3 = Color3.fromRGB(20, 20, 20)
    bar.Text = tostring(note.lane)
    bar.Parent = frame
    noteFrames[note.id] = frame
    return frame
end

local function setStatus(message)
    statusLabel.Text = message
end

local function flashLane(lane, color, intensity)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 1 - intensity
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0.21, 0, 1, 0)
    frame.Position = laneColumns[lane]
    frame.Parent = laneFlashFrame
    TweenService:Create(frame, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
    task.delay(0.3, function()
        if frame then
            frame:Destroy()
        end
    end)
end

local function judgementText(judgement)
    if judgement == "Perfect" then
        return "PERFECT GROAN"
    elseif judgement == "Good" then
        return "GOOD GROAN"
    elseif judgement == "Miss" then
        return "MISSED"
    end
    return judgement
end

local function showJudgement(judgement, color)
    judgementBanner.Text = judgementText(judgement)
    judgementBanner.TextColor3 = color
    local tween = TweenService:Create(judgementBanner, TweenInfo.new(0.15), { TextTransparency = 0 })
    judgementBanner.TextTransparency = 1
    tween:Play()
    task.delay(0.5, function()
        if judgementBanner then
            judgementBanner.TextTransparency = 1
        end
    end)
end

local function updateHud(state)
    scoreLabel.Text = string.format("Score: %d", state.score or 0)
    comboLabel.Text = string.format("Combo: %d x%.2f", state.combo or 0, state.multiplier or 1)
    hypeLabel.Text = string.format("Hype: %d", state.hype or 0)
    gradeLabel.Text = string.format("Grade: %s", state.grade or "-")
    powerLabel.Text = string.format("Power: %d", state.power or 0)
end

local function rebuildNotes(song)
    clearNotes()
    songState.notes = song.Notes or {}
    songState.activeNotes = {}
    for _, note in ipairs(songState.notes) do
        createNoteFrame(note)
    end
end

local function getSongTime()
    if not songState.active then
        return 0
    end
    return getLocalTime() - songState.startServerTime
end

local function applyVisuals(note, judgement, visuals)
    local color = Color3.fromRGB(255, 255, 255)
    if judgement == "Perfect" then
        color = Color3.fromRGB(120, 255, 170)
        flashLane(note.lane, visuals and visuals.laneFlash or Color3.fromRGB(255, 255, 255), 0.8)
    elseif judgement == "Good" then
        color = Color3.fromRGB(120, 180, 255)
        flashLane(note.lane, visuals and visuals.laneFlash or Color3.fromRGB(255, 255, 255), 0.5)
    else
        color = Color3.fromRGB(255, 120, 120)
    end
    showJudgement(judgement, color)
end

local lastState = { score = 0, combo = 0, hype = 0, grade = "-", power = 0, multiplier = 1 }

remotes.StartSong.OnClientEvent:Connect(function(payload)
    songState.active = true
    songState.sessionId = payload.sessionId
    songState.song = payload.song
    songState.startServerTime = payload.startServerTime or getLocalTime()
    songState.countdownEndTime = payload.countdownEndTime or songState.startServerTime
    songState.endServerTime = payload.endServerTime or (songState.startServerTime + (payload.song and payload.song.Duration or 30))
    songState.mode = payload.mode or Config.Modes.Career
    songState.replaySongId = payload.song and payload.song.Id or Config.DefaultSongId
    songState.replayMode = songState.mode
    songState.replayVenueId = payload.venueId or "SchoolStage"
    rebuildNotes(payload.song or SongCatalog.Get(Config.DefaultSongId))
    resultFrame.Visible = false
    setStatus("Countdown")
    countdownLabel.Text = "3"
end)

remotes.ScoreUpdate.OnClientEvent:Connect(function(payload)
    lastState = payload
    updateHud(payload)
end)

remotes.NoteJudged.OnClientEvent:Connect(function(payload)
    local note = nil
    for _, entry in ipairs(songState.notes) do
        if entry.id == payload.noteId then
            note = entry
            break
        end
    end
    if note then
        applyVisuals(note, payload.judgement, payload.visuals)
        local frame = noteFrames[note.id]
        if frame then
            frame:Destroy()
            noteFrames[note.id] = nil
        end
    end
end)

remotes.SongFinished.OnClientEvent:Connect(function(payload)
    songState.active = false
    local summary = payload.summary or {}
    local rewards = payload.rewards or {}
    resultFrame.Visible = true
    resultText.Text = string.format(
        "Song: %s\nGrade: %s\nScore: %d\nMax Combo: %d\nHype: %d\nFans +%d\nCoins +%d\nXP +%d\nTickets +%d",
        payload.song and payload.song.Title or "Song",
        summary.grade or "-",
        summary.score or 0,
        summary.maxCombo or 0,
        summary.hype or 0,
        rewards.Fans or 0,
        rewards.Coins or 0,
        rewards.XP or 0,
        rewards.Tickets or 0
    )
    countdownLabel.Text = ""
    setStatus("Finished")
end)

local function startReplay()
    if not songState.replaySongId then
        return
    end
    remotes.StartSongRequest:FireServer({
        songId = songState.replaySongId,
        mode = songState.replayMode,
        venueId = songState.replayVenueId,
    })
end

replayButton.Activated:Connect(startReplay)
closeButton.Activated:Connect(function()
    resultFrame.Visible = false
end)

inputBus.Event:Connect(function(payload)
    if type(payload) == "number" then
        payload = { lane = payload, source = "Legacy" }
    end
    if type(payload) ~= "table" or not payload.lane then
        return
    end
    if not songState.active then
        return
    end
    local songTime = getSongTime()
    local lane = payload.lane
    if not lane then
        return
    end
    local targetNote = nil
    local bestDelta = math.huge
    for _, note in ipairs(songState.notes) do
        if note.lane == lane and not note.hit then
            local delta = math.abs(songTime - note.time)
            if delta < bestDelta then
                bestDelta = delta
                targetNote = note
            end
        end
    end
    if targetNote then
        remotes.NoteHit:FireServer({
            songId = songState.song and songState.song.Id or Config.DefaultSongId,
            noteId = targetNote.id,
            lane = lane,
            songTime = songTime,
        })
    end
end)

local countdownStart = 0
RunService.PreRender:Connect(function()
    local songTime = getSongTime()
    if songState.active then
        local remaining = math.max(0, songState.countdownEndTime - getLocalTime())
        if remaining > 0 then
            countdownLabel.Text = tostring(math.ceil(remaining))
        else
            countdownLabel.Text = ""
        end
        for _, note in ipairs(songState.notes) do
            local frame = noteFrames[note.id]
            if frame then
                local visible = songTime >= (note.time - Config.SongFlow.SpawnLeadSeconds) and songTime <= note.time + 0.65
                frame.Visible = visible
                if visible then
                    local progress = 1 - ((note.time - songTime) / Config.SongFlow.HighwayTravelSeconds)
                    local y = math.clamp(progress, 0, 1)
                    local laneX = (laneColumns[note.lane].X.Scale or 0) + 0.095
                    frame.Position = UDim2.new(laneX, 0, y * 0.78, 0)
                    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
        if getLocalTime() > songState.endServerTime + 1 then
            setStatus("Song Ended")
        else
            setStatus(songState.mode .. " | " .. (songState.song and songState.song.Title or ""))
        end
    end
end)

remotes.DataSnapshot.OnClientEvent:Connect(function(snapshot)
    ClientState.SetSnapshot(snapshot)
    if snapshot and snapshot.Equipped then
        local visuals = require(ReplicatedStorage.Shared.CosmeticConfig).GetVisualProfile(snapshot.Equipped)
        scoreLabel.TextColor3 = visuals.laneFlash or Color3.fromRGB(255, 255, 255)
    end
end)
