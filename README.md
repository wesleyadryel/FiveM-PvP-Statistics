<p align="center">
    <h1 align="center"> Fivem PVP Match Metrics</h1>
</p>

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)



<p align="center">
  This project is a PvP combat statistics system designed for FiveM. It tracks and displays detailed combat data, including damage dealt, damage received, shot accuracy, etc. The system aims to enhance the gameplay experience by providing combat reports.
</p>

<hr/>

To get started with the PvP Combat Statistics System, follow these steps:

1. **Clone the Repository**
2. **Add to FiveM Resources**
     Copy the cloned folder to the resources directory of your FiveM server.
3.  **Start the Resource**
   Ensure the resource is started by adding it to your server configuration file (server.cfg)
```bash
ensure PVPStatistics
```

## Documentation

### Configuration and Usage
The configuration file, located in the root directory of the resource, contains some default settings. You can modify it if needed.

Starting a Match
To start a match, go to the default location, unless you have changed the configuration:
```bash
642.83074951172, 597.56042480469, 129.89599609375
```

At this location, you will see two blips, one red and one blue, representing the teams, and a floating timer showing the countdown until the match starts.
- ***Notes:***:
    - If the Config.DevMode setting is not set to true, you will only be able to start the match if there is at least one player in each team.
A match starts when the timer reaches 0 and there are enough players to begin.
    - Use the ``finishMatches`` command to finish matches in progress. This command is exclusive to players with ace admin permission

### During the Match
Once the match starts, players should engage in combat until one of the teams reaches the number of points defined in the configuration file. Each point corresponds to a round won.
When a match begins, information about the teams, including the number of players alive and the team's points, will appear in the top right corner of the screen.
You can access a panel showing player metrics, such as damage dealt and received, and number of kills and deaths. By default, this panel is activated with the "Z" key.
When a player is killed, they enter spectator mode with a panoramic view from various angles until a new round starts or the match ends.

![image](https://github.com/user-attachments/assets/681f8ced-cb09-4c46-84e1-c159210572f2)


### End of Match
At the end of a match, you can open a panel showing metrics for the previous match and all past matches. By default, this panel is activated with the "F1" key.

![image](https://github.com/user-attachments/assets/07aba21d-cb0c-484c-8e4c-4308fd838048)


## Data Saving and API
The script saves match data in a JSON file located in the root directory of the resource, which is read each time the resource is started. This is an initial method for data storage and should be improved in the future.

### The script also includes an API for retrieving game metrics, which can be enabled in the configuration file. The API includes the following endpoints:
* Get all completed matches:
```bash
https://{SERVER_IP}/{RESOURCE_NAME}/matches
```
* Get data for a specific match:
```bash
https://{SERVER_IP}/{RESOURCE_NAME}/matches/{matchIndex}
```
* Get all matches a player has participated in:
```bash
https://{SERVER_IP}/{RESOURCE_NAME}/players/{playerUniqueIdentifier}
```

## API data return example

```json
{
    "M1sR_1722588937": { /* MATCH UNIQUE INDEX */
        "matchMetrics": {
            "startIn": 1722588937, /* Unix timestamp when the match started */
            "winningGroup": "group:2", /* The group that won the match */
            "finishIn": 1722588990 /* Unix timestamp when the match finished */
        },
        "roundWinners": {
            "1": "group:2" /* The group that won round 1 */
        },
        "playersMetrics": {
            "1": { /* PLAYER_SOURCE */
                "totalDeaths": 0, /* Total number of deaths for the player */
                "totalDamageDone": 348, /* Total damage done by the player */
                "playerLicense": "license:365KK909787980JUH98I0IFD0587", /* UNIQUE IDENTIFIER for the player */
                "totalKills": 1, /* Total number of kills by the player */
                "totalDamageReceived": 0, /* Total damage received by the player */
                "roundsMetrics": {
                    "1": { /* Round 1 metrics */
                        "roundDamageReceived": 0, /* Total damage received in round 1 */
                        "damageEvents": [ /* LIST OF ALL DAMAGE EVENTS */
                            {
                                "isTeamDamage": false, /* Whether the damage was team damage */
                                "weaponDamage": 31, /* Amount of damage inflicted by the weapon */
                                "attackerLicense": "license:365KK909787980JUH98I0IFD0587", /* UNIQUE IDENTIFIER for the attacker */
                                "victimGroup": "group:1", /* The group of the victim */
                                "victimLicense": "license:14603ff0jrty6e6fb6f096faatt5t", /* UNIQUE IDENTIFIER for the victim */
                                "attackerCoords": { /* Coordinates of the attacker at the time of the damage */
                                    "z": 125.91357421875,
                                    "y": 511.6747131347656,
                                    "x": 848.6769409179688
                                },
                                "isWeaponKill": true, /* Whether the kill was done by a weapon */
                                "victimSrc": 1, /* Source of the victim */
                                "useArmour": false, /* Whether armor was used */
                                "damagedBodyPart": "hip", /* Body part that was damaged */
                                "hitPosition": { /* Position where the hit occurred */
                                    "z": 125.91357421875,
                                    "y": 513.2966918945313,
                                    "x": 849.4285888671875
                                },
                                "attackerGroup": "group:2", /* The group of the attacker */
                                "projectilePosition": { /* Position of the projectile (if applicable) */
                                    "z": -0.02182073518633,
                                    "y": -0.08560442179441,
                                    "x": -0.02349925227463
                                },
                                "willKill": false, /* Whether the damage will kill the victim */
                                "attackerName": "dev", /* Name of the attacker */
                                "timestamp": 1722588988, /* Unix timestamp of the damage event */
                                "isTeamKill": false, /* Whether the kill was a team kill */
                                "attackerSrc": 2, /* Source of the attacker */
                                "weaponHash": 3219281620, /* Hash of the weapon used */
                                "victimCoords": { /* Coordinates of the victim at the time of the damage */
                                    "z": 125.91357421875,
                                    "y": 513.2966918945313,
                                    "x": 849.4285888671875
                                },
                                "victimName": "irineu", /* Name of the victim */
                                "victimSource": "license:14603ff0jrty6e6fb6f096faatt5t", /* Source of the victim */
                                "overrideDefaultDamage": true, /* Whether the damage is overridden */
                                "damagedBodyPartId": 0 /* ID of the damaged body part */
                            }
                        ],
                        "roundDamageDone": 348, /* Total damage done in round 1 */
                        "roundKills": 1, /* Total number of kills in round 1 */
                        "roundDeaths": 0 /* Total number of deaths in round 1 */
                    }
                }
            }
        }
    }
}

```
