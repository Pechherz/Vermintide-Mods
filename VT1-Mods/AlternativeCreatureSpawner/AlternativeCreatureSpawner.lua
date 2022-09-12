local mod_name = "AlternativeCreatureSpawner"
local oi = OptionsInjector

--allow spawning in the inn/ prevent crash in the inn
--allow setting health and other attributes, default e.g.
--ConflictDirector.destroy_unit

AlternativeCreatureSpawner = {}
AlternativeCreatureSpawner.breeds = {
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
AlternativeCreatureSpawner.breed_index = 1
AlternativeCreatureSpawner.spawn_multiplier = 1

AlternativeCreatureSpawner.widget_settings = {
    CREATURE_SPAWNER_ENABLED = {
        ["save"] = "cb_alternative_creature_spawner_enabled",
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
                    "cb_alternative_creature_spawner_next_creature",
                    "cb_alternative_creature_spawner_previous_creature",
                    "cb_alternative_creature_spawner_increase_multiplier",
                    "cb_alternative_creature_spawner_decrease_multiplier",
                    "cb_alternative_creature_spawner_spawn_creature",
                    "cb_alternative_creature_spawner_kill_all_creatures",
                    "cb_alternative_creature_spawner_kill_last_creature",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_alternative_creature_spawner_next_creature",
                    "cb_alternative_creature_spawner_previous_creature",
                    "cb_alternative_creature_spawner_increase_multiplier",
                    "cb_alternative_creature_spawner_decrease_multiplier",
                    "cb_alternative_creature_spawner_spawn_creature",
                    "cb_alternative_creature_spawner_kill_all_creatures",
                    "cb_alternative_creature_spawner_kill_last_creature",
                }
            },
        },
    },
    NEXT_CREATURE = {
        ["save"] = "cb_alternative_creature_spawner_next_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Next Creature",
        ["default"] = {
            "numpad 6",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "next_creature" },
    },
    PREVIOUS_CREATURE = {
        ["save"] = "cb_alternative_creature_spawner_previous_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Previous Creature",
        ["default"] = {
            "numpad 4",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "previous_creature" },
    },
    INCREASE_SPAWN_MULTIPLIER = {
        ["save"] = "cb_alternative_creature_spawner_increase_multiplier",
        ["widget_type"] = "keybind",
        ["text"] = "Increase Spawn Multiplier",
        ["default"] = {
            "numpad +",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "increase_spawn_multiplier" },
    },
    DECREASE_SPAWN_MULTIPLIER = {
        ["save"] = "cb_alternative_creature_spawner_decrease_multiplier",
        ["widget_type"] = "keybind",
        ["text"] = "Decrease Spawn Multiplier",
        ["default"] = {
            "num -",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "decrease_spawn_multiplier" },
    },
    SPAWN_CREATURE = {
        ["save"] = "cb_alternative_creature_spawner_spawn_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Spawn Creature(s)",
        ["default"] = {
            "numpad 5",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "spawn_creature" },
    },
    KILL_ALL_CREATURES = {
        ["save"] = "cb_alternative_creature_spawner_kill_all_creatures",
        ["widget_type"] = "keybind",
        ["text"] = "Kill All Creatures",
        ["default"] = {
            "numpad *",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "kill_all_creatures" },
    },
    KILL_LAST_CREATURE = {
        ["save"] = "cb_alternative_creature_spawner_kill_last_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Kill Last Creature",
        ["tooltip"] = "Doesn't work right now",
        ["default"] = {
            "numpad /",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "kill_last_creatures" },
    },
}

---Switch to the next creature
---@param self table
AlternativeCreatureSpawner.next_creature = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then
        if Managers.player.is_server then
            self.breed_index = self.breed_index + 1
            if self.breed_index > #self.breeds then
                self.breed_index = 1
            end

            EchoConsole("Current Creature: " .. self.spawn_multiplier .. "x " .. self.breeds[self.breed_index].text)
            Managers.chat.chat_gui:show_chat()
        end
    end
end

---Switch to the previous creature
---@param self table
AlternativeCreatureSpawner.previous_creature = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then
        if Managers.player.is_server then
            self.breed_index = self.breed_index - 1
            if self.breed_index < 1 then
                self.breed_index = #self.breeds
            end

            EchoConsole("Current Creature: " .. self.spawn_multiplier .. "x " .. self.breeds[self.breed_index].text)
            Managers.chat.chat_gui:show_chat()
        end
    end
end

---Increase the amount of creature, that will be spawned at once
---@param self table
AlternativeCreatureSpawner.increase_spawn_multiplier = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then
        if Managers.player.is_server then
            self.spawn_multiplier = self.spawn_multiplier + 1

            EchoConsole("Current Creature: " .. self.spawn_multiplier .. "x " .. self.breeds[self.breed_index].text)
            Managers.chat.chat_gui:show_chat()
        end
    end
end

---Decrease the amount of creature, that will be spawned at once
---@param self table
AlternativeCreatureSpawner.decrease_spawn_multiplier = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then
        if Managers.player.is_server then
            if self.spawn_multiplier > 1 then
                self.spawn_multiplier = self.spawn_multiplier - 1
            end

            EchoConsole("Current Creature: " .. self.spawn_multiplier .. "x " .. self.breeds[self.breed_index].text)
            Managers.chat.chat_gui:show_chat()
        end
    end

end

---Spawn a creature, that is currently choosen
---@param self table
AlternativeCreatureSpawner.spawn_creature = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then
        if Managers.player.is_server then

            local creature_name = self.breeds[self.breed_index].value
            if "skaven_horde" == creature_name then
                for i = 1, self.spawn_multiplier, 1 do
                    Managers.state.conflict:debug_spawn_horde()
                end
            elseif "skaven_storm_vermin_patrol" == creature_name then
                for i = 1, self.spawn_multiplier, 1 do
                    Managers.state.conflict:debug_spawn_group(0)
                end
            else
                for i = 1, self.spawn_multiplier, 1 do
                    Managers.state.conflict:aim_spawning(Breeds[creature_name], false)
                end
            end

            local conflict_director = Managers.state.conflict
            local position, distance, normal, actor = conflict_director:player_aim_raycast(conflict_director._world,
                false, "filter_ray_horde_spawn")

            if position ~= nil then
                EchoConsole(self.spawn_multiplier .. "x " .. self.breeds[self.breed_index].text .. " were spawned")
                Managers.chat.chat_gui:show_chat()
            end
        end
    end

end

---Remove all creatures, that are currently alive and roaming the level
---@param self table
AlternativeCreatureSpawner.kill_all_creatures = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then
        if Managers.player.is_server then
            Managers.state.conflict:destroy_all_units()
        else
            safe_pcall(function()
                local unit_spawner = Managers.state.spawn.unit_spawner
                local units = unit_spawner.unit_storage.map_goid_to_unit

                for _, unit in pairs(units) do
                    -- Check unit is a breed
                    if Unit.has_data(unit, "breed") then
                        -- Repeat damage to fully kill all enemies
                        for x = 1, 10 do
                            DamageUtils.add_damage_network(
                                unit,
                                unit,
                                200, -- Max damage you can do per hit
                                "full",
                                "burninating",
                                Vector3(0, 0, 0),
                                "bw_skullstaff_beam_0048",
                                nil
                            )
                        end
                    end
                end
            end)
        end

        EchoConsole("Removed all enemies")
        Managers.chat.chat_gui:show_chat()
    end
end

---Removes the last creature, that has been spawned
---@param self table
AlternativeCreatureSpawner.kill_last_creatures = function(self)
    Managers.state.conflict:last_spawned_unit()
end

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
AlternativeCreatureSpawner.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Creates widgets under mod settings
---@param self table
AlternativeCreatureSpawner.create_options = function(self)
    local group = "cheats"
    Mods.option_menu:add_group(group, "Gameplay Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.CREATURE_SPAWNER_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.NEXT_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.PREVIOUS_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.INCREASE_SPAWN_MULTIPLIER)
    Mods.option_menu:add_item(group, self.widget_settings.DECREASE_SPAWN_MULTIPLIER)
    Mods.option_menu:add_item(group, self.widget_settings.SPAWN_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.KILL_ALL_CREATURES)
    --Mods.option_menu:add_item(group, self.widget_settings.KILL_LAST_CREATURE)
end

AlternativeCreatureSpawner:create_options()