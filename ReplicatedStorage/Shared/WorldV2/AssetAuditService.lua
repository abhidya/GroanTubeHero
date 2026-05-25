local AssetAuditService = {}

local AUDIT_CLASSES = {
    Script = "scripts",
    LocalScript = "scripts",
    ModuleScript = "scripts",
    MeshPart = "meshParts",
    Part = "parts",
    WedgePart = "parts",
    CornerWedgePart = "parts",
    Sound = "sounds",
    ParticleEmitter = "emitters",
    PointLight = "lights",
    SpotLight = "lights",
    SurfaceLight = "lights",
    Decal = "decals",
    SurfaceAppearance = "surfaceAppearances",
}

function AssetAuditService.Audit(root)
    local counts = {
        scripts = 0,
        meshParts = 0,
        parts = 0,
        sounds = 0,
        emitters = 0,
        lights = 0,
        decals = 0,
        surfaceAppearances = 0,
    }
    local suspiciousScripts = {}
    if not root then
        return counts, suspiciousScripts
    end
    for _, desc in ipairs(root:GetDescendants()) do
        local bucket = AUDIT_CLASSES[desc.ClassName]
        if bucket then
            counts[bucket] += 1
            if bucket == "scripts" then
                table.insert(suspiciousScripts, desc)
            end
        end
    end
    return counts, suspiciousScripts
end

function AssetAuditService.QuarantineScripts(root, quarantineFolder)
    local counts, scripts = AssetAuditService.Audit(root)
    if quarantineFolder then
        for _, scriptInst in ipairs(scripts) do
            scriptInst.Disabled = true
            scriptInst.Parent = quarantineFolder
        end
    end
    return counts, #scripts
end

return AssetAuditService
