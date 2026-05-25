local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "NPCDialogueGui"
gui.IgnoreGuiInset = false
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "DialoguePanel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -28)
panel.Size = UDim2.new(0.78, 0, 0, 92)
panel.BackgroundColor3 = Color3.fromRGB(7, 10, 22)
panel.BackgroundTransparency = 1
panel.Visible = false
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120, 240, 255)
stroke.Thickness = 2
stroke.Transparency = 0.15
stroke.Parent = panel

local text = Instance.new("TextLabel")
text.Name = "DialogueText"
text.BackgroundTransparency = 1
text.Position = UDim2.new(0, 18, 0, 10)
text.Size = UDim2.new(1, -36, 1, -20)
text.TextWrapped = true
text.TextScaled = true
text.TextColor3 = Color3.fromRGB(235, 245, 255)
text.Font = Enum.Font.GothamBold
text.TextXAlignment = Enum.TextXAlignment.Left
text.Parent = panel

local token = 0
local function show(line)
    token += 1
    local my = token
    panel.Visible = true
    panel.BackgroundTransparency = 0.08
    text.TextTransparency = 0
    text.Text = tostring(line or "Crew: Keep the stage alive.")
    panel.Size = UDim2.new(0.78, 0, 0, 88)
    TweenService:Create(panel, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Size = UDim2.new(0.82, 0, 0, 96) }):Play()
    task.delay(3.2, function()
        if my ~= token then return end
        TweenService:Create(panel, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(text, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
        task.delay(0.28, function()
            if my == token then panel.Visible = false end
        end)
    end)
end

local remote = remotes:WaitForChild("NPCDialogue", 10)
if remote then
    remote.OnClientEvent:Connect(function(payload)
        if type(payload) == "table" then
            show(payload.text)
        else
            show(payload)
        end
    end)
end
