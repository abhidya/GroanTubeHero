--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Scoring = require(Shared.Scoring)
local ChartService = require(Shared.ChartService)
local SongCatalog = require(Shared.SongCatalog)

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
    local oldDebug = Config.DebugRhythm
    Config.DebugRhythm = false
    expectEqual(SongCatalog.PrettyTitle("LocalAudioSong001"), "Local Audio Song 001", "local public title sanitizes")
    Config.DebugRhythm = true
    expectEqual(SongCatalog.PrettyTitle("LocalAudioSong001"), "Thick of it Thomas the train remix", "debug title override visible")
    Config.DebugRhythm = oldDebug
end

function UnitTests.Run(): { passed: number, failed: number, failures: { string } }
    local tests = {
        testScoring,
        testChartSegments,
        testCatalogTitles,
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
