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
local RoomConfig = require(Shared.WorldV2.RoomConfig)

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

local function requireServerServiceClone(serviceName: string): any
    if not RunService:IsServer() then
        fail("server service clone requested on client: " .. serviceName)
    end
    local serverScriptService = game:GetService("ServerScriptService")
    local services = serverScriptService:FindFirstChild("Services")
    local moduleScript = services and services:FindFirstChild(serviceName)
    if not (moduleScript and moduleScript:IsA("ModuleScript")) then
        fail("missing server service ModuleScript: " .. serviceName)
    end
    local clone = moduleScript:Clone()
    clone.Name = serviceName .. "_UnitTestClone"
    clone.Parent = services
    local ok, result = pcall(require, clone)
    clone:Destroy()
    if not ok then
        fail("failed to require service clone " .. serviceName .. ": " .. tostring(result))
    end
    return result
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
    local defaultSong = SongCatalog.Get("LocalAudioSong001")
    expect(defaultSong ~= nil, "LocalAudioSong001 exists in catalog")
    expect(defaultSong and defaultSong.Title ~= "Local Audio Song 001", "SongCatalog keeps readable song title visible")
end

local function testSongCounts(): ()
    -- SongCatalog valid count is 22
    expectEqual(#SongCatalog.LocalTest, 22, "22 playable local test songs in catalog")

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
    local stageCandidates = AssetRegistry.GetSearchCandidates("StageConcertPack")
    expect(stageCandidates and stageCandidates.query == "concert stage lights speakers", "asset search candidate query recorded")
    expect(type(stageCandidates.assetIds) == "table" and #stageCandidates.assetIds >= 3, "asset search candidate ids recorded")
    local roomCandidateBuckets = {
        "CyberArcadeOverclock",
        "SubwayMemeTunnel",
        "HauntedKaraokeTheater",
        "AquariumBassDrop",
        "DoomscrollDataCenter",
    }
    for _, bucketName in ipairs(roomCandidateBuckets) do
        local bucket = AssetRegistry.GetSearchCandidates(bucketName)
        expect(bucket ~= nil, bucketName .. " room expansion search bucket exists")
        expect(bucket.reviewState == "claimed_maybe_requires_studio_inspection", bucketName .. " is not treated as palette-approved")
        expect(type(bucket.assetIds) == "table" and #bucket.assetIds >= 5, bucketName .. " has a real MCP inspection shortlist")
    end
    local cyberReadiness = AssetRegistry.GetRoomAssetReadiness("cyber_arcade_overclock")
    expectEqual(cyberReadiness.visualStatus, "inspected_with_fixes", "Cyber Arcade readiness mirrors Studio asset lab result")
    expectEqual(cyberReadiness.passCount, 1, "Cyber Arcade has one pass asset")
    expectEqual(cyberReadiness.fixCount, 1, "Cyber Arcade has one fix asset")
    expect(cyberReadiness.paletteCommitted == true, "Cyber Arcade inspection palette is committed")
    expectEqual(cyberReadiness.paletteAssetCount, 2, "Cyber Arcade has two committed inspection-palette assets")
    expect(cyberReadiness.publishPermission == "missing", "publish permission gap remains explicit")
    expectEqual(cyberReadiness.placementStatus, "palette_committed_pending_permission_and_fragment", "committed palette still waits on permission and fragment merge")
    local aquariumReadiness = AssetRegistry.GetRoomAssetReadiness("aquarium_bass_drop")
    expect(aquariumReadiness.paletteCommitted == true, "Aquarium Bass Drop inspection palette is committed")
    expectEqual(aquariumReadiness.paletteAssetCount, 2, "Aquarium Bass Drop has two committed inspection-palette assets")
    local hauntedReadiness = AssetRegistry.GetRoomAssetReadiness("haunted_karaoke_theater")
    expect(hauntedReadiness.paletteCommitted == true, "Haunted Karaoke Theater inspection palette is committed")
    local doomscrollReadiness = AssetRegistry.GetRoomAssetReadiness("doomscroll_data_center")
    expect(doomscrollReadiness.paletteCommitted == true, "Doomscroll Data Center inspection palette is committed")
    local subwayReadiness = AssetRegistry.GetRoomAssetReadiness("subway_meme_tunnel")
    expectEqual(subwayReadiness.visualStatus, "candidate_rejected", "Subway records rejected oversized station candidate")
    expectEqual(subwayReadiness.rejectCount, 1, "Subway has one rejected inspected asset")
    expect(subwayReadiness.paletteCommitted == false, "Subway remains uncommitted after rejected oversized shell")
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

local function testWorldValidationRejectsFakeAuditedSourceIds(): ()
    local model = Instance.new("Model")
    model.Name = "GTH_WorldV2"
    local fake = Instance.new("Part")
    fake.Name = "FakeAuditedPlacement"
    fake.Transparency = 0
    fake:SetAttribute("AuditedArtAsset", true)
    fake:SetAttribute("AssetSourcePath", "ReplicatedStorage.ArtAssets.FakeDistinctId_001")
    fake.Parent = model
    local counts = WorldValidation.CountActive(model)
    expectEqual(counts.activePlacedArtInstances, 0, "fake audited source path does not count as placed art")
    expectEqual(counts.invalidAuditedSourcePaths, 1, "fake audited source path counted as invalid")
    expectEqual(counts.unauditedAssetPlacements, 1, "fake audited source remains unaudited placement")
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


local function testCreatorStoreBucketManifestSource(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping Creator Store bucket manifest source test (not on server)")
        return
    end
    local serverScriptService = game:GetService("ServerScriptService")
    local builderScript = serverScriptService:FindFirstChild("Services") and serverScriptService.Services:FindFirstChild("WorldV2Builder")
    if not builderScript then
        print("[UnitTests] WorldV2Builder not found, skipping Creator Store bucket manifest source test")
        return
    end
    local source = ""
    local readable = pcall(function()
        source = builderScript.Source
    end)
    if not readable then
        print("[UnitTests] WorldV2Builder.Source not readable in this runtime, skipping Creator Store bucket manifest source test")
        return
    end

    local requiredRoots = {
        "Workspace.AssetInbox",
        "ServerStorage.AssetQuarantine",
        "ReplicatedStorage.ArtAssets.Stage.Clean_ConcertStageTrussSpeakerLights",
        "ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde",
        "ReplicatedStorage.ArtAssets.Audience.Clean_FanNPCCreatorLocalPack",
        "ReplicatedStorage.ArtAssets.Vendors.Clean_VendorKioskShopCounter",
        "ReplicatedStorage.ArtAssets.Volcano.Clean_VolcanoRockLavaCliff",
        "ReplicatedStorage.ArtAssets.Vendors.Clean_CreatorVendorStation_425283754",
        "ReplicatedStorage.ArtAssets.Props.Clean_CreatorSecurityConsole_11864290745",
        "ReplicatedStorage.ArtAssets.TourBus.Clean_CreatorTourBusProp_75431387",
    }
    for _, needle in ipairs(requiredRoots) do
        expect(source:find(needle, 1, true) ~= nil, "Creator Store bucket/source path present: " .. needle)
    end

    for _, category in ipairs({ "stageCore", "lightingAndTrusses", "vendorRing", "fenceRing", "hordeRing", "audienceRing", "volcanoOuterRing", "tourBusAndSpawn" }) do
        expect(source:find(category, 1, true) ~= nil, "Creator Store placement bucket present: " .. category)
    end

    expect(source:find("QuarantineScripts", 1, true) ~= nil, "Creator Store/local import pipeline quarantines scripts")
    expect(source:find("AssetInbox is quarantine/inbox only", 1, true) ~= nil, "AssetInbox is explicitly inactive visual staging")
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

    -- 3. Valid client input timestamp survives realistic remote latency.
    mockSession.notesById.note1.time = songTime - 0.45
    payload.clientDelta = 0
    payload.clientInputServerTime = mockSession.startServerTime + mockSession.notesById.note1.time
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expect(ok, "server-synced client input time survives realistic remote latency")
    expectEqual(result, 0, "client input timestamp chooses the visual hit offset")
    payload.clientInputServerTime = nil

    -- 4. Stale client input timestamps are rejected.
    payload.clientDelta = 0
    payload.clientInputServerTime = currentTime - ((Config.Judgement.ClientInputMaxAge or 1.25) + 0.5)
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expectEqual(ok, false, "stale client input timestamp fails")
    expectEqual(result, "UntrustedClientInputTime", "returns UntrustedClientInputTime")
    payload.clientInputServerTime = nil

    -- 5. Invalid spoofed clientDelta far from serverOffset
    mockSession.notesById.note1.time = songTime - 0.35
    payload.clientDelta = 0.05
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expectEqual(ok, false, "spoofed clientDelta far from serverOffset fails")
    expectEqual(result, "SpoofedClientDelta", "returns SpoofedClientDelta")

    -- 6. Duplicate note rejection
    mockSession.notesById.note1.hit = true
    payload.clientDelta = nil
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expectEqual(ok, false, "duplicate hit fails")
    expectEqual(result, "DuplicateHit", "returns DuplicateHit")

    -- Restore
    mockSession.notesById.note1.hit = nil

    -- 7. Wrong lane rejection
    payload.lane = 2
    ok, result = AntiExploitService:ValidateNoteHit(nil, payload, mockSession)
    expectEqual(ok, false, "wrong lane hit fails")
    expectEqual(result, "WrongLane", "returns WrongLane")
end


local function getScriptSource(container: Instance?, name: string, className: string): string
    local scriptObj = container and container:FindFirstChild(name, true)
    expect(scriptObj ~= nil and scriptObj:IsA(className), name .. " " .. className .. " exists")
    return scriptObj and scriptObj.Source or ""
end

local function expectSourceContains(source: string, needle: string, label: string): ()
    expect(source:find(needle, 1, true) ~= nil, label)
end

local function testRhythmInputClientSourceContract(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping rhythm input client source contract (not on server)")
        return
    end
    local starterPlayerScripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    expect(starterPlayerScripts ~= nil, "StarterPlayerScripts exists")

    local inputSource = getScriptSource(starterPlayerScripts, "InputController", "LocalScript")
    expectSourceContains(inputSource, "local function isAcceptInput()", "InputController defines AcceptInput gate")
    expectSourceContains(inputSource, "rg:GetAttribute(\"SongActive\") == true and rg:GetAttribute(\"AcceptInput\") == true", "InputController gates lane fire on SongActive and AcceptInput")
    expectSourceContains(inputSource, "ContextActionService:BindActionAtPriority", "InputController binds arrow keys through ContextActionService")
    expectSourceContains(inputSource, "UserInputService.InputBegan:Connect", "InputController keeps keyboard fallback path")
    expectSourceContains(inputSource, "button.Activated:Connect(function()", "InputController keeps touch/mobile button activation path")
    expectSourceContains(inputSource, "fireLane(lane, \"Mobile\"", "InputController mobile buttons fire lane payloads")
    expectSourceContains(inputSource, "laneInput.Event:Connect(function(payload, legacySource)", "InputController bridges shared LaneInput event")
    expectSourceContains(inputSource, "binder:Fire(payload)", "InputController forwards LaneInput payloads into RhythmClient InputBus")

    local rhythmSource = getScriptSource(starterPlayerScripts, "RhythmClient", "LocalScript")
    expectSourceContains(rhythmSource, "inputBus.Event:Connect(function(payload)", "RhythmClient consumes InputBus lane payloads")
    expectSourceContains(rhythmSource, "screenGui:GetAttribute(\"SongActive\") ~= true or screenGui:GetAttribute(\"AcceptInput\") ~= true", "RhythmClient rejects hits until SongActive and AcceptInput are true")
    expectSourceContains(rhythmSource, "remotes.NoteHit:FireServer({", "RhythmClient sends note hits through NoteHit remote")
    expectSourceContains(rhythmSource, "noteId = targetNote.id", "RhythmClient NoteHit payload includes target note id")
    expectSourceContains(rhythmSource, "lane = payload.lane", "RhythmClient NoteHit payload includes input lane")
    expectSourceContains(rhythmSource, "local inputServerTime = tonumber(payload.time) or serverNow()", "RhythmClient uses captured input timestamp for hit timing")
    expectSourceContains(rhythmSource, "clientSongTime = songTime", "RhythmClient NoteHit payload includes client song time")
    expectSourceContains(rhythmSource, "clientInputServerTime = inputServerTime", "RhythmClient NoteHit payload includes server-synced input time")
    expectSourceContains(rhythmSource, "clientDelta = clientDelta", "RhythmClient NoteHit payload includes client timing delta")
end

local function testRhythmSongStartRemoteAndAudioSourceContract(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping rhythm song/remote/audio source contract (not on server)")
        return
    end
    local starterPlayerScripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    expect(starterPlayerScripts ~= nil, "StarterPlayerScripts exists")
    local rhythmSource = getScriptSource(starterPlayerScripts, "RhythmClient", "LocalScript")

    expectSourceContains(rhythmSource, "remotes.StartSong.OnClientEvent:Connect(function(payload)", "RhythmClient handles SongStart payload")
    expectSourceContains(rhythmSource, "state.active = true", "SongStart marks client state active")
    expectSourceContains(rhythmSource, "state.sessionId = payload.sessionId", "SongStart stores session id")
    expectSourceContains(rhythmSource, "state.song = payload.song", "SongStart stores playable song")
    expectSourceContains(rhythmSource, "screenGui:SetAttribute(\"SongActive\", true)", "SongStart exposes SongActive for input controller")
    expectSourceContains(rhythmSource, "screenGui:SetAttribute(\"AcceptInput\", false)", "SongStart starts with input disabled during countdown")
    expectSourceContains(rhythmSource, "screenGui:SetAttribute(\"AcceptInput\", true)", "SongStart enables input after countdown")

    expectSourceContains(rhythmSource, "songSound.Name = \"SongAudioPipe\"", "RhythmClient owns deterministic song audio pipe")
    expectSourceContains(rhythmSource, "groanSoundFolder.Name = \"GroanHitPipe\"", "RhythmClient owns deterministic groan hit pipe")
    expectSourceContains(rhythmSource, "local function playGroanPayload(payload)", "RhythmClient defines note groan playback helper")
    expectSourceContains(rhythmSource, "payload.groan", "RhythmClient reads groan payload from NoteJudged")
    expectSourceContains(rhythmSource, "assetId ~= \"rbxassetid://0\"", "RhythmClient rejects placeholder groan audio ids")
    expectSourceContains(rhythmSource, "local function stopSongAudio()", "RhythmClient defines song audio stop helper")
    expectSourceContains(rhythmSource, "songSound:Stop()", "stopSongAudio stops playback")
    expectSourceContains(rhythmSource, "songSound.SoundId = \"\"", "stopSongAudio clears loaded audio asset")
    expectSourceContains(rhythmSource, "stopSongAudio()\n    songSound.Volume = baseSongVolume", "playSongAudio resets previous audio and restores base volume")
    expectSourceContains(rhythmSource, "baseSongVolume * duck", "miss glitch ducks song audio without muting to zero")
    expectSourceContains(rhythmSource, "restoreSessionId", "miss glitch restores only the active song session")
    expectSourceContains(rhythmSource, "songSound.Volume = baseSongVolume", "successful judgement and miss-glitch recovery restore song audio volume")
    expectSourceContains(rhythmSource, "remotes.SongFinished.OnClientEvent:Connect(function(payload)", "RhythmClient handles song finish")
    expectSourceContains(rhythmSource, "screenGui:SetAttribute(\"SongActive\", false)", "SongFinished clears SongActive")
    expectSourceContains(rhythmSource, "stopSongAudio()", "SongFinished stops song audio")
    expectSourceContains(rhythmSource, "formatRoomUnlockSummary", "RhythmClient formats room unlocks on results screen")
    expectSourceContains(rhythmSource, "RoomUnlocks", "RhythmClient reads room unlock payloads")
    expectSourceContains(rhythmSource, "GroanTokens", "RhythmClient displays GroanToken room rewards")
    expectSourceContains(rhythmSource, "helperAffinityGains", "RhythmClient displays helper affinity gains")
    expectSourceContains(rhythmSource, "newSkins", "RhythmClient displays room skin unlocks")
    expectSourceContains(rhythmSource, "newBoosts", "RhythmClient displays room boost unlocks")

    local serverScriptService = game:GetService("ServerScriptService")
    local services = serverScriptService:FindFirstChild("Services")
    expect(services ~= nil, "Services folder exists")
    local gameBootstrap = services and services:FindFirstChild("GameBootstrap")
    local bootstrapSource = getScriptSource(services, "GameBootstrap", "Script")
    expect(gameBootstrap ~= nil, "GameBootstrap script exists")
    expectSourceContains(bootstrapSource, "context.Remotes.NoteHit.OnServerEvent:Connect", "GameBootstrap wires NoteHit remote")
    expectSourceContains(bootstrapSource, "CheckRate(player, \"noteHit\"", "NoteHit remote applies anti-spam rate check")
    expectSourceContains(bootstrapSource, "SongSessionService:NoteHit(player, payload or {})", "NoteHit remote reaches SongSessionService")

    local sessionSource = getScriptSource(services, "SongSessionService", "ModuleScript")
    expectSourceContains(sessionSource, "function SongSessionService:_buildGroanPayload(note, judgement)", "SongSessionService builds groan payloads for judged hits")
    expectSourceContains(sessionSource, "groan = self:_buildGroanPayload(note, judgement)", "SongSessionService sends groan payload on NoteJudged")
    expectSourceContains(sessionSource, "for key, value in pairs(note) do", "SongSessionService preserves chart note metadata")
    expectSourceContains(sessionSource, "self.context.Remotes.StartSong:FireClient(player", "SongSessionService sends StartSong to client")
    expectSourceContains(sessionSource, "self.context.Remotes.NoteJudged:FireClient(player", "SongSessionService sends NoteJudged after NoteHit")
    expectSourceContains(sessionSource, "self.context.Remotes.SongFinished:FireClient(player", "SongSessionService sends SongFinished for cleanup")
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

local function testHordeClientMovementSource(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping HordeClient source test (not on server)")
        return
    end
    local StarterPlayer = game:GetService("StarterPlayer")
    local scripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
    local hordeClient = scripts and scripts:FindFirstChild("HordeClient")
    expect(hordeClient ~= nil and hordeClient:IsA("LocalScript"), "HordeClient LocalScript exists")
    local source = hordeClient and hordeClient.Source or ""
    expect(source:find("local function colorForCue", 1, true) ~= nil, "HordeClient defines colorForCue before HordeUpdate uses it")
    expect(source:find("colorForCue(payload.movementCue or payload.lastJudgement)", 1, true) ~= nil, "HordeClient prefers movement cue color over action label")
    expect(source:find("payload.lastJudgement or payload.movementCue", 1, true) == nil, "HordeClient never prefers action labels over movement cues")
    expect(source:find("payload.helperEvent", 1, true) ~= nil, "HordeClient displays helper NPC horde events")
    expect(source:find("payload.roomMechanicEvent", 1, true) ~= nil, "HordeClient displays room mechanic events")
    expect(source:find("ROOM_HAZARD_CUES", 1, true) ~= nil, "HordeClient recognizes room-specific hazard cues")
    expect(source:find("ROOM_SUPPORT_CUES", 1, true) ~= nil, "HordeClient recognizes room-specific helper cues")
    expect(source:find("HeatOverload", 1, true) ~= nil, "HordeClient recognizes Doomscroll overload hazard cue")
    expect(source:find("FirewallFreeze", 1, true) ~= nil, "HordeClient recognizes Doomscroll firewall support cue")
    expect(source:find("CacheRecovery", 1, true) ~= nil, "HordeClient recognizes Doomscroll cache support cue")
    expect(source:find("AudienceHeatPushback", 1, true) ~= nil, "HordeClient recognizes helper-driven pushback waves")
    expect(source:find("renderNpcAction", 1, true) ~= nil, "HordeClient renders explicit NPC action waves")
    expect(source:find("payload.npcAction", 1, true) ~= nil, "HordeClient consumes authoritative NPC action payloads")
    expect(source:find("HordeActionShockwave", 1, true) ~= nil, "HordeClient creates action shockwave markers")
    expect(source:find("HordeHelperBeam", 1, true) ~= nil, "HordeClient creates helper beam pushback markers")
    expect(source:find("HordeActionTelegraphRing", 1, true) ~= nil, "HordeClient creates windup telegraph rings")
    expect(source:find("actionNumber(action, \"windupSeconds\"", 1, true) ~= nil, "HordeClient consumes NPC action windup timing")
    expect(source:find("actionInteger(action, \"laneCount\"", 1, true) ~= nil, "HordeClient consumes NPC action lane counts")
    expect(source:find("npcAction.pushbackStuds", 1, true) ~= nil, "HordeClient applies helper pushback distance")
    expect(source:find("npcAction.knockbackStuds", 1, true) ~= nil, "HordeClient applies hazard knockback distance")
    expect(source:find("LastNpcActionPathStyle", 1, true) ~= nil, "HordeClient records rendered NPC path style")
    expect(source:find("tweenCluster(cluster, distance, sectorId, payload)", 1, true) ~= nil, "HordeClient HordeUpdate calls tweenCluster")
    expect(source:find("RunService.Heartbeat:Connect", 1, true) ~= nil, "HordeClient has idle horde motion heartbeat")
end

local function testHordeServiceMovementPayloadSource(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping HordeService source test (not on server)")
        return
    end
    local ServerScriptService = game:GetService("ServerScriptService")
    local services = ServerScriptService:FindFirstChild("Services")
    local hordeService = services and services:FindFirstChild("HordeService")
    expect(hordeService ~= nil and hordeService:IsA("ModuleScript"), "HordeService ModuleScript exists")
    local source = hordeService and hordeService.Source or ""
    expect(source:find("activeSectorPressure", 1, true) ~= nil, "HordeService payload includes activeSectorPressure")
    expect(source:find("audienceAssist = horde.audienceAssist", 1, true) ~= nil, "HordeService payload includes audience assist feedback")
    expect(source:find("focusReduction", 1, true) ~= nil, "HordeService applies Focus recovery to miss horde surge")
    expect(source:find("movementCue = horde.movementCue", 1, true) ~= nil, "HordeService payload preserves movementCue table")
    expect(source:find("roomMechanicEvent = horde.roomMechanicEvent", 1, true) ~= nil, "HordeService payload includes room mechanic events")
    expect(source:find("roomHazard = horde.roomHazard", 1, true) ~= nil, "HordeService payload includes room hazards")
    expect(source:find("npcAction = horde.npcAction", 1, true) ~= nil, "HordeService payload includes explicit NPC action data")
    expect(source:find("function HordeService:_setNpcAction", 1, true) ~= nil, "HordeService centralizes NPC action events")
    expect(source:find("actionKindForCue", 1, true) ~= nil, "HordeService classifies NPC action cues")
    expect(source:find("actionChoreography", 1, true) ~= nil, "HordeService builds explicit NPC action choreography")
    expect(source:find("attackId = string.format", 1, true) ~= nil, "HordeService tags NPC actions with stable attack ids")
    expect(source:find("laneCount = choreography.laneCount", 1, true) ~= nil, "HordeService NPC actions include lane counts")
    expect(source:find("windupSeconds = choreography.windupSeconds", 1, true) ~= nil, "HordeService NPC actions include windup timing")
    expect(source:find("impactSeconds = choreography.impactSeconds", 1, true) ~= nil, "HordeService NPC actions include impact timing")
    expect(source:find("pushbackStuds = choreography.pushbackStuds", 1, true) ~= nil, "HordeService NPC actions include helper pushback")
    expect(source:find("knockbackStuds = choreography.knockbackStuds", 1, true) ~= nil, "HordeService NPC actions include hazard knockback")
    expect(source:find("npcActionEventId = npcAction and npcAction.eventId", 1, true) ~= nil, "HordeService movement cue links to NPC action event")
    expect(source:find("ROOM_MECHANICS", 1, true) ~= nil, "HordeService owns room-specific mechanic table")
    expect(source:find("GlitchSurge", 1, true) ~= nil, "HordeService defines Cyber Arcade hazard")
    expect(source:find("BubbleShieldPulse", 1, true) ~= nil, "HordeService defines Aquarium helper cue")
    expect(source:find("HeatOverload", 1, true) ~= nil, "HordeService defines Doomscroll Data Center hazard")
    expect(source:find("FirewallFreeze", 1, true) ~= nil, "HordeService defines Doomscroll FirewallAdmin helper cue")
    expect(source:find("CacheRecovery", 1, true) ~= nil, "HordeService defines Doomscroll CacheMedic helper cue")
    expect(source:find("scoreSectorTarget", 1, true) ~= nil, "HordeService scores horde sector targets instead of pure round-robin movement")
    expect(source:find("targetReason = horde.lastTargeting", 1, true) ~= nil, "HordeService payload exposes horde targeting reason")
    expect(source:find("horde.movementCue = lastJudgement", 1, true) == nil, "HordeService broadcast does not overwrite movementCue table")
end

local function testScoreServiceFocusRecoveryBehavior(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping ScoreService focus behavior test (not on server)")
        return
    end
    local ScoreService = requireServerServiceClone("ScoreService")
    local profile = { Level = 1, Upgrades = { Recovery = 0, Focus = 0 } }
    local baseSession = {
        difficultyConfig = { hpDamageMiss = 10 },
        mode = Config.Modes.Career,
        stateData = { hp = 80 },
        modifiers = {},
    }
    local focusedHighHp = {
        difficultyConfig = { hpDamageMiss = 10 },
        mode = Config.Modes.Career,
        stateData = { hp = 80 },
        modifiers = { focusReduction = 3 },
    }
    local focusedLowHp = {
        difficultyConfig = { hpDamageMiss = 10 },
        mode = Config.Modes.Career,
        stateData = { hp = 40 },
        modifiers = { focusReduction = 5 },
    }
    expectEqual(ScoreService:GetMissDamage(profile, baseSession), 10, "baseline miss damage")
    expectEqual(ScoreService:GetMissDamage(profile, focusedHighHp), 9, "Focus reduces high-hp miss damage within cap")
    expectEqual(ScoreService:GetMissDamage(profile, focusedLowHp), 8, "Focus gives stronger low-hp miss damage recovery")
    expectEqual(ScoreService:GetMissPenalty(profile, focusedLowHp), 4, "Focus softens low-hp hype penalty")
end

local function testHordeAudienceAssistBehavior(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping HordeService audience assist behavior test (not on server)")
        return
    end
    local HordeService = requireServerServiceClone("HordeService")
    local fired = {}
    local fakeRemote = {
        FireAllClients = function(_, payload)
            table.insert(fired, payload)
        end,
    }
    HordeService:Init({
        Remotes = { HordeUpdate = fakeRemote },
        Services = {},
    })
    local session = {
        id = "UnitHordeAssist",
        playerId = 123,
        difficulty = "Easy",
        difficultyConfig = { hordeMissAdvance = 10, hpDamageMiss = 10 },
        stateData = { hp = 40 },
        modifiers = { focusReduction = 5 },
    }
    HordeService:StartSession(session)
    local horde = HordeService.sessions[session.id]
    horde.distance = 50
    horde.warningSectorId = "N"
    horde.sectorHealths.N = 40
    horde.sectorPressure.N = 80

    HordeService:ApplyAudienceSupport(session, 4, "Support")
    local supportPayload = fired[#fired]
    expect(type(supportPayload.audienceAssist) == "table", "Support emits audienceAssist payload")
    expectEqual(supportPayload.audienceAssist.sectorId, "N", "Support repairs pre-existing warning sector")
    expect(horde.sectorHealths.N > 40, "Support increases weak sector health")
    expect(horde.sectorPressure.N < 80, "Support lowers weak sector pressure")

    HordeService:ApplyJudgement(session, "Perfect")
    local nextPayload = fired[#fired]
    expect(nextPayload.audienceAssist == nil, "regular judgement clears one-shot audienceAssist payload")

    horde.distance = 50
    HordeService:ApplyJudgement(session, "Miss")
    expectEqual(horde.distance, 42, "Focus reduces horde miss surge from 10 to 8")
end

local function testHordeHelperNpcBehavior(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping HordeService helper NPC behavior test (not on server)")
        return
    end
    local HordeService = requireServerServiceClone("HordeService")
    local fired = {}
    local fakeRemote = {
        FireAllClients = function(_, payload)
            table.insert(fired, payload)
        end,
    }
    HordeService:Init({
        Remotes = { HordeUpdate = fakeRemote },
        Services = {},
    })
    local session = {
        id = "UnitHordeHelpers",
        playerId = 456,
        difficulty = "Easy",
        difficultyConfig = { hordeMissAdvance = 10, hpDamageMiss = 10 },
        stateData = { hp = 80, hype = 70 },
        modifiers = {},
        roomBoosts = { "HordePushback", "AudienceHeat" },
        roomHelperNPCs = {
            { Id = "SecurityManager" },
            { Id = "AudienceHypeManager" },
            { Id = "DJ_GroanMaster" },
        },
    }
    HordeService:StartSession(session)
    local horde = HordeService.sessions[session.id]
    horde.warningSectorId = "N"
    horde.sectorHealths.N = 42
    horde.sectorPressure.N = 82

    HordeService:ApplyJudgement(session, "Perfect")
    local helperPayload = fired[#fired]
    expect(type(helperPayload.helperEvent) == "table", "helper NPC emits helperEvent payload")
    expectEqual(helperPayload.helperEvent.id, "SecurityManager", "SecurityManager repairs the weak sector first")
    expectEqual(helperPayload.helperEvent.sectorId, "N", "SecurityManager targets the warning sector")
    expect(horde.sectorHealths.N > 42, "SecurityManager repair increases weak sector health")
    expect(horde.sectorPressure.N < 82, "SecurityManager repair lowers weak sector pressure")
end

local function testHordeRoomSpecificMechanics(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping HordeService room-specific mechanics test (not on server)")
        return
    end
    local HordeService = requireServerServiceClone("HordeService")
    local fired = {}
    local fakeRemote = {
        FireAllClients = function(_, payload)
            table.insert(fired, payload)
        end,
    }
    HordeService:Init({
        Remotes = { HordeUpdate = fakeRemote },
        Services = {},
    })

    local hazardSession = {
        id = "UnitCyberHazard",
        playerId = 789,
        roomId = "cyber_arcade_overclock",
        roomName = "Cyber Arcade Overclock",
        difficulty = "Hard",
        difficultyConfig = { hordeMissAdvance = 10, hpDamageMiss = 10 },
        stateData = { hp = 80, hype = 40 },
        modifiers = {},
        roomBoosts = {},
        roomHelperNPCs = {},
    }
    HordeService:StartSession(hazardSession)
    local hazardHorde = HordeService.sessions[hazardSession.id]
    hazardHorde.sectorPressure.E = 88
    hazardHorde.sectorHealths.E = 78
    HordeService:ApplyJudgement(hazardSession, "Miss")
    local hazardPayload = fired[#fired]
    expect(type(hazardPayload.roomHazard) == "table", "Cyber Arcade miss emits a room hazard")
    expectEqual(hazardPayload.roomHazard.type, "GlitchSurge", "Cyber Arcade uses GlitchSurge hazard")
    expectEqual(hazardPayload.roomMechanicEvent.type, "GlitchSurge", "Cyber Arcade hazard emits roomMechanicEvent")
    expect(type(hazardPayload.npcAction) == "table", "Cyber Arcade hazard emits explicit NPC action")
    expectEqual(hazardPayload.npcAction.kind, "hazard", "Cyber Arcade hazard NPC action is classified as hazard")
    expectEqual(hazardPayload.npcAction.type, "GlitchSurge", "Cyber Arcade hazard NPC action carries cue type")
    expectEqual(hazardPayload.npcAction.sectorId, "E", "Cyber Arcade hazard NPC action targets hot sector")
    expect(tostring(hazardPayload.npcAction.attackId):find("GlitchSurge", 1, true) ~= nil, "Cyber Arcade hazard NPC action has cue-scoped attack id")
    expectEqual(hazardPayload.npcAction.pathStyle, "horde_lunge", "Cyber Arcade hazard uses lunge choreography")
    expect((hazardPayload.npcAction.laneCount or 0) >= 2, "Cyber Arcade hazard broadcasts multiple attack lanes")
    expect((hazardPayload.npcAction.windupSeconds or 0) > 0, "Cyber Arcade hazard broadcasts windup timing")
    expect((hazardPayload.npcAction.impactSeconds or 0) > 0, "Cyber Arcade hazard broadcasts impact timing")
    expect((hazardPayload.npcAction.knockbackStuds or 0) > 0, "Cyber Arcade hazard broadcasts knockback distance")
    expectEqual(hazardPayload.movementCue.npcActionEventId, hazardPayload.npcAction.eventId, "movement cue links to hazard NPC action")
    expectEqual(hazardPayload.activeSectorId, "E", "Cyber Arcade miss targets the hot pressure sector instead of round-robin")
    expect(type(hazardPayload.targeting) == "table", "Cyber Arcade miss emits targeting metadata")
    expect(tostring(hazardPayload.targetReason):find("pressure", 1, true) ~= nil, "Cyber Arcade target reason records pressure intent")
    expectEqual(hazardPayload.roomHazard.sectorId, "E", "Cyber Arcade room hazard uses the targeted sector")

    local helperSession = {
        id = "UnitCyberHelper",
        playerId = 790,
        roomId = "cyber_arcade_overclock",
        roomName = "Cyber Arcade Overclock",
        difficulty = "Hard",
        difficultyConfig = { hordeMissAdvance = 10, hpDamageMiss = 10 },
        stateData = { hp = 80, hype = 40 },
        modifiers = {},
        roomBoosts = { "ComboCache" },
        roomHelperNPCs = {
            { Id = "PatchBot" },
            { Id = "ArcadeTech" },
        },
    }
    HordeService:StartSession(helperSession)
    local horde = HordeService.sessions[helperSession.id]
    horde.warningSectorId = "N"
    horde.sectorHealths.N = 62
    horde.sectorPressure.N = 70

    HordeService:ApplyJudgement(helperSession, "Good")
    local helperPayload = fired[#fired]
    expect(type(helperPayload.helperEvent) == "table", "room helper emits helperEvent")
    expectEqual(helperPayload.helperEvent.id, "PatchBot", "PatchBot responds to a weak Cyber Arcade sector")
    expectEqual(helperPayload.roomMechanicEvent.type, "PatchBotStabilize", "PatchBot emits room-specific cue")
    expect(type(helperPayload.npcAction) == "table", "room helper emits explicit NPC action")
    expectEqual(helperPayload.npcAction.kind, "support", "room helper NPC action is classified as support")
    expectEqual(helperPayload.npcAction.actorId, "PatchBot", "room helper NPC action records helper actor")
    expectEqual(helperPayload.npcAction.type, "PatchBotStabilize", "room helper NPC action carries helper cue type")
    expectEqual(helperPayload.npcAction.pathStyle, "helper_pushback", "room helper NPC action uses pushback choreography")
    expect((helperPayload.npcAction.pushbackStuds or 0) > 0, "room helper NPC action broadcasts pushback distance")
    expect((helperPayload.npcAction.toDistance or 0) > (helperPayload.npcAction.fromDistance or 0), "room helper NPC action pushes outward")
    expect((helperPayload.npcAction.laneCount or 0) >= 1, "room helper NPC action broadcasts helper lane count")
    expectEqual(helperPayload.movementCue.npcActionEventId, helperPayload.npcAction.eventId, "movement cue links to helper NPC action")
    expect(horde.sectorHealths.N > 62, "PatchBot repairs weak Cyber Arcade sector health")
    expect(horde.sectorPressure.N < 70, "PatchBot lowers weak Cyber Arcade sector pressure")

    local doomHazardSession = {
        id = "UnitDoomscrollHazard",
        playerId = 791,
        roomId = "doomscroll_data_center",
        roomName = "Doomscroll Data Center",
        difficulty = "Extreme",
        difficultyConfig = { hordeMissAdvance = 10, hpDamageMiss = 10 },
        stateData = { hp = 78, hype = 35 },
        modifiers = {},
        roomBoosts = {},
        roomHelperNPCs = {},
    }
    HordeService:StartSession(doomHazardSession)
    local doomHazard = HordeService.sessions[doomHazardSession.id]
    doomHazard.sectorPressure.E = 86
    doomHazard.sectorHealths.E = 74
    HordeService:ApplyJudgement(doomHazardSession, "Miss")
    local doomHazardPayload = fired[#fired]
    expect(type(doomHazardPayload.roomHazard) == "table", "Doomscroll miss emits a room hazard")
    expectEqual(doomHazardPayload.roomHazard.type, "HeatOverload", "Doomscroll uses HeatOverload hazard")
    expectEqual(doomHazardPayload.roomHazard.sectorId, "E", "Doomscroll hazard targets hot rack sector")
    expect(type(doomHazardPayload.npcAction) == "table", "Doomscroll hazard emits explicit NPC action")
    expectEqual(doomHazardPayload.npcAction.kind, "hazard", "Doomscroll hazard NPC action is classified as hazard")
    expectEqual(doomHazardPayload.npcAction.type, "HeatOverload", "Doomscroll hazard NPC action carries cue type")
    expect((doomHazardPayload.npcAction.laneCount or 0) >= 2, "Doomscroll hazard broadcasts multiple overload lanes")
    expect((doomHazardPayload.npcAction.knockbackStuds or 0) > 0, "Doomscroll hazard broadcasts knockback distance")

    local doomHelperSession = {
        id = "UnitDoomscrollHelper",
        playerId = 792,
        roomId = "doomscroll_data_center",
        roomName = "Doomscroll Data Center",
        difficulty = "Extreme",
        difficultyConfig = { hordeMissAdvance = 10, hpDamageMiss = 10 },
        stateData = { hp = 82, hype = 42 },
        modifiers = {},
        roomBoosts = { "FirewallFreeze", "CooldownCache" },
        roomHelperNPCs = {
            { Id = "FirewallAdmin" },
            { Id = "CacheMedic" },
        },
    }
    HordeService:StartSession(doomHelperSession)
    local doomHelper = HordeService.sessions[doomHelperSession.id]
    doomHelper.warningSectorId = "W"
    doomHelper.sectorHealths.W = 60
    doomHelper.sectorPressure.W = 72

    HordeService:ApplyJudgement(doomHelperSession, "Good")
    local doomHelperPayload = fired[#fired]
    expect(type(doomHelperPayload.helperEvent) == "table", "Doomscroll helper emits helperEvent")
    expectEqual(doomHelperPayload.helperEvent.id, "FirewallAdmin", "FirewallAdmin responds to overloaded rack pressure")
    expectEqual(doomHelperPayload.roomMechanicEvent.type, "FirewallFreeze", "FirewallAdmin emits room-specific support cue")
    expect(type(doomHelperPayload.npcAction) == "table", "Doomscroll helper emits explicit NPC action")
    expectEqual(doomHelperPayload.npcAction.kind, "support", "Doomscroll helper NPC action is classified as support")
    expectEqual(doomHelperPayload.npcAction.actorId, "FirewallAdmin", "Doomscroll helper NPC action records helper actor")
    expectEqual(doomHelperPayload.npcAction.type, "FirewallFreeze", "Doomscroll helper NPC action carries helper cue type")
    expect((doomHelperPayload.npcAction.pushbackStuds or 0) > 0, "Doomscroll helper broadcasts pushback distance")
    expect(doomHelper.sectorHealths.W > 60, "FirewallAdmin repairs overloaded Doomscroll rack sector")
    expect(doomHelper.sectorPressure.W < 72, "FirewallAdmin lowers overloaded Doomscroll rack pressure")
end

local function testCreatorMenuExpansionBuilderSource(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping Creator menu expansion builder source test (not on server)")
        return
    end
    local ServerScriptService = game:GetService("ServerScriptService")
    local services = ServerScriptService:FindFirstChild("Services")
    local builderScript = services and services:FindFirstChild("WorldV2Builder")
    expect(builderScript ~= nil and builderScript:IsA("ModuleScript"), "WorldV2Builder ModuleScript exists")
    local source = builderScript and builderScript.Source or ""
    expect(source:find("buildCreatorMenuExpansionPlacements", 1, true) ~= nil, "builder creates Creator menu expansion placements")
    expect(source:find("Clean_Creator_CS_StageTruss", 1, true) ~= nil, "builder uses audited Creator StageTruss source")
    expect(source:find("Clean_FanNPCCreatorLocalPack", 1, true) ~= nil, "builder replaces blocked Creator NPC source with safe local fan pack")
    expect(source:find("CreatorMenuExpansionPlacements", 1, true) ~= nil, "builder records Creator expansion placement count")
    expect(source:find("not 1,000 distinct source asset IDs", 1, true) ~= nil, "builder documents placement-vs-source-ID boundary")
end

local function testRoomConfigThemedMultiplayerRooms(): ()
    local rooms = RoomConfig.GetRooms()
    expect(#rooms >= 10, "RoomConfig defines a bunch of themed rooms")
    local defaultRoom = RoomConfig.GetDefaultRoom()
    expect(defaultRoom.Id == "brainrot_volcano_horde_rave", "Room 1 is Brainrot Volcano Horde Rave")
    expect(defaultRoom.Index == 1, "Brainrot Volcano Horde Rave is room 1")
    expect(defaultRoom.Capacity >= 4, "Room 1 supports multiplayer capacity")
    expect((defaultRoom.MinPlayers or 0) >= 1, "Room 1 declares min players")
    expect((defaultRoom.FillSeconds or 0) > 0, "Room 1 declares queue fill seconds")
    expect(type(defaultRoom.TeamMode) == "string" and defaultRoom.TeamMode ~= "", "Room 1 declares team mode")
    expect(typeof(RoomConfig.GetLaunchCFrame(1)) == "CFrame", "RoomConfig exposes launch CFrames")
    expect(typeof(RoomConfig.GetReturnCFrame(1)) == "CFrame", "RoomConfig exposes return CFrames")
    expect(RoomConfig.IsDifficultyAllowed(defaultRoom, "Brainrot"), "Room 1 supports Brainrot difficulty")
    expect((defaultRoom.RewardMultiplier or 1) > 1, "Room 1 has room reward multiplier")
    expect(type(defaultRoom.HelperNPCs) == "table" and #defaultRoom.HelperNPCs >= 3, "Room 1 has helper NPC roles")
    expect(type(defaultRoom.AssetSearchSlots) == "table" and #defaultRoom.AssetSearchSlots >= 4, "Room 1 keeps asset-search slots")

    local defaultSpace = RoomConfig.GetRoomSpace(defaultRoom.Id)
    expect(typeof(defaultSpace.Center) == "Vector3", "Room 1 has a playable room space center")
    expect(typeof(defaultSpace.Entry) == "Vector3", "Room 1 has a player-entry review point")

    local cyberSpace = RoomConfig.GetRoomSpace("cyber_arcade_overclock")
    expect(typeof(cyberSpace.Center) == "Vector3", "Cyber Arcade has a playable room space center")
    expect((cyberSpace.Center - defaultSpace.Center).Magnitude > 60, "later rooms occupy separate multiplayer spaces")
    local doomscrollRoom = RoomConfig.GetRoom("doomscroll_data_center")
    expect(doomscrollRoom.Id == "doomscroll_data_center", "Doomscroll Data Center is promoted into the active room slate")
    local doomscrollSpace = RoomConfig.GetRoomSpace("doomscroll_data_center")
    expect(typeof(doomscrollSpace.Center) == "Vector3", "Doomscroll Data Center has a source room space for screenshots")
    expect((doomscrollSpace.Center - defaultSpace.Center).Magnitude > 60, "Doomscroll Data Center no longer falls back to Room 1 space")
    local volcanoLaunch = RoomConfig.GetLaunchCFrame(defaultRoom.Id, 1)
    local cyberLaunch = RoomConfig.GetLaunchCFrame("cyber_arcade_overclock", 1)
    local doomscrollLaunch = RoomConfig.GetLaunchCFrame("doomscroll_data_center", 1)
    expect(typeof(cyberLaunch) == "CFrame", "room-specific launch CFrames are available")
    expect((cyberLaunch.Position - volcanoLaunch.Position).Magnitude > 60, "room sessions launch into their own room space")
    expect((doomscrollLaunch.Position - volcanoLaunch.Position).Magnitude > 60, "Doomscroll sessions launch into their own room space")

    local hasHighDifficultyRoom = false
    local hasSixPlayerRoom = false
    for _, room in ipairs(rooms) do
        expect(type(room.SkinUnlocks) == "table" and #room.SkinUnlocks > 0, "room has skin unlocks: " .. tostring(room.Id))
        expect(type(room.Boosts) == "table" and #room.Boosts > 0, "room has boosts: " .. tostring(room.Id))
        expect(type(room.HelperNPCs) == "table" and #room.HelperNPCs > 0, "room has helper NPCs: " .. tostring(room.Id))
        expect((room.MinPlayers or 0) >= 1, "room declares min players: " .. tostring(room.Id))
        expect((room.FillSeconds or 0) > 0, "room declares fill timer: " .. tostring(room.Id))
        expect(type(room.TeamMode) == "string" and room.TeamMode ~= "", "room declares team mode: " .. tostring(room.Id))
        expect(type(room.ReviewSpaceId) == "string" and room.ReviewSpaceId ~= "", "room has visual review space id: " .. tostring(room.Id))
        if RoomConfig.IsDifficultyAllowed(room, "Brainrot") then hasHighDifficultyRoom = true end
        if (room.Capacity or 0) >= 6 then hasSixPlayerRoom = true end
    end
    expect(hasHighDifficultyRoom, "at least one themed room supports Brainrot difficulty")
    expect(hasSixPlayerRoom, "later rooms support larger multiplayer capacity")
    expect(#RoomConfig.GetAssetSearchSlots() >= #rooms * 4, "room asset-search slot list is broad enough for deep curation")
    local reviewSpaces = RoomConfig.GetReviewSpaces()
    expect(#reviewSpaces >= #rooms, "room review spaces are available for screenshot planning")
    expect(typeof(reviewSpaces[1].center) == "Vector3", "room review spaces include player-angle center coordinates")
end

local function testEconomyRoomProgressRewards(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping EconomyService room progress rewards test (not on server)")
        return
    end

    local EconomyService = requireServerServiceClone("EconomyService")
    local profile = Config.DeepCopy(Config.DefaultProfile)
    local player = {
        UserId = 43210,
        Name = "RoomRewardUnit",
    }
    local missionEvents = {}
    local savedCount = 0

    EconomyService:Init({
        Services = {
            DataService = {
                GetProfile = function(_service, requestedPlayer)
                    expect(requestedPlayer == player, "EconomyService requests the active player profile")
                    return profile
                end,
                SavePlayer = function(_service, requestedPlayer)
                    expect(requestedPlayer == player, "EconomyService saves the active player profile")
                    savedCount += 1
                end,
                UpdateProfile = function(_service, requestedPlayer, callback)
                    expect(requestedPlayer == player, "EconomyService updates the active player profile")
                    if callback then
                        callback(profile)
                    end
                end,
                GetSnapshot = function(_service, requestedPlayer)
                    expect(requestedPlayer == player, "EconomyService snapshots the active player profile")
                    return profile
                end,
            },
            MissionService = {
                RecordEvent = function(_service, _profile, eventName, amount, _options)
                    table.insert(missionEvents, {
                        eventName = eventName,
                        amount = amount,
                    })
                    return {}
                end,
            },
            VenueService = {
                GetRewardModifiers = function(_service, _venueId)
                    return nil, { fans = 1, tickets = 0 }
                end,
                GetFeeMultiplier = function(_service, _venueId, _profile)
                    return 0
                end,
            },
            TourBusService = {
                ApplyRewardModifiers = function(_service, _profile, rewards)
                    return rewards
                end,
            },
        },
        Remotes = {
            DataSnapshot = {
                FireClient = function(_remote, requestedPlayer, snapshot)
                    expect(requestedPlayer == player, "EconomyService fires snapshot to the active player")
                    expect(snapshot == profile, "EconomyService sends the updated profile snapshot")
                end,
            },
        },
    })

    local rewards = EconomyService:FinalizeSong(player, {
        id = "RoomRewardSession",
        songId = "UnitSong",
        roomId = "cyber_arcade_overclock",
        roomName = "Cyber Arcade Overclock",
        roomSessionId = "RoomSession_Cyber_1",
        roomTeamMode = "ComboCrew",
        roomTeamName = "Cyber Crew",
        roomCrewKey = "cyber_arcade_overclock:crew:RoomSession_Cyber_1",
        roomCrewLaunchId = "CrewLaunch_Cyber_1",
        roomParticipantCount = 3,
        roomRewardMultiplier = 1.28,
        roomRewardBonuses = { Fans = 14, Coins = 12, XP = 18, Tickets = 0 },
        roomSkinUnlocks = { "Pixel Visor", "Arcade Arrow Skin", "CRT Speaker Stack" },
        roomBoosts = { "ComboCache", "LanePreview", "CoinJackpot" },
        roomHelperNPCs = {
            { Id = "PatchBot" },
            { Id = "ArcadeTech" },
        },
        difficulty = "Hard",
        difficultyConfig = { rewardMultiplier = 1.5 },
        segmentLength = "30s",
        segmentSection = "Intro",
        mode = Config.Modes.Career,
        venueId = "SchoolStage",
        song = { Id = "UnitSong" },
    }, {
        score = 5000,
        grade = "A",
        hype = 70,
        maxCombo = 25,
        accuracyPercent = 90,
        miss = 2,
    })

    expect(type(rewards) == "table", "EconomyService returns room rewards")
    expectEqual(rewards.RoomCrewKey, "cyber_arcade_overclock:crew:RoomSession_Cyber_1", "EconomyService returns stable room crew key")
    expectEqual(rewards.RoomParticipantCount, 3, "EconomyService returns room participant count")
    local roomProgress = profile.RoomProgress.cyber_arcade_overclock
    expect(type(roomProgress) == "table", "EconomyService persists room progress")
    expectEqual(roomProgress.ClearCount, 1, "room clear count increments")
    expect(roomProgress.Awards["cyber_arcade_overclock:first_clear"], "first room clear award is stored")
    expect(roomProgress.Awards["cyber_arcade_overclock:difficulty:Hard"], "difficulty room clear award is stored")
    expect(type(roomProgress.Difficulties.Hard) == "table", "difficulty clear record is stored")
    expectEqual(roomProgress.BestGrade, "A", "room best grade is stored")
    expect(roomProgress.Skins["Pixel Visor"], "first room skin is stored")
    expect(roomProgress.Skins["Arcade Arrow Skin"], "A-grade room skin is stored")
    expect(roomProgress.Boosts.ComboCache, "first room boost is stored")
    expect(roomProgress.Boosts.LanePreview, "Hard room boost is stored")
    expect((roomProgress.HelperAffinity.PatchBot or 0) > 0, "PatchBot helper affinity increases")
    expect((roomProgress.HelperAffinity.ArcadeTech or 0) > 0, "ArcadeTech helper affinity increases")
    expectEqual(rewards.RoomUnlocks.firstRoomClear, true, "reward payload reports first room clear")
    expectEqual(rewards.RoomUnlocks.roomName, "Cyber Arcade Overclock", "reward payload reports room name")
    expect(#rewards.RoomUnlocks.helperAffinityGains >= 2, "reward payload reports helper affinity gains")
    expect((rewards.GroanTokens or 0) >= 2, "new room awards grant GroanTokens")
    expectEqual(profile.GroanTokens, rewards.GroanTokens, "GroanTokens persist to profile")
    expect(savedCount == 1, "EconomyService saves the room reward profile once")

    local sawRoomClear = false
    local sawRoomDifficulty = false
    for _, event in ipairs(missionEvents) do
        if event.eventName == "RoomClear_cyber_arcade_overclock" then
            sawRoomClear = true
        elseif event.eventName == "RoomDifficulty_cyber_arcade_overclock_Hard" then
            sawRoomDifficulty = true
        end
    end
    expect(sawRoomClear, "room clear mission event is recorded")
    expect(sawRoomDifficulty, "room difficulty mission event is recorded")
end

local function testRoomServiceSourceContract(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping RoomService source contract (not on server)")
        return
    end
    local ServerScriptService = game:GetService("ServerScriptService")
    local services = ServerScriptService:FindFirstChild("Services")
    local roomService = services and services:FindFirstChild("RoomService")
    expect(roomService ~= nil and roomService:IsA("ModuleScript"), "RoomService ModuleScript exists")
    local source = roomService and roomService.Source or ""
    expectSourceContains(source, "function RoomService:JoinRoom", "RoomService owns server-authoritative joins")
    expectSourceContains(source, "function RoomService:LeaveRoom", "RoomService owns server-authoritative leaves")
    expectSourceContains(source, "function RoomService:DecorateSongPayload", "RoomService decorates song payloads")
    expectSourceContains(source, "function RoomService:PrepareSongPayload", "RoomService gates song start on room readiness")
    expectSourceContains(source, "createdDuringPrepare", "RoomService tracks room sessions created during song preparation")
    expectSourceContains(source, "if createdDuringPrepare then", "RoomService broadcasts active room snapshots after song-start promotion")
    expectSourceContains(source, "function RoomService:_ensureRoomSession", "RoomService creates active room sessions")
    expectSourceContains(source, "function RoomService:FinishPlayerRoomSession", "RoomService finishes room participants")
    expectSourceContains(source, "function RoomService:_applyRoomObjective", "RoomService owns room objective effects")
    expectSourceContains(source, "function RoomService:_recordRoomObjective", "RoomService records session objective progress")
    expectSourceContains(source, "function RoomService:_roomObjectiveSnapshot", "RoomService exposes objective progress snapshots")
    expectSourceContains(source, "objectiveProgress", "RoomService tracks room objective progress")
    expectSourceContains(source, "objectiveMomentum", "RoomService tracks room objective momentum")
    expectSourceContains(source, "objectiveCombo", "RoomService tracks room objective combo chains")
    expectSourceContains(source, "objectiveContributions", "RoomService tracks per-player objective contributions")
    expectSourceContains(source, "objectiveMilestone", "RoomService emits objective milestones")
    expectSourceContains(source, "function RoomService:_bindRoomObjectivePrompt", "RoomService binds room objective prompts separately")
    expectSourceContains(source, "RoomObjectivePrompt", "RoomService recognizes objective prompts")
    expectSourceContains(source, "RoomObjectiveBound", "RoomService prevents duplicate objective prompt binding")
    expectSourceContains(source, "RoomObjectiveCooldown", "RoomService enforces objective cooldown metadata")
    expectSourceContains(source, "not prompt:GetAttribute(\"RoomObjectiveId\")", "RoomService excludes objectives from room queue prompt binding")
    expectSourceContains(source, "hordeService:ApplyAudienceSupport", "RoomService objectives can push horde support")
    expectSourceContains(source, "hordeService:RepairSector", "RoomService objectives can repair horde sectors")
    expectSourceContains(source, "activeRoomSessions", "RoomService tracks active room sessions")
    expectSourceContains(source, "roomSessionId", "RoomService emits shared room session ids")
    expectSourceContains(source, "roomCrewKey", "RoomService emits stable room crew keys")
    expectSourceContains(source, "participants", "RoomService emits participant rosters")
    expectSourceContains(source, "participantUserIds", "RoomService emits participant user-id rosters")
    expectSourceContains(source, "roomParticipantCount", "RoomService decorates song payloads with participant counts")
    expectSourceContains(source, "roomParticipantUserIds", "RoomService decorates song payloads with participant user ids")
    expectSourceContains(source, "RoomUpdate", "RoomService broadcasts room snapshots")
    expectSourceContains(source, "RoomActionResult", "RoomService sends action results")
    expectSourceContains(source, "roomRewardMultiplier", "RoomService passes room reward multiplier into sessions")
    expectSourceContains(source, "assetReadiness = AssetRegistry.GetRoomAssetReadiness(room.Id)", "RoomService includes asset readiness in room snapshots")
    expectSourceContains(source, "function RoomService:_refreshQueueState", "RoomService owns min-player/fill-timer state")
    expectSourceContains(source, "function RoomService:Update", "RoomService advances queue countdowns")
    expectSourceContains(source, "countdownSeconds", "RoomService snapshots countdown seconds")
    expectSourceContains(source, "profileLevel(profile) < (room.MinLevel or 1)", "RoomService enforces level gates server-side")
    expectSourceContains(source, "RoomConfig.GetLaunchCFrame(session.roomId, participant.slot)", "RoomService launches players into room-specific spaces")
    expectSourceContains(source, "RoomConfig.GetReturnCFrame(session.roomId, participant.slot)", "RoomService returns players through room-aware exits")
end

local function testRoomSessionPropagationSourceContract(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping room session propagation source contract (not on server)")
        return
    end
    local ServerScriptService = game:GetService("ServerScriptService")
    local services = ServerScriptService:FindFirstChild("Services")
    expect(services ~= nil, "Services folder exists")

    local sessionSource = getScriptSource(services, "SongSessionService", "ModuleScript")
    expectSourceContains(sessionSource, "RoomService:PrepareSongPayload", "SongSessionService asks RoomService to prepare room payloads")
    expectSourceContains(sessionSource, "function SongSessionService:_startRoomCrewSong", "SongSessionService can launch room crews together")
    expectSourceContains(sessionSource, "sharedStartServerTime", "SongSessionService gives crew members one server countdown")
    expectSourceContains(sessionSource, "roomLaunches", "SongSessionService de-duplicates room crew launches")
    expectSourceContains(sessionSource, "Players:GetPlayerByUserId(participant.userId)", "SongSessionService resolves room participants by user id")
    expectSourceContains(sessionSource, "roomSessionId = payload.roomSessionId", "SongSessionService stores roomSessionId")
    expectSourceContains(sessionSource, "roomCrewKey = payload.roomCrewKey", "SongSessionService stores room crew key")
    expectSourceContains(sessionSource, "roomParticipantCount = payload.roomParticipantCount", "SongSessionService stores room participant count")
    expectSourceContains(sessionSource, "roomParticipantUserIds = payload.roomParticipantUserIds", "SongSessionService stores room participant user ids")
    expectSourceContains(sessionSource, "participant.status = \"playing\"", "SongSessionService marks all crew participants playing before launch fanout")
    expectSourceContains(sessionSource, "memberPayload.roomTeamName = participant.teamName", "SongSessionService preserves per-participant team names during crew launch")
    expectSourceContains(sessionSource, "memberPayload.roomLaunchSlot = participant.slot", "SongSessionService preserves per-participant launch slots during crew launch")
    expectSourceContains(sessionSource, "roomCrewLaunchId = options.roomCrewLaunchId", "SongSessionService stores room crew launch id")
    expectSourceContains(sessionSource, "crewLaunchId = session.roomCrewLaunchId", "SongSessionService sends crew launch id to clients")
    expectSourceContains(sessionSource, "participantUserIds = session.roomParticipantUserIds", "SongSessionService sends participant user-id rosters to clients")
    expectSourceContains(sessionSource, "participants = session.roomParticipants", "SongSessionService sends room participant roster")
    expectSourceContains(sessionSource, "RoomService:FinishPlayerRoomSession", "SongSessionService reports room participant finish")

    local economySource = getScriptSource(services, "EconomyService", "ModuleScript")
    expectSourceContains(economySource, "RoomSessionId = session.roomSessionId", "EconomyService includes RoomSessionId in rewards")
    expectSourceContains(economySource, "RoomCrewKey = session.roomCrewKey", "EconomyService includes RoomCrewKey in rewards")
    expectSourceContains(economySource, "RoomCrewLaunchId = session.roomCrewLaunchId", "EconomyService includes RoomCrewLaunchId in rewards")
    expectSourceContains(economySource, "RoomParticipantCount = session.roomParticipantCount", "EconomyService includes room participant count in rewards")
    expectSourceContains(economySource, "roomSessionId = session.roomSessionId", "EconomyService records RoomSessionId in history")
    expectSourceContains(economySource, "roomCrewKey = session.roomCrewKey", "EconomyService records RoomCrewKey in history")
    expectSourceContains(economySource, "roomCrewLaunchId = session.roomCrewLaunchId", "EconomyService records RoomCrewLaunchId in history")
    expectSourceContains(economySource, "roomParticipantCount = session.roomParticipantCount", "EconomyService records participant count in history")
    expectSourceContains(economySource, "RoomProgress", "EconomyService persists room progress")
    expectSourceContains(economySource, "RoomUnlocks = roomUnlocks", "EconomyService returns room unlock payloads")
    expectSourceContains(economySource, "helperAffinityGains", "EconomyService reports helper affinity gains")

    local scoreSource = getScriptSource(services, "ScoreService", "ModuleScript")
    expectSourceContains(scoreSource, "roomObjectiveBoostUntil", "ScoreService consumes room objective boost windows")
    expectSourceContains(scoreSource, "lastRoomObjectiveBoost", "ScoreService records room objective boost feedback")

    local starterPlayerScripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    local roomClientSource = getScriptSource(starterPlayerScripts, "RoomClient", "LocalScript")
    expectSourceContains(roomClientSource, "crew active", "RoomClient displays active room-session state")
    expectSourceContains(roomClientSource, "describeArtReadiness", "RoomClient displays room asset readiness")
    expectSourceContains(roomClientSource, "assetReadiness", "RoomClient consumes asset readiness snapshots")
    expectSourceContains(roomClientSource, "RoomBoardList", "RoomClient renders a full room board list")
    expectSourceContains(roomClientSource, "renderRoomCards", "RoomClient rebuilds room cards from snapshots")
    expectSourceContains(roomClientSource, "RoomCard_", "RoomClient creates a card per themed room")
    expectSourceContains(roomClientSource, "JoinRoomButton", "RoomClient exposes a per-room queue button")
    expectSourceContains(roomClientSource, "JoinRoomRequest", "RoomClient queues selected rooms through the server remote")
    expectSourceContains(roomClientSource, "RoomRewardSummary", "RoomClient displays room rewards")
    expectSourceContains(roomClientSource, "RoomAssetReadiness", "RoomClient displays room asset readiness per card")
    expectSourceContains(roomClientSource, "paletteCommitted", "RoomClient surfaces committed inspection palettes")
    expectSourceContains(roomClientSource, "perm missing", "RoomClient keeps publish-permission gaps visible")
    expectSourceContains(roomClientSource, "RoomBoardResponsiveScale", "RoomClient keeps the board responsive on smaller screens")
    expectSourceContains(roomClientSource, "describeObjectiveProgress", "RoomClient displays room objective progress")
    expectSourceContains(roomClientSource, "objectiveProgress", "RoomClient consumes objective progress payloads")
    expectSourceContains(roomClientSource, "objectiveCombo", "RoomClient displays room objective combo payloads")
    expectSourceContains(roomClientSource, "objectiveMilestone", "RoomClient displays objective milestone toasts")
    expectSourceContains(roomClientSource, "RoomSongStatusChip", "RoomClient has compact in-song room status")
    expectSourceContains(roomClientSource, "SongActive", "RoomClient reacts to active rhythm HUD state")
    expectSourceContains(roomClientSource, "child:IsA(\"ScreenGui\")", "RoomClient ignores duplicate RhythmGui folders")
    expectSourceContains(roomClientSource, "refreshSongChip(findSelectedRoom(latestSnapshot))", "RoomClient resets chip from latest room snapshot on song start")
    expectSourceContains(roomClientSource, "panel.Visible = not songActive", "RoomClient hides full room board during songs")

    local dataClientSource = getScriptSource(starterPlayerScripts, "DataClient", "LocalScript")
    expectSourceContains(dataClientSource, "WelcomeCard", "DataClient owns the welcome card chrome")
    expectSourceContains(dataClientSource, "refreshSongActiveChrome", "DataClient collapses profile chrome during songs")
    expectSourceContains(dataClientSource, "actionBar.Visible = not profileSongActive", "DataClient hides top action bar during songs")
    expectSourceContains(dataClientSource, "arrow.Visible = not profileSongActive", "DataClient hides stage arrow during songs")
    expectSourceContains(dataClientSource, "welcome.Visible = not profileSongActive and not welcomeDismissed", "DataClient hides welcome card during songs")
end

local function testAudienceZoneCompatibilitySourceContract(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping audience zone compatibility source contract (not on server)")
        return
    end
    local ServerScriptService = game:GetService("ServerScriptService")
    local services = ServerScriptService:FindFirstChild("Services")
    local audienceServiceSource = getScriptSource(services, "AudienceService", "ModuleScript")
    expectSourceContains(audienceServiceSource, "zonePart:IsA(\"ObjectValue\")", "AudienceService dereferences WorldV2 compatibility ObjectValue zones")
    expectSourceContains(audienceServiceSource, "zonePart:IsA(\"BasePart\")", "AudienceService validates the resolved audience zone before CFrame math")

    local starterPlayerScripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    local audienceClientSource = getScriptSource(starterPlayerScripts, "AudienceClient", "LocalScript")
    expectSourceContains(audienceClientSource, "zone:IsA(\"ObjectValue\")", "AudienceClient dereferences WorldV2 compatibility ObjectValue zones")
    expectSourceContains(audienceClientSource, "zone:IsA(\"BasePart\")", "AudienceClient validates the resolved audience zone before CFrame math")
    expectSourceContains(audienceClientSource, "setPanelVisible", "AudienceClient centralizes audience panel visibility")
    expectSourceContains(audienceClientSource, "not songActive and (forcedOpen or lastZone)", "AudienceClient hides audience panel during rhythm songs")
    expectSourceContains(audienceClientSource, "child:IsA(\"ScreenGui\")", "AudienceClient ignores duplicate RhythmGui folders")
end

local function testRoomPortalBuilderSourceContract(): ()
    if not RunService:IsServer() then
        print("[UnitTests] Skipping room portal builder source contract (not on server)")
        return
    end
    local ServerScriptService = game:GetService("ServerScriptService")
    local services = ServerScriptService:FindFirstChild("Services")
    local builderScript = services and services:FindFirstChild("WorldV2Builder")
    expect(builderScript ~= nil and builderScript:IsA("ModuleScript"), "WorldV2Builder ModuleScript exists")
    local source = builderScript and builderScript.Source or ""
    expectSourceContains(source, "buildRoomPortalRing", "WorldV2Builder creates room portal ring")
    expectSourceContains(source, "RoomPortalRing", "WorldV2Builder targets RoomPortalRing")
    expectSourceContains(source, "RoomQueuePrompt", "WorldV2Builder creates room queue prompts")
    expectSourceContains(source, "RoomId", "WorldV2Builder tags room portal prompts with RoomId")
    expectSourceContains(source, "RoomMinPlayers", "WorldV2Builder tags portal min players")
    expectSourceContains(source, "RoomFillSeconds", "WorldV2Builder tags portal fill seconds")
    expectSourceContains(source, "RoomTeamMode", "WorldV2Builder tags portal team mode")
    expectSourceContains(source, "RoomReadableSign", "WorldV2Builder creates readable room signs")
    expectSourceContains(source, "RoomAssetVisualStatus", "WorldV2Builder tags portal art readiness")
    expectSourceContains(source, "RoomInspectedAssetCount", "WorldV2Builder tags inspected asset count")
    expectSourceContains(source, "PaletteAssetCount", "WorldV2Builder tags committed palette asset counts")
    expectSourceContains(source, "MissingPublishPermissionCount", "WorldV2Builder tags publish-permission gaps")
    expectSourceContains(source, "buildThemedRoomSpaces", "WorldV2Builder creates themed room spaces")
    expectSourceContains(source, "ThemedRoomSpaces", "WorldV2Builder targets ThemedRoomSpaces")
    expectSourceContains(source, "RoomPlayableFloor", "WorldV2Builder creates playable floors for themed rooms")
    expectSourceContains(source, "StructuralThemeCues", "WorldV2Builder adds structural theme readability cues")
    expectSourceContains(source, "RoomTitleBeacon", "WorldV2Builder adds overhead room identity beacons")
    expectSourceContains(source, "RoomBackdropPanel_", "WorldV2Builder adds visible room backdrop panels")
    expectSourceContains(source, "RoomObjectiveStations", "WorldV2Builder creates room objective stations")
    expectSourceContains(source, "RoomObjectivePrompt", "WorldV2Builder creates interactive room objective prompts")
    expectSourceContains(source, "RoomObjectiveEffect", "WorldV2Builder tags objective effects")
    expectSourceContains(source, "RoomObjectiveCooldown", "WorldV2Builder tags objective cooldowns")
    expectSourceContains(source, "RoomObjectivePlayerAngleScale", "WorldV2Builder records compact objective station scale")
    expectSourceContains(source, "compact encounter objective", "WorldV2Builder keeps objective stations compact for player-angle views")
    expectSourceContains(source, "Use Objective", "WorldV2Builder labels objective interactions")
    expectSourceContains(source, "RoomHazardLanes", "WorldV2Builder creates room hazard lanes")
    expectSourceContains(source, "RoomHelperNPCs", "WorldV2Builder creates visible helper NPC groups")
    expectSourceContains(source, "RoomEncounterHazardCue", "WorldV2Builder tags room encounter hazard cues")
    expectSourceContains(source, "HelperActionLane_", "WorldV2Builder gives helper NPCs action lanes")
    expectSourceContains(source, "NpcMovementPattern", "WorldV2Builder marks helper NPC movement intent")
    expectSourceContains(source, "AssetAnchorPads", "WorldV2Builder creates asset-search anchor pads")
    expectSourceContains(source, "palette_committed_pending_permission_and_fragment", "WorldV2Builder marks committed palette art as not yet fragment-merged/release-ready")
    expectSourceContains(source, "RoomWall_", "WorldV2Builder creates invisible room boundary walls")
    expectSourceContains(source, "PlayableSpaceBoundary", "WorldV2Builder tags room walls as playable-space boundaries")
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
        testWorldValidationRejectsFakeAuditedSourceIds,
        testWorldValidationScriptDetection,
        testFanNpcCreatorLocalManifest,
        testVendorDialoguePrompts,
        testCreatorStoreBucketManifestSource,
        testConfigLanes,
        testAntiExploit,
        testRhythmInputClientSourceContract,
        testRhythmSongStartRemoteAndAudioSourceContract,
        testHordeRootPivot,
        testWorldV2Validation,
        testHordeClientMovementSource,
        testHordeServiceMovementPayloadSource,
        testScoreServiceFocusRecoveryBehavior,
        testHordeAudienceAssistBehavior,
        testHordeHelperNpcBehavior,
        testHordeRoomSpecificMechanics,
        testCreatorMenuExpansionBuilderSource,
        testRoomConfigThemedMultiplayerRooms,
        testEconomyRoomProgressRewards,
        testRoomServiceSourceContract,
        testRoomSessionPropagationSourceContract,
        testAudienceZoneCompatibilitySourceContract,
        testRoomPortalBuilderSourceContract,
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
