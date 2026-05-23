local VenueConfig = {}

VenueConfig.Venues = {
    SchoolStage = { id = "SchoolStage", name = "School Stage", fee = 0, difficulty = "Easy", fansMultiplier = 1.0, hypeBonus = 0, ticketChance = 0.05, description = "Beginner-friendly with no venue fee." },
    MallBooth = { id = "MallBooth", name = "Mall Booth", fee = 0.05, difficulty = "Easy", fansMultiplier = 1.0, hypeBonus = 0, ticketChance = 0.12, description = "Small crowd, low risk, better ticket chance." },
    NeonArena = { id = "NeonArena", name = "Neon Arena", fee = 0.10, difficulty = "Medium", fansMultiplier = 1.35, hypeBonus = 0, ticketChance = 0.07, description = "Bigger crowd and stronger fans growth." },
    WeddingHall = { id = "WeddingHall", name = "Wedding Hall", fee = 0.08, difficulty = "Medium", fansMultiplier = 1.05, hypeBonus = 8, ticketChance = 0.08, description = "Audience hype rises quickly if you keep it clean." },
    SpaceLounge = { id = "SpaceLounge", name = "Space Lounge", fee = 0.15, difficulty = "Hard", fansMultiplier = 1.20, hypeBonus = 4, ticketChance = 0.15, description = "High risk, rare event energy, premium ticket chance." },
}

function VenueConfig.Get(venueId)
    return VenueConfig.Venues[venueId] or VenueConfig.Venues.SchoolStage
end

function VenueConfig.ListIds()
    local ids = {}
    for key in pairs(VenueConfig.Venues) do
        ids[#ids + 1] = key
    end
    return ids
end

return VenueConfig
