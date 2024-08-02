

Utils.onPlayerExitMatch = function()
    local pPed = PlayerPedId()
    SetPedInfiniteAmmoClip(pPed, true)
    RemoveAllPedWeapons(pPed, true)
    PLAYER_IN_MATCH = nil
    deactivateZone()
    Utils.revivePlayer()
    Utils.destroyScoreboard()
end

RegisterNetEvent('PVPStatistics:finishMatch', function()
    Utils.onPlayerExitMatch()
end)

