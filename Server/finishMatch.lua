local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}

---Finalizes the match with the given index.
-- This function handles cleanup and updates related to a match. It resets player states, removes match instances, 
-- updates match metrics, and handles scoreboard data.
---@param matchIndex string The index of the match to finish.
---@return nil
Utils.finishMatch = function(matchIndex, winningGroup)

    if not matchIndex then
        return
    end

    if not MATCHES_INSTANCES or not MATCHES_INSTANCES[matchIndex] then
        return
    end
    local matchData = MATCHES_INSTANCES[matchIndex]
    local lobbyIndex = matchData.lobbyIndex

    local lobbyConfig = lobbies and lobbies[lobbyIndex]
    local groupsConfig = lobbyConfig.groups or {}

    local groups = matchData.groups
    if groups then
        for _, group in ipairs(groups) do
            for _, v in pairs(group.members) do
                if v and not v.offline then
                    local src = v.src
                    v.isDead = false
                    Player(src).state:set('PVPStatistics:isDead', false, false)
                    TriggerClientEvent('PVPStatistics:isDead', src, false)
                    TriggerClientEvent('PVPStatistics:finishMatch', src)
                    SetPlayerRoutingBucket(src, v.bucket or 0)
                    local cds = groupsConfig[group.index] and groupsConfig[group.index].coordinateStartBlip
                    if cds then
                        local pPed = GetPlayerPed(src)
                        if pPed and DoesEntityExist(pPed) then
                            SetEntityCoords(pPed, cds)
                        end
                    end
                    Utils.clearCachePlayerMetrics(src)
                    Utils.deleteScoreboardGroupInstance(matchIndex, group.index)
                end
            end
        end
    end

    local timestamp = os.time()
    matchData:setFinishIn(timestamp)
    matchData:setWinningGroup(winningGroup)

    local matchMetrics = Utils.getMatchInstanceMetrics(matchIndex)
    if matchMetrics then
        Utils.setMatchMetrics(matchIndex, matchMetrics)
    end

    SCOREBOARD_GROUPS_INSTANCES[matchIndex] = nil
    SCOREBOARD_PLAYERS_INSTANCES[matchIndex] = nil
    SCOREBOARD_PLAYERS_INSTANCES[matchIndex] = nil


    MATCHES_INSTANCES[matchIndex] = nil

    local bucketMatch = matchData.bucket
    if bucketMatch then
        USE_BUCKET_LIST[tostring(bucketMatch)] = nil
    end

    Utils.updateScoreboardPlayers(matchIndex)
    Utils.updateScoreboardGroups(matchIndex)

end


RegisterCommand('finishMatches', function(src)
    for k, v in pairs(MATCHES_INSTANCES) do
        Utils.finishMatch(v.index)
    end
end, true)