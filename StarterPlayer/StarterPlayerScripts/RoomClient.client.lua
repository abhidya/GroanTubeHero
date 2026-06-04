local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "RoomQueueGui"
gui.IgnoreGuiInset = false
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "RoomPanel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -16, 0, 148)
panel.Size = UDim2.new(0, 384, 0, 392)
panel.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
panel.BackgroundTransparency = 0.08
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120, 240, 255)
stroke.Thickness = 2
stroke.Parent = panel

local panelScale = Instance.new("UIScale")
panelScale.Name = "RoomBoardResponsiveScale"
panelScale.Parent = panel

local songChip = Instance.new("Frame")
songChip.Name = "RoomSongStatusChip"
songChip.AnchorPoint = Vector2.new(1, 1)
songChip.Position = UDim2.new(1, -18, 1, -86)
songChip.Size = UDim2.new(0, 352, 0, 54)
songChip.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
songChip.BackgroundTransparency = 0.05
songChip.Visible = false
songChip.Parent = gui

local songChipCorner = Instance.new("UICorner")
songChipCorner.CornerRadius = UDim.new(0, 8)
songChipCorner.Parent = songChip

local songChipStroke = Instance.new("UIStroke")
songChipStroke.Color = Color3.fromRGB(120, 255, 190)
songChipStroke.Thickness = 2
songChipStroke.Parent = songChip

local songChipScale = Instance.new("UIScale")
songChipScale.Name = "RoomSongStatusChipResponsiveScale"
songChipScale.Parent = songChip

local songChipTitle = Instance.new("TextLabel")
songChipTitle.Name = "RoomSongStatusTitle"
songChipTitle.BackgroundTransparency = 1
songChipTitle.Position = UDim2.new(0, 12, 0, 5)
songChipTitle.Size = UDim2.new(1, -24, 0, 22)
songChipTitle.Text = "Room"
songChipTitle.TextColor3 = Color3.fromRGB(245, 250, 255)
songChipTitle.TextScaled = true
songChipTitle.TextXAlignment = Enum.TextXAlignment.Left
songChipTitle.Font = Enum.Font.GothamBlack
songChipTitle.Parent = songChip

local songChipDetail = Instance.new("TextLabel")
songChipDetail.Name = "RoomSongStatusDetail"
songChipDetail.BackgroundTransparency = 1
songChipDetail.Position = UDim2.new(0, 12, 0, 28)
songChipDetail.Size = UDim2.new(1, -24, 0, 20)
songChipDetail.Text = ""
songChipDetail.TextColor3 = Color3.fromRGB(210, 240, 255)
songChipDetail.TextScaled = true
songChipDetail.TextXAlignment = Enum.TextXAlignment.Left
songChipDetail.Font = Enum.Font.GothamBold
songChipDetail.Parent = songChip

local function refreshPanelScale()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    if viewport.X < 460 then
        panelScale.Scale = math.max(0.76, viewport.X / 440)
    elseif viewport.Y < 620 then
        panelScale.Scale = 0.88
    else
        panelScale.Scale = 1
    end
    if viewport.X < 560 then
        songChipScale.Scale = math.max(0.72, viewport.X / 520)
    elseif viewport.Y < 620 then
        songChipScale.Scale = 0.88
    else
        songChipScale.Scale = 1
    end
end

refreshPanelScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshPanelScale)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    refreshPanelScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshPanelScale)
    end
end)

local header = Instance.new("Frame")
header.Name = "RoomBoardHeader"
header.BackgroundTransparency = 1
header.Position = UDim2.new(0, 12, 0, 8)
header.Size = UDim2.new(1, -24, 0, 62)
header.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "RoomTitle"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 0, 0, 0)
title.Size = UDim2.new(1, -96, 0, 30)
title.Text = "Rooms"
title.TextColor3 = Color3.fromRGB(245, 250, 255)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.Parent = header

local leave = Instance.new("TextButton")
leave.Name = "LeaveRoom"
leave.AnchorPoint = Vector2.new(1, 0)
leave.Position = UDim2.new(1, 0, 0, 2)
leave.Size = UDim2.new(0, 86, 0, 28)
leave.BackgroundColor3 = Color3.fromRGB(28, 34, 56)
leave.Text = "Leave"
leave.TextColor3 = Color3.fromRGB(255, 235, 235)
leave.TextScaled = true
leave.Font = Enum.Font.GothamBold
leave.Visible = false
leave.Parent = header
local leaveCorner = Instance.new("UICorner")
leaveCorner.CornerRadius = UDim.new(0, 8)
leaveCorner.Parent = leave

local detail = Instance.new("TextLabel")
detail.Name = "RoomDetail"
detail.BackgroundTransparency = 1
detail.Position = UDim2.new(0, 0, 0, 34)
detail.Size = UDim2.new(1, 0, 0, 28)
detail.Text = "Pick a themed room."
detail.TextColor3 = Color3.fromRGB(210, 230, 255)
detail.TextScaled = true
detail.TextWrapped = true
detail.TextXAlignment = Enum.TextXAlignment.Left
detail.Font = Enum.Font.GothamBold
detail.Parent = header

local list = Instance.new("ScrollingFrame")
list.Name = "RoomBoardList"
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.Position = UDim2.new(0, 10, 0, 78)
list.Size = UDim2.new(1, -20, 1, -88)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 6
list.ScrollBarImageColor3 = Color3.fromRGB(120, 240, 255)
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local selectedRoomId = nil
local latestSnapshot = nil
local songActive = false
local boundRhythmGui = nil
local songActiveConnection = nil

local function roomOrder(room)
    return tonumber(room and room.index) or 999
end

local function findSelectedRoom(snapshot)
    if type(snapshot) ~= "table" then return nil end
    local selected = snapshot.selectedRoomId
    for _, room in ipairs(snapshot.rooms or {}) do
        if room.playerQueued or room.id == selected then
            return room
        end
    end
    return nil
end

local function describeReward(room)
    local reward = type(room.reward) == "table" and room.reward or {}
    local bonuses = type(reward.bonuses) == "table" and reward.bonuses or {}
    local tickets = tonumber(bonuses.Tickets) or 0
    local ticketText = tickets > 0 and string.format("  +%d tickets", tickets) or ""
    return string.format("x%.2f rewards  +%d fans  +%d coins%s", tonumber(reward.multiplier) or 1, bonuses.Fans or 0, bonuses.Coins or 0, ticketText)
end

local function describeObjectiveProgress(activeSession)
    local objectives = type(activeSession) == "table" and type(activeSession.objectives) == "table" and activeSession.objectives or {}
    local objectiveProgress = math.floor(tonumber(objectives.progress) or tonumber(activeSession and activeSession.objectiveProgress) or 0)
    local objectiveCombo = tonumber(objectives.combo) or tonumber(activeSession and activeSession.objectiveCombo) or 0
    local objectiveMomentum = tonumber(objectives.momentum) or tonumber(activeSession and activeSession.objectiveMomentum) or 0
    if objectiveProgress <= 0 and objectiveCombo <= 0 then
        return "objective 0%"
    end
    return string.format("objective %d%%  combo x%d  momentum %d", objectiveProgress, objectiveCombo, objectiveMomentum)
end

local function describeQueue(room)
    local state = tostring(room.queueState or "empty")
    if state == "active" then
        local active = type(room.activeSession) == "table" and room.activeSession or {}
        return string.format("crew active %d  %s", active.participantCount or room.occupancy or 0, describeObjectiveProgress(active))
    elseif state == "ready" then
        return "ready"
    elseif state == "countdown" then
        return string.format("starts in %ds", tonumber(room.countdownSeconds) or 0)
    elseif state == "waiting" then
        return string.format("needs %d", math.max(0, (room.minPlayers or 1) - (room.occupancy or 0)))
    end
    return string.format("min %d", room.minPlayers or 1)
end

local function refreshSongChip(room, message)
    if room then
        songChipTitle.Text = room.shortName or room.name or "Room"
        local active = type(room.activeSession) == "table" and room.activeSession or nil
        songChipDetail.Text = message or (active and describeObjectiveProgress(active) or describeQueue(room))
    elseif message then
        songChipTitle.Text = "Room"
        songChipDetail.Text = message
    end
end

local function findRhythmScreenGui()
    for _, child in ipairs(playerGui:GetChildren()) do
        if child.Name == "RhythmGui" and child:IsA("ScreenGui") then
            return child
        end
    end
    return nil
end

local function refreshSongActiveState()
    local rhythmGui = boundRhythmGui or findRhythmScreenGui()
    songActive = rhythmGui and rhythmGui:GetAttribute("SongActive") == true or false
    if songActive then
        refreshSongChip(findSelectedRoom(latestSnapshot))
    end
    panel.Visible = not songActive
    songChip.Visible = songActive and selectedRoomId ~= nil
end

local function bindRhythmGui(rhythmGui)
    if not rhythmGui or boundRhythmGui == rhythmGui then
        refreshSongActiveState()
        return
    end
    if songActiveConnection then
        songActiveConnection:Disconnect()
    end
    boundRhythmGui = rhythmGui
    songActiveConnection = rhythmGui:GetAttributeChangedSignal("SongActive"):Connect(refreshSongActiveState)
    refreshSongActiveState()
end

local function describeArtReadiness(room)
    local readiness = type(room.assetReadiness) == "table" and room.assetReadiness or nil
    if not readiness then return "art not inspected" end
    if readiness.paletteCommitted then
        local count = tonumber(readiness.paletteAssetCount) or 0
        if tostring(readiness.publishPermission or "missing") == "missing" then
            return string.format("palette %d perm missing", count)
        end
        return string.format("palette %d ready", count)
    end
    local status = tostring(readiness.visualStatus or "not_inspected")
    if status == "inspected_pass" then
        return string.format("art pass %d", readiness.passCount or 0)
    elseif status == "inspected_with_fixes" then
        return string.format("art pass %d fix %d", readiness.passCount or 0, readiness.fixCount or 0)
    elseif status == "candidate_rejected" then
        return string.format("art rejected %d", readiness.rejectCount or 0)
    elseif status == "mixed_with_rejections" then
        return string.format("art mixed %d/%d", readiness.passCount or 0, readiness.inspectedCount or 0)
    end
    return string.format("art %s", status:gsub("_", " "))
end

local function roomStatusColor(room)
    if room.playerQueued then
        return Color3.fromRGB(120, 255, 190)
    end
    local state = tostring(room.queueState or "empty")
    if state == "active" then
        return Color3.fromRGB(255, 190, 90)
    elseif state == "countdown" or state == "ready" then
        return Color3.fromRGB(255, 235, 120)
    elseif room.status ~= "open" then
        return Color3.fromRGB(120, 130, 150)
    end
    return Color3.fromRGB(120, 240, 255)
end

local function makeLabel(parent, name, position, size, text, color, font)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = font or Enum.Font.GothamBold
    label.Parent = parent
    return label
end

local function updateCanvas()
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
end

local function fireJoin(roomId)
    if remotes:FindFirstChild("JoinRoomRequest") then
        remotes.JoinRoomRequest:FireServer({ roomId = roomId })
    end
end

local function buildRoomCard(room)
    local card = Instance.new("Frame")
    card.Name = "RoomCard_" .. tostring(room.id or "unknown")
    card.LayoutOrder = roomOrder(room)
    card.Size = UDim2.new(1, -4, 0, 92)
    card.BackgroundColor3 = Color3.fromRGB(15, 18, 34)
    card.BackgroundTransparency = 0.04
    card.Parent = list

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = roomStatusColor(room)
    cardStroke.Thickness = room.playerQueued and 2 or 1
    cardStroke.Parent = card

    makeLabel(card, "RoomName", UDim2.new(0, 10, 0, 7), UDim2.new(1, -92, 0, 24), string.format("%d. %s", room.index or 0, room.shortName or room.name or "Room"), Color3.fromRGB(245, 250, 255), Enum.Font.GothamBlack)
    makeLabel(card, "RoomQueueStatus", UDim2.new(0, 10, 0, 32), UDim2.new(1, -106, 0, 20), string.format("%d/%d players  %s", room.occupancy or 0, room.capacity or 4, describeQueue(room)), Color3.fromRGB(215, 235, 255), Enum.Font.GothamBold)
    makeLabel(card, "RoomRewardSummary", UDim2.new(0, 10, 0, 52), UDim2.new(1, -106, 0, 18), describeReward(room), Color3.fromRGB(255, 235, 150), Enum.Font.GothamMedium)
    makeLabel(card, "RoomAssetReadiness", UDim2.new(0, 10, 0, 70), UDim2.new(1, -106, 0, 16), string.format("lvl %d  %s", room.minLevel or 1, describeArtReadiness(room)), Color3.fromRGB(170, 195, 220), Enum.Font.GothamMedium)

    local join = Instance.new("TextButton")
    join.Name = "JoinRoomButton"
    join.AnchorPoint = Vector2.new(1, 0.5)
    join.Position = UDim2.new(1, -10, 0.5, 0)
    join.Size = UDim2.new(0, 78, 0, 34)
    join.BackgroundColor3 = room.playerQueued and Color3.fromRGB(24, 70, 54) or Color3.fromRGB(35, 92, 135)
    join.Text = room.playerQueued and "Queued" or "Queue"
    join.TextColor3 = Color3.fromRGB(245, 250, 255)
    join.TextScaled = true
    join.Font = Enum.Font.GothamBlack
    join.AutoButtonColor = not room.playerQueued
    join.Parent = card

    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 8)
    joinCorner.Parent = join

    join.Activated:Connect(function()
        fireJoin(room.id)
    end)

    return card
end

local function clearCards()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") and tostring(child.Name):match("^RoomCard_") then
            child:Destroy()
        end
    end
end

local function renderRoomCards(snapshot)
    clearCards()
    local rooms = {}
    local snapshotRooms = type(snapshot) == "table" and type(snapshot.rooms) == "table" and snapshot.rooms or {}
    for _, room in ipairs(snapshotRooms) do
        table.insert(rooms, room)
    end
    table.sort(rooms, function(a, b)
        return roomOrder(a) < roomOrder(b)
    end)
    for _, room in ipairs(rooms) do
        buildRoomCard(room)
    end
    updateCanvas()
end

local function applySnapshot(snapshot)
    latestSnapshot = snapshot
    local room = findSelectedRoom(snapshot)
    if room then
        selectedRoomId = room.id
        title.Text = string.format("Queued: %s", room.shortName or room.name)
        detail.Text = string.format("%d/%d players  %s  %s", room.occupancy or 0, room.capacity or 4, describeQueue(room), describeArtReadiness(room))
        refreshSongChip(room)
        stroke.Color = Color3.fromRGB(120, 255, 190)
        songChipStroke.Color = Color3.fromRGB(120, 255, 190)
        leave.Visible = true
    else
        selectedRoomId = nil
        title.Text = "Rooms"
        detail.Text = "Pick a themed room for crew rewards, skins, boosts, and helper NPCs."
        refreshSongChip(nil, "")
        stroke.Color = Color3.fromRGB(120, 240, 255)
        songChipStroke.Color = Color3.fromRGB(120, 240, 255)
        leave.Visible = false
    end
    renderRoomCards(snapshot)
    refreshSongActiveState()
end

local function toast(payload)
    if type(payload) ~= "table" then return end
    if payload.message then
        local message = tostring(payload.message)
        if tonumber(payload.objectiveMilestone) then
            message = string.format("%s  Milestone %d%%.", message, tonumber(payload.objectiveMilestone))
        elseif tonumber(payload.objectiveProgress) then
            message = string.format("%s  Objective %d%% x%d.", message, tonumber(payload.objectiveProgress), tonumber(payload.objectiveCombo) or 0)
        end
        detail.Text = message
        local color = payload.ok == false and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(120, 255, 190)
        stroke.Color = color
        songChipStroke.Color = color
        if payload.roomName then
            songChipTitle.Text = tostring(payload.roomName)
        end
        refreshSongChip(findSelectedRoom(latestSnapshot), message)
        refreshSongActiveState()
        TweenService:Create(panel, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 1, true), {
            Size = UDim2.new(0, 396, 0, 404),
        }):Play()
    end
end

leave.Activated:Connect(function()
    if remotes:FindFirstChild("LeaveRoomRequest") then
        remotes.LeaveRoomRequest:FireServer({ roomId = selectedRoomId })
    end
end)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local roomUpdate = remotes:WaitForChild("RoomUpdate", 10)
if roomUpdate then
    roomUpdate.OnClientEvent:Connect(applySnapshot)
end

local actionResult = remotes:WaitForChild("RoomActionResult", 10)
if actionResult then
    actionResult.OnClientEvent:Connect(toast)
end

task.defer(function()
    bindRhythmGui(findRhythmScreenGui())
    if latestSnapshot == nil then
        applySnapshot({ rooms = {} })
    end
end)

playerGui.ChildAdded:Connect(function(child)
    if child.Name == "RhythmGui" and child:IsA("ScreenGui") then
        bindRhythmGui(child)
    end
end)
