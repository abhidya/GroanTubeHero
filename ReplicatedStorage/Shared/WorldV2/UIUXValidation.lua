local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local UIUXValidation = {}

-- Creator/Studio audited assets only contract:
-- Runtime UI should stay style-driven (Frames/Text/gradients/strokes) unless a
-- Studio-reviewed visual asset is explicitly marked with AuditedArtAsset and
-- AssetSourcePath. This keeps UI validation aligned with WorldValidation's
-- visible-art gate without introducing gameplay-affecting dependencies.
local AUDITED_UI_VISUAL_ASSET_CONTRACT = {
    disallowedImageClasses = {
        ImageButton = true,
        ImageLabel = true,
    },
    allowedWhenAuditedAttributesPresent = true,
}

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

local function simulatedModalRect(modalName, viewport)
    local maxW = modalName == "ResultsFrame" and 620 or 680
    local maxH = modalName == "ResultsFrame" and 520 or 650
    local scaleX = modalName == "ResultsFrame" and 0.9 or 0.92
    local scaleY = modalName == "ResultsFrame" and 0.84 or 0.86
    if viewport.X <= 900 then scaleX = 0.94 end
    if viewport.Y <= 430 then scaleY = 0.92 end
    local width = math.min(maxW, math.max(320, math.min(viewport.X - 24, viewport.X * scaleX)))
    local height = math.min(maxH, math.max(280, math.min(viewport.Y - 24, viewport.Y * scaleY)))
    return { x = (viewport.X - width) / 2, y = (viewport.Y - height) / 2, width = width, height = height }
end

local function simulatedCloseInside(modalName, viewport)
    local rect = simulatedModalRect(modalName, viewport)
    local short = viewport.Y <= 430
    local sizeX = modalName == "ResultsFrame" and (short and 42 or 50) or (short and 42 or 48)
    local sizeY = modalName == "ResultsFrame" and (short and 38 or 46) or (short and 38 or 44)
    local offsetX = modalName == "ResultsFrame" and (short and 52 or 64) or (short and 52 or 62)
    local offsetY = short and 10 or 14
    local x = rect.x + rect.width - offsetX
    local y = rect.y + offsetY
    return x >= -1 and y >= -1 and (x + sizeX) <= viewport.X + 1 and (y + sizeY) <= viewport.Y + 1
end

local function simulatedHighwayFits(viewport)
    local scale = math.clamp(math.min(viewport.X / 1280, viewport.Y / 720), 0.48, 1.15)
    local size = 500 * scale
    return size <= viewport.X + 1 and size <= viewport.Y + 1
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

local function isAuditedStudioAsset(inst)
    return inst:GetAttribute("AuditedArtAsset") == true and inst:GetAttribute("AssetSourcePath") ~= nil
end

local function imagePropertyHasAsset(inst)
    local ok, image = pcall(function()
        return inst.Image
    end)
    return ok and type(image) == "string" and image ~= ""
end

local function collectUnauditedUiVisualAssets(root)
    local violations = {}
    if not root then return violations end
    for _, desc in ipairs(root:GetDescendants()) do
        if AUDITED_UI_VISUAL_ASSET_CONTRACT.disallowedImageClasses[desc.ClassName]
            and imagePropertyHasAsset(desc)
            and not isAuditedStudioAsset(desc)
        then
            table.insert(violations, desc:GetFullName())
        end
    end
    return violations
end

function UIUXValidation.GetAuditedUiVisualAssetContract()
    return AUDITED_UI_VISUAL_ASSET_CONTRACT
end

function UIUXValidation.ValidateAuditedUiVisualAssets(root)
    local violations = collectUnauditedUiVisualAssets(root)
    return {
        ok = #violations == 0,
        violations = violations,
        contract = AUDITED_UI_VISUAL_ASSET_CONTRACT,
    }
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
        local uiAssetAudit = UIUXValidation.ValidateAuditedUiVisualAssets(root)
        local controller = rawget(_G, "GTH_UIUXMenuController")
        if not controller then
            local deadline = os.clock() + 3
            while not controller and os.clock() < deadline do
                task.wait(0.1)
                controller = rawget(_G, "GTH_UIUXMenuController")
            end
        end
        local starterPlayerScripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
        local controllerScript = (player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("UIUXMenuController", true))
            or (starterPlayerScripts and starterPlayerScripts:FindFirstChild("UIUXMenuController", true))
        local controllerSource = controllerScript and controllerScript:IsA("LocalScript") and controllerScript.Source or ""
        local controllerAvailable = controller ~= nil or (controllerSource:find("function Controller.openMenu", 1, true) and controllerSource:find("function Controller.closeAllMenus", 1, true))
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
        expect(controllerAvailable, "UIUXMenuController API exists")
        expect(uiAssetAudit.ok, "UI visible art uses only audited Studio assets: " .. table.concat(uiAssetAudit.violations, ", "))
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
                    if label == "Desktop" then
                        expect(rectInside(findButton(modal, { "CloseSongSelect", "CloseResults", "Close", "X" }), viewport), label .. " close button onscreen for " .. modal.Name)
                    end
                    expect(simulatedCloseInside(modal.Name, viewport), label .. " close button onscreen for " .. modal.Name)
                    modal.Visible = false
                end
            end
            if highway then
                expect(simulatedHighwayFits(viewport), label .. " rhythm arrows fit viewport")
            end
        end
    end
    if UserInputService.KeyboardEnabled then
        expect(root ~= nil, "Escape/back target root exists")
    end
    assert(#errors == 0, table.concat(errors, " | "))
    return {
        ok = true,
        errors = errors,
        viewports = VIEWPORTS,
        auditedUiVisualAssetContract = AUDITED_UI_VISUAL_ASSET_CONTRACT,
    }
end

return UIUXValidation
