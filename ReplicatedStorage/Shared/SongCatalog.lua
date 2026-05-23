local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SongCatalog = {}

local shared = ReplicatedStorage:WaitForChild("Shared")
local songs = {}
local publicSongs = {}
local localTestSongs = {}
local seen = {}

local DEFAULT_MODULES = {
    "Chart_NeonGroan",
    "Chart_RomanticTubeDisaster",
    "Chart_MallBalladButWrong",
}

local function validSong(song)
    if type(song) ~= "table" or type(song.Id) ~= "string" or song.Id == "" then
        return false
    end
    if type(song.Title) ~= "string" or song.Title == "" then
        return false
    end
    if type(song.Duration) ~= "number" or song.Duration <= 0 then
        return false
    end
    if type(song.Notes) ~= "table" or #song.Notes == 0 then
        return false
    end
    for _, note in ipairs(song.Notes) do
        if type(note.id) ~= "string" or type(note.time) ~= "number" or type(note.lane) ~= "number" then
            return false
        end
        if note.lane < 1 or note.lane > 4 then
            return false
        end
    end
    return true
end

local function addSong(song, group)
    if not validSong(song) or seen[song.Id] then
        return false
    end
    seen[song.Id] = true
    song.CatalogGroup = group or "Public"
    table.insert(songs, song)
    if song.CatalogGroup == "LocalTest" then
        table.insert(localTestSongs, song)
    else
        table.insert(publicSongs, song)
    end
    return true
end

for _, moduleName in ipairs(DEFAULT_MODULES) do
    local module = shared:FindFirstChild(moduleName)
    if module and module:IsA("ModuleScript") then
        local ok, song = pcall(require, module)
        if ok then
            song.SafePublicDemo = true
            addSong(song, "Public")
        else
            warn("Groan Tube Hero: failed to load public chart", moduleName, song)
        end
    end
end

local generatedModules = {}
for _, child in ipairs(shared:GetChildren()) do
    if child:IsA("ModuleScript") and (child.Name:match("^Chart_LocalAudioSong%d+$") or child.Name:match("^Chart_DownloadSong%d+$")) then
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
        song.LocalTestOnly = true
        addSong(song, "LocalTest")
    else
        warn("Groan Tube Hero: skipped invalid local test chart", module.Name, song)
    end
end

local byId = {}
for _, song in ipairs(songs) do
    byId[song.Id] = song
end

SongCatalog.All = songs
SongCatalog.Public = publicSongs
SongCatalog.LocalTest = localTestSongs
SongCatalog.ById = byId

function SongCatalog.Get(songId)
    return byId[songId]
end

function SongCatalog.List(includeLocalTests)
    -- Backward compatibility: older live clients call List() with no args.
    -- Return all playable songs then; new UI passes false for public-only.
    if includeLocalTests == false then
        return publicSongs
    end
    return songs
end

function SongCatalog.ListLocalTests()
    return localTestSongs
end

function SongCatalog.GetDefaultSong()
    return publicSongs[1] or songs[1]
end

return SongCatalog
