local mod_name = "AlternativeCreatureSpawner"
local oi = OptionsInjector
local conflict_director = Managers.state.conflict

--allow spawning in the inn/ prevent crash in the inn
--allow setting health and other attributes, default e.g.
--ConflictDirector.destroy_unit

CreatureSpawner = {}
CreatureSpawner.breeds = {
    {
        value = "critter_pig",
        text = "Pig",
    },
    {
        value = "critter_rat",
        text = "Critter Rat",
    },
    {
        value = "skaven_slave",
        text = "Slave Rat",
    },
    {
        value = "skaven_clan_rat",
        text = "Clan Rat",
    },
    {
        value = "skaven_storm_vermin",
        text = "Storm Vermin",
    },
    {
        value = "skaven_storm_vermin_patrol",
        text = "Storm Vermin Patrol",
    },
    {
        value = "skaven_horde",
        text = "Slave Rat Horde",
    },
    {
        value = "skaven_storm_vermin_commander",
        text = "Storm Vermin Commander",
    },
    {
        value = "skaven_gutter_runner",
        text = "Gutter Runner",
    },
    {
        value = "skaven_gutter_runner_decoy",
        text = "Gutter Runner (Decoy)",
    },
    {
        value = "skaven_pack_master",
        text = "Packmaster",
    },
    {
        value = "skaven_ratling_gunner",
        text = "Ratling Gunner",
    },
    {
        value = "skaven_poison_wind_globadier",
        text = "Poison Wind Globadier",
    },
    {
        value = "skaven_rat_ogre",
        text = "Rat Ogre",
    },
    {
        value = "skaven_loot_rat",
        text = "Sack Rat",
    },
    {
        value = "skaven_storm_vermin_champion",
        text = "Storm Vermin Boss (Krench)",
    },
    {
        value = "skaven_grey_seer",
        text = "Grey Seer (Rasknitt)",
    },
}
CreatureSpawner.breed_index = 1
CreatureSpawner.spawn_multiplier = 1

CreatureSpawner.widget_settings = {
    CREATURE_SPAWNER_ENABLED = {
        ["save"] = "cb_creature_spawner_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable Alternative Creature Spawner",
        ["tooltip"] = "Enable Alternative Creature Spawner",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1, -- Default second option is enabled. In this case Off
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = {
                    "cb_creature_spawner_next_creature",
                    "cb_creature_spawner_previous_creature",
                    "cb_creature_spawner_increase_multiplier",
                    "cb_creature_spawner_decrease_multiplier",
                    "cb_creature_spawner_spawn_creature",
                    "cb_creature_spawner_kill_all_creatures",
                    "cb_creature_spawner_kill_last_creature",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_creature_spawner_next_creature",
                    "cb_creature_spawner_previous_creature",
                    "cb_creature_spawner_increase_multiplier",
                    "cb_creature_spawner_decrease_multiplier",
                    "cb_creature_spawner_spawn_creature",
                    "cb_creature_spawner_kill_all_creatures",
                    "cb_creature_spawner_kill_last_creature",
                }
            },
        },
    },
    NEXT_CREATURE = {
        ["save"] = "cb_creature_spawner_next_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Next Creature",
        ["default"] = {
            "numpad 6",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_actions", "next_creature" },
    },
    PREVIOUS_CREATURE = {
        ["save"] = "cb_creature_spawner_previous_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Previous Creature",
        ["default"] = {
            "numpad 4",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_actions", "previous_creature" },
    },
    INCREASE_SPAWN_MULTIPLIER = {
        ["save"] = "cb_creature_spawner_increase_multiplier",
        ["widget_type"] = "keybind",
        ["text"] = "Increase Spawn Multiplier",
        ["default"] = {
            "numpad +",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_actions", "increase_spawn_multiplier" },
    },
    DECREASE_SPAWN_MULTIPLIER = {
        ["save"] = "cb_creature_spawner_decrease_multiplier",
        ["widget_type"] = "keybind",
        ["text"] = "Decrease Spawn Multiplier",
        ["default"] = {
            "num -",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_actions", "decrease_spawn_multiplier" },
    },
    SPAWN_CREATURE = {
        ["save"] = "cb_creature_spawner_spawn_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Spawn Creature(s)",
        ["default"] = {
            "numpad 5",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_actions", "spawn_creature" },
    },
    KILL_CREATURE = {
        ["save"] = "cb_creature_spawner_kill_all_creatures",
        ["widget_type"] = "keybind",
        ["text"] = "Kill All Creatures",
        ["default"] = {
            "numpad *",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_actions", "kill_creatures" },
    },
    KILL_LAST_CREATURE = {
        ["save"] = "cb_creature_spawner_kill_last_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Kill Last Creature",
        ["default"] = {
            "numpad /",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_actions", "kill_last_creatures" },
    },
}

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
CreatureSpawner.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Creates widgets under mod settings
---@param self table
CreatureSpawner.create_options = function(self)
    local group = "cheats"
    Mods.option_menu:add_group(group, "Gameplay Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.CREATURE_SPAWNER_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.NEXT_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.PREVIOUS_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.INCREASE_SPAWN_MULTIPLIER)
    Mods.option_menu:add_item(group, self.widget_settings.DECREASE_SPAWN_MULTIPLIER)
    Mods.option_menu:add_item(group, self.widget_settings.SPAWN_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.KILL_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.KILL_LAST_CREATURE)
end

CreatureSpawner:create_options()
