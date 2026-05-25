local WorldV2Config = {}

WorldV2Config.RootName = "GTH_WorldV2"
WorldV2Config.CoordinateConvention = "0=East(+X), 90=North(+Z), 180=West(-X), 270=South(-Z)"
WorldV2Config.Rings = {
    PerformanceCenter = { Min = 0, Max = 18 },
    StageCircle = { Min = 20, Max = 34 },
    VendorWalkway = { Min = 36, Max = 48 },
    FenceRing = { Min = 50, Max = 58 },
    HordePressureRing = { Min = 60, Max = 82 },
    AudienceRing = { Min = 84, Max = 105 },
    VolcanoOuterRing = { Min = 110, Max = 150 },
}
WorldV2Config.RootFolders = {
    "ArenaCore",
    "StageCircle",
    "InnerPlayerRing",
    "VendorRing",
    "FenceRing",
    "HordeRing",
    "AudienceRing",
    "VolcanoOuterRing",
    "OuterVolcanoRing",
    "LightingAnchors",
    "InvisibleGameplayHitboxes",
    "CompatibilityAdapters",
}
WorldV2Config.ArtAssetFolders = { "Stage", "Lobby", "Horde", "Audience", "Volcano", "Lighting", "Props" }
WorldV2Config.PlaceholderNames = { Part = true, Block = true, Circle = true, Cylinder = true, Temp = true, Debug = true }
WorldV2Config.RequiredArtAssets = { "WorldV2_SafeProceduralKit" }
WorldV2Config.Viewports = {
    Desktop = Vector2.new(1920, 1080),
    Laptop = Vector2.new(1366, 768),
    iPad = Vector2.new(1024, 768),
    iPhone = Vector2.new(844, 390),
    SmallPhone = Vector2.new(667, 375),
}

return WorldV2Config
