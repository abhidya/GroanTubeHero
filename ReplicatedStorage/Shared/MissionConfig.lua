local MissionConfig = {}

MissionConfig.Daily = {
    { id = "DailyPerfects", title = "Get 50 Perfects", event = "PerfectHit", target = 50, rewardFans = 120, rewardCoins = 80, rewardXP = 150 },
    { id = "DailySongs", title = "Finish 3 songs", event = "SongFinished", target = 3, rewardFans = 80, rewardCoins = 70, rewardXP = 100 },
    { id = "DailyHype", title = "Reach 80 Hype", event = "HypePeak", target = 1, rewardFans = 100, rewardCoins = 75, rewardXP = 120 },
    { id = "DailyBuffs", title = "Use 2 buffs", event = "BuffUsed", target = 2, rewardFans = 70, rewardCoins = 70, rewardXP = 90 },
    { id = "DailyCheer", title = "Cheer for 2 performances", event = "AudienceActionCheer", target = 2, rewardFans = 60, rewardCoins = 40, rewardXP = 80 },
    { id = "DailyBattle", title = "Battle wins — Coming Soon", event = "BattleWin", target = 1, rewardFans = 140, rewardCoins = 120, rewardXP = 160 },
    { id = "DailyClean", title = "Clear a song with fewer than 5 misses", event = "SongClearUnder5Misses", target = 1, rewardFans = 100, rewardCoins = 90, rewardXP = 130 },
    { id = "DailyQuickRun", title = "Finish any 20s Quick Run", event = "QuickRun20s", target = 1, rewardFans = 60, rewardCoins = 50, rewardXP = 80 },
    { id = "DailyHard30", title = "Clear 30s on Hard", event = "Hard30sClear", target = 1, rewardFans = 110, rewardCoins = 90, rewardXP = 130 },
    { id = "DailyBrainrot40", title = "Survive 40s Brainrot with 30+ Stability", event = "Brainrot40sSurvive", target = 1, rewardFans = 180, rewardCoins = 130, rewardXP = 220 },
    { id = "DailyFullClear", title = "Full clear any song", event = "FullClear", target = 1, rewardFans = 170, rewardCoins = 130, rewardXP = 200 },
    { id = "DailyClearEasy", title = "Clear Easy difficulty", event = "ClearDifficulty_Easy", target = 1, rewardFans = 60, rewardCoins = 40, rewardXP = 70 },
    { id = "DailyClearHard", title = "Clear Hard difficulty", event = "ClearDifficulty_Hard", target = 1, rewardFans = 90, rewardCoins = 70, rewardXP = 100 },
}

MissionConfig.Weekly = {
    { id = "WeeklyFans", title = "Earn 10,000 Fans", event = "FansEarned", target = 10000, rewardFans = 500, rewardCoins = 400, rewardXP = 600 },
    { id = "WeeklyAGrades", title = "Get A grade on 5 songs", event = "SongGradeAOrHigher", target = 5, rewardFans = 350, rewardCoins = 350, rewardXP = 500 },
    { id = "WeeklyEncore", title = "Trigger Encore Mode 3 times", event = "EncoreModeTriggered", target = 3, rewardFans = 350, rewardCoins = 300, rewardXP = 450 },
    { id = "WeeklyAudience", title = "Help 5 performers as audience", event = "AudienceHelp", target = 5, rewardFans = 250, rewardCoins = 220, rewardXP = 350 },
    { id = "WeeklyExtreme", title = "Clear Extreme difficulty", event = "ClearDifficulty_Extreme", target = 1, rewardFans = 300, rewardCoins = 260, rewardXP = 420 },
    { id = "WeeklyBrainrot", title = "Clear Brainrot difficulty", event = "ClearDifficulty_Brainrot", target = 1, rewardFans = 450, rewardCoins = 360, rewardXP = 620 },
}

function MissionConfig.GetAll()
    return {
        Daily = MissionConfig.Daily,
        Weekly = MissionConfig.Weekly,
    }
end

return MissionConfig
