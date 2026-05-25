--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local ChartService = require(Shared.ChartService)
local Scoring = require(Shared.Scoring)
local SongCatalog = require(Shared.SongCatalog)
local UnitTests = require(Shared.UnitTests)
local WorldValidation = require(Shared.WorldV2.WorldValidation)
local UIUXValidation = require(Shared.WorldV2.UIUXValidation)

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
    print("[GameTestHarness] Starting test suite...")

    -- 1. Run UnitTests
    local unitResult = UnitTests.Run()
    assert(unitResult.failed == 0, "UnitTests must pass")

    -- 2. Run simulation
    local run = GameTestHarness.BuildSimulatedRun(nil, "Easy", "20s")
    assert(run.song.Duration == 20, "Harness 20s duration mismatch")
    assert(#run.events == #run.song.Notes, "Harness event count mismatch")
    assert(run.summary.perfect > 0, "Harness expected perfect hits")
    assert(run.summary.good > 0, "Harness expected good hits")
    assert(run.summary.grade == "S" or run.summary.grade == "A", "Harness expected strong grade")

    -- 3. If on Server, test game service integrations
    if RunService:IsServer() then
        local ServerScriptService = game:GetService("ServerScriptService")
        local services = ServerScriptService:FindFirstChild("Services")
        if services then
            local SongSessionService = require(services:FindFirstChild("SongSessionService"))
            local Players = game:GetService("Players")
            local player = Players:GetPlayers()[1]
            if player then
                print("[GameTestHarness] Simulating SongSessionService active play on Server for: " .. player.Name)

                -- Start Song Session
                local session = SongSessionService:StartSong(player, {
                    songId = "LocalAudioSong001",
                    difficulty = "Easy",
                    segmentLength = "20s",
                })
                assert(session, "Failed to start song session via SongSessionService")

                -- Simulate note hit
                local note = session.notes[1]
                if note then
                    local hitPayload = {
                        sessionId = session.id,
                        songId = "LocalAudioSong001",
                        noteId = note.id,
                        lane = note.lane,
                        clientSongTime = note.time,
                        clientDelta = 0,
                    }
                    SongSessionService:NoteHit(player, hitPayload)
                    assert(note.hit == true, "Expected note to be marked hit on the server")
                    print("[GameTestHarness] NoteHit successfully processed and note marked as hit")
                end

                -- Remove session
                SongSessionService:RemoveSession(player)
            else
                print("[GameTestHarness] Warning: No active player found to simulate live session hit")
            end
        end

        -- WorldV2 validation and prompt paths check
        local worldResult = WorldValidation.Run()
        assert(worldResult.ok == true, "WorldValidation must pass")
        local counts = worldResult.counts or {}
        print("[GameTestHarness] Active WorldV2 Models: " .. tostring(counts.models or 0))
        print("[GameTestHarness] Active WorldV2 MeshParts: " .. tostring(counts.meshParts or 0))
        print("[GameTestHarness] Active WorldV2 visible BaseParts: " .. tostring(counts.visibleBaseParts or 0))
        print("[GameTestHarness] ArtAssets source models: " .. tostring(counts.artAssetSourceModels or 0))
        print("[GameTestHarness] Quarantined scripts: " .. tostring(counts.quarantinedScripts or 0))
        print("[GameTestHarness] Missing required assets: " .. tostring(counts.missingRequiredAssets or 0))
        print("[GameTestHarness] Visible placeholder violations: " .. tostring(counts.visiblePlaceholderViolations or 0))
        print("[GameTestHarness] Audit scripts: " .. tostring(counts.auditScripts or 0))
        print("[GameTestHarness] Audit MeshParts: " .. tostring(counts.auditMeshParts or 0))
        print("[GameTestHarness] Audit parts: " .. tostring(counts.auditParts or 0))
        print("[GameTestHarness] Audit sounds: " .. tostring(counts.auditSounds or 0))
        print("[GameTestHarness] Audit emitters: " .. tostring(counts.auditEmitters or 0))
        print("[GameTestHarness] Audit lights: " .. tostring(counts.auditLights or 0))
        print("[GameTestHarness] Audit decals: " .. tostring(counts.auditDecals or 0))
        print("[GameTestHarness] Audit SurfaceAppearances: " .. tostring(counts.auditSurfaceAppearances or 0))
    end

    -- 4. If on Client, test UI modals
    if RunService:IsClient() then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local rhythmGui = player.PlayerGui:FindFirstChild("RhythmGui")
        if rhythmGui then
            local modal = rhythmGui.Root:FindFirstChild("SongSelectModal")
            if modal then
                modal.Visible = true
                print("[GameTestHarness] Client UI: SongSelectModal successfully opened")
                task.wait(0.1)
                modal.Visible = false
                print("[GameTestHarness] Client UI: SongSelectModal successfully closed")
                task.wait(0.1)
                modal.Visible = true
                print("[GameTestHarness] Client UI: SongSelectModal successfully reopened")
            end
        end
        local uiResult = UIUXValidation.Run(player)
        assert(uiResult.ok == true, "UIUXValidation must pass")
    end

    print("[GameTestHarness] ALL HARNESS TESTS PASSED SUCCESSFULLY!")
    return run
end

return GameTestHarness
