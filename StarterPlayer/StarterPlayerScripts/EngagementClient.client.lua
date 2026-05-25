local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "EngagementGui"
gui.IgnoreGuiInset = false
gui.ResetOnSpawn = false
gui.Parent = playerGui

local toast = Instance.new("TextLabel")
toast.Name = "ActionToast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 156)
toast.Size = UDim2.new(0, 620, 0, 64)
toast.BackgroundColor3 = Color3.fromRGB(10, 12, 24)
toast.BackgroundTransparency = 1
toast.TextTransparency = 1
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.Font = Enum.Font.GothamBlack
toast.TextScaled = true
toast.TextWrapped = true
toast.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = toast
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 230, 120)
stroke.Thickness = 2
stroke.Transparency = 1
stroke.Parent = toast

local scale = Instance.new("UIScale")
scale.Parent = toast

local lastComboToast = 0
local lastHordeWarning = 0
local function show(text, color)
    toast.Text = text
    toast.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    toast.BackgroundTransparency = 0.12
    toast.TextTransparency = 0
    stroke.Transparency = 0.05
    scale.Scale = 0.92
    TweenService:Create(scale, TweenInfo.new(0.14, Enum.EasingStyle.Back), { Scale = 1.04 }):Play()
    task.delay(0.75, function()
        TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
    end)
end

remotes.NoteJudged.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then return end
    if payload.judgement == "Perfect" then
        show("PERFECT! Horde knocked back", Color3.fromRGB(120, 255, 170))
    elseif payload.judgement == "Good" then
        show("GOOD! Horde slowed", Color3.fromRGB(140, 200, 255))
    elseif payload.judgement == "Miss" then
        show("MISS! Horde surges closer", Color3.fromRGB(255, 110, 120))
    end
    local combo = tonumber(payload.combo) or 0
    if combo >= 5 and combo % 5 == 0 and combo ~= lastComboToast then
        lastComboToast = combo
        task.delay(0.18, function()
            show(combo .. " combo — stage lights charged", Color3.fromRGB(255, 240, 120))
        end)
    end
end)

remotes.HordeUpdate.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then return end
    local t = os.clock()
    if t - lastHordeWarning < 1.2 then return end
    if payload.disasterMode then
        lastHordeWarning = t
        show("DISASTER MODE — survive the song!", Color3.fromRGB(255, 80, 80))
    elseif payload.state == "Critical" then
        lastHordeWarning = t
        show("Horde at the stage! Hit clean notes!", Color3.fromRGB(255, 120, 90))
    end
end)

remotes.SongFinished.OnClientEvent:Connect(function(payload)
    local summary = payload and payload.summary or {}
    show((summary.disasterMode and "Song survived in Disaster Mode" or "Run complete — claim rewards"), Color3.fromRGB(255, 245, 160))
end)
