local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CosmeticConfig = require(ReplicatedStorage.Shared.CosmeticConfig)
local UpgradeConfig = require(ReplicatedStorage.Shared.UpgradeConfig)
local BuffConfig = require(ReplicatedStorage.Shared.BuffConfig)

local StoreService = {}
StoreService.__index = StoreService

function StoreService:Init(runtimeContext)
    self.context = runtimeContext
    self.lastRequest = {}
end

function StoreService:IsDebounced(player)
    local nowTime = os.clock()
    local last = self.lastRequest[player.UserId] or 0
    if nowTime - last < Config.RateLimits.StoreDebounceSeconds then
        return true
    end
    self.lastRequest[player.UserId] = nowTime
    return false
end

function StoreService:GetPrice(category, itemId)
    local item = CosmeticConfig.Get(category, itemId) or BuffConfig.Get(itemId)
    if not item then
        return nil
    end
    return item.price, item.currency
end

function StoreService:PurchaseItem(player, category, itemId)
    if self:IsDebounced(player) then
        return false, "Debounced"
    end
    local data = self.context.Services.DataService:GetProfile(player)
    if not data then
        return false, "NoData"
    end

    if category == "GameplayUpgrades" then
        return self.context.Services.UpgradeService:PurchaseUpgrade(player, itemId)
    end

    if category == "VIP" and itemId == "VIPPass" then
        if data.VIP then
            return true, "AlreadyVIP"
        end
        data.VIP = true
        data.SongUnlocks = data.SongUnlocks or {}
        data.SongUnlocks.Downloads = true
        data.OwnedCosmetics = data.OwnedCosmetics or {}
        data.OwnedCosmetics.Buffs = data.OwnedCosmetics.Buffs or {}
        data.OwnedCosmetics.Buffs.DeepBreath = true
        data.OwnedCosmetics.Buffs.CrowdCall = true
        self.context.Services.DataService:SavePlayer(player)
        self.context.Services.DataService:UpdateProfile(player, function(profile) return profile end)
        return true, "VIPUnlocked"
    end

    local item = CosmeticConfig.Get(category, itemId)
    if not item then
        return false, "UnknownItem"
    end
    data.OwnedCosmetics = data.OwnedCosmetics or {}
    data.OwnedCosmetics[category] = data.OwnedCosmetics[category] or {}
    if data.OwnedCosmetics[category][itemId] then
        return true, "AlreadyOwned"
    end

    local price = item.price or 0
    local currency = item.currency or "Coins"
    if price > 0 then
        if not self.context.Services.DataService:SpendCurrency(player, currency, price) then
            return false, "InsufficientCurrency"
        end
    end
    data.OwnedCosmetics[category][itemId] = true
    self.context.Services.DataService:SavePlayer(player)
    self.context.Services.DataService:UpdateProfile(player, function(profile)
        return profile
    end)
    return true, "Purchased"
end

function StoreService:EquipItem(player, category, itemId)
    if self:IsDebounced(player) then
        return false, "Debounced"
    end
    local data = self.context.Services.DataService:GetProfile(player)
    if not data then
        return false, "NoData"
    end
    if not data.OwnedCosmetics or not data.OwnedCosmetics[category] or not data.OwnedCosmetics[category][itemId] then
        return false, "NotOwned"
    end
    if not CosmeticConfig.Get(category, itemId) then
        return false, "UnknownItem"
    end
    data.Equipped = data.Equipped or {}
    data.Equipped[category] = itemId
    self.context.Services.DataService:SavePlayer(player)
    self.context.Services.DataService:UpdateProfile(player, function(profile)
        return profile
    end)
    return true, "Equipped"
end

function StoreService:GetCatalog()
    local catalog = {
        TubeSounds = CosmeticConfig.Items.TubeSounds,
        StageEffects = CosmeticConfig.Items.StageEffects,
        AvatarPoses = CosmeticConfig.Items.AvatarPoses,
        AudiencePacks = CosmeticConfig.Items.AudiencePacks,
        StageThemes = CosmeticConfig.Items.StageThemes,
        GameplayUpgrades = UpgradeConfig.Upgrades,
        Buffs = CosmeticConfig.Items.Buffs,
    }
    return catalog
end

return StoreService
