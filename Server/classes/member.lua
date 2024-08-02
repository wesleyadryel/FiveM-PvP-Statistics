---@class Member
---@field id number The ID of the member.
---@field name string The name of the member.
---@field src number The source or identifier for the member.
---@field bucket any The bucket associated with the member.
---@field offline boolean Whether the member is offline.
---@field isDead boolean Whether the member is dead.

Member = {}
Member.__index = Member

---Constructor for the Member class
---@param src number The source or identifier for the member.
---@param name string The name of the member.
---@param bucket any The bucket associated with the member.
---@return Member The newly created Member instance.
function Member:new(src, name, bucket)
    local data = {
        src = src,       ---@type number
        name = name,     ---@type string
        bucket = bucket and tonumber(bucket), ---@type any
        offline = false, ---@type boolean
        isDead = false   ---@type boolean
    }
    setmetatable(data, Member)
    return data
end
