local lang = type(Config.lang) == 'table' and Config.lang or {}

local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}
local PANEL_DATA = {}
local SHOW_PANEL = false
local panelInstance

---Loads the players into the panel instance.
local loadPlayers = function()
    if panelInstance then
        panelInstance:ResetPlayers()
        if PANEL_DATA then
            for _, player in ipairs(PANEL_DATA) do
                panelInstance:AddPlayer(player)
            end
        end
    end
end

---Closes the panel.
local closePanel = function()
    AnimpostfxStop("MenuMGSelectionIn")
    SHOW_PANEL = false
    return
end

---Toggles the display of the match panel.
Utils.togglePanelMatch = function()
    if SHOW_PANEL then
        closePanel()
        return
    end

    if not panelInstance then
        panelInstance = DynamicPanel:new( lang.players or 'Players', {}, {}, {
            r = 255,
            g = 255,
            b = 255,
            a = 255 
        })
        panelInstance:AddHeader('name', lang.PlayerName or "Player Name", 0.38)
        panelInstance:AddHeader('totalKills', lang.kills or "Kills", 0.12)
        panelInstance:AddHeader('totalDeaths', lang.deaths or "Deaths", 0.12)
        panelInstance:AddHeader('totalDamageReceived',  lang.damageReceived or "Damage Received", 0.12)
        panelInstance:AddHeader('totalDamageDone', lang.damageDone or "Damage Done", 0.12)
    end
    loadPlayers()

    if not next(panelInstance.players) then
        SHOW_PANEL = false
        return
    end

    SHOW_PANEL = true
    AnimpostfxPlay("MenuMGSelectionIn", 0, true)

    while SHOW_PANEL do
        panelInstance:Show()
        Citizen.Wait(0)
    end
    closePanel()
end

---Loads the state of the match.
---@param lobbyIndex string The index of the lobby.
---@param matchData table The data of the match.
local loadState = function(lobbyIndex, matchData)
    local formatData = {}
    if type(matchData) == 'table' then
        for playerSource, playerData in pairs(matchData) do
            playerData.src = playerSource
            local group = playerData.group
            local groupConfigLobby = lobbies and lobbies[lobbyIndex] and lobbies[lobbyIndex].groups and
                                     lobbies[lobbyIndex].groups[group]
            playerData.backgroundColor = groupConfigLobby and groupConfigLobby.panelPlayersColor
            for k, v in pairs(playerData) do
                if type(v) == 'number' then
                    playerData[k] = tostring(v)
                end
            end
            table.insert(formatData, playerData)
        end
    end

    PANEL_DATA = formatData
    loadPlayers()
end

---Event handler for updating the scoreboard panel.
---@param lobbyIndex string The index of the lobby.
---@param matchData table The data of the match.
RegisterNetEvent('PVPStatistics:updateScoreboardPanel', function(lobbyIndex, matchData)
    loadState(lobbyIndex, matchData)
end)
