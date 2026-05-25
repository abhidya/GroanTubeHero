local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.WorldV2.WorldV2Config)
local PolarLayout = require(ReplicatedStorage.Shared.WorldV2.PolarLayout)
local Vendors = require(ReplicatedStorage.Shared.WorldV2.VendorDefinitions)
local Sectors = require(ReplicatedStorage.Shared.WorldV2.HordeSectorDefinitions)
local AssetAuditService = require(script.Parent.AssetAuditService)

local WorldV2Builder = {}

local function ensureFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then folder = Instance.new("Folder"); folder.Name = name; folder.Parent = parent end
    return folder
end

local function ensureModel(parent, name)
    local model = parent:FindFirstChild(name)
    if not model then model = Instance.new("Model"); model.Name = name; model.Parent = parent end
    return model
end

local function setPartProps(part, props)
    for k, v in pairs(props) do pcall(function() part[k] = v end) end
end

local function part(parent, name, size, cframe, color, material, shape)
    local p = parent:FindFirstChild(name)
    if not (p and p:IsA("BasePart")) then
        if p then p:Destroy() end
        p = Instance.new("Part")
        p.Name = name
        p.Parent = parent
    end
    p.Size = size
    p.CFrame = cframe
    p.Color = color or Color3.fromRGB(255, 255, 255)
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = true
    p.Transparency = 0
    if shape then p.Shape = shape end
    return p
end

local function invisible(parent, name, size, cframe, canCollide)
    local p = part(parent, name, size, cframe, Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
    p.Name = name:match("^InvisibleHitbox_") and name or "InvisibleHitbox_" .. name
    p.Transparency = 1
    p.CanCollide = canCollide == true
    return p
end

local function surfaceLabel(target, text, face)
    local gui = target:FindFirstChild("SurfaceLabel") or Instance.new("SurfaceGui")
    gui.Name = "SurfaceLabel"
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.15
    gui.PixelsPerStud = 56
    gui.Face = face or Enum.NormalId.Front
    gui.Parent = target
    local label = gui:FindFirstChild("Text") or Instance.new("TextLabel")
    label.Name = "Text"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Text = text
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextStrokeTransparency = 0.25
    label.Parent = gui
end


local function hideProceduralScaffoldWhenAuditedArtReady(world)
    local auditedCount = 0
    for _, desc in ipairs(world:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Transparency < 0.95 and desc:GetAttribute("AuditedArtAsset") == true then
            auditedCount += 1
        end
    end
    if auditedCount < 500 then return 0 end
    local hidden = 0
    for _, desc in ipairs(world:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Transparency < 0.95 and desc:GetAttribute("AuditedArtAsset") ~= true then
            desc.Transparency = 1
            desc.CanCollide = false
            hidden += 1
        end
    end
    world:SetAttribute("HiddenProceduralScaffoldParts", hidden)
    return hidden
end

local function prompt(anchor, action, objectText, menuName)
    local pr = anchor:FindFirstChildOfClass("ProximityPrompt") or Instance.new("ProximityPrompt")
    pr.Name = "ProximityPrompt"
    pr.ActionText = action
    pr.ObjectText = objectText
    pr.HoldDuration = 0.15
    pr.MaxActivationDistance = 18
    pr.RequiresLineOfSight = false
    pr:SetAttribute("MenuName", menuName or objectText)
    pr.Parent = anchor
    return pr
end

local function disableArchivedVisuals(inst)
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Transparency = 1
            d.CanCollide = false
            d.Anchored = true
        elseif d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            d.Enabled = false
        elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") or d:IsA("SurfaceLight") or d:IsA("PointLight") or d:IsA("SpotLight") then
            d.Enabled = false
        end
    end
end

function WorldV2Builder.EnsureAssetRoots()
    local roots = AssetAuditService.EnsureRoots()
    local kit = roots.ArtAssets:FindFirstChild("WorldV2_SafeProceduralKit") or Instance.new("Model")
    kit.Name = "WorldV2_SafeProceduralKit"
    kit:SetAttribute("AssetSource", "project-owned procedural; no Creator Store IDs")
    kit:SetAttribute("ScriptsQuarantined", 0)
    kit.Parent = roots.ArtAssets
    return roots
end

function WorldV2Builder.ArchiveOldWorld()
    ensureFolder(ServerStorage, "WorldArchive")
    ensureFolder(Workspace, "__WorldArchive_DoNotDelete")
    local archived = {}
    for _, name in ipairs({ "ImportedArenaAssets", "TourBus" }) do
        local inst = Workspace:FindFirstChild(name)
        if inst then
            disableArchivedVisuals(inst)
            inst:SetAttribute("WorldV2ArchiveReason", "Known V1/prototype visual replaced by Workspace.GTH_WorldV2")
            inst.Parent = ServerStorage.WorldArchive
            table.insert(archived, { oldPath = "Workspace." .. name, archivePath = "ServerStorage.WorldArchive." .. name, reason = "known V1/prototype visual" })
        end
    end
    local stage = Workspace:FindFirstChild("Stage")
    if stage then
        local keep = { StartPrompt = true, StoreKiosk = true, UpgradeKiosk = true, MissionBoard = true, AudienceZone = true, BrainrotHorde = true }
        for _, child in ipairs(stage:GetChildren()) do
            if child:IsA("BasePart") or child:IsA("Model") or child:IsA("Folder") then
                if not keep[child.Name] and child.Name ~= "CompatibilityOnly" then
                    disableArchivedVisuals(child)
                    child:SetAttribute("WorldV2ArchiveReason", "Known V1 Stage visual replaced by WorldV2")
                    child.Parent = ServerStorage.WorldArchive
                    table.insert(archived, { oldPath = "Workspace.Stage." .. child.Name, archivePath = "ServerStorage.WorldArchive." .. child.Name, reason = "known V1 Stage visual" })
                end
            end
        end
    end
    return archived
end

function WorldV2Builder.Build()
    WorldV2Builder.EnsureAssetRoots()
    local world = Workspace:FindFirstChild(Config.RootName)
    if not (world and world:IsA("Model")) then
        if world then world:Destroy() end
        world = Instance.new("Model")
        world.Name = Config.RootName
        world.Parent = Workspace
    end
    world:SetAttribute("CoordinateConvention", Config.CoordinateConvention)
    world:SetAttribute("AssetPolicy", "Audited ArtAssets or local Studio candidates only; no hardcoded Creator Store IDs")

    local roots = {}
    for _, name in ipairs(Config.RootFolders) do roots[name] = ensureFolder(world, name) end

    -- Center/stage rings. Intentional stylized procedural kit, not fallback placeholders.
    local disc = part(roots.ArenaCore, "CursedConcertDisc", Vector3.new(36, 1.2, 36), CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(38, 36, 52), Enum.Material.Slate, Enum.PartType.Cylinder)
    disc:SetAttribute("WorldV2Art", true)
    part(roots.StageCircle, "NeonPerformanceCircle", Vector3.new(18, 0.4, 18), CFrame.new(0, 1.35, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(80, 225, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
    part(roots.InnerPlayerRing, "PlayerWalkwayRing", Vector3.new(58, 0.35, 58), CFrame.new(0, 1.05, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(30, 95, 80), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)

    invisible(roots.InvisibleGameplayHitboxes, "SingerSpot", Vector3.new(8, 5, 8), CFrame.new(0, 4, 0), false)
    invisible(roots.InvisibleGameplayHitboxes, "AudienceZone", Vector3.new(96, 14, 96), CFrame.new(0, 5, 0), false)
    invisible(roots.InvisibleGameplayHitboxes, "AntiFallBarrier_N", Vector3.new(220, 60, 4), CFrame.new(0, 25, 160), true)
    invisible(roots.InvisibleGameplayHitboxes, "AntiFallBarrier_S", Vector3.new(220, 60, 4), CFrame.new(0, 25, -160), true)
    invisible(roots.InvisibleGameplayHitboxes, "AntiFallBarrier_E", Vector3.new(4, 60, 220), CFrame.new(160, 25, 0), true)
    invisible(roots.InvisibleGameplayHitboxes, "AntiFallBarrier_W", Vector3.new(4, 60, 220), CFrame.new(-160, 25, 0), true)

    local spawn = world:FindFirstChild("SpawnLocation") or Instance.new("SpawnLocation")
    spawn.Name = "SpawnLocation"
    spawn.Anchored = true
    spawn.CanCollide = true
    spawn.Transparency = 0
    spawn.Size = Vector3.new(10, 1, 10)
    spawn.Material = Enum.Material.Neon
    spawn.Color = Color3.fromRGB(80, 225, 255)
    spawn.CFrame = CFrame.new(0, 2, -38)
    spawn.Parent = world

    for _, point in ipairs(PolarLayout.distribute(32, 54, 3.2, 0)) do
        part(roots.FenceRing, "FenceArcSegment_" .. point.index, Vector3.new(7, 5, 0.8), point.cframeFacingCenter, Color3.fromRGB(95, 255, 120), Enum.Material.Metal)
    end

    for _, def in ipairs(Vendors) do
        local parent = roots[def.Root]
        local model = ensureModel(parent, def.Id)
        local cf = PolarLayout.cframeFacingCenter(def.Radius, def.Angle, 2.5)
        local plinth = part(model, "StationPlinth", Vector3.new(7, 1.2, 5), cf, def.Color, Enum.Material.SmoothPlastic)
        local body = part(model, "NpcBody", Vector3.new(2.2, 5, 1.5), cf * CFrame.new(0, 3.1, 0), def.Color:Lerp(Color3.new(1,1,1), 0.18), Enum.Material.Neon)
        part(model, "NpcHead", Vector3.new(1.8, 1.8, 1.8), cf * CFrame.new(0, 6.1, 0), Color3.fromRGB(255, 225, 170), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        local sign = part(model, "MenuSurfaceSign", Vector3.new(6.5, 3, 0.35), cf * CFrame.new(0, 4.4, -2.8), def.Color, Enum.Material.Neon)
        surfaceLabel(sign, def.Menu, Enum.NormalId.Front)
        local anchor = invisible(model, "PromptAnchor", Vector3.new(5, 6, 5), cf * CFrame.new(0, 3, 0), false)
        prompt(anchor, def.Prompt, def.Menu, def.Menu)
        model.PrimaryPart = plinth
        body:SetAttribute("FacesCenter", true)
    end

    for _, sectorDef in ipairs(Sectors) do
        local sector = ensureFolder(roots.HordeRing, "HordeSector_" .. sectorDef.Id)
        sector:SetAttribute("SectorId", sectorDef.Id)
        sector:SetAttribute("AngleDeg", sectorDef.Angle)
        sector:SetAttribute("Health", sector:GetAttribute("Health") or 100)
        local cf = PolarLayout.cframeFacingCenter(54, sectorDef.Angle, 3)
        local fence = part(sector, "FenceSegment", Vector3.new(13, 5, 1), cf, Color3.fromRGB(95, 255, 120), Enum.Material.Metal)
        local vfx = part(sector, "FenceDamageVFX", Vector3.new(10, 0.4, 0.4), cf * CFrame.new(0, 2.9, -0.7), Color3.fromRGB(255, 80, 40), Enum.Material.Neon)
        vfx.Transparency = 0.55
        local security = part(sector, "SecurityLight", Vector3.new(1.2, 1.2, 1.2), cf * CFrame.new(-4.8, 3.8, -1), Color3.fromRGB(150, 220, 255), Enum.Material.Neon, Enum.PartType.Ball)
        local secLight = security:FindFirstChildOfClass("PointLight") or Instance.new("PointLight"); secLight.Range = 18; secLight.Brightness = 1.2; secLight.Color = security.Color; secLight.Parent = security
        local siren = part(sector, "SirenLight", Vector3.new(1.5, 1.5, 1.5), cf * CFrame.new(4.8, 3.8, -1), Color3.fromRGB(255, 35, 35), Enum.Material.Neon, Enum.PartType.Ball)
        local sirenLight = siren:FindFirstChildOfClass("PointLight") or Instance.new("PointLight"); sirenLight.Range = 20; sirenLight.Brightness = 0; sirenLight.Color = siren.Color; sirenLight.Parent = siren
        local horde = ensureModel(sector, "HordeCluster")
        for i = 1, 5 do
            local creep = part(horde, "HordeFigure_" .. sectorDef.Id .. "_" .. i, Vector3.new(1.7, 3.6 + (i % 2), 1.7), PolarLayout.cframeFacingCenter(68 + (i % 2) * 3, sectorDef.Angle, 3) * CFrame.new((i - 3) * 2.4, 0, 0), Color3.fromRGB(90, 255, 90), Enum.Material.Neon)
            creep.CanCollide = false
        end
        horde.PrimaryPart = horde.PrimaryPart or horde:FindFirstChildWhichIsA("BasePart", true)
        local meter = part(sector, "HordePressureMeter", Vector3.new(8, 1.1, 0.6), cf * CFrame.new(0, -2.7, -1.2), Color3.fromRGB(255, 230, 90), Enum.Material.Neon)
        meter:SetAttribute("Pressure", 0)
        part(sector, "WeakPointMarker", Vector3.new(2.2, 2.2, 0.5), cf * CFrame.new(0, 0.7, -1.25), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
        prompt(invisible(sector, "RepairPromptAnchor", Vector3.new(5, 6, 5), cf * CFrame.new(0, 2, -4), false), "Repair Fence", "Sector " .. sectorDef.Id, "Security")
    end

    for _, point in ipairs(PolarLayout.distribute(24, 92, 4, 7.5)) do
        local crowd = part(roots.AudienceRing, "CrowdSilhouette_" .. point.index, Vector3.new(1.5, 4 + (point.index % 2), 1.5), point.cframeFacingCenter, Color3.fromRGB(75, 255, 120), Enum.Material.Neon)
        crowd.CanCollide = false
    end
    for _, point in ipairs(PolarLayout.distribute(16, 126, 12, 11.25)) do
        local cliff = part(roots.VolcanoOuterRing, "VolcanicCliff_" .. point.index, Vector3.new(11, 22 + (point.index % 3) * 5, 8), point.cframeFacingCenter, Color3.fromRGB(105, 45, 30), Enum.Material.CrackedLava)
        cliff.CanCollide = false
        cliff.Parent = roots.VolcanoOuterRing
        local also = roots.OuterVolcanoRing:FindFirstChild(cliff.Name) or cliff:Clone()
        also.Parent = roots.OuterVolcanoRing
    end
    local atmosphere = Lighting:FindFirstChild("WorldV2ToxicAtmosphere") or Instance.new("Atmosphere")
    atmosphere.Name = "WorldV2ToxicAtmosphere"
    atmosphere.Density = 0.45
    atmosphere.Haze = 2.2
    atmosphere.Color = Color3.fromRGB(160, 225, 120)
    atmosphere.Decay = Color3.fromRGB(90, 45, 25)
    atmosphere.Parent = Lighting

    local compat = ensureFolder(world, "CompatibilityAdapters")
    local stage = ensureFolder(Workspace, "Stage")
    stage:SetAttribute("CompatibilityOnly", true)
    local aliases = {
        StartPrompt = roots.VendorRing.DJ_GroanMaster,
        StoreKiosk = roots.VendorRing.Vendor_Store,
        UpgradeKiosk = roots.VendorRing.Vendor_UpgradeEngineer,
        MissionBoard = roots.VendorRing.MissionOfficer,
        AudienceZone = roots.InvisibleGameplayHitboxes:FindFirstChild("InvisibleHitbox_AudienceZone"),
    }
    for name, target in pairs(aliases) do
        local ref = stage:FindFirstChild(name) or Instance.new("ObjectValue")
        if not ref:IsA("ObjectValue") then ref:Destroy(); ref = Instance.new("ObjectValue") end
        ref.Name = name
        ref.Value = target
        ref.Parent = stage
        local compatRef = compat:FindFirstChild(name) or Instance.new("ObjectValue")
        compatRef.Name = name
        compatRef.Value = target
        compatRef.Parent = compat
    end
    local brainrot = ensureFolder(stage, "BrainrotHorde")
    local rootRef = brainrot:FindFirstChild("HordeRoot") or Instance.new("ObjectValue")
    rootRef.Name = "HordeRoot"
    rootRef.Value = roots.HordeRing.HordeSector_N.HordeCluster
    rootRef.Parent = brainrot

    hideProceduralScaffoldWhenAuditedArtReady(world)
    return world
end

function WorldV2Builder.RunValidation(options)
    options = options or {}
    local result = require(ReplicatedStorage.Shared.WorldV2.WorldValidation).Run()
    if options.PrintSummary ~= false then
        print("[WorldV2Builder] validation ok", result.ok)
    end
    return result
end

return WorldV2Builder
