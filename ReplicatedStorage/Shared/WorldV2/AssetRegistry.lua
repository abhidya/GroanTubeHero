local AssetRegistry = {}

AssetRegistry.SearchCandidates = {
    StageConcertPack = {
        query = "concert stage lights speakers",
        assetIds = { "88635163003664", "104914864697053", "81538308011761" },
        purpose = "audited replacement candidates for stage, lights, and speaker dressing",
    },
    DJBooth = {
        query = "cartoon dj booth npc music",
        assetIds = { "5152105414", "80617112899558", "79768676992019" },
        purpose = "audited DJ station/NPC personality candidate",
    },
    NeonArrowSigns = {
        query = "neon music ui icon arrows",
        assetIds = { "74716477504276", "130850560922663", "85317983953668" },
        purpose = "audited arrow/sign dressing candidates for rhythm lanes and world navigation",
    },
    CyberArcadeOverclock = {
        query = "arcade machine neon game cabinet Roblox",
        assetIds = { "637807731", "5083929571", "9342944537", "10968103368", "15476061406", "13903220189", "14840309510", "4672044552" },
        purpose = "asset-search MCP inspection shortlist only for Cyber Arcade Overclock cabinets and portal dressing",
        reviewState = "claimed_maybe_requires_studio_inspection",
    },
    SubwayMemeTunnel = {
        query = "train station platform Roblox",
        assetIds = { "228201234", "16422570368", "40117484", "8314991219", "14609442409", "1957743767" },
        purpose = "asset-search MCP inspection shortlist only for Subway Meme Tunnel platform, signage, and kiosk dressing",
        reviewState = "claimed_maybe_requires_studio_inspection",
        rejectedAfterInspection = { "111644166341307" },
    },
    HauntedKaraokeTheater = {
        query = "stage curtain Roblox ghost character Roblox",
        assetIds = { "8297623882", "8297711035", "12531890060", "13951875544", "155660821", "6036864116", "2070341625" },
        purpose = "asset-search MCP inspection shortlist only for Haunted Karaoke Theater shell and host NPC dressing",
        reviewState = "claimed_maybe_requires_studio_inspection",
    },
    AquariumBassDrop = {
        query = "fish pack Roblox aquarium fish tank Roblox",
        assetIds = { "5512630914", "10378024631", "7038203367", "11365429086", "1560282339", "734771184", "13345468318", "2073923199" },
        purpose = "asset-search MCP inspection shortlist only for Aquarium Bass Drop fish and tank setpieces",
        reviewState = "claimed_maybe_requires_studio_inspection",
    },
    DoomscrollDataCenter = {
        query = "server rack Roblox computer terminal Roblox",
        assetIds = { "10693308533", "138509177498653", "150383271", "125482914900896", "18544107878", "207300591", "26783279", "379210270", "3623280668", "3623273000", "152665536" },
        purpose = "asset-search MCP inspection shortlist only for Doomscroll Data Center server racks and terminal setpieces",
        reviewState = "claimed_maybe_requires_studio_inspection",
    },
}

AssetRegistry.InspectedRoomAssets = {
    cyber_arcade_overclock = {
        {
            assetId = "637807731",
            slot = "setpiece",
            verdict = "pass",
            sizeStuds = { x = 35.10, y = 9.00, z = 4.40 },
            scriptCount = 0,
            basePartCount = 89,
            visualRiskScore = 3,
            note = "usable arcade cabinet child set; wrapper imports vertically stacked, so arrange child cabinets into a horizontal row before final placement",
        },
        {
            assetId = "13903220189",
            slot = "portal",
            verdict = "fix",
            sizeStuds = { x = 2.31, y = 14.00, z = 11.42 },
            scriptCount = 0,
            basePartCount = 3,
            visualRiskScore = 3,
            note = "clean portal dressing; reads well beside cabinet row but should pair with source-owned functional queue trigger",
        },
    },
    subway_meme_tunnel = {
        {
            assetId = "111644166341307",
            slot = "room_shell",
            verdict = "reject",
            sizeStuds = { x = 85.16, y = 26.12, z = 218.20 },
            scriptCount = 1,
            basePartCount = 1277,
            visualRiskScore = 9,
            note = "oversized train station shell rejected after Studio inspection",
        },
    },
    haunted_karaoke_theater = {
        {
            assetId = "8297623882",
            slot = "room_shell",
            verdict = "fix",
            sizeStuds = { x = 30.98, y = 18.80, z = 14.34 },
            scriptCount = 0,
            basePartCount = 49,
            visualRiskScore = 4,
            note = "theater stage is usable only when grounded and viewed from its front side; back side reads as a plain slab",
        },
        {
            assetId = "155660821",
            slot = "host_npc",
            verdict = "fix",
            sizeStuds = { x = 4.00, y = 5.17, z = 1.00 },
            scriptCount = 0,
            basePartCount = 7,
            visualRiskScore = 4,
            note = "readable ghost host; keep as a side helper with playful lighting/accessories, not as a central horror figure",
        },
    },
    aquarium_bass_drop = {
        {
            assetId = "734771184",
            slot = "setpiece",
            verdict = "pass",
            sizeStuds = { x = 11.24, y = 20.78, z = 11.17 },
            scriptCount = 0,
            basePartCount = 17,
            visualRiskScore = 2,
            note = "strong cylinder aquarium setpiece; needs brighter final-room lighting for fish readability",
        },
        {
            assetId = "5512630914",
            slot = "fish",
            verdict = "fix",
            sizeStuds = { x = 3.62, y = 1.64, z = 3.97 },
            scriptCount = 0,
            basePartCount = 8,
            visualRiskScore = 3,
            note = "usable only after scaling to 0.45 and placing inside/near the tank; raw size reads misplaced",
        },
    },
    doomscroll_data_center = {
        {
            assetId = "3623280668",
            slot = "terminal",
            verdict = "pass",
            sizeStuds = { x = 3.36, y = 6.00, z = 3.28 },
            scriptCount = 0,
            basePartCount = 3,
            visualRiskScore = 3,
            note = "lightweight terminal candidate; readable but too sparse without surrounding data-center clutter and lighting",
        },
        {
            assetId = "10693308533",
            slot = "rack",
            verdict = "fix",
            sizeStuds = { x = 4.00, y = 14.77, z = 4.03 },
            scriptCount = 0,
            basePartCount = 310,
            visualRiskScore = 4,
            note = "readable rack but heavy for repeated cloning; use sparingly with lighter surrounding props",
        },
    },
}

AssetRegistry.PaletteCommitments = {
    cyber_arcade_overclock = {
        {
            slot = "setpiece.cabinet_row",
            assetId = "637807731",
            name = "Arcade Game cabinet row",
            verdict = "pass",
            publishPermission = "missing",
            placementStatus = "palette_committed_pending_permission_and_fragment",
        },
        {
            slot = "portal.static_neon_door",
            assetId = "13903220189",
            name = "Low Poly Portal static Cyber Arcade doorway",
            verdict = "fix",
            publishPermission = "missing",
            placementStatus = "palette_committed_pending_permission_and_fragment",
        },
    },
    aquarium_bass_drop = {
        {
            slot = "setpiece.tank",
            assetId = "734771184",
            name = "Cylinder Aquarium room setpiece",
            verdict = "pass",
            publishPermission = "missing",
            placementStatus = "palette_committed_pending_permission_and_fragment",
        },
        {
            slot = "prop.fish_school",
            assetId = "5512630914",
            name = "Fish school scaled room prop",
            verdict = "fix",
            publishPermission = "missing",
            placementStatus = "palette_committed_pending_permission_and_fragment",
        },
    },
    haunted_karaoke_theater = {
        {
            slot = "setpiece.stage",
            assetId = "8297623882",
            name = "Grounded Theater Stage curtain shell",
            verdict = "fix",
            publishPermission = "missing",
            placementStatus = "palette_committed_pending_permission_and_fragment",
        },
        {
            slot = "npc.friendly_ghost_host",
            assetId = "155660821",
            name = "Friendly Ghost side host",
            verdict = "fix",
            publishPermission = "missing",
            placementStatus = "palette_committed_pending_permission_and_fragment",
        },
    },
    doomscroll_data_center = {
        {
            slot = "objective.terminal",
            assetId = "3623280668",
            name = "Lightweight Computer Terminal objective",
            verdict = "pass",
            publishPermission = "missing",
            placementStatus = "palette_committed_pending_permission_and_fragment",
        },
        {
            slot = "setpiece.server_rack",
            assetId = "10693308533",
            name = "Server Rack sparse-use setpiece",
            verdict = "fix",
            publishPermission = "missing",
            placementStatus = "palette_committed_pending_permission_and_fragment",
        },
    },
}

AssetRegistry.Entries = {
    StagePlatform = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Stage.StagePlatform", "Workspace.Stage.StagePlatform" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "central performance deck" },
    Truss = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Stage.Truss" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "concert truss decoration" },
    SpeakerStack = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Stage.SpeakerStack", "Workspace.Stage.SpeakerStacks.SpeakerStack1", "Workspace.Stage.SpeakerStacks.SpeakerStack2" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "speaker power fantasy" },
    Spotlight = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lighting.Spotlight", "Workspace.Stage.Spotlights" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "stage lighting" },
    LaserBeamAnchor = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lighting.LaserBeamAnchor" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "laser/beam/light anchors" },
    CashRegister = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.CashRegister", "Workspace.Stage.StoreKiosk" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "store counter" },
    UpgradeTerminal = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.UpgradeTerminal", "Workspace.Stage.UpgradeKiosk" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "upgrade station" },
    MissionBoard = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.MissionBoard", "Workspace.Stage.MissionBoard" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "missions station" },
    SecurityTerminal = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.SecurityTerminal" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "sector health station" },
    TutorialGuide = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Lobby.TutorialGuide" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "tutorial station" },
    HypeManager = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Audience.HypeManager" }, Required = false, FallbackAllowed = false, CloneCount = 1, Purpose = "audience rewards station" },
    FenceSegment = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Props.FenceSegment" }, Required = false, FallbackAllowed = false, CloneCount = 32, Purpose = "fence ring protection" },
    HordeEnemy = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Horde.HordeEnemy", "Workspace.Unused_MapAssets" }, Required = false, FallbackAllowed = false, CloneCount = 40, Purpose = "horde cluster figures" },
    HordeGate = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Horde.HordeGate" }, Required = false, FallbackAllowed = false, CloneCount = 8, Purpose = "sector gate silhouette" },
    CrowdNPC = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Audience.CrowdNPC", "Workspace.Unused_MapAssets" }, Required = false, FallbackAllowed = false, CloneCount = 24, Purpose = "crowd silhouettes" },
    StadiumChair = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Audience.StadiumChair" }, Required = false, FallbackAllowed = false, CloneCount = 32, Purpose = "audience seating" },
    VolcanoCliff = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Volcano.VolcanoCliff", "Workspace.Stage.BrainrotBackdrop" }, Required = false, FallbackAllowed = false, CloneCount = 16, Purpose = "outer cliff/horizon mask" },
    LavaFogEmber = { PreferredPaths = { "ReplicatedStorage.ArtAssets.Volcano.LavaFogEmber", "ReplicatedStorage.ArtAssets.Lighting" }, Required = false, FallbackAllowed = false, CloneCount = 16, Purpose = "lava/fog/ember effects" },
}

local function resolvePath(path)
    local current = game
    for token in string.gmatch(path, "[^%.]+") do
        if token == "game" then
            current = game
        else
            current = current and current:FindFirstChild(token)
        end
    end
    return current
end

function AssetRegistry.Resolve(entryName)
    local entry = AssetRegistry.Entries[entryName]
    if not entry then return nil, "UnknownAssetRegistryEntry" end
    for _, path in ipairs(entry.PreferredPaths or {}) do
        local inst = resolvePath(path)
        if inst then return inst, path, entry end
    end
    if entry.Required then
        return nil, "MissingRequiredAsset", entry
    end
    return nil, "MissingOptionalAsset", entry
end

function AssetRegistry.MissingRequired()
    local missing = {}
    for name, entry in pairs(AssetRegistry.Entries) do
        if entry.Required then
            local inst = AssetRegistry.Resolve(name)
            if not inst then table.insert(missing, name) end
        end
    end
    table.sort(missing)
    return missing
end

function AssetRegistry.GetSearchCandidates(name)
    return AssetRegistry.SearchCandidates[name]
end

function AssetRegistry.GetInspectedRoomAssets(roomId)
    return AssetRegistry.InspectedRoomAssets[roomId] or {}
end

function AssetRegistry.GetRoomPaletteCommitments(roomId)
    return AssetRegistry.PaletteCommitments[roomId] or {}
end

function AssetRegistry.GetRoomAssetReadiness(roomId)
    local assets = AssetRegistry.GetInspectedRoomAssets(roomId)
    local paletteAssets = AssetRegistry.GetRoomPaletteCommitments(roomId)
    local counts = {
        pass = 0,
        fix = 0,
        reject = 0,
        total = #assets,
    }
    local highestRisk = 0
    for _, asset in ipairs(assets) do
        local verdict = tostring(asset.verdict or "unknown")
        if counts[verdict] ~= nil then
            counts[verdict] += 1
        end
        highestRisk = math.max(highestRisk, tonumber(asset.visualRiskScore) or 0)
    end
    local paletteCounts = {
        pass = 0,
        fix = 0,
        reject = 0,
        total = #paletteAssets,
    }
    local missingPermission = 0
    for _, asset in ipairs(paletteAssets) do
        local verdict = tostring(asset.verdict or "unknown")
        if paletteCounts[verdict] ~= nil then
            paletteCounts[verdict] += 1
        end
        if tostring(asset.publishPermission or "missing") == "missing" then
            missingPermission += 1
        end
    end

    local visualStatus = "not_inspected"
    if counts.pass > 0 and counts.reject == 0 and counts.fix == 0 then
        visualStatus = "inspected_pass"
    elseif counts.pass > 0 and counts.reject == 0 then
        visualStatus = "inspected_with_fixes"
    elseif counts.pass > 0 then
        visualStatus = "mixed_with_rejections"
    elseif counts.reject > 0 then
        visualStatus = "candidate_rejected"
    elseif counts.fix > 0 then
        visualStatus = "needs_fixes"
    end
    local paletteCommitted = paletteCounts.total > 0
    local publishPermission = "missing"
    if paletteCommitted and missingPermission == 0 then
        publishPermission = "recorded"
    end
    local placementStatus = "not_placed"
    if paletteCommitted then
        placementStatus = "palette_committed_pending_permission_and_fragment"
    end

    return {
        roomId = roomId,
        visualStatus = visualStatus,
        inspectedCount = counts.total,
        passCount = counts.pass,
        fixCount = counts.fix,
        rejectCount = counts.reject,
        highestVisualRiskScore = highestRisk,
        paletteCommitted = paletteCommitted,
        paletteAssetCount = paletteCounts.total,
        palettePassCount = paletteCounts.pass,
        paletteFixCount = paletteCounts.fix,
        paletteRejectCount = paletteCounts.reject,
        publishPermission = publishPermission,
        missingPublishPermissionCount = missingPermission,
        placementStatus = placementStatus,
        needsPlayerAngleRoomScreenshots = not paletteCommitted or missingPermission > 0,
    }
end

return AssetRegistry
