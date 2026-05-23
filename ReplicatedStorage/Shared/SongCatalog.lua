local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SongCatalog = {}

local shared = ReplicatedStorage:WaitForChild("Shared")

local baseCharts = {
    require(shared:WaitForChild("Chart_NeonGroan")),
    require(shared:WaitForChild("Chart_RomanticTubeDisaster")),
    require(shared:WaitForChild("Chart_MallBalladButWrong")),
}

local songs = {}
local seen = {}

local function addSong(song)
    if type(song) ~= "table" or type(song.Id) ~= "string" or seen[song.Id] then
        return
    end
    seen[song.Id] = true
    table.insert(songs, song)
end

for _, song in ipairs(baseCharts) do
    addSong(song)
end

local generatedModules = {}
for _, child in ipairs(shared:GetChildren()) do
    if child:IsA("ModuleScript") and child.Name:match("^Chart_LocalAudioSong%d+$") then
        table.insert(generatedModules, child)
    end
end
table.sort(generatedModules, function(a, b)
    return a.Name < b.Name
end)

for _, module in ipairs(generatedModules) do
    local ok, song = pcall(require, module)
    if ok then
        song.LocalAudioGenerated = true
        addSong(song)
    else
        warn("Groan Tube Hero: failed to load generated chart", module.Name, song)
    end
end

local byId = {}
for _, song in ipairs(songs) do
    byId[song.Id] = song
end

SongCatalog.All = songs
SongCatalog.ById = byId

function SongCatalog.Get(songId)
    return byId[songId]
end

function SongCatalog.List()
    return songs
end

function SongCatalog.GetDefaultSong()
    return byId.NeonGroan or songs[1]
end

return SongCatalog
