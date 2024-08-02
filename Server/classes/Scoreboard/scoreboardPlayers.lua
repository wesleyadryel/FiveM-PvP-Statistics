--- Class representing scoreboard players
---@class ScoreboardPlayers
ScoreboardPlayers = {}
ScoreboardPlayers.__index = ScoreboardPlayers

--- Creates a new ScoreboardPlayers instance
---@param groupPlayer string
---@param playerLicense string
---@return ScoreboardPlayers
function ScoreboardPlayers:new(groupPlayer, playerLicense)
    local instance = setmetatable({}, ScoreboardPlayers)
    instance.groupPlayer = groupPlayer
    instance.playerLicense = playerLicense
    instance.rounds = {}
    instance.currentRound = nil
    return instance
end

--- Gets the data for the current round
---@return table
function ScoreboardPlayers:getCurrentRoundData()
    local currentRound = self.currentRound
    if not currentRound then
        return {}
    end
    if self.rounds[currentRound] then
        return self.rounds[currentRound]
    end
    return {}
end

--- Sets the current round index
---@param roundIndex any
---@return table
function ScoreboardPlayers:setRound(roundIndex)
    if not roundIndex then
        return
    end
    roundIndex = tostring(roundIndex)
    if not self.rounds[roundIndex] then
        self.rounds[roundIndex] = {}
    end
    self.currentRound = roundIndex
    return self.rounds[roundIndex]
end

--- Adds a new damage event to the current round
---@param damageEvent table
function ScoreboardPlayers:newDamageEvent(damageEvent)
    if not damageEvent or not self.currentRound or not self.rounds[self.currentRound] then
        return
    end
    table.insert(self.rounds[self.currentRound], damageEvent)
end

--- Checks if the event represents a kill
---@param event table
---@return boolean
function ScoreboardPlayers:isKillEvent(event)
    return event and event.willKill and event.attackerGroup and
               (event.attackerGroup == self.groupPlayer)
end

--- Checks if the event represents damage done by the player
---@param event table
---@return boolean
function ScoreboardPlayers:isDamageDoneEvent(event)
    return event and event.weaponDamage and event.attackerGroup and (event.attackerGroup == self.groupPlayer)
end

--- Checks if the event represents damage received by the player
---@param event table
---@return boolean
function ScoreboardPlayers:isDamageReceivedEvent(event)
    return event and event.weaponDamage and event.victimGroup and (event.victimGroup == self.groupPlayer)
end

--- Checks if the event represents a death
---@param event table
---@return boolean
function ScoreboardPlayers:isDeathEvent(event)
    return event and event.willKill and event.victimGroup and (event.victimGroup == self.groupPlayer)
end

--- Gets the number of kills for the current round
---@return number
function ScoreboardPlayers:getRoundNumKills()
    local kills = 0
    if not self.currentRound or not self.rounds[self.currentRound] then
        return kills
    end
    for _, v in pairs(self.rounds[self.currentRound]) do
        if self:isKillEvent(v) then
            kills = kills + 1
        end
    end
    return kills
end

--- Gets the total damage done for the current round
---@return number
function ScoreboardPlayers:getRoundTotalDamageDone()
    local damage = 0
    if not self.currentRound or not self.groupPlayer or not self.rounds[self.currentRound] then
        return damage
    end
    for _, v in pairs(self.rounds[self.currentRound]) do
        if self:isDamageDoneEvent(v) then
            damage = damage + v.weaponDamage
        end
    end
    return damage
end

--- Gets the total damage received for the current round
---@return number
function ScoreboardPlayers:getRoundTotalDamageReceived()
    local damage = 0
    if not self.currentRound or not self.groupPlayer or not self.rounds[self.currentRound] then
        return damage
    end
    for _, v in pairs(self.rounds[self.currentRound]) do
        if self:isDamageReceivedEvent(v) then
            damage = damage + v.weaponDamage
        end
    end
    return damage
end

--- Gets the number of deaths for the current round
---@return number
function ScoreboardPlayers:getRoundNumDeaths()
    local deaths = 0
    if not self.currentRound or not self.rounds[self.currentRound] then
        return deaths
    end
    for _, v in pairs(self.rounds[self.currentRound]) do
        if self:isDeathEvent(v) then
            deaths = deaths + 1
        end
    end
    return deaths
end

--- Gets the metrics for the current round
---@return table
function ScoreboardPlayers:getRoundMetrics()
    local roundKills = 0
    local roundDamageDone = 0
    local roundDamageReceived = 0
    local roundDeaths = 0

    if not self.currentRound or not self.rounds[self.currentRound] then
        return {
            roundKills = roundKills,
            roundDamageDone = roundDamageDone,
            roundDamageReceived = roundDamageReceived,
            roundDeaths = roundDeaths
        }
    end

    for _, v in pairs(self.rounds[self.currentRound]) do
        if self:isKillEvent(v) then
            roundKills = roundKills + 1
        end
        if self:isDamageDoneEvent(v) then
            roundDamageDone = roundDamageDone + v.weaponDamage
        end
        if self:isDamageReceivedEvent(v) then
            roundDamageReceived = roundDamageReceived + v.weaponDamage
        end
        if self:isDeathEvent(v) then
            roundDeaths = roundDeaths + 1
        end
    end

    return {
        roundKills = roundKills,
        roundDamageDone = roundDamageDone,
        roundDamageReceived = roundDamageReceived,
        roundDeaths = roundDeaths
    }
end

--- Gets the aggregated metrics for all rounds
---@return table
function ScoreboardPlayers:getMetrics()
    local totalKills = 0
    local totalDamageDone = 0
    local totalDamageReceived = 0
    local totalDeaths = 0

    local roundsMetrics = {}

    for roundIndex, events in pairs(self.rounds) do
        local roundKills = 0
        local roundDamageDone = 0
        local roundDamageReceived = 0
        local roundDeaths = 0

        for _, v in pairs(events) do
            if self:isKillEvent(v) then
                roundKills = roundKills + 1
            end
            if self:isDamageDoneEvent(v) then
                roundDamageDone = roundDamageDone + v.weaponDamage
            end
            if self:isDamageReceivedEvent(v) then
                roundDamageReceived = roundDamageReceived + v.weaponDamage
            end
            if self:isDeathEvent(v) then
                roundDeaths = roundDeaths + 1
            end
        end

        totalKills = totalKills + roundKills
        totalDamageDone = totalDamageDone + roundDamageDone
        totalDamageReceived = totalDamageReceived + roundDamageReceived
        totalDeaths = totalDeaths + roundDeaths

        roundsMetrics[roundIndex] = {
            roundKills = roundKills,
            roundDamageDone = roundDamageDone,
            roundDamageReceived = roundDamageReceived,
            roundDeaths = roundDeaths,
            damageEvents = events
        }
    end

    return {
        playerLicense = self.playerLicense,
        totalKills = totalKills,
        totalDamageDone = totalDamageDone,
        totalDamageReceived = totalDamageReceived,
        totalDeaths = totalDeaths,
        roundsMetrics = roundsMetrics
    }
end

--- Gets the aggregated metrics for all rounds
---@return table
function ScoreboardPlayers:getMetricsPanel()
    local totalKills = 0
    local totalDamageDone = 0
    local totalDamageReceived = 0
    local totalDeaths = 0

    for roundIndex, events in pairs(self.rounds) do
        local roundKills = 0
        local roundDamageDone = 0
        local roundDamageReceived = 0
        local roundDeaths = 0

        for _, v in pairs(events) do

            if self:isKillEvent(v) then
                roundKills = roundKills + 1
            end

            if self:isDamageDoneEvent(v) then
                roundDamageDone = roundDamageDone + v.weaponDamage
            end
            if self:isDamageReceivedEvent(v) then
                roundDamageReceived = roundDamageReceived + v.weaponDamage
            end
            if self:isDeathEvent(v) then
                roundDeaths = roundDeaths + 1
            end
        end

        totalKills = totalKills + roundKills
        totalDamageDone = totalDamageDone + roundDamageDone
        totalDamageReceived = totalDamageReceived + roundDamageReceived
        totalDeaths = totalDeaths + roundDeaths
    end


    return {
        totalKills = totalKills,
        totalDamageDone = totalDamageDone,
        totalDamageReceived = totalDamageReceived,
        totalDeaths = totalDeaths
    }
end
