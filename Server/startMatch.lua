
Utils.startMatch = function()

    local lobbyIndex = 'lobby1'
    if type(GROUPS_LOBBIES) ~= 'table' then
        return
    end

    if not GROUPS_LOBBIES[lobbyIndex] then
        return
    end

    local match = Match:new(lobbyIndex)
    if not match or not match.index then
        return
    end
    local indexMatch = match.index

    local groups = GROUPS_LOBBIES[lobbyIndex]
    for __, group in pairs(groups) do
        match:addGroup(group)
    end

    local started = match:startMatch()
    if not started then
        return
    end

    if GROUPS_GLOBALSTATE then
        GROUPS_GLOBALSTATE[lobbyIndex] = {}
    end
    GROUPS_LOBBIES[lobbyIndex] = {}
    MATCHES_INSTANCES[indexMatch] = match

    Utils.updateStartTimer()
    Utils.updateGlobalStateGroups()
    Utils.getScoreboardGroupInstance(lobbyIndex)

    SCOREBOARD_GROUPS_INSTANCES[indexMatch] = {}
    SCOREBOARD_PLAYERS_INSTANCES[indexMatch] = {}


    for k, v in pairs(groups) do
        local members = v.members
        if members then
            for _, memberData in pairs(members) do
                if memberData and memberData.src then
                    Player(memberData.src).state:set('PVPStatistics:inMatch', indexMatch, false)
                    Utils.getScoreboardPlayerInstance(indexMatch, v.index, memberData.src)
                end
            end
        end
        Utils.getScoreboardGroupInstance(indexMatch, v.index)
    end

    Utils.updateScoreboardGroups(indexMatch)
    Utils.updateScoreboardPlayers(indexMatch)

    local timestamp = os.time()
    match:setStartIn(timestamp)

end
