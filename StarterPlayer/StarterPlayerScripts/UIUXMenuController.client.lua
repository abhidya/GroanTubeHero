local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local Controller = {}
local stack = {}
local mode = "lobby"
local majorMenus = { SongSelect = true, Store = true, Upgrades = true, Missions = true, Security = true, Tutorial = true, Hype = true, Settings = true, Results = true, Pause = true }

local function rhythmRoot()
    local gui = playerGui:FindFirstChild("RhythmGui")
    return gui, gui and gui:FindFirstChild("Root")
end

local function setNavigationVisible(visible)
    local _, root = rhythmRoot()
    local nav = root and root:FindFirstChild("NavigationMenu", true)
    if nav and nav:IsA("GuiObject") then nav.Visible = visible end
end

local function setRhythmHudVisible(visible)
    local _, root = rhythmRoot()
    if not root then return end
    for _, name in ipairs({ "TopBar", "NoteHighway", "BottomHint", "AlwaysVisibleNoteLegend", "Judgement" }) do
        local obj = root:FindFirstChild(name, true)
        if obj and obj:IsA("GuiObject") then obj.Visible = visible end
    end
end

local function setSongSelect(visible)
    local gui, root = rhythmRoot()
    local modal = root and root:FindFirstChild("SongSelectModal", true)
    if modal and modal:IsA("GuiObject") then modal.Visible = visible end
    if gui and visible then gui:SetAttribute("OpenSongSelect", true) end
end

local function setResults(visible, resultData)
    local _, root = rhythmRoot()
    local modal = root and root:FindFirstChild("ResultsFrame", true)
    if modal and modal:IsA("GuiObject") then modal.Visible = visible end
    if resultData and modal then modal:SetAttribute("ResultDataReady", true) end
end

local function openStoreLike(menuName)
    local storeGui = playerGui:FindFirstChild("StoreGui")
    if storeGui then
        storeGui.Enabled = true
        storeGui:SetAttribute("Open", true)
        storeGui:SetAttribute("Tab", menuName == "Store" and "Tube Sounds" or menuName)
    end
end

local function openAudience()
    local gui = playerGui:FindFirstChild("AudienceGui")
    if gui then gui:SetAttribute("Open", true) end
end

local function closeExternal(menuName)
    if menuName == "Store" or menuName == "Upgrades" or menuName == "Missions" or menuName == "Security" or menuName == "Tutorial" or menuName == "Settings" then
        local storeGui = playerGui:FindFirstChild("StoreGui")
        if storeGui then storeGui:SetAttribute("Open", false) end
    elseif menuName == "Hype" then
        local gui = playerGui:FindFirstChild("AudienceGui")
        if gui then gui:SetAttribute("Open", false) end
    end
end

function Controller.closeMenu(menuName)
    if menuName == "SongSelect" then setSongSelect(false) elseif menuName == "Results" then setResults(false) else closeExternal(menuName) end
    for i = #stack, 1, -1 do
        if stack[i] == menuName then table.remove(stack, i) break end
    end
    if #stack == 0 and mode == "lobby" then Controller.showNavigation() end
end

function Controller.closeAllMenus()
    for _, menuName in ipairs({ "SongSelect", "Store", "Upgrades", "Missions", "Security", "Tutorial", "Hype", "Settings", "Results", "Pause" }) do
        Controller.closeMenu(menuName)
    end
    stack = {}
    if mode == "lobby" then Controller.showNavigation() end
end

function Controller.openMenu(menuName)
    menuName = menuName or "SongSelect"
    if majorMenus[menuName] then Controller.closeAllMenus() end
    if menuName == "SongSelect" then
        setSongSelect(true)
    elseif menuName == "Store" or menuName == "Upgrades" or menuName == "Missions" or menuName == "Security" or menuName == "Tutorial" or menuName == "Settings" then
        openStoreLike(menuName)
    elseif menuName == "Hype" then
        openAudience()
    elseif menuName == "Results" then
        setResults(true)
    end
    table.insert(stack, menuName)
    Controller.hideNavigation()
end

function Controller.closeTopMenu()
    local top = stack[#stack]
    if top then Controller.closeMenu(top) end
end

function Controller.back()
    Controller.closeTopMenu()
    local previous = stack[#stack]
    if previous then Controller.openMenu(previous) elseif mode == "lobby" then Controller.showNavigation() end
end

function Controller.isMenuOpen(menuName)
    for _, value in ipairs(stack) do if value == menuName then return true end end
    return false
end

function Controller.setGameMode(nextMode)
    mode = nextMode or "lobby"
    if mode == "playing" then
        Controller.closeAllMenus()
        Controller.hideNavigation()
        setRhythmHudVisible(true)
    elseif mode == "results" then
        setRhythmHudVisible(false)
        Controller.openMenu("Results")
    else
        setRhythmHudVisible(false)
        Controller.showNavigation()
    end
end

function Controller.showNavigation() setNavigationVisible(true) end
function Controller.hideNavigation() setNavigationVisible(false) end
function Controller.openResults(resultData) mode = "results"; setResults(true, resultData); Controller.hideNavigation() end
function Controller.restoreLobbyState() mode = "lobby"; Controller.closeAllMenus(); setRhythmHudVisible(false); Controller.showNavigation() end

_G.GTH_UIUXMenuController = Controller
_G.UIUXMenuController = Controller

if remotes:FindFirstChild("OpenSongSelect") then
    remotes.OpenSongSelect.OnClientEvent:Connect(function() Controller.openMenu("SongSelect") end)
end

ProximityPromptService.PromptTriggered:Connect(function(prompt)
    if not prompt or not prompt.Parent then return end
    local station = prompt.Parent.Parent and prompt.Parent.Parent.Name or prompt.Parent.Name
    local map = {
        DJ_GroanMaster = "SongSelect",
        Vendor_Store = "Store",
        Vendor_UpgradeEngineer = "Upgrades",
        MissionOfficer = "Missions",
        SecurityManager = "Security",
        TutorialGuide = "Tutorial",
        AudienceHypeManager = "Hype",
        StartPrompt = "SongSelect",
        StoreKiosk = "Store",
        UpgradeKiosk = "Upgrades",
        MissionBoard = "Missions",
        AudienceZone = "Hype",
    }
    if map[station] then Controller.openMenu(map[station]) end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
        Controller.closeTopMenu()
    end
end)

