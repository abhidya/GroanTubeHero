local AssetRegistry = {}

AssetRegistry.Entries = {
    StagePlatform = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Stage.StagePlatform", "Workspace.Stage.StagePlatform" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "central performance deck" },
    Truss = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Stage.Truss" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "concert truss decoration" },
    SpeakerStack = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Stage.SpeakerStack", "Workspace.Stage.SpeakerStacks.SpeakerStack1", "Workspace.Stage.SpeakerStacks.SpeakerStack2" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "speaker power fantasy" },
    Spotlight = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lighting.Spotlight", "Workspace.Stage.Spotlights" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "stage lighting" },
    LaserBeamAnchor = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lighting.LaserBeamAnchor" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "laser/beam/light anchors" },
    CashRegister = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.CashRegister", "Workspace.Stage.StoreKiosk" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "store counter" },
    UpgradeTerminal = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.UpgradeTerminal", "Workspace.Stage.UpgradeKiosk" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "upgrade station" },
    MissionBoard = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.MissionBoard", "Workspace.Stage.MissionBoard" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "missions station" },
    SecurityTerminal = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.SecurityTerminal" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "sector health station" },
    TutorialGuide = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.TutorialGuide" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "tutorial station" },
    HypeManager = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Audience.HypeManager" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "audience rewards station" },
    FenceSegment = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Props.FenceSegment" }, Required = false, FallbackAllowed = false, CloneCount = 32, Purpose = "fence ring protection" },
    HordeEnemy = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Horde.HordeEnemy", "Workspace.Unused_MapAssets" }, Required = false, FallbackAllowed = false, CloneCount = 40, Purpose = "horde cluster figures" },
    HordeGate = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Horde.HordeGate" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "sector gate silhouette" },
    CrowdNPC = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Audience.CrowdNPC", "Workspace.Unused_MapAssets" }, Required = false, FallbackAllowed = false, CloneCount = 24, Purpose = "crowd silhouettes" },
    StadiumChair = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Audience.StadiumChair" }, Required = false, FallbackAllowed = false, CloneCount = 32, Purpose = "audience seating" },
    VolcanoCliff = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Volcano.VolcanoCliff", "Workspace.Stage.BrainrotBackdrop" }, Required = false, FallbackAllowed = false, CloneCount = 16, Purpose = "outer cliff/horizon mask" },
    LavaFogEmber = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Volcano.LavaFogEmber", "ReplicatedStorage.ArtAssets.Lighting" }, Required = false, FallbackAllowed = false, CloneCount = 16, Purpose = "lava/fog/ember effects" },
}

local function resolvePath(path)
    local current = game
    for token in string.gmatch(path, "[^%.]+") do
        if token == "game" then
            current = game
        else
            current = current and current:FindFirstChild(token)
        end
    end
    return current
end

function AssetRegistry.Resolve(entryName)
    local entry = AssetRegistry.Entries[entryName]
    if not entry then return nil, "UnknownAssetRegistryEntry" end
    for _, path in ipairs(entry.PreferredPaths or {}) do
        local inst = resolvePath(path)
        if inst then return inst, path, entry end
    end
    if entry.Required then
        return nil, "MissingRequiredAsset", entry
    end
    return nil, "MissingOptionalAsset", entry
end

function AssetRegistry.MissingRequired()
    local missing = {}
    for name, entry in pairs(AssetRegistry.Entries) do
        if entry.Required then
            local inst = AssetRegistry.Resolve(name)
            if not inst then table.insert(missing, name) end
        end
    end
    table.sort(missing)
    return missing
end

return AssetRegistry
