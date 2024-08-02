--- @class ScoreboardGroups
--- @field points number The number of points
--- @field deathsRound number The number of deaths in the current round
--- @field killsRound number The number of kills in the current round


ScoreboardGroups = {}
ScoreboardGroups.__index = ScoreboardGroups

--- Creates a new instance of ScoreboardGroups. 
--- @return ScoreboardGroups
function ScoreboardGroups:new()
    local instance = setmetatable({}, ScoreboardGroups)
    instance.points = 0
    instance.deathsRound = 0
    instance.killsRound = 0
    return instance
end

--- Sets the points.
--- @param points number The number of points.
function ScoreboardGroups:setPoints(points)
    self.points = points
end

--- Sets the deaths in the current round.
--- @param deathsRound number The number of deaths in the current round.
function ScoreboardGroups:setDeathsRound(deathsRound)
    self.deathsRound = deathsRound
end

--- Sets the kills in the current round.
--- @param killsRound number The number of kills in the current round.
function ScoreboardGroups:setKillsRound(killsRound)
    self.killsRound = killsRound
end


--- Gets the points.
--- @return number The number of points.
function ScoreboardGroups:getPoints()
    return self.points
end

--- Gets the deaths in the current round.
--- @return number The number of deaths in the current round.
function ScoreboardGroups:getDeathsRound()
    return self.deathsRound
end

--- Gets the kills in the current round.
--- @return number The number of kills in the current round.
function ScoreboardGroups:getKillsRound()
    return self.killsRound
end


--- Gets the total number of deaths.
--- @return number The total number of deaths.
function ScoreboardGroups:getTotalDeaths()
    return self.totalDeaths
end

--- Increments the points by a given amount.
--- @param amount number The amount to increment.
function ScoreboardGroups:incrementPoints(amount)
    self.points = self.points + amount
end

--- Increments the deaths in the current round by a given amount.
--- @param amount number The amount to increment.
function ScoreboardGroups:incrementDeathsRound(amount)
    self.deathsRound = self.deathsRound + amount
end

--- Increments the kills in the current round by a given amount.
--- @param amount number The amount to increment.
function ScoreboardGroups:incrementKillsRound(amount)
    self.killsRound = self.killsRound + amount
end


--- Gets the current metrics data.
--- @return table A table containing the metrics data.
function ScoreboardGroups:getMetrics()
    return {
        points = self.points,
        deathsRound = self.deathsRound,
        killsRound = self.killsRound,
    }
end
