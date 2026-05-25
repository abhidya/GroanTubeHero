--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local ChartService = require(Shared.ChartService)
local Scoring = require(Shared.Scoring)
local SongCatalog = require(Shared.SongCatalog)

local GameTestHarness = {}

local function notePayload(sessionId: string, songId: string, note: any, delta: number)
    return {
        sessionId = sessionId,
        songId = songId,
        noteId = note.id,
        lane = note.lane,
        clientSongTime = note.time + delta,
        clientDelta = delta,
    }
end

function GameTestHarness.BuildSimulatedRun(songId: string?, difficulty: string?, segmentLength: string?)
    local baseSong = SongCatalog.Get(songId or Config.DefaultSongId) or SongCatalog.GetDefaultSong()
    assert(baseSong, "No playable songs available for harness")
    local playable = ChartService.BuildPlayableChart(baseSong, difficulty or "Easy", segmentLength or "20s", "Intro")
    local sessionId = "Harness-" .. playable.Id .. "-" .. tostring(math.floor(os.clock() * 1000))
    local events = {}
    local state = {
        totalNotes = #playable.Notes,
        score = 0,
        accuracyPoints = 0,
        perfect = 0,
        good = 0,
        miss = 0,
        combo = 0,
        maxCombo = 0,
        hype = 0,
        hp = 100,
        mode = Config.Modes.Career,
    }
    for index, note in ipairs(playable.Notes) do
        local delta = (index % 5 == 0) and (Config.Judgement.GoodWindow * 0.85) or 0
        local judgement = Scoring.ResolveJudgement(delta)
        if judgement == "Perfect" then
            state.perfect += 1
            state.combo += 1
            state.score += Scoring.GetScoreValue(judgement) * Scoring.GetMultiplier(state.combo)
            state.accuracyPoints += Config.Judgement.PerfectScore
            state.hype = math.min(100, state.hype + 4)
        elseif judgement == "Good" then
            state.good += 1
            state.combo += 1
            state.score += Scoring.GetScoreValue(judgement) * Scoring.GetMultiplier(state.combo)
            state.accuracyPoints += Config.Judgement.GoodScore
            state.hype = math.min(100, state.hype + 2)
        else
            state.miss += 1
            state.combo = 0
            state.hp = math.max(0, state.hp - 8)
        end
        state.maxCombo = math.max(state.maxCombo, state.combo)
        table.insert(events, {
            payload = notePayload(sessionId, playable.Id, note, delta),
            judgement = judgement,
        })
    end
    return {
        sessionId = sessionId,
        song = playable,
        events = events,
        summary = Scoring.BuildSummary(state),
    }
end

function GameTestHarness.Run()
    local run = GameTestHarness.BuildSimulatedRun(nil, "Easy", "20s")
    assert(run.song.Duration == 20, "Harness 20s duration mismatch")
    assert(#run.events == #run.song.Notes, "Harness event count mismatch")
    assert(run.summary.perfect > 0, "Harness expected perfect hits")
    assert(run.summary.good > 0, "Harness expected good hits")
    assert(run.summary.grade == "S" or run.summary.grade == "A", "Harness expected strong grade")
    print(string.format("[GameTestHarness] PASS song=%s events=%d grade=%s accuracy=%.1f", run.song.Id, #run.events, run.summary.grade, run.summary.accuracyPercent))
    return run
end

return GameTestHarness
