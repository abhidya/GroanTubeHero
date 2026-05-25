local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local WorldValidation = {}

local REQUIRED_ROOTS = { "ArenaCore", "StageCircle", "InnerPlayerRing", "VendorRing", "FenceRing", "HordeRing", "AudienceRing", "VolcanoOuterRing", "OuterVolcanoRing", "LightingAnchors", "InvisibleGameplayHitboxes", "CompatibilityAdapters" }
local REQUIRED_VENDORS = { "DJ_GroanMaster", "Vendor_Store", "Vendor_UpgradeEngineer", "MissionOfficer", "SecurityManager", "TutorialGuide" }
local REQUIRED_SECTORS = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }
local REQUIRED_SECTOR_CHILDREN = { "FenceSegment", "FenceDamageVFX", "SecurityLight", "SirenLight", "HordeCluster", "HordePressureMeter", "WeakPointMarker" }
local PLACEHOLDER_NAMES = { Part = true, Block = true, Circle = true, Cylinder = true, Temp = true, Debug = true }
local REQUIRED_ART_ASSETS = { "WorldV2_SafeProceduralKit" }
local PLACEMENT_MINIMUMS = {
    stageCore = 60,
    lightingAndTrusses = 80,
    vendorRing = 60,
    fenceRing = 64,
    hordeRing = 160,
    audienceRing = 80,
    volcanoOuterRing = 80,
    tourBusAndSpawn = 30,
    activePlacedArtInstances = 500,
}
local TRUSTED_VIRTUAL_ASSET_SOURCES = {
    ["ProjectOwned/ReadableWorldV2Art"] = true,
}

local AUTOGEN_PATTERNS = {
    "^NpcBody$", "^NpcHead$", "^StationPlinth$", "^HordeFigure_", "^FenceArcSegment_",
    "^VolcanicCliff_", "^CrowdSilhouette_", "^CursedConcertDisc$", "^NeonPerformanceCircle$",
    "^PlayerWalkwayRing$", "^MenuSurfaceSign$", "^FenceSegment$", "^FenceDamageVFX$",
    "^SecurityLight$", "^SirenLight$", "^HordePressureMeter$", "^WeakPointMarker$",
}

local function add(errors, condition, message)
    if not condition then table.insert(errors, message) end
end

local function isVisibleBasePart(inst)
    return inst:IsA("BasePart") and inst.Transparency < 0.95
end


local function matchesAnyPattern(name, patterns)
    for _, pattern in ipairs(patterns) do
        if tostring(name):match(pattern) then return true end
    end
    return false
end

local function placementCategory(world, inst)
    if not world or not inst then return nil end
    local rootMap = {
        ArenaCore = "stageCore",
        StageCircle = "stageCore",
        InnerPlayerRing = "stageCore",
        LightingAnchors = "lightingAndTrusses",
        VendorRing = "vendorRing",
        FenceRing = "fenceRing",
        HordeRing = "hordeRing",
        AudienceRing = "audienceRing",
        VolcanoOuterRing = "volcanoOuterRing",
        OuterVolcanoRing = "volcanoOuterRing",
    }
    for rootName, category in pairs(rootMap) do
        local root = world:FindFirstChild(rootName)
        if root and inst:IsDescendantOf(root) then return category end
    end
    if inst.Name == "SpawnLocation" or tostring(inst:GetAttribute("PlacementCategory")) == "tourBusAndSpawn" then
        return "tourBusAndSpawn"
    end
    return nil
end

local function resolvePath(path)
    if type(path) ~= "string" or path == "" or path == "UNKNOWN" then return nil end
    local current = game
    for token in string.gmatch(path, "[^%.]+") do
        if token == "game" then
            current = game
        else
            current = current and current:FindFirstChild(token)
        end
        if not current then return nil end
    end
    return current
end

local function auditedSourcePath(inst)
    local sourcePath = inst:GetAttribute("AssetSourcePath")
    if inst:GetAttribute("AuditedArtAsset") ~= true or type(sourcePath) ~= "string" then
        return nil
    end
    return sourcePath
end

local function getServerStorage()
    if RunService:IsServer() then
        return game:GetService("ServerStorage")
    end
    return nil
end

local function countActive(world)
    local counts = {
        models = 0,
        meshParts = 0,
        visibleBaseParts = 0,
        invisibleHitboxes = 0,
        activeWorldScripts = 0,
        quarantinedScripts = 0,
        vendorPrompts = 0,
        hordeSectors = 0,
        missingRequiredAssets = 0,
        visiblePlaceholderViolations = 0,
        auditScripts = 0,
        auditMeshParts = 0,
        auditParts = 0,
        auditSounds = 0,
        auditEmitters = 0,
        auditLights = 0,
        auditDecals = 0,
        auditSurfaceAppearances = 0,
        activePlacedArtInstances = 0,
        stageCore = 0,
        lightingAndTrusses = 0,
        vendorRing = 0,
        fenceRing = 0,
        hordeRing = 0,
        audienceRing = 0,
        volcanoOuterRing = 0,
        tourBusAndSpawn = 0,
        invisibleHitboxesExcluded = 0,
        archivedObjectsExcluded = 0,
        quarantinedObjectsExcluded = 0,
        autogenBlankMeshesExcluded = 0,
        incorrectRingPlacements = 0,
        unauditedAssetPlacements = 0,
        massBrainrotNPCs = 0,
        distinctAuditedSourcePaths = 0,
        invalidAuditedSourcePaths = 0,
        creatorMenuExpansionModelPlacements = 0,
        creatorMenuExpansionSourceFamilies = 0,
        creatorMenuExpansionMissingSources = 0,
    }
    local auditedSourcePaths = {}
    local sourcePathResolution = {}
    local hitboxes = world and world:FindFirstChild("InvisibleGameplayHitboxes")
    if world then
        counts.creatorMenuExpansionSourceFamilies = tonumber(world:GetAttribute("CreatorMenuExpansionSourceFamilies")) or 0
        counts.creatorMenuExpansionMissingSources = tonumber(world:GetAttribute("CreatorMenuExpansionMissingSources")) or 0
        for _, desc in ipairs(world:GetDescendants()) do
            if desc:IsA("Model") then
                counts.models += 1
                if desc:GetAttribute("MassBrainrotNPC") == true then counts.massBrainrotNPCs += 1 end
                if desc:GetAttribute("CreatorMenuExpansion") == true then counts.creatorMenuExpansionModelPlacements += 1 end
            end
            if desc:IsA("MeshPart") then counts.meshParts += 1 end
            if isVisibleBasePart(desc) then
                counts.visibleBaseParts += 1
                if hitboxes and desc:IsDescendantOf(hitboxes) then
                    counts.invisibleHitboxesExcluded += 1
                else
                    local sourcePath = auditedSourcePath(desc)
                    if sourcePath ~= nil and sourcePathResolution[sourcePath] == nil then
                        sourcePathResolution[sourcePath] = TRUSTED_VIRTUAL_ASSET_SOURCES[sourcePath] == true or resolvePath(sourcePath) ~= nil
                    end
                    if sourcePath ~= nil and sourcePathResolution[sourcePath] == true then
                        auditedSourcePaths[sourcePath] = true
                        local category = placementCategory(world, desc)
                        if category then
                            counts[category] += 1
                            counts.activePlacedArtInstances += 1
                        else
                            counts.incorrectRingPlacements += 1
                        end
                    else
                        if desc:GetAttribute("AuditedArtAsset") == true or desc:GetAttribute("AssetSourcePath") ~= nil then
                            counts.invalidAuditedSourcePaths += 1
                        end
                        counts.unauditedAssetPlacements += 1
                        if matchesAnyPattern(desc.Name, AUTOGEN_PATTERNS) or desc.ClassName == "Part" or desc.ClassName == "SpawnLocation" then
                            counts.autogenBlankMeshesExcluded += 1
                        end
                    end
                end
            end
            if hitboxes and desc:IsDescendantOf(hitboxes) and desc:IsA("BasePart") then counts.invisibleHitboxes += 1 end
            if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then counts.activeWorldScripts += 1 end
            if desc:IsA("ProximityPrompt") then counts.vendorPrompts += 1 end
            if isVisibleBasePart(desc) and PLACEHOLDER_NAMES[desc.Name] and not (hitboxes and desc:IsDescendantOf(hitboxes)) then
                counts.visiblePlaceholderViolations += 1
            end
        end
        local horde = world:FindFirstChild("HordeRing")
        if horde then
            for _, id in ipairs(REQUIRED_SECTORS) do
                if horde:FindFirstChild("HordeSector_" .. id) then counts.hordeSectors += 1 end
            end
        end
    end
    for _ in pairs(auditedSourcePaths) do
        counts.distinctAuditedSourcePaths += 1
    end
    local artAssets = ReplicatedStorage:FindFirstChild("ArtAssets")
    counts.artAssetSourceModels = 0
    if artAssets then
        for _, child in ipairs(artAssets:GetChildren()) do
            if child:IsA("Model") then counts.artAssetSourceModels += 1 end
        end
    end
    if artAssets then
        for _, requiredName in ipairs(REQUIRED_ART_ASSETS) do
            if not artAssets:FindFirstChild(requiredName) then
                counts.missingRequiredAssets += 1
            end
        end
        local ok, AssetAuditService = pcall(function()
            return require(ReplicatedStorage.Shared.WorldV2.AssetAuditService)
        end)
        if ok and AssetAuditService then
            local auditCounts = AssetAuditService.Audit(artAssets)
            counts.auditScripts = auditCounts.scripts or 0
            counts.auditMeshParts = auditCounts.meshParts or 0
            counts.auditParts = auditCounts.parts or 0
            counts.auditSounds = auditCounts.sounds or 0
            counts.auditEmitters = auditCounts.emitters or 0
            counts.auditLights = auditCounts.lights or 0
            counts.auditDecals = auditCounts.decals or 0
            counts.auditSurfaceAppearances = auditCounts.surfaceAppearances or 0
        end
    else
        counts.missingRequiredAssets += #REQUIRED_ART_ASSETS
    end
    local liveWorld = Workspace:FindFirstChild("GTH_WorldV2")
    local shouldCountGlobalQuarantine = world ~= nil and world == liveWorld
    local serverStorage = shouldCountGlobalQuarantine and getServerStorage() or nil
    local quarantine = serverStorage and serverStorage:FindFirstChild("AssetQuarantine")
    if quarantine then
        for _, desc in ipairs(quarantine:GetDescendants()) do
            if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then counts.quarantinedScripts += 1 end
        end
    end
    return counts
end

function WorldValidation.Run()
    local errors = {}
    local world = Workspace:FindFirstChild("GTH_WorldV2")
    add(errors, world ~= nil, "Workspace.GTH_WorldV2 exists")
    if world then
        for _, rootName in ipairs(REQUIRED_ROOTS) do
            add(errors, world:FindFirstChild(rootName) ~= nil, "WorldV2 root missing: " .. rootName)
        end
        local vendorRing = world:FindFirstChild("VendorRing")
        add(errors, vendorRing ~= nil, "VendorRing exists")
        if vendorRing then
            for _, vendor in ipairs(REQUIRED_VENDORS) do
                local model = vendorRing:FindFirstChild(vendor)
                add(errors, model ~= nil, "Vendor missing: " .. vendor)
                add(errors, model and model:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil, "Vendor prompt missing: " .. vendor)
            end
        end
        local audience = world:FindFirstChild("AudienceRing") and world.AudienceRing:FindFirstChild("AudienceHypeManager")
        add(errors, audience ~= nil, "AudienceHypeManager exists")
        add(errors, audience and audience:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil, "AudienceHypeManager prompt exists")
        local artAssets = ReplicatedStorage:FindFirstChild("ArtAssets")
        add(errors, artAssets ~= nil, "ReplicatedStorage.ArtAssets exists")
        if artAssets then
            for _, requiredName in ipairs(REQUIRED_ART_ASSETS) do
                add(errors, artAssets:FindFirstChild(requiredName) ~= nil, "Required ArtAssets source missing: " .. requiredName)
            end
        end
        local hordeRing = world:FindFirstChild("HordeRing")
        add(errors, hordeRing ~= nil, "HordeRing exists")
        if hordeRing then
            for _, id in ipairs(REQUIRED_SECTORS) do
                local sector = hordeRing:FindFirstChild("HordeSector_" .. id)
                add(errors, sector ~= nil, "Horde sector missing: " .. id)
                if sector then
                    for _, childName in ipairs(REQUIRED_SECTOR_CHILDREN) do
                        add(errors, sector:FindFirstChild(childName) ~= nil, "Sector " .. id .. " missing " .. childName)
                    end
                    local hordeRoot = sector:FindFirstChild("HordeCluster")
                    add(errors, hordeRoot and hordeRoot:IsA("Model"), "HordeRoot is Model for sector " .. id)
                    if hordeRoot and hordeRoot:IsA("Model") then
                        local ok = pcall(function()
                            local cf = hordeRoot:GetPivot()
                            hordeRoot:PivotTo(cf)
                        end)
                        add(errors, ok, "HordeRoot:PivotTo works for " .. id)
                    end
                end
            end
        end
        for _, desc in ipairs(world:GetDescendants()) do
            add(errors, not (desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript")), "Script descendant under WorldV2: " .. desc:GetFullName())
            if desc:IsA("BillboardGui") then
                add(errors, desc.AlwaysOnTop == false, "BillboardGui AlwaysOnTop true: " .. desc:GetFullName())
                add(errors, desc.MaxDistance <= 40, "BillboardGui MaxDistance > 40: " .. desc:GetFullName())
            end
            if isVisibleBasePart(desc) and PLACEHOLDER_NAMES[desc.Name] and world:FindFirstChild("InvisibleGameplayHitboxes") and not desc:IsDescendantOf(world.InvisibleGameplayHitboxes) then
                add(errors, false, "Visible placeholder BasePart: " .. desc:GetFullName())
            end
            if isVisibleBasePart(desc) and desc:GetAttribute("RawFallbackArt") == true then
                add(errors, false, "Visible raw fallback art: " .. desc:GetFullName())
            end
        end
    end
    local counts = countActive(world)
    print("[WorldValidation] Active WorldV2 Models", counts.models)
    print("[WorldValidation] Active WorldV2 MeshParts", counts.meshParts)
    print("[WorldValidation] Active WorldV2 visible BaseParts", counts.visibleBaseParts)
    print("[WorldValidation] ArtAssets source models", counts.artAssetSourceModels)
    print("[WorldValidation] Active WorldV2 scripts", counts.activeWorldScripts)
    print("[WorldValidation] Quarantined scripts", counts.quarantinedScripts)
    print("[WorldValidation] Missing required assets", counts.missingRequiredAssets)
    print("[WorldValidation] Visible placeholder violations", counts.visiblePlaceholderViolations)
    print("[WorldValidation] Audit scripts", counts.auditScripts)
    print("[WorldValidation] Audit meshParts", counts.auditMeshParts)
    print("[WorldValidation] Audit parts", counts.auditParts)
    print("[WorldValidation] Audit sounds", counts.auditSounds)
    print("[WorldValidation] Audit emitters", counts.auditEmitters)
    print("[WorldValidation] Audit lights", counts.auditLights)
    print("[WorldValidation] Audit decals", counts.auditDecals)
    print("[WorldValidation] Audit SurfaceAppearances", counts.auditSurfaceAppearances)
    print("[AssetPlacementValidation] activePlacedArtInstances = " .. tostring(counts.activePlacedArtInstances))
    print("[AssetPlacementValidation] stageCore = " .. tostring(counts.stageCore))
    print("[AssetPlacementValidation] lightingAndTrusses = " .. tostring(counts.lightingAndTrusses))
    print("[AssetPlacementValidation] vendorRing = " .. tostring(counts.vendorRing))
    print("[AssetPlacementValidation] fenceRing = " .. tostring(counts.fenceRing))
    print("[AssetPlacementValidation] hordeRing = " .. tostring(counts.hordeRing))
    print("[AssetPlacementValidation] audienceRing = " .. tostring(counts.audienceRing))
    print("[AssetPlacementValidation] volcanoOuterRing = " .. tostring(counts.volcanoOuterRing))
    print("[AssetPlacementValidation] tourBusAndSpawn = " .. tostring(counts.tourBusAndSpawn))
    print("[AssetPlacementValidation] invisibleHitboxesExcluded = " .. tostring(counts.invisibleHitboxesExcluded))
    print("[AssetPlacementValidation] archivedObjectsExcluded = " .. tostring(counts.archivedObjectsExcluded))
    print("[AssetPlacementValidation] quarantinedObjectsExcluded = " .. tostring(counts.quarantinedObjectsExcluded))
    print("[AssetPlacementValidation] autogenBlankMeshesExcluded = " .. tostring(counts.autogenBlankMeshesExcluded))
    print("[AssetPlacementValidation] placeholderViolations = " .. tostring(counts.visiblePlaceholderViolations))
    print("[AssetPlacementValidation] scriptsUnderWorldV2 = " .. tostring(counts.activeWorldScripts))
    print("[AssetPlacementValidation] incorrectRingPlacements = " .. tostring(counts.incorrectRingPlacements))
    print("[AssetPlacementValidation] unauditedAssetPlacements = " .. tostring(counts.unauditedAssetPlacements))
    print("[AssetPlacementValidation] massBrainrotNPCs = " .. tostring(counts.massBrainrotNPCs))
    print("[AssetPlacementValidation] distinctAuditedSourcePaths = " .. tostring(counts.distinctAuditedSourcePaths))
    print("[AssetPlacementValidation] invalidAuditedSourcePaths = " .. tostring(counts.invalidAuditedSourcePaths))
    print("[AssetPlacementValidation] creatorMenuExpansionModelPlacements = " .. tostring(counts.creatorMenuExpansionModelPlacements))
    print("[AssetPlacementValidation] creatorMenuExpansionSourceFamilies = " .. tostring(counts.creatorMenuExpansionSourceFamilies))
    print("[AssetPlacementValidation] creatorMenuExpansionMissingSources = " .. tostring(counts.creatorMenuExpansionMissingSources))
    add(errors, counts.massBrainrotNPCs >= 500, "Mass brainrot horde NPC gate failed: requires 500 got " .. tostring(counts.massBrainrotNPCs))
    add(errors, counts.missingRequiredAssets == 0, "Missing required assets: " .. tostring(counts.missingRequiredAssets))
    for key, minimum in pairs(PLACEMENT_MINIMUMS) do
        add(errors, (counts[key] or 0) >= minimum, "Asset placement gate failed: " .. key .. " requires " .. tostring(minimum) .. " got " .. tostring(counts[key] or 0))
    end
    add(errors, counts.activeWorldScripts == 0, "Scripts under WorldV2: " .. tostring(counts.activeWorldScripts))
    add(errors, counts.invalidAuditedSourcePaths == 0, "Invalid audited source paths: " .. tostring(counts.invalidAuditedSourcePaths))
    add(errors, counts.unauditedAssetPlacements == 0, "Unaudited visible placements: " .. tostring(counts.unauditedAssetPlacements))
    add(errors, counts.autogenBlankMeshesExcluded == 0, "Autogen/blank/procedural placements excluded: " .. tostring(counts.autogenBlankMeshesExcluded))
    assert(#errors == 0, table.concat(errors, " | "))
    return { ok = true, counts = counts, errors = errors }
end

WorldValidation.CountActive = countActive
return WorldValidation
