
local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}
local spectator_intance

Utils.notify = function(text)
    if not text then
        return
    end
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, false)
end
RegisterNetEvent('PVPStatistics:notify', Utils.notify)

-- prevents the screen from becoming blurry if the script is restarted when the player has a blurred background interface open
AnimpostfxStop("MenuMGSelectionIn")

Utils.playerCache = {}
local getCacheData = function()
    Utils.playerCache.playerId = PlayerId()
    Utils.playerCache.PlayerPedId = PlayerPedId()
    Utils.playerCache.playerCds = GetEntityCoords(Utils.playerCache.PlayerPedId)
    Utils.playerCache.GetGameplayCamFov = GetGameplayCamFov()
end
getCacheData()

Citizen.CreateThread(function()
    getCacheData()
    while true do
        getCacheData()
        Citizen.Wait(600)
    end
end)

--- Retrieves the headshot texture dictionary string for a specified ped.
---
--- @param ped number The ped entity.
--- @param autoUnRegister boolean Optional. If true, automatically unregisters the headshot after retrieving it.
---
--- @return string The texture dictionary string for the ped's headshot.
Utils.getPlayerHeadshot = function(ped, autoUnRegister)
    if not DoesEntityExist(ped) or not IsEntityAPed(ped) then
        return
    end

    local prevState = Entity(ped).state
    if IsPedAPlayer(ped) then
        prevState = LocalPlayer.state
    end
    local lastHeadShot = prevState and prevState.headshot

    if lastHeadShot then
        UnregisterPedheadshot(lastHeadShot)
        if IsPedheadshotValid(lastHeadShot) then
            local c = 0
            while (IsPedheadshotValid(lastHeadShot) or IsPedheadshotReady(lastHeadShot)) and c < 80 do
                Citizen.Wait(2)
                c = c + 1
            end
        end
    end

    local create = function(mode)
        if mode and (mode == 'transparent') then
            return RegisterPedheadshotTransparent(ped)
        end
        return RegisterPedheadshot(ped)
    end

    local Handle = create('transparent')
    if not Handle or Handle == 0 then
        Handle = create()
    end

    if Handle and Handle ~= 0 then
        local c = 0
        while (not IsPedheadshotReady(Handle) or not IsPedheadshotValid(Handle)) and c < 80 do
            c = c + 1
            Wait(2)
        end
    end

    local MugShotTxd = 'CHAR_DEFAULT'
    if (IsPedheadshotReady(Handle) and IsPedheadshotValid(Handle)) then
        MugShotTxd = GetPedheadshotTxdString(Handle)
    end

    if autoUnRegister then
        UnregisterPedheadshot(Handle)
    else
        if prevState and Handle and (Handle ~= 0) then
            prevState:set('headshot', Handle, false)
        end
    end
    return MugShotTxd
end

local scoreboardIntance = nil

--- Updates the scoreboard with the provided match and lobby data.
---
--- @param matchIndex string The index of the match.
--- @param lobbyIndex string The index of the lobby.
--- @param stateData table Optional. The state data to use for updating the scoreboard.
---
--- @return nil
Utils.updateScoreboard = function(matchIndex, lobbyIndex, stateData)
    if not matchIndex or not lobbyIndex then
        return
    end
    if not scoreboardIntance then
        scoreboardIntance = Scoreboard:new()
    end
    scoreboardIntance:clear()
    local scoreboardData = type(stateData) == 'table' and stateData or GlobalState['PVPStatistics:Scoreboard']
    if type(scoreboardData) ~= 'table' then
        return
    end
    if type(scoreboardData[matchIndex]) ~= 'table' then
        return
    end
    local scoreboardMatch = scoreboardData[matchIndex]
    if not lobbies[lobbyIndex] or not lobbies[lobbyIndex].groups then
        return
    end
    for groupIndex, metrics in pairs(scoreboardMatch) do
        if lobbies[lobbyIndex].groups[groupIndex] then
            local scoreColor = lobbies[lobbyIndex].groups[groupIndex].scoreColor or {
                r = 0,
                g = 0,
                b = 0,
                a = 0
            }

            local killsRound = metrics.killsRound
            local deathsRound = metrics.deathsRound
            local points = metrics.points or 0
            local maxMembers = metrics.numMembers or 0
            local deathsCompare = maxMembers - killsRound
            if deathsCompare < 0 then
                deathsCompare = 0
            end
            local formatRoundMembers = string.format('%s/%s', tostring(deathsCompare), tostring(maxMembers))
            scoreboardIntance:AddTeam(formatRoundMembers, points, scoreColor)
        end
    end
    scoreboardIntance:build()
end


Utils.destroyScoreboard = function()
    if scoreboardIntance then
        scoreboardIntance:clear()
        scoreboardIntance:stop()
        scoreboardIntance = nil
    end
end

--- Revive the player
---
--- @return nil
Utils.revivePlayer = function()
    local ped = PlayerPedId()
    SetPedCanRagdoll(ped, false)
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
    ClearPedBloodDamage(ped)
    SetEntityHealth(ped, 400)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, true, false)
end

--- Revive the player
---
--- @return nil
Utils.revivePlayer = function()
    local ped = PlayerPedId()
    SetPedCanRagdoll(ped, false)
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
    ClearPedBloodDamage(ped)
    SetEntityHealth(ped, 400)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, true, false)
end

---Starts spectating mode for the player if they are dead and in a match.
---@return void
Utils.startAreaSpectating = function()
    if not PLAYER_IN_MATCH or not IS_PLAYER_DEAD then
        return
    end

    local groupPlayer, lobbyIndex, matchIndex = PLAYER_IN_MATCH.group, PLAYER_IN_MATCH.lobby, PLAYER_IN_MATCH.matchIndex
    if not lobbyIndex or not groupPlayer then
        return
    end
    local lobbyConfig = lobbies[lobbyIndex] and lobbies[lobbyIndex]
    if not lobbyConfig then
        return
    end

    local spectatorLocations = lobbyConfig.spectatorLocations
    local configGroup = lobbyConfig.groups and lobbyConfig.groups[groupPlayer]
    if not configGroup or not configGroup.coordinateStartBlip then
        return
    end
    local coordinateStartBlip = configGroup.coordinateStartBlip

    if not spectatorLocations then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        SetEntityCoords(ped, coords.x, coords.y, coords.z + 40.0)
        FreezeEntityPosition(ped, true)
        SetEntityVisible(ped, false, false)
        SetEntityCollision(ped, false, false)
        return
    end

    if spectator_intance then
        spectator_intance:destroy()
        spectator_intance = nil
    end

    spectator_intance = Spectate:new(function()
        if not PLAYER_IN_MATCH or not IS_PLAYER_DEAD then
            return true
        end
    end)

    spectator_intance:setLocations(spectatorLocations)
    spectator_intance:blockControls()
    spectator_intance:changeCam()
    spectator_intance:setLastPosition(coordinateStartBlip)

    spectator_intance:createInstructionalThread(function()
        spectator_intance:changeCam()
    end)

end

---Checks if the player is currently in spectator mode and has changed the camera.
---@return boolean|nil Returns true if the player is in spectator mode 
Utils.isSpectate = function()
    if spectator_intance then
        return spectator_intance.changedCam
    end
end

---Stops the spectator mode and cleans up the spectator instance.
---@return void
Utils.stopSpectate = function()
    if spectator_intance then
        spectator_intance:destroy()
        spectator_intance = nil
    end
end

RegisterNetEvent('PVPStatistics:finishMatch', function()
    Utils.stopSpectate()
end)
 
RegisterNetEvent('PVPStatistics:startAreaSpectating', function()
    Utils.startAreaSpectating()
end)

