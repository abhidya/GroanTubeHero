local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local Config = require(ReplicatedStorage.Shared.Config)
local ClientState = require(ReplicatedStorage.Shared.ClientState)

local function pulseColor(target, property, fromColor, toColor, duration)
    target[property] = fromColor
    local tween = TweenService:Create(target, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { [property] = toColor })
    tween:Play()
end

local function flashLighting(color, brightness)
    local bloom = Lighting:FindFirstChild("GroanBloom") or Instance.new("ColorCorrectionEffect")
    bloom.Name = "GroanBloom"
    bloom.Parent = Lighting
    bloom.TintColor = color
    bloom.Contrast = brightness
    task.delay(0.2, function()
        if bloom then
            bloom.TintColor = Color3.new(1, 1, 1)
            bloom.Contrast = 0
        end
    end)
end

local function updateStageColor(color)
    local world = workspace:FindFirstChild("GTH_WorldV2")
    local hordeRing = world and world:FindFirstChild("HordeRing")
    if hordeRing then
        for _, sector in ipairs(hordeRing:GetChildren()) do
            local lightBase = sector:FindFirstChild("SecurityLight")
            local light = lightBase and lightBase:FindFirstChildOfClass("PointLight")
            if light then
                light.Color = color
                light.Brightness = 3
            end
        end
        return
    end
    local stage = workspace:FindFirstChild("Stage")
    local spotlights = stage and stage:FindFirstChild("Spotlights")
    if not spotlights then return end
    for _, lightBase in ipairs(spotlights:GetChildren()) do
        local light = lightBase:FindFirstChildOfClass("SpotLight")
        if light then
            light.Color = color
            light.Brightness = 3
        end
    end
end

local function playGroan(kind)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://0"
    sound.Volume = 0.6
    sound.Parent = workspace.CurrentCamera or workspace
    sound:Play()
    task.delay(0.25, function()
        sound:Destroy()
    end)
end

remotes.NoteJudged.OnClientEvent:Connect(function(payload)
    local visuals = payload.visuals or {}
    if payload.judgement == "Perfect" then
        playGroan("Perfect")
        flashLighting(Color3.fromRGB(120, 255, 190), 0.15)
        updateStageColor(Color3.fromRGB(120, 240, 255))
    elseif payload.judgement == "Good" then
        playGroan("Good")
        flashLighting(Color3.fromRGB(160, 200, 255), 0.05)
    else
        playGroan("Miss")
        flashLighting(Color3.fromRGB(255, 130, 130), 0.3)
        local cam = workspace.CurrentCamera
        if cam then
            local offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(1.5))
            cam.CFrame = cam.CFrame * offset
        end
    end
    if visuals.spotlightDrift then
        updateStageColor(Color3.fromRGB(255, 180, 255))
    end
    if visuals.booWave then
        flashLighting(Color3.fromRGB(220, 160, 160), 0.2)
    end
    if visuals.micFeedback then
        flashLighting(Color3.fromRGB(255, 255, 255), 0.4)
    end
    if visuals.tomatoSplash then
        flashLighting(Color3.fromRGB(255, 180, 120), 0.25)
    end
end)

remotes.AudienceAction.OnClientEvent:Connect(function(payload)
    if payload.action == "BuffUsed" then
        flashLighting(Color3.fromRGB(200, 255, 170), 0.05)
    elseif payload.action == "AttackApplied" then
        flashLighting(Color3.fromRGB(255, 120, 120), 0.25)
    end
end)

remotes.SongFinished.OnClientEvent:Connect(function(payload)
    flashLighting(Color3.fromRGB(255, 255, 255), 0.05)
    local profile = ClientState.GetSnapshot and ClientState.GetSnapshot() or nil
    if profile and profile.Equipped then
        local visuals = require(ReplicatedStorage.Shared.CosmeticConfig).GetVisualProfile(profile.Equipped)
        updateStageColor(visuals.laneFlash or Color3.fromRGB(255, 255, 255))
    end
end)
