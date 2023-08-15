----------------------
-- HELPER FUNCTIONS --
----------------------

-- Generic iterator for C vectors
local function vter(cvec)
    local i = -1 -- so the first returned value is indexed at zero
    local n = cvec:size()
    return function()
        i = i + 1
        if i < n then return cvec[i] end
    end
end

-- Check if a weapon's current shot is its first
local function is_first_shot(weapon, afterFirstShot)
    local shots = weapon.numShots
    if weapon.weaponVisual.iChargeLevels > 0 then shots = shots*(weapon.weaponVisual.boostLevel + 1) end
    if weapon.blueprint.miniProjectiles:size() > 0 then shots = shots*weapon.blueprint.miniProjectiles:size() end
    if afterFirstShot then shots = shots - 1 end
    return shots == weapon.queuedProjectiles:size()
end

-- Get a table for a userdata value by name
local function userdata_table(userdata, tableName)
    if not userdata.table[tableName] then userdata.table[tableName] = {} end
    return userdata.table[tableName]
end

-- Check whether we're fighting a ship
local function in_ship_combat(playerShip, enemyShip)
    return enemyShip and
           playerShip and
           enemyShip._targetable.hostile and
           not (enemyShip.bDestroyed or playerShip.bJumping)
end

local function string_starts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

local function should_track_achievement(achievement, ship, shipClassName)
    return ship and
           Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame and
           Hyperspace.CustomAchievementTracker.instance:GetAchievementStatus(achievement) < Hyperspace.Settings.difficulty and
           string_starts(ship.myBlueprint.blueprintName, shipClassName)
end

local function current_sector()
    return Hyperspace.Global.GetInstance():GetCApp().world.starMap.worldLevel + 1
end

local function count_ship_achievements(achPrefix)
    local count = 0
    for i = 1, 3 do
        if Hyperspace.CustomAchievementTracker.instance:GetAchievementStatus(achPrefix.."_"..tostring(i)) > -1 then
            count = count + 1
        end
    end
    return count
end

--------------
-- TRACKERS --
--------------

-- Track changes in system damage
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    for system in vter(ship.vSystemList) do
        if ship:HasSystem(system:GetId()) then
            local damage = system.healthState.second - system.healthState.first
            local sysData = userdata_table(system, "mods.dino.achTrackSys")
            sysData.damageChange = damage - (sysData.damageLast or damage)
            sysData.damageLast = damage
        end
    end
end)

--------------------
-- MANTIS WARSHIP --
--------------------

-- Easy
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    if ship.iShipId == 0 and in_ship_combat(ship, Hyperspace.ships.enemy) and should_track_achievement("ACH_SHIP_MANTIS_WARSHIP_1", ship, "PLAYER_SHIP_MANTIS_WARSHIP") then
        for system in vter(ship.vSystemList) do
            local damageChange = userdata_table(system, "mods.dino.achTrackSys").damageChange
            if damageChange and damageChange < 0 and ship.ship.vRoomList[system:GetRoomId()].extend.timeDilation ~= 0 then
                local vars = Hyperspace.playerVariables
                vars.loc_ach_mantis_time_repairs = vars.loc_ach_mantis_time_repairs + 1
                if vars.loc_ach_mantis_time_repairs >= 10 then
                    Hyperspace.CustomAchievementTracker.instance:SetAchievement("ACH_SHIP_MANTIS_WARSHIP_1", false)
                end
            end
        end
    end
end)

-- Normal


-- Hard


-------------------------------------
-- LAYOUT UNLOCKS FOR ACHIEVEMENTS --
-------------------------------------

local achLayoutUnlocks = {
    {
        achPrefix = "ACH_SHIP_MANTIS_WARSHIP",
        unlockShip = "PLAYER_SHIP_MANTIS_WARSHIP_3"
    }
}

script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
    local unlockTracker = Hyperspace.CustomShipUnlocks.instance
    for _, unlockData in ipairs(achLayoutUnlocks) do
        if not unlockTracker:GetCustomShipUnlocked(unlockData.unlockShip) and count_ship_achievements(unlockData.achPrefix) >= 2 then
            unlockTracker:UnlockShip(unlockData.unlockShip, false)
        end
    end
end)
