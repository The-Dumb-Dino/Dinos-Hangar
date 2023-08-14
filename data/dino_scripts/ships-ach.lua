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

-------------------------
-- ACHIEVEMENT UNLOCKS --
-------------------------

-- Easy


-- Normal


-- Hard

