local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HapticService = game:GetService("HapticService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local Config = require(ReplicatedStorage.Shared.Config)
local ClientState = require(ReplicatedStorage.Shared.ClientState)

local updateStageColor

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

local function hapticPulse(strength)
    pcall(function()
        if HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1) then
            HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, math.clamp(strength, 0, 1))
            task.delay(0.12, function()
                pcall(function() HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0) end)
            end)
        end
    end)
end

local function cameraShake(power, duration)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local untilTime = os.clock() + duration
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() >= untilTime or not cam then
            if conn then conn:Disconnect() end
            return
        end
        local p = power * ((untilTime - os.clock()) / math.max(duration, 0.01))
        cam.CFrame = cam.CFrame * CFrame.new(math.random(-100, 100) / 100 * p, math.random(-100, 100) / 130 * p, 0) * CFrame.Angles(0, 0, math.rad(math.random(-100, 100) / 100 * p * 3))
    end)
end

local function pulseWorldLights(color, brightness, duration)
    local world = workspace:FindFirstChild("GTH_WorldV2")
    if not world then return end
    for _, desc in ipairs(world:GetDescendants()) do
        if desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then
            desc.Color = color
            desc.Brightness = math.max(desc.Brightness, brightness)
        elseif desc:IsA("BasePart") and (desc.Material == Enum.Material.Neon or tostring(desc.Name):find("Light") or tostring(desc.Name):find("Glow")) then
            desc.Color = color
        end
    end
    task.delay(duration, function()
        if world then updateStageColor(Color3.fromRGB(120, 240, 255)) end
    end)
end

local function lightningMode(combo)
    local color = combo >= 30 and Color3.fromRGB(185, 110, 255) or combo >= 20 and Color3.fromRGB(80, 220, 255) or Color3.fromRGB(255, 240, 120)
    flashLighting(color, combo >= 30 and 0.38 or 0.22)
    pulseWorldLights(color, combo >= 30 and 8 or 5, 0.55)
    cameraShake(combo >= 30 and 0.20 or 0.12, 0.28)
    hapticPulse(combo >= 30 and 0.75 or 0.45)
end

local function showCinematicText(text, subtext, color)
    local gui = player:FindFirstChildOfClass("PlayerGui") and player.PlayerGui:FindFirstChild("StageCinematicGui")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "StageCinematicGui"
        gui.IgnoreGuiInset = false
        gui.ResetOnSpawn = false
        gui.Parent = player:WaitForChild("PlayerGui")
        local label = Instance.new("TextLabel")
        label.Name = "Title"
        label.BackgroundTransparency = 0.25
        label.BackgroundColor3 = Color3.fromRGB(5, 8, 18)
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.Position = UDim2.fromScale(0.5, 0.22)
        label.Size = UDim2.new(0.84, 0, 0.18, 0)
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.TextStrokeTransparency = 0.35
        label.Parent = gui
    end
    local label = gui:FindFirstChild("Title")
    if label then
        label.Visible = true
        label.Text = text .. "\n" .. subtext
        label.TextColor3 = color
        label.TextTransparency = 0
        task.delay(2.4, function()
            if label then label.Visible = false end
        end)
    end
end

function updateStageColor(color)
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
    local combo = tonumber(payload.combo) or 0
    if combo >= 10 and combo % 10 == 0 then
        lightningMode(combo)
        showCinematicText("COMBO LIGHTNING", tostring(combo) .. " streak blasts the brainrot back", Color3.fromRGB(120, 240, 255))
    end
    if payload.judgement == "Perfect" or payload.judgement == "Good" then
        hapticPulse(payload.judgement == "Perfect" and 0.28 or 0.18)
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
    local summary = payload and payload.summary or {}
    local won = not summary.downed
    flashLighting(won and Color3.fromRGB(130, 255, 190) or Color3.fromRGB(255, 120, 120), won and 0.2 or 0.35)
    cameraShake(won and 0.28 or 0.18, 0.7)
    hapticPulse(won and 0.8 or 0.35)
    showCinematicText(won and "BRAINROT HORDE BEATEN" or "HORDE STILL SURGING", won and "Your music pushed the demons back" or "Regroup at Security and hit cleaner", won and Color3.fromRGB(130, 255, 190) or Color3.fromRGB(255, 120, 120))
    local profile = ClientState.GetSnapshot and ClientState.GetSnapshot() or nil
    if profile and profile.Equipped then
        local visuals = require(ReplicatedStorage.Shared.CosmeticConfig).GetVisualProfile(profile.Equipped)
        updateStageColor(visuals.laneFlash or Color3.fromRGB(255, 255, 255))
    end
end)
