local commandsConfig = type(Config.commands) == 'table' and Config.commands or {}

if commandsConfig['panelMatch'] then
    local command, keyBind, description = commandsConfig['panelMatch'].command, commandsConfig['panelMatch'].keyBind, commandsConfig['panelMatch'].description
    if command then
        RegisterCommand(command, function(src)
            Utils.togglePanelMatch()
        end)
        if description then
            RegisterKeyMapping(command, description, 'KEYBOARD', keyBind)
        end
    end
end

if commandsConfig['panekMetrics'] then
    local command, keyBind, description = commandsConfig['panekMetrics'].command, commandsConfig['panekMetrics'].keyBind, commandsConfig['panekMetrics'].description
    if command then
        RegisterCommand(command, function(src)
           TriggerServerEvent('PVPStatistics:togglePlayerMetricsPanel')
        end)
        if description then
            RegisterKeyMapping(command, description, 'KEYBOARD', keyBind)
        end
    end
end
