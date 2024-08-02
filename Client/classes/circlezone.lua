CircleZone = {}
CircleZone.__index = CircleZone

---@alias vector3 table<string, number> @ {r: number, g: number, b: number}

---Creates a new CircleZone
---@param center vector3 The center coordinates of the circle zone.
---@param radius number The radius of the circle zone.
---@param circleColor table RGB color for the debug marker.
---@param useZ boolean Whether to use the Z coordinate.
---@param alpha number (optional) alpha zone.
---@return CircleZone
function CircleZone:new(center, radius, circleColor, useZ, alpha)
    local self = setmetatable({}, CircleZone)
    self.center = center
    self.radius = radius
    self.circleColor = circleColor or {0, 255, 0}
    self.useZ = useZ or false
    self.diameter = radius * 2
    self.alpha = alpha
    return self
end

---Checks if a player is inside the circle zone
---@param playerPed number The player ped ID.
---@return boolean True if the player is inside the zone, false otherwise.
function CircleZone:isPlayerInZone(playerPed)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - self.center)
    return distance <= self.radius
end

---Draws the circle zone marker
function CircleZone:draw()
    local center = self.center
    local circleColor = self.circleColor
    local r, g, b = circleColor[1], circleColor[2], circleColor[3]
    if self.useZ then
        DrawMarker(28, center.x, center.y, center.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.radius, self.radius,
            self.radius, r, g, b, self.alpha or 48, false, false, 2, nil, nil, false)
    else
        DrawMarker(1, center.x, center.y, -200.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.diameter, self.diameter, 400.0, r,
            g, b, 96, false, false, 2, nil, nil, false)
    end
end

local currentZone = nil

local disableZoneEffects = function(pId, pPed)
    NetworkSetFriendlyFireOption(false)
    DisablePlayerFiring(pId, false) -- allow firing
end

---Configures and activates a circle zone
---@param zoneConfig table A table containing the configuration for the circle zone.
function activateZone(zoneConfig)
    local center = vector3(zoneConfig.x, zoneConfig.y, zoneConfig.z)
    local radius = zoneConfig.radius
    local circleColor = zoneConfig.circleColor or {0, 255, 0}
    local useZ = zoneConfig.useZ or false
    local alpha = zoneConfig.alpha

    if currentZone then
        currentZone.center = center
        currentZone.diameter = radius
        currentZone.circleColor = circleColor
        currentZone.useZ = useZ
        currentZone.alpha = alpha
        return
    end

    currentZone = CircleZone:new(center, radius, circleColor, useZ, alpha)
    local pId = Utils.playerCache.playerId
    local inZone = false

    Citizen.CreateThread(function()
        while currentZone do
            Citizen.Wait(1000)
            local playerPed = Utils.playerCache.PlayerPedId
            if currentZone and currentZone:isPlayerInZone(playerPed) then
                disableZoneEffects()
                inZone = true
                NetworkSetFriendlyFireOption(true)
            else
                if inZone then
                    NetworkSetFriendlyFireOption(true)
                    ClearPlayerWantedLevel(Utils.playerCache.playerId)
                    SetCurrentPedWeapon(Utils.playerCache.PlayerPedId, GetHashKey("WEAPON_UNARMED"), true)
                    inZone = false
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while currentZone do
            Citizen.Wait(0)
            local playerPed = Utils.playerCache.PlayerPedId
            if not inZone then

                DisablePlayerFiring(pId, true)
                SetPlayerCanDoDriveBy(pId, false)
                DisableControlAction(2, 37, true)
                DisableControlAction(0, 106, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 70, true)
                DisableControlAction(0, 92, true)
                DisableControlAction(0, 114, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 331, true)
                DisableControlAction(0, 68, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)

            end
            if currentZone then
                -- Draw the circle zone marker
                currentZone:draw()
            end
        end
    end)
end

--- Deactivates the current zone
function deactivateZone()
    if currentZone then
        currentZone = nil
        local playerPed = Utils.playerCache.PlayerPedId
        local pId = Utils.playerCache.playerId
        disableZoneEffects(pId, playerPed)
    end
end

-- RegisterCommand('testZone', function()
--     local pCoords = GetEntityCoords(PlayerPedId())
--     activateZone({
--         x = pCoords.x,
--         y = pCoords.y,
--         z = pCoords.z,
--         radius = 60.0,
--         circleColor = {125, 34, 0},
--         alpha = 255,
--         useZ = true
--     })
-- end)
