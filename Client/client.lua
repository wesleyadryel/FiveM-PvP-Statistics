IS_PLAYER_DEAD = false

---Handles the player's death state.
---@param state boolean The state indicating if the player is dead.
RegisterNetEvent('PVPStatistics:isDead', function(state)
    IS_PLAYER_DEAD = state
    if state then
        SetEntityHealth(PlayerPedId(), 0)
    end
end)

---Handles the changes in the scoreboard state bag.
---@param bagName string The name of the state bag.
---@param key string The key of the changed value.
---@param value any The new value of the key.
AddStateBagChangeHandler("PVPStatistics:Scoreboard", nil, function(bagName, key, value)
    if not PLAYER_IN_MATCH then
        return
    end
    Utils.updateScoreboard(PLAYER_IN_MATCH.matchIndex, PLAYER_IN_MATCH.lobby, value)
end)

local scoreboardInstance

---Closes the panel displaying player metrics.
local closePanelMetrics = function()
    AnimpostfxStop("MenuMGSelectionIn")
    if scoreboardInstance then
        scoreboardInstance:stop()
    end
    scoreboardInstance = nil
end

---Shows the panel displaying player metrics.
---@param playerMetrics table The metrics of the player to be displayed.
local showPanelMetrics = function(playerMetrics)
    closePanelMetrics()
    AnimpostfxPlay("MenuMGSelectionIn", 0, true)
    scoreboardInstance = PlayerStatistics:new()
    scoreboardInstance:setPlayerMetrics(playerMetrics)
    scoreboardInstance:build()
end

---Toggles the panel displaying player metrics.
---@param playerMetrics table The metrics of the player to be displayed or nil to close the panel.
RegisterNetEvent('PVPStatistics:togglePanelPlayerMetrics', function(playerMetrics)
    if type(playerMetrics) ~= 'table' then
        closePanelMetrics()
        return
    end
    showPanelMetrics(playerMetrics)
end)
