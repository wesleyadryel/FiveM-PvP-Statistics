if Config.enableApi then


    local validateRoute = function(path_, route_)
        if not path_  or not route_ then
            return
        end
        path_ = tostring(path_)
        local numChar = #route_
        local validate = path_:sub(1, numChar)
        if validate == route_ then
            return true
        end
        return false
    end


    local getRouteParameter = function(str, route_)
        local matchPrefix = route_ .. "/"
        if str:sub(1, #matchPrefix) == matchPrefix then
            local str_ = str:sub(#matchPrefix + 1)
            if str_ and #str_ > 0 then
                return str_
            end
        end
        return false
    end

    SetHttpHandler(function(request, response)
        if request.method == 'GET' then


            ---Handles GET requests to /matches endpoint.  [ https://{SERVER_IP}/{RESOURCE_NAME}/matches ]
            -- Returns metrics for a specific match or all matches if no matchId is provided.
            if validateRoute(request.path, '/matches') then    
                response.writeHead(200, {
                    ['Content-Type'] = 'application/json'
                })

                -- use matches/{matchIndex} to get data for a specific match [ https://{SERVER_IP}/{RESOURCE_NAME}/matches/Oh8j_1722574192 ]
                local matchIn = getRouteParameter(request.path, '/matches')
                if matchIn then
                    local metrics = Utils.getMachMetrics(matchIn)
                    response.send(json.encode(metrics or {}))
                else
                    local metrics = Utils.getMatchesMetrics()
                    response.send(json.encode(metrics or {}))
                end
                return
            end

            ---Handles GET requests to /players endpoint.  [ https://{SERVER_IP}/{RESOURCE_NAME}/players ]
            --Returns metrics for a specific player or all players if no playerLicense is provided.
            if validateRoute(request.path, '/players') then
                response.writeHead(200, {
                    ['Content-Type'] = 'application/json'
                })

                -- use players/{license} to get match data for a specific player [ https://{SERVER_IP}/{RESOURCE_NAME}/players/license:123ff24794e6345883c579f565aa6a657 ]
                local playerLicense = getRouteParameter(request.path, '/players')
                if playerLicense then
                    local metrics = Utils.getPlayersMetrics(playerLicense)
                    response.send(json.encode(metrics or {}))
                else
                    local metrics = Utils.getMatchesMetrics()
                    response.send(json.encode(metrics or {}))
                end
                return
            end

        end
    end)
end
