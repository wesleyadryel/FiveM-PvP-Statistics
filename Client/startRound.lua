local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}
PLAYER_IN_MATCH = nil


--- Displays a panel with a title, subtitle, and player information using a Scaleform movie.
---@param title string The title to set for the panel.
---@param subtitle string The subtitle to set for the panel.
---@param players table|nil A table of player information. Each entry should be a table with `state` and `name` fields.
---@return number|nil Returns the handle of the Scaleform movie used to display the panel, or nil if the movie could not be loaded.
local function showPanel(title, subtitle, players)
    local scaleform = Scaleform.Request('MP_RESULTS_PANEL')

    Scaleform.CallFunction(scaleform, false, "SET_TITLE", title)
    Scaleform.CallFunction(scaleform, false, "SET_SUBTITLE", subtitle)
    Scaleform.CallFunction(scaleform, false, "CLEAR_ALL_SLOTS")

    local slot = 1
    Scaleform.CallFunction(scaleform, false, "SET_SLOT", 0, 3, '')
    slot = slot + 1

    if players then
        for i, k in ipairs(players) do
            Scaleform.CallFunction(scaleform, false, "SET_SLOT", slot, players[i].state, players[i].name)
            slot = slot + 1
        end
    end

    return scaleform
end


---Event handler for starting a round.
---@param matchIndex string The index of the match.
---@param lobbyIndex string The index of the lobby.
---@param groupIndex string The index of the group.
---@param round number The current round number.
---@param groupMembers table The members of the group.
RegisterNetEvent('PVPStatistics:startRound', function(matchIndex, lobbyIndex, groupIndex,round, groupMembers)
    if not matchIndex or not lobbyIndex or not groupIndex or not round then
        return
    end

    PLAYER_IN_MATCH = {
        lobby = lobbyIndex,
        group = groupIndex,
        matchIndex = matchIndex
    }

    local showScaleform = true
    local scale = 0
    local _waitTime = 6000

    AnimpostfxPlay("MenuMGSelectionIn", 0, true)
    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)

    local members = {}
    if type(groupMembers) == 'table' then
        for __, v in ipairs(groupMembers) do
            table.insert(members, {
                name = v,
                state = 0
            })
        end
    end

    local configPanel = type(Config.initMatchInfos) == 'table' and Config.initMatchInfos or {}
    local title = string.format((configPanel.title or ''), tostring(round or ''))

    scale = showPanel(title, configPanel.subtitle or '', members)

    Citizen.CreateThread(function()
        while showScaleform do
            DisableAllControlActions(0)
            DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255)
            Citizen.Wait(1)
        end
    end)

    Citizen.Wait(_waitTime)
    showScaleform = false
    AnimpostfxStop("MenuMGSelectionIn")

    if not lobbies[lobbyIndex] or not lobbies[lobbyIndex].groups or
        not lobbies[lobbyIndex].groups[groupIndex] then
            PLAYER_IN_MATCH = nil
        return
    end

    local lobbyConfig = lobbies[lobbyIndex]
    local groupConfig = lobbies[lobbyIndex].groups[groupIndex]

    local pPed = PlayerPedId()

    local coordinateSpawnMatch = groupConfig.coordinateSpawnMatch
    if not coordinateSpawnMatch then
        PLAYER_IN_MATCH = nil
        return
    end

    if Utils.isSpectate() then
        Citizen.Wait(300)
        Utils.stopSpectate()
        Citizen.Wait(300)
    end

    local health = GetEntityHealth(pPed)
    local isDead_ = Config.checkPlayerDead(health)

    if isDead_ then
        Utils.revivePlayer()
        SetTimeout(800, function()
            SetEntityCoordsNoOffset(pPed, coordinateSpawnMatch)
        end)
    else
        SetEntityCoordsNoOffset(pPed, coordinateSpawnMatch)
    end

    local weapons = type(lobbyConfig.weapons) == 'table' and lobbyConfig.weapons or {}
    for __, weapon in ipairs(weapons) do
        local hash = GetHashKey(weapon)
        GiveWeaponToPed(pPed, hash, 250, false, false)
        SetPedInfiniteAmmo(pPed, true, hash)
    end

    SetPedInfiniteAmmoClip(PlayerPedId(), true)

    local circleZone = lobbyConfig.circleZone
    if type(circleZone) == 'table' and circleZone.coordinate and circleZone.radius then
        local radius = circleZone.radius + 0.0
        activateZone({
            x = circleZone.coordinate.x,
            y = circleZone.coordinate.y,
            z = circleZone.coordinate.z,
            radius = radius,
            circleColor = {circleZone.zoneColor.r, circleZone.zoneColor.g, circleZone.zoneColor.b},
            alpha = circleZone.alpha,
            useZ = circleZone.useZ
        })
    end

    Utils.updateScoreboard(matchIndex, lobbyIndex)

    
end)


