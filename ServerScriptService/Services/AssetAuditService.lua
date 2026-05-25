local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local SharedAudit = require(ReplicatedStorage.Shared.WorldV2.AssetAuditService)

local AssetAuditService = {}

local SUSPICIOUS_PATTERNS = {
    "require%s*%(", "require%s*%(%s*%d+", "loadstring", "getfenv", "setfenv", "HttpService", "InsertService",
    "AssetService", "LoadAsset", "LoadAssetAsync", "LinkedSource", "_G", "shared",
}

local function ensureFolder(parent, name)
    local f = parent:FindFirstChild(name)
    if not f then f = Instance.new("Folder"); f.Name = name; f.Parent = parent end
    return f
end

function AssetAuditService.EnsureRoots()
    local quarantine = ensureFolder(ServerStorage, "AssetQuarantine")
    local inbox = ensureFolder(Workspace, "AssetInbox")
    local art = ensureFolder(ReplicatedStorage, "ArtAssets")
    for _, name in ipairs({ "Stage", "Lobby", "Horde", "Audience", "Volcano", "Lighting", "Props" }) do
        ensureFolder(art, name)
    end
    return { Quarantine = quarantine, Inbox = inbox, ArtAssets = art }
end

function AssetAuditService.Audit(root)
    local counts, scripts = SharedAudit.Audit(root)
    counts.suspiciousScripts = 0
    counts.suspiciousFindings = {}
    for _, scriptInst in ipairs(scripts) do
        local source = ""
        pcall(function() source = scriptInst.Source or "" end)
        for _, pattern in ipairs(SUSPICIOUS_PATTERNS) do
            if string.find(source, pattern) then
                counts.suspiciousScripts += 1
                table.insert(counts.suspiciousFindings, scriptInst:GetFullName() .. " pattern=" .. pattern)
                break
            end
        end
    end
    return counts, scripts
end

function AssetAuditService.QuarantineScripts(root, reason)
    AssetAuditService.EnsureRoots()
    local moved = {}
    local quarantine = ServerStorage.AssetQuarantine
    for _, desc in ipairs(root:GetDescendants()) do
        if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
            desc.Disabled = true
            desc:SetAttribute("QuarantineReason", reason or "Third-party script not project-owned")
            table.insert(moved, desc:GetFullName())
            desc.Parent = quarantine
        end
    end
    return moved
end

return AssetAuditService
