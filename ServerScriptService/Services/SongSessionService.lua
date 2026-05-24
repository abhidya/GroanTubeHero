local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local SongCatalog = require(ReplicatedStorage.Shared.SongCatalog)
local Scoring = require(ReplicatedStorage.Shared.Scoring)
local ChartService = require(ReplicatedStorage.Shared.ChartService)

local SongSessionService = {}
SongSessionService.__index = SongSessionService

local function now()
    if workspace.GetServerTimeNow then
        return workspace:GetServerTimeNow()
    end
    return os.clock()
end

function SongSessionService:Init(runtimeContext)
    self.context = runtimeContext
    self.sessions = {}
    self.sessionById = {}
    self.watchingSessionId = nil
end

function SongSessionService:GetSession(player)
    return self.sessions[player.UserId]
end

function SongSessionService:GetSessionById(sessionId)
    return self.sessionById[sessionId]
end

function SongSessionService:GetWatchingSession()
    if self.watchingSessionId then
        return self.sessionById[self.watchingSessionId]
    end
    for _, session in pairs(self.sessionById) do
        return session
    end
    return nil
end

function SongSessionService:_buildSessionId(player, songId)
    return tostring(player.UserId) .. "-" .. songId .. "-" .. tostring(math.floor(now() * 1000))
end

function SongSessionService:_attachNotes(song)
    local byId = {}
    local order = {}
    for index, note in ipairs(song.Notes or {}) do
        local copy = {
            id = note.id,
            time = note.time,
            lane = note.lane,
            groan = note.groan,
            pose = note.pose,
            lightCue = note.lightCue,
            crowdCue = note.crowdCue,
            hit = false,
            index = index,
        }
        byId[copy.id] = copy
        order[#order + 1] = copy
    end
    return byId, order
end

function SongSessionService:_createSession(player, payload)
    payload = type(payload) == "table" and payload or {}
    local requestedSongId = payload.songId or Config.DefaultSongId
    local profile = self.context.Services.DataService:GetProfile(player)
    local baseSong = SongCatalog.Get(requestedSongId) or SongCatalog.GetDefaultSong()
    assert(baseSong, "No playable songs are available")

    local difficulty = Config.Difficulties[payload.difficulty] and payload.difficulty or "Easy"
    local segmentLength = payload.segmentLength or "30s"
    local segmentStart = payload.segmentStart or "Intro"
    local song = ChartService.BuildPlayableChart(baseSong, difficulty, segmentLength, segmentStart)

    local sessionId = self:_buildSessionId(player, song.Id)
    local notesById, noteOrder = self:_attachNotes(song)
    local mode = Config.Modes[payload.mode] and payload.mode or Config.Modes.Career
    local venueId = payload.venueId or "SchoolStage"
    local currentTime = now()

    local session = {
        id = sessionId,
        playerId = player.UserId,
        player = player,
        songId = song.Id,
        baseSongId = baseSong.Id,
        song = song,
        baseSong = baseSong,
        difficulty = difficulty,
        difficultyConfig = ChartService.GetDifficultyConfig(difficulty),
        segmentLength = song.SegmentLength,
        segmentLabel = song.SegmentLabel,
        segmentStart = song.SegmentStart,
        segmentSection = song.SegmentSection,
        mode = mode,
        venueId = venueId,
        notesById = notesById,
        noteOrder = noteOrder,
        startServerTime = currentTime + Config.SongFlow.CountdownSeconds,
        countdownEndTime = currentTime + Config.SongFlow.CountdownSeconds,
        endServerTime = currentTime + Config.SongFlow.CountdownSeconds + (song.Duration or 30),
        state = "Countdown",
        stateData = self.context.Services.ScoreService:CreateState(song, mode),
        judgedNotes = 0,
        modifiers = {},
        lastActionAt = currentTime,
    }
    session.stateData.difficulty = difficulty
    session.stateData.segmentLength = song.SegmentLength

    session.GetSongTime = function()
        return now() - session.startServerTime
    end

    local profileData = profile or {}
    self.context.Services.BuffAttackService:_ensureSessionState(session)
    if profileData.Upgrades and profileData.Upgrades.Focus and profileData.Upgrades.Focus > 0 then
        session.modifiers.focusReduction = profileData.Upgrades.Focus
    end

    if profileData.OwnedCosmetics and profileData.OwnedCosmetics.Buffs and profileData.OwnedCosmetics.Buffs.CrowdWarmup then
        session.modifiers.crowdWarmup = true
        session.stateData.hype = 10
    end

    self.sessions[player.UserId] = session
    self.sessionById[sessionId] = session
    self.watchingSessionId = sessionId
    return session
end

function SongSessionService:StartSong(player, payload)
    local session = self:_createSession(player, payload or {})
    local profile = self.context.Services.DataService:GetProfile(player)
    if profile and profile.Equipped then
        session.visuals = require(ReplicatedStorage.Shared.CosmeticConfig).GetVisualProfile(profile.Equipped)
    end
    self.context.Remotes.StartSong:FireClient(player, {
        sessionId = session.id,
        song = session.song,
        mode = session.mode,
        venueId = session.venueId,
        startServerTime = session.startServerTime,
        countdownEndTime = session.countdownEndTime,
        endServerTime = session.endServerTime,
        visuals = session.visuals,
        profile = self.context.Services.DataService:GetSnapshot(player),
        difficulty = session.difficulty,
        difficultyConfig = session.difficultyConfig,
        segmentLength = session.segmentLength,
        segmentLabel = session.segmentLabel,
        segmentStart = session.segmentStart,
        segmentSection = session.segmentSection,
    })
    self.context.Services.HypeService:ApplyStartBonus(session, profile or {})
    if self.context.Services.AudienceService then
        self.context.Services.AudienceService:RefreshWatcher(player)
    end
    return session
end

function SongSessionService:StartDefaultSong(player)
    return self:StartSong(player, {
        songId = Config.DefaultSongId,
        mode = Config.Modes.Career,
        venueId = "SchoolStage",
    })
end

function SongSessionService:NoteHit(player, payload)
    local session = self:GetSession(player)
    local allowed, result = self.context.Services.AntiExploitService:ValidateNoteHit(player, payload, session)
    if not allowed then
        return false, result
    end

    local note = session.notesById[payload.noteId]
    local timingBonus = self.context.Services.ScoreService:GetTimingBonus(self.context.Services.DataService:GetProfile(player), session)
    local judgement = Scoring.ResolveJudgement(result, timingBonus)
    if judgement == "Reject" then
        return false, "Reject"
    end

    note.hit = true
    session.judgedNotes = session.judgedNotes + 1
    session.state = "Playing"

    local profile = self.context.Services.DataService:GetProfile(player)
    if not profile then
        return false, "NoProfile"
    end

    local summaryState = self.context.Services.ScoreService:ApplyJudgement(session, note, judgement, profile)
    if judgement == "Perfect" then
        self.context.Services.HypeService:ApplyPerfect(session, profile, note)
        self.context.Services.MissionService:RecordEvent(profile, "PerfectHit", 1, { player = player, songId = session.songId })
    elseif judgement == "Good" then
        self.context.Services.HypeService:ApplyGood(session, profile)
    else
        self.context.Services.HypeService:ApplyMiss(session, profile)
    end

    local missPenalty = self.context.Services.BuffAttackService:ApplyMissMitigation(session)
    if judgement == "Miss" and missPenalty > 0 then
        session.stateData.hype = math.min(100, session.stateData.hype + missPenalty)
    end

    if session.modifiers and session.modifiers.tubeResonanceUntil and now() < session.modifiers.tubeResonanceUntil and judgement == "Perfect" then
        session.stateData.hype = math.min(100, session.stateData.hype + 2)
    end
    if session.modifiers and session.modifiers.cleanRunSection and session.stateData.sectionMisses == 0 then
        session.stateData.hype = math.min(100, session.stateData.hype + 1)
    end

    if session.song.Sections then
        for index, section in ipairs(session.song.Sections) do
            local sectionSongTime = tonumber(payload.clientSongTime) or tonumber(payload.songTime) or 0
            if sectionSongTime >= section.start and sectionSongTime <= section.finish then
                session.currentSectionIndex = index
                break
            end
        end
    end

    self.context.Remotes.NoteJudged:FireClient(player, {
        sessionId = session.id,
        noteId = note.id,
        lane = note.lane,
        judgement = judgement,
        offset = result,
        score = summaryState.score,
        combo = summaryState.combo,
        multiplier = summaryState.multiplier,
        hype = summaryState.hype,
        hp = summaryState.hp,
        downed = summaryState.downed,
        lastDamage = summaryState.lastDamage,
        power = summaryState.power,
        visuals = self.context.Services.BuffAttackService:VisualModifiers(session),
    })

    self.context.Remotes.ScoreUpdate:FireClient(player, {
        score = summaryState.score,
        combo = summaryState.combo,
        maxCombo = summaryState.maxCombo,
        multiplier = summaryState.multiplier,
        hype = summaryState.hype,
        hp = summaryState.hp,
        downed = summaryState.downed,
        lastDamage = summaryState.lastDamage,
        power = summaryState.power,
        grade = Scoring.GetGrade(Scoring.GetAccuracyPercent(summaryState)),
        hypeTier = Scoring.GetHypeTier(summaryState.hype),
    })

    -- Stability hitting 0 enters Disaster Mode in the demo; the player can still finish.

    return true, judgement
end

function SongSessionService:UseBuff(player, payload)
    local session = self:GetSession(player)
    local ok, reason = self.context.Services.AntiExploitService:ValidateBuffUse(player, payload, session)
    if not ok then
        return false, reason
    end
    local profile = self.context.Services.DataService:GetProfile(player)
    if not profile then
        return false, "NoProfile"
    end
    local allowed, buffReason = self.context.Services.BuffAttackService:CanUse(profile, payload.buffId)
    if not allowed then
        return false, buffReason
    end
    local applied, applyReason = self.context.Services.BuffAttackService:ApplyBuff(session, profile, payload.buffId)
    if applied then
        self.context.Remotes.AudienceAction:FireClient(player, {
            action = "BuffUsed",
            buffId = payload.buffId,
        })
        self.context.Services.MissionService:RecordEvent(profile, "BuffUsed", 1, { player = player })
    end
    return applied, applyReason
end

function SongSessionService:UseAttack(player, payload)
    local session = self:GetSession(player)
    local ok, reason = self.context.Services.AntiExploitService:ValidateAttack(player, payload, session)
    if not ok then
        return false, reason
    end

    local targetPlayer = Players:GetPlayerByUserId(payload.targetUserId)
    if not targetPlayer then
        return false, "NoTarget"
    end
    local applied, applyReason = self.context.Services.BuffAttackService:ApplyAttack(player, targetPlayer, payload.attackId)
    if applied then
        self.context.Remotes.AudienceAction:FireAllClients({
            action = "AttackApplied",
            attackId = payload.attackId,
            sourceUserId = player.UserId,
            targetUserId = targetPlayer.UserId,
        })
    end
    return applied, applyReason
end

function SongSessionService:Update(dt)
    for userId, session in pairs(self.sessions) do
        if session.state ~= "Finished" then
            if session.state == "Countdown" and now() >= session.startServerTime then
                session.state = "Playing"
            end
            if now() >= session.endServerTime then
                self:FinishSession(session.player)
            else
                local allowedWindow = (Config.Judgement.AcceptWindow or 0.25) + (Config.Judgement.LatencyGrace or 0)
                for _, note in ipairs(session.noteOrder) do
                    if not note.hit and now() - session.startServerTime > note.time + allowedWindow then
                        note.hit = true
                        session.judgedNotes = session.judgedNotes + 1
                        local profile = self.context.Services.DataService:GetProfile(session.player)
                        session.stateData = self.context.Services.ScoreService:ApplyJudgement(session, note, "Miss", profile)
                        self.context.Services.HypeService:ApplyMiss(session, profile)
                        self.context.Remotes.NoteJudged:FireClient(session.player, {
                            sessionId = session.id,
                            noteId = note.id,
                            lane = note.lane,
                            judgement = "Miss",
                            offset = allowedWindow,
                            score = session.stateData.score,
                            combo = session.stateData.combo,
                            multiplier = session.stateData.multiplier,
                            hype = session.stateData.hype,
                            hp = session.stateData.hp,
                            downed = session.stateData.downed,
                            lastDamage = session.stateData.lastDamage,
                            power = session.stateData.power,
                            visuals = self.context.Services.BuffAttackService:VisualModifiers(session),
                        })
                        self.context.Remotes.ScoreUpdate:FireClient(session.player, {
                            score = session.stateData.score,
                            combo = session.stateData.combo,
                            maxCombo = session.stateData.maxCombo,
                            multiplier = session.stateData.multiplier,
                            hype = session.stateData.hype,
                            hp = session.stateData.hp,
                            downed = session.stateData.downed,
                            lastDamage = session.stateData.lastDamage,
                            power = session.stateData.power,
                            grade = Scoring.GetGrade(Scoring.GetAccuracyPercent(session.stateData)),
                            hypeTier = Scoring.GetHypeTier(session.stateData.hype),
                        })
                        -- Do not hard-stop at 0 Stability; finish the selected segment/song.

                    end
                end
            end
        end
    end
end

function SongSessionService:FinishSession(player)
    local session = self:GetSession(player)
    if not session or session.state == "Finished" then
        return nil
    end
    session.state = "Finished"
    local summary = self.context.Services.ScoreService:Finalize(session)
    local rewards = self.context.Services.EconomyService:FinalizeSong(player, session, summary)
    self.context.Remotes.SongFinished:FireClient(player, {
        sessionId = session.id,
        summary = summary,
        rewards = rewards,
        song = session.song,
        visuals = session.visuals,
    })
    self.context.Remotes.DataSnapshot:FireClient(player, self.context.Services.DataService:GetSnapshot(player))
    if session.mode == Config.Modes.Battle then
        self.context.Services.MissionService:RecordEvent(self.context.Services.DataService:GetProfile(player), "BattleWin", 1, { player = player })
    end
    return summary
end

function SongSessionService:RemoveSession(player)
    local session = self.sessions[player.UserId]
    if session then
        self.sessionById[session.id] = nil
    end
    self.sessions[player.UserId] = nil
end

return SongSessionService
