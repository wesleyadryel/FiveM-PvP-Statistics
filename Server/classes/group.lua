---@class Group
---@field index string The index of the group.
---@field members table Table storing the members of the group.
Group = {}
Group.__index = Group

---Group class
---@param index string The index of the group.
---@return Group
function Group:new(index)
    local data = {
        index = index,
        members = {},
        cacheMembersName = nil
    }
    setmetatable(data, Group)
    return data
end

---Method to add a member to the group
---@param member Member The member to be added to the group.
function Group:addMember(member)
    self.cacheMembersName = nil
    table.insert(self.members, member)
end

---Method to remove a member from the group
---@param memberSrc number The member to be removed from the group.
function Group:removeMember(memberSrc)
    if not memberSrc then
        return
    end
    memberSrc = math.floor(memberSrc)
    self.cacheMembersName = nil
    for i, m in ipairs(self.members) do
        if m and m.src == memberSrc then
            table.remove(self.members, i)
            break
        end
    end
end

---Method to check offline players
function Group:checkOfflinePlayers()
    for memberIndex, memberData in pairs(self.members) do
        if memberData and memberData.src and GetPlayerName(memberData.src) == nil then
            self.cacheMembersName = nil
            memberData.offline = true
        end
    end
end

---Method to count the number of members in the group
---@return number The number of members in the group.
function Group:getActiveMembersName()
    if self.cacheMembersName then
        return self.cacheMembersName
    end
    local membersName = {}
    for _, memberData in pairs(self.members) do 
        if memberData and not memberData.offline then
            table.insert(membersName, memberData.name)
        end
    end
    self.cacheMembersName = membersName
    return membersName
end


---Method to count the number of members in the group
---@return number The number of members in the group.
function Group:countMembers()
    local count = 0
    for _, memberData in pairs(self.members) do
        if memberData and not memberData.offline then
            count = count + 1
        end
    end
    return count
end

---Method to get global data about the group
---@return table A table containing info about the group.
function Group:getGlobalData()
    local data = {
        numMembers = self:countMembers() -- Calls countMembers to get the number of members.
    }
    return data
end

---Method to check if a player is in the group
---@param playerSrc number The ID of source of the player to check.
---@return boolean True if the player is in the group, false otherwise.
---@return table member data 
function Group:hasPlayer(playerSrc)
    playerSrc = math.floor(playerSrc)
    for _, member in ipairs(self.members) do
        if member.src == playerSrc then
            return true, member
        end
    end
    return false
end 



---Method to count the number of members in the group that are currently alive.
---@return number The number of members who are online and not marked as dead.
function Group:countAliveMembers()
    local count = 0
    for _, memberData in pairs(self.members) do
        if memberData and not memberData.offline and not memberData.isDead then
            count = count + 1
        end
    end 
    return count
end
