local SongCatalog = {}

local NeonGroan = require(script.Parent.Chart_NeonGroan)
local RomanticTubeDisaster = require(script.Parent.Chart_RomanticTubeDisaster)
local MallBalladButWrong = require(script.Parent.Chart_MallBalladButWrong)

local songs = {
    NeonGroan,
    RomanticTubeDisaster,
    MallBalladButWrong,
}

local byId = {}
for _, song in ipairs(songs) do
    byId[song.Id] = song
end

SongCatalog.All = songs
SongCatalog.ById = byId

function SongCatalog.Get(songId)
    return byId[songId] or songs[1]
end

function SongCatalog.List()
    return songs
end

function SongCatalog.GetDefaultSong()
    return songs[1]
end

return SongCatalog
