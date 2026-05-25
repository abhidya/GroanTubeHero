--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Scoring = require(Shared.Scoring)
local ChartService = require(Shared.ChartService)
local SongCatalog = require(Shared.SongCatalog)
local WorldValidation = require(Shared.WorldV2.WorldValidation)
local AssetAuditService = require(Shared.WorldV2.AssetAuditService)
local AssetRegistry = require(Shared.WorldV2.AssetRegistry)
local VendorDefinitions = require(Shared.WorldV2.VendorDefinitions)

local AntiExploitService
if RunService:IsServer() then
    local ServerScriptService = game:GetService("ServerScriptService")
    local services = ServerScriptService:FindFirstChild("Services")
    if services then
        AntiExploitService = require(services:FindFirstChild("AntiExploitService"))
    end
end

local UnitTests = {}

local function fail(message: string): ()
    error("[UnitTests] " .. message, 2)
end

local function expectEqual(actual: any, expected: any, label: string): ()
    if actual ~= expected then
        fail(label .. " expected " .. tostring(expected) .. " got " .. tostring(actual))
    end
end

local function expect(condition: boolean, label: string): ()
    if not condition then
        fail(label)
    end
end

local function makeSong()
    local notes = {}
    for index = 1, 12 do
        notes[index] = {
            id = "n" .. index,
            time = index * 1.5,
            lane = ((index - 1) % 4) + 1,
        }
    end
    return {
        Id = "UnitSong",
        Title = "001 - Unit_Test_Track_Official_Video [abc]",
        Duration = 60,
        Sections = {
            { name = "Intro", start = 0 },
            { name = "Middle", start = 20 },
        },
        Notes = notes,
    }
end

local function testScoring(): ()
    expectEqual(Scoring.GetScoreValue("Perfect"), Config.Judgement.PerfectScore, "perfect score")
    expectEqual(Scoring.GetScoreValue("Good"), Config.Judgement.GoodScore, "good score")
    expectEqual(Scoring.GetScoreValue("Miss"), Config.Judgement.MissScore, "miss score")
    expectEqual(Scoring.ResolveJudgement(0), "Perfect", "zero offset perfect")
    expectEqual(Scoring.ResolveJudgement(Config.Judgement.GoodWindow), "Good", "good window")
    expectEqual(Scoring.ResolveJudgement(Config.Judgement.AcceptWindow + Config.Judgement.LatencyGrace + 0.01), "Reject", "outside window reject")
    expect(Scoring.GetMultiplier(Config.Judgement.ComboStep) > 1, "combo multiplier increases")
    expect(Scoring.GetMultiplier(9999) <= Config.Judgement.MultiplierMax, "combo multiplier caps")
    expectEqual(Scoring.GetGrade(96), "S", "S grade")
    expectEqual(Scoring.GetGrade(86), "A", "A grade")
    expectEqual(Scoring.GetGrade(71), "B", "B grade")
    expectEqual(Scoring.GetGrade(56), "C", "C grade")
    expectEqual(Scoring.GetGrade(10), "D", "D grade")
end

local function testChartSegments(): ()
    local song = makeSong()
    local playable = ChartService.BuildPlayableChart(song, "Easy", "20s", "Intro")
    expectEqual(playable.Duration, 20, "20s duration")
    expectEqual(playable.SegmentLength, "20s", "20s segment id")
    expect(#playable.Notes >= 8, "segment filler creates playable notes")
    local seen = {}
    for _, note in ipairs(playable.Notes) do
        expect(type(note.id) == "string" and note.id ~= "", "note id exists")
        expect(not seen[note.id], "unique note id " .. tostring(note.id))
        seen[note.id] = true
        expect(type(note.time) == "number" and note.time >= 0, "note time nonnegative")
        expect(type(note.lane) == "number" and note.lane >= 1 and note.lane <= 4, "lane 1-4")
    end
    local hard = ChartService.BuildPlayableChart(song, "Hard", "20s", "Intro")
    local extreme = ChartService.BuildPlayableChart(song, "Extreme", "20s", "Intro")
    expect(#hard.Notes >= #playable.Notes, "hard at least easy density")
    expect(#extreme.Notes >= #hard.Notes, "extreme at least hard density")
end

local function testCatalogTitles(): ()
    -- PrettyTitle cleanup examples
    expectEqual(SongCatalog.CleanRawTitle("001 - 003 — [abc123] Official Music Video Extended"), "Untitled Song", "clean raw title 1")
    expectEqual(SongCatalog.CleanRawTitle("039—Love Me Not [hash]"), "Love Me Not", "clean raw title 2")
    expectEqual(SongCatalog.CleanRawTitle("12 - 04 – Song Name - Music"), "Song Name", "clean raw title 3")

    -- Test PrettyTitle override is returned correctly
    local pretty = SongCatalog.PrettyTitle("LocalAudioSong001")
    expectEqual(pretty, "Thick of It Thomas the Train Remix", "pretty title resolves override")
end

local function testSongCounts(): ()
    -- SongCatalog valid count is 21
    expectEqual(#SongCatalog.LocalTest, 21, "21 playable local test songs in catalog")

    -- UkedCharts count is 18
    local ukedFolder = Shared:FindFirstChild("UkedCharts")
    expect(ukedFolder ~= nil, "UkedCharts folder exists in Shared")
    local count = 0
    if ukedFolder then
        for _, child in ipairs(ukedFolder:GetChildren()) do
            if child:IsA("ModuleScript") and child.Name:match("^Chart_LocalAudioSong%d+$") then
                count = count + 1
            end
        end
    end
    expectEqual(count, 18, "18 quarantined charts in UkedCharts")
end


local function testAssetAuditService(): ()
    local folder = Instance.new("Folder")
    folder.Name = "AuditFixture"
    local part = Instance.new("Part")
    part.Name = "FixturePart"
    part.Parent = folder
    local sound = Instance.new("Sound")
    sound.Parent = folder
    local emitter = Instance.new("ParticleEmitter")
    emitter.Parent = part
    local counts = AssetAuditService.Audit(folder)
    expectEqual(counts.parts, 1, "asset audit counts parts")
    expectEqual(counts.sounds, 1, "asset audit counts sounds")
    expectEqual(counts.emitters, 1, "asset audit counts emitters")
    expectEqual(counts.scripts, 0, "asset audit no scripts")
    folder:Destroy()
end

local function testAssetRegistryMissingBehavior(): ()
    local missing, reason = AssetRegistry.Resolve("Truss")
    expect(missing == nil, "missing optional truss returns nil")
    expect(reason == "MissingOptionalAsset" or reason == nil, "missing optional truss reports optional missing")
    local unknown, unknownReason = AssetRegistry.Resolve("DoesNotExist")
    expect(unknown == nil, "unknown registry entry returns nil")
    expectEqual(unknownReason, "UnknownAssetRegistryEntry", "unknown registry reason")
end

local function testWorldValidationPlaceholderDetection(): ()
    local model = Instance.new("Model")
    model.Name = "PlaceholderFixture"
    local raw = Instance.new("Part")
    raw.Name = "Block"
    raw.Transparency = 0
    raw.Parent = model
    local counts = WorldValidation.CountActive(model)
    expectEqual(counts.visiblePlaceholderViolations, 1, "visible placeholder Block counted")
    model:Destroy()
end

local function testWorldValidationScriptDetection(): ()
    local model = Instance.new("Model")
    model.Name = "GTH_WorldV2"
    local untrustedScript = Instance.new("Script")
    untrustedScript.Name = "UntrustedImportedScript"
    untrustedScript.Parent = model
    local counts = WorldValidation.CountActive(model)
    expectEqual(counts.activeWorldScripts, 1, "script under WorldV2 counted separately from quarantine")
    expectEqual(counts.quarantinedScripts, 0, "active WorldV2 script is not mislabeled as quarantined")
    model:Destroy()
end

local function testFanNpcCreatorLocalManifest(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping fan NPC Creator manifest test (not on server)")
        return
    end
    local serverScriptService = game:GetService("ServerScriptService")
    local builderScript = serverScriptService:FindFirstChild("Services") and serverScriptService.Services:FindFirstChild("WorldV2Builder")
    if not builderScript then
        print("[UnitTests] WorldV2Builder not found, skipping fan NPC Creator manifest test")
        return
    end
    local source = ""
    local readable = pcall(function()
        source = builderScript.Source
    end)
    if not readable then
        print("[UnitTests] WorldV2Builder.Source not readable in this runtime, skipping fan NPC Creator manifest test")
        return
    end
    expect(source:find("Workspace.AssetInbox.FanNPC_CreatorLocal", 1, true) ~= nil, "fan NPC Creator import stages through AssetInbox")
    expect(source:find("ReplicatedStorage.ArtAssets.Audience.Clean_FanNPCCreatorLocalPack", 1, true) ~= nil, "fan NPC Creator clean ArtAssets path recorded")
    expect(source:find("QuarantineScripts(rawPack", 1, true) ~= nil, "fan NPC Creator raw scripts quarantined before promotion")
    expect(source:find("Audited_FanNPCCreatorLocalCrowd_", 1, true) ~= nil, "fan NPC Creator clean pack is placed as audited audience crowd")
end

local function testVendorDialoguePrompts(): ()
    for _, def in ipairs(VendorDefinitions) do
        expect(type(def.Prompt) == "string" and def.Prompt ~= "", "vendor prompt text exists for " .. tostring(def.Id))
        expect(type(def.ObjectText) == "string" and def.ObjectText ~= "", "vendor object text exists for " .. tostring(def.Id))
        expect(type(def.Dialogue) == "string" and def.Dialogue ~= "", "vendor dialogue exists for " .. tostring(def.Id))
        expect(type(def.ActionPrompt) == "string" and def.ActionPrompt ~= "", "vendor action prompt exists for " .. tostring(def.Id))
    end
end

local function testConfigLanes(): ()
    for _, lane in ipairs(Config.Lanes) do
        expect(lane.symbol == "←" or lane.symbol == "→" or lane.symbol == "↑" or lane.symbol == "↓", "lane symbol is arrow")
    end
end

local function testAntiExploit(): ()
    if not AntiExploitService then
        print("[UnitTests] Skipping AntiExploit tests (not on server)")
        return
    end

    local currentTime = workspace.GetServerTimeNow and workspace:GetServerTimeNow() or os.clock()
    local mockSession = {
        id = "session1",
        songId = "LocalAudioSong001",
        state = "Playing",
        startServerTime = currentTime - 10,
        endServerTime = currentTime + 20,
        notesById = {
            note1 = { id = "note1", time = 5.0, lane = 1 }
        }
    }

    local songTime = currentTime - mockSession.startServerTime
    mockSession.notesById.note1.time = songTime

    local payload = {
        sessionId = "session1",
        songId = "LocalAudioSong001",
        noteId = "note1",
        lane = 1,
    }

    -- 1. On-time server hit
    local ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expect(ok, "on-time server hit validation passes")

    -- 2. Valid late clientDelta within latency grace
    mockSession.notesById.note1.time = songTime - 0.12
    payload.clientDelta = 0.1
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expect(ok, "valid late clientDelta within latency grace passes")
    expectEqual(result, 0.1, "chosen offset is clientDelta")

    -- 3. Invalid spoofed clientDelta far from serverOffset
    mockSession.notesById.note1.time = songTime - 0.35
    payload.clientDelta = 0.05
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expectEqual(ok, false, "spoofed clientDelta far from serverOffset fails")
    expectEqual(result, "SpoofedClientDelta", "returns SpoofedClientDelta")

    -- 4. Duplicate note rejection
    mockSession.notesById.note1.hit = true
    payload.clientDelta = nil
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expectEqual(ok, false, "duplicate hit fails")
    expectEqual(result, "DuplicateHit", "returns DuplicateHit")

    -- Restore
    mockSession.notesById.note1.hit = nil

    -- 5. Wrong lane rejection
    payload.lane = 2
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expectEqual(ok, false, "wrong lane hit fails")
    expectEqual(result, "WrongLane", "returns WrongLane")
end

local function testHordeRootPivot(): ()
    local world = workspace:FindFirstChild("GTH_WorldV2")
    local hordeRing = world and world:FindFirstChild("HordeRing")
    local hordeRoot = hordeRing and hordeRing:FindFirstChild("HordeSector_N") and hordeRing.HordeSector_N:FindFirstChild("HordeCluster")
    if hordeRoot and hordeRoot:IsA("Model") then
        local originalCFrame = hordeRoot:GetPivot()
        local ok, err = pcall(function()
            hordeRoot:PivotTo(originalCFrame * CFrame.new(0, 1, 0))
            hordeRoot:PivotTo(originalCFrame)
        end)
        expect(ok, "WorldV2 HordeCluster model PivotTo does not throw error: " .. tostring(err))
    else
        print("[UnitTests] WorldV2 HordeCluster model not found in workspace, skipping pivot test")
    end
end

local function testWorldV2Validation(): ()
    if RunService:IsServer() then
        local result = WorldValidation.Run()
        expect(result.ok == true, "WorldValidation passes")
        expect(result.counts.missingRequiredAssets == 0, "WorldValidation missing required assets is zero")
        expect(type(result.counts.auditParts) == "number", "WorldValidation includes audit counts")
        expectEqual(result.counts.activeWorldScripts, 0, "WorldValidation active WorldV2 scripts is zero")
    end
end

function UnitTests.Run(): { passed: number, failed: number, failures: { string } }
    local tests = {
        testScoring,
        testChartSegments,
        testCatalogTitles,
        testSongCounts,
        testAssetAuditService,
        testAssetRegistryMissingBehavior,
        testWorldValidationPlaceholderDetection,
        testWorldValidationScriptDetection,
        testFanNpcCreatorLocalManifest,
        testVendorDialoguePrompts,
        testConfigLanes,
        testAntiExploit,
        testHordeRootPivot,
        testWorldV2Validation,
    }
    local failures = {}
    for _, test in ipairs(tests) do
        local ok, err = pcall(test)
        if not ok then
            table.insert(failures, tostring(err))
        end
    end
    local result = {
        passed = #tests - #failures,
        failed = #failures,
        failures = failures,
    }
    if result.failed == 0 then
        print("[UnitTests] PASS", result.passed)
    else
        warn("[UnitTests] FAIL", result.failed, table.concat(failures, " | "))
    end
    return result
end

return UnitTests
