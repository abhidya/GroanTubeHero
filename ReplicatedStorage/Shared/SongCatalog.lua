local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local SongCatalog = {}

local shared = ReplicatedStorage:WaitForChild("Shared")
local songs = {}
local publicSongs = {}
local localTestSongs = {}
local seen = {}

local DEFAULT_MODULES = {}

local TITLE_OVERRIDES = {
    LocalAudioSong001 = "Thick of it Thomas the train remix",
    LocalAudioSong005 = "Decorate Ur Life",
    LocalAudioSong008 = "Flawed Mangoes Dramamine",
    LocalAudioSong009 = "Ordinary",
    LocalAudioSong011 = "Lose Control The Village Sessions",
    LocalAudioSong015 = "Spoiled Cover",
    LocalAudioSong016 = "Anything You Can Do I Can Do Better",
    LocalAudioSong017 = "Girl Like Me 2",
    LocalAudioSong018 = "Sneak Out",
    LocalAudioSong021 = "Feat",
    LocalAudioSong022 = "Assumptions",
    LocalAudioSong024 = "It Is Going Down Now",
    LocalAudioSong026 = "Oiia Oiia Spinning Cat",
    LocalAudioSong027 = "Heaven On This Earth",
    LocalAudioSong028 = "Tattletale Parents Revenge",
    LocalAudioSong032 = "Legends Never Die Tribute",
    LocalAudioSong033 = "Up Where We Belong",
    LocalAudioSong036 = "I Am Fine",
    LocalAudioSong037 = "Surrender",
    LocalAudioSong038 = "Love Me Not",
    LocalAudioSong039 = "You Are The Poison I Keep Choosing Still",
}

local function trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function titleCase(value)
    local lowered = tostring(value or ""):lower()
    return (lowered:gsub("(%a)([%w']*)", function(first, rest)
        local word = first .. rest
        if word == "of" or word == "the" or word == "and" or word == "or" or word == "to" or word == "in" or word == "on" then
            return word
        end
        return first:upper() .. rest
    end):gsub("^%l", string.upper))
end

local function cleanRawTitle(raw)
    local title = tostring(raw or "")
    title = title:gsub("^%d+%s*[%-%–]%s*", ""):gsub("%b[]", ""):gsub("_", " ")
    title = title:gsub("%f[%a]Official%f[%A]", ""):gsub("%f[%a]Lyric%f[%A]", "")
    title = title:gsub("%f[%a]Video%f[%A]", ""):gsub("%f[%a]Visualizer%f[%A]", "")
    title = title:gsub("%f[%a]Audio%f[%A]", ""):gsub("%f[%a]Music%f[%A]", "")
    title = title:gsub("%f[%a]Extended%f[%A]", ""):gsub("%s+", " ")
    return trim(titleCase(title))
end

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
        local number = module.Name:match("Chart_LocalAudioSong(%d+)$")
        if number then
            song.Id = "LocalAudioSong" .. number
            song.SourceTitle = TITLE_OVERRIDES[song.Id] or cleanRawTitle(song.Title)
            song.Title = Config.DebugRhythm and song.SourceTitle or ("Local Audio Song " .. number)
        end
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
    return byId.LocalAudioSong001 or localTestSongs[1] or songs[1]
end

function SongCatalog.PrettyTitle(songOrId)
    local id = type(songOrId) == "table" and songOrId.Id or tostring(songOrId or "")
    local number = tostring(id):match("LocalAudioSong(%d+)") or tostring(id):match("Local Audio Song (%d+)")
    if number and not Config.DebugRhythm then
        return "Local Audio Song " .. number
    end
    if TITLE_OVERRIDES[id] then
        return TITLE_OVERRIDES[id]
    end
    if type(songOrId) == "table" and type(songOrId.Title) == "string" and trim(songOrId.Title) ~= "" then
        return cleanRawTitle(songOrId.Title)
    end
    if number then
        return "Local Audio Song " .. number
    end
    return tostring(id):gsub("(%l)(%u)", "%1 %2")
end

return SongCatalog
