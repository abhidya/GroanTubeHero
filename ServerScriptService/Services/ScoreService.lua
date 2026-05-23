local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Scoring = require(ReplicatedStorage.Shared.Scoring)

local ScoreService = {}
ScoreService.__index = ScoreService

local function adjustMultiplier(state)
    state.multiplier = Scoring.GetMultiplier(state.combo)
end

function ScoreService:Init(runtimeContext)
    self.context = runtimeContext
end

function ScoreService:CreateState(song, mode)
    return {
        songId = song.Id,
        mode = mode,
        totalNotes = #song.Notes,
        score = 0,
        combo = 0,
        maxCombo = 0,
        perfect = 0,
        good = 0,
        miss = 0,
        multiplier = 1,
        hype = 0,
        hp = 100,
        downed = false,
        revived = false,
        power = 0,
        accuracyPoints = 0,
        sectionIndex = 1,
        sectionPerfects = 0,
        sectionMisses = 0,
        chorusStreak = 0,
        noteIndex = 0,
    }
end

function ScoreService:GetTimingBonus(profile, session)
    local bonus = (profile.Upgrades.Timing or 0) * 0.01
    if session.modifiers and session.modifiers.steadyHands then
        bonus = bonus + 0.015
    end
    return bonus
end

function ScoreService:GetGoodWindowBonus(profile, mode, session)
    if mode == Config.Modes.Pure then
        return 0
    end
    local bonus = (profile.Upgrades.Timing or 0) * 0.01
    if session.modifiers and session.modifiers.steadyHands then
        bonus = bonus + 0.02
    end
    return bonus
end

function ScoreService:GetHypeOnHit(profile, mode, judgement, session)
    if mode == Config.Modes.Pure then
        return judgement == "Perfect" and 2 or 1
    end
    local base = 0
    if judgement == "Perfect" then
        base = 4
    elseif judgement == "Good" then
        base = 2
    end
    base = base + (profile.Upgrades.HypeGain or 0)
    if session.modifiers and session.modifiers.dramaBoost and judgement == "Perfect" then
        base = base + 2
    end
    return base
end


function ScoreService:GetMissDamage(profile, session)
    local damage = 10
    local upgrades = profile.Upgrades or {}
    local levelReduction = math.min(0.15, math.max(0, ((profile.Level or 1) - 1) * 0.005))
    damage = damage * (1 - math.min(0.5, (upgrades.Recovery or 0) * 0.10))
    damage = damage * (1 - levelReduction)
    if session.modifiers and session.modifiers.recoveryShield then
        damage = damage * 0.75
    end
    if session.modifiers and session.modifiers.voiceCrack then
        damage = damage * 1.25
    end
    if session.mode == Config.Modes.Battle then
        damage = damage * 1.15
    end
    return math.max(1, math.floor(damage + 0.5))
end

function ScoreService:GetMissPenalty(profile, session)
    local penalty = 6
    penalty = math.max(2, penalty - (profile.Upgrades.Recovery or 0))
    if session.modifiers and session.modifiers.recoveryShield then
        penalty = math.max(1, penalty - 2)
    end
    return penalty
end

function ScoreService:ApplyJudgement(session, note, judgement, profile)
    local state = session.stateData
    state.lastDamage = 0
    state.noteIndex = state.noteIndex + 1
    local mode = session.mode

    if judgement == "Perfect" then
        state.perfect = state.perfect + 1
        state.combo = state.combo + 1
        state.sectionPerfects = state.sectionPerfects + 1
        state.score = state.score + (100 * state.multiplier)
        state.accuracyPoints = state.accuracyPoints + 100
        state.hype = math.min(100, state.hype + self:GetHypeOnHit(profile, mode, judgement, session))
        state.power = math.min(100, state.power + 3)
        if state.combo % 10 == 0 then
            state.power = math.min(100, state.power + 10)
        end
        if session.modifiers and session.modifiers.ensembleResonance then
            state.score = state.score + math.floor(100 * 0.2)
        end
        if session.modifiers and session.modifiers.tubeSolo and self:IsChorusSection(session, note.time) then
            state.score = state.score + math.floor(100 * 0.15)
        end
    elseif judgement == "Good" then
        state.good = state.good + 1
        state.combo = state.combo + 1
        state.score = state.score + (50 * state.multiplier)
        state.accuracyPoints = state.accuracyPoints + 50
        state.hype = math.min(100, state.hype + self:GetHypeOnHit(profile, mode, judgement, session))
        state.power = math.min(100, state.power + 1)
    elseif judgement == "Miss" then
        state.miss = state.miss + 1
        state.sectionMisses = state.sectionMisses + 1
        state.score = state.score + 0
        state.hype = math.max(0, state.hype - self:GetMissPenalty(profile, session))
        local damage = self:GetMissDamage(profile, session)
        if session.modifiers and session.modifiers.deepBreath then
            damage = math.max(1, math.floor(damage * 0.5))
        end
        state.hp = math.max(0, (state.hp or 100) - damage)
        state.lastDamage = damage
        state.downed = state.hp <= 0
        if session.modifiers and session.modifiers.deepBreath then
            session.modifiers.deepBreath = false
        else
            state.combo = 0
        end
    end

    if state.combo > state.maxCombo then
        state.maxCombo = state.combo
    end
    adjustMultiplier(state)
    if session.modifiers and session.modifiers.encoreSurgeNotes and session.modifiers.encoreSurgeNotes > 0 then
        state.score = math.floor(state.score * 1.2)
        session.modifiers.encoreSurgeNotes = session.modifiers.encoreSurgeNotes - 1
    end
    if state.hype > 100 then
        state.hype = 100
    end
    if state.hype == 100 then
        state.power = math.min(100, state.power + 1)
    end
    return state
end

function ScoreService:ApplyMissIfNeeded(session, note, profile)
    local state = session.stateData
    if note.hit then
        return state
    end
    return self:ApplyJudgement(session, note, "Miss", profile)
end

function ScoreService:IsChorusSection(session, noteTime)
    local song = session.song
    for _, section in ipairs(song.Sections or {}) do
        if section.name == "Chorus" and noteTime >= section.start and noteTime <= section.finish then
            return true
        end
    end
    return false
end

function ScoreService:Finalize(session)
    local state = session.stateData
    local percent = Scoring.GetAccuracyPercent(state)
    local grade = Scoring.GetGrade(percent)
    local summary = Scoring.BuildSummary(state)
    summary.grade = grade
    summary.accuracyPercent = percent
    summary.songId = session.songId
    summary.mode = session.mode
    summary.venueId = session.venueId
    summary.totalNotes = state.totalNotes
    summary.hp = state.hp or 0
    summary.downed = state.downed == true
    summary.revived = state.revived == true
    summary.clear = state.miss < 5 and not summary.downed
    summary.cleanedSection = state.sectionMisses == 0
    summary.battle = session.mode == Config.Modes.Battle
    return summary
end

return ScoreService
