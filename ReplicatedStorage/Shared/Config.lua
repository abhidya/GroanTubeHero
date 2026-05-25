local Config = {}

Config.GameName = "Groan Tube Hero"
Config.DefaultSongId = "LocalAudioSong001"
Config.Modes = {
    Career = "Career",
    Pure = "Pure",
    Battle = "Battle",
}

Config.Lanes = {
    { index = 1, key = "Left", symbol = "←", name = "Left" },
    { index = 2, key = "Right", symbol = "→", name = "Right" },
    { index = 3, key = "Up", symbol = "↑", name = "Up" },
    { index = 4, key = "Down", symbol = "↓", name = "Down" },
}

Config.Difficulties = {
    Easy = { id = "Easy", label = "Easy", noteSpeed = 1.0, densityMultiplier = 1.0, doubleNotes = false, bursts = false, fakeouts = false, chaosSections = false, rewardMultiplier = 1.0, hpDamageMiss = 8, recommendedLevel = 1, hordeMissAdvance = 8 },
    Hard = { id = "Hard", label = "Hard", noteSpeed = 1.25, densityMultiplier = 1.5, doubleNotes = true, bursts = true, fakeouts = false, chaosSections = false, rewardMultiplier = 1.5, hpDamageMiss = 12, recommendedLevel = 3, hordeMissAdvance = 12 },
    Extreme = { id = "Extreme", label = "Extreme", noteSpeed = 1.5, densityMultiplier = 2.0, doubleNotes = true, bursts = true, fakeouts = true, chaosSections = false, rewardMultiplier = 2.25, hpDamageMiss = 16, recommendedLevel = 6, hordeMissAdvance = 16 },
    Brainrot = { id = "Brainrot", label = "Brainrot", noteSpeed = 1.75, densityMultiplier = 2.5, doubleNotes = true, bursts = true, fakeouts = true, chaosSections = true, glitchVisuals = true, rewardMultiplier = 3.0, hpDamageMiss = 20, recommendedLevel = 10, hordeMissAdvance = 20 },
}
Config.DifficultyOrder = { "Easy", "Hard", "Extreme", "Brainrot" }

Config.SegmentLengths = {
    Quick = { id = "20s", label = "20 sec", duration = 20, rewardMultiplier = 0.6 },
    Standard = { id = "30s", label = "30 sec", duration = 30, rewardMultiplier = 1.0 },
    Long = { id = "40s", label = "40 sec", duration = 40, rewardMultiplier = 1.25 },
    Full = { id = "full", label = "Full", duration = nil, rewardMultiplier = 2.0 },
}
Config.SegmentOrder = { "20s", "30s", "40s", "full" }

Config.MissGlitch = {
    enabled = true,
    duration = 0.25,
    volumeDuck = 0.2,
    screenShake = true,
    lightFlicker = true,
}

Config.DebugRhythm = false
Config.ClientHitCandidateWindow = 0.65

Config.Judgement = {
    PerfectWindow = 0.16,
    GoodWindow = 0.30,
    AcceptWindow = 0.42,
    LatencyGrace = 0.18,
    ClientInputMaxAge = 1.25,
    DebugWindow = 0.65,
    MissWindow = 0.42,
    PerfectScore = 100,
    GoodScore = 50,
    MissScore = 0,
    ComboStep = 10,
    MultiplierStep = 0.25,
    MultiplierMax = 4,
}

Config.Hype = {
    Min = 0,
    Max = 100,
    DeadRoom = { min = 0, max = 20 },
    UnsureCrowd = { min = 21, max = 50 },
    IntoIt = { min = 51, max = 80 },
    EncoreMode = { min = 81, max = 100 },
}

Config.ScoreGrades = {
    S = 95,
    A = 85,
    B = 70,
    C = 55,
    D = 0,
}

Config.RateLimits = {
    NoteHitPerSecond = 20,
    AudienceActionPerSecond = 8,
    StoreDebounceSeconds = 0.45,
    BuffCooldownSeconds = 12,
    AttackCooldownSeconds = 10,
}

Config.SongFlow = {
    CountdownSeconds = 3,
    SpawnLeadSeconds = 2.75,
    HighwayTravelSeconds = 2.75,
    SafeSongFallbackSeconds = 0,
}

Config.Economy = {
    AutoSaveSeconds = 60,
    BaseCompletionReward = 40,
    FirstClearBonus = 35,
    NewBestBonus = 25,
    MissionBonus = 20,
    VenueBonusCap = 2,
}

Config.RemoteNames = {
    "StartSongRequest",
    "StartSong",
    "NoteHit",
    "NoteJudged",
    "ScoreUpdate",
    "SongFinished",
    "UseBuff",
    "UseAttack",
    "AudienceAction",
    "PurchaseItem",
    "EquipItem",
    "ClaimMission",
    "DataSnapshot",
    "OpenSongSelect",
    "NPCDialogue",
    "HordeUpdate",
}

Config.DefaultProfile = {
    Version = 1,
    Level = 1,
    XP = 0,
    Fans = 0,
    Coins = 0,
    Tickets = 0,
    GroanTokens = 0,
    BestScores = {
        Career = {},
        Pure = {},
    },
    OwnedCosmetics = {
        TubeSounds = { "ClassicTube" },
        StageEffects = { "DefaultGlow" },
        AvatarPoses = { "HeroPose" },
        AudiencePacks = { "BasicCrowd" },
        StageThemes = { "SchoolBackdrop" },
        Buffs = { "CrowdWarmup" },
    },
    Equipped = {
        TubeSounds = "ClassicTube",
        StageEffects = "DefaultGlow",
        AvatarPoses = "HeroPose",
        AudiencePacks = "BasicCrowd",
        StageThemes = "SchoolBackdrop",
    },
    Upgrades = {
        Timing = 0,
        HypeGain = 0,
        Recovery = 0,
        Stagecraft = 0,
        Chaos = 0,
        Focus = 0,
        CoinBonus = 0,
        AudiencePower = 0,
    },
    Missions = {
        Daily = {},
        Weekly = {},
        Completed = {},
        ResetStamp = 0,
    },
    TourBus = {
        BiggerSpeakers = 0,
        SnackStand = 0,
        PracticeSeat = 0,
        MerchBox = 0,
        RoadCrew = 0,
        NeonWrap = 0,
    },
    SessionHistory = {
        Career = {},
        Pure = {},
    },
}

function Config.Clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

function Config.DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[Config.DeepCopy(k)] = Config.DeepCopy(v)
    end
    return copy
end

return Config
