local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local UIUXValidation = {}

local VIEWPORTS = {
    Desktop = Vector2.new(1920, 1080),
    Laptop = Vector2.new(1366, 768),
    iPad = Vector2.new(1024, 768),
    iPhone = Vector2.new(844, 390),
    SmallPhone = Vector2.new(667, 375),
}

local function rectInside(frame, viewport)
    if not frame or not frame:IsA("GuiObject") then return false end
    local pos = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    return pos.X >= -1 and pos.Y >= -1 and (pos.X + size.X) <= viewport.X + 1 and (pos.Y + size.Y) <= viewport.Y + 1
end

local function findButton(root, names)
    for _, name in ipairs(names) do
        local found = root and root:FindFirstChild(name, true)
        if found and found:IsA("GuiButton") then return found end
    end
    return nil
end

local function visible(guiObject)
    return guiObject and guiObject:IsA("GuiObject") and guiObject.Visible == true
end

local function countOpenModals(modals)
    local count = 0
    for _, modal in pairs(modals) do
        if visible(modal) then count += 1 end
    end
    return count
end

local function requiredPromptExists(world, stationName)
    local station = world and world:FindFirstChild(stationName, true)
    return station and station:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
end

function UIUXValidation.Run(player)
    player = player or Players.LocalPlayer
    local errors = {}
    local function expect(condition, message)
        if not condition then table.insert(errors, message) end
    end
    if not player then
        return { ok = true, skipped = true, reason = "No LocalPlayer on server validation" }
    end
    local playerGui = player:FindFirstChild("PlayerGui")
    expect(playerGui ~= nil, "PlayerGui exists")
    local rhythmGui = playerGui and playerGui:FindFirstChild("RhythmGui")
    expect(rhythmGui ~= nil, "RhythmGui exists")
    local root = rhythmGui and rhythmGui:FindFirstChild("Root")
    expect(root ~= nil, "RhythmGui.Root exists")
    if root then
        local nav = root:FindFirstChild("NavigationMenu", true)
        local songSelect = root:FindFirstChild("SongSelectModal", true)
        local results = root:FindFirstChild("ResultsFrame", true)
        local controller = rawget(_G, "GTH_UIUXMenuController")
        local modals = { SongSelect = songSelect, Results = results }
        expect(nav ~= nil, "NavigationMenu visible in lobby")
        expect(songSelect ~= nil, "SongSelect exists")
        expect(findButton(songSelect, { "CloseSongSelect", "Close", "X" }) ~= nil, "SongSelect has close")
        expect(findButton(songSelect, { "BackSongSelect", "Back" }) ~= nil, "SongSelect has Back")
        expect(results ~= nil, "Results exists")
        expect(findButton(results, { "CloseResults", "Close", "X" }) ~= nil, "Results has close")
        expect(findButton(results, { "ContinueButton", "ReplayButton" }) ~= nil, "Results has Continue/Replay")
        expect(findButton(results, { "ChooseButton", "ChooseAnotherSongButton" }) ~= nil, "Results has Choose Another Song")
        expect(findButton(results, { "BackToLobbyButton", "CloseResults" }) ~= nil, "Results has Back to Lobby path")
        expect(controller ~= nil, "UIUXMenuController global exists")
        if controller then
            for _, methodName in ipairs({ "openMenu", "closeMenu", "closeTopMenu", "closeAllMenus", "back", "isMenuOpen", "setGameMode", "showNavigation", "hideNavigation", "openResults", "restoreLobbyState" }) do
                expect(type(controller[methodName]) == "function", "UIUXMenuController." .. methodName .. " exists")
            end
            if type(controller.closeAllMenus) == "function" and type(controller.openMenu) == "function" and type(controller.closeTopMenu) == "function" then
                controller.closeAllMenus()
                controller.openMenu("SongSelect")
                expect(visible(songSelect), "SongSelect opens through controller")
                expect(countOpenModals(modals) <= 1, "Only one major modal open after SongSelect")
                controller.openMenu("Results")
                expect(not visible(songSelect), "Opening Results closes SongSelect")
                expect(visible(results), "Results opens through controller")
                expect(countOpenModals(modals) <= 1, "Only one major modal open after Results")
                controller.closeTopMenu()
                expect(not visible(results), "closeTopMenu closes Results")
                controller.openMenu("SongSelect")
                expect(visible(songSelect), "SongSelect reopens after closing")
                controller.back()
                expect(not visible(songSelect), "back closes top modal")
                controller.restoreLobbyState()
                expect(nav == nil or nav.Visible == true, "NavigationMenu returns in lobby")
            end
        end
        local world = Workspace:FindFirstChild("GTH_WorldV2")
        if world then
            local promptStations = { "DJ_GroanMaster", "Vendor_Store", "Vendor_UpgradeEngineer", "MissionOfficer", "SecurityManager", "TutorialGuide", "AudienceHypeManager" }
            for _, stationName in ipairs(promptStations) do
                expect(requiredPromptExists(world, stationName), "Prompt path exists for " .. stationName)
            end
        end
        local highway = root:FindFirstChild("NoteHighway", true)
        local major = { songSelect, results }
        for label, viewport in pairs(VIEWPORTS) do
            for _, modal in ipairs(major) do
                if modal then
                    modal.Visible = true
                    expect(rectInside(findButton(modal, { "CloseSongSelect", "CloseResults", "Close", "X" }), viewport), label .. " close button onscreen for " .. modal.Name)
                    modal.Visible = false
                end
            end
            if highway then
                expect(highway.AbsoluteSize.X <= viewport.X and highway.AbsoluteSize.Y <= viewport.Y, label .. " rhythm arrows fit viewport")
            end
        end
    end
    if UserInputService.KeyboardEnabled then
        expect(root ~= nil, "Escape/back target root exists")
    end
    assert(#errors == 0, table.concat(errors, " | "))
    return { ok = true, errors = errors, viewports = VIEWPORTS }
end

return UIUXValidation
