local Config = require(script.Parent.Config)

local Scoring = {}

local function clamp(value, minValue, maxValue)
    return Config.Clamp(value, minValue, maxValue)
end

function Scoring.ResolveJudgement(offsetSeconds, timingBonusSeconds)
    local absValue = math.abs(offsetSeconds)
    local perfectWindow = Config.Judgement.PerfectWindow + (timingBonusSeconds or 0)
    local goodWindow = Config.Judgement.GoodWindow + (timingBonusSeconds or 0)
    local acceptWindow = Config.Judgement.AcceptWindow

    if absValue <= perfectWindow then
        return "Perfect"
    end
    if absValue <= goodWindow then
        return "Good"
    end
    if absValue <= acceptWindow then
        return "Miss"
    end
    return "Reject"
end

function Scoring.GetScoreValue(judgement)
    if judgement == "Perfect" then
        return Config.Judgement.PerfectScore
    elseif judgement == "Good" then
        return Config.Judgement.GoodScore
    end
    return Config.Judgement.MissScore
end

function Scoring.GetMultiplier(combo)
    local tier = math.floor(combo / Config.Judgement.ComboStep)
    local multiplier = 1 + (tier * Config.Judgement.MultiplierStep)
    return clamp(multiplier, 1, Config.Judgement.MultiplierMax)
end

function Scoring.GetGrade(percent)
    if percent >= Config.ScoreGrades.S then
        return "S"
    elseif percent >= Config.ScoreGrades.A then
        return "A"
    elseif percent >= Config.ScoreGrades.B then
        return "B"
    elseif percent >= Config.ScoreGrades.C then
        return "C"
    end
    return "D"
end

function Scoring.GetAccuracyPercent(state)
    -- Accuracy/grade must measure judgement quality, not multiplied score.
    -- Combo multipliers and buffs can push score above the base perfect total,
    -- but the results screen should still cap a clean run at 100% accuracy.
    local totalPossible = math.max(1, state.totalNotes * Config.Judgement.PerfectScore)
    local points = state.accuracyPoints or state.score or 0
    return clamp((points / totalPossible) * 100, 0, 100)
end

function Scoring.GetHypeTier(hypeValue)
    if hypeValue <= Config.Hype.DeadRoom.max then
        return "Dead Room"
    elseif hypeValue <= Config.Hype.UnsureCrowd.max then
        return "Unsure Crowd"
    elseif hypeValue <= Config.Hype.IntoIt.max then
        return "Into It"
    end
    return "Encore Mode"
end

function Scoring.GetNoteWindowState(offsetSeconds)
    local absValue = math.abs(offsetSeconds)
    if absValue <= Config.Judgement.PerfectWindow then
        return "Perfect"
    elseif absValue <= Config.Judgement.GoodWindow then
        return "Good"
    elseif absValue <= Config.Judgement.AcceptWindow then
        return "Miss"
    end
    return "Reject"
end

function Scoring.BuildSummary(state)
    local accuracyPercent = Scoring.GetAccuracyPercent(state)
    return {
        score = state.score,
        perfect = state.perfect,
        good = state.good,
        miss = state.miss,
        maxCombo = state.maxCombo,
        combo = state.combo,
        multiplier = state.multiplier,
        accuracyPercent = accuracyPercent,
        grade = Scoring.GetGrade(accuracyPercent),
        hype = state.hype,
        hp = state.hp or 0,
        downed = state.downed == true,
        revived = state.revived == true,
        hypeTier = Scoring.GetHypeTier(state.hype),
        power = state.power,
        battle = state.mode == Config.Modes.Battle,
    }
end

return Scoring
