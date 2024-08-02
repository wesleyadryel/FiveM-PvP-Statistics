local blockedweaponHashs = {
    -- ["2725352035"] = true -- Fist
}

local bodyParts = {
    [0] = "hip",
    [1] = "leftThigh",
    [2] = "leftShin",
    [3] = "leftFoot",
    [4] = "rightThigh",
    [5] = "rightShin",
    [6] = "rightFoot",
    [7] = "belly",
    [8] = "abdomen",
    [9] = "chest",
    [10] = "trapezius",
    [11] = "leftShoulder",
    [12] = "leftArm",
    [13] = "leftForearm",
    [14] = "leftHand",
    [15] = "rightShoulder",
    [16] = "rightArm",
    [17] = "rightForearm",
    [18] = "rightHand",
    [19] = "neck",
    [20] = "head"
}

AddEventHandler('weaponDamageEvent', function(attackerSrc, eventData)
    attackerSrc = tonumber(attackerSrc)

    local weaponHash = eventData.weaponType
    if blockedweaponHashs[tostring(weaponHash)] then
        return
    end

    if (eventData.damageType ~= 3) then
        return
    end

    local weaponDamage = eventData.weaponDamage
    local overrideDefaultDamage = eventData.overrideDefaultDamage

    if overrideDefaultDamage and (not weaponDamage or tonumber(weaponDamage) < 1.0) then
        return
    end

    local hitPeds = eventData.hitGlobalIds
    local willKill = eventData.willKill

    local hitPosX = eventData.localPosX
    local hitPosY = eventData.localPosY
    local hitPosZ = eventData.localPosZ

    local weaponsList = Utils.WeaponsHashs or {}
    local weaponName = weaponsList[tostring(weaponHash)]

    if not weaponName then
        print('^3 Weapon hash ' .. tostring(weaponHash) .. ' was not found in the weapons list. Check in the config ^0')
    end

    local damagedBodyPartId = eventData.hitComponent
    local damagedBodyPart = bodyParts[damagedBodyPartId]

    if WasEventCanceled() then
        return
    end

    for _, pedId in pairs(hitPeds) do
        if pedId then
            local victimPed = NetworkGetEntityFromNetworkId(pedId)
            local victimSrc = NetworkGetEntityOwner(victimPed)
            if victimSrc then
                if not WasEventCanceled() then
                    local isWeaponKill = true
                    Utils.processDamageEvent(isWeaponKill, attackerSrc, victimSrc, victimPed, hitPosX, hitPosY, hitPosZ,
                        weaponHash, weaponName, weaponDamage, willKill, overrideDefaultDamage, damagedBodyPartId,
                        damagedBodyPart)
                end
            end
        end
    end
end)

AddEventHandler("playerDropped", function(reason)
    local src = source
    if src then
        Utils.setPlayerOffline(src)
    end
end)

RegisterServerEvent("PVPStatistics:onPlayerDead", function()
    local src = source
    if not src then
        return
    end
    local isDead = Player(src).state['PVPStatistics:isDead']
    if isDead then
        return
    end

    local attackerSrc = nil
    local pPed = GetPlayerPed(src)

    local hitPosX, hitPosY, hitPosZ = nil, nil, nil
    local weaponName = nil
    local weaponHash = nil
    local killerPlayerSource = nil
    local damage = nil

    local isWeaponKill = false
    local weaponDamage = (damage and damage > 0) and damage or damage

    local willKill = true
    local overrideDefaultDamage, damagedBodyPartId, damagedBodyPart = nil, nil, nil
    Utils.processDamageEvent(isWeaponKill, attackerSrc, src, pPed, hitPosX, hitPosY, hitPosZ, weaponHash, weaponName,
        weaponDamage, willKill, overrideDefaultDamage, damagedBodyPartId, damagedBodyPart)
end)

