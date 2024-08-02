---@class Spectate
Spectate = {}
Spectate.__index = Spectate

---Constructor for the Spectate class
---@return Spectate The newly created Spectate instance.
function Spectate:new(validateToStopSpectate)
    local data = {
        active = false,
        locations = {},
        currentLocationIndex = 1,
        blockControlsThread = false,
        changedCam = false,
        lastPosition = nil,
        validateToStopSpectate = type(validateToStopSpectate) == 'function' and validateToStopSpectate or nil
    }
    setmetatable(data, Spectate)
    local pPed = PlayerPedId()
    if pPed and DoesEntityExist(pPed) then
        local currentPlayerPosition = GetEntityCoords(pPed)
        data.lastPosition = currentPlayerPosition
    end
    return data
end

---Sets the last position of the player.
---
--- @param position table A table containing x, y, and z coordinates.
--- @field position table A table with x, y, and z coordinates.
---
--- @return nil
function Spectate:setLastPosition(position)
    if (type(position) == 'vector3' or type(position) == 'table') and position.x and position.y and position.z then
        self.lastPosition = position
    end
end

---Sets the spectator locations.
---
--- @param locations table A table containing location coordinates.
--- @field locations table An array of location tables with x, y, and z coordinates.
---
--- @return nil
function Spectate:setLocations(locations)
    local validData = {}
    for _, loc in pairs(locations) do
        if type(loc) == 'table' and loc.x and loc.y and loc.z then
            table.insert(validData, loc)
        end
    end
    self.locations = validData
end

---Creates a thread to display instructional controls and handle user input.
---
--- @param callback function The callback function to be called when a control action is triggered.
---
--- @return nil
function Spectate:createInstructionalThread(callback)
    local controls = {}

    if type(Config.spectateControl) == 'table' and Config.spectateControl.key and Config.spectateControl.label then
        controls = {{
            label = Config.spectateControl.label,
            key = Config.spectateControl.key
        }}
    else
        controls = {{
            label = 'Next Cam',
            key = 190 -- INPUT_FRONTEND_RIGHT
        }}
    end

    if not self.active then
        self.active = true
        CreateThread(function()
            local fivemScaleform = Utils.instructionalScaleform(controls)
            while self.active do
                DrawScaleformMovieFullscreen(fivemScaleform, 255, 255, 255, 255, 0)
                Wait(0)
            end
            SetScaleformMovieAsNoLongerNeeded(fivemScaleform)
        end)

        CreateThread(function()
            while self.active do
                for _, control in pairs(controls) do
                    if control.key and IsControlJustPressed(0, control.key) then
                        callback()
                    end
                end
                Wait(5)
            end
        end)
    end
end

---Stops the instructional controls and cleans up resources.
---
--- @return nil
function Spectate:destroy()
    if self.active then
        self.active = false
        self.blockControls = false
        self.threadStopSpec = false
        self.blockControlsThread = false
        if self.changedCam then
            if self.lastPosition then
                local pPed = PlayerPedId()
                SetEntityCoords(pPed, self.lastPosition)
                FreezeEntityPosition(pPed, false)
                SetEntityVisible(pPed, true, true)
                SetEntityCollision(pPed, true, true)
                SetEntityInvincible(pPed, false)
            end
        end
    end
end

---Changes the camera to the next location in the list.
---
--- @return nil
function Spectate:changeCam()
    if #self.locations == 0 then
        return
    end

    local ped = PlayerPedId()
    local location = self.locations[self.currentLocationIndex]

    Utils.revivePlayer()
    SetEntityCoords(ped, location.x, location.y, location.z)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    SetEntityCollision(ped, false, false)
    SetEntityInvincible(ped, true)

    -- set default cam position
    SetGameplayCamRelativePitch(-90.0, 1.0)
    self.changedCam = true

    self.currentLocationIndex = self.currentLocationIndex + 1
    if self.currentLocationIndex > #self.locations then
        self.currentLocationIndex = 1
    end

    if self.validateToStopSpectate then
        if not self.threadStopSpec then
            self.threadStopSpec = true
            Citizen.CreateThread(function()
                while self.threadStopSpec do
                    if self.validateToStopSpectate() then
                        self:destroy()
                    end
                    Citizen.Wait(1000)
                end
            end)
        end
    end

end

---Blocks controls while in a specified zone.
---
--- @return nil
function Spectate:blockControls()
    if self.blockControlsThread then
        return
    end
    self.blockControlsThread = true
    CreateThread(function()
        while self.blockControlsThread do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()

            DisablePlayerFiring(playerPed, true)
            SetPlayerCanDoDriveBy(playerPed, false)
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
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)

            if IsDisabledControlJustPressed(2, 37) or IsDisabledControlJustPressed(0, 106) then
                SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
            end

        end
        self.blockControlsThread = false
    end)
end
