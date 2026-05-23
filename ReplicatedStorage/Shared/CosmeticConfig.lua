local CosmeticConfig = {}

CosmeticConfig.Items = {
    TubeSounds = {
        ClassicTube = { id = "ClassicTube", name = "Classic Tube", price = 0, currency = "Coins", default = true, tubeTag = "Classic Tube", laneFlash = Color3.fromRGB(255, 255, 255) },
        NeonGroan = { id = "NeonGroan", name = "Neon Groan", price = 120, currency = "Fans", tubeTag = "Neon Groan", laneFlash = Color3.fromRGB(120, 240, 255) },
        RustyWail = { id = "RustyWail", name = "Rusty Wail", price = 100, currency = "Coins", tubeTag = "Rusty Wail", laneFlash = Color3.fromRGB(255, 170, 120) },
    },
    StageEffects = {
        DefaultGlow = { id = "DefaultGlow", name = "Default Glow", price = 0, currency = "Coins", default = true, stageEffect = "Glow" },
        PurpleRift = { id = "PurpleRift", name = "Purple Rift", price = 160, currency = "Fans", stageEffect = "Purple Rift" },
        ChromeSpark = { id = "ChromeSpark", name = "Chrome Spark", price = 180, currency = "Coins", stageEffect = "Chrome Spark" },
    },
    AvatarPoses = {
        HeroPose = { id = "HeroPose", name = "Hero Pose", price = 0, currency = "Coins", default = true, poseTag = "Hero Pose" },
        CrookedBop = { id = "CrookedBop", name = "Crooked Bop", price = 90, currency = "Coins", poseTag = "Crooked Bop" },
        TubeLegend = { id = "TubeLegend", name = "Tube Legend", price = 150, currency = "Fans", poseTag = "Tube Legend" },
    },
    AudiencePacks = {
        BasicCrowd = { id = "BasicCrowd", name = "Basic Crowd", price = 0, currency = "Coins", default = true, packTag = "Basic Crowd" },
        NeonFans = { id = "NeonFans", name = "Neon Fans", price = 140, currency = "Fans", packTag = "Neon Fans" },
        MallRegulars = { id = "MallRegulars", name = "Mall Regulars", price = 110, currency = "Coins", packTag = "Mall Regulars" },
    },
    StageThemes = {
        SchoolBackdrop = { id = "SchoolBackdrop", name = "School Backdrop", price = 0, currency = "Coins", default = true, themeTag = "School Backdrop" },
        NeonArenaTheme = { id = "NeonArenaTheme", name = "Neon Arena", price = 150, currency = "Fans", themeTag = "Neon Arena" },
        WeddingGlow = { id = "WeddingGlow", name = "Wedding Glow", price = 130, currency = "Coins", themeTag = "Wedding Glow" },
    },
    Buffs = {
        SecondWind = { id = "SecondWind", name = "Second Wind", price = 35, currency = "Coins", unlocks = true },
        CrowdWarmup = { id = "CrowdWarmup", name = "Crowd Warmup", price = 25, currency = "Coins", unlocks = true, default = true },
        EncoreEnergy = { id = "EncoreEnergy", name = "Encore Energy", price = 45, currency = "Fans", unlocks = true },
        SteadyHands = { id = "SteadyHands", name = "Steady Hands", price = 30, currency = "Coins", unlocks = true },
        DramaBoost = { id = "DramaBoost", name = "Drama Boost", price = 30, currency = "Coins", unlocks = true },
        TubeSolo = { id = "TubeSolo", name = "Tube Solo", price = 30, currency = "Coins", unlocks = true },
        DeepBreath = { id = "DeepBreath", name = "Deep Breath", price = 20, currency = "Coins", unlocks = true },
        CrowdCall = { id = "CrowdCall", name = "Crowd Call", price = 20, currency = "Coins", unlocks = true },
        StageFocus = { id = "StageFocus", name = "Stage Focus", price = 25, currency = "Coins", unlocks = true },
        EncoreSurge = { id = "EncoreSurge", name = "Encore Surge", price = 30, currency = "Fans", unlocks = true },
        TubeResonance = { id = "TubeResonance", name = "Tube Resonance", price = 25, currency = "Coins", unlocks = true },
        CleanRun = { id = "CleanRun", name = "Clean Run", price = 25, currency = "Coins", unlocks = true },
    },
}

function CosmeticConfig.Get(category, itemId)
    local categoryItems = CosmeticConfig.Items[category]
    if not categoryItems then
        return nil
    end
    return categoryItems[itemId]
end

function CosmeticConfig.GetDefaultOwned()
    local owned = {}
    for category, categoryItems in pairs(CosmeticConfig.Items) do
        owned[category] = {}
        for id, item in pairs(categoryItems) do
            if item.default then
                owned[category][id] = true
            end
        end
    end
    return owned
end

function CosmeticConfig.GetVisualProfile(equipped)
    local tubeSound = CosmeticConfig.Get("TubeSounds", equipped.TubeSounds or "ClassicTube") or CosmeticConfig.Items.TubeSounds.ClassicTube
    local stageEffect = CosmeticConfig.Get("StageEffects", equipped.StageEffects or "DefaultGlow") or CosmeticConfig.Items.StageEffects.DefaultGlow
    local pose = CosmeticConfig.Get("AvatarPoses", equipped.AvatarPoses or "HeroPose") or CosmeticConfig.Items.AvatarPoses.HeroPose
    local audience = CosmeticConfig.Get("AudiencePacks", equipped.AudiencePacks or "BasicCrowd") or CosmeticConfig.Items.AudiencePacks.BasicCrowd
    local theme = CosmeticConfig.Get("StageThemes", equipped.StageThemes or "SchoolBackdrop") or CosmeticConfig.Items.StageThemes.SchoolBackdrop

    return {
        tubeTag = tubeSound.tubeTag,
        laneFlash = tubeSound.laneFlash,
        stageEffect = stageEffect.stageEffect,
        poseTag = pose.poseTag,
        audiencePack = audience.packTag,
        themeTag = theme.themeTag,
    }
end

return CosmeticConfig
