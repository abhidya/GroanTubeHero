local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local ProjectReadme = require(ReplicatedStorage.Shared.ProjectReadme)

local function ensureFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

local function ensureRemote(folder, name)
    local remote = folder:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = folder
    end
    return remote
end

local function alignInstance(instance, size, cframe, color, material)
    if instance:IsA("Model") then
        instance:PivotTo(cframe)
        for _, desc in ipairs(instance:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.Anchored = true
                desc.CanCollide = true
            end
        end
    elseif instance:IsA("BasePart") then
        instance.Anchored = true
        instance.CanCollide = true
        instance.Size = size
        instance.CFrame = cframe
        if color then instance.Color = color end
        if material then instance.Material = material end
    end
end

local function ensurePart(parent, name, size, cframe, color, material)
    local part = parent:FindFirstChild(name)
    if not part then
        part = Instance.new("Part")
        part.Name = name
        part.Parent = parent
    end
    alignInstance(part, size, cframe, color, material)
    return part
end

local function setBasePart(instance, props)
    if not instance or not instance:IsA("BasePart") then return end
    for key, value in pairs(props) do
        pcall(function()
            instance[key] = value
        end)
    end
end

local function setModelPrimaryPart(model)
    if not model or not model:IsA("Model") or model.PrimaryPart then return end
    local firstPart = model:FindFirstChildWhichIsA("BasePart", true)
    if firstPart then
        model.PrimaryPart = firstPart
    end
end

local function ensurePrompt(part, actionText, objectText)
    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.Parent = part
    end
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.HoldDuration = 0.15
    prompt.MaxActivationDistance = 18
    return prompt
end

local function createBillboard(part, text)
    local gui = part:FindFirstChildOfClass("BillboardGui") or Instance.new("BillboardGui")
    gui.Size = UDim2.new(0, 260, 0, 70)
    gui.StudsOffset = Vector3.new(0, 4, 0)
    gui.AlwaysOnTop = false
    gui.MaxDistance = 40
    gui.Parent = part
    local label = gui:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.35
    label.Parent = gui
end

local function ungroupMapPackage()
    local unusedAssets = Workspace:FindFirstChild("Unused_MapAssets")
    if not unusedAssets then return end

    local openMe = unusedAssets:FindFirstChild("OPEN ME! (READ THE READ ME)")
    if not openMe then return end

    -- 1. MaterialService
    local materialFolder = openMe:FindFirstChild("Ungroup in MaterialService")
    if materialFolder then
        local MaterialService = game:GetService("MaterialService")
        for _, variant in ipairs(materialFolder:GetChildren()) do
            if variant:IsA("MaterialVariant") then
                local existing = MaterialService:FindFirstChild(variant.Name)
                if not existing then
                    variant.Parent = MaterialService
                else
                    variant:Destroy()
                end
            end
        end
    end

    -- 2. Lighting & Skybox
    local lightingFolder = openMe:FindFirstChild("(DELETE YOUR OLD LIGHTING AND UNGROUP THIS FOLDER IN LIGHTING)")
    if lightingFolder then
        local targetFolder = lightingFolder:FindFirstChild("This is the new lighting from the latest update")
        if targetFolder then
            local Lighting = game:GetService("Lighting")
            if not Lighting:FindFirstChild("DarkSky") then
                for _, child in ipairs(Lighting:GetChildren()) do
                    if child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("PostEffect") then
                        child:Destroy()
                    end
                end
                for _, effect in ipairs(targetFolder:GetChildren()) do
                    effect.Parent = Lighting
                end
            end
        end
    end

    -- 3. ReplicatedStorage
    local replicatedFolder = openMe:FindFirstChild("Ungroup in ReplicatedStorage")
    if replicatedFolder then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        for _, child in ipairs(replicatedFolder:GetChildren()) do
            local existing = ReplicatedStorage:FindFirstChild(child.Name)
            if not existing then
                child.Parent = ReplicatedStorage
            else
                if child:IsA("Folder") and existing:IsA("Folder") then
                    for _, subChild in ipairs(child:GetChildren()) do
                        if not existing:FindFirstChild(subChild.Name) then
                            subChild.Parent = existing
                        else
                            subChild:Destroy()
                        end
                    end
                    child:Destroy()
                else
                    child:Destroy()
                end
            end
        end
    end

    -- 4. StarterGui
    local guiFolder = openMe:FindFirstChild("ungroup in startergui")
    if guiFolder then
        local StarterGui = game:GetService("StarterGui")
        for _, child in ipairs(guiFolder:GetChildren()) do
            if not StarterGui:FindFirstChild(child.Name) then
                child.Parent = StarterGui
            else
                child:Destroy()
            end
        end
    end

    -- 5. StarterPack
    local packFolder = openMe:FindFirstChild("ungroup in starterpack")
    if packFolder then
        local StarterPack = game:GetService("StarterPack")
        for _, child in ipairs(packFolder:GetChildren()) do
            if not StarterPack:FindFirstChild(child.Name) then
                child.Parent = StarterPack
            else
                child:Destroy()
            end
        end
    end

    -- 6. ServerScriptService
    local serverFolder = openMe:FindFirstChild("ungroup in ServerScriptService")
    if serverFolder then
        local ServerScriptService = game:GetService("ServerScriptService")
        for _, child in ipairs(serverFolder:GetChildren()) do
            if not ServerScriptService:FindFirstChild(child.Name) then
                child.Parent = ServerScriptService
            else
                child:Destroy()
            end
        end
    end

    -- 7. Workspace
    local workspaceFolder = openMe:FindFirstChild("Ungroup in workspace")
    if workspaceFolder then
        for _, child in ipairs(workspaceFolder:GetChildren()) do
            if not Workspace:FindFirstChild(child.Name) then
                child.Parent = Workspace
            else
                child:Destroy()
            end
        end
    end

    openMe:Destroy()
end

local function getObjectBoundingBox(inst)
    if inst:IsA("Model") then
        return inst:GetBoundingBox()
    elseif inst:IsA("BasePart") then
        return inst.CFrame, inst.Size
    end
end

local function getRotation(inst)
    if inst:IsA("Model") then
        local cf = inst:GetPivot()
        return cf - cf.Position
    elseif inst:IsA("BasePart") then
        local cf = inst.CFrame
        return cf - cf.Position
    end
    return CFrame.new()
end

local function ensureStageObject(stage, name, defaultSize, x, z, rotation, color, material, stageTopY)
    local inst = stage:FindFirstChild(name)
    if not inst then
        local unusedAssets = Workspace:FindFirstChild("Unused_MapAssets")
        local template = unusedAssets and unusedAssets:FindFirstChild(name)
        if template then
            inst = template:Clone()
            inst.Parent = stage
        else
            inst = Instance.new("Part")
            inst.Name = name
            inst.Size = defaultSize
            inst.Parent = stage
        end
    end

    local sz
    local currentRotation = rotation

    if inst:IsA("Model") then
        local cf, modelSize = inst:GetBoundingBox()
        sz = modelSize
        if not currentRotation then
            currentRotation = cf - cf.Position
        end
    else
        sz = defaultSize or inst.Size
        if not currentRotation then
            currentRotation = inst.CFrame - inst.CFrame.Position
        end
    end

    local finalY = stageTopY + sz.Y / 2
    local targetCf = CFrame.new(x, finalY, z) * currentRotation

    if inst:IsA("Model") then
        inst:PivotTo(targetCf)
        for _, desc in ipairs(inst:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.Anchored = true
                desc.CanCollide = true
            end
        end
    else
        inst.Size = sz
        inst.CFrame = targetCf
        inst.Anchored = true
        inst.CanCollide = true
        if color then inst.Color = color end
        if material then inst.Material = material end
    end

    return inst
end

local function buildMap()
    ungroupMapPackage()

    local stage = ensureFolder(Workspace, "Stage")
    local tourBus = ensureFolder(Workspace, "TourBus")

    local base = stage:FindFirstChild("StagePlatform")
    if not base then
        warn("Groan Tube Hero: Workspace.Stage.StagePlatform not found. Creating fallback.")
        base = ensurePart(stage, "StagePlatform", Vector3.new(60, 2, 40), CFrame.new(0, 10.17, 0), Color3.fromRGB(40, 40, 50), Enum.Material.Metal)
    else
        if base:IsA("Model") then
            base:PivotTo(CFrame.new(0, 10.17, 0))
            for _, child in ipairs(base:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.Anchored = true
                    child.CanCollide = true
                end
            end
        else
            base.Size = Vector3.new(60, 2, 40)
            base.CFrame = CFrame.new(0, 10.17, 0)
            base.Anchored = true
            base.CanCollide = true
        end
    end

    local stageCf, stageSize
    if base:IsA("Model") then
        stageCf, stageSize = base:GetBoundingBox()
    else
        stageCf, stageSize = base.CFrame, base.Size
    end
    local stageTopY = stageCf.Position.Y + (stageSize.Y / 2)

    local singerSpot = ensureStageObject(stage, "SingerSpot", Vector3.new(6, 1, 6), 0, -4, nil, Color3.fromRGB(255, 255, 255), Enum.Material.Neon, stageTopY)
    setBasePart(singerSpot, { CanCollide = false })

    local audienceZone = ensureStageObject(stage, "AudienceZone", Vector3.new(24, 8, 18), 0, 18, nil, Color3.fromRGB(55, 55, 70), Enum.Material.ForceField, stageTopY)
    setBasePart(audienceZone, { Transparency = 0.7, CanCollide = false })

    local startPromptPart = ensureStageObject(stage, "StartPrompt", Vector3.new(4, 1, 4), -16, -8, nil, Color3.fromRGB(80, 170, 255), Enum.Material.Neon, stageTopY)
    setBasePart(startPromptPart, { CanCollide = false })
    local prompt = ensurePrompt(startPromptPart, "Choose Song", "START SONG")
    if prompt then prompt.HoldDuration = 0.5 end
    createBillboard(startPromptPart, "START SONG")

    local storeKiosk = ensureStageObject(stage, "StoreKiosk", Vector3.new(5, 8, 5), 14, -6, nil, Color3.fromRGB(120, 255, 180), Enum.Material.SmoothPlastic, stageTopY)
    createBillboard(storeKiosk, "STORE")

    local upgradeKiosk = ensureStageObject(stage, "UpgradeKiosk", Vector3.new(5, 8, 5), 20, -6, nil, Color3.fromRGB(255, 220, 120), Enum.Material.SmoothPlastic, stageTopY)
    createBillboard(upgradeKiosk, "UPGRADES")

    local missionBoard = ensureStageObject(stage, "MissionBoard", Vector3.new(6, 9, 1), 26, -6, nil, Color3.fromRGB(220, 220, 255), Enum.Material.Wood, stageTopY)
    createBillboard(missionBoard, "MISSIONS")

    local microphone = ensureStageObject(stage, "MicrophoneStand", Vector3.new(1, 8, 1), 0, -2, nil, Color3.fromRGB(60, 60, 60), Enum.Material.Metal, stageTopY)
    if microphone:IsA("Model") then
        for _, desc in ipairs(microphone:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.CanCollide = false
            end
        end
    else
        setBasePart(microphone, { CanCollide = false })
    end

    local speakerStacks = ensureFolder(stage, "SpeakerStacks")
    local speaker1 = ensureStageObject(speakerStacks, "SpeakerStack1", Vector3.new(3, 8, 3), -22, -3, nil, Color3.fromRGB(25, 25, 30), Enum.Material.Metal, stageTopY)
    local speaker2 = ensureStageObject(speakerStacks, "SpeakerStack2", Vector3.new(3, 8, 3), 22, -3, nil, Color3.fromRGB(25, 25, 30), Enum.Material.Metal, stageTopY)

    local spotlights = ensureFolder(stage, "Spotlights")
    for i = 1, 8 do
        local name = "GTH_LightPole_" .. i
        local pole = spotlights:FindFirstChild(name)
        if pole and pole:IsA("Model") then
            local cf, size = pole:GetBoundingBox()
            pole:PivotTo(stageCf * CFrame.new(-16 + (i - 1) * 4.5, (stageSize.Y / 2) + (size.Y / 2), -12))
            for _, desc in ipairs(pole:GetDescendants()) do
                if desc:IsA("BasePart") then
                    desc.Anchored = true
                    desc.CanCollide = false
                end
            end
        elseif pole and pole:IsA("BasePart") then
            pole.CFrame = stageCf * CFrame.new(-16 + (i - 1) * 4.5, (stageSize.Y / 2) + 5, -12)
            pole.Anchored = true
            pole.CanCollide = false
        else
            local lightBase = ensurePart(spotlights, "Spotlight" .. i, Vector3.new(1, 10, 1), stageCf * CFrame.new(-12 + (i - 1) * 8, (stageSize.Y / 2) + 5, -10), Color3.fromRGB(255, 255, 255), Enum.Material.Metal)
            setBasePart(lightBase, { CanCollide = false })
            local light = lightBase:FindFirstChildOfClass("SpotLight") or Instance.new("SpotLight")
            light.Angle = 70
            light.Brightness = 2
            light.Range = 18
            light.Parent = lightBase
        end
    end

    local hordeFolder = ensureFolder(stage, "BrainrotHorde")

    local farPointPos = stageCf * CFrame.new(0, 0, -(stageSize.Z / 2) - 52)
    local nearPointPos = stageCf * CFrame.new(0, 0, -(stageSize.Z / 2) - 2)
    local farPoint = ensurePart(hordeFolder, "HordeFarPoint", Vector3.new(2, 2, 2), CFrame.new(farPointPos.Position.X, 1.4, farPointPos.Position.Z), Color3.fromRGB(255, 80, 80), Enum.Material.Neon)
    setBasePart(farPoint, { Transparency = 1, CanCollide = false })
    local nearPoint = ensurePart(hordeFolder, "HordeNearStagePoint", Vector3.new(2, 2, 2), CFrame.new(nearPointPos.Position.X, stageTopY, nearPointPos.Position.Z), Color3.fromRGB(255, 255, 80), Enum.Material.Neon)
    setBasePart(nearPoint, { Transparency = 1, CanCollide = false })

    local hordeRoot = hordeFolder:FindFirstChild("HordeRoot")
    if hordeRoot and hordeRoot:IsA("Folder") then
        local oldFolder = hordeRoot
        local model = Instance.new("Model")
        model.Name = "HordeRoot"
        model.Parent = hordeFolder
        for _, child in ipairs(oldFolder:GetChildren()) do
            child.Parent = model
            if child:IsA("Model") then
                for _, part in ipairs(child:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                        part.CanCollide = false
                    end
                end
            elseif child:IsA("BasePart") then
                child.Anchored = true
                child.CanCollide = false
            end
        end
        oldFolder:Destroy()
        hordeRoot = model
        setModelPrimaryPart(hordeRoot)
    end
    if not hordeRoot then
        hordeRoot = Instance.new("Model")
        hordeRoot.Name = "HordeRoot"
        hordeRoot.Parent = hordeFolder
        for i = 1, 16 do
            local row = math.floor((i - 1) / 4)
            local col = ((i - 1) % 4) - 1.5
            local creep = ensurePart(hordeRoot, "Brainrot" .. i, Vector3.new(2.4, 4 + (i % 3), 2.4), stageCf * CFrame.new(col * 4, 1.2, -(stageSize.Z / 2) - 52 + row * 4), Color3.fromRGB(90, 255, 90), Enum.Material.Neon)
            setBasePart(creep, { CanCollide = false, Shape = Enum.PartType.Block })
        end
        setModelPrimaryPart(hordeRoot)
    elseif hordeRoot:IsA("Model") then
        setModelPrimaryPart(hordeRoot)
    end

    local lanePos = stageCf * CFrame.new(0, -(stageSize.Y / 2) + 0.25, -(stageSize.Z / 2) - 27)
    local lane = ensurePart(stage, "BrainrotHordeLane", Vector3.new(22, 0.5, 54), lanePos, Color3.fromRGB(80, 30, 30), Enum.Material.CrackedLava)
    setBasePart(lane, { CanCollide = false, Transparency = 0.15 })

    local backdrop = ensureFolder(stage, "BrainrotBackdrop")
    local hasCustomBackdrop = false
    for _, child in ipairs(backdrop:GetChildren()) do
        if child.Name:match("^Volcano_") or child.Name:match("^LavaGlow_") then
            hasCustomBackdrop = true
            break
        end
    end
    if not hasCustomBackdrop then
        for i = 1, 5 do
            local angle = (i / 5) * math.pi * 2
            local volcano = ensurePart(backdrop, "Volcano" .. i, Vector3.new(10, 22, 10), stageCf * CFrame.new(math.cos(angle) * 34, 10, -(stageSize.Z / 2) - 50 + math.sin(angle) * 12), Color3.fromRGB(130, 45, 25), Enum.Material.CrackedLava)
            setBasePart(volcano, { Anchored = true, CanCollide = false })
            local fire = volcano:FindFirstChildOfClass("PointLight") or Instance.new("PointLight")
            fire.Color = Color3.fromRGB(255, 80, 20)
            fire.Range = 22
            fire.Brightness = 2
            fire.Parent = volcano
        end
    end

    local hordeSign = ensurePart(stage, "BrainrotHordeSign", Vector3.new(16, 5, 1), stageCf * CFrame.new(0, (stageSize.Y / 2) + 5, 18), Color3.fromRGB(90, 255, 90), Enum.Material.SmoothPlastic)
    createBillboard(hordeSign, "BRAINROT HORDE")

    local venueSigns = ensureFolder(stage, "VenueSigns")
    local sign = ensurePart(venueSigns, "MainSign", Vector3.new(24, 6, 1), stageCf * CFrame.new(0, (stageSize.Y / 2) + 8, -12), Color3.fromRGB(70, 70, 90), Enum.Material.SmoothPlastic)
    createBillboard(sign, "GROAN TUBE HERO")

    local crowd = ensureFolder(stage, "Crowd")
    for i = 1, 8 do
        local c = ensurePart(crowd, "Crowd" .. i, Vector3.new(2, 5, 2), stageCf * CFrame.new(-18 + i * 4, -0.5, (stageSize.Z / 2) + 4 + (i % 2) * 2), Color3.fromRGB(90, 90, 100), Enum.Material.SmoothPlastic)
        setBasePart(c, { CanCollide = false })
    end

    local busBase = tourBus:FindFirstChild("BusBody")
    if busBase and busBase:IsA("Model") then
        busBase:PivotTo(stageCf * CFrame.new(50, 4, 18))
        for _, desc in ipairs(busBase:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.Anchored = true
                desc.CanCollide = true
            end
        end
    else
        busBase = ensurePart(tourBus, "BusBody", Vector3.new(22, 8, 10), stageCf * CFrame.new(50, 4, 18), Color3.fromRGB(25, 25, 35), Enum.Material.Metal)
        local wrap = Instance.new("SelectionBox")
        wrap.Adornee = busBase
        wrap.LineThickness = 0.04
        wrap.Color3 = Color3.fromRGB(0, 255, 255)
        wrap.Parent = busBase
    end
    for i = 1, 4 do
        local name = "Wheel" .. i
        local wheel = tourBus:FindFirstChild(name)
        if wheel and wheel:IsA("BasePart") then
            wheel.CFrame = busBase:GetPivot() * CFrame.new(-9 + ((i - 1) % 2) * 18, -4, -5 + math.floor((i - 1) / 2) * 10)
            wheel.Anchored = true
            wheel.CanCollide = false
        else
            wheel = ensurePart(tourBus, name, Vector3.new(3, 3, 3), stageCf * CFrame.new(41 + ((i - 1) % 2) * 14, -3, 13 + math.floor((i - 1) / 2) * 10), Color3.fromRGB(10, 10, 10), Enum.Material.Rubber)
            setBasePart(wheel, { Shape = Enum.PartType.Cylinder, CanCollide = false })
        end
    end
    createBillboard(busBase, "TOUR BUS")

    local pathFolder = ensureFolder(stage, "SpawnPath")
    for i = 1, 7 do
        local pad = ensurePart(pathFolder, "ArrowPad" .. i, Vector3.new(5, 0.25, 3), stageCf * CFrame.new(-34 + i * 4, 0.05, -10 + i), Color3.fromRGB(255, 230, 80), Enum.Material.Neon)
        setBasePart(pad, { CanCollide = false, Transparency = 0.15 })
    end

    local audienceSign = ensurePart(stage, "AudienceSign", Vector3.new(8, 5, 1), stageCf * CFrame.new(-22, 4, 18), Color3.fromRGB(80, 170, 255), Enum.Material.SmoothPlastic)
    createBillboard(audienceSign, "AUDIENCE / WATCH")

    local cleanSigns = stage:FindFirstChild("CleanSigns")
    if cleanSigns then
        local signActions = {
            Sign_Store = { "Open Store", "STORE" },
            Sign_Upgrades = { "Open Upgrades", "UPGRADES" },
            Sign_Missions = { "Open Missions", "MISSIONS" },
            Sign_TourBus = { "Open Tour Bus", "TOUR BUS" },
            Sign_Audience = { "Open Watch", "AUDIENCE / WATCH" },
            Sign_Start = { "Choose Song", "START SONG" },
        }
        for name, values in pairs(signActions) do
            local signPart = cleanSigns:FindFirstChild(name)
            if signPart then
                local x = signPart.Position.X
                local z = signPart.Position.Z
                local rot = signPart.CFrame - signPart.Position
                local finalY = stageTopY + signPart.Size.Y / 2
                signPart.CFrame = CFrame.new(x, finalY, z) * rot
                signPart.Anchored = true
                signPart.CanCollide = true
                ensurePrompt(signPart, values[1], values[2])
            end
        end
    end
end


local function ensureArtAssets()
    local artAssets = ensureFolder(ReplicatedStorage, "ArtAssets")
    local kit = artAssets:FindFirstChild("WorldV2_SafeProceduralKit") or Instance.new("Model")
    kit.Name = "WorldV2_SafeProceduralKit"
    kit.Parent = artAssets
    kit:SetAttribute("AssetSource", "project-owned procedural; no Creator Store IDs")
    kit:SetAttribute("ScriptsQuarantined", 0)
    return artAssets, kit
end

local function archiveVisualInstance(inst, reason)
    if not inst or inst.Name == "GTH_WorldV2" or inst.Name == "Unused_MapAssets" or inst.Name == "AssetInbox" then return nil end
    local ServerStorage = game:GetService("ServerStorage")
    local archive = ensureFolder(ServerStorage, "WorldArchive")
    local archivedName = inst.Name .. "_ArchivedV1"
    local existing = archive:FindFirstChild(archivedName)
    if existing then existing:Destroy() end
    for _, desc in ipairs(inst:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Transparency = 1
            desc.CanCollide = false
        elseif desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") then
            desc.Enabled = false
        elseif desc:IsA("ParticleEmitter") or desc:IsA("Beam") or desc:IsA("Trail") or desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") or desc:IsA("SurfaceLight") or desc:IsA("PointLight") or desc:IsA("SpotLight") then
            desc.Enabled = false
        end
    end
    inst:SetAttribute("WorldV2ArchiveReason", reason or "Known V1 placeholder visual")
    inst.Name = archivedName
    inst.Parent = archive
    return inst
end

local function createInvisiblePart(parent, name, size, cframe)
    local part = ensurePart(parent, name, size, cframe, Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
    setBasePart(part, { Transparency = 1, CanCollide = false, Anchored = true })
    return part
end

local function createDisplayPart(parent, name, size, cframe, color, material, shape)
    local part = ensurePart(parent, name, size, cframe, color, material)
    setBasePart(part, { Anchored = true, CanCollide = true, Transparency = 0 })
    if shape then part.Shape = shape end
    return part
end

local function createSurfaceLabel(part, text, face)
    local gui = part:FindFirstChild("SurfaceLabel") or Instance.new("SurfaceGui")
    gui.Name = "SurfaceLabel"
    gui.Face = face or Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0.2
    gui.PixelsPerStud = 48
    gui.Parent = part
    local label = gui:FindFirstChild("Text") or Instance.new("TextLabel")
    label.Name = "Text"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Text = text
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.25
    label.Parent = gui
    return gui
end

local function makeStation(vendorRing, id, menuName, angle, radius, color)
    local PolarLayout = require(ReplicatedStorage.Shared.WorldV2.PolarLayout)
    local model = vendorRing:FindFirstChild(id) or Instance.new("Model")
    model.Name = id
    model.Parent = vendorRing
    local baseCf = PolarLayout.cframeFacingCenter(radius, angle, 3)
    local plinth = createDisplayPart(model, "StationPlinth", Vector3.new(7, 1.2, 5), baseCf, color, Enum.Material.SmoothPlastic)
    local body = createDisplayPart(model, "NpcBody", Vector3.new(2.2, 5, 1.5), baseCf * CFrame.new(0, 3.1, 0), color:Lerp(Color3.new(1,1,1), 0.18), Enum.Material.Neon)
    local head = createDisplayPart(model, "NpcHead", Vector3.new(1.8, 1.8, 1.8), baseCf * CFrame.new(0, 6.1, 0), Color3.fromRGB(255, 225, 170), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    local sign = createDisplayPart(model, "MenuSurfaceSign", Vector3.new(6.5, 3, 0.35), baseCf * CFrame.new(0, 4.4, -2.8), color, Enum.Material.Neon)
    createSurfaceLabel(sign, menuName, Enum.NormalId.Front)
    local promptAnchor = createInvisiblePart(model, "PromptAnchor", Vector3.new(5, 6, 5), baseCf * CFrame.new(0, 3, 0))
    local prompt = ensurePrompt(promptAnchor, "Open " .. menuName, menuName)
    prompt.Name = "ProximityPrompt"
    prompt:SetAttribute("MenuName", menuName)
    model.PrimaryPart = plinth
    return model, prompt
end

local SECTOR_ORDER = {
    { id = "N", angle = 90 }, { id = "NE", angle = 45 }, { id = "E", angle = 0 }, { id = "SE", angle = 315 },
    { id = "S", angle = 270 }, { id = "SW", angle = 225 }, { id = "W", angle = 180 }, { id = "NW", angle = 135 },
}

local function buildWorldV2()
    ensureArtAssets()
    local ServerStorage = game:GetService("ServerStorage")
    ensureFolder(ServerStorage, "AssetQuarantine")

    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "Stage" or child.Name == "TourBus" or child.Name == "ImportedArenaAssets" then
            archiveVisualInstance(child, "WorldV2 replaced known V1/placeholder visuals")
        end
    end

    local world = Workspace:FindFirstChild("GTH_WorldV2")
    if not world then
        world = Instance.new("Model")
        world.Name = "GTH_WorldV2"
        world.Parent = Workspace
    end
    world:SetAttribute("CoordinateConvention", "0=East(+X), 90=North(+Z), 180=West(-X), 270=South(-Z)")
    world:SetAttribute("AssetPolicy", "No unaudited Creator Store asset IDs used")

    local PolarLayout = require(ReplicatedStorage.Shared.WorldV2.PolarLayout)
    local arenaCore = ensureFolder(world, "ArenaCore")
    local fenceRing = ensureFolder(world, "FenceRing")
    local vendorRing = ensureFolder(world, "VendorRing")
    local audienceRing = ensureFolder(world, "AudienceRing")
    local hordeRing = ensureFolder(world, "HordeRing")
    local volcanoRing = ensureFolder(world, "OuterVolcanoRing")
    local hitboxes = ensureFolder(world, "InvisibleGameplayHitboxes")
    local adapters = ensureFolder(world, "CompatibilityAdapters")

    createDisplayPart(arenaCore, "ArenaDisc", Vector3.new(72, 1.4, 72), CFrame.new(0, 0, 0), Color3.fromRGB(38, 38, 54), Enum.Material.Slate, Enum.PartType.Cylinder).CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(90))
    createDisplayPart(arenaCore, "PerformanceCircle", Vector3.new(18, 0.35, 18), CFrame.new(0, 1.05, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(80, 225, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
    createInvisiblePart(hitboxes, "AudienceZone", Vector3.new(95, 14, 95), CFrame.new(0, 5, 0))
    createInvisiblePart(hitboxes, "SingerSpot", Vector3.new(8, 5, 8), CFrame.new(0, 4, 0))
    local spawn = world:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation") or Instance.new("SpawnLocation")
    spawn.Name = "SpawnLocation"
    spawn.Anchored = true
    spawn.CanCollide = true
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.CFrame = CFrame.new(0, 2, 12)
    spawn.Transparency = 1
    spawn.Parent = world

    for _, point in ipairs(PolarLayout.distribute(32, 38, 2.2, 0)) do
        local seg = createDisplayPart(fenceRing, "FenceArcSegment_" .. tostring(point.index), Vector3.new(5.5, 4.2, 0.8), point.cframeFacingCenter, Color3.fromRGB(95, 255, 120), Enum.Material.Metal)
        seg.CanCollide = true
    end

    makeStation(vendorRing, "DJ_GroanMaster", "SongSelect", 270, 24, Color3.fromRGB(170, 95, 255))
    makeStation(vendorRing, "Vendor_Store", "Store", 225, 25, Color3.fromRGB(55, 145, 255))
    makeStation(vendorRing, "Vendor_UpgradeEngineer", "Upgrades", 315, 25, Color3.fromRGB(255, 175, 70))
    makeStation(vendorRing, "MissionOfficer", "Missions", 180, 27, Color3.fromRGB(120, 200, 95))
    makeStation(vendorRing, "SecurityManager", "Security", 0, 27, Color3.fromRGB(255, 90, 90))
    makeStation(vendorRing, "TutorialGuide", "Tutorial", 135, 27, Color3.fromRGB(90, 210, 220))
    makeStation(audienceRing, "AudienceHypeManager", "Hype", 90, 29, Color3.fromRGB(255, 220, 90))

    for _, sectorInfo in ipairs(SECTOR_ORDER) do
        local sector = hordeRing:FindFirstChild("HordeSector_" .. sectorInfo.id) or Instance.new("Folder")
        sector.Name = "HordeSector_" .. sectorInfo.id
        sector:SetAttribute("SectorId", sectorInfo.id)
        sector:SetAttribute("AngleDeg", sectorInfo.angle)
        sector:SetAttribute("Health", 100)
        sector.Parent = hordeRing
        local centerCf = PolarLayout.cframeFacingCenter(51, sectorInfo.angle, 3)
        local fence = createDisplayPart(sector, "FenceSegment", Vector3.new(13, 5, 1), centerCf, Color3.fromRGB(95, 255, 120), Enum.Material.Metal)
        fence:SetAttribute("SectorId", sectorInfo.id)
        local vfx = createDisplayPart(sector, "FenceDamageVFX", Vector3.new(10, 0.4, 0.4), centerCf * CFrame.new(0, 2.9, -0.7), Color3.fromRGB(255, 80, 40), Enum.Material.Neon)
        vfx.Transparency = 0.55
        local security = createDisplayPart(sector, "SecurityLight", Vector3.new(1.2, 1.2, 1.2), centerCf * CFrame.new(-4.8, 3.8, -1), Color3.fromRGB(150, 220, 255), Enum.Material.Neon, Enum.PartType.Ball)
        local sl = security:FindFirstChildOfClass("PointLight") or Instance.new("PointLight"); sl.Name = "SecurityPointLight"; sl.Range = 18; sl.Brightness = 1.2; sl.Color = security.Color; sl.Parent = security
        local siren = createDisplayPart(sector, "SirenLight", Vector3.new(1.5, 1.5, 1.5), centerCf * CFrame.new(4.8, 3.8, -1), Color3.fromRGB(255, 35, 35), Enum.Material.Neon, Enum.PartType.Ball)
        local pl = siren:FindFirstChildOfClass("PointLight") or Instance.new("PointLight"); pl.Name = "SirenPointLight"; pl.Range = 20; pl.Brightness = 0; pl.Color = siren.Color; pl.Parent = siren
        local horde = sector:FindFirstChild("HordeCluster") or Instance.new("Model")
        horde.Name = "HordeCluster"
        horde.Parent = sector
        for i = 1, 5 do
            local offset = CFrame.new((i - 3) * 2.4, 0, 0)
            local creep = createDisplayPart(horde, "HordeFigure_" .. sectorInfo.id .. "_" .. i, Vector3.new(1.7, 3.6 + (i % 2), 1.7), PolarLayout.cframeFacingCenter(66 + (i % 2) * 3, sectorInfo.angle, 3) * offset, Color3.fromRGB(90, 255, 90), Enum.Material.Neon)
            creep.CanCollide = false
        end
        setModelPrimaryPart(horde)
        local meter = createDisplayPart(sector, "HordePressureMeter", Vector3.new(8, 1.1, 0.6), centerCf * CFrame.new(0, -2.7, -1.2), Color3.fromRGB(255, 230, 90), Enum.Material.Neon)
        meter:SetAttribute("Pressure", 0)
        createDisplayPart(sector, "WeakPointMarker", Vector3.new(2.2, 2.2, 0.5), centerCf * CFrame.new(0, 0.7, -1.25), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
        local repair = createInvisiblePart(sector, "RepairPromptAnchor", Vector3.new(5, 6, 5), centerCf * CFrame.new(0, 2, -4))
        ensurePrompt(repair, "Repair Fence", "Sector " .. sectorInfo.id)
    end

    for _, point in ipairs(PolarLayout.distribute(16, 82, 8, 11.25)) do
        local cliff = createDisplayPart(volcanoRing, "VolcanicCliff_" .. tostring(point.index), Vector3.new(11, 20 + (point.index % 3) * 5, 8), point.cframeFacingCenter, Color3.fromRGB(105, 45, 30), Enum.Material.CrackedLava)
        cliff.CanCollide = false
        local glow = cliff:FindFirstChildOfClass("PointLight") or Instance.new("PointLight")
        glow.Color = Color3.fromRGB(255, 85, 25)
        glow.Range = 24
        glow.Brightness = 1.1
        glow.Parent = cliff
    end

    local compatStage = ensureFolder(Workspace, "Stage")
    compatStage:SetAttribute("CompatibilityOnly", true)
    local aliases = {
        StartPrompt = world.VendorRing.DJ_GroanMaster,
        StoreKiosk = world.VendorRing.Vendor_Store,
        UpgradeKiosk = world.VendorRing.Vendor_UpgradeEngineer,
        MissionBoard = world.VendorRing.MissionOfficer,
        AudienceZone = world.InvisibleGameplayHitboxes.AudienceZone,
    }
    for name, target in pairs(aliases) do
        local ref = compatStage:FindFirstChild(name) or Instance.new("ObjectValue")
        ref.Name = name
        ref.Value = target
        ref.Parent = compatStage
    end
    local brainrot = ensureFolder(compatStage, "BrainrotHorde")
    local rootRef = brainrot:FindFirstChild("HordeRoot") or Instance.new("ObjectValue")
    rootRef.Name = "HordeRoot"
    rootRef.Value = world.HordeRing.HordeSector_N.HordeCluster
    rootRef.Parent = brainrot

    return world
end

local function wirePrompt(context)
    local world = Workspace:WaitForChild("GTH_WorldV2")
    local promptMap = {
        DJ_GroanMaster = "SongSelect",
        Vendor_Store = "Store",
        Vendor_UpgradeEngineer = "Upgrades",
        MissionOfficer = "Missions",
        SecurityManager = "Security",
        TutorialGuide = "Tutorial",
        AudienceHypeManager = "Hype",
    }
    for stationName, menuName in pairs(promptMap) do
        local station = world:FindFirstChild(stationName, true)
        local prompt = station and station:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            prompt.Triggered:Connect(function(player)
                if menuName == "SongSelect" and context.Remotes.OpenSongSelect then
                    context.Remotes.OpenSongSelect:FireClient(player)
                end
            end)
        end
    end
end

local function createRemotes()
    local folder = ensureFolder(ReplicatedStorage, "Remotes")
    local remotes = {}
    for _, name in ipairs(Config.RemoteNames) do
        remotes[name] = ensureRemote(folder, name)
    end
    return folder, remotes
end

local function loadServices(context)
    local serviceFolder = ServerScriptService:WaitForChild("Services")
    local serviceNames = {
        "DataService",
        "AntiExploitService",
        "ScoreService",
        "HypeService",
        "VenueService",
        "TourBusService",
        "MissionService",
        "BuffAttackService",
        "UpgradeService",
        "StoreService",
        "EconomyService",
        "SongSessionService",
        "HordeService",
        "AudienceService",
    }

    context.Services = {}
    for _, name in ipairs(serviceNames) do
        local module = require(serviceFolder:WaitForChild(name))
        context.Services[name] = module
    end

    for _, service in pairs(context.Services) do
        if service.Init then
            service:Init(context)
        end
    end
end

local function startServices(context)
    for _, service in pairs(context.Services) do
        if service.Start then
            service:Start()
        end
    end
end

local function wireRemotes(context)
    context.Remotes.StartSongRequest.OnServerEvent:Connect(function(player, payload)
        context.Services.SongSessionService:StartSong(player, payload or {})
    end)

    context.Remotes.NoteHit.OnServerEvent:Connect(function(player, payload)
        if Config.DebugRhythm then
            print("[RhythmDebug][NoteHitRemote]", player.Name, "session", payload and payload.sessionId, "song", payload and payload.songId, "note", payload and payload.noteId, "lane", payload and payload.lane, "clientSongTime", payload and payload.clientSongTime, "clientDelta", payload and payload.clientDelta)
        end
        if not context.Services.AntiExploitService:CheckRate(player, "noteHit", Config.RateLimits.NoteHitPerSecond) then
            return
        end
        context.Services.SongSessionService:NoteHit(player, payload or {})
    end)

    context.Remotes.UseBuff.OnServerEvent:Connect(function(player, payload)
        context.Services.SongSessionService:UseBuff(player, payload or {})
    end)

    context.Remotes.UseAttack.OnServerEvent:Connect(function(player, payload)
        context.Services.SongSessionService:UseAttack(player, payload or {})
    end)

    context.Remotes.AudienceAction.OnServerEvent:Connect(function(player, payload)
        if not context.Services.AntiExploitService:CheckRate(player, "audienceAction", Config.RateLimits.AudienceActionPerSecond) then
            return
        end
        context.Services.AudienceService:ApplyAudienceAction(player, payload or {})
    end)

    context.Remotes.PurchaseItem.OnServerEvent:Connect(function(player, payload)
        context.Services.StoreService:PurchaseItem(player, payload and payload.category, payload and payload.itemId)
    end)

    context.Remotes.EquipItem.OnServerEvent:Connect(function(player, payload)
        context.Services.StoreService:EquipItem(player, payload and payload.category, payload and payload.itemId)
    end)

    if context.Remotes.ClaimMission then
        context.Remotes.ClaimMission.OnServerEvent:Connect(function(player, payload)
            context.Services.MissionService:ClaimMission(player, payload and payload.missionId)
        end)
    end

end


local function installWorldV2Diagnostics()
    local diagnostics = ensureFolder(ReplicatedStorage, "Diagnostics")
    local runner = diagnostics:FindFirstChild("RunWorldV2Validation")
    if not runner then
        runner = Instance.new("BindableFunction")
        runner.Name = "RunWorldV2Validation"
        runner.Parent = diagnostics
    end
    runner.OnInvoke = function(options)
        options = type(options) == "table" and options or {}
        local Shared = ReplicatedStorage:WaitForChild("Shared")
        local result = {
            worldValidation = nil,
            unitTests = nil,
            gameTestHarness = nil,
        }
        local okWorld, worldResult = pcall(function()
            return require(Shared.WorldV2.WorldValidation).Run()
        end)
        result.worldValidation = okWorld and worldResult or { ok = false, error = tostring(worldResult) }
        if options.runUnitTests then
            local okUnit, unitResult = pcall(function()
                return require(Shared.UnitTests).Run()
            end)
            result.unitTests = okUnit and unitResult or { ok = false, error = tostring(unitResult) }
        end
        if options.runHarness then
            local okHarness, harnessResult = pcall(function()
                return require(Shared.GameTestHarness).Run()
            end)
            result.gameTestHarness = okHarness and harnessResult or { ok = false, error = tostring(harnessResult) }
        end
        print("[WorldV2Diagnostics] world", result.worldValidation and result.worldValidation.ok, "unit", result.unitTests and result.unitTests.failed, "harness", result.gameTestHarness ~= nil)
        return result
    end
    if ReplicatedStorage:GetAttribute("RunWorldV2HarnessOnBoot") or Workspace:GetAttribute("RunWorldV2HarnessOnBoot") then
        task.defer(function()
            local ok, err = pcall(function()
                runner:Invoke({ runUnitTests = true, runHarness = true })
            end)
            if not ok then
                warn("[WorldV2Diagnostics] boot harness failed", err)
            end
        end)
    end
    return runner
end

local function makeClientReadmeString()
    return ProjectReadme
end


local function startStageAtmosphere()
    local world = Workspace:FindFirstChild("GTH_WorldV2")
    if not world then return end
    local hordeRing = world:FindFirstChild("HordeRing")
    task.spawn(function()
        while true do
            if hordeRing then
                for index, sector in ipairs(hordeRing:GetChildren()) do
                    local security = sector:FindFirstChild("SecurityLight")
                    local light = security and security:FindFirstChildOfClass("PointLight")
                    if light then
                        light.Color = Color3.fromHSV((os.clock() * 0.06 + index * 0.17) % 1, 0.65, 1)
                        light.Brightness = 1.2 + math.sin(os.clock() * 1.5 + index) * 0.4
                    end
                end
            end
            task.wait(0.12)
        end
    end)
end

local context = {
    Remotes = {},
    Services = {},
    Readme = makeClientReadmeString(),
}

buildWorldV2()
local remotesFolder, remotes = createRemotes()
context.Remotes = remotes
loadServices(context)
wirePrompt(context)
wireRemotes(context)

Players.PlayerAdded:Connect(function(player)
    context.Services.DataService:PlayerAdded(player)
    local profile = context.Services.DataService:GetProfile(player)
    if profile then
        context.Services.MissionService:ResetIfNeeded(profile)
        context.Remotes.DataSnapshot:FireClient(player, context.Services.DataService:GetSnapshot(player))
    end
end)

Players.PlayerRemoving:Connect(function(player)
    context.Services.DataService:PlayerRemoving(player)
    context.Services.AntiExploitService:Clear(player)
    if context.Services.HordeService then
        local session = context.Services.SongSessionService:GetSession(player)
        if session then context.Services.HordeService:RemoveSession(session) end
    end
    context.Services.SongSessionService:RemoveSession(player)
end)

context.Services.DataService:StartAutosave()
startServices(context)
installWorldV2Diagnostics()
startStageAtmosphere()

RunService.Heartbeat:Connect(function(dt)
    context.Services.SongSessionService:Update(dt)
    if context.Services.HordeService then
        context.Services.HordeService:Update(dt)
    end
    for _, player in ipairs(Players:GetPlayers()) do
        context.Services.AudienceService:RefreshWatcher(player)
    end
end)

ReplicatedStorage:SetAttribute("GroanTubeHeroReady", true)
Workspace:SetAttribute("GroanTubeHeroReady", true)

print("Groan Tube Hero ready", context.Readme)
