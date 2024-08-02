Config = {}

Config.DevMode = false
Config.disableBucketPopulation = true
Config.setBucketLockdownMode = true
Config.enableApi = true

Config.checkPlayerDead = function(health)
    return health <= 101
end

Config.createMatchIndex = function()
    return tostring(Utils.createToken(4) .. '_' .. os.time())
end

Config.getPlayerUniqueIdentifier = function(playerSource)
    if not playerSource then
        return
    end
    local src = math.floor(playerSource)
    local playerLicense = GetPlayerIdentifierByType(src, 'license')
    return playerLicense
end

Config.initMatchInfos = {
    title = "Round %s", 
    subtitle = "YOUR TEAM"
}

Config.lobbyControls = {{
    label = 'Join the Group',
    key = 201, -- INPUT_FRONTEND_ACCEPT
    action = 'enterGroup'
}}

Config.spectateControl = {
    label = 'Next Location',
    key = 190 -- INPUT_FRONTEND_RIGHT
}

Config.commands = {
    ['panelMatch'] = {
        command = 'panelMatch',
        keyBind = 'Z',
        description = 'Open Match Panel'
    },
    ['panekMetrics'] = {
        command = 'panekMetrics',
        keyBind = 'F1',
        description = 'Open Player Metrics'
    }
}

Config.lang = {
    ['KDR'] = 'KDR',
    ['HS'] = 'HS',
    ['KILLS'] = 'KILLS',
    ['DEATH'] = 'DEATH',
    ['DAMAGE_RECEIVED'] = 'DAMAGE\nRECEIVED',
    ['DAMAGE_DONE'] = 'DAMAGE\nDONE',
    ['ACCURACY_LAST_MATCH'] = 'ACCURACY\nLast Match',
    ['ACCURACY_GENERAL_REPORT'] = 'ACCURACY\nGeneral Report',
    ['GeneralReport'] = 'General Report',
    ['LastMatch'] = 'Last Match',
    ['PlayerName'] = 'Player Name',
    ['kills'] = 'Kils',
    ['deaths'] = 'Deaths',
    ['damageReceived'] = 'Damage Received',
    ['damageDone'] = 'Damage Done',
    ['players'] = 'Players',
    ['notValidGroup'] = '~r~This group is not a valid~s~',
    ['alreadyInAmatch'] = '~y~You are already in a match~s~',
    ['leaveGroup'] = '~y~You left the group~s~', 
    ['isAlreadyInAGroup'] = '~r~You are already in a group~s~',
    ['crowdedGroup'] = '~y~This group is full~s~',
    ['joinedTheGroup'] = 'You have joined the group~s~\nWait until the match starts',
    ['disqualifiedGroup'] = 'Your group was ~r~disqualified~s~ from the match because it did not reach the ~y~minimum number of members~s~'
}

Config.lobbies = {
    ['lobby1'] = {
        pointsToEndMatch = 13, -- amount of points to be acquired for the match to end
        cooldownInitMatch = 8000, -- 30s
        circleZone = {
            coordinate = vector3(733.55603027344, 556.27252197266, 137.53991699219),
            radius = 130.0,
            zoneColor = {
                r = 255,
                g = 255,
                b = 255
            },
            alpha = 200,
            useZ = true
        },
        timerLobby = {
            coordinate = vector3(624.65936279297, 590.36047363281, 139.26013183594),
            text = 'Starting Match at:'
        },
        spectatorLocations = {{
            x = 641.52526855469,
            y = 609.32305908203,
            z = 143.55529785156
        }, {
            x = 660.92309570312,
            y = 540.30328369141,
            z = 148.13842773438
        }, {
            x = 775.10766601562,
            y = 495.54724121094,
            z = 152.1318359375
        }, {
            x = 839.65716552734,
            y = 495.77142333984,
            z = 146.28503417969
        }, {
            x = 832.52307128906,
            y = 523.8857421875,
            z = 167.01025390625
        }, {
            x = 763.34503173828,
            y = 627.57360839844,
            z = 140.01684570312
        }, {
            x = 705.34942626953,
            y = 660.65936279297,
            z = 149.78979492188
        }, {
            x = 713.78900146484,
            y = 566.80877685547,
            z = 174.59265136719
        }},
        weapons = {'WEAPON_HEAVYSNIPER', 'WEAPON_SNIPERRIFLE', 'WEAPON_SPECIALCARBINE', 'WEAPON_ASSAULTRIFLE_MK2',
                   'WEAPON_MACHINEPISTOL', 'WEAPON_PUMPSHOTGUN', 'WEAPON_COMBATPDW', 'WEAPON_CERAMICPISTOL',
                   'WEAPON_PISTOL_MK2', 'WEAPON_SNSPISTOL'},
        groups = {
            ['group:1'] = {
                numberOfTeamMembers = 5,
                label = 'Blue Group',
                blipColor = {
                    r = 44,
                    g = 152,
                    b = 240
                },
                scoreColor = {
                    r = 44,
                    g = 152,
                    b = 240,
                    a = 255
                },
                panelPlayersColor = {
                    r = 44,
                    g = 152,
                    b = 240,
                    a = 255
                },
                coordinateStartBlip = vector3(642.83074951172, 597.56042480469, 129.89599609375),
                coordinateSpawnMatch = vector3(849.19122314453, 513.04614257812, 126.91357421875)
            },
            ['group:2'] = {
                numberOfTeamMembers = 5,
                label = 'Red Group',
                blipColor = {
                    r = 150,
                    g = 8,
                    b = 0
                },
                scoreColor = {
                    r = 255,
                    g = 0,
                    b = 0,
                    a = 255
                },
                panelPlayersColor = {
                    r = 255,
                    g = 0,
                    b = 0,
                    a = 255
                },
                coordinateStartBlip = vector3(617.41979980469, 608.00439453125, 129.89599609375),
                coordinateSpawnMatch = vector3(662.63739013672, 600.35601806641, 130.04760742188)
            }
        }
    }
}

Config.Weapons = {
    ['WEAPON_KNUCKLE'] = 'Knuckle Dusters',
    ['WEAPON_SWITCHBLADE'] = 'Switchblade',
    ['WEAPON_KNIFE'] = 'Knife',
    ['WEAPON_NIGHTSTICK'] = 'Nightstick',
    ['WEAPON_HAMMER'] = 'Hammer',
    ['WEAPON_BAT'] = 'Katana',
    ['WEAPON_GOLFCLUB'] = 'Golf Club',
    ['WEAPON_CROWBAR'] = 'Knife',
    ['WEAPON_HATCHET'] = 'Hatchet',
    ['WEAPON_POOLCUE'] = 'Pool Cue',
    ['WEAPON_WRENCH'] = 'Wrench',
    ['WEAPON_FLASHLIGHT'] = 'Flashlight',
    ['WEAPON_BOTTLE'] = 'Broken Bottle',
    ['WEAPON_DAGGER'] = 'Bowie Knife',
    ['WEAPON_MACHETE'] = 'Machete',
    ['WEAPON_BATTLEAXE'] = 'Battle Axe',
    ['WEAPON_BALL'] = 'Baseball',
    ['WEAPON_SNOWBALL'] = 'Snowball',
    ['WEAPON_PISTOL'] = 'Pistol',
    ['WEAPON_PISTOL_MK2'] = 'Pistol MKII',
    ['WEAPON_COMBATPISTOL'] = 'Combat Pistol',
    ['WEAPON_MACHINEPISTOL'] = 'Machine Pistol',
    ['WEAPON_APPISTOL'] = 'Automatic Pistol',
    ['WEAPON_PISTOL50'] = 'Pistol .50',
    ['WEAPON_REVOLVER'] = 'Revolver',
    ['WEAPON_REVOLVER_MK2'] = 'Revolver MKII',
    ['WEAPON_VINTAGEPISTOL'] = 'Vintage Pistol',
    ['WEAPON_CERAMICPISTOL'] = 'Ceramic Pistol',
    ['WEAPON_SNSPISTOL'] = 'SNS Pistol',
    ['WEAPON_SNSPISTOL_MK2'] = 'SNS Pistol MKII',
    ['WEAPON_MARKSMANPISTOL'] = 'Marksman Pistol',
    ['WEAPON_HEAVYPISTOL'] = 'Heavy Pistol',
    ['WEAPON_FLAREGUN'] = 'Flare Gun',
    ['WEAPON_STUNGUN'] = 'Taser',
    ['WEAPON_DOUBLEACTION'] = 'Double-Action Revolver',
    ['WEAPON_MICROSMG'] = 'Micro SMG',
    ['WEAPON_SMG'] = 'SMG',
    ['WEAPON_SMG_MK2'] = 'SMG MKII',
    ['WEAPON_ASSAULTSMG'] = 'Assault SMG',
    ['WEAPON_MINISMG'] = 'Mini SMG',
    ['WEAPON_COMBATPDW'] = 'Combat PDW',
    ['WEAPON_MG'] = 'MG',
    ['WEAPON_COMBATMG'] = 'Combat MG',
    ['WEAPON_COMBATMG_MK2'] = 'Combat MG MKII',
    ['WEAPON_GUSENBERG'] = 'Gusenberg',
    ['WEAPON_PUMPSHOTGUN'] = 'Pump Shotgun',
    ['WEAPON_PUMPSHOTGUN_MK2'] = 'Pump Shotgun MKII',
    ['WEAPON_HEAVYSHOTGUN'] = 'Heavy Shotgun',
    ['WEAPON_SAWNOFFSHOTGUN'] = 'Sawn-off Shotgun',
    ['WEAPON_ASSAULTSHOTGUN'] = 'Assault Shotgun',
    ['WEAPON_BULLPUPSHOTGUN'] = 'Bullpup Shotgun',
    ['WEAPON_COMBATSHOTGUN'] = 'Combat Shotgun',
    ['WEAPON_AUTOSHOTGUN'] = 'Sweeper',
    ['WEAPON_DBSHOTGUN'] = 'Double-Barreled Shotgun',
    ['WEAPON_MUSKET'] = 'Musket',
    ['WEAPON_ASSAULTRIFLE'] = 'Assault Rifle',
    ['WEAPON_ASSAULTRIFLE_MK2'] = 'Assault Rifle MKII',
    ['WEAPON_CARBINERIFLE'] = 'Carbine Rifle',
    ['WEAPON_CARBINERIFLE_MK2'] = 'Carbine Rifle MKII',
    ['WEAPON_ADVANCEDRIFLE'] = 'Advanced Rifle',
    ['WEAPON_COMPACTRIFLE'] = 'Compact Rifle',
    ['WEAPON_SPECIALCARBINE'] = 'Special Carbine',
    ['WEAPON_SPECIALCARBINE_MK2'] = 'Special Carbine MKII',
    ['WEAPON_BULLPUPRIFLE'] = 'Bullpup Rifle',
    ['WEAPON_BULLPUPRIFLE_MK2'] = 'Bullpup Rifle MKII',
    ['WEAPON_MILITARYRIFLE'] = 'Military Rifle',
    ['WEAPON_HEAVYRIFLE'] = 'Heavy Rifle',
    ['WEAPON_TACTICALRIFLE'] = 'Service Carbine',
    ['WEAPON_SNIPERRIFLE'] = 'Sniper Rifle',
    ['WEAPON_HEAVYSNIPER'] = 'Heavy Sniper Rifle',
    ['WEAPON_HEAVYSNIPER_MK2'] = 'Heavy Sniper Rifle MKII',
    ['WEAPON_MARKSMANRIFLE'] = 'Marksman Rifle',
    ['WEAPON_MARKSMANRIFLE_MK2'] = 'Marksman Rifle MKII',
    ['WEAPON_PRECISIONRIFLE'] = 'Precision Rifle',
    ['WEAPON_COMPACTLAUNCHER'] = 'Compact Grenade Launcher',
    ['WEAPON_GRENADELAUNCHER'] = 'Grenade Launcher',
    ['WEAPON_RPG'] = 'RPG',
    ['WEAPON_HOMINGLAUNCHER'] = 'Homing Launcher',
    ['WEAPON_MINIGUN'] = 'Minigun',
    ['WEAPON_RAILGUN'] = 'Railgun',
    ['WEAPON_GRENADE'] = 'Frag Grenade',
    ['WEAPON_STICKYBOMB'] = 'Sticky Bombs',
    ['WEAPON_SMOKEGRENADE'] = 'Smoke Grenade',
    ['WEAPON_BZGAS'] = 'BZ Gas',
    ['WEAPON_MOLOTOV'] = 'Molotov Cocktail',
    ['WEAPON_PIPEBOMB'] = 'Pipebomb',
    ['WEAPON_PROXMINE'] = 'Proximity Mine',
    ['WEAPON_FIREWORK'] = 'Firework Launcher',
    ['WEAPON_PETROLCAN'] = 'Jerry Can',
    ['WEAPON_FLARE'] = 'Flare',
    ['GADGET_PARACHUTE'] = 'Parachute'

}
