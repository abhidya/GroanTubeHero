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

local function ensurePart(parent, name, size, cframe, color, material)
    local part = parent:FindFirstChild(name)
    if part then
        -- Preserve hand-placed/imported Studio assets. Bootstrapping must not flatten meshes,
        -- signs, custom stages, or user-positioned props on every server start.
        return part
    end
    part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.CanCollide = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.Parent = parent
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
    if not part or not part:IsA("BasePart") then return nil end
    local prompt = part:FindFirstChildOfClass("ProximityPrompt") or Instance.new("ProximityPrompt")
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.HoldDuration = 0.15
    prompt.MaxActivationDistance = 18
    prompt.Parent = part
    return prompt
end

local function createBillboard(part, text)
    if not part or not part:IsA("BasePart") then return end
    local gui = part:FindFirstChildOfClass("BillboardGui") or Instance.new("BillboardGui")
    gui.Size = UDim2.new(0, 260, 0, 70)
    gui.StudsOffset = Vector3.new(0, 4, 0)
    gui.AlwaysOnTop = true
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

local function buildMap()
    local stage = ensureFolder(Workspace, "Stage")
    local tourBus = ensureFolder(Workspace, "TourBus")
    local unusedAssets = Workspace:FindFirstChild("Unused_MapAssets")
    local importedStage = unusedAssets and unusedAssets:FindFirstChild("Stage")
    local existingStagePlatform = stage:FindFirstChild("StagePlatform")
    if importedStage and existingStagePlatform and existingStagePlatform:IsA("BasePart") then
        existingStagePlatform.Name = "ProgrammaticStagePlatform"
        existingStagePlatform.Parent = unusedAssets
    end
    if importedStage and not stage:FindFirstChild("StagePlatform") then
        importedStage.Name = "StagePlatform"
        importedStage.Parent = stage
        if importedStage:IsA("Model") then
            setModelPrimaryPart(importedStage)
            importedStage:PivotTo(CFrame.new(0, 3, 0))
            for _, part in ipairs(importedStage:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                    part.CanCollide = true
                end
            end
        elseif importedStage:IsA("BasePart") then
            importedStage.Anchored = true
            importedStage.CanCollide = true
            importedStage.CFrame = CFrame.new(0, 3, 0)
        end
    end
    local ledPanel = unusedAssets and unusedAssets:FindFirstChild("LED panel")
    if ledPanel and not stage:FindFirstChild("LED panel") then
        ledPanel.Parent = stage
        if ledPanel:IsA("BasePart") then
            ledPanel.Anchored = true
            ledPanel.CanCollide = false
            ledPanel.CFrame = CFrame.new(0, 11, -15)
        elseif ledPanel:IsA("Model") then
            setModelPrimaryPart(ledPanel)
            ledPanel:PivotTo(CFrame.new(0, 11, -15))
        end
    end

    local base = stage:FindFirstChild("StagePlatform") or ensurePart(stage, "StagePlatform", Vector3.new(60, 2, 40), CFrame.new(0, 3, 0), Color3.fromRGB(40, 40, 50), Enum.Material.Metal)
    setBasePart(base, { CanCollide = true })
    local singerSpot = ensurePart(stage, "SingerSpot", Vector3.new(6, 1, 6), CFrame.new(0, 4.1, -4), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
    setBasePart(singerSpot, { CanCollide = false })
    local audienceZone = ensurePart(stage, "AudienceZone", Vector3.new(24, 8, 18), CFrame.new(0, 4, 18), Color3.fromRGB(55, 55, 70), Enum.Material.ForceField)
    setBasePart(audienceZone, { Transparency = 0.7, CanCollide = false })

    local startPromptPart = ensurePart(stage, "StartPrompt", Vector3.new(4, 1, 4), CFrame.new(-16, 4.5, -8), Color3.fromRGB(80, 170, 255), Enum.Material.Neon)
    setBasePart(startPromptPart, { CanCollide = false })
    local prompt = ensurePrompt(startPromptPart, "Choose Song", "START SONG")
    if prompt then prompt.HoldDuration = 0.5 end
    createBillboard(startPromptPart, "START SONG")

    local storeKiosk = ensurePart(stage, "StoreKiosk", Vector3.new(5, 8, 5), CFrame.new(14, 7, -6), Color3.fromRGB(120, 255, 180), Enum.Material.SmoothPlastic)
    createBillboard(storeKiosk, "STORE")
    local upgradeKiosk = ensurePart(stage, "UpgradeKiosk", Vector3.new(5, 8, 5), CFrame.new(20, 7, -6), Color3.fromRGB(255, 220, 120), Enum.Material.SmoothPlastic)
    createBillboard(upgradeKiosk, "UPGRADES")
    local missionBoard = ensurePart(stage, "MissionBoard", Vector3.new(6, 9, 1), CFrame.new(26, 7.5, -6), Color3.fromRGB(220, 220, 255), Enum.Material.Wood)
    createBillboard(missionBoard, "MISSIONS")

    local microphone = ensurePart(stage, "MicrophoneStand", Vector3.new(1, 8, 1), CFrame.new(0, 7, -2), Color3.fromRGB(60, 60, 60), Enum.Material.Metal)
    setBasePart(microphone, { CanCollide = false })

    local speakerStacks = ensureFolder(stage, "SpeakerStacks")
    for i = 1, 2 do
        local speaker = ensurePart(speakerStacks, "SpeakerStack" .. i, Vector3.new(3, 8, 3), CFrame.new(-22 + ((i - 1) * 44), 7, -3), Color3.fromRGB(25, 25, 30), Enum.Material.Metal)
        setBasePart(speaker, { CanCollide = true })
    end

    local spotlights = ensureFolder(stage, "Spotlights")
    for i = 1, 4 do
        local lightBase = ensurePart(spotlights, "Spotlight" .. i, Vector3.new(1, 10, 1), CFrame.new(-12 + (i - 1) * 8, 10, -10), Color3.fromRGB(255, 255, 255), Enum.Material.Metal)
        setBasePart(lightBase, { CanCollide = false })
        local light = lightBase:FindFirstChildOfClass("SpotLight") or Instance.new("SpotLight")
        light.Angle = 70
        light.Brightness = 2
        light.Range = 18
        light.Parent = lightBase
    end


    local hordeFolder = ensureFolder(stage, "BrainrotHorde")
    local farPoint = ensurePart(hordeFolder, "HordeFarPoint", Vector3.new(2, 2, 2), CFrame.new(0, 4, -72), Color3.fromRGB(255, 80, 80), Enum.Material.Neon)
    setBasePart(farPoint, { Transparency = 1, CanCollide = false })
    local nearPoint = ensurePart(hordeFolder, "HordeNearStagePoint", Vector3.new(2, 2, 2), CFrame.new(0, 4, -16), Color3.fromRGB(255, 255, 80), Enum.Material.Neon)
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
            local creep = ensurePart(hordeRoot, "Brainrot" .. i, Vector3.new(2.4, 4 + (i % 3), 2.4), CFrame.new(col * 4, 4, -72 + row * 4), Color3.fromRGB(90, 255, 90), Enum.Material.Neon)
            setBasePart(creep, { CanCollide = false, Shape = Enum.PartType.Block })
        end
        setModelPrimaryPart(hordeRoot)
    elseif hordeRoot:IsA("Model") then
        setModelPrimaryPart(hordeRoot)
    end
    local lane = ensurePart(stage, "BrainrotHordeLane", Vector3.new(22, 0.5, 64), CFrame.new(0, 2.8, -44), Color3.fromRGB(80, 30, 30), Enum.Material.CrackedLava)
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
            local volcano = ensurePart(backdrop, "Volcano" .. i, Vector3.new(10, 22, 10), CFrame.new(math.cos(angle) * 34, 10, -70 + math.sin(angle) * 12), Color3.fromRGB(130, 45, 25), Enum.Material.CrackedLava)
            setBasePart(volcano, { Anchored = true, CanCollide = false })
            if volcano:IsA("BasePart") then
                local fire = volcano:FindFirstChildOfClass("PointLight") or Instance.new("PointLight")
                fire.Color = Color3.fromRGB(255, 80, 20)
                fire.Range = 22
                fire.Brightness = 2
                fire.Parent = volcano
            end
        end
    end
    local hordeSign = ensurePart(stage, "BrainrotHordeSign", Vector3.new(16, 5, 1), CFrame.new(0, 8, -18), Color3.fromRGB(90, 255, 90), Enum.Material.SmoothPlastic)
    createBillboard(hordeSign, "BRAINROT HORDE")

    local venueSigns = ensureFolder(stage, "VenueSigns")
    local sign = ensurePart(venueSigns, "MainSign", Vector3.new(24, 6, 1), CFrame.new(0, 13, -12), Color3.fromRGB(70, 70, 90), Enum.Material.SmoothPlastic)
    createBillboard(sign, "GROAN TUBE HERO")

    local crowd = ensureFolder(stage, "Crowd")
    for i = 1, 8 do
        local c = ensurePart(crowd, "Crowd" .. i, Vector3.new(2, 5, 2), CFrame.new(-14 + i * 4, 1.5, 24 + (i % 2) * 2), Color3.fromRGB(90, 90, 100), Enum.Material.SmoothPlastic)
        setBasePart(c, { CanCollide = false })
    end

    local busBase = ensurePart(tourBus, "BusBody", Vector3.new(22, 8, 10), CFrame.new(50, 7, 18), Color3.fromRGB(25, 25, 35), Enum.Material.Metal)
    local wrap = Instance.new("SelectionBox")
    wrap.Adornee = busBase
    wrap.LineThickness = 0.04
    wrap.Color3 = Color3.fromRGB(0, 255, 255)
    wrap.Parent = busBase
    for i = 1, 4 do
        local wheel = ensurePart(tourBus, "Wheel" .. i, Vector3.new(3, 3, 3), CFrame.new(41 + ((i - 1) % 2) * 14, 2, 13 + math.floor((i - 1) / 2) * 10), Color3.fromRGB(10, 10, 10), Enum.Material.Rubber)
        setBasePart(wheel, { Shape = Enum.PartType.Cylinder, CanCollide = false })
    end
    createBillboard(busBase, "TOUR BUS")

    local pathFolder = ensureFolder(stage, "SpawnPath")
    for i = 1, 7 do
        local pad = ensurePart(pathFolder, "ArrowPad" .. i, Vector3.new(5, 0.25, 3), CFrame.new(-34 + i * 4, 3.2, -10 + i), Color3.fromRGB(255, 230, 80), Enum.Material.Neon)
        setBasePart(pad, { CanCollide = false, Transparency = 0.15 })
    end
    local audienceSign = ensurePart(stage, "AudienceSign", Vector3.new(8, 5, 1), CFrame.new(-22, 6.5, 18), Color3.fromRGB(80, 170, 255), Enum.Material.SmoothPlastic)
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
            ensurePrompt(signPart, values[1], values[2])
            createBillboard(signPart, values[2])
        end
    end
end

local function wirePrompt(context)
    local stage = Workspace:WaitForChild("Stage")
    local promptPart = stage:WaitForChild("StartPrompt")
    local prompt = promptPart:WaitForChild("ProximityPrompt")
    prompt.Triggered:Connect(function(player)
        -- Dedicated song-select remote; keep StartSong fallback for older clients.
        if context.Remotes.OpenSongSelect then
            context.Remotes.OpenSongSelect:FireClient(player)
        else
            context.Remotes.StartSong:FireClient(player, { openSongSelect = true })
        end
    end)
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

local function makeClientReadmeString()
    return ProjectReadme
end


local function startStageAtmosphere()
    local stage = Workspace:FindFirstChild("Stage")
    if not stage then return end
    local spotlights = stage:FindFirstChild("Spotlights")
    local speakerStacks = stage:FindFirstChild("SpeakerStacks")
    task.spawn(function()
        while true do
            if spotlights then
                for index, lightBase in ipairs(spotlights:GetChildren()) do
                    local light = lightBase:FindFirstChildOfClass("SpotLight")
                    if light then
                        light.Color = Color3.fromHSV((os.clock() * 0.06 + index * 0.17) % 1, 0.65, 1)
                        light.Brightness = 2 + math.sin(os.clock() * 1.5 + index) * 0.6
                    end
                end
            end
            if speakerStacks then
                for _, speaker in ipairs(speakerStacks:GetChildren()) do
                    if speaker:IsA("BasePart") then
                        speaker.Size = Vector3.new(3, 8 + math.sin(os.clock() * 3) * 0.25, 3)
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

buildMap()
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
