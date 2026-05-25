local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local ProjectReadme = require(ReplicatedStorage.Shared.ProjectReadme)

local serviceFolder = ServerScriptService:WaitForChild("Services")
local WorldV2Builder = require(serviceFolder:WaitForChild("WorldV2Builder"))
local AssetAuditService = require(serviceFolder:WaitForChild("AssetAuditService"))
local VendorPromptService = require(serviceFolder:WaitForChild("VendorPromptService"))

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

local function createRemotes()
    local folder = ensureFolder(ReplicatedStorage, "Remotes")
    local remotes = {}
    for _, name in ipairs(Config.RemoteNames) do
        remotes[name] = ensureRemote(folder, name)
    end
    remotes.OpenMenu = ensureRemote(folder, "OpenMenu")
    return folder, remotes
end

local function loadServices(context)
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
        context.Services[name] = require(serviceFolder:WaitForChild(name))
    end
    for _, service in pairs(context.Services) do
        if service.Init then service:Init(context) end
    end
end

local function startServices(context)
    for _, service in pairs(context.Services) do
        if service.Start then service:Start() end
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
        if not context.Services.AntiExploitService:CheckRate(player, "noteHit", Config.RateLimits.NoteHitPerSecond) then return end
        context.Services.SongSessionService:NoteHit(player, payload or {})
    end)
    context.Remotes.UseBuff.OnServerEvent:Connect(function(player, payload)
        context.Services.SongSessionService:UseBuff(player, payload or {})
    end)
    context.Remotes.UseAttack.OnServerEvent:Connect(function(player, payload)
        context.Services.SongSessionService:UseAttack(player, payload or {})
    end)
    context.Remotes.AudienceAction.OnServerEvent:Connect(function(player, payload)
        if not context.Services.AntiExploitService:CheckRate(player, "audienceAction", Config.RateLimits.AudienceActionPerSecond) then return end
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
    local runner = diagnostics:FindFirstChild("RunWorldV2Validation") or Instance.new("BindableFunction")
    runner.Name = "RunWorldV2Validation"
    runner.Parent = diagnostics
    runner.OnInvoke = function(options)
        options = type(options) == "table" and options or {}
        local shared = ReplicatedStorage:WaitForChild("Shared")
        local result = {}
        local okWorld, worldResult = pcall(function() return require(shared.WorldV2.WorldValidation).Run() end)
        result.worldValidation = okWorld and worldResult or { ok = false, error = tostring(worldResult) }
        if options.runUnitTests then
            local okUnit, unitResult = pcall(function() return require(shared.UnitTests).Run() end)
            result.unitTests = okUnit and unitResult or { ok = false, error = tostring(unitResult) }
        end
        if options.runHarness then
            local okHarness, harnessResult = pcall(function() return require(shared.GameTestHarness).Run() end)
            result.gameTestHarness = okHarness and harnessResult or { ok = false, error = tostring(harnessResult) }
        end
        print("[WorldV2Diagnostics]", result.worldValidation and result.worldValidation.ok, result.unitTests and result.unitTests.failed, result.gameTestHarness ~= nil)
        return result
    end
    if ReplicatedStorage:GetAttribute("RunWorldV2HarnessOnBoot") or Workspace:GetAttribute("RunWorldV2HarnessOnBoot") then
        task.defer(function()
            local ok, err = pcall(function() runner:Invoke({ runUnitTests = true, runHarness = true }) end)
            if not ok then warn("[WorldV2Diagnostics] boot harness failed", err) end
        end)
    end
    return runner
end

local function startWorldV2Atmosphere()
    task.spawn(function()
        while true do
            local world = Workspace:FindFirstChild("GTH_WorldV2")
            local hordeRing = world and world:FindFirstChild("HordeRing")
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

local context = { Remotes = {}, Services = {}, Readme = ProjectReadme }

local archived = WorldV2Builder.ArchiveOldWorld()
AssetAuditService.EnsureRoots()
local world = WorldV2Builder.Build()
local _, remotes = createRemotes()
context.Remotes = remotes
loadServices(context)
VendorPromptService.Bind(context)
wireRemotes(context)
local validation = WorldV2Builder.RunValidation()

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
startWorldV2Atmosphere()

RunService.Heartbeat:Connect(function(dt)
    context.Services.SongSessionService:Update(dt)
    if context.Services.HordeService then context.Services.HordeService:Update(dt) end
    for _, player in ipairs(Players:GetPlayers()) do
        context.Services.AudienceService:RefreshWatcher(player)
    end
end)

ReplicatedStorage:SetAttribute("GroanTubeHeroReady", true)
Workspace:SetAttribute("GroanTubeHeroReady", true)
print("Groan Tube Hero WorldV2 ready", world:GetFullName(), "archived", #archived, "validation", validation.ok, context.Readme)
