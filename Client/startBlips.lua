local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}

local lobbyControls = type(Config.lobbyControls) == 'table' and Config.lobbyControls or {}
local numberOfTeamMembers = Config.numberOfTeamMembers or 5

local globalStateCooldown = GlobalState['PVPStatistics:cooldownInitMatch']
local INIT_MATCH_GLOBAL_STATE = type(globalStateCooldown) == 'table' and globalStateCooldown or {}

local GROUPS_GLOBALSTATE = {}
local NEARBYBLIPS = {}
local active_scaleformThread = false

AddStateBagChangeHandler("PVPStatistics:groups", nil, function(bagName, key, value)
    if type(value) == 'table' then
        GROUPS_GLOBALSTATE = value
    end
end)

AddStateBagChangeHandler("PVPStatistics:cooldownInitMatch", nil, function(bagName, key, value)
    if type(value) == 'table' then
        INIT_MATCH_GLOBAL_STATE = value
    end
end)

---Creates an instructional thread to display a scaleform and handle lobby controls.
---If no instructional thread is active, it creates one that draws the instructional
---scaleform on the screen and listens for control inputs to execute a callback.
---@param cb function The callback function to execute when a control input is detected.
local function createInstructionalThread(cb)
    if not active_scaleformThread then
        active_scaleformThread = true
        CreateThread(function()
            local fivemScaleform = Utils.instructionalScaleform(lobbyControls)
            while not PLAYER_IN_MATCH and active_scaleformThread do
                DrawScaleformMovieFullscreen(fivemScaleform, 255, 255, 255, 255, 0)
                Wait(0)
            end
            active_scaleformThread = false
            SetScaleformMovieAsNoLongerNeeded()
        end)
        CreateThread(function()
            while active_scaleformThread do
                for k, v in pairs(lobbyControls) do
                    if v.key and v.action and IsControlJustPressed(0, v.key) then
                        cb(v.action)
                    end
                end
                Wait(5)
            end
            active_scaleformThread = false
        end)
    end
end

local waitingTimeMatch = {}
Citizen.CreateThread(function()
    while true do
        if INIT_MATCH_GLOBAL_STATE then
            for lobbyIndex, matchCooldown in pairs(INIT_MATCH_GLOBAL_STATE) do
                local waitingTime = 0

                local netTime = GetNetworkTime()
                local diff = (matchCooldown - netTime)
                if diff < 0 then
                    waitingTime = '0'
                else
                    waitingTime = diff / 1000
                    waitingTime = math.floor(waitingTime)
                end

                waitingTimeMatch[lobbyIndex] = waitingTime
            end
        end
        Citizen.Wait(1000)
    end
end)

--- Returns the intensity of blips based on the game's clock hour.
-- The intensity is calculated to be highest at noon and lowest at midnight.
-- @return number Intensity of the blips multiplied by 200
local getIntensityBlips = function()
    local hour = GetClockHours()
    local intensity = (24 - hour) / 24 * 6
    return intensity * 200
end
local intensity = getIntensityBlips()

---Generates the text for a blip based on its data.
---@param lobbyIndex string The index of the lobby containing the blip.
---@param blipIndex string The index of the blip within the lobby.
---@param blipData table The data of the blip, including its label.
---@return string The formatted text for the blip.
local getBlipText = function(lobbyIndex, blipIndex, blipData)
    local label = blipData.label
    local dataStateBag = GROUPS_GLOBALSTATE and GROUPS_GLOBALSTATE[lobbyIndex] and
                             GROUPS_GLOBALSTATE[lobbyIndex][blipIndex]

    local text = [[
    ~m~[%s]~s~
    %d/%d Players  
    ]]

    return string.format(text, tostring(label), tonumber(dataStateBag and dataStateBag.numMembers or 0),
        tonumber(numberOfTeamMembers))
end

---Finds the closest blip to the player within a specified distance.
---@return table|nil The data of the closest blip if found, otherwise nil.
local getBlip = function()
    local closestProximity = nil
    local playerCoords = GetEntityCoords(PlayerPedId())

    local function updateProximity(lobbyIndex, groupIndex, distance)
        closestProximity = {
            dist = distance,
            data = {
                lobbyIndex = lobbyIndex,
                groupIndex = groupIndex
            }
        }
    end

    for lobbyIndex, lobbyData in pairs(lobbies) do
        if lobbyData.groups then
            for groupIndex, groupData in pairs(lobbyData.groups) do
                local distance = #(groupData.coordinateStartBlip - playerCoords)
                if distance <= 8 then
                    if not closestProximity or distance < closestProximity.dist then
                        updateProximity(lobbyIndex, groupIndex, distance)
                    end
                end
            end
        end
    end

    if closestProximity then
        return closestProximity.data
    end
end

Citizen.CreateThread(function()
    while true do

        local waitTime = 1500
        if not PLAYER_IN_MATCH then
            local cds = Utils.playerCache.playerCds
            local list = {}
            local playerOnBlip = nil

            for lobbyIndex, lobbyData in pairs(lobbies) do
                if lobbyData.groups then
                    for groupIndex, groupData in pairs(lobbyData.groups) do
                        local distance = #(groupData.coordinateStartBlip - cds)
                        if distance <= 30 then
                            waitTime = 600
                            list[groupIndex] = groupData
                            list[groupIndex].blipText = getBlipText(lobbyIndex, groupIndex, groupData)
                            if distance < 5 then
                                playerOnBlip = groupIndex
                            end
                        end
                    end

                    intensity = getIntensityBlips()
                    NEARBYBLIPS = list
                    if playerOnBlip then
                        createInstructionalThread(function(action)
                            local blip = getBlip()
                            if not blip then
                                return
                            end

                            if action == 'enterGroup' then
                                TriggerServerEvent('PVPStatistics:enterGroup', blip.lobbyIndex, blip.groupIndex)
                                Citizen.Wait(1000)
                                return
                            end

                        end)
                    else
                        active_scaleformThread = false
                    end
                end
            end
        end

        Citizen.Wait(waitTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        local waitTime = 1500

        if not PLAYER_IN_MATCH then
            for k, v in pairs(NEARBYBLIPS) do
                waitTime = 4

                DrawLightWithRangeAndShadow(v.coordinateStartBlip.x, v.coordinateStartBlip.y, v.coordinateStartBlip.z,
                    v.blipColor.r, v.blipColor.g, v.blipColor.b, 5.0, intensity, 1.0)

                Utils.DrawText3D(v.coordinateStartBlip.x, v.coordinateStartBlip.y, v.coordinateStartBlip.z, v.blipText,
                    0.3, 7, false)

            end

            local pCoods = Utils.playerCache.playerCds

            for lobbyIndex, lobbyData in pairs(lobbies) do
                local timerLobby = type(lobbyData.timerLobby) == 'table' and lobbyData.timerLobby or {}
                if timerLobby.coordinate then
                    local cds = timerLobby.coordinate
                    local text = timerLobby.text
                    local playerDistance = #(pCoods - cds)
                    if playerDistance < 40 then
                        local scale_ = (1 / playerDistance) * 12
                        local fov = (1 / Utils.playerCache.GetGameplayCamFov) * 50
                        scale_ = scale_ * fov
                        waitTime = 4
                        Utils.DrawText3D(cds.x, cds.y, cds.z + 0.1, text, scale_, 4, false)
                        Utils.DrawText3D(cds.x, cds.y, cds.z,
                            tostring(waitingTimeMatch and waitingTimeMatch[lobbyIndex] or 0), scale_ * 12, 7, false)
                    end
                end
            end
        end

        Citizen.Wait(waitTime)
    end
end)

