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

local function assertCreatorStudioAuditedAssetsOnly(counts: any)
    -- Regression contract for visible art:
    -- WorldValidation owns the deep asset traversal; the harness keeps the
    -- gate explicit in the all-up test output so Creator/Studio audited assets
    -- cannot be replaced by raw fallback/procedural visible parts unnoticed.
    assert((counts.missingRequiredAssets or 0) == 0, "Creator/Studio audit: missing required ArtAssets")
    assert((counts.visiblePlaceholderViolations or 0) == 0, "Creator/Studio audit: visible placeholder art found")
    assert((counts.unauditedAssetPlacements or 0) == 0, "Creator/Studio audit: unaudited visible placements found")
    assert((counts.autogenBlankMeshesExcluded or 0) == 0, "Creator/Studio audit: autogen/blank visible placements found")
    assert((counts.activePlacedArtInstances or 0) > 0, "Creator/Studio audit: expected active audited art placements")
end

local function assertAuditedUiAssetContract(contract: any)
    assert(type(contract) == "table", "UI audit contract must be table")
    assert(contract.allowedWhenAuditedAttributesPresent == true, "UI audit contract must allow explicitly audited Studio assets")
    assert(type(contract.disallowedImageClasses) == "table", "UI audit contract must list image classes")
    assert(contract.disallowedImageClasses.ImageButton == true, "UI audit contract must guard ImageButton assets")
    assert(contract.disallowedImageClasses.ImageLabel == true, "UI audit contract must guard ImageLabel assets")
end

local function assertUiAuditFixture(root: Instance)
    local fixture = Instance.new("ImageLabel")
    fixture.Name = "HarnessUnauditedUiAssetFixture"
    fixture.BackgroundTransparency = 1
    fixture.Image = "rbxassetid://1"
    fixture.Visible = true
    fixture.Parent = root

    local unauditedResult = UIUXValidation.ValidateAuditedUiVisualAssets(root)

    fixture:SetAttribute("AuditedArtAsset", true)
    fixture:SetAttribute("AssetSourcePath", "Harness/StudioAuditedUiFixture")
    local auditedResult = UIUXValidation.ValidateAuditedUiVisualAssets(root)
    fixture:Destroy()

    assert(unauditedResult.ok == false, "UI audit fixture: unaudited image asset should fail")
    assert(auditedResult.ok == true, "UI audit fixture: audited Studio image asset should pass")
end

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

    -- 3. WorldV2/asset placement validation runs in every harness context.
    local worldResult = WorldValidation.Run()
    assert(worldResult.ok == true, "WorldValidation must pass")
    local counts = worldResult.counts or {}
    assertCreatorStudioAuditedAssetsOnly(counts)
    print("[GameTestHarness] Active WorldV2 Models: " .. tostring(counts.models or 0))
    print("[GameTestHarness] Active WorldV2 MeshParts: " .. tostring(counts.meshParts or 0))
    print("[GameTestHarness] Active WorldV2 visible BaseParts: " .. tostring(counts.visibleBaseParts or 0))
    print("[GameTestHarness] Active placed art instances: " .. tostring(counts.activePlacedArtInstances or 0))
    print("[GameTestHarness] ArtAssets source models: " .. tostring(counts.artAssetSourceModels or 0))
    print("[GameTestHarness] Quarantined scripts: " .. tostring(counts.quarantinedScripts or 0))
    print("[GameTestHarness] Missing required assets: " .. tostring(counts.missingRequiredAssets or 0))
    print("[GameTestHarness] Visible placeholder violations: " .. tostring(counts.visiblePlaceholderViolations or 0))
    print("[GameTestHarness] Unaudited asset placements: " .. tostring(counts.unauditedAssetPlacements or 0))
    print("[GameTestHarness] Autogen blank meshes excluded: " .. tostring(counts.autogenBlankMeshesExcluded or 0))
    print("[GameTestHarness] Creator/Studio audited assets only: PASS")

    -- 4. If on Server, test game service integrations
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

        -- WorldV2 validation already ran above in all contexts.
    end

    -- 4. If on Client, test UI modals
    if RunService:IsClient() then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer or Players:GetPlayers()[1]
        local playerGui = player and (player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 2))
        if not playerGui then
            print("[GameTestHarness] Client UI validation skipped: no LocalPlayer/PlayerGui in this execution context")
            return run
        end
        local rhythmGui = playerGui:FindFirstChild("RhythmGui")
        if rhythmGui then
            local root = rhythmGui:FindFirstChild("Root")
            if root then
                assertUiAuditFixture(root)
            end
            local modal = root and root:FindFirstChild("SongSelectModal")
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
        assertAuditedUiAssetContract(uiResult.auditedUiVisualAssetContract)
    end

    print("[GameTestHarness] ALL HARNESS TESTS PASSED SUCCESSFULLY!")
    return run
end

return GameTestHarness
