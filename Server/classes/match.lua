---@class Match
---@field groups table Table storing the groups in the match.
---@field round number Current round of the match.
---@field startIn number timestamp referring to the start of the match
---@field finishIn number timestamp referring to the end of the match
---@field roundWinners table Table storing the winners of each round.
---@field winningGroup string|nil the winning group of the match 
Match = {}
Match.__index = Match

---Match class
---@param lobbyIndex string Index Lobby
---@return Match
function Match:new(lobbyIndex)
    local data = {
        lobbyIndex = lobbyIndex,
        groups = {},
        round = 1,
        roundWinners = {},
        startIn = nil,
        finishIn = nil,
        winningGroup = nil
    }
    setmetatable(data, Match)

    -- if Config.DevMode then
    --     data.index = 'testMatch'
    --     return data
    -- end

    if type(Config.createMatchIndex) == 'function' then
        local tkn = Config.createMatchIndex()
        if tkn then
            data.index = tkn
            return data
        end
    end

    local tkn = tostring(Utils.createToken(4) .. '_' .. os.time())
    data.index = tkn
    return data
end

---Sets the start timestamp for the match.
---@param timestamp number The start timestamp.
function Match:setStartIn(timestamp)
    if not timestamp then
        return
    end
    self.startIn = timestamp
end

---Sets the finish timestamp for the match.
---@param timestamp number The finish timestamp.
function Match:setFinishIn(timestamp)
    if not timestamp then
        return
    end
    self.finishIn = timestamp
end

--- Sets the winning group for the match.
--- @param groupIndex string The index of the winning group.
function Match:setWinningGroup(groupIndex)
    if not groupIndex then
        return
    end
    self.winningGroup = groupIndex
end

---Adds a group to the match.
---@param group Group The group to be added to the match.
function Match:addGroup(group)
    table.insert(self.groups, group)
end

---Method to remove a group from the match
---Removes the group with the specified index from the match.
---@param groupIndex string The index of the group to be removed.
function Match:removeGroup(groupIndex)
    for i, group in ipairs(self.groups) do
        if group.index == groupIndex then
            table.remove(self.groups, i)
            return
        end
    end
end

---Method to retrieve a group from the match
---Returns the group with the specified index from the match.
---@param groupIndex string The index of the group to be retrieved.
---@return table|nil The group table if found, otherwise nil.
function Match:getGroup(groupIndex)
    for i, group in ipairs(self.groups) do
        if group.index == groupIndex then
            return group
        end
    end
end

---Method to start the match
---@return boolean True if the match was started successfully, false otherwise.
function Match:startMatch()

    local lobbyIndex = self.lobbyIndex
    if not lobbyIndex then
        return false
    end

    local notifyPlayersRemoveGroup = {}

    local countGroups = 0
    for _, group in ipairs(self.groups) do
        local countMembers = group:countMembers()
        if countMembers < 1 then
            for memberIndex, memberData in pairs(group.members) do
                table.insert(notifyPlayersRemoveGroup, memberData.src)
            end
            self:removeGroup(group.index)
        else
            countGroups = countGroups + 1
        end
    end

    if countGroups <= 0 or (not Config.DevMode and countGroups < 2) then
        return false
    end

    for _, src in pairs(notifyPlayersRemoveGroup) do
        Utils.notify(src,
            'Seu grupo foi ~r~desclassificado~s~ da partida pois não atingiu o ~y~número mínimo de membros~s~')
    end

    local getBucketMatch
    getBucketMatch = function()
        local random = Utils.generateRandomNumber(0, 500)
        local randomStr = tostring(random)
        if USE_BUCKET_LIST[randomStr] then
            return getBucketMatch()
        end
        return random
    end

    local bucketMatch = getBucketMatch()
    self.bucket = bucketMatch

    if Config.disableBucketPopulation then
        SetRoutingBucketPopulationEnabled(bucketMatch, true)
    end
    if Config.setBucketLockdownMode then
        SetRoutingBucketEntityLockdownMode(bucketMatch, 'strict')
    end

    for _, group in ipairs(self.groups) do
        for _, v in pairs(group.members) do
            local src = v.src
            SetPlayerRoutingBucket(src, bucketMatch)
            TriggerClientEvent('PVPStatistics:startRound', src, self.index, lobbyIndex, group.index, self.round,
                group:getActiveMembersName())
        end
    end

    return true
end

--- Getter for the round
---@return number Current round of the match.
function Match:getRound()
    return self.round
end

--- Setter for the round
---@param newRound number The new round value to set.
function Match:setRound(newRound)
    if type(newRound) == "number" and newRound >= 0 then
        self.round = newRound
    end
end

---Method to increment the round value by a given amount
---@param amount number The amount to increment 
function Match:incrementRound(amount)
    self.round = self.round + (amount or 1)
end

--- Getter for round winners
---@return table A table where keys are round indices and values are the indices of the winning groups.
function Match:getRoundWinners()
    return self.roundWinners
end

--- Setter for round winners
---@param newRoundWinners table A table of round winners to set.
function Match:setRoundWinners(newRoundWinners)
    if type(newRoundWinners) == "table" then
        self.roundWinners = newRoundWinners
    end
end

--- Add a winner for the current round
---@param groupIndex string The index of the group that won the round.
function Match:addRoundWinner(groupIndex)
    self.roundWinners[tostring(self.round)] = groupIndex
end
