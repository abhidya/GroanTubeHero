local SongCatalog = {}

local NeonGroan = require(script.Parent.Chart_NeonGroan)
local RomanticTubeDisaster = require(script.Parent.Chart_RomanticTubeDisaster)
local MallBalladButWrong = require(script.Parent.Chart_MallBalladButWrong)
local DownloadSong001 = require(script.Parent.Chart_DownloadSong001)
local DownloadSong002 = require(script.Parent.Chart_DownloadSong002)
local DownloadSong003 = require(script.Parent.Chart_DownloadSong003)
local DownloadSong004 = require(script.Parent.Chart_DownloadSong004)
local DownloadSong005 = require(script.Parent.Chart_DownloadSong005)
local DownloadSong006 = require(script.Parent.Chart_DownloadSong006)
local DownloadSong007 = require(script.Parent.Chart_DownloadSong007)
local DownloadSong008 = require(script.Parent.Chart_DownloadSong008)
local DownloadSong009 = require(script.Parent.Chart_DownloadSong009)
local DownloadSong010 = require(script.Parent.Chart_DownloadSong010)
local DownloadSong011 = require(script.Parent.Chart_DownloadSong011)
local DownloadSong012 = require(script.Parent.Chart_DownloadSong012)
local DownloadSong013 = require(script.Parent.Chart_DownloadSong013)
local DownloadSong014 = require(script.Parent.Chart_DownloadSong014)
local DownloadSong015 = require(script.Parent.Chart_DownloadSong015)
local DownloadSong016 = require(script.Parent.Chart_DownloadSong016)
local DownloadSong017 = require(script.Parent.Chart_DownloadSong017)
local DownloadSong018 = require(script.Parent.Chart_DownloadSong018)
local DownloadSong019 = require(script.Parent.Chart_DownloadSong019)
local DownloadSong020 = require(script.Parent.Chart_DownloadSong020)
local DownloadSong021 = require(script.Parent.Chart_DownloadSong021)
local DownloadSong022 = require(script.Parent.Chart_DownloadSong022)
local DownloadSong023 = require(script.Parent.Chart_DownloadSong023)
local DownloadSong024 = require(script.Parent.Chart_DownloadSong024)
local DownloadSong025 = require(script.Parent.Chart_DownloadSong025)
local DownloadSong026 = require(script.Parent.Chart_DownloadSong026)
local DownloadSong027 = require(script.Parent.Chart_DownloadSong027)
local DownloadSong028 = require(script.Parent.Chart_DownloadSong028)
local DownloadSong029 = require(script.Parent.Chart_DownloadSong029)
local DownloadSong030 = require(script.Parent.Chart_DownloadSong030)
local DownloadSong031 = require(script.Parent.Chart_DownloadSong031)
local DownloadSong032 = require(script.Parent.Chart_DownloadSong032)
local DownloadSong033 = require(script.Parent.Chart_DownloadSong033)
local DownloadSong034 = require(script.Parent.Chart_DownloadSong034)
local DownloadSong035 = require(script.Parent.Chart_DownloadSong035)
local DownloadSong036 = require(script.Parent.Chart_DownloadSong036)
local DownloadSong037 = require(script.Parent.Chart_DownloadSong037)
local DownloadSong038 = require(script.Parent.Chart_DownloadSong038)
local DownloadSong039 = require(script.Parent.Chart_DownloadSong039)

local songs = {
    NeonGroan,
    RomanticTubeDisaster,
    MallBalladButWrong,
    DownloadSong001,
    DownloadSong002,
    DownloadSong003,
    DownloadSong004,
    DownloadSong005,
    DownloadSong006,
    DownloadSong007,
    DownloadSong008,
    DownloadSong009,
    DownloadSong010,
    DownloadSong011,
    DownloadSong012,
    DownloadSong013,
    DownloadSong014,
    DownloadSong015,
    DownloadSong016,
    DownloadSong017,
    DownloadSong018,
    DownloadSong019,
    DownloadSong020,
    DownloadSong021,
    DownloadSong022,
    DownloadSong023,
    DownloadSong024,
    DownloadSong025,
    DownloadSong026,
    DownloadSong027,
    DownloadSong028,
    DownloadSong029,
    DownloadSong030,
    DownloadSong031,
    DownloadSong032,
    DownloadSong033,
    DownloadSong034,
    DownloadSong035,
    DownloadSong036,
    DownloadSong037,
    DownloadSong038,
    DownloadSong039,
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
