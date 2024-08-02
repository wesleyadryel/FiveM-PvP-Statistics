local lang = type(Config.lang) == 'table' and Config.lang or {}

local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}
GROUPS_LOBBIES = {}
GROUPS_GLOBALSTATE = {}
SCOREBOARD_GLOBALSTATE = {}
SCOREBOARD_GROUPS_INSTANCES = {}
USE_BUCKET_LIST = {}
MATCHES_INSTANCES = {}
SCOREBOARD_PLAYERS_INSTANCES = {}

local validateGroup = function(lobbyIndex, groupIndex)
    if not groupIndex then
        return
    end
    if Config.lobbies and Config.lobbies[lobbyIndex] and Config.lobbies[lobbyIndex].groups and
        Config.lobbies[lobbyIndex].groups[groupIndex] then
        return true, Config.lobbies[lobbyIndex].groups[groupIndex]
    end
    return false
end

local checkPlayerInGroup = function(src)
    src = tonumber(src)
    for lobbyIndex, lobbyGroup in pairs(GROUPS_LOBBIES) do
        for groupIndex, group in pairs(lobbyGroup) do
            if group:hasPlayer(src) then
                return groupIndex
            end
        end
    end
    return false
end

RegisterServerEvent("PVPStatistics:enterGroup", function(lobbyIndex, groupIndex)
    local src = source
    if not src or not lobbyIndex or not groupIndex then
        return
    end

    local isValidGroup, groupStartingConfig = validateGroup(lobbyIndex, groupIndex)
    if not isValidGroup then
        Utils.notify(src, lang.notValidGroup or '~r~This group is not a valid~s~') 
        return
    end

    local inMatch = Utils.checkPlayerInMatch(src)
    if inMatch then
        Utils.notify(src,  lang.alreadyInAmatch or '~y~You are already in a match~s~')
        return
    end

    local updateGroupsGlobalState = function(groupInstance_)
        local groupGlobalData = groupInstance_:getGlobalData()
        if not GROUPS_GLOBALSTATE[lobbyIndex] then
            GROUPS_GLOBALSTATE[lobbyIndex] = {}
        end
        GROUPS_GLOBALSTATE[lobbyIndex][groupIndex] = groupGlobalData
        Utils.updateGlobalStateGroups()
    end

    local playerInGroup = checkPlayerInGroup(src)
    if playerInGroup then
        if playerInGroup == groupIndex then
            if GROUPS_LOBBIES[lobbyIndex] and GROUPS_LOBBIES[lobbyIndex][groupIndex] then
                GROUPS_LOBBIES[lobbyIndex][groupIndex]:removeMember(src) 
                Utils.notify(src, lang.leaveGroup or '~y~You left the group~s~') 
                updateGroupsGlobalState(GROUPS_LOBBIES[lobbyIndex][groupIndex])
                return
            end
        end 
 
        Utils.notify(src, lang.isAlreadyInAGroup or '~r~You are already in a group~s~')
        return
    end
    if not GROUPS_LOBBIES[lobbyIndex] then
        GROUPS_LOBBIES[lobbyIndex] = {}
    end

    if not GROUPS_LOBBIES[lobbyIndex][groupIndex] then
        GROUPS_LOBBIES[lobbyIndex][groupIndex] = Group:new(groupIndex)
    end
    local groupInstance = GROUPS_LOBBIES[lobbyIndex][groupIndex]

    groupInstance:checkOfflinePlayers()
    local countMembers = groupInstance:countMembers()
    local maxPlayers = type(groupStartingConfig.numberOfTeamMembers) == 'number' and
                           groupStartingConfig.numberOfTeamMembers or 5
    if countMembers >= maxPlayers then 
        Utils.notify(src, lang.crowdedGroup or '~y~This group is full~s~')
        return
    end

    local playerName = GetPlayerName(src)
    if playerName == nil then
        return
    end


    local currentBucket = GetPlayerRoutingBucket(src)
    local member1 = Member:new(src, playerName, currentBucket)
    groupInstance:addMember(member1)

    updateGroupsGlobalState(groupInstance)
    Utils.notify(src, lang.joinedTheGroup or 'You have joined the group~s~\nWait until the match starts')
 
end)

local INIT_MATCH_GLOBAL_STATE
Utils.updateStartTimer = function()
    local cooldowns = {}
    for lobbyIndex, lobbyData in pairs(lobbies) do
        if lobbyData then
            local cooldownConfig = lobbyData.cooldownInitMatch
            local cooldownInitMatch = cooldownConfig + 1000
            cooldowns[lobbyIndex] = GetGameTimer() + cooldownInitMatch
        end
    end
    INIT_MATCH_GLOBAL_STATE = cooldowns
    GlobalState:set('PVPStatistics:cooldownInitMatch', INIT_MATCH_GLOBAL_STATE, true)
end

