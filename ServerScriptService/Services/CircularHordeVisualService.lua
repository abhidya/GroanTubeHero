local Workspace = game:GetService("Workspace")

local CircularHordeVisualService = {}

function CircularHordeVisualService.ApplyUpdate(payload)
    local world = Workspace:FindFirstChild("GTH_WorldV2")
    local hordeRing = world and world:FindFirstChild("HordeRing")
    if not hordeRing or type(payload) ~= "table" then return end
    local healths = payload.sectorHealths or {}
    local pressure = payload.sectorPressure or {}
    for _, sector in ipairs(hordeRing:GetChildren()) do
        local id = sector:GetAttribute("SectorId")
        local health = healths[id] or sector:GetAttribute("Health") or 100
        sector:SetAttribute("Health", health)
        sector:SetAttribute("Pressure", pressure[id] or 0)
        local siren = sector:FindFirstChild("SirenLight")
        local light = siren and siren:FindFirstChildOfClass("PointLight")
        if light then light.Brightness = health <= 35 and 3 or 0 end
        local fence = sector:FindFirstChild("FenceSegment")
        if fence and fence:IsA("BasePart") then
            fence.Color = health <= 35 and Color3.fromRGB(255, 70, 60) or Color3.fromRGB(95, 255, 120)
        end
    end
end

return CircularHordeVisualService
