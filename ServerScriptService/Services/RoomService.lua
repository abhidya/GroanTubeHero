local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RoomConfig = require(ReplicatedStorage.Shared.WorldV2.RoomConfig)
local AssetRegistry = require(ReplicatedStorage.Shared.WorldV2.AssetRegistry)

local RoomService = {}
RoomService.__index = RoomService

local function profileLevel(profile)
    return tonumber(profile and profile.Level) or 1
end

local OBJECTIVE_SECTORS = { "N", "E", "S", "W" }
local OBJECTIVE_EFFECT_COLORS = {
    Repair = Color3.fromRGB(80, 255, 140),
    Pushback = Color3.fromRGB(100, 210, 255),
    Boost = Color3.fromRGB(255, 220, 90),
    Encore = Color3.fromRGB(255, 95, 230),
}
local OBJECTIVE_PROGRESS_POINTS = {
    Repair = 16,
    Pushback = 18,
    Boost = 14,
    Encore = 22,
}
local OBJECTIVE_MILESTONES = { 25, 50, 75, 100 }
local OBJECTIVE_MILESTONE_SUPPORT = {
    [25] = 4,
    [50] = 7,
    [75] = 10,
    [100] = 14,
}

local function objectiveSector(index)
    index = math.max(1, tonumber(index) or 1)
    return OBJECTIVE_SECTORS[((index - 1) % #OBJECTIVE_SECTORS) + 1]
end

local function participantUserIds(participants)
    local userIds = {}
    for _, participant in ipairs(participants or {}) do
        table.insert(userIds, participant.userId)
    end
    return userIds
end

function RoomService:Init(runtimeContext)
    self.context = runtimeContext
    self.queues = {}
    self.playerRoom = {}
    self.activeRoomSessions = {}
    self.playerRoomSession = {}
    self.objectiveCooldowns = {}
    self.roomSessionSerial = 0
    for _, room in ipairs(RoomConfig.GetRooms()) do
        self.queues[room.Id] = {
            roomId = room.Id,
            orderedUserIds = {},
            playersByUserId = {},
            fillDeadline = nil,
            readyAt = nil,
            activeSessionId = nil,
            lastBroadcastAt = 0,
        }
    end
end

local function cloneRoomSummary(room)
    return {
        id = room.Id,
        index = room.Index,
        name = room.Name,
        shortName = room.ShortName,
        theme = room.Theme,
        status = room.Status,
        minLevel = room.MinLevel,
        minPlayers = room.MinPlayers or 1,
        capacity = room.Capacity,
        fillSeconds = room.FillSeconds or 20,
        teamMode = room.TeamMode or "Crew",
        recommendedPlayers = room.RecommendedPlayers,
        difficulties = room.DifficultyOrder,
        defaultDifficulty = room.DefaultDifficulty,
        reward = RoomConfig.BuildRewardSummary(room),
        helperNPCs = room.HelperNPCs,
        reviewSpaceId = room.ReviewSpaceId,
        assetReadiness = AssetRegistry.GetRoomAssetReadiness(room.Id),
    }
end

function RoomService:_queue(roomId)
    roomId = roomId or RoomConfig.DefaultRoomId
    self.queues[roomId] = self.queues[roomId] or {
        roomId = roomId,
        orderedUserIds = {},
        playersByUserId = {},
        fillDeadline = nil,
        readyAt = nil,
        activeSessionId = nil,
        lastBroadcastAt = 0,
    }
    return self.queues[roomId]
end

function RoomService:_publicRoomSession(session)
    if not session then return nil end
    return {
        id = session.id,
        crewKey = session.crewKey,
        roomId = session.roomId,
        roomName = session.roomName,
        state = session.state,
        teamMode = session.teamMode,
        minPlayers = session.minPlayers,
        capacity = session.capacity,
        readyAt = session.readyAt,
        startedAt = session.startedAt,
        participantCount = #session.participants,
        participantUserIds = participantUserIds(session.participants),
        participants = session.participants,
        objectives = self:_roomObjectiveSnapshot(session),
    }
end

function RoomService:_roomObjectiveSnapshot(session)
    if not session then return nil end
    local contributors = {}
    for _, contribution in pairs(session.objectiveContributions or {}) do
        table.insert(contributors, {
            userId = contribution.userId,
            name = contribution.name,
            uses = contribution.uses or 0,
            progress = contribution.progress or 0,
            lastEffect = contribution.lastEffect,
            lastObjectiveId = contribution.lastObjectiveId,
        })
    end
    table.sort(contributors, function(a, b)
        if (a.progress or 0) == (b.progress or 0) then
            return tostring(a.name or "") < tostring(b.name or "")
        end
        return (a.progress or 0) > (b.progress or 0)
    end)
    local milestones = {}
    for _, milestone in ipairs(session.objectiveMilestones or {}) do
        table.insert(milestones, milestone)
    end
    return {
        progress = session.objectiveProgress or 0,
        momentum = session.objectiveMomentum or 0,
        combo = session.objectiveCombo or 0,
        milestone = session.objectiveMilestone or 0,
        milestones = milestones,
        lastObjective = session.lastObjective,
        contributors = contributors,
    }
end

function RoomService:_roomSnapshot(roomId)
    local room = RoomConfig.GetRoom(roomId)
    local queue = self:_queue(room.Id)
    local activeSession = queue.activeSessionId and self.activeRoomSessions[queue.activeSessionId] or nil
    local occupants = {}
    for _, userId in ipairs(queue.orderedUserIds) do
        local player = queue.playersByUserId[userId]
        if player and player.Parent == Players then
            table.insert(occupants, {
                userId = player.UserId,
                name = player.DisplayName or player.Name,
            })
        end
    end
    local summary = cloneRoomSummary(room)
    summary.occupancy = #occupants
    summary.occupants = occupants
    summary.isFull = #occupants >= (room.Capacity or 4)
    summary.readyAt = queue.readyAt
    summary.fillDeadline = queue.fillDeadline
    summary.countdownSeconds = queue.fillDeadline and math.max(0, math.ceil(queue.fillDeadline - os.clock())) or nil
    summary.activeSessionId = activeSession and activeSession.id or nil
    summary.activeSession = self:_publicRoomSession(activeSession)
    if activeSession then
        summary.queueState = "active"
    elseif summary.isFull or queue.readyAt then
        summary.queueState = "ready"
    elseif queue.fillDeadline then
        summary.queueState = "countdown"
    elseif #occupants > 0 then
        summary.queueState = "waiting"
    else
        summary.queueState = "empty"
    end
    return summary
end

function RoomService:_refreshQueueState(room, queue, nowTime)
    nowTime = nowTime or os.clock()
    if queue.activeSessionId and self.activeRoomSessions[queue.activeSessionId] then
        return false
    elseif queue.activeSessionId then
        queue.activeSessionId = nil
    end
    local minPlayers = room.MinPlayers or 1
    local capacity = room.Capacity or 4
    local count = #queue.orderedUserIds
    if count <= 0 then
        queue.fillDeadline = nil
        queue.readyAt = nil
        return false
    end
    if count < minPlayers then
        local changed = queue.fillDeadline ~= nil or queue.readyAt ~= nil
        queue.fillDeadline = nil
        queue.readyAt = nil
        return changed
    end
    if count >= capacity then
        if not queue.readyAt then
            queue.readyAt = nowTime
            queue.fillDeadline = nowTime
            return true
        end
        return false
    end
    if not queue.fillDeadline then
        queue.fillDeadline = nowTime + (room.FillSeconds or 20)
        queue.readyAt = nil
        return true
    end
    if nowTime >= queue.fillDeadline and not queue.readyAt then
        queue.readyAt = nowTime
        return true
    end
    return false
end

function RoomService:_buildSessionId(room)
    self.roomSessionSerial = (self.roomSessionSerial or 0) + 1
    return string.format("%s-%d-%d", room.Id, math.floor(os.clock() * 1000), self.roomSessionSerial)
end

function RoomService:_buildParticipants(room, queue)
    local participants = {}
    local teamName = room.TeamMode or "Crew"
    for _, userId in ipairs(queue.orderedUserIds) do
        local player = queue.playersByUserId[userId]
        if player and player.Parent == Players then
            table.insert(participants, {
                userId = player.UserId,
                name = player.DisplayName or player.Name,
                slot = #participants + 1,
                teamName = teamName,
                status = "ready",
            })
        end
    end
    return participants
end

function RoomService:_teleportPlayer(player, cframe)
    local character = player and player.Character
    if not character then return false end
    local root = character:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    local ok = pcall(function()
        character:PivotTo(cframe)
    end)
    return ok
end

function RoomService:_teleportRoomSession(session, mode)
    for _, participant in ipairs(session.participants or {}) do
        local player = Players:GetPlayerByUserId(participant.userId)
        if player then
            local cframe = mode == "return"
                and RoomConfig.GetReturnCFrame(session.roomId, participant.slot)
                or RoomConfig.GetLaunchCFrame(session.roomId, participant.slot)
            self:_teleportPlayer(player, cframe)
        end
    end
end

function RoomService:_ensureRoomSession(room, queue, nowTime)
    nowTime = nowTime or os.clock()
    if queue.activeSessionId and self.activeRoomSessions[queue.activeSessionId] then
        return self.activeRoomSessions[queue.activeSessionId]
    end
    if not queue.readyAt then
        return nil
    end
    local participants = self:_buildParticipants(room, queue)
    if #participants <= 0 then
        return nil
    end
    local sessionId = self:_buildSessionId(room)
    local session = {
        id = sessionId,
        roomId = room.Id,
        roomName = room.Name,
        roomShortName = room.ShortName,
        crewKey = string.format("%s:crew:%s", room.Id, sessionId),
        teamMode = room.TeamMode or "Crew",
        state = "active",
        minPlayers = room.MinPlayers or 1,
        capacity = room.Capacity or 4,
        readyAt = queue.readyAt or nowTime,
        startedAt = nowTime,
        participants = participants,
        participantByUserId = {},
        objectiveProgress = 0,
        objectiveMomentum = 0,
        objectiveCombo = 0,
        objectiveMilestone = 0,
        objectiveMilestones = {},
        objectiveContributions = {},
        lastObjective = nil,
    }
    for _, participant in ipairs(participants) do
        session.participantByUserId[participant.userId] = participant
        self.playerRoomSession[participant.userId] = session.id
    end
    self.activeRoomSessions[session.id] = session
    queue.activeSessionId = session.id
    queue.readyAt = nowTime
    queue.fillDeadline = nowTime
    self:_teleportRoomSession(session, "launch")
    for _, participant in ipairs(participants) do
        local player = Players:GetPlayerByUserId(participant.userId)
        if player then
            self:_fireResult(player, {
                ok = true,
                action = "RoomSessionReady",
                roomId = room.Id,
                roomName = room.Name,
                roomSessionId = session.id,
                roomCrewKey = session.crewKey,
                message = string.format("%s crew is ready. Pick a song to launch together.", room.Name),
                participantCount = #participants,
                participantUserIds = participantUserIds(participants),
                participants = participants,
            })
        end
    end
    return session
end

function RoomService:GetPlayerRoomSession(player)
    local sessionId = player and self.playerRoomSession[player.UserId] or nil
    return sessionId and self.activeRoomSessions[sessionId] or nil
end

function RoomService:_markParticipantStatus(player, status)
    local session = self:GetPlayerRoomSession(player)
    local participant = session and session.participantByUserId[player.UserId]
    if participant then
        participant.status = status
        participant.updatedAt = os.clock()
    end
    return session
end

function RoomService:_roomSessionHasActivePlayers(session)
    for _, participant in ipairs(session.participants or {}) do
        if participant.status ~= "finished" and participant.status ~= "left" then
            return true
        end
    end
    return false
end

function RoomService:_closeRoomSession(session, reason)
    if not session then return end
    session.state = "closed"
    session.closedAt = os.clock()
    session.closeReason = reason or "complete"
    local cooldownPrefix = session.id .. ":"
    for cooldownKey in pairs(self.objectiveCooldowns or {}) do
        if tostring(cooldownKey):sub(1, #cooldownPrefix) == cooldownPrefix then
            self.objectiveCooldowns[cooldownKey] = nil
        end
    end
    self:_teleportRoomSession(session, "return")
    for _, participant in ipairs(session.participants or {}) do
        self.playerRoomSession[participant.userId] = nil
        local player = Players:GetPlayerByUserId(participant.userId)
        if player then
            self.playerRoom[player.UserId] = nil
            self:_fireResult(player, {
                ok = true,
                action = "RoomSessionClosed",
                roomId = session.roomId,
                roomSessionId = session.id,
                message = "Returned to the room portals.",
            })
        end
    end
    local queue = self:_queue(session.roomId)
    if queue.activeSessionId == session.id then
        queue.activeSessionId = nil
        queue.readyAt = nil
        queue.fillDeadline = nil
        queue.orderedUserIds = {}
        queue.playersByUserId = {}
    end
    self.activeRoomSessions[session.id] = nil
end

function RoomService:FinishPlayerRoomSession(player)
    local session = self:_markParticipantStatus(player, "finished")
    if session and not self:_roomSessionHasActivePlayers(session) then
        self:_closeRoomSession(session, "all_finished")
    end
    self:_broadcast()
end

function RoomService:BuildSnapshot(player)
    local rooms = {}
    for _, room in ipairs(RoomConfig.GetRooms()) do
        local snapshot = self:_roomSnapshot(room.Id)
        if player then
            snapshot.playerQueued = self.playerRoom[player.UserId] == room.Id
        end
        table.insert(rooms, snapshot)
    end
    return {
        defaultRoomId = RoomConfig.DefaultRoomId,
        selectedRoomId = player and self.playerRoom[player.UserId] or nil,
        rooms = rooms,
    }
end

function RoomService:_fireResult(player, payload)
    local remote = self.context and self.context.Remotes and self.context.Remotes.RoomActionResult
    if remote and player then
        remote:FireClient(player, payload)
    end
end

function RoomService:_broadcast()
    local remote = self.context and self.context.Remotes and self.context.Remotes.RoomUpdate
    if not remote then return end
    for _, player in ipairs(Players:GetPlayers()) do
        remote:FireClient(player, self:BuildSnapshot(player))
    end
end

function RoomService:_pulseRoomObjectivePrompt(prompt, effect)
    if not prompt then return end
    local station = prompt:FindFirstAncestorWhichIsA("Model")
    local color = OBJECTIVE_EFFECT_COLORS[effect] or Color3.fromRGB(255, 255, 255)
    local restored = {}
    if station then
        station:SetAttribute("LastObjectivePulseAt", os.clock())
        station:SetAttribute("LastObjectiveEffect", effect)
        for _, desc in ipairs(station:GetDescendants()) do
            if desc:IsA("BasePart") and (desc:GetAttribute("RoomObjectiveEffect") ~= nil or tostring(desc.Name):match("^Objective")) then
                table.insert(restored, {
                    part = desc,
                    color = desc.Color,
                    material = desc.Material,
                    transparency = desc.Transparency,
                })
                desc.Color = color
                desc.Material = Enum.Material.Neon
                desc.Transparency = math.min(desc.Transparency, 0.08)
            end
        end
    end
    task.delay(0.8, function()
        for _, entry in ipairs(restored) do
            local part = entry.part
            if part and part.Parent then
                part.Color = entry.color
                part.Material = entry.material
                part.Transparency = entry.transparency
            end
        end
    end)
end

function RoomService:_recordRoomObjective(roomSession, player, objectiveId, objectiveLabel, effect, sectorId)
    local gain = OBJECTIVE_PROGRESS_POINTS[effect] or 12
    local previousProgress = tonumber(roomSession.objectiveProgress) or 0
    local nextProgress = math.clamp(previousProgress + gain, 0, 100)
    local previousMilestone = tonumber(roomSession.objectiveMilestone) or 0
    local milestone = nil
    for _, threshold in ipairs(OBJECTIVE_MILESTONES) do
        if previousMilestone < threshold and nextProgress >= threshold then
            milestone = threshold
        end
    end

    roomSession.objectiveProgress = nextProgress
    roomSession.objectiveMomentum = math.clamp((roomSession.objectiveMomentum or 0) + 1, 0, 12)
    roomSession.objectiveCombo = (roomSession.objectiveCombo or 0) + 1
    roomSession.objectiveContributions = roomSession.objectiveContributions or {}
    roomSession.objectiveMilestones = roomSession.objectiveMilestones or {}

    local userId = player and player.UserId or 0
    local contribution = roomSession.objectiveContributions[userId] or {
        userId = userId,
        name = player and (player.DisplayName or player.Name) or "Unknown",
        uses = 0,
        progress = 0,
    }
    contribution.uses += 1
    contribution.progress = math.clamp((contribution.progress or 0) + gain, 0, 100)
    contribution.lastEffect = effect
    contribution.lastObjectiveId = objectiveId
    contribution.lastObjectiveLabel = objectiveLabel
    contribution.lastSectorId = sectorId
    roomSession.objectiveContributions[userId] = contribution

    local participant = roomSession.participantByUserId and roomSession.participantByUserId[userId] or nil
    if participant then
        participant.objectiveUses = (participant.objectiveUses or 0) + 1
        participant.objectiveProgress = (participant.objectiveProgress or 0) + gain
        participant.lastObjectiveEffect = effect
    end

    if milestone then
        roomSession.objectiveMilestone = milestone
        table.insert(roomSession.objectiveMilestones, {
            value = milestone,
            reachedAt = os.clock(),
            objectiveId = objectiveId,
            effect = effect,
            playerUserId = userId,
        })
    end

    roomSession.lastObjective = {
        objectiveId = objectiveId,
        label = objectiveLabel,
        effect = effect,
        sectorId = sectorId,
        playerUserId = userId,
        playerName = contribution.name,
        gain = gain,
        progress = nextProgress,
        combo = roomSession.objectiveCombo,
        milestone = milestone,
        usedAt = os.clock(),
    }

    return {
        gain = gain,
        progress = nextProgress,
        momentum = roomSession.objectiveMomentum,
        combo = roomSession.objectiveCombo,
        contribution = {
            userId = contribution.userId,
            name = contribution.name,
            uses = contribution.uses,
            progress = contribution.progress,
            lastEffect = contribution.lastEffect,
            lastObjectiveId = contribution.lastObjectiveId,
        },
        milestone = milestone,
    }
end

function RoomService:_applyRoomObjective(player, prompt)
    local roomId = prompt and prompt:GetAttribute("RoomId") or nil
    local room = roomId and RoomConfig.GetRoom(roomId) or nil
    local objectiveId = prompt and prompt:GetAttribute("RoomObjectiveId") or nil
    local effect = tostring(prompt and prompt:GetAttribute("RoomObjectiveEffect") or "Repair")
    local objectiveIndex = tonumber(prompt and prompt:GetAttribute("RoomObjectiveIndex")) or 1
    local objectiveLabel = tostring(prompt and prompt:GetAttribute("RoomObjectiveLabel") or "Room objective")
    local cooldown = tonumber(prompt and prompt:GetAttribute("RoomObjectiveCooldown")) or 7

    if not room or not objectiveId then
        self:_fireResult(player, {
            ok = false,
            action = "RoomObjective",
            reason = "UnknownObjective",
            message = "That room objective is not ready.",
        })
        return false, "UnknownObjective"
    end

    local roomSession = self:GetPlayerRoomSession(player)
    if not roomSession or roomSession.roomId ~= room.Id or roomSession.state ~= "active" then
        self:_fireResult(player, {
            ok = false,
            action = "RoomObjective",
            roomId = room.Id,
            objectiveId = objectiveId,
            reason = "NotInRoomSession",
            message = "Queue and launch this room before using its objectives.",
        })
        return false, "NotInRoomSession"
    end

    local services = self.context and self.context.Services
    local songService = services and services.SongSessionService
    local hordeService = services and services.HordeService
    local songSession = songService and songService:GetSession(player) or nil
    if not songSession or songSession.roomSessionId ~= roomSession.id or songSession.state == "Finished" then
        self:_fireResult(player, {
            ok = false,
            action = "RoomObjective",
            roomId = room.Id,
            objectiveId = objectiveId,
            reason = "NoActiveSong",
            message = "Start the room song before using " .. objectiveLabel .. ".",
        })
        return false, "NoActiveSong"
    end
    if not hordeService then
        self:_fireResult(player, {
            ok = false,
            action = "RoomObjective",
            roomId = room.Id,
            objectiveId = objectiveId,
            reason = "HordeUnavailable",
            message = "The horde system is not ready for that objective.",
        })
        return false, "HordeUnavailable"
    end

    local cooldownKey = roomSession.id .. ":" .. objectiveId
    local nowTime = os.clock()
    local lastUse = self.objectiveCooldowns[cooldownKey]
    if lastUse and nowTime - lastUse < cooldown then
        local remaining = math.max(1, math.ceil(cooldown - (nowTime - lastUse)))
        self:_fireResult(player, {
            ok = false,
            action = "RoomObjective",
            roomId = room.Id,
            objectiveId = objectiveId,
            effect = effect,
            reason = "ObjectiveCooldown",
            message = string.format("%s recharges in %ds.", objectiveLabel, remaining),
            remainingSeconds = remaining,
        })
        return false, "ObjectiveCooldown"
    end

    self.objectiveCooldowns[cooldownKey] = nowTime
    local sectorId = objectiveSector(objectiveIndex)
    local message
    if effect == "Repair" then
        hordeService:RepairSector(player, sectorId, 24)
        message = string.format("%s repaired sector %s.", objectiveLabel, sectorId)
    elseif effect == "Pushback" then
        hordeService:ApplyAudienceSupport(songSession, 9, "Support")
        message = objectiveLabel .. " shoved the horde back."
    elseif effect == "Boost" then
        songSession.modifiers = songSession.modifiers or {}
        songSession.stateData.hype = math.min(100, (songSession.stateData.hype or 0) + 10)
        songSession.modifiers.roomObjectiveBoostUntil = nowTime + 8
        hordeService:ApplyAudienceSupport(songSession, 4, "Support")
        message = objectiveLabel .. " armed an 8s score boost."
    elseif effect == "Encore" then
        songSession.modifiers = songSession.modifiers or {}
        songSession.modifiers.encoreSurgeNotes = (songSession.modifiers.encoreSurgeNotes or 0) + 4
        hordeService:ApplyAudienceSupport(songSession, 12, "Encore")
        message = objectiveLabel .. " triggered an encore surge."
    else
        hordeService:ApplyAudienceSupport(songSession, 6, "Support")
        message = objectiveLabel .. " supported the crew."
    end

    local objectiveResult = self:_recordRoomObjective(roomSession, player, objectiveId, objectiveLabel, effect, sectorId)
    if objectiveResult.milestone then
        local milestoneSupport = OBJECTIVE_MILESTONE_SUPPORT[objectiveResult.milestone] or 5
        if objectiveResult.milestone >= 100 then
            songSession.modifiers = songSession.modifiers or {}
            songSession.modifiers.roomObjectiveBoostUntil = math.max(
                songSession.modifiers.roomObjectiveBoostUntil or 0,
                nowTime + 10
            )
            hordeService:ApplyAudienceSupport(songSession, milestoneSupport + 6, "Encore")
        else
            hordeService:ApplyAudienceSupport(songSession, milestoneSupport, "Support")
        end
        message = string.format("%s Crew objective %d%%!", message, objectiveResult.milestone)
    end

    self:_pulseRoomObjectivePrompt(prompt, effect)
    self:_fireResult(player, {
        ok = true,
        action = "RoomObjective",
        roomId = room.Id,
        roomName = room.Name,
        roomSessionId = roomSession.id,
        objectiveId = objectiveId,
        objectiveLabel = objectiveLabel,
        objectiveIndex = objectiveIndex,
        effect = effect,
        sectorId = sectorId,
        cooldownSeconds = cooldown,
        objectiveGain = objectiveResult.gain,
        objectiveProgress = objectiveResult.progress,
        objectiveMomentum = objectiveResult.momentum,
        objectiveCombo = objectiveResult.combo,
        objectiveContribution = objectiveResult.contribution,
        objectiveMilestone = objectiveResult.milestone,
        objectives = self:_roomObjectiveSnapshot(roomSession),
        message = message,
    })
    self:_broadcast()
    return true, effect
end

function RoomService:_bindRoomObjectivePrompt(prompt)
    if not prompt or prompt:GetAttribute("RoomObjectiveBound") then return end
    prompt:SetAttribute("RoomObjectiveBound", true)
    prompt.Triggered:Connect(function(player)
        self:_applyRoomObjective(player, prompt)
    end)
end

function RoomService:_removeFromQueue(player, silent)
    if not player then return nil end
    local currentRoomId = self.playerRoom[player.UserId]
    if not currentRoomId then return nil end
    local room = RoomConfig.GetRoom(currentRoomId)
    local queue = self:_queue(currentRoomId)
    local activeSession = self:GetPlayerRoomSession(player)
    if activeSession then
        local participant = activeSession.participantByUserId[player.UserId]
        if participant then
            participant.status = "left"
            participant.updatedAt = os.clock()
        end
        self.playerRoomSession[player.UserId] = nil
        self:_teleportPlayer(player, RoomConfig.GetReturnCFrame(currentRoomId, participant and participant.slot or 1))
        if not self:_roomSessionHasActivePlayers(activeSession) then
            self:_closeRoomSession(activeSession, "all_left")
        end
    end
    queue.playersByUserId[player.UserId] = nil
    for index = #queue.orderedUserIds, 1, -1 do
        if queue.orderedUserIds[index] == player.UserId then
            table.remove(queue.orderedUserIds, index)
        end
    end
    self.playerRoom[player.UserId] = nil
    if room then
        self:_refreshQueueState(room, queue)
    end
    if not silent then
        self:_fireResult(player, {
            ok = true,
            action = "LeaveRoom",
            roomId = currentRoomId,
            message = "Left room queue.",
        })
        self:_broadcast()
    end
    return currentRoomId
end

function RoomService:JoinRoom(player, payload)
    payload = type(payload) == "table" and payload or {}
    local room = RoomConfig.GetRoom(payload.roomId or RoomConfig.DefaultRoomId)
    if not room then
        self:_fireResult(player, { ok = false, action = "JoinRoom", reason = "UnknownRoom" })
        return false, "UnknownRoom"
    end
    local profile = self.context.Services.DataService:GetProfile(player)
    if profileLevel(profile) < (room.MinLevel or 1) then
        self:_fireResult(player, {
            ok = false,
            action = "JoinRoom",
            roomId = room.Id,
            reason = "LevelLocked",
            message = string.format("%s unlocks at level %d.", room.Name, room.MinLevel or 1),
        })
        return false, "LevelLocked"
    end
    if room.Status ~= "open" then
        self:_fireResult(player, {
            ok = false,
            action = "JoinRoom",
            roomId = room.Id,
            reason = "RoomNotOpen",
            message = room.Name .. " is staged for future asset review.",
        })
        return false, "RoomNotOpen"
    end
    local queue = self:_queue(room.Id)
    if queue.activeSessionId and self.activeRoomSessions[queue.activeSessionId] then
        self:_fireResult(player, {
            ok = false,
            action = "JoinRoom",
            roomId = room.Id,
            reason = "RoomActive",
            message = room.Name .. " has an active crew. Try again after they return.",
        })
        return false, "RoomActive"
    end
    if not queue.playersByUserId[player.UserId] and #queue.orderedUserIds >= (room.Capacity or 4) then
        self:_fireResult(player, {
            ok = false,
            action = "JoinRoom",
            roomId = room.Id,
            reason = "RoomFull",
            message = room.Name .. " is full.",
        })
        return false, "RoomFull"
    end

    self:_removeFromQueue(player, true)
    queue.playersByUserId[player.UserId] = player
    table.insert(queue.orderedUserIds, player.UserId)
    self.playerRoom[player.UserId] = room.Id
    self:_refreshQueueState(room, queue)

    self:_fireResult(player, {
        ok = true,
        action = "JoinRoom",
        roomId = room.Id,
        roomName = room.Name,
        message = string.format("Queued for %s (%d/%d).", room.Name, #queue.orderedUserIds, room.Capacity or 4),
        reward = RoomConfig.BuildRewardSummary(room),
        queue = self:_roomSnapshot(room.Id),
    })
    self:_broadcast()
    return true, room.Id
end

function RoomService:LeaveRoom(player)
    local oldRoom = self:_removeFromQueue(player, false)
    if not oldRoom then
        self:_fireResult(player, { ok = true, action = "LeaveRoom", message = "No active room queue." })
    end
    return true
end

function RoomService:GetPlayerRoom(player)
    local roomId = player and self.playerRoom[player.UserId] or nil
    return RoomConfig.GetRoom(roomId or RoomConfig.DefaultRoomId)
end

function RoomService:DecorateSongPayload(player, payload)
    payload = type(payload) == "table" and payload or {}
    local decorated = {}
    for key, value in pairs(payload) do
        decorated[key] = value
    end
    local room = RoomConfig.GetRoom(decorated.roomId or (player and self.playerRoom[player.UserId]) or RoomConfig.DefaultRoomId)
    decorated.roomId = room.Id
    decorated.roomName = room.Name
    decorated.difficulty = RoomConfig.GetDifficulty(room, decorated.difficulty)
    decorated.roomRewardMultiplier = room.RewardMultiplier or 1
    decorated.roomRewardBonuses = room.Bonuses or {}
    decorated.roomBoosts = room.Boosts or {}
    decorated.roomHelperNPCs = room.HelperNPCs or {}
    decorated.roomSkinUnlocks = room.SkinUnlocks or {}
    decorated.roomMinPlayers = room.MinPlayers or 1
    decorated.roomCapacity = room.Capacity or 4
    local roomSession = player and self:GetPlayerRoomSession(player) or nil
    if roomSession then
        decorated.roomSessionId = roomSession.id
        decorated.roomCrewKey = roomSession.crewKey
        decorated.roomSessionState = roomSession.state
        decorated.roomParticipants = roomSession.participants
        decorated.roomParticipantCount = #roomSession.participants
        decorated.roomParticipantUserIds = participantUserIds(roomSession.participants)
        decorated.roomTeamMode = roomSession.teamMode
        decorated.roomReadyAt = roomSession.readyAt
        decorated.roomStartedAt = roomSession.startedAt
        decorated.roomObjectiveProgress = roomSession.objectiveProgress or 0
        decorated.roomObjectiveMomentum = roomSession.objectiveMomentum or 0
        decorated.roomObjectiveCombo = roomSession.objectiveCombo or 0
        decorated.roomObjectiveSnapshot = self:_roomObjectiveSnapshot(roomSession)
        local participant = roomSession.participantByUserId[player.UserId]
        if participant then
            participant.status = "playing"
            participant.updatedAt = os.clock()
            decorated.roomTeamName = participant.teamName
            decorated.roomLaunchSlot = participant.slot
        end
    end
    return decorated
end

function RoomService:PrepareSongPayload(player, payload)
    payload = type(payload) == "table" and payload or {}
    local queuedRoomId = player and self.playerRoom[player.UserId] or nil
    if not queuedRoomId then
        return self:DecorateSongPayload(player, payload)
    end
    local room = RoomConfig.GetRoom(queuedRoomId)
    local queue = self:_queue(room.Id)
    local nowTime = os.clock()
    self:_refreshQueueState(room, queue, nowTime)
    local session = self:GetPlayerRoomSession(player)
    local createdDuringPrepare = false
    if not session then
        session = self:_ensureRoomSession(room, queue, nowTime)
        createdDuringPrepare = session ~= nil
    end
    if not session then
        local snapshot = self:_roomSnapshot(room.Id)
        self:_fireResult(player, {
            ok = false,
            action = "StartRoomSong",
            roomId = room.Id,
            reason = "RoomNotReady",
            message = snapshot.queueState == "waiting"
                and string.format("%s needs %d player(s).", room.Name, room.MinPlayers or 1)
                or string.format("%s starts in %ds.", room.Name, snapshot.countdownSeconds or room.FillSeconds or 0),
            queue = snapshot,
        })
        self:_broadcast()
        return nil, "RoomNotReady"
    end
    if createdDuringPrepare then
        self:_broadcast()
    end
    return self:DecorateSongPayload(player, payload)
end

function RoomService:BindWorldPrompts()
    local world = Workspace:FindFirstChild("GTH_WorldV2")
    if not world then return end
    for _, prompt in ipairs(world:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("RoomObjectiveId") then
            self:_bindRoomObjectivePrompt(prompt)
        end
    end
    for _, prompt in ipairs(world:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("RoomId") and not prompt:GetAttribute("RoomObjectiveId") and not prompt:GetAttribute("RoomServiceBound") then
            prompt:SetAttribute("RoomServiceBound", true)
            prompt.Triggered:Connect(function(player)
                local roomId = prompt:GetAttribute("RoomId")
                local ok = self:JoinRoom(player, { roomId = roomId })
                local dialogue = self.context and self.context.Remotes and self.context.Remotes.NPCDialogue
                local room = RoomConfig.GetRoom(roomId)
                if dialogue and room then
                    dialogue:FireClient(player, {
                        menu = "RoomQueue",
                        speaker = room.ShortName or room.Name,
                        actionPrompt = ok and "Queued" or "Room locked",
                        text = ok and ("You are queued for " .. room.Name .. ". Pick a song when your crew is ready.")
                            or (room.Name .. " needs more level or review before you can enter."),
                    })
                end
            end)
        end
    end
end

function RoomService:PlayerAdded(player)
    self:_fireResult(player, {
        ok = true,
        action = "RoomSnapshot",
        message = "Room board ready.",
    })
    local remote = self.context and self.context.Remotes and self.context.Remotes.RoomUpdate
    if remote then
        remote:FireClient(player, self:BuildSnapshot(player))
    end
end

function RoomService:PlayerRemoving(player)
    self:_removeFromQueue(player, true)
    self:_broadcast()
end

function RoomService:Start()
    self:BindWorldPrompts()
    self:_broadcast()
end

function RoomService:Update()
    local changed = false
    local nowTime = os.clock()
    for _, room in ipairs(RoomConfig.GetRooms()) do
        local queue = self:_queue(room.Id)
        changed = self:_refreshQueueState(room, queue, nowTime) or changed
        if queue.readyAt and not queue.activeSessionId then
            local session = self:_ensureRoomSession(room, queue, nowTime)
            changed = session ~= nil or changed
        end
        if queue.fillDeadline and nowTime - (queue.lastBroadcastAt or 0) >= 1 then
            queue.lastBroadcastAt = nowTime
            changed = true
        end
    end
    if changed then
        self:_broadcast()
    end
end

return RoomService
