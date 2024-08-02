local lobbies = type(Config.lobbies) == 'table' and Config.lobbies or {}

for k, v in pairs(lobbies) do
    Utils.updateStartTimer()
    local loopCooldowns
    loopCooldowns = function()
        local cooldown = v.cooldownInitMatch or 30000
        cooldown = cooldown + 1000
        SetTimeout(cooldown, function()
            Utils.updateStartTimer()
            Utils.startMatch()
            loopCooldowns()
        end)
    end
    loopCooldowns()
end
