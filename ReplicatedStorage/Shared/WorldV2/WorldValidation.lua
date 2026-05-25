local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local WorldValidation = {}

local REQUIRED_ROOTS = { "ArenaCore", "FenceRing", "VendorRing", "AudienceRing", "HordeRing", "OuterVolcanoRing", "InvisibleGameplayHitboxes", "CompatibilityAdapters" }
local REQUIRED_VENDORS = { "DJ_GroanMaster", "Vendor_Store", "Vendor_UpgradeEngineer", "MissionOfficer", "SecurityManager", "TutorialGuide" }
local REQUIRED_SECTORS = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }
local REQUIRED_SECTOR_CHILDREN = { "FenceSegment", "FenceDamageVFX", "SecurityLight", "SirenLight", "HordeCluster", "HordePressureMeter", "WeakPointMarker" }
local PLACEHOLDER_NAMES = { Part = true, Block = true, Circle = true, Cylinder = true, Temp = true, Debug = true }

local function add(errors, condition, message)
    if not condition then table.insert(errors, message) end
end

local function isVisibleBasePart(inst)
    return inst:IsA("BasePart") and inst.Transparency < 0.95
end

local function countActive(world)
    local counts = { models = 0, meshParts = 0, visibleBaseParts = 0, invisibleHitboxes = 0, quarantinedScripts = 0, vendorPrompts = 0, hordeSectors = 0, missingRequiredAssets = 0, visiblePlaceholderViolations = 0 }
    local hitboxes = world and world:FindFirstChild("InvisibleGameplayHitboxes")
    if world then
        for _, desc in ipairs(world:GetDescendants()) do
            if desc:IsA("Model") then counts.models += 1 end
            if desc:IsA("MeshPart") then counts.meshParts += 1 end
            if isVisibleBasePart(desc) then counts.visibleBaseParts += 1 end
            if hitboxes and desc:IsDescendantOf(hitboxes) and desc:IsA("BasePart") then counts.invisibleHitboxes += 1 end
            if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then counts.quarantinedScripts += 1 end
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
    local artAssets = ReplicatedStorage:FindFirstChild("ArtAssets")
    counts.artAssetSourceModels = artAssets and #artAssets:GetChildren() or 0
    local quarantine = game:GetService("ServerStorage"):FindFirstChild("AssetQuarantine")
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
            if isVisibleBasePart(desc) and PLACEHOLDER_NAMES[desc.Name] and not desc:IsDescendantOf(world.InvisibleGameplayHitboxes) then
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
    print("[WorldValidation] Quarantined scripts", counts.quarantinedScripts)
    print("[WorldValidation] Missing required assets", counts.missingRequiredAssets)
    print("[WorldValidation] Visible placeholder violations", counts.visiblePlaceholderViolations)
    assert(#errors == 0, table.concat(errors, " | "))
    return { ok = true, counts = counts, errors = errors }
end

WorldValidation.CountActive = countActive
return WorldValidation
