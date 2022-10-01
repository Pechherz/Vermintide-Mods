--this is a simple merge of special_spawn_idling and No Silent Assassins
-- all credits to Jsat & Prop joe & IamLupo & Xp

local mod_name = "EnemyTweaks"

EnemyTweaks = {}
EnemyTweaks.widget_settings = {
    NO_SILENT_ASSASSINS_ENABLED = {
        ["save"] = "cb_enemy_tweaks_no_silent_assassins_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "No Silent Assassins",
        ["tooltip"] = "Use different assassin spawn sound to prevent silent spawns.",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1,
    },
    SPECIALS_SPAWN_IDLING_ENABLED = {
        ["save"] = "cb_enemy_tweaks_specials_spawn_idling_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Specials Spawn Idling",
        ["tooltip"] = "Specials don't attack for a given time after spawning",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1,
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = {
                    "cb_enemy_tweaks_specials_idle_time",
                    "cb_enemy_tweaks_gutter_runner_spawns_idling_enabled",
                    "cb_enemy_tweaks_globadier_spawns_idling_enabled",
                    "cb_enemy_tweaks_packmaster_spawns_idling_enabled",
                    "cb_enemy_tweaks_ratling_spawns_idling_enabled",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_enemy_tweaks_specials_idle_time",
                    "cb_enemy_tweaks_gutter_runner_spawns_idling_enabled",
                    "cb_enemy_tweaks_globadier_spawns_idling_enabled",
                    "cb_enemy_tweaks_packmaster_spawns_idling_enabled",
                    "cb_enemy_tweaks_ratling_spawns_idling_enabled",
                }
            },
        },
    },
    SPECIALS_IDLING_TIME = {
        ["save"]        = "cb_enemy_tweaks_specials_idle_time",
        ["widget_type"] = "slider",
        ["text"]        = "Idling Time (Seconds)",
        ["tooltip"]     = "",
        ["range"]       = { 1, 30 },
        ["default"]     = 3,
    },
    GUTTER_RUNNER_SPAWNS_IDLING_ENABLED = {
        ["save"] = "cb_enemy_tweaks_gutter_runner_spawns_idling_enabled",
        ["widget_type"] = "checkbox",
        ["text"] = "Gutter Runner",
        ["tooltip"] = "Note:\n" .. 
            "Gutter Runner show some unusual/tactical behaviour if only one player is within the Lobby",
        ["value_type"] = "boolean",
        ["default"] = false,
        ["breed_name"] = "skaven_gutter_runner",
    },
    GLOBADIER_SPAWNS_IDLING_ENABLED = {
        ["save"] = "cb_enemy_tweaks_globadier_spawns_idling_enabled",
        ["widget_type"] = "checkbox",
        ["text"] = "Poison Wind Globadier",
        ["tooltip"] = "",
        ["value_type"] = "boolean",
    ["default"] = false,
        ["breed_name"] = "skaven_poison_wind_globadier",
    },
    PACKMASTER_SPAWNS_IDLING_ENABLED = {
        ["save"] = "cb_enemy_tweaks_packmaster_spawns_idling_enabled",
        ["widget_type"] = "checkbox",
        ["text"] = "Packmaster",
        ["tooltip"] = "",
        ["value_type"] = "boolean",
        ["default"] = false,
        ["breed_name"] = "skaven_pack_master",
    },
    RATLING_SPAWNS_IDLING_ENABLED = {
        ["save"] = "cb_enemy_tweaks_ratling_spawns_idling_enabled",
        ["widget_type"] = "checkbox",
        ["text"] = "Ratling",
        ["tooltip"] = "",
        ["value_type"] = "boolean",
        ["default"] = false,
        ["breed_name"] = "skaven_ratling_gunner",
    },
}

-- local SPECIAL_SPAWN_IDLE_TIME = 2
local special_spawn_idle_times = {}

-- Create new Terror event
TerrorEventBlueprints.custom_gutter_warning = {
    {
        "play_stinger",
        stinger_name = "Play_enemy_stormvermin_champion_electric_floor"
    },
}

-- order selected specials to idle a bit after they spawn
Mods.hook.set(mod_name, "ConflictDirector.spawn_unit", function(func, self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, inventory_template, group_data, archetype_index)
    if breed.name == "skaven_gutter_runner" then
        if EnemyTweaks.get(EnemyTweaks.widget_settings.NO_SILENT_ASSASSINS_ENABLED) then
            -- Disable orginal sound
            Breeds.skaven_gutter_runner.combat_spawn_stinger = nil

            -- Trigger terror event
            Managers.state.conflict:start_terror_event("custom_gutter_warning")
        else
            -- use orginal sound
            Breeds.skaven_gutter_runner.combat_spawn_stinger = "enemy_gutterrunner_stinger"
        end
    end
    
    local unit = func(self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, inventory_template, group_data, archetype_index)

    if EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_SPAWN_IDLING_ENABLED) then        
        if unit and breed and EnemyTweaks:breed_enabled(breed.name) then
            local current_time = Managers.time:time("game")
            if breed.special then
                special_spawn_idle_times[unit] = current_time + EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_IDLING_TIME)
            end
            
            for key, value in pairs(special_spawn_idle_times) do
                if not Unit.alive(key) then
                    special_spawn_idle_times[key] = nil
                end
            end
        end
    end

	return unit
end)

-- prevent assassins from jumping
Mods.hook.set(mod_name, "BTPrepareForCrazyJumpAction.run", function(func, self, unit, blackboard, t, dt)
    if EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_SPAWN_IDLING_ENABLED) then  
        if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
            return "failed"
        end
    end

	return func(self, unit, blackboard, t, dt)
end)

Mods.hook.set(mod_name, "BTNinjaHighGroundAction.try_jump", function(func, self, unit, blackboard, t, pos1, force_idle)
    if EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_SPAWN_IDLING_ENABLED) then   
        if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
            return
        end
    end

	return func(self, unit, blackboard, t, pos1, force_idle)
end)

-- order assassins to idle a bit after they TP
-- Mods.hook.set(mod_name, "BTNinjaVanishAction.vanish", function(func, unit, blackboard)
--     if EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_SPAWN_IDLING_ENABLED) then  
--         for key, value in pairs(special_spawn_idle_times) do
--             if not Unit.alive(key) then
--                 special_spawn_idle_times[key] = nil
--             end
--         end

--         local current_time = Managers.time:time("game")

--         special_spawn_idle_times[unit] = current_time + EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_IDLING_TIME)
--     end

-- 	return func(unit, blackboard)
-- end)

--prevents packmaster from attacking and moving
Mods.hook.set(mod_name, "BTPackMasterSkulkAroundAction.run", function(func, self, unit, blackboard, t, dt)
    if EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_SPAWN_IDLING_ENABLED) then   
        if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
            return "failed"
        end
    end

	return func(self, unit, blackboard, t, dt)
end)

--forces ratling to wait
Mods.hook.set(mod_name, "BTRatlingGunnerApproachAction.run", function(func, self, unit, blackboard, t, dt)
    if EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_SPAWN_IDLING_ENABLED) then   
        if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
            return "failed"
        end
    end
    
    return func(self, unit, blackboard, t, dt)
end)

Mods.hook.set(mod_name, "BTAdvanceTowardsPlayersAction.run", function(func, self, unit, blackboard, t, dt)
    if EnemyTweaks.get(EnemyTweaks.widget_settings.SPECIALS_SPAWN_IDLING_ENABLED) then   
        if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
            return "failed"
        end
    end
    
    return func(self, unit, blackboard, t, dt)
end)

---Check whether this special
---@param self table
---@param breed_name string
---@return boolean
EnemyTweaks.breed_enabled = function (self, breed_name)
    for _, widget in pairs(self.widget_settings) do
        if widget.breed_name == breed_name then
            return self.get(widget)
        end
    end

    return false
end

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
EnemyTweaks.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Creates widgets under mod settings
---@param self table
EnemyTweaks.create_options = function(self)
    local group = "tweaks"
	Mods.option_menu:add_group(group, "Gameplay Tweaks")
    Mods.option_menu:add_item(group, self.widget_settings.NO_SILENT_ASSASSINS_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.SPECIALS_SPAWN_IDLING_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.SPECIALS_IDLING_TIME)
    Mods.option_menu:add_item(group, EnemyTweaks.widget_settings.GUTTER_RUNNER_SPAWNS_IDLING_ENABLED)
    Mods.option_menu:add_item(group, EnemyTweaks.widget_settings.PACKMASTER_SPAWNS_IDLING_ENABLED)
    Mods.option_menu:add_item(group, EnemyTweaks.widget_settings.GLOBADIER_SPAWNS_IDLING_ENABLED)
    Mods.option_menu:add_item(group, EnemyTweaks.widget_settings.RATLING_SPAWNS_IDLING_ENABLED)
end

EnemyTweaks:create_options()
