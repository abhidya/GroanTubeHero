--!strict
-- Verify that a headless fragment merge output reloads and contains a root.

local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local args = process.args
local placePath = args[1] or "/private/tmp/GroanTubeHero-cyber-palette-fragment-merged.rbxl"
local targetParentPath = args[2] or "Workspace.GTH_WorldV2.ThemedRoomSpaces"
local rootName = args[3] or "CommittedPalette_CyberArcadeOverclock"
local expectedAssetIdsCsv = args[4] or "637807731,13903220189"

local function splitPath(path: string): { string }
	local parts = {}
	for part in string.gmatch(string.gsub(path, "^game%.", ""), "[^%.]+") do
		table.insert(parts, part)
	end
	return parts
end

local function resolvePath(game: any, path: string)
	local parts = splitPath(path)
	assert(#parts > 0, "empty target path")
	local current = game:GetService(parts[1])
	for index = 2, #parts do
		current = current:FindFirstChild(parts[index])
		assert(current ~= nil, "missing path segment " .. parts[index] .. " in " .. path)
	end
	return current
end

local game = roblox.deserializePlace(fs.readFile(placePath))
local targetParent = resolvePath(game, targetParentPath)
local root = targetParent:FindFirstChild(rootName)
assert(root ~= nil, "merged root missing: " .. rootName)
assert(root:GetAttribute("HeadlessFragmentId") ~= nil, "HeadlessFragmentId missing")
assert(root:GetAttribute("PaletteCommitted") == true, "PaletteCommitted attribute missing")
assert(root:GetAttribute("PublishPermission") == "missing", "PublishPermission missing gate not preserved")
assert(root:GetAttribute("FragmentContentKind") == "committed_palette_intake_anchor", "fragment kind not preserved")

local assetIdText = tostring(root:GetAttribute("HeadlessAssetIds") or "")
for assetId in string.gmatch(expectedAssetIdsCsv, "[^,%s]+") do
	assert(
		string.find(assetIdText, assetId, 1, true) ~= nil,
		string.format("expected asset id missing from %s: %s", rootName, assetId)
	)
end

print(string.format(
	"FRAGMENT_MERGE_VERIFY_OK place=%s parent=%s root=%s children=%d assets=%s",
	placePath,
	targetParentPath,
	rootName,
	#root:GetChildren(),
	assetIdText
))
