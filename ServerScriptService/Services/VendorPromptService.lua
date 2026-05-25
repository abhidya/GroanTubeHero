local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VendorDefinitions = require(ReplicatedStorage.Shared.WorldV2.VendorDefinitions)

local VendorPromptService = {}

local function getDialogue(menuName, fallbackText)
    for _, def in ipairs(VendorDefinitions) do
        if def.Menu == menuName or def.Id == menuName then
            return def.Dialogue or fallbackText
        end
    end
    return fallbackText
end

local function fireDialogue(context, player, menuName, fallbackText, preferFallback)
    local remote = context and context.Remotes and context.Remotes.NPCDialogue
    if not (remote and player) then return end
    local text = (preferFallback and fallbackText) or getDialogue(menuName, fallbackText) or "Crew: Keep the stage alive."
    remote:FireClient(player, {
        menu = menuName,
        speaker = menuName or "Crew",
        text = text,
    })
end

local function configurePrompt(prompt, def)
    prompt.ActionText = def.Prompt
    prompt.ObjectText = def.ObjectText or def.Menu
    prompt:SetAttribute("MenuName", def.Menu)
    prompt:SetAttribute("Dialogue", def.Dialogue or "")
    prompt:SetAttribute("ActionPrompt", def.ActionPrompt or def.Prompt)
    prompt:SetAttribute("StationId", def.Id)
end

local function fireMenu(context, player, menuName)
    if menuName == "SongSelect" and context.Remotes.OpenSongSelect then
        context.Remotes.OpenSongSelect:FireClient(player)
    elseif context.Remotes.OpenMenu then
        context.Remotes.OpenMenu:FireClient(player, menuName)
    end
end

local function pulseWorldFeedback(menuName, source)
    local world = Workspace:FindFirstChild("GTH_WorldV2")
    if not world then return end
    local color = Color3.fromRGB(120, 240, 255)
    local folderName = nil
    if menuName == "Security" then
        folderName = "HordeRing"
        color = Color3.fromRGB(80, 255, 140)
    elseif menuName == "TourBus" or menuName == "Tour Bus" then
        folderName = "TourBusAndSpawnDressing"
        color = Color3.fromRGB(255, 115, 220)
    elseif menuName == "Hype" then
        folderName = "AudienceRing"
        color = Color3.fromRGB(255, 220, 90)
    end
    local root = (folderName and world:FindFirstChild(folderName, true)) or source or world
    for _, desc in ipairs(root:GetDescendants()) do
        if desc:IsA("BasePart") and (desc.Material == Enum.Material.Neon or tostring(desc.Name):find("Light") or tostring(desc.Name):find("Glow") or tostring(desc.Name):find("Marker")) then
            local original = desc.Color
            desc.Color = color
            desc:SetAttribute("LastMenuPulse", menuName)
            task.delay(0.75, function()
                if desc and desc.Parent then desc.Color = original end
            end)
        elseif desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then
            local originalColor = desc.Color
            local originalBrightness = desc.Brightness
            desc.Color = color
            desc.Brightness = math.max(desc.Brightness, 3)
            task.delay(0.75, function()
                if desc and desc.Parent then
                    desc.Color = originalColor
                    desc.Brightness = originalBrightness
                end
            end)
        end
    end
end

function VendorPromptService.Bind(context)
    local world = Workspace:WaitForChild("GTH_WorldV2")
    local stageMic = world:FindFirstChild("GlowingStageMicPrompt", true)
    local stageMicPrompt = stageMic and stageMic:FindFirstChildWhichIsA("ProximityPrompt", true)
    if stageMicPrompt and not stageMicPrompt:GetAttribute("WorldV2Bound") then
        stageMicPrompt:SetAttribute("WorldV2Bound", true)
        stageMicPrompt:SetAttribute("MenuName", "SongSelect")
        stageMicPrompt:SetAttribute("Dialogue", "Step to the glowing mic and launch the next Groan Tube run.")
        stageMicPrompt:SetAttribute("ActionPrompt", "Open song select")
        stageMicPrompt.Triggered:Connect(function(player)
            fireDialogue(context, player, "SongSelect", stageMicPrompt:GetAttribute("Dialogue"), true)
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
        if prompt then
            configurePrompt(prompt, def)
        end
        if prompt and not prompt:GetAttribute("WorldV2Bound") then
            prompt:SetAttribute("WorldV2Bound", true)
            prompt.Triggered:Connect(function(player)
                fireDialogue(context, player, def.Menu, def.Prompt)
                pulseWorldFeedback(def.Menu, station)
                fireMenu(context, player, def.Menu)
            end)
        end
    end

    for _, prompt in ipairs(world:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("MenuName") == "TourBus" and not prompt:GetAttribute("WorldV2Bound") then
            prompt:SetAttribute("WorldV2Bound", true)
            prompt.Triggered:Connect(function(player)
                fireDialogue(context, player, "TourBus", prompt:GetAttribute("Dialogue"), true)
                pulseWorldFeedback("TourBus", prompt.Parent)
                fireMenu(context, player, "TourBus")
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
                    pulseWorldFeedback("Hype", prompt.Parent)
                    fireMenu(context, player, "Hype")
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
                    fireDialogue(context, player, "Security", "Repair Fence")
                    if sectorId and context.Services and context.Services.HordeService then
                        context.Services.HordeService:RepairSector(player, sectorId, 25)
                    end
                    pulseWorldFeedback("Security", sector)
                    fireMenu(context, player, "Security")
                end)
            end
        end
    end
end

return VendorPromptService
