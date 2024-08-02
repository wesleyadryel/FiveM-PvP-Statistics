---@class DamageEvent
DamageEvent = {}
DamageEvent.__index = DamageEvent

---@param attackerGroup number
---@param victimGroup number
---@param isTeamDamage boolean
---@param isTeamKill boolean
---@param timestamp number
---@param weaponHash string
---@param weaponName number
---@param weaponDamage number
---@param hitPlayerCoords table
---@param attackerCoords vector3
---@param victimCoords vector3
---@param projectileCoords table
---@param license_attacker string
---@param license_victim string
---@param attackerSrc number
---@param victimSrc number
---@param name_attacker string
---@param name_victim string
---@param willKill boolean
---@param isDefaultDamageOverridden boolean
---@param hasArmour boolean
---@param damagedBodyPartId number
---@param damagedBodyPart string
---@param isWeaponKill boolean
---@return DamageEvent
function DamageEvent:new(isWeaponKill, attackerGroup, victimGroup, isTeamDamage, isTeamKill, timestamp, weaponHash, weaponName, weaponDamage, hitPlayerCoords, attackerCoords, victimCoords, projectileCoords, license_attacker, license_victim, attackerSrc, victimSrc, name_attacker, name_victim, willKill, isDefaultDamageOverridden, hasArmour, damagedBodyPartId, damagedBodyPart)
    local obj = setmetatable({}, self)
    obj.isWeaponKill = isWeaponKill
    obj.attackerGroup = attackerGroup
    obj.victimGroup = victimGroup
    obj.isTeamDamage = isTeamDamage
    obj.isTeamKill = isTeamKill
    obj.timestamp = timestamp
    obj.weaponHash = weaponHash
    obj.weaponName = weaponName
    obj.weaponDamage = weaponDamage
    obj.hitPosition = {
        x = hitPlayerCoords.x,
        y = hitPlayerCoords.y,
        z = hitPlayerCoords.z
    }
    obj.attackerCoords = {
        x = attackerCoords.x,
        y = attackerCoords.y,
        z = attackerCoords.z
    }
    obj.victimCoords = {
        x = victimCoords.x,
        y = victimCoords.y,
        z = victimCoords.z
    }
    obj.projectilePosition = {
        x = projectileCoords.x,
        y = projectileCoords.y,
        z = projectileCoords.z
    }
    obj.attackerLicense = license_attacker
    obj.victimLicense = license_victim
    obj.attackerSrc = attackerSrc
    obj.victimSrc = victimSrc
    obj.victimSource = license_victim
    obj.attackerName = name_attacker
    obj.victimName = name_victim
    obj.willKill = willKill
    obj.overrideDefaultDamage = isDefaultDamageOverridden
    obj.useArmour = hasArmour
    obj.damagedBodyPartId = damagedBodyPartId
    obj.damagedBodyPart = damagedBodyPart
    return obj
end
