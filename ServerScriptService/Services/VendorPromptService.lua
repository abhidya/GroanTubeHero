local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VendorDefinitions = require(ReplicatedStorage.Shared.WorldV2.VendorDefinitions)

local VendorPromptService = {}

local DIALOGUE_LINES = {
    SongSelect = "DJ GroanMaster: Pick a track. Every clean hit shoves the brainrot back.",
    Store = "Store Vendor: Fresh tube sounds, stage effects, poses, audience packs, and safe cosmetics.",
    Upgrades = "Upgrade Engineer: Speaker power, fence durability, stability recovery, combo, security, hype.",
    Missions = "Mission Officer: Clear objectives, claim rewards, then get back on stage.",
    Security = "Security Manager: Watch the eight sectors. Repair weak fences before the horde breaks through.",
    Tutorial = "Tutorial Guide: Arrows only: ← ↓ ↑ →, or tap the lanes on mobile.",
    Hype = "Hype Manager: Cheer, clap, encore. The crowd can help push the horde back.",
    TourBus = "Road Crew: Upgrade the tour bus, backstage gear, and crew support between songs.",
}

local function fireDialogue(context, player, menuName, action)
    local remote = context.Remotes and context.Remotes.NPCDialogue
    if remote then
        remote:FireClient(player, {
            menuName = menuName,
            action = action,
            text = DIALOGUE_LINES[menuName] or "Crew: Keep the stage alive and keep moving.",
        })
    end
end

function VendorPromptService.Bind(context)
    local world = Workspace:WaitForChild("GTH_WorldV2")
    local stageMic = world:FindFirstChild("GlowingStageMicPrompt", true)
    local stageMicPrompt = stageMic and stageMic:FindFirstChildWhichIsA("ProximityPrompt", true)
    if stageMicPrompt and not stageMicPrompt:GetAttribute("WorldV2Bound") then
        stageMicPrompt:SetAttribute("WorldV2Bound", true)
        stageMicPrompt:SetAttribute("MenuName", "SongSelect")
        stageMicPrompt.Triggered:Connect(function(player)
            if context.Remotes.OpenSongSelect then
                context.Remotes.OpenSongSelect:FireClient(player)
            elseif context.Remotes.OpenMenu then
                context.Remotes.OpenMenu:FireClient(player, "SongSelect")
            end
        end)
    end

    for _, def in ipairs(VendorDefinitions) do
        local station = world:FindFirstChild(def.Id, true)
        local prompt = station and station:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and not prompt:GetAttribute("WorldV2Bound") then
            prompt:SetAttribute("WorldV2Bound", true)
            prompt:SetAttribute("MenuName", def.Menu)
            prompt.Triggered:Connect(function(player)
                fireDialogue(context, player, def.Menu, def.Prompt)
                if def.Menu == "SongSelect" and context.Remotes.OpenSongSelect then
                    context.Remotes.OpenSongSelect:FireClient(player)
                elseif context.Remotes.OpenMenu then
                    context.Remotes.OpenMenu:FireClient(player, def.Menu)
                end
            end)
        end
    end

    local hordeRing = world:FindFirstChild("HordeRing")
    if hordeRing then
        for _, prompt in ipairs(world:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Name == "AudienceFanPrompt" and not prompt:GetAttribute("WorldV2FanBound") then
                prompt:SetAttribute("WorldV2FanBound", true)
                prompt.Triggered:Connect(function(player)
                    local action = prompt:GetAttribute("FanAction") or prompt.ActionText or "Cheer"
                    fireDialogue(context, player, "Hype", action)
                    if context.Services and context.Services.AudienceService then
                        pcall(function() context.Services.AudienceService:RefreshWatcher(player) end)
                        pcall(function() context.Services.AudienceService:ApplyAudienceAction(player, { action = action }) end)
                    end
                    if context.Remotes.OpenMenu then
                        context.Remotes.OpenMenu:FireClient(player, "Hype")
                    end
                end)
            end
        end
        for _, prompt in ipairs(hordeRing:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.ActionText == "Repair Fence" and not prompt:GetAttribute("WorldV2RepairBound") then
                prompt:SetAttribute("WorldV2RepairBound", true)
                prompt.Triggered:Connect(function(player)
                    local sector = prompt:FindFirstAncestorWhichIsA("Folder")
                    while sector and not tostring(sector.Name):match("^HordeSector_") do
                        sector = sector.Parent
                    end
                    local sectorId = sector and tostring(sector.Name):gsub("^HordeSector_", "")
                    if sectorId and context.Services and context.Services.HordeService then
                        fireDialogue(context, player, "Security", "Repair Fence")
                        context.Services.HordeService:RepairSector(player, sectorId, 25)
                    end
                    if context.Remotes.OpenMenu then
                        context.Remotes.OpenMenu:FireClient(player, "Security")
                    end
                end)
            end
        end
    end
end

return VendorPromptService
