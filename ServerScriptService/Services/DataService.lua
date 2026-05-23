local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CosmeticConfig = require(ReplicatedStorage.Shared.CosmeticConfig)

local DataService = {}
DataService.__index = DataService

local STORE_NAME = "GroanTubeHero_Profile_v1"
local STORE = nil
local SESSION_ONLY = RunService:IsStudio()
local cache = {}
local context = nil

local function cloneDefaults()
    local profile = Config.DeepCopy(Config.DefaultProfile)
    profile.OwnedCosmetics = CosmeticConfig.GetDefaultOwned()
    profile.Equipped = Config.DeepCopy(Config.DefaultProfile.Equipped)
    return profile
end

local function ensureDataShape(data)
    local profile = cloneDefaults()
    if type(data) ~= "table" then
        return profile
    end

    for key, value in pairs(data) do
        if type(profile[key]) == "table" and type(value) == "table" then
            profile[key] = Config.DeepCopy(value)
        elseif value ~= nil then
            profile[key] = value
        end
    end

    if type(profile.BestScores) ~= "table" then
        profile.BestScores = { Career = {}, Pure = {} }
    end
    profile.BestScores.Career = profile.BestScores.Career or {}
    profile.BestScores.Pure = profile.BestScores.Pure or {}

    if type(profile.OwnedCosmetics) ~= "table" then
        profile.OwnedCosmetics = CosmeticConfig.GetDefaultOwned()
    end
    for category, defaults in pairs(CosmeticConfig.GetDefaultOwned()) do
        profile.OwnedCosmetics[category] = profile.OwnedCosmetics[category] or {}
        for itemId in pairs(defaults) do
            profile.OwnedCosmetics[category][itemId] = true
        end
    end

    profile.Equipped = profile.Equipped or Config.DeepCopy(Config.DefaultProfile.Equipped)
    profile.Upgrades = profile.Upgrades or Config.DeepCopy(Config.DefaultProfile.Upgrades)
    profile.Missions = profile.Missions or Config.DeepCopy(Config.DefaultProfile.Missions)
    profile.TourBus = profile.TourBus or Config.DeepCopy(Config.DefaultProfile.TourBus)
    profile.SessionHistory = profile.SessionHistory or { Career = {}, Pure = {} }
    profile.SessionHistory.Career = profile.SessionHistory.Career or {}
    profile.SessionHistory.Pure = profile.SessionHistory.Pure or {}
    profile.SongUnlocks = profile.SongUnlocks or { Downloads = false }
    if profile.VIP then
        profile.SongUnlocks.Downloads = true
    end

    return profile
end

local function snapshot(profile)
    return Config.DeepCopy(profile)
end

local function ensureLeaderstats(player, profile)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end

    local function setValue(name, value)
        local stat = leaderstats:FindFirstChild(name)
        if not stat then
            stat = Instance.new("IntValue")
            stat.Name = name
            stat.Parent = leaderstats
        end
        stat.Value = value or 0
    end

    setValue("Level", profile.Level)
    setValue("XP", profile.XP)
    setValue("Fans", profile.Fans)
    setValue("Coins", profile.Coins)
    setValue("Tickets", profile.Tickets)
    setValue("GroanTokens", profile.GroanTokens)
end

local function syncLeaderstats(player)
    local profile = cache[player.UserId]
    if not profile then
        return
    end
    ensureLeaderstats(player, profile)
end

function DataService:Init(runtimeContext)
    context = runtimeContext
    pcall(function()
        STORE = DataStoreService:GetDataStore(STORE_NAME)
    end)
end

function DataService:GetProfile(player)
    return cache[player.UserId]
end

function DataService:SetProfile(player, profile)
    cache[player.UserId] = profile
    syncLeaderstats(player)
    if context and context.Remotes and context.Remotes.DataSnapshot then
        context.Remotes.DataSnapshot:FireClient(player, snapshot(profile))
    end
end

function DataService:UpdateProfile(player, mutator)
    local profile = cache[player.UserId]
    if not profile then
        return nil
    end
    local result = mutator(profile) or profile
    cache[player.UserId] = result
    syncLeaderstats(player)
    if context and context.Remotes and context.Remotes.DataSnapshot then
        context.Remotes.DataSnapshot:FireClient(player, snapshot(result))
    end
    return result
end

function DataService:LoadPlayer(player)
    local profile = cloneDefaults()
    local loaded = false

    if not SESSION_ONLY and STORE then
        local success, result = pcall(function()
            return STORE:GetAsync(tostring(player.UserId))
        end)
        if success and result then
            profile = ensureDataShape(result)
            loaded = true
        else
            warn("Groan Tube Hero: DataStore load fallback for", player.Name)
        end
    end

    profile = ensureDataShape(profile)
    cache[player.UserId] = profile
    ensureLeaderstats(player, profile)

    if context and context.Remotes and context.Remotes.DataSnapshot then
        context.Remotes.DataSnapshot:FireClient(player, snapshot(profile))
    end

    return profile, loaded
end

function DataService:SavePlayer(player)
    local profile = cache[player.UserId]
    if not profile then
        return false
    end

    if SESSION_ONLY or not STORE then
        return true
    end

    local success, err = pcall(function()
        STORE:SetAsync(tostring(player.UserId), snapshot(profile))
    end)
    if not success then
        warn("Groan Tube Hero: DataStore save fallback for", player.Name, err)
        return false
    end
    return true
end

function DataService:PlayerAdded(player)
    self:LoadPlayer(player)
end

function DataService:PlayerRemoving(player)
    self:SavePlayer(player)
    cache[player.UserId] = nil
end

function DataService:Award(player, rewards)
    return self:UpdateProfile(player, function(profile)
        profile.Fans = math.max(0, profile.Fans + (rewards.Fans or 0))
        profile.Coins = math.max(0, profile.Coins + (rewards.Coins or 0))
        profile.XP = math.max(0, profile.XP + (rewards.XP or 0))
        profile.Tickets = math.max(0, profile.Tickets + (rewards.Tickets or 0))
        profile.GroanTokens = math.max(0, profile.GroanTokens + (rewards.GroanTokens or 0))
        return profile
    end)
end

function DataService:SpendCurrency(player, currency, amount)
    local profile = cache[player.UserId]
    if not profile or amount <= 0 then
        return false
    end
    if currency == "Fans" and profile.Fans >= amount then
        profile.Fans = profile.Fans - amount
    elseif currency == "Coins" and profile.Coins >= amount then
        profile.Coins = profile.Coins - amount
    elseif currency == "Tickets" and profile.Tickets >= amount then
        profile.Tickets = profile.Tickets - amount
    elseif currency == "GroanTokens" and profile.GroanTokens >= amount then
        profile.GroanTokens = profile.GroanTokens - amount
    else
        return false
    end
    syncLeaderstats(player)
    if context and context.Remotes and context.Remotes.DataSnapshot then
        context.Remotes.DataSnapshot:FireClient(player, snapshot(profile))
    end
    return true
end

function DataService:EnsureOwned(profile, category, itemId)
    profile.OwnedCosmetics = profile.OwnedCosmetics or {}
    profile.OwnedCosmetics[category] = profile.OwnedCosmetics[category] or {}
    profile.OwnedCosmetics[category][itemId] = true
end

function DataService:HasOwned(profile, category, itemId)
    return profile.OwnedCosmetics
        and profile.OwnedCosmetics[category]
        and profile.OwnedCosmetics[category][itemId]
end

function DataService:GetSnapshot(player)
    local profile = cache[player.UserId]
    if not profile then
        return nil
    end
    return snapshot(profile)
end

function DataService:StartAutosave()
    task.spawn(function()
        while true do
            task.wait(Config.Economy.AutoSaveSeconds)
            for _, player in ipairs(Players:GetPlayers()) do
                self:SavePlayer(player)
            end
        end
    end)
end

return DataService
