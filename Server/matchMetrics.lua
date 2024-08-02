local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}
local matchesMetrics = {}
local resourceName = GetCurrentResourceName()
local filenameCache = 'matches_metrics.json'

Citizen.CreateThread(function()
    local fileCache = LoadResourceFile(resourceName, filenameCache)
    if fileCache then
        local data = json.decode(fileCache)
        if data then
            matchesMetrics = data
        end
    end
end)

---Retrieves match metrics for a specific match index.
---@param matchIndex  string The index of the match to retrieve metrics for.
---@return table The metrics data for the specified match index, or nil if matchIndex is not provided.
Utils.getMatchMetrics = function(matchIndex)
    if not matchIndex then
        return
    end
    return matchesMetrics[matchIndex]
end

---Retrieves player metrics for a specific player license.
---@param playerLicense string The license of the player to retrieve metrics for.
---@return table A table containing metrics for the specified player license. If no playerLicense is provided, returns an empty table.
Utils.getPlayersMetrics = function(playerLicense)
    if not playerLicense then
        return {}
    end
    local data = {}
    if matchesMetrics then
        for matchIndex, matchData in pairs(matchesMetrics) do
            data[matchIndex] = {}
            data[matchIndex].playersMetrics = {}
            data[matchIndex].roundWinners = matchData.roundWinners
            data[matchIndex].matchMetrics = matchData.matchMetrics
            if matchData.playersMetrics then
                for k, v in pairs(matchData.playersMetrics) do
                    if v and v.playerLicense and (v.playerLicense == playerLicense) then
                        data[matchIndex].playersMetrics[k] = v
                    end
                end
            end
        end
    end
    return data
end

---Sets match metrics for a specific match index and saves the data to a file.
---@param matchIndex string The index of the match to set metrics for.
---@param data table A table containing the metrics data to be set.
---@return nil
Utils.setMatchMetrics = function(matchIndex, data)
    if not matchIndex or type(data) ~= 'table' then
        return
    end
    matchesMetrics[matchIndex] = data
    SaveResourceFile(resourceName, filenameCache, json.encode(matchesMetrics), -1)
end

---Retrieves all match metrics.
---@return table A table containing all match metrics.
Utils.getMatchesMetrics = function()
    return matchesMetrics
end

----Retrieves metrics for a match instance.
---@param matchIndex string The index of the match instance to retrieve metrics for.
---@return table A table containing metrics for the match instance, including player metrics, round winners, and match metrics.
Utils.getMatchInstanceMetrics = function(matchIndex)
    local data = {}
    local playersInstances = SCOREBOARD_PLAYERS_INSTANCES[matchIndex]
    local matchInstance = MATCHES_INSTANCES[matchIndex] or {}

    data.playersMetrics = {}
    if playersInstances then
        for playerSource, metrics in pairs(playersInstances) do
            data.playersMetrics[playerSource] = metrics:getMetrics()
        end
    end

    data.roundWinners = {}
    if matchInstance then
        local roundWinners = matchInstance:getRoundWinners()
        if roundWinners then
            data.roundWinners = roundWinners
        end
    end

    data.matchMetrics = {}
    data.matchMetrics.startIn = matchInstance.startIn
    data.matchMetrics.finishIn = matchInstance.finishIn
    data.matchMetrics.winningGroup = matchInstance.winningGroup

    return data
end

---- Sorts match indexes by their start time in descending order.
---@return string[] A table of match IDs sorted by startIn timestamp in descending order.
Utils.sortMatchIndexesByStartTime = function()
    local matchIndexes = {}
    for matchId, matchData in pairs(matchesMetrics) do
        table.insert(matchIndexes, matchId)
    end
    local function compareMatchStartTimes(a, b)
        return matchesMetrics[a].matchMetrics.startIn > matchesMetrics[b].matchMetrics.startIn
    end
    table.sort(matchIndexes, compareMatchStartTimes)
    return matchIndexes
end

Utils.getLastMatchPlayer = function(playerLicense)
    if not playerLicense then
        return
    end
    local sort = Utils.sortMatchIndexesByStartTime()
    for __, matchIndex in pairs(sort) do
        local data = matchesMetrics[matchIndex]
        if data then
            local playersMetrics = data.playersMetrics
            if playersMetrics then
                for playerSrc, playerData in pairs(playersMetrics) do
                    if playerData and playerData.playerLicense and (playerData.playerLicense == playerLicense) then
                        local dataMetrics = {
                            matchIndex = matchIndex,
                            totalDamageReceived = playerData.totalDamageReceived,
                            totalKills = playerData.totalKills,
                            totalDamageDone = playerData.totalDamageDone,
                            totalDeaths = playerData.totalDeaths,
                            bodyHitRate = {},
                            totalHS = 0
                        }
                        local roundsMetrics = playerData.roundsMetrics
                        if roundsMetrics then
                            for roundNum, roundData in pairs(roundsMetrics) do
                                if roundData then
                                    local damageEvents = roundData.damageEvents
                                    if damageEvents then
                                        for __, damageData in ipairs(damageEvents) do
                                            if damageData then
                                                if damageData.attackerLicense == playerLicense then
                                                    if damageData.damagedBodyPart then
                                                        if not dataMetrics.bodyHitRate[damageData.damagedBodyPart] then
                                                            dataMetrics.bodyHitRate[damageData.damagedBodyPart] = 1
                                                        else
                                                            dataMetrics.bodyHitRate[damageData.damagedBodyPart] =
                                                            dataMetrics.bodyHitRate[damageData.damagedBodyPart] + 1
                                                        end
                                                    end
                                                    if damageData.willKill then
                                                        dataMetrics.totalHS = dataMetrics.totalHS + 1
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        return dataMetrics
                    end
                end
            end
        end
    end
end

Utils.getPlayerMetricsForAllMatches = function(playerLicense)
    if not playerLicense then
        return
    end
    local data = {
        totalDamageReceived = 0,
        totalKills = 0,
        totalDamageDone = 0,
        totalDeaths = 0,
        totalHS = 0,
        bodyHitRate = {}
    }

    for matchIndex, matchData in pairs(matchesMetrics) do
        local playersMetrics = matchData.playersMetrics
        if playersMetrics then
            for playerSrc, playerData in pairs(playersMetrics) do
                if playerData and playerData.playerLicense and (playerData.playerLicense == playerLicense) then

                    if playerData.totalDamageReceived then
                        data.totalDamageReceived = data.totalDamageReceived + playerData.totalDamageReceived
                    end
                    if playerData.totalKills then
                        data.totalKills = data.totalKills + playerData.totalKills
                    end
                    if playerData.totalDamageDone then
                        data.totalDamageDone = data.totalDamageDone + playerData.totalDamageDone
                    end
                    if playerData.totalDeaths then
                        data.totalDeaths = data.totalDeaths + playerData.totalDeaths
                    end
                    local roundsMetrics = playerData.roundsMetrics
                    if roundsMetrics then
                        for roundNum, roundData in pairs(roundsMetrics) do
                            if roundData then
                                local damageEvents = roundData.damageEvents
                                if damageEvents then
                                    for __, damageData in ipairs(damageEvents) do
                                        if damageData then
                                            if damageData.attackerLicense == playerLicense then
                                                if damageData.damagedBodyPart then
                                                    if not data.bodyHitRate[damageData.damagedBodyPart] then
                                                        data.bodyHitRate[damageData.damagedBodyPart] = 1
                                                    else
                                                        data.bodyHitRate[damageData.damagedBodyPart] =
                                                            data.bodyHitRate[damageData.damagedBodyPart] + 1
                                                    end
                                                end
                                                if damageData.willKill then
                                                    data.totalHS = data.totalHS + 1
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

            end
        end
    end
    return data
end

--- Processes a damage event between players and updates the scoreboard accordingly.
---@param isWeaponKill boolean if the damage was caused by a shooting event
---@param attackerSrc number Source player ID of the attacker.
---@param victimSrc number Target player ID of the victim.
---@param victimPed number Entity ID of the entity being hit.
---@param hitPosX number X coordinate of the hit position.
---@param hitPosY number Y coordinate of the hit position.
---@param hitPosZ number Z coordinate of the hit position.
---@param weaponHash number Hash of the weapon used in the attack.
---@param weaponName string Name of the weapon used in the attack.
---@param weaponDamage number Damage value of the weapon.
---@param willKill boolean Boolean indicating if the attack will result in the victim's death.
---@param overrideDefaultDamage boolean Boolean indicating if the default damage is overridden.
---@param damagedBodyPartId number ID of the damaged body part.
---@param damagedBodyPart string Name of the damaged body part.
Utils.processDamageEvent = function(isWeaponKill, attackerSrc, victimSrc, victimPed, hitPosX, hitPosY, hitPosZ,
    weaponHash, weaponName, weaponDamage, willKill, overrideDefaultDamage, damagedBodyPartId, damagedBodyPart)
    local timestamp = os.time()
    local hitPlayerCoords = GetEntityCoords(tonumber(victimPed))
    local attackerPed = attackerSrc and GetPlayerPed(attackerSrc)
    local attackerCoords = GetEntityCoords(attackerPed)
    local victimCoords = GetEntityCoords(victimPed)
    local projectilePosition = vector3(hitPosX or 0.0, hitPosY or 0.0, hitPosZ or 0.0)
    local hasArmour = GetPedArmour(tonumber(victimPed)) >= (weaponDamage or 0.0)
    local damageValue = weaponDamage and math.floor(weaponDamage) > 0 and tostring(weaponDamage)
    local statePlayerInMatch_attacker = attackerSrc and Player(attackerSrc).state['PVPStatistics:inMatch']
    local statePlayerInMatch_victim = Player(victimSrc).state['PVPStatistics:inMatch']

    if (attackerSrc and not statePlayerInMatch_victim) or (not statePlayerInMatch_victim) then
        return
    end

    local inMatch_attacker, groupData_attacker, groupMember_attacker = Utils.checkPlayerInMatch(attackerSrc)
    local inMatch_victim, groupData_victim, groupMember_victim = Utils.checkPlayerInMatch(victimSrc)

    if (attackerSrc and not inMatch_attacker) or (not inMatch_victim) then
        return
    end

    if willKill then
        groupMember_victim.isDead = true
    end

    local matchIndex = inMatch_victim.index
    local lobbyIndex = inMatch_victim.lobbyIndex
    local currentRound = inMatch_victim.round

    local groupIndex_attacker = groupData_attacker and groupData_attacker.index
    local groupIndex_victim = groupData_victim.index

    -- VALIDATE TK
    local isTeamDamage = groupIndex_attacker and (groupIndex_attacker == groupIndex_victim)
    local isTeamKill = isTeamDamage and willKill
    local license_attacker = attackerSrc and Config.getPlayerUniqueIdentifier(attackerSrc)
    local license_victim = Config.getPlayerUniqueIdentifier(victimSrc)
    local name_attacker = attackerSrc and GetPlayerName(attackerSrc)
    local name_victim = GetPlayerName(victimSrc)

    if willKill then
        if attackerSrc then
            local instanceGroup_attacker = Utils.getScoreboardGroupInstance(matchIndex, groupData_attacker and
                groupData_attacker.index)
            if instanceGroup_attacker then
                instanceGroup_attacker:incrementKillsRound(1)
            end
        end

        local instanceGroup_victim = Utils.getScoreboardGroupInstance(matchIndex, groupData_victim.index)
        if instanceGroup_victim then
            instanceGroup_victim:incrementDeathsRound(1)
        end
    end

    local damageEventInstance = DamageEvent:new(isWeaponKill, groupIndex_attacker, groupIndex_victim, isTeamDamage,
        isTeamKill, timestamp, weaponHash, weaponName, weaponDamage, hitPlayerCoords, attackerCoords, victimCoords,
        projectilePosition, license_attacker, license_victim, attackerSrc, victimSrc, name_attacker, name_victim,
        willKill, overrideDefaultDamage, hasArmour, damagedBodyPartId, damagedBodyPart)

    if attackerSrc then
        local instance_scoreboard_attacker = Utils.getScoreboardPlayerInstance(matchIndex, groupIndex_attacker,
            attackerSrc)

        if instance_scoreboard_attacker then
            instance_scoreboard_attacker:setRound(currentRound)
            instance_scoreboard_attacker:newDamageEvent(damageEventInstance)
        end
    end

    local instance_scoreboard_victim = Utils.getScoreboardPlayerInstance(matchIndex, groupIndex_victim, victimSrc)
    if instance_scoreboard_victim then
        instance_scoreboard_victim:setRound(currentRound)
        instance_scoreboard_victim:newDamageEvent(damageEventInstance)
    end

    local isRoundOver = Utils.isRoundOver(matchIndex)
    local victim_metrics = instance_scoreboard_victim:getMetrics()

    if isRoundOver then
        if groupData_attacker then
            local scoreboardInstance_attacker = Utils.getScoreboardGroupInstance(matchIndex, groupIndex_attacker)
            if scoreboardInstance_attacker then
                scoreboardInstance_attacker:incrementPoints(1)
                local currentPoints = scoreboardInstance_attacker.points or 0

                local pointsToEndMatch = lobbyIndex and lobbies[lobbyIndex] and lobbies[lobbyIndex].pointsToEndMatch
                if not pointsToEndMatch then
                    return
                end

                inMatch_victim:addRoundWinner(groupData_attacker.index)

                if (currentPoints >= pointsToEndMatch) then
                    Utils.finishMatch(matchIndex, groupData_attacker.index)
                else
                    scoreboardInstance_attacker:setDeathsRound(0)
                    scoreboardInstance_attacker:setKillsRound(0)

                    local scoreboardInstance_victim = Utils.getScoreboardGroupInstance(matchIndex, groupIndex_victim)
                    if scoreboardInstance_victim then
                        scoreboardInstance_victim:setDeathsRound(0)
                        scoreboardInstance_victim:setKillsRound(0)
                    end

                    -- NEW ROUND 
                    inMatch_victim:incrementRound(1)

                    local groups = inMatch_victim.groups
                    for _, group in ipairs(groups) do
                        for _, v in pairs(group.members) do
                            if v and not v.offline then
                                local src = v.src
                                v.isDead = false
                                Player(src).state:set('PVPStatistics:isDead', false, false)
                                TriggerClientEvent('PVPStatistics:isDead', src, false)
                                TriggerClientEvent('PVPStatistics:startRound', src, inMatch_victim.index, lobbyIndex,
                                    group.index, inMatch_victim.round, group:getActiveMembersName())
                            end
                        end
                    end

                    Utils.updateScoreboardPlayers(matchIndex)
                    Utils.updateScoreboardGroups(matchIndex)

                end
            end
        end
    else

        if willKill then
            Player(victimSrc).state:set('PVPStatistics:isDead', true, false)
            TriggerClientEvent('PVPStatistics:isDead', victimSrc, true)
            TriggerClientEvent('PVPStatistics:startAreaSpectating', victimSrc, inMatch_victim.index, lobbyIndex,
                groupData_victim.index)
        end

        Utils.updateScoreboardPlayers(matchIndex)
        Utils.updateScoreboardGroups(matchIndex)
    end

end

local getPanelPlayerMetrics = function(src)
    local cache = Player(src).state['PVPStatistics:playerMetrics']
    if cache then
        return cache
    end

    local metricsData = {
        lastMatch = {},
        allMatchs = {}
    }

    local license = Config.getPlayerUniqueIdentifier(src)

    local lastMatchData = Utils.getLastMatchPlayer(license)
    if lastMatchData then
        metricsData.lastMatch = lastMatchData
    end

    local allMatchesMetrics = Utils.getPlayerMetricsForAllMatches(license)
    if allMatchesMetrics then
        metricsData.allMatchs = allMatchesMetrics
    end
    return metricsData
end

Utils.clearCachePlayerMetrics = function(src)
    if not src or (GetPlayerName(src) == nil) then
        return
    end
    Player(src).state:set('PVPStatistics:playerMetrics', false, false)
end

Utils.togglePlayerMetricsPanel = function(src)
    if not src or (GetPlayerName(src) == nil) then
        return
    end
    local isOpen = Player(src).state['PVPStatistics:OpenPanelPlayerMetrics']
    if isOpen then
        Player(src).state:set('PVPStatistics:OpenPanelPlayerMetrics', false, false)
        TriggerClientEvent('PVPStatistics:togglePanelPlayerMetrics', src, false)
        return
    end
    local metrics = getPanelPlayerMetrics(src)
    TriggerClientEvent('PVPStatistics:togglePanelPlayerMetrics', src, metrics)
    Player(src).state:set('PVPStatistics:OpenPanelPlayerMetrics', true, false)
end



RegisterServerEvent("PVPStatistics:togglePlayerMetricsPanel", function()
    local src = source
    Utils.togglePlayerMetricsPanel(src)
end)