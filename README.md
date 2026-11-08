# Roblox Combat Mechanics Script

BedWars Companion is a Roblox script that adds server-authoritative combat mechanics to your own Roblox experience, including automatic attacks, extra airborne jumps, damage, knockback, cooldowns, target validation, and request-rate limiting.

## Install

1. Open your Roblox experience in Roblox Studio.
2. In `ServerScriptService`, create a Script named `CombatMechanics`.
3. Copy the contents of `ServerScriptService/CombatMechanics.server.lua` into the new Script.
4. In `StarterPlayer > StarterPlayerScripts`, create a LocalScript named `CombatControls`.
5. Copy the contents of `StarterPlayer/StarterPlayerScripts/CombatControls.client.lua` into the new LocalScript.
6. Press Play with at least two test players.
7. Confirm that the `ReplicatedStorage.CombatAction` RemoteEvent is created automatically.

## Use

1. Hold `F` to automatically attack the nearest living player within range and in front of your character.
2. Successful attacks deal damage and apply server-side knockback.
3. Press `Space` while airborne to request an extra jump.
4. Adjust the constants near the top of `CombatMechanics.server.lua` to change attack range, facing requirements, damage, cooldown, knockback, upward force, and request limits.
5. Test the mechanics in Roblox Studio before publishing the experience.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/fcf4c2b5-3635-463a-bb5e-3a5fce022f10?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=fcf4c2b5-3635-463a-bb5e-3a5fce022f10
