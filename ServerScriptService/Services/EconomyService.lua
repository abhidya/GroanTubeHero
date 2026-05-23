local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local EconomyConfig = require(ReplicatedStorage.Shared.EconomyConfig)
local Scoring = require(ReplicatedStorage.Shared.Scoring)

local EconomyService = {}
EconomyService.__index = EconomyService

function EconomyService:Init(runtimeContext)
    self.context = runtimeContext
end


function EconomyService:LevelFromXP(xp)
    local level = 1
    while xp >= EconomyConfig.GetXPForLevel(level + 1) do
        level = level + 1
    end
    return level
end

function EconomyService:FinalizeSong(player, session, summary)
    local profile = self.context.Services.DataService:GetProfile(player)
    if not profile then
        return nil
    end

    local venue, modifiers = self.context.Services.VenueService:GetRewardModifiers(session.venueId)
    local difficulty = session.difficulty or summary.difficulty or "Easy"
    local base = EconomyConfig.GetDifficultyProfile(difficulty)
    local difficultyMultiplier = (session.song and session.song.DifficultyMultiplier) or (session.difficultyConfig and session.difficultyConfig.rewardMultiplier) or 1
    local segmentMultiplier = (session.song and session.song.SegmentMultiplier) or 1

    local gradeMultiplier = 1
    if summary.grade == "S" then
        gradeMultiplier = 1.35
    elseif summary.grade == "A" then
        gradeMultiplier = 1.20
    elseif summary.grade == "B" then
        gradeMultiplier = 1.05
    elseif summary.grade == "C" then
        gradeMultiplier = 0.95
    else
        gradeMultiplier = 0.85
    end

    local hypeBonus = math.floor((summary.hype or 0) * 0.5)
    local comboBonus = math.floor((summary.maxCombo or 0) * 2)
    local completionBonus = Config.Economy.BaseCompletionReward
    local firstClearBonus = 0
    local newBestBonus = 0
    local missionBonus = 0

    local modeKey = session.mode or Config.Modes.Career
    profile.BestScores = profile.BestScores or {}
    profile.BestScores[modeKey] = profile.BestScores[modeKey] or {}
    local bestKey = string.format("%s:%s:%s:%s", session.songId, difficulty, session.segmentLength or "30s", session.segmentSection or "Intro")
    local bestRecord = profile.BestScores[modeKey][bestKey]
    if not bestRecord then
        firstClearBonus = Config.Economy.FirstClearBonus
    else
        if summary.score > (bestRecord.bestScore or 0) then
            newBestBonus = Config.Economy.NewBestBonus
        end
    end

    self.context.Services.MissionService:RecordEvent(profile, "SongFinished", 1, { player = player })
    self.context.Services.MissionService:RecordEvent(profile, "ClearDifficulty_" .. difficulty, 1, { player = player })
    if session.segmentLength == "20s" then
        self.context.Services.MissionService:RecordEvent(profile, "QuickRun20s", 1, { player = player })
    elseif session.segmentLength == "30s" and difficulty == "Hard" then
        self.context.Services.MissionService:RecordEvent(profile, "Hard30sClear", 1, { player = player })
    elseif session.segmentLength == "40s" and difficulty == "Brainrot" and (summary.hp or 0) >= 30 then
        self.context.Services.MissionService:RecordEvent(profile, "Brainrot40sSurvive", 1, { player = player })
    elseif session.segmentLength == "full" then
        self.context.Services.MissionService:RecordEvent(profile, "FullClear", 1, { player = player })
    end
    if summary.grade == "A" or summary.grade == "S" then
        self.context.Services.MissionService:RecordEvent(profile, "SongGradeAOrHigher", 1, { player = player })
    end
    if summary.miss < 5 then
        self.context.Services.MissionService:RecordEvent(profile, "SongClearUnder5Misses", 1, { player = player })
    end
    if summary.hype >= 80 then
        self.context.Services.MissionService:RecordEvent(profile, "HypePeak", 1, { player = player })
    end
    if summary.grade == "S" then
        self.context.Services.MissionService:RecordEvent(profile, "EncoreModeTriggered", 1, { player = player })
    end

    local rewardFans = math.floor(base.baseFans * gradeMultiplier * difficultyMultiplier * segmentMultiplier)
    local rewardCoins = math.floor(base.baseCoins * gradeMultiplier * difficultyMultiplier * segmentMultiplier)
    local rewardXP = math.floor(base.baseXP * gradeMultiplier * difficultyMultiplier * segmentMultiplier)
    local rewardTickets = base.baseTickets or 0

    rewardFans = math.floor(rewardFans + hypeBonus + comboBonus * 0.5 + completionBonus)
    rewardCoins = math.floor(rewardCoins + comboBonus * 0.35 + completionBonus * 0.5)
    rewardXP = math.floor(rewardXP + math.floor(summary.accuracyPercent or 0))

    if session.mode == Config.Modes.Battle and summary.battle then
        rewardFans = rewardFans + 20
        rewardCoins = rewardCoins + 20
    end

    local venueFee = self.context.Services.VenueService:GetFeeMultiplier(session.venueId, profile)
    local feeAmount = math.floor(rewardFans * venueFee)
    local netFans = rewardFans - feeAmount
    local venueFansBonus = math.floor(netFans * ((modifiers.fans or 1) - 1))
    netFans = netFans + venueFansBonus
    rewardCoins = math.floor(rewardCoins * (profile.Upgrades.CoinBonus and (1 + profile.Upgrades.CoinBonus * 0.08) or 1))
    rewardXP = math.floor(rewardXP * (1 + (profile.Upgrades.Stagecraft or 0) * 0.04))
    rewardTickets = rewardTickets + (modifiers.tickets or 0)

    local busModifiers = self.context.Services.TourBusService:ApplyRewardModifiers(profile, {
        Fans = netFans,
        Coins = rewardCoins,
        XP = rewardXP,
        Tickets = rewardTickets,
    }, summary.miss > 0)

    if summary.cleanedSection and session.modifiers and session.modifiers.encoreEnergy then
        busModifiers.Fans = math.floor(busModifiers.Fans * 1.1)
    end

    missionBonus = missionBonus + (self.context.Services.MissionService:RecordEvent(profile, "FansEarned", busModifiers.Fans, { player = player }).Fans or 0)

    local rewards = {
        Fans = busModifiers.Fans + firstClearBonus + newBestBonus,
        Coins = busModifiers.Coins + newBestBonus,
        XP = busModifiers.XP + missionBonus,
        Tickets = busModifiers.Tickets,
        GroanTokens = 0,
        DifficultyMultiplier = difficultyMultiplier,
        SegmentMultiplier = segmentMultiplier,
        VenueFee = feeAmount,
        GrossFans = rewardFans,
    }

    profile.SessionHistory = profile.SessionHistory or { Career = {}, Pure = {} }
    profile.SessionHistory[modeKey] = profile.SessionHistory[modeKey] or {}
    table.insert(profile.SessionHistory[modeKey], {
        songId = session.songId,
        score = summary.score,
        grade = summary.grade,
        hype = summary.hype,
        maxCombo = summary.maxCombo,
        time = os.time(),
        difficulty = difficulty,
        segmentLength = session.segmentLength,
        segmentSection = session.segmentSection,
    })

    profile.BestScores[modeKey][bestKey] = profile.BestScores[modeKey][bestKey] or {}
    local best = profile.BestScores[modeKey][bestKey]
    if summary.score > (best.bestScore or 0) then
        best.bestScore = summary.score
    end
    if summary.maxCombo > (best.bestCombo or 0) then
        best.bestCombo = summary.maxCombo
    end
    if not best.bestGrade or summary.grade < best.bestGrade then
        best.bestGrade = summary.grade
    end

    profile.Fans = profile.Fans + rewards.Fans
    profile.Coins = profile.Coins + rewards.Coins
    profile.XP = profile.XP + rewards.XP
    profile.Tickets = profile.Tickets + rewards.Tickets

    local oldLevel = profile.Level
    profile.Level = self:LevelFromXP(profile.XP)
    if profile.Level > oldLevel then
        rewards.LevelUp = profile.Level - oldLevel
    end

    self.context.Services.DataService:SavePlayer(player)
    self.context.Services.DataService:UpdateProfile(player, function(p)
        return p
    end)
    self.context.Remotes.DataSnapshot:FireClient(player, self.context.Services.DataService:GetSnapshot(player))
    return rewards
end

return EconomyService
