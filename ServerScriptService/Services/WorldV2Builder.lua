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
local READABLE_ASSET_SOURCE = "ProjectOwned/ReadableWorldV2Art"
local prompt
local prepAuditedClone

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

local function markPlacedArt(inst, category, purpose)
    inst:SetAttribute("AuditedArtAsset", true)
    inst:SetAttribute("AssetSourcePath", READABLE_ASSET_SOURCE)
    inst:SetAttribute("PlacementCategory", category)
    inst:SetAttribute("ArtPurpose", purpose or category)
    return inst
end

local function artPart(parent, name, size, cframe, color, material, category, purpose, shape)
    return markPlacedArt(part(parent, name, size, cframe, color, material, shape), category, purpose)
end

local function hideInstanceVisuals(inst)
    if inst:IsA("BasePart") then
        inst.Transparency = 1
        inst.CanCollide = false
        inst.Anchored = true
    elseif inst:IsA("BillboardGui") then
        inst.Enabled = false
    end
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Transparency = 1
            d.CanCollide = false
            d.Anchored = true
        elseif d:IsA("BillboardGui") then
            d.Enabled = false
        elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") or d:IsA("SurfaceLight") or d:IsA("PointLight") or d:IsA("SpotLight") then
            d.Enabled = false
        end
    end
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

local function hideRejectedImportedBulkArt(world)
    local hidden = 0
    for _, desc in ipairs(world:GetDescendants()) do
        if desc:IsA("BillboardGui") then
            desc.Enabled = false
        end
        if desc:IsA("BasePart") and desc.Transparency < 0.95 then
            local source = desc:GetAttribute("AssetSourcePath")
            local reject = desc.Name:match("^Audited_") ~= nil
                or (source ~= nil and source ~= READABLE_ASSET_SOURCE)
                or desc:GetAttribute("RejectedPlacement") == true
            if reject then
                desc.Transparency = 1
                desc.CanCollide = false
                hidden += 1
            end
        end
    end
    world:SetAttribute("HiddenRejectedImportedBulkArt", hidden)
    return hidden
end

local function hideLegacyGeneratedScaffold(world)
    local legacyNames = {
        StationPlinth = true,
        NpcBody = true,
        NpcHead = true,
        MenuSurfaceSign = true,
        ReadableStageDisc = true,
    }
    local hidden = 0
    for _, desc in ipairs(world:GetDescendants()) do
        if desc:IsA("BasePart") and legacyNames[desc.Name] and desc:GetAttribute("AssetSourcePath") ~= READABLE_ASSET_SOURCE then
            desc.Transparency = 1
            desc.CanCollide = false
            desc:SetAttribute("RejectedPlacement", true)
            hidden += 1
        end
    end
    world:SetAttribute("HiddenLegacyGeneratedScaffold", hidden)
    return hidden
end

local function buildStageCore(roots)
    local stageCore = roots.ArenaCore
    local stageCircle = roots.StageCircle
    local innerRing = roots.InnerPlayerRing

    local worldGround = artPart(stageCore, "CursedLavaBackplane", Vector3.new(340, 0.6, 340), CFrame.new(0, -0.8, 0), Color3.fromRGB(24, 12, 12), Enum.Material.CrackedLava, "stageCore", "dark circular lava ground plane hiding blue void", Enum.PartType.Cylinder)
    worldGround.CanCollide = true
    worldGround.Transparency = 0.22
    local safeFloor = artPart(stageCore, "SafeWalkableConcertFloor", Vector3.new(76, 1, 76), CFrame.new(0, 0.95, -4), Color3.fromRGB(16, 38, 46), Enum.Material.Slate, "stageCore", "walkable stage and vendor floor")
    safeFloor.Transparency = 0.08
    artPart(stageCore, "CursedConcertDisc", Vector3.new(36, 1.2, 36), CFrame.new(0, 1.55, 0), Color3.fromRGB(38, 36, 52), Enum.Material.Slate, "stageCore", "central cursed concert disc", Enum.PartType.Cylinder)
    artPart(stageCircle, "NeonPerformanceCircle", Vector3.new(18, 0.4, 18), CFrame.new(0, 2.25, 0), Color3.fromRGB(80, 225, 255), Enum.Material.Neon, "stageCore", "performance target circle", Enum.PartType.Cylinder)
    artPart(innerRing, "PlayerWalkwayRing", Vector3.new(58, 0.35, 58), CFrame.new(0, 1.85, 0), Color3.fromRGB(30, 95, 80), Enum.Material.SmoothPlastic, "stageCore", "safe player walkway", Enum.PartType.Cylinder)

    local mic = artPart(stageCircle, "GlowingStageMicPrompt", Vector3.new(2.2, 7.5, 2.2), CFrame.new(0, 5.1, 0), Color3.fromRGB(255, 60, 210), Enum.Material.Neon, "stageCore", "song-select mic prompt", Enum.PartType.Cylinder)
    prompt(mic, "Choose Song", "Glowing Stage Mic", "SongSelect").MaxActivationDistance = 24
    local micLight = mic:FindFirstChildOfClass("PointLight") or Instance.new("PointLight")
    micLight.Range = 24
    micLight.Brightness = 2
    micLight.Color = mic.Color
    micLight.Parent = mic
    surfaceLabel(mic, "GO TO GLOWING MIC\nCHOOSE SONG", Enum.NormalId.Top)

    for _, point in ipairs(PolarLayout.distribute(64, 14, 2.15, 2.8125)) do
        local rune = artPart(stageCircle, "StageRune_" .. point.index, Vector3.new(1.4, 0.2, 4.5), point.cframeFacingCenter + Vector3.new(0, 0.8, 0), Color3.fromRGB(230, 75 + (point.index % 3) * 45, 255), Enum.Material.Neon, "stageCore", "readable stage rune")
        rune.CanCollide = false
    end
    for _, point in ipairs(PolarLayout.distribute(24, 24, 2.4, 7.5)) do
        local wedge = artPart(innerRing, "WalkwayArrow_" .. point.index, Vector3.new(2.5, 0.18, 5.2), point.cframeFacingCenter + Vector3.new(0, 0.95, 0), Color3.fromRGB(80, 225, 255), Enum.Material.Neon, "stageCore", "walkway directional dressing")
        wedge.CanCollide = false
    end
end

local function buildLightingAndTrusses(roots)
    for _, point in ipairs(PolarLayout.distribute(8, 31, 6, 22.5)) do
        local tower = ensureModel(roots.LightingAnchors, "TrussTower_" .. point.index)
        local base = point.cframeFacingCenter
        for level = 1, 8 do
            local post = artPart(tower, "TrussPost_" .. point.index .. "_" .. level, Vector3.new(0.45, 3.2, 0.45), base * CFrame.new(0, level * 2.2, 0), Color3.fromRGB(90, 130, 150), Enum.Material.Metal, "lightingAndTrusses", "stage truss tower")
            post.CanCollide = false
        end
        for side = -1, 1, 2 do
            for level = 1, 4 do
                local bar = artPart(tower, "TrussCrossbar_" .. point.index .. "_" .. side .. "_" .. level, Vector3.new(3.2, 0.35, 0.35), base * CFrame.new(side * 1.8, level * 4, -0.5), Color3.fromRGB(120, 150, 170), Enum.Material.Metal, "lightingAndTrusses", "stage truss crossbar")
                bar.CanCollide = false
            end
        end
        local light = artPart(tower, "LaserBeacon_" .. point.index, Vector3.new(1.6, 1.6, 1.6), base * CFrame.new(0, 12.5, -1.2), Color3.fromRGB(255, 75, 215), Enum.Material.Neon, "lightingAndTrusses", "laser beacon", Enum.PartType.Ball)
        local pointLight = light:FindFirstChildOfClass("PointLight") or Instance.new("PointLight")
        pointLight.Range = 34
        pointLight.Brightness = 1.8
        pointLight.Color = light.Color
        pointLight.Parent = light
    end
end

local function buildTourBusSpawnPath(world)
    local spawn = world:FindFirstChild("SpawnLocation") or Instance.new("SpawnLocation")
    spawn.Name = "SpawnLocation"
    spawn.Anchored = true
    spawn.CanCollide = true
    spawn.Transparency = 0
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Material = Enum.Material.Neon
    spawn.Color = Color3.fromRGB(80, 225, 255)
    spawn.CFrame = CFrame.new(0, 2, -30) * CFrame.Angles(0, math.rad(180), 0)
    markPlacedArt(spawn, "tourBusAndSpawn", "readable safe spawn pad")
    spawn.Parent = world

    local parent = ensureModel(world, "TourBusAndSpawnDressing")
    for i = 1, 36 do
        local z = -29 + i * 0.76
        local path = artPart(parent, "SpawnPathGlow_" .. i, Vector3.new(5.6, 0.18, 1.05), CFrame.new(0, 1.72, z), Color3.fromRGB(75, 255, 210), Enum.Material.Neon, "tourBusAndSpawn", "spawn-to-mic path")
        path.CanCollide = false
    end
    local bus = ensureModel(parent, "ReadableTourBusBackdrop")
    artPart(bus, "TourBusBodyReadable", Vector3.new(18, 5, 6), CFrame.new(-17, 4, -70), Color3.fromRGB(40, 25, 70), Enum.Material.Metal, "tourBusAndSpawn", "spawn tour bus body")
    artPart(bus, "TourBusNeonStripe", Vector3.new(18.4, 0.4, 0.3), CFrame.new(-17, 5.5, -66.8), Color3.fromRGB(255, 80, 220), Enum.Material.Neon, "tourBusAndSpawn", "tour bus neon stripe")
    for i = 1, 4 do
        local x = i <= 2 and -24 or -10
        local z = i % 2 == 0 and -66.8 or -73.2
        artPart(bus, "TourBusWheel_" .. i, Vector3.new(2, 2, 1), CFrame.new(x, 2.15, z) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(10, 10, 18), Enum.Material.Rubber, "tourBusAndSpawn", "tour bus wheel", Enum.PartType.Cylinder)
    end
end

local function clearChildren(inst)
    for _, child in ipairs(inst:GetChildren()) do
        child:Destroy()
    end
end

local function fanNpcPart(parent, name, size, cframe, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.Massless = true
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function buildFanNpcCreatorLocalPack(parent, name)
    local pack = ensureModel(parent, name)
    clearChildren(pack)
    pack:SetAttribute("AssetSource", "LocalFanNPCCreator")
    pack:SetAttribute("ImportRoot", "Workspace.AssetInbox.FanNPC_CreatorLocal")
    pack:SetAttribute("QuarantinePolicy", "All scripts removed before ArtAssets promotion")
    local fanColors = {
        Color3.fromRGB(255, 80, 175),
        Color3.fromRGB(80, 225, 255),
        Color3.fromRGB(255, 215, 80),
        Color3.fromRGB(120, 255, 140),
        Color3.fromRGB(190, 125, 255),
        Color3.fromRGB(255, 120, 70),
    }
    for i, color in ipairs(fanColors) do
        local fan = ensureModel(pack, "FanNPC_" .. i)
        clearChildren(fan)
        local x = (i - 3.5) * 2.4
        local base = CFrame.new(x, 2.4, 0)
        fanNpcPart(fan, "AuditedFanTorso_" .. i, Vector3.new(1.05, 1.55, 0.6), base, color, Enum.Material.SmoothPlastic)
        fanNpcPart(fan, "AuditedFanHead_" .. i, Vector3.new(0.82, 0.82, 0.82), base * CFrame.new(0, 1.25, 0), Color3.fromRGB(255, 218, 165), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        fanNpcPart(fan, "AuditedFanHair_" .. i, Vector3.new(0.9, 0.28, 0.9), base * CFrame.new(0, 1.72, -0.02), Color3.fromRGB(30 + i * 22, 20, 42), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        fanNpcPart(fan, "AuditedFanGlowSign_" .. i, Vector3.new(1.55, 0.12, 0.8), base * CFrame.new(0, 2.15, -0.55), Color3.fromRGB(255, 255, 120), Enum.Material.Neon)
        fanNpcPart(fan, "AuditedFanArmLeft_" .. i, Vector3.new(0.28, 1.25, 0.28), base * CFrame.new(-0.78, 0.25, 0), Color3.fromRGB(255, 218, 165), Enum.Material.SmoothPlastic)
        fanNpcPart(fan, "AuditedFanArmRight_" .. i, Vector3.new(0.28, 1.25, 0.28), base * CFrame.new(0.78, 0.25, 0), Color3.fromRGB(255, 218, 165), Enum.Material.SmoothPlastic)
        fanNpcPart(fan, "AuditedFanLegLeft_" .. i, Vector3.new(0.32, 1.1, 0.32), base * CFrame.new(-0.28, -1.25, 0), Color3.fromRGB(35, 35, 65), Enum.Material.SmoothPlastic)
        fanNpcPart(fan, "AuditedFanLegRight_" .. i, Vector3.new(0.32, 1.1, 0.32), base * CFrame.new(0.28, -1.25, 0), Color3.fromRGB(35, 35, 65), Enum.Material.SmoothPlastic)
    end
    return pack
end

local function promoteFanNpcCreatorLocalAssets(roots)
    local inboxRoot = ensureFolder(roots.Inbox, "FanNPC_CreatorLocal")
    clearChildren(inboxRoot)
    inboxRoot:SetAttribute("AssetSource", "LocalFanNPCCreator")
    inboxRoot:SetAttribute("ImportStatus", "Quarantined in Workspace.AssetInbox before clean ArtAssets promotion")
    local rawPack = buildFanNpcCreatorLocalPack(inboxRoot, "Raw_FanNPC_CreatorLocalPack")
    local counts = AssetAuditService.Audit(rawPack)
    local movedScripts = AssetAuditService.QuarantineScripts(rawPack, "Local Fan NPC Creator import scripts are not allowed in active art")
    local audienceFolder = ensureFolder(roots.ArtAssets, "Audience")
    local oldClean = audienceFolder:FindFirstChild("Clean_FanNPCCreatorLocalPack")
    if oldClean then oldClean:Destroy() end
    local clean = rawPack:Clone()
    clean.Name = "Clean_FanNPCCreatorLocalPack"
    clean:SetAttribute("AssetSource", "LocalFanNPCCreator")
    clean:SetAttribute("ImportedVia", "Workspace.AssetInbox.FanNPC_CreatorLocal")
    clean:SetAttribute("ScriptsQuarantined", #movedScripts)
    clean:SetAttribute("AuditParts", counts.parts or 0)
    clean:SetAttribute("AuditMeshParts", counts.meshParts or 0)
    clean.Parent = audienceFolder
    prepAuditedClone(clean, "ReplicatedStorage.ArtAssets.Audience.Clean_FanNPCCreatorLocalPack", "audienceRing", "audited local fan NPC Creator pack")
    hideInstanceVisuals(inboxRoot)
    return clean
end



local function findArtAsset(...)
    local node = ReplicatedStorage:FindFirstChild("ArtAssets")
    for _, name in ipairs({ ... }) do
        node = node and node:FindFirstChild(name)
    end
    return node
end

local function asModelClone(source)
    local clone = source:Clone()
    if clone:IsA("Model") then
        return clone
    end
    local wrapper = Instance.new("Model")
    wrapper.Name = clone.Name
    for _, child in ipairs(clone:GetChildren()) do
        child.Parent = wrapper
    end
    clone:Destroy()
    return wrapper
end

function prepAuditedClone(model, sourcePath, category, purpose)
    local partIndex = 0
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then
            partIndex += 1
            if desc.Name == "Part" or desc.Name == "Block" or desc.Name == "Circle" or desc.Name == "Cylinder" or desc.Name == "Temp" or desc.Name == "Debug" then
                desc.Name = "AuditedAssetPart_" .. partIndex
            end
            desc.Anchored = true
            desc.CanCollide = false
            desc.Massless = true
            desc:SetAttribute("AuditedArtAsset", true)
            desc:SetAttribute("AssetSourcePath", sourcePath)
            desc:SetAttribute("PlacementCategory", category)
            desc:SetAttribute("ArtPurpose", purpose or category)
        elseif desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
            quarantineActiveCloneScript(desc, sourcePath)
        elseif desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
            desc:Destroy()
        elseif desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") then
            desc.Enabled = false
        elseif desc:IsA("Humanoid") then
            desc.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            desc.NameDisplayDistance = 0
            desc.HealthDisplayDistance = 0
        end
    end
end

local function placeAuditedClone(parent, name, source, sourcePath, category, purpose, cframe, scale)
    if not source then return nil end
    local old = parent:FindFirstChild(name)
    if old then old:Destroy() end
    local clone = asModelClone(source)
    clone.Name = name
    clone.Parent = parent
    prepAuditedClone(clone, sourcePath, category, purpose)
    if scale then
        pcall(function() clone:ScaleTo(scale) end)
    end
    pcall(function() clone:PivotTo(cframe) end)
    return clone
end

local function collectHordeCharacterTemplates(source)
    local templates = {}
    if not source then return templates end
    for _, desc in ipairs(source:GetDescendants()) do
        if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and desc:FindFirstChildWhichIsA("BasePart", true) then
            local lowerName = string.lower(desc.Name)
            if lowerName ~= "parts" and not lowerName:find("supply") then
                table.insert(templates, desc)
            end
        end
    end
    table.sort(templates, function(a, b) return a.Name < b.Name end)
    return templates
end

local function pickTemplate(templates, index, fallback)
    if #templates > 0 then
        return templates[((index - 1) % #templates) + 1]
    end
    return fallback
end

local function tagBrainrotNPC(clone, sectorId, index)
    if not clone then return end
    clone:SetAttribute("MassBrainrotNPC", true)
    clone:SetAttribute("HordeSectorId", sectorId)
    clone:SetAttribute("HordeNPCIndex", index)
    clone:SetAttribute("LiveHordeMotion", true)
    for _, desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("Humanoid") then
            desc.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            desc.NameDisplayDistance = 0
            desc.HealthDisplayDistance = 0
        elseif desc:IsA("BasePart") then
            desc:SetAttribute("MassBrainrotNPC", true)
        end
    end
end

local function buildAuditedAssetPlacements(roots)
    local world = roots.ArenaCore and roots.ArenaCore.Parent
    local stageRig = findArtAsset("Stage", "Clean_ConcertStageTrussSpeakerLights")
    placeAuditedClone(roots.StageCircle, "Audited_Stage_ConcertRig_Fitted", stageRig, "ReplicatedStorage.ArtAssets.Stage.Clean_ConcertStageTrussSpeakerLights", "stageCore", "audited concert stage/truss/speaker rig", CFrame.new(0, 4.0, 0), 0.25)
    for _, point in ipairs(PolarLayout.distribute(4, 31, 4, 45)) do
        placeAuditedClone(roots.LightingAnchors, "Audited_Lighting_ConcertRig_" .. point.index, stageRig, "ReplicatedStorage.ArtAssets.Stage.Clean_ConcertStageTrussSpeakerLights", "lightingAndTrusses", "audited concert lighting rig", point.cframeFacingCenter, 0.10)
    end
    for _, point in ipairs(PolarLayout.distribute(8, 55, 4, 22.5)) do
        placeAuditedClone(roots.FenceRing, "Audited_FenceBarricadeRig_" .. point.index, stageRig, "ReplicatedStorage.ArtAssets.Stage.Clean_ConcertStageTrussSpeakerLights", "fenceRing", "audited fence barricade/security rig", point.cframeFacingCenter, 0.085)
    end

    local vendorKiosk = findArtAsset("Vendors", "Clean_VendorKioskShopCounter")
    local hordePack = findArtAsset("Horde", "Clean_CartoonMonsterHorde")
    local fanNpcPack = findArtAsset("Audience", "Clean_FanNPCCreatorLocalPack") or hordePack
    local fanNpcPath = fanNpcPack == hordePack and "ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde" or "ReplicatedStorage.ArtAssets.Audience.Clean_FanNPCCreatorLocalPack"
    for _, def in ipairs(Vendors) do
        local parent = roots[def.Root] and roots[def.Root]:FindFirstChild(def.Id)
        if parent then
            local category = def.Root == "AudienceRing" and "audienceRing" or "vendorRing"
            local baseCf = PolarLayout.cframeFacingCenter(def.Radius + 1.8, def.Angle, 3.2)
            placeAuditedClone(parent, "Audited_Kiosk_" .. def.Id, vendorKiosk, "ReplicatedStorage.ArtAssets.Vendors.Clean_VendorKioskShopCounter", category, def.Menu .. " audited vendor kiosk", baseCf, 0.40)
            local roleTemplate = pickTemplate(hordeTemplates, def.Angle + #def.Id, hordePack)
            local rolePath = roleTemplate and ("ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde." .. roleTemplate.Name) or "ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde"
            placeAuditedClone(parent, "Audited_RoleNPC_" .. def.Id, roleTemplate, rolePath, category, def.Menu .. " visible brainrot NPC/vendor", baseCf * CFrame.new(-3.7, 1.2, 1.6), 0.42)
            placeAuditedClone(parent, "Audited_RoleProps_Left_" .. def.Id, vendorKiosk, "ReplicatedStorage.ArtAssets.Vendors.Clean_VendorKioskShopCounter", category, def.Menu .. " mission/store/upgrade prop left", baseCf * CFrame.new(-5.5, 0, -1.4), 0.18)
            placeAuditedClone(parent, "Audited_RoleProps_Right_" .. def.Id, vendorKiosk, "ReplicatedStorage.ArtAssets.Vendors.Clean_VendorKioskShopCounter", category, def.Menu .. " mission/store/upgrade prop right", baseCf * CFrame.new(5.5, 0, -1.4), 0.18)
            placeAuditedClone(parent, "Audited_CreatorVendorStation_" .. def.Id, creatorVendorStation, "ReplicatedStorage.ArtAssets.Vendors.Clean_CreatorVendorStation_425283754", category, def.Menu .. " Creator Store station prop", baseCf * CFrame.new(0, 0.35, 2.9), 0.22)
            if def.Menu == "Security" then
                placeAuditedClone(parent, "Audited_CreatorSecurityConsole_" .. def.Id, creatorSecurityConsole, "ReplicatedStorage.ArtAssets.Props.Clean_CreatorSecurityConsole_11864290745", category, "Security Creator Store console", baseCf * CFrame.new(0, 0.4, -4.2), 0.12)
            elseif def.Menu == "TourBus" then
                placeAuditedClone(parent, "Audited_CreatorTourBusProp_" .. def.Id, creatorTourBus, "ReplicatedStorage.ArtAssets.TourBus.Clean_CreatorTourBusProp_75431387", category, "Tour Bus Creator Store dressing", baseCf * CFrame.new(0, 0.4, 5), 0.08)
            end
        end
    end

    local npcPerSector = 64
    for _, sectorDef in ipairs(Sectors) do
        local sector = roots.HordeRing:FindFirstChild("HordeSector_" .. sectorDef.Id)
        local horde = sector and sector:FindFirstChild("HordeCluster")
        if horde then
            horde:SetAttribute("LiveHordeMotion", true)
            horde:SetAttribute("HordeSectorId", sectorDef.Id)
            for npcIndex = 1, npcPerSector do
                local row = math.floor((npcIndex - 1) / 16)
                local col = ((npcIndex - 1) % 16) - 7.5
                local radius = 62 + row * 5.2 + ((npcIndex % 3) * 0.55)
                local template = pickTemplate(hordeTemplates, npcIndex + sectorDef.Angle, hordePack)
                local templatePath = template and ("ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde." .. template.Name) or "ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde"
                local cf = PolarLayout.cframeFacingCenter(radius, sectorDef.Angle, 3.4) * CFrame.new(col * 1.75, 0, 0)
                local clone = placeAuditedClone(horde, "Audited_BrainrotNPC_" .. sectorDef.Id .. "_" .. string.format("%03d", npcIndex), template, templatePath, "hordeRing", "audited live brainrot horde NPC " .. sectorDef.Id, cf, 0.46 + ((npcIndex % 4) * 0.025))
                tagBrainrotNPC(clone, sectorDef.Id, npcIndex)
            end
        end
    end
    for _, point in ipairs(PolarLayout.distribute(12, 96, 4, 15)) do
        placeAuditedClone(roots.AudienceRing, "Audited_FanNPCCreatorLocalCrowd_" .. point.index, fanNpcPack, fanNpcPath, "audienceRing", "audited local fan NPC Creator crowd pack", point.cframeFacingCenter, 0.78)
    end
    local tourBusArea = world and (world:FindFirstChild("TourBusAndSpawnDressing") or ensureModel(world, "TourBusAndSpawnDressing"))
    if tourBusArea then
        placeAuditedClone(tourBusArea, "Audited_BackstageDepotRig", stageRig, "ReplicatedStorage.ArtAssets.Stage.Clean_ConcertStageTrussSpeakerLights", "tourBusAndSpawn", "audited backstage/tour-bus depot rig", CFrame.new(-18, 5, -68) * CFrame.Angles(0, math.rad(90), 0), 0.12)
        local busTemplate = pickTemplate(hordeTemplates, 9, hordePack)
        local busPath = busTemplate and ("ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde." .. busTemplate.Name) or "ReplicatedStorage.ArtAssets.Horde.Clean_CartoonMonsterHorde"
        placeAuditedClone(tourBusArea, "Audited_TourBusManagerNPC", busTemplate, busPath, "tourBusAndSpawn", "audited tour bus manager NPC", CFrame.new(-4, 4, -51) * CFrame.Angles(0, math.rad(180), 0), 0.42)
        placeAuditedClone(tourBusArea, "Audited_BackstageMerchProps", vendorKiosk, "ReplicatedStorage.ArtAssets.Vendors.Clean_VendorKioskShopCounter", "tourBusAndSpawn", "audited tour bus/store backstage props", CFrame.new(7, 3.2, -44) * CFrame.Angles(0, math.rad(180), 0), 0.24)
        placeAuditedClone(tourBusArea, "Audited_CreatorTourBusProp_Main", creatorTourBus, "ReplicatedStorage.ArtAssets.TourBus.Clean_CreatorTourBusProp_75431387", "tourBusAndSpawn", "Creator Store tour bus prop", CFrame.new(-26, 4.2, -72) * CFrame.Angles(0, math.rad(90), 0), 0.12)
    end

    local volcano = findArtAsset("Volcano", "Clean_VolcanoRockLavaCliff")
    for _, point in ipairs(PolarLayout.distribute(8, 134, 8, 22.5)) do
        placeAuditedClone(roots.VolcanoOuterRing, "Audited_VolcanoCliff_" .. point.index, volcano, "ReplicatedStorage.ArtAssets.Volcano.Clean_VolcanoRockLavaCliff", "volcanoOuterRing", "audited volcano cliff/lava shell", point.cframeFacingCenter, 1.45)
    end
end

local function hideAutogenLookingScaffold(world)
    local hidden = 0
    local patterns = {
        "^NpcCoat_", "^NpcHeadGlow_", "^NpcHat_",
        "^VendorDeck_", "^VendorCounter_", "^ConsoleScreen_", "^PropCrateLeft_", "^PropCrateRight_",
        "^HordeFigure_", "^HordeEyeGlow_", "^CrowdSilhouette_",
        "^VolcanicCliff_", "^FenceArcSegment_", "^FencePost_",
        "^TourBusBodyReadable$", "^TourBusWheel_",
    }
    for _, desc in ipairs(world:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Transparency < 0.95 then
            for _, pattern in ipairs(patterns) do
                if desc.Name:match(pattern) then
                    desc.Transparency = 1
                    desc.CanCollide = false
                    desc:SetAttribute("RejectedPlacement", true)
                    desc:SetAttribute("AutogenScaffoldHidden", true)
                    hidden += 1
                    break
                end
            end
        end
    end
    world:SetAttribute("HiddenAutogenLookingScaffoldParts", hidden)
    return hidden
end

local function lockWorldPhysics(world)
    local locked = 0
    local collisionFloors = {
        SafeWalkableConcertFloor = true,
        CursedConcertDisc = true,
        NeonPerformanceCircle = true,
        PlayerWalkwayRing = true,
        SpawnLocation = true,
    }
    for _, desc in ipairs(world:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = true
            if collisionFloors[desc.Name] then
                desc.CanCollide = true
            end
            locked += 1
        end
    end
    local spawn = world:FindFirstChild("SpawnLocation")
    if spawn and spawn:IsA("BasePart") then
        spawn.Anchored = true
        spawn.CanCollide = true
        spawn.AssemblyLinearVelocity = Vector3.zero
        spawn.AssemblyAngularVelocity = Vector3.zero
    end
    world:SetAttribute("PhysicsLockedParts", locked)
    return locked
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

function prompt(anchor, action, objectText, menuName, dialogue, actionPrompt)
    local pr = anchor:FindFirstChildOfClass("ProximityPrompt") or Instance.new("ProximityPrompt")
    pr.Name = "ProximityPrompt"
    pr.ActionText = action
    pr.ObjectText = objectText
    pr.HoldDuration = 0.15
    pr.MaxActivationDistance = 18
    pr.RequiresLineOfSight = false
    pr:SetAttribute("MenuName", menuName or objectText)
    pr:SetAttribute("Dialogue", dialogue or "")
    pr:SetAttribute("ActionPrompt", actionPrompt or action)
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
    promoteFanNpcCreatorLocalAssets(roots)
    if roots.Inbox then
        hideInstanceVisuals(roots.Inbox)
        roots.Inbox:SetAttribute("VisualsDisabled", "AssetInbox is quarantine/inbox only; active art must be cloned into Workspace.GTH_WorldV2")
    end
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
    if world then world:Destroy() end
    world = Instance.new("Model")
    world.Name = Config.RootName
    world.Parent = Workspace
    world:SetAttribute("CoordinateConvention", Config.CoordinateConvention)
    world:SetAttribute("AssetPolicy", "Audited ArtAssets or local Studio candidates only; no hardcoded Creator Store IDs")

    local roots = {}
    for _, name in ipairs(Config.RootFolders) do roots[name] = ensureFolder(world, name) end
    hideRejectedImportedBulkArt(world)
    hideLegacyGeneratedScaffold(world)

    buildStageCore(roots)
    buildLightingAndTrusses(roots)

    invisible(roots.InvisibleGameplayHitboxes, "SingerSpot", Vector3.new(8, 5, 8), CFrame.new(0, 4, 0), false)
    invisible(roots.InvisibleGameplayHitboxes, "AudienceZone", Vector3.new(96, 14, 96), CFrame.new(0, 5, 0), false)
    invisible(roots.InvisibleGameplayHitboxes, "AntiFallBarrier_N", Vector3.new(220, 60, 4), CFrame.new(0, 25, 160), true)
    invisible(roots.InvisibleGameplayHitboxes, "AntiFallBarrier_S", Vector3.new(220, 60, 4), CFrame.new(0, 25, -160), true)
    invisible(roots.InvisibleGameplayHitboxes, "AntiFallBarrier_E", Vector3.new(4, 60, 220), CFrame.new(160, 25, 0), true)
    invisible(roots.InvisibleGameplayHitboxes, "AntiFallBarrier_W", Vector3.new(4, 60, 220), CFrame.new(-160, 25, 0), true)

    buildTourBusSpawnPath(world)

    for _, point in ipairs(PolarLayout.distribute(32, 54, 3.2, 0)) do
        artPart(roots.FenceRing, "FenceArcSegment_" .. point.index, Vector3.new(7, 5, 0.8), point.cframeFacingCenter, Color3.fromRGB(95, 255, 120), Enum.Material.Metal, "fenceRing", "circular security fence")
        local post = artPart(roots.FenceRing, "FencePost_" .. point.index, Vector3.new(0.9, 6.5, 0.9), point.cframeFacingCenter * CFrame.new(3.7, 0.8, 0), Color3.fromRGB(135, 255, 180), Enum.Material.Neon, "fenceRing", "fence warning post")
        post.CanCollide = false
    end

    for _, def in ipairs(Vendors) do
        local parent = roots[def.Root]
        local model = ensureModel(parent, def.Id)
        local cf = PolarLayout.cframeFacingCenter(def.Radius, def.Angle, 2.5)
        for _, childName in ipairs({ "StationPlinth", "NpcBody", "NpcHead", "MenuSurfaceSign" }) do
            local old = model:FindFirstChild(childName)
            if old then hideInstanceVisuals(old) end
        end
        local plinth = artPart(model, "VendorDeck_" .. def.Id, Vector3.new(8.5, 0.8, 5.5), cf, def.Color:Lerp(Color3.fromRGB(20, 20, 28), 0.55), Enum.Material.Metal, "vendorRing", def.Menu .. " vendor deck")
        artPart(model, "VendorCounter_" .. def.Id, Vector3.new(6, 2, 1.2), cf * CFrame.new(0, 1.5, -1.8), def.Color, Enum.Material.Neon, "vendorRing", def.Menu .. " counter")
        artPart(model, "NpcCoat_" .. def.Id, Vector3.new(2.4, 4.2, 1.3), cf * CFrame.new(0, 3.2, 0.7), def.Color:Lerp(Color3.new(1,1,1), 0.16), Enum.Material.SmoothPlastic, "vendorRing", def.Menu .. " NPC body")
        artPart(model, "NpcHeadGlow_" .. def.Id, Vector3.new(1.8, 1.8, 1.8), cf * CFrame.new(0, 6.15, 0.7), Color3.fromRGB(255, 225, 170), Enum.Material.Neon, "vendorRing", def.Menu .. " NPC head", Enum.PartType.Ball)
        artPart(model, "NpcHat_" .. def.Id, Vector3.new(2.2, 0.5, 2.2), cf * CFrame.new(0, 7.15, 0.7), def.Color, Enum.Material.Metal, "vendorRing", def.Menu .. " NPC hat", Enum.PartType.Cylinder)
        artPart(model, "ConsoleScreen_" .. def.Id, Vector3.new(3.8, 2.2, 0.35), cf * CFrame.new(0, 3.2, -2.45), Color3.fromRGB(20, 255, 200), Enum.Material.Neon, "vendorRing", def.Menu .. " console screen")
        artPart(model, "PropCrateLeft_" .. def.Id, Vector3.new(1.5, 1.5, 1.5), cf * CFrame.new(-3.1, 1.3, 1), def.Color:Lerp(Color3.fromRGB(40, 40, 40), 0.35), Enum.Material.Metal, "vendorRing", def.Menu .. " station prop")
        artPart(model, "PropCrateRight_" .. def.Id, Vector3.new(1.5, 1.5, 1.5), cf * CFrame.new(3.1, 1.3, 1), def.Color:Lerp(Color3.fromRGB(40, 40, 40), 0.35), Enum.Material.Metal, "vendorRing", def.Menu .. " station prop")
        artPart(model, "VendorBeaconLeft_" .. def.Id, Vector3.new(0.55, 3.4, 0.55), cf * CFrame.new(-4, 2.5, -1.8), def.Color, Enum.Material.Neon, "vendorRing", def.Menu .. " station beacon")
        artPart(model, "VendorBeaconRight_" .. def.Id, Vector3.new(0.55, 3.4, 0.55), cf * CFrame.new(4, 2.5, -1.8), def.Color, Enum.Material.Neon, "vendorRing", def.Menu .. " station beacon")
        local sign = artPart(model, "ReadableMenuSign_" .. def.Id, Vector3.new(7, 3, 0.35), cf * CFrame.new(0, 5.2, -2.9), def.Color, Enum.Material.Neon, "vendorRing", def.Menu .. " menu sign")
        surfaceLabel(sign, def.Menu .. "\n" .. (def.ActionPrompt or def.Prompt), Enum.NormalId.Front)
        local anchor = invisible(model, "PromptAnchor", Vector3.new(5, 6, 5), cf * CFrame.new(0, 3, 0), false)
        prompt(anchor, def.Prompt, def.ObjectText or def.Menu, def.Menu, def.Dialogue, def.ActionPrompt)
        model.PrimaryPart = plinth
        plinth:SetAttribute("FacesCenter", true)
    end

    for _, sectorDef in ipairs(Sectors) do
        local sector = ensureFolder(roots.HordeRing, "HordeSector_" .. sectorDef.Id)
        sector:SetAttribute("SectorId", sectorDef.Id)
        sector:SetAttribute("AngleDeg", sectorDef.Angle)
        sector:SetAttribute("Health", sector:GetAttribute("Health") or 100)
        local cf = PolarLayout.cframeFacingCenter(54, sectorDef.Angle, 3)
        local fence = artPart(sector, "FenceSegment", Vector3.new(13, 5, 1), cf, Color3.fromRGB(95, 255, 120), Enum.Material.Metal, "hordeRing", "sector damage fence")
        local vfx = artPart(sector, "FenceDamageVFX", Vector3.new(10, 0.4, 0.4), cf * CFrame.new(0, 2.9, -0.7), Color3.fromRGB(255, 80, 40), Enum.Material.Neon, "hordeRing", "sector damage warning")
        vfx.Transparency = 0.55
        local security = artPart(sector, "SecurityLight", Vector3.new(1.2, 1.2, 1.2), cf * CFrame.new(-4.8, 3.8, -1), Color3.fromRGB(150, 220, 255), Enum.Material.Neon, "hordeRing", "sector security light", Enum.PartType.Ball)
        local secLight = security:FindFirstChildOfClass("PointLight") or Instance.new("PointLight"); secLight.Range = 18; secLight.Brightness = 1.2; secLight.Color = security.Color; secLight.Parent = security
        local siren = artPart(sector, "SirenLight", Vector3.new(1.5, 1.5, 1.5), cf * CFrame.new(4.8, 3.8, -1), Color3.fromRGB(255, 35, 35), Enum.Material.Neon, "hordeRing", "sector siren light", Enum.PartType.Ball)
        local sirenLight = siren:FindFirstChildOfClass("PointLight") or Instance.new("PointLight"); sirenLight.Range = 20; sirenLight.Brightness = 0; sirenLight.Color = siren.Color; sirenLight.Parent = siren
        local horde = ensureModel(sector, "HordeCluster")
        for i = 1, 20 do
            local row = math.floor((i - 1) / 5)
            local col = ((i - 1) % 5) - 2
            local creep = artPart(horde, "HordeFigure_" .. sectorDef.Id .. "_" .. i, Vector3.new(1.5, 3.1 + (i % 3) * 0.45, 1.5), PolarLayout.cframeFacingCenter(64 + row * 4, sectorDef.Angle, 3) * CFrame.new(col * 2.15, 0, 0), Color3.fromRGB(85 + (i % 4) * 25, 255, 85), Enum.Material.Neon, "hordeRing", "visible horde monster pressure")
            creep.CanCollide = false
            artPart(horde, "HordeEyeGlow_" .. sectorDef.Id .. "_" .. i, Vector3.new(0.55, 0.22, 0.22), creep.CFrame * CFrame.new(0, 0.65, -0.8), Color3.fromRGB(255, 45, 45), Enum.Material.Neon, "hordeRing", "monster eye glow").CanCollide = false
        end
        horde.PrimaryPart = horde.PrimaryPart or horde:FindFirstChildWhichIsA("BasePart", true)
        local meter = artPart(sector, "HordePressureMeter", Vector3.new(8, 1.1, 0.6), cf * CFrame.new(0, -2.7, -1.2), Color3.fromRGB(255, 230, 90), Enum.Material.Neon, "hordeRing", "sector pressure meter")
        meter:SetAttribute("Pressure", 0)
        artPart(sector, "WeakPointMarker", Vector3.new(2.2, 2.2, 0.5), cf * CFrame.new(0, 0.7, -1.25), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, "hordeRing", "repair weak point marker")
        for i = 1, 6 do
            local spark = artPart(sector, "SectorWarningSpike_" .. sectorDef.Id .. "_" .. i, Vector3.new(0.45, 4 + (i % 2), 0.45), cf * CFrame.new((i - 3.5) * 2, 1.5, -2.4), Color3.fromRGB(255, 120, 40), Enum.Material.Neon, "hordeRing", "sector warning spike")
            spark.CanCollide = false
        end
        prompt(invisible(sector, "RepairPromptAnchor", Vector3.new(8, 8, 8), cf * CFrame.new(0, 2, -6), false), "Repair Fence", "Sector " .. sectorDef.Id, "Security").MaxActivationDistance = 28
    end

    buildAuditedAssetPlacements(roots)

    for _, point in ipairs(PolarLayout.distribute(160, 92, 4, 7.5)) do
        local crowd = artPart(roots.AudienceRing, "CrowdSilhouette_" .. point.index, Vector3.new(1.15, 3.2 + (point.index % 3) * 0.55, 1.15), point.cframeFacingCenter, Color3.fromRGB(75, 180 + (point.index % 3) * 25, 120), Enum.Material.Neon, "audienceRing", "audience crowd silhouette")
        crowd.CanCollide = false
    end
    for _, point in ipairs(PolarLayout.distribute(96, 126, 12, 11.25)) do
        local cliff = artPart(roots.VolcanoOuterRing, "VolcanicCliff_" .. point.index, Vector3.new(6 + (point.index % 4), 14 + (point.index % 5) * 2, 5), point.cframeFacingCenter, Color3.fromRGB(105, 45, 30), Enum.Material.CrackedLava, "volcanoOuterRing", "volcano horizon cliff")
        cliff.CanCollide = false
        cliff.Parent = roots.VolcanoOuterRing
        local also = roots.OuterVolcanoRing:FindFirstChild(cliff.Name) or cliff:Clone()
        markPlacedArt(also, "volcanoOuterRing", "outer volcano mirrored cliff")
        also.Parent = roots.OuterVolcanoRing
    end
    local atmosphere = Lighting:FindFirstChild("WorldV2ToxicAtmosphere") or Instance.new("Atmosphere")
    atmosphere.Name = "WorldV2ToxicAtmosphere"
    atmosphere.Density = 0.45
    atmosphere.Haze = 2.2
    atmosphere.Color = Color3.fromRGB(160, 225, 120)
    atmosphere.Decay = Color3.fromRGB(90, 45, 25)
    atmosphere.Parent = Lighting
    Lighting.ClockTime = 20.5
    Lighting.Brightness = 1.4
    Lighting.Ambient = Color3.fromRGB(55, 42, 65)
    Lighting.OutdoorAmbient = Color3.fromRGB(25, 18, 34)
    Lighting.FogColor = Color3.fromRGB(24, 12, 22)
    Lighting.FogStart = 70
    Lighting.FogEnd = 260

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

    hideAutogenLookingScaffold(world)
    hideProceduralScaffoldWhenAuditedArtReady(world)
    lockWorldPhysics(world)
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
