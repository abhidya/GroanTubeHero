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
    if not part then
        part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = true
        part.TopSurface = Enum.SurfaceType.Smooth
        part.BottomSurface = Enum.SurfaceType.Smooth
        part.Parent = parent
    end
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    return part
end

local function createBillboard(part, text)
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

    local base = ensurePart(stage, "StagePlatform", Vector3.new(60, 2, 40), CFrame.new(0, 3, 0), Color3.fromRGB(40, 40, 50), Enum.Material.Metal)
    base.CanCollide = true
    local singerSpot = ensurePart(stage, "SingerSpot", Vector3.new(6, 1, 6), CFrame.new(0, 4.1, -4), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
    singerSpot.CanCollide = false
    local audienceZone = ensurePart(stage, "AudienceZone", Vector3.new(24, 8, 18), CFrame.new(0, 4, 18), Color3.fromRGB(55, 55, 70), Enum.Material.ForceField)
    audienceZone.Transparency = 0.7
    audienceZone.CanCollide = false

    local startPromptPart = ensurePart(stage, "StartPrompt", Vector3.new(4, 1, 4), CFrame.new(-16, 4.5, -8), Color3.fromRGB(80, 170, 255), Enum.Material.Neon)
    startPromptPart.CanCollide = false
    local prompt = startPromptPart:FindFirstChildOfClass("ProximityPrompt") or Instance.new("ProximityPrompt")
    prompt.ActionText = "Choose Song"
    prompt.ObjectText = "START SONG"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 18
    prompt.Parent = startPromptPart
    createBillboard(startPromptPart, "START SONG")

    local storeKiosk = ensurePart(stage, "StoreKiosk", Vector3.new(5, 8, 5), CFrame.new(14, 7, -6), Color3.fromRGB(120, 255, 180), Enum.Material.SmoothPlastic)
    createBillboard(storeKiosk, "STORE")
    local upgradeKiosk = ensurePart(stage, "UpgradeKiosk", Vector3.new(5, 8, 5), CFrame.new(20, 7, -6), Color3.fromRGB(255, 220, 120), Enum.Material.SmoothPlastic)
    createBillboard(upgradeKiosk, "UPGRADES")
    local missionBoard = ensurePart(stage, "MissionBoard", Vector3.new(6, 9, 1), CFrame.new(26, 7.5, -6), Color3.fromRGB(220, 220, 255), Enum.Material.Wood)
    createBillboard(missionBoard, "MISSIONS")

    local microphone = ensurePart(stage, "MicrophoneStand", Vector3.new(1, 8, 1), CFrame.new(0, 7, -2), Color3.fromRGB(60, 60, 60), Enum.Material.Metal)
    microphone.CanCollide = false

    local speakerStacks = ensureFolder(stage, "SpeakerStacks")
    for i = 1, 2 do
        local speaker = ensurePart(speakerStacks, "SpeakerStack" .. i, Vector3.new(3, 8, 3), CFrame.new(-22 + ((i - 1) * 44), 7, -3), Color3.fromRGB(25, 25, 30), Enum.Material.Metal)
        speaker.CanCollide = true
    end

    local spotlights = ensureFolder(stage, "Spotlights")
    for i = 1, 4 do
        local lightBase = ensurePart(spotlights, "Spotlight" .. i, Vector3.new(1, 10, 1), CFrame.new(-12 + (i - 1) * 8, 10, -10), Color3.fromRGB(255, 255, 255), Enum.Material.Metal)
        lightBase.CanCollide = false
        local light = lightBase:FindFirstChildOfClass("SpotLight") or Instance.new("SpotLight")
        light.Angle = 70
        light.Brightness = 2
        light.Range = 18
        light.Parent = lightBase
    end

    local venueSigns = ensureFolder(stage, "VenueSigns")
    local sign = ensurePart(venueSigns, "MainSign", Vector3.new(24, 6, 1), CFrame.new(0, 13, -12), Color3.fromRGB(70, 70, 90), Enum.Material.SmoothPlastic)
    createBillboard(sign, "GROAN TUBE HERO")

    local crowd = ensureFolder(stage, "Crowd")
    for i = 1, 8 do
        local c = ensurePart(crowd, "Crowd" .. i, Vector3.new(2, 5, 2), CFrame.new(-14 + i * 4, 1.5, 24 + (i % 2) * 2), Color3.fromRGB(90, 90, 100), Enum.Material.SmoothPlastic)
        c.CanCollide = false
    end

    local busBase = ensurePart(tourBus, "BusBody", Vector3.new(22, 8, 10), CFrame.new(50, 7, 18), Color3.fromRGB(25, 25, 35), Enum.Material.Metal)
    local wrap = Instance.new("SelectionBox")
    wrap.Adornee = busBase
    wrap.LineThickness = 0.04
    wrap.Color3 = Color3.fromRGB(0, 255, 255)
    wrap.Parent = busBase
    for i = 1, 4 do
        local wheel = ensurePart(tourBus, "Wheel" .. i, Vector3.new(3, 3, 3), CFrame.new(41 + ((i - 1) % 2) * 14, 2, 13 + math.floor((i - 1) / 2) * 10), Color3.fromRGB(10, 10, 10), Enum.Material.Rubber)
        wheel.Shape = Enum.PartType.Cylinder
        wheel.CanCollide = false
    end
    createBillboard(busBase, "TOUR BUS")

    local pathFolder = ensureFolder(stage, "SpawnPath")
    for i = 1, 7 do
        local pad = ensurePart(pathFolder, "ArrowPad" .. i, Vector3.new(5, 0.25, 3), CFrame.new(-34 + i * 4, 3.2, -10 + i), Color3.fromRGB(255, 230, 80), Enum.Material.Neon)
        pad.CanCollide = false
        pad.Transparency = 0.15
    end
    local audienceSign = ensurePart(stage, "AudienceSign", Vector3.new(8, 5, 1), CFrame.new(-22, 6.5, 18), Color3.fromRGB(80, 170, 255), Enum.Material.SmoothPlastic)
    createBillboard(audienceSign, "AUDIENCE ZONE")
end

local function wirePrompt(context)
    local stage = Workspace:WaitForChild("Stage")
    local promptPart = stage:WaitForChild("StartPrompt")
    local prompt = promptPart:WaitForChild("ProximityPrompt")
    prompt.Triggered:Connect(function(player)
        -- Prompt opens song select on the client; the server still starts songs only
        -- after StartSongRequest and server-side validation.
        context.Remotes.StartSong:FireClient(player, { openSongSelect = true })
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
    context.Services.SongSessionService:RemoveSession(player)
end)

context.Services.DataService:StartAutosave()
startServices(context)
startStageAtmosphere()

RunService.Heartbeat:Connect(function(dt)
    context.Services.SongSessionService:Update(dt)
    for _, player in ipairs(Players:GetPlayers()) do
        context.Services.AudienceService:RefreshWatcher(player)
    end
end)

ReplicatedStorage:SetAttribute("GroanTubeHeroReady", true)
Workspace:SetAttribute("GroanTubeHeroReady", true)

print("Groan Tube Hero ready", context.Readme)
