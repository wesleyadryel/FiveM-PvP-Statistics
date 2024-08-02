local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}

--- Sends a notification to a specific client.
--- @param src number The source client ID to send the notification to.
--- @param text string The notification message to be sent.
--- @return void
Utils.notify = function(src, text)
    if not src or not text then
        return
    end
    TriggerClientEvent('PVPStatistics:notify', src, text)
end

--- Updates the global state with the group data.
--- This function sets the global state for the key `'PVPStatistics:groups'` using the data stored in `GROUPS_GLOBALSTATE`.
--- @return void
Utils.updateGlobalStateGroups = function()
    GlobalState:set('PVPStatistics:groups', GROUPS_GLOBALSTATE, true)
end
Utils.updateGlobalStateGroups()

--- Retrieves or creates an instance of `ScoreboardGroups` for a given match index.
--- @param matchIndex string 
--- @param groupIndex string 
--- @return ScoreboardGroups 
Utils.getScoreboardGroupInstance = function(matchIndex, groupIndex)
    if not matchIndex or not groupIndex then
        return
    end
    if not SCOREBOARD_GROUPS_INSTANCES[matchIndex] then
        SCOREBOARD_GROUPS_INSTANCES[matchIndex] = {}
    end
    if not SCOREBOARD_GROUPS_INSTANCES[matchIndex][groupIndex] then
        SCOREBOARD_GROUPS_INSTANCES[matchIndex][groupIndex] = ScoreboardGroups:new()
    end
    return SCOREBOARD_GROUPS_INSTANCES[matchIndex][groupIndex]
end

--- Deletes an instance of `ScoreboardGroups` for a given match index and group index.
--- @param matchIndex string 
--- @param groupIndex string 
Utils.deleteScoreboardGroupInstance = function(matchIndex, groupIndex)
    if not matchIndex or not groupIndex then
        return
    end
    if SCOREBOARD_GROUPS_INSTANCES[matchIndex] and SCOREBOARD_GROUPS_INSTANCES[matchIndex][groupIndex] then
        SCOREBOARD_GROUPS_INSTANCES[matchIndex][groupIndex] = nil
        if next(SCOREBOARD_GROUPS_INSTANCES[matchIndex]) == nil then
            SCOREBOARD_GROUPS_INSTANCES[matchIndex] = nil
        end
    end
end

--- Retrieves or creates an instance of `ScoreboardPlayers` for a given match index and player source.
--- @param matchIndex string The index of the match.
--- @param groupIndex string The index of the group.
--- @param playerSource number The source identifier of the player.
--- @return ScoreboardPlayers 
Utils.getScoreboardPlayerInstance = function(matchIndex, groupIndex, playerSource)
    if not matchIndex or not playerSource or not groupIndex then
        return
    end
    if not SCOREBOARD_PLAYERS_INSTANCES[matchIndex] then
        SCOREBOARD_PLAYERS_INSTANCES[matchIndex] = {}
    end
    playerSource = tostring(playerSource)
    if not SCOREBOARD_PLAYERS_INSTANCES[matchIndex][playerSource] then
        local playerLicense = Config.getPlayerUniqueIdentifier(playerSource)
        SCOREBOARD_PLAYERS_INSTANCES[matchIndex][playerSource] = ScoreboardPlayers:new(groupIndex, playerLicense)
    end
    return SCOREBOARD_PLAYERS_INSTANCES[matchIndex][playerSource]
end

--- Generates and updates the global scoreboard metrics data.
--- This function collects metrics from all existing `ScoreboardGroups` instances
--- and updates the global state with this data.
--- @param matchIndex string The index of the match.
--- @return void
Utils.updateScoreboardGroups = function(matchIndex)
    local data = SCOREBOARD_GLOBALSTATE or {}
    local metricsGroups = SCOREBOARD_GROUPS_INSTANCES and SCOREBOARD_GROUPS_INSTANCES[matchIndex]

    if metricsGroups then
        if MATCHES_INSTANCES[matchIndex] then
            data[matchIndex] = {}
            local groupsMatch = MATCHES_INSTANCES[matchIndex].groups
            if groupsMatch then
                for groupIndex, metricsInstance in pairs(metricsGroups) do

                    local getGroup = function()
                        for k, v in pairs(groupsMatch) do
                            if v and v.index == groupIndex then
                                return v
                            end
                        end
                    end
                    local group = getGroup()

                    if group then
                        if metricsInstance then
                            local metricsData = metricsInstance:getMetrics()
                            if metricsData then
                                data[matchIndex][groupIndex] = metricsData
                                local numMembers = group:countMembers()
                                data[matchIndex][groupIndex].numMembers = numMembers
                            end
                        end
                    end
                end
            end
        end
    end
    for _matchIndex_, v in pairs(data) do
        if not MATCHES_INSTANCES[_matchIndex_] then
            data[_matchIndex_] = nil
        end
    end
    SCOREBOARD_GLOBALSTATE = data
    GlobalState:set('PVPStatistics:Scoreboard', SCOREBOARD_GLOBALSTATE, true)
end

---Updates the global scoreboard panel state with player metrics for the given match index.
---This function collects and updates player metrics for the specified match, including group and player names.
---It updates the global state and cleans up data for matches that no longer exist.
---@param matchIndex string The index of the match to update player metrics for.
---@return nil
Utils.updateScoreboardPlayers = function(matchIndex)
    local data = {}
    local matchData = SCOREBOARD_PLAYERS_INSTANCES and SCOREBOARD_PLAYERS_INSTANCES[matchIndex]
    if MATCHES_INSTANCES[matchIndex] then
        local matchInstance = MATCHES_INSTANCES[matchIndex]
        for playerSource, playerMetrics in pairs(matchData) do
            data[playerSource] = playerMetrics:getMetricsPanel()
            data[playerSource].group = playerMetrics.groupPlayer
            local groupInstance = matchInstance and matchInstance:getGroup(playerMetrics.groupPlayer)
            if groupInstance then
                local hasPlayer, memberInstance = groupInstance:hasPlayer(playerSource)
                if hasPlayer and memberInstance then
                    data[playerSource].name = memberInstance.name
                end
            end
        end
        for playerSource, playerMetrics in pairs(matchData) do
            TriggerClientEvent('PVPStatistics:updateScoreboardPanel', playerSource, matchInstance.lobbyIndex,  data)
        end
    end
end

--- Checks if a player is in any match.
---@param src number Player ID.
---@return boolean|table If the player is found, returns the matchInstance. Otherwise, returns false.
---@return boolean|table If the player is found, returns the group data
---@return boolean|table If the player is found, returns the member data
Utils.checkPlayerInMatch = function(src)
    if not MATCHES_INSTANCES or not src then
        return false
    end
    src = tonumber(src)
    for matchIndex, matchInstance in pairs(MATCHES_INSTANCES) do
        if matchInstance then
            local groups = matchInstance.groups
            if groups then
                for groupIndex, groupData in pairs(groups) do
                    local hasPlayer, memberInstance = groupData:hasPlayer(src)
                    if hasPlayer and memberInstance then
                        return matchInstance, groupData, memberInstance
                    end
                end
            end
        end
    end
    return false
end

---Marks a player as offline in all match instances.
---This function iterates through all match instances and sets the specified player to offline status.
---@param src number The source ID of the player to mark as offline.
---@return boolean Returns false (always), indicating no specific outcome of the operation.
Utils.setPlayerOffline = function(src)
    if not MATCHES_INSTANCES then
        return false
    end
    src = tonumber(src)
    for matchIndex, matchInstance in pairs(MATCHES_INSTANCES) do
        if matchInstance then
            local groups = matchInstance.groups
            if groups then
                for groupIndex, groupData in pairs(groups) do
                    local hasPlayer, memberInstance = groupData:hasPlayer(src)
                    if hasPlayer and memberInstance then
                        groupData.cacheMembersName = nil
                        memberInstance.offline = true
                    end
                end
            end
        end
    end
    return false
end

---Checks if the round is over for a given match index.
---This function determines if the round has ended by checking the number of active groups and players.
---A round is considered over if less than two groups have active players.
---@param matchIndex string The index of the match to check.
---@return boolean Returns true if the round is over, false otherwise.
Utils.isRoundOver = function(matchIndex)
    if not MATCHES_INSTANCES then
        return false
    end
    matchIndex = tostring(matchIndex)
    local matchData = MATCHES_INSTANCES[matchIndex]
    if not matchData then
        return
    end
    local groups = matchData.groups
    local numActiveGroups = 0
    if groups then
        for groupIndex, groupData in pairs(groups) do
            local numActivePlayers = groupData:countAliveMembers()
            if numActivePlayers >= 1 then
                numActiveGroups = numActiveGroups + 1
            end
        end
    end
    if numActiveGroups < 2 then
        return true
    end
    return false
end

