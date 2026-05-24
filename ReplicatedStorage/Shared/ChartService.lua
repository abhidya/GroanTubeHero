local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local ChartService = {}

local function copyNote(note)
    local out = {}
    for k, v in pairs(note) do
        out[k] = v
    end
    return out
end

local function cloneSong(song)
    local out = {}
    for k, v in pairs(song) do
        if k ~= "Notes" and k ~= "Sections" then
            out[k] = v
        end
    end
    out.Sections = {}
    for _, section in ipairs(song.Sections or {}) do
        local s = {}
        for k, v in pairs(section) do
            s[k] = v
        end
        table.insert(out.Sections, s)
    end
    out.Notes = {}
    for _, note in ipairs(song.Notes or {}) do
        table.insert(out.Notes, copyNote(note))
    end
    return out
end

function ChartService.GetDifficultyConfig(difficulty)
    return Config.Difficulties[difficulty] or Config.Difficulties.Easy
end

function ChartService.GetSegmentConfig(segmentLength)
    for _, segment in pairs(Config.SegmentLengths) do
        if segment.id == segmentLength then
            return segment
        end
    end
    return Config.SegmentLengths.Standard
end

local function addTransformedNote(notes, source, timeValue, lane, idSuffix)
    local n = copyNote(source)
    n.time = timeValue
    n.lane = math.clamp(lane, 1, 4)
    n.id = tostring(source.id or "note") .. idSuffix
    table.insert(notes, n)
end

function ChartService.BuildDifficultyChart(baseSong, difficulty)
    local diff = ChartService.GetDifficultyConfig(difficulty)
    local chart = cloneSong(baseSong)
    chart.BaseSongId = baseSong.Id
    chart.Difficulty = diff.id
    chart.DifficultyConfig = diff
    if diff.id == "Easy" then
        return chart
    end

    local sourceNotes = chart.Notes
    local output = {}
    local minGap = diff.id == "Hard" and 0.22 or diff.id == "Extreme" and 0.18 or 0.15
    local lastTimeByLane = { -99, -99, -99, -99 }
    for index, note in ipairs(sourceNotes) do
        addTransformedNote(output, note, note.time, note.lane, "")
        lastTimeByLane[note.lane] = note.time

        if diff.doubleNotes and index % (diff.id == "Hard" and 8 or 5) == 0 then
            local lane = ((note.lane + 1) % 4) + 1
            if note.time - lastTimeByLane[lane] > minGap then
                addTransformedNote(output, note, note.time + 0.01, lane, "-double")
                lastTimeByLane[lane] = note.time + 0.01
            end
        end
        if diff.bursts and index % (diff.id == "Hard" and 11 or 7) == 0 then
            local burstCount = diff.id == "Brainrot" and 3 or 2
            for b = 1, burstCount do
                local lane = ((note.lane + b) % 4) + 1
                local t = note.time + (0.16 * b)
                if t < (baseSong.Duration or t + 1) and t - lastTimeByLane[lane] > minGap then
                    addTransformedNote(output, note, t, lane, "-burst" .. b)
                    lastTimeByLane[lane] = t
                end
            end
        end
        if diff.chaosSections and index % 13 == 0 then
            local lane = ((note.lane + 2) % 4) + 1
            local t = note.time + 0.33
            if t < (baseSong.Duration or t + 1) then
                addTransformedNote(output, note, t, lane, "-brainrot")
            end
        end
    end
    table.sort(output, function(a, b)
        if a.time == b.time then return a.lane < b.lane end
        return a.time < b.time
    end)
    chart.Notes = output
    return chart
end

local function resolveSegmentStart(song, segmentDuration, segmentStart)
    if not segmentDuration then
        return 0, "Full"
    end
    local maxStart = math.max(0, (song.Duration or segmentDuration) - segmentDuration)
    if type(segmentStart) == "number" then
        return math.clamp(segmentStart, 0, maxStart), "Custom"
    end
    if segmentStart == "Random" then
        local seed = math.floor((song.Duration or 0) * 1000) + #song.Notes
        return maxStart > 0 and (seed % math.max(1, math.floor(maxStart * 10))) / 10 or 0, "Random"
    end
    if type(segmentStart) == "string" then
        for _, section in ipairs(song.Sections or {}) do
            if section.name == segmentStart then
                return math.clamp(section.start or 0, 0, maxStart), section.name
            end
        end
    end
    return 0, "Intro"
end

function ChartService.BuildPlayableChart(baseSong, difficulty, segmentLength, segmentStart)
    local diffChart = ChartService.BuildDifficultyChart(baseSong, difficulty or "Easy")
    local segment = ChartService.GetSegmentConfig(segmentLength or "30s")
    local segmentDuration = segment.duration
    local startTime, sectionName = resolveSegmentStart(diffChart, segmentDuration, segmentStart)
    local finishTime = segmentDuration and (startTime + segmentDuration) or (diffChart.Duration or 30)

    local playable = cloneSong(diffChart)
    playable.Id = baseSong.Id
    playable.SourceSongId = baseSong.Id
    playable.Difficulty = (Config.Difficulties[difficulty] and difficulty) or "Easy"
    playable.SegmentLength = segment.id
    playable.SegmentLabel = segment.label
    playable.SegmentStart = startTime
    playable.SegmentSection = sectionName
    playable.SegmentMultiplier = segment.rewardMultiplier or 1
    playable.DifficultyMultiplier = ChartService.GetDifficultyConfig(playable.Difficulty).rewardMultiplier or 1
    playable.Duration = segmentDuration or (diffChart.Duration or 30)
    playable.Offset = 0
    playable.Notes = {}

    local count = 0
    for _, note in ipairs(diffChart.Notes or {}) do
        if note.time >= startTime and note.time <= finishTime then
            count += 1
            local n = copyNote(note)
            n.time = math.max(0, note.time - startTime)
            n.id = string.format("%s-%s-%s-%03d", playable.Id, playable.Difficulty, segment.id, count)
            table.insert(playable.Notes, n)
        end
    end

    -- If a chart segment is sparse, add deterministic filler so every visible
    -- local/test song can be played through the selected short segment.
    local minNotes = math.max(8, math.floor((playable.Duration or 20) * (ChartService.GetDifficultyConfig(playable.Difficulty).densityMultiplier or 1) * 1.15 + 0.5))
    if #playable.Notes < minNotes then
        local syntheticCount = minNotes - #playable.Notes
        for i = 1, syntheticCount do
            local base = diffChart.Notes[((i - 1) % math.max(1, #diffChart.Notes)) + 1] or { lane = ((i - 1) % 4) + 1 }
            local n = copyNote(base)
            n.time = 1 + (i - 1) * math.max(0.45, ((playable.Duration or 20) - 2) / math.max(1, syntheticCount))
            n.lane = ((i - 1) % 4) + 1
            n.id = string.format("%s-fill-%03d", playable.Id, i)
            table.insert(playable.Notes, n)
        end
    end

    table.sort(playable.Notes, function(a, b)
        if a.time == b.time then return a.lane < b.lane end
        return a.time < b.time
    end)
    playable.TotalSourceNotes = #(diffChart.Notes or {})
    return playable
end

return ChartService
