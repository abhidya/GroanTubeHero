local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VendorDefinitions = require(ReplicatedStorage.Shared.WorldV2.VendorDefinitions)

local VendorPromptService = {}

function VendorPromptService.Bind(context)
    local world = Workspace:WaitForChild("GTH_WorldV2")
    for _, def in ipairs(VendorDefinitions) do
        local station = world:FindFirstChild(def.Id, true)
        local prompt = station and station:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and not prompt:GetAttribute("WorldV2Bound") then
            prompt:SetAttribute("WorldV2Bound", true)
            prompt:SetAttribute("MenuName", def.Menu)
            prompt.Triggered:Connect(function(player)
                if def.Menu == "SongSelect" and context.Remotes.OpenSongSelect then
                    context.Remotes.OpenSongSelect:FireClient(player)
                elseif context.Remotes.OpenMenu then
                    context.Remotes.OpenMenu:FireClient(player, def.Menu)
                end
            end)
        end
    end
end

return VendorPromptService
