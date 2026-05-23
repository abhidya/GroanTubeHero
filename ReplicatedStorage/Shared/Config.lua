local Config = {}

Config.GameName = "Groan Tube Hero"
Config.DefaultSongId = "NeonGroan"
Config.Modes = {
    Career = "Career",
    Pure = "Pure",
    Battle = "Battle",
}

Config.Lanes = {
    { index = 1, key = "Left", symbol = "<-", name = "Left" },
    { index = 2, key = "Right", symbol = "->", name = "Right" },
    { index = 3, key = "Up", symbol = "^", name = "Up" },
    { index = 4, key = "Down", symbol = "V", name = "Down" },
}

Config.Judgement = {
    PerfectWindow = 0.09,
    GoodWindow = 0.16,
    AcceptWindow = 0.25,
    MissWindow = 0.25,
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
    "DataSnapshot",
    "ReviveSong",
}

Config.DefaultProfile = {
    Version = 1,
    Level = 1,
    XP = 0,
    Fans = 0,
    Coins = 0,
    Tickets = 0,
    GroanTokens = 0,
    VIP = false,
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
    SongUnlocks = {
        Downloads = false,
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
