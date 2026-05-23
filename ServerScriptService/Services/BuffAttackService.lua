local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local BuffConfig = require(ReplicatedStorage.Shared.BuffConfig)
local AttackConfig = require(ReplicatedStorage.Shared.AttackConfig)

local BuffAttackService = {}
BuffAttackService.__index = BuffAttackService

function BuffAttackService:Init(runtimeContext)
    self.context = runtimeContext
end

local function getNow()
    return os.clock()
end

function BuffAttackService:_ensureSessionState(session)
    session.modifiers = session.modifiers or {}
    session.modifiers.cooldowns = session.modifiers.cooldowns or {}
    session.modifiers.activeAttacks = session.modifiers.activeAttacks or {}
end

function BuffAttackService:CanUse(profile, buffId)
    local item = BuffConfig.Get(buffId)
    if not item then
        return false, "UnknownBuff"
    end
    local owned = profile.OwnedCosmetics and profile.OwnedCosmetics.Buffs and profile.OwnedCosmetics.Buffs[buffId]
    if not owned then
        return false, "NotOwned"
    end
    return true
end

function BuffAttackService:ApplyBuff(session, profile, buffId)
    self:_ensureSessionState(session)
    local buff = BuffConfig.Get(buffId)
    if not buff then
        return false, "UnknownBuff"
    end

    local cooldowns = session.modifiers.cooldowns
    local nowTime = getNow()
    local readyAt = cooldowns[buffId] or 0
    if nowTime < readyAt then
        return false, "Cooldown"
    end
    cooldowns[buffId] = nowTime + (buff.cooldown or 0)

    if buffId == "SecondWind" then
        session.modifiers.secondWind = true
    elseif buffId == "CrowdWarmup" then
        session.stateData.hype = math.min(100, session.stateData.hype + 10)
        session.modifiers.crowdWarmup = true
    elseif buffId == "EncoreEnergy" then
        session.modifiers.encoreEnergy = true
    elseif buffId == "SteadyHands" then
        session.modifiers.steadyHands = true
    elseif buffId == "DramaBoost" then
        session.modifiers.dramaBoost = true
    elseif buffId == "TubeSolo" then
        session.modifiers.tubeSolo = true
    elseif buffId == "DeepBreath" then
        session.modifiers.deepBreath = true
    elseif buffId == "CrowdCall" then
        session.stateData.hype = math.min(100, session.stateData.hype + 15)
    elseif buffId == "StageFocus" then
        session.modifiers.stageFocus = true
    elseif buffId == "EncoreSurge" then
        session.modifiers.encoreSurgeNotes = 10
    elseif buffId == "TubeResonance" then
        session.modifiers.tubeResonanceUntil = nowTime + 5
    elseif buffId == "CleanRun" then
        session.modifiers.cleanRunSection = session.currentSectionIndex or 1
    end
    return true
end

function BuffAttackService:GetAttackCooldown(profile, attackId)
    local attack = AttackConfig.Get(attackId)
    return attack and attack.cooldown or 0
end

function BuffAttackService:ApplyAttack(sourcePlayer, targetPlayer, attackId)
    local attack = AttackConfig.Get(attackId)
    if not attack then
        return false, "UnknownAttack"
    end
    local sourceSession = self.context.Services.SongSessionService:GetSession(sourcePlayer)
    local targetSession = self.context.Services.SongSessionService:GetSession(targetPlayer)
    if not sourceSession or not targetSession then
        return false, "NoSession"
    end
    if targetSession.mode ~= Config.Modes.Battle then
        return false, "BattleOnly"
    end
    self:_ensureSessionState(sourceSession)
    self:_ensureSessionState(targetSession)

    local nowTime = getNow()
    local cooldowns = sourceSession.modifiers.cooldowns
    local readyAt = cooldowns[attackId] or 0
    if nowTime < readyAt then
        return false, "Cooldown"
    end
    cooldowns[attackId] = nowTime + attack.cooldown

    local targetMod = targetSession.modifiers
    targetMod.activeAttacks = targetMod.activeAttacks or {}
    if targetMod.stageFocus then
        targetMod.stageFocus = false
        return true, "Blocked"
    end

    if attackId == "VoiceCrack" then
        targetMod.voiceCrack = true
    elseif attackId == "SpotlightDrift" then
        targetMod.spotlightDriftUntil = nowTime + 2
    elseif attackId == "BooWave" then
        targetMod.booWaveUntil = nowTime + 5
    elseif attackId == "TubeWarp" then
        targetMod.tubeWarpNote = true
    elseif attackId == "MicFeedback" then
        targetMod.micFeedbackUntil = nowTime + 1.5
    elseif attackId == "AwkwardSilence" then
        targetMod.awkwardSilenceUntil = nowTime + 4
    elseif attackId == "Heckle" then
        targetMod.heckleUntil = nowTime + 2
        targetSession.stateData.hype = math.max(0, targetSession.stateData.hype - 2)
    elseif attackId == "TomatoSplash" then
        targetMod.tomatoSplashUntil = nowTime + 1.5
    end

    return true, "Applied"
end

function BuffAttackService:ApplyMissMitigation(session)
    local mods = session.modifiers or {}
    if mods.voiceCrack then
        mods.voiceCrack = false
        return 3
    end
    return 0
end

function BuffAttackService:ShouldIgnoreCrowd(session)
    local mods = session.modifiers or {}
    return mods.awkwardSilenceUntil and getNow() < mods.awkwardSilenceUntil
end

function BuffAttackService:VisualModifiers(session)
    local mods = session.modifiers or {}
    local nowTime = getNow()
    return {
        spotlightDrift = mods.spotlightDriftUntil and nowTime < mods.spotlightDriftUntil,
        booWave = mods.booWaveUntil and nowTime < mods.booWaveUntil,
        micFeedback = mods.micFeedbackUntil and nowTime < mods.micFeedbackUntil,
        tomatoSplash = mods.tomatoSplashUntil and nowTime < mods.tomatoSplashUntil,
        tubeWarp = mods.tubeWarpNote == true,
    }
end

return BuffAttackService
