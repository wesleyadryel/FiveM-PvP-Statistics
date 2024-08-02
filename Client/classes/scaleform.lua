Scaleform = {}

---Requests and loads a Scaleform movie.
---@param Scaleform string The name of the Scaleform movie to request.
---@return number|nil Returns the handle of the loaded Scaleform movie or nil if the movie could not be loaded.
Scaleform.Request = function(Scaleform)
    local attemp = 0
    local scaleform_handle = RequestScaleformMovie(Scaleform)
    while not HasScaleformMovieLoaded(scaleform_handle) do
        if attemp > 150 then
            break
        end
        Citizen.Wait(10)
        attemp = attemp + 1
    end
    if not scaleform_handle or not HasScaleformMovieLoaded(scaleform_handle) then
        print('Scaleform', string.format('Scaleform %s not loaded', tostring(Scaleform)))
        return
    end
    return scaleform_handle
end

---Calls a function on a Scaleform movie with optional return value.
---@param Scaleform number The handle of the Scaleform movie to call the function on.
---@param returndata boolean Whether to retrieve the return value from the Scaleform movie method.
---@param the_function string The name of the function to call on the Scaleform movie.
---@param ... ...args The parameters to pass to the Scaleform movie function. Supported types: boolean, number, string.
---@return any|nil Returns the return value from the Scaleform movie method if returndata is true, otherwise nil.
Scaleform.CallFunction = function(Scaleform, returndata, the_function, ...)
    BeginScaleformMovieMethod(Scaleform, the_function)
    local args = {...}

    if args ~= nil then
        for i = 1, #args do
            local arg_type = type(args[i])

            if arg_type == "boolean" then
                ScaleformMovieMethodAddParamBool(args[i])
            elseif arg_type == "number" then
                if not string.find(args[i], '%.') then
                    ScaleformMovieMethodAddParamInt(args[i])
                else
                    ScaleformMovieMethodAddParamFloat(args[i])
                end
            elseif arg_type == "string" then
                ScaleformMovieMethodAddParamTextureNameString(args[i])
            end
        end

        if not returndata then
            EndScaleformMovieMethod()
        else
            return EndScaleformMovieMethodReturnValue()
        end
    end
end
