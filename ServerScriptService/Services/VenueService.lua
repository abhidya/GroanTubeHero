local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.Shared.EconomyConfig)
local VenueConfig = require(ReplicatedStorage.Shared.VenueConfig)

local VenueService = {}
VenueService.__index = VenueService

function VenueService:Init(runtimeContext)
    self.context = runtimeContext
end

function VenueService:GetVenue(venueId)
    return VenueConfig.Get(venueId)
end

function VenueService:GetRewardModifiers(venueId)
    local venue = self:GetVenue(venueId)
    local modifiers = EconomyConfig.VenueModifiers[venueId] or EconomyConfig.VenueModifiers.SchoolStage
    return venue, modifiers
end

function VenueService:GetFeeMultiplier(venueId, profile)
    local venue = self:GetVenue(venueId)
    local fee = venue.fee or 0
    local roadCrew = (profile.TourBus and profile.TourBus.RoadCrew) or 0
    fee = math.max(0, fee - roadCrew * 0.02)
    return fee
end

function VenueService:GetVenueName(venueId)
    return self:GetVenue(venueId).name
end

return VenueService
