Utils = {}
Utils.WeaponsHashs = {}

Citizen.CreateThread(function()
    if Config.Weapons then
        for k, v in pairs(Config.Weapons) do
            Utils.WeaponsHashs[tostring(GetHashKey(k))] = k
        end
    end
end)



--- Draws 3D text on the screen at the specified coordinates.
-- 
---@param x number The X coordinate
---@param y number The Y coordinate 
---@param z number The Z coordinate 
---@param text string The text to be displayed
---@param scale number Optional. The scale of the text. Defaults to 4 if not provided
---@param textFont number Optional. The font of the text.
---@param useDrawColor boolean Optional. If true, a background rectangle is drawn behind the text
-- 
-- @return nil
Utils.DrawText3D = function(x, y, z, text, scale, textFont, useDrawColor)
    local scale = scale or 0.45
    SetTextScale(scale, scale)
    SetTextFont(textFont or 4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    if useDrawColor then
        local stringLen = string.len(text)
        local factor = stringLen / 450
        local lines = countStringLines(text) or 1
        local height = 0.03 * lines
        local ajustTextZ = 0.0128 * lines
        DrawRect(0.0, ajustTextZ, factor, height, 7, 110, 50, 75)
    end
    ClearDrawOrigin()
end

--- Generates a instructional scaleform
---@param keysTable table
---@return integer scaleform
Utils.instructionalScaleform = function(keysTable)
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(10)
    end
    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    for btnIndex, keyData in ipairs(keysTable) do
        local btn = GetControlInstructionalButton(0, keyData.key, true)

        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(btnIndex - 1)
        ScaleformMovieMethodAddParamPlayerNameString(btn)
        BeginTextCommandScaleformString("STRING")
        AddTextComponentSubstringKeyboardDisplay(keyData.label)
        EndTextCommandScaleformString()
        EndScaleformMovieMethod()
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    return scaleform
end

---Generates a random alphanumeric token.
---@param size number? The length of the token. If not provided, defaults to 10.
---@return string A random alphanumeric token of the specified length.
Utils.createToken = function(size)
    local character_set = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local string_sub = string.sub
    local math_random = Utils.generateRandomNumber
    local table_concat = table.concat
    local character_set_amount = #character_set
    local number_one = 1
    local default_length = 10

    local function generate_key(length)
        local random_string = {}
        for int = number_one, length or default_length do
            local random_number = math_random(number_one, character_set_amount)
            local character = string_sub(character_set, random_number, random_number)
            random_string[#random_string + number_one] = character
        end
        return table_concat(random_string)
    end

    return generate_key(size)
end

local countGenerateSeed = 0

---Generates a random number within a given range or returns a random number if no range is specified.
---@param min number The minimum value of the range. If not specified, defaults to 1.
---@param max number The maximum value of the range. If not specified, defaults to 1.
---@param increment number? A value to modify the random seed for variability. If not provided, it increments internally.
---@return number A random number within the specified range or a random number if no range is specified.
Utils.generateRandomNumber = function(min, max, increment)
    if type(increment) ~= 'number' then
        increment = nil
    end
    if min and max and (min == max) then
        return min
    end
    local timer = GetGameTimer()
    local calc = timer + (increment or countGenerateSeed)
    if not increment then
        if countGenerateSeed > 100000 then
            countGenerateSeed = 1000
        else
            countGenerateSeed = countGenerateSeed + 100
        end
    end
    if not min or not max then
        return math.random()
    else
        return math.random(min, max)
    end
end

