--!strict
-- Generate one-root committed-palette intake fragments for headless merge.
--
-- These fragments are evidence/placement layers, not final imported Creator
-- Store mesh layers. They exist because unauthenticated Asset Delivery can
-- block real bytes even after asset-search curation has committed a palette.

local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local Instance = roblox.Instance
local Color3 = roblox.Color3
local CFrame = roblox.CFrame
local Vector3 = roblox.Vector3
local UDim2 = roblox.UDim2
local Enum = roblox.Enum

type PaletteAsset = {
	assetId: number,
	slot: string,
	name: string,
	verdict: string,
	sizeStuds: string,
	note: string,
	color: Color3,
	anchorSize: Vector3,
	offset: Vector3,
	rotationY: number?,
}

type PaletteRoom = {
	roomId: string,
	roomName: string,
	rootName: string,
	fragmentId: string,
	orderKey: string,
	outputModel: string,
	center: Vector3,
	baseSize: Vector3,
	primary: Color3,
	secondary: Color3,
	accent: Color3,
	anchorPath: string,
	assets: { PaletteAsset },
}

local TARGET_PARENT = "Workspace.GTH_WorldV2.ThemedRoomSpaces"

local ROOMS: { [string]: PaletteRoom } = {
	cyber_arcade_overclock = {
		roomId = "cyber_arcade_overclock",
		roomName = "Cyber Arcade Overclock",
		rootName = "CommittedPalette_CyberArcadeOverclock",
		fragmentId = "groantubehero_cyber_arcade_overclock_committed_inspection_palette_room",
		orderKey = "010-cyber-arcade-committed-palette-intake",
		outputModel = "fragments/groantubehero_cyber_arcade_committed_palette.rbxm",
		center = Vector3.new(260, 3.5, 0),
		baseSize = Vector3.new(30, 0.35, 16),
		primary = Color3.fromRGB(80, 225, 255),
		secondary = Color3.fromRGB(120, 90, 255),
		accent = Color3.fromRGB(255, 230, 90),
		anchorPath = "Workspace.GTH_WorldV2.ThemedRoomSpaces.RoomSpace_02_cyber_arcade_overclock",
		assets = {
			{
				assetId = 637807731,
				slot = "cyber_arcade_overclock.setpiece.cabinet_row",
				name = "Arcade Game cabinet row",
				verdict = "pass",
				sizeStuds = "35.10 x 9.00 x 4.40",
				note = "arrange child cabinets into a horizontal row before final placement",
				color = Color3.fromRGB(80, 225, 255),
				anchorSize = Vector3.new(18, 5.5, 1.2),
				offset = Vector3.new(-8, 2.9, -4),
			},
			{
				assetId = 13903220189,
				slot = "cyber_arcade_overclock.portal.static_neon_door",
				name = "Low Poly Portal static Cyber Arcade doorway",
				verdict = "fix",
				sizeStuds = "2.31 x 14.00 x 11.42",
				note = "use as visual portal dressing beside source-owned room queue trigger",
				color = Color3.fromRGB(255, 230, 90),
				anchorSize = Vector3.new(6, 9.5, 1),
				offset = Vector3.new(8, 4.9, -2),
				rotationY = -18,
			},
		},
	},
	aquarium_bass_drop = {
		roomId = "aquarium_bass_drop",
		roomName = "Aquarium Bass Drop",
		rootName = "CommittedPalette_AquariumBassDrop",
		fragmentId = "groantubehero_aquarium_bass_drop_committed_inspection_palette_room",
		orderKey = "011-aquarium-bass-drop-committed-palette-intake",
		outputModel = "fragments/groantubehero_aquarium_bass_drop_committed_palette.rbxm",
		center = Vector3.new(0, 3.5, 260),
		baseSize = Vector3.new(28, 0.35, 16),
		primary = Color3.fromRGB(80, 210, 255),
		secondary = Color3.fromRGB(30, 120, 150),
		accent = Color3.fromRGB(140, 255, 210),
		anchorPath = "Workspace.GTH_WorldV2.ThemedRoomSpaces.RoomSpace_06_aquarium_bass_drop",
		assets = {
			{
				assetId = 734771184,
				slot = "aquarium_bass_drop.setpiece.tank",
				name = "Cylinder Aquarium room setpiece",
				verdict = "pass",
				sizeStuds = "20.72 x 7.93 x 7.90",
				note = "strong readable tank; final room lighting must keep fish silhouettes visible",
				color = Color3.fromRGB(80, 210, 255),
				anchorSize = Vector3.new(12, 7, 7),
				offset = Vector3.new(-7, 4.2, -2),
			},
			{
				assetId = 5512630914,
				slot = "aquarium_bass_drop.prop.fish_school",
				name = "Fish school scaled room prop",
				verdict = "fix",
				sizeStuds = "8.04 x 3.64 x 8.83",
				note = "use as clustered accent, not repeated heavy wall dressing",
				color = Color3.fromRGB(140, 255, 210),
				anchorSize = Vector3.new(8, 4, 8),
				offset = Vector3.new(7, 3.9, -1),
				rotationY = 15,
			},
		},
	},
	haunted_karaoke_theater = {
		roomId = "haunted_karaoke_theater",
		roomName = "Haunted Karaoke Theater",
		rootName = "CommittedPalette_HauntedKaraokeTheater",
		fragmentId = "groantubehero_haunted_karaoke_theater_committed_inspection_palette_room",
		orderKey = "012-haunted-karaoke-theater-committed-palette-intake",
		outputModel = "fragments/groantubehero_haunted_karaoke_committed_palette.rbxm",
		center = Vector3.new(-260, 3.5, 0),
		baseSize = Vector3.new(30, 0.35, 16),
		primary = Color3.fromRGB(120, 255, 190),
		secondary = Color3.fromRGB(80, 50, 120),
		accent = Color3.fromRGB(255, 245, 180),
		anchorPath = "Workspace.GTH_WorldV2.ThemedRoomSpaces.RoomSpace_04_haunted_karaoke_theater",
		assets = {
			{
				assetId = 8297623882,
				slot = "haunted_karaoke_theater.setpiece.stage",
				name = "Grounded Theater Stage curtain shell",
				verdict = "fix",
				sizeStuds = "24.25 x 12.09 x 9.84",
				note = "keep grounded and readable; pair with playful lighting to avoid harsh horror tone",
				color = Color3.fromRGB(120, 255, 190),
				anchorSize = Vector3.new(16, 8, 2),
				offset = Vector3.new(-5, 4.6, -4),
			},
			{
				assetId = 155660821,
				slot = "haunted_karaoke_theater.npc.friendly_ghost_host",
				name = "Friendly Ghost side host",
				verdict = "fix",
				sizeStuds = "4.00 x 5.17 x 1.00",
				note = "use as side host with playful accessories, not central horror figure",
				color = Color3.fromRGB(255, 245, 180),
				anchorSize = Vector3.new(4, 5.5, 1),
				offset = Vector3.new(9, 3.6, -2),
				rotationY = -10,
			},
		},
	},
	doomscroll_data_center = {
		roomId = "doomscroll_data_center",
		roomName = "Doomscroll Data Center",
		rootName = "CommittedPalette_DoomscrollDataCenter",
		fragmentId = "groantubehero_doomscroll_data_center_committed_inspection_palette_room",
		orderKey = "013-doomscroll-data-center-committed-palette-intake",
		outputModel = "fragments/groantubehero_doomscroll_data_center_committed_palette.rbxm",
		center = Vector3.new(380, 3.5, 260),
		baseSize = Vector3.new(30, 0.35, 16),
		primary = Color3.fromRGB(95, 255, 170),
		secondary = Color3.fromRGB(30, 38, 52),
		accent = Color3.fromRGB(255, 80, 130),
		anchorPath = "Workspace.GTH_WorldV2.ThemedRoomSpaces.RoomSpace_doomscroll_data_center",
		assets = {
			{
				assetId = 3623280668,
				slot = "doomscroll_data_center.objective.terminal",
				name = "Lightweight Computer Terminal objective",
				verdict = "pass",
				sizeStuds = "3.36 x 6.00 x 3.28",
				note = "readable terminal; needs surrounding data-center clutter and lighting",
				color = Color3.fromRGB(95, 255, 170),
				anchorSize = Vector3.new(5, 5.5, 2),
				offset = Vector3.new(-7, 3.5, -2),
			},
			{
				assetId = 10693308533,
				slot = "doomscroll_data_center.setpiece.server_rack",
				name = "Server Rack sparse-use setpiece",
				verdict = "fix",
				sizeStuds = "4.00 x 14.77 x 4.03",
				note = "readable rack but heavy for repeated cloning; use sparingly",
				color = Color3.fromRGB(255, 80, 130),
				anchorSize = Vector3.new(5, 10, 3),
				offset = Vector3.new(7, 5.4, -2),
				rotationY = 12,
			},
		},
	},
}

local ROOM_ORDER = {
	"cyber_arcade_overclock",
	"aquarium_bass_drop",
	"haunted_karaoke_theater",
	"doomscroll_data_center",
}

local args = process.args

local function dirname(path: string): string
	return string.match(path, "^(.*)[/\\][^/\\]+$") or "."
end

local function ensureDir(path: string)
	if path == "." or path == "" then
		return
	end
	if not fs.isDir(path) then
		fs.writeDir(path)
	end
end

local function manifestPathFor(modelPath: string): string
	local outputManifest = string.gsub(modelPath, "%.rbxm$", ".manifest.json")
	if outputManifest == modelPath then
		outputManifest = modelPath .. ".manifest.json"
	end
	return outputManifest
end

local function safeName(value: string): string
	local safe = string.gsub(value, "[^%w_]+", "_")
	return string.gsub(safe, "_+", "_")
end

local function assetIdText(room: PaletteRoom): string
	local ids = {}
	for _, asset in ipairs(room.assets) do
		table.insert(ids, tostring(asset.assetId))
	end
	return table.concat(ids, ",")
end

local function makePart(name: string, parent: Instance, size: Vector3, cframe: CFrame, color: Color3, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Parent = parent
	return part
end

local function labelPart(part: Instance, textValue: string, face)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "PaletteEvidenceLabel"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 36
	gui.AlwaysOnTop = false
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = textValue
	label.TextScaled = true
	label.TextWrapped = true
	label.TextColor3 = Color3.fromRGB(245, 250, 255)
	label.Parent = gui
end

local function setCommonAttributes(instance: Instance, room: PaletteRoom)
	instance:SetAttribute("HeadlessAssemblyTarget", true)
	instance:SetAttribute("RoomId", room.roomId)
	instance:SetAttribute("RoomName", room.roomName)
	instance:SetAttribute("PaletteCommitted", true)
	instance:SetAttribute("PaletteAssetCount", #room.assets)
	instance:SetAttribute("PublishPermission", "missing")
	instance:SetAttribute("MissingPublishPermissionCount", #room.assets)
	instance:SetAttribute("CreatorStorePlacementStatus", "palette_committed_pending_permission_and_fragment")
	instance:SetAttribute("AssetDeliveryStatus", "blocked_401_without_authenticated_client")
	instance:SetAttribute("FragmentContentKind", "committed_palette_intake_anchor")
	instance:SetAttribute("HeadlessAssetIds", assetIdText(room))
end

local function makeFragmentRoot(room: PaletteRoom)
	local root = Instance.new("Model")
	root.Name = room.rootName
	setCommonAttributes(root, room)

	local center = room.center
	local base = makePart(
		"PaletteIntakeBase_" .. safeName(room.roomId),
		root,
		room.baseSize,
		CFrame.new(center.X, 2.35, center.Z),
		room.secondary,
		Enum.Material.Metal
	)
	base:SetAttribute("RoomId", room.roomId)
	base:SetAttribute("ArtPurpose", "headless committed palette intake base")
	base.CanCollide = true

	for _, asset in ipairs(room.assets) do
		local rotationY = math.rad(asset.rotationY or 0)
		local anchor = makePart(
			string.format("AssetAnchor_%d_%s", asset.assetId, safeName(asset.name)),
			root,
			asset.anchorSize,
			CFrame.new(center + asset.offset) * CFrame.Angles(0, rotationY, 0),
			asset.color,
			Enum.Material.Neon
		)
		anchor:SetAttribute("CreatorStoreAssetId", tostring(asset.assetId))
		anchor:SetAttribute("PaletteSlot", asset.slot)
		anchor:SetAttribute("InspectionVerdict", asset.verdict)
		anchor:SetAttribute("SourceSizeStuds", asset.sizeStuds)
		anchor:SetAttribute("PlacementInstruction", asset.note)
		labelPart(
			anchor,
			string.format("%s\nasset %d\n%s - needs authenticated bytes", string.upper(asset.name), asset.assetId, string.upper(asset.verdict)),
			Enum.NormalId.Front
		)
	end

	local permissionGate = makePart(
		"PublishPermissionGate_Missing",
		root,
		Vector3.new(room.baseSize.X - 6, 3.8, 0.55),
		CFrame.new(center.X, 5.15, center.Z + 7.5) * CFrame.Angles(0, math.rad(180), 0),
		Color3.fromRGB(255, 85, 100),
		Enum.Material.SmoothPlastic
	)
	permissionGate:SetAttribute("PublishPermission", "missing")
	permissionGate:SetAttribute("PublishPermissionMode", "grantable_or_open_use")
	permissionGate:SetAttribute("ReleaseGate", "blocked_until_permission_recorded")
	labelPart(
		permissionGate,
		string.format("PUBLISH GATE\n%d permission records missing\nnot release-ready", #room.assets),
		Enum.NormalId.Back
	)

	local routeCue = makePart(
		"PlayerRouteCue_ClearCenter",
		root,
		Vector3.new(room.baseSize.X - 8, 0.22, 2),
		CFrame.new(center.X, 2.7, center.Z + 1.5),
		room.accent,
		Enum.Material.Neon
	)
	routeCue:SetAttribute("PlayerAngleReviewIntent", "keep center route readable after final asset replacement")

	root.PrimaryPart = base
	return root
end

local function generateRoom(room: PaletteRoom, outputModel: string?, outputManifest: string?)
	outputModel = outputModel or room.outputModel
	outputManifest = outputManifest or manifestPathFor(outputModel)
	ensureDir(dirname(outputModel))
	ensureDir(dirname(outputManifest))

	local root = makeFragmentRoot(room)
	local modelBytes = roblox.serializeModel({ root })
	fs.writeFile(outputModel, modelBytes)

	local assetIds = {}
	for _, asset in ipairs(room.assets) do
		table.insert(assetIds, asset.assetId)
	end

	local manifest = {
		version = "roblox-fragment-manifest/v1",
		fragment_id = room.fragmentId,
		target_parent = TARGET_PARENT,
		order_key = room.orderKey,
		model_path = outputModel,
		root_name = room.rootName,
		roots = { room.rootName },
		single_root = true,
		source_digest = "sha256:" .. serde.hash("sha256", modelBytes),
		asset_ids = assetIds,
		identity_policy = {
			referents = "coordinator_remap",
			unique_ids = "strip",
			history_ids = "strip",
		},
		replace_existing = true,
		external_anchors = {
			{
				path = room.anchorPath,
				purpose = "final room-space placement parent after WorldV2 generation",
				required = false,
			},
		},
		safety = {
			dangerous_loader_review = "no scripts in generated fragment; real asset bytes not downloaded in this pass",
			asset_delivery_status = "401 without authenticated Roblox client context",
			publish_permission_status = "missing",
		},
	}

	fs.writeFile(outputManifest, serde.encode("json", manifest))
	print(string.format(
		"COMMITTED_PALETTE_FRAGMENT_OK room=%s model=%s manifest=%s digest=%s assets=%s",
		room.roomId,
		outputModel,
		outputManifest,
		manifest.source_digest,
		table.concat(assetIds, ",")
	))
end

if args[1] == "--all" then
	for _, roomId in ipairs(ROOM_ORDER) do
		generateRoom(ROOMS[roomId])
	end
elseif args[1] and ROOMS[args[1]] then
	local room = ROOMS[args[1]]
	generateRoom(room, args[2], args[3])
else
	local room = ROOMS.cyber_arcade_overclock
	generateRoom(room, args[1], args[2])
end
