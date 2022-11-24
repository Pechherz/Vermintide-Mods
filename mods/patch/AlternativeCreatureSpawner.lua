local mod_name = "AlternativeCreatureSpawner"
local oi = OptionsInjector

--todo:
--allow creatures within the inn

AlternativeCreatureSpawner = {}
AlternativeCreatureSpawner.breeds = {
    {
        id = "critter_pig",
        value = "Pig",
    },
    {
        id = "critter_rat",
        value = "Critter Rat",
    },
    {
        id = "skaven_slave",
        value = "Slave Rat",
    },
    {
        id = "skaven_clan_rat",
        value = "Clan Rat",
    },
    {
        id = "skaven_storm_vermin",
        value = "Storm Vermin",
    },
    {
        id = "skaven_storm_vermin_patrol",
        value = "Storm Vermin Patrol",
    },
    {
        id = "skaven_horde",
        value = "Slave Rat Horde",
    },
    {
        id = "skaven_storm_vermin_commander",
        value = "Storm Vermin Commander",
    },
    {
        id = "skaven_gutter_runner",
        value = "Gutter Runner",
    },
    {
        id = "skaven_gutter_runner_decoy",
        value = "Gutter Runner (Decoy)",
    },
    {
        id = "skaven_pack_master",
        value = "Packmaster",
    },
    {
        id = "skaven_ratling_gunner",
        value = "Ratling Gunner",
    },
    {
        id = "skaven_poison_wind_globadier",
        value = "Poison Wind Globadier",
    },
    {
        id = "skaven_rat_ogre",
        value = "Rat Ogre",
    },
    {
        id = "skaven_loot_rat",
        value = "Sack Rat",
    },
    {
        id = "skaven_storm_vermin_champion",
        value = "Storm Vermin Boss (Krench)",
    },
    {
        id = "skaven_grey_seer",
        value = "Grey Seer (Rasknitt)",
    },
}
AlternativeCreatureSpawner.breed_index = 1
AlternativeCreatureSpawner.spawn_multiplier = 1
AlternativeCreatureSpawner.ai_disabled = false

AlternativeCreatureSpawner.widget_settings = {
    SUB_GROUP = {
        ["save"] = "cb_alternative_creature_subgroup",
        ["widget_type"] = "dropdown_checkbox",
        ["text"] = "Alternative Creature Spawner",
        ["tooltip"] = "",
        ["default"] = false,
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = {
                    "cb_alternative_creature_spawner_enabled",
                    "cb_alternative_creature_spawner_next_creature",
                    "cb_alternative_creature_spawner_previous_creature",
                    "cb_alternative_creature_spawner_increase_multiplier",
                    "cb_alternative_creature_spawner_decrease_multiplier",
                    "cb_alternative_creature_spawner_toggle_ai",
                    "cb_alternative_creature_spawner_toggle_conflict_director",
                    "cb_alternative_creature_spawner_spawn_creature",
                    "cb_alternative_creature_spawner_kill_all_creatures",
                    "cb_alternative_creature_spawner_kill_last_creature",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_alternative_creature_spawner_enabled",
                    "cb_alternative_creature_spawner_next_creature",
                    "cb_alternative_creature_spawner_previous_creature",
                    "cb_alternative_creature_spawner_increase_multiplier",
                    "cb_alternative_creature_spawner_decrease_multiplier",
                    "cb_alternative_creature_spawner_toggle_ai",
                    "cb_alternative_creature_spawner_toggle_conflict_director",
                    "cb_alternative_creature_spawner_spawn_creature",
                    "cb_alternative_creature_spawner_kill_all_creatures",
                    "cb_alternative_creature_spawner_kill_last_creature",
                }
            },
        },
    },
    CREATURE_SPAWNER_ENABLED = {
        ["save"] = "cb_alternative_creature_spawner_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable",
        ["tooltip"] = "",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1, -- Default second option is enabled. In this case Off
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
    TOGGLE_AI = {
        ["save"] = "cb_alternative_creature_spawner_toggle_ai",
        ["widget_type"] = "keybind",
        ["text"] = "Disable AI",
        ["tooltip"] = "Enemy AI\n" ..
            "Toggle the Enemy AI ON and OFF.",
        ["default"] = {
            "p",
            oi.key_modifiers.ALT,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "toggle_ai" },
    },
    TOGGLE_CONFLICT_DIRECTOR = {
        ["save"] = "cb_alternative_creature_spawner_toggle_conflict_director",
        ["widget_type"] = "keybind",
        ["text"] = "Disable Conflict Director",
        ["tooltip"] = "Conflict Director\n" ..
            "Toggle the Conflict Director ON and OFF to prevent the game from spawning all types creatures.",
        ["default"] = {
            "o",
            oi.key_modifiers.ALT,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "toggle_conflict_director" },
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
    KILL_LAST_CREATURE = {
        ["save"] = "cb_alternative_creature_spawner_kill_last_creature",
        ["widget_type"] = "keybind",
        ["text"] = "Kill Last Creature",
        ["tooltip"] = "Doesn't work right now",
        ["default"] = {
            "numpad /",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_creature_spawner_action", "kill_last_creature" },
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

            local creature_name = self.breeds[self.breed_index].value
            local number_of_creatures = self.spawn_multiplier
            self:add_local_system_message("iterate_creatures", creature_name, number_of_creatures)
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

            local creature_name = self.breeds[self.breed_index].value
            local number_of_creatures = self.spawn_multiplier
            self:add_local_system_message("iterate_creatures", creature_name, number_of_creatures)
        end
    end
end

---Increase the amount of creature, that will be spawned at once
---@param self table
AlternativeCreatureSpawner.increase_spawn_multiplier = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then
        if Managers.player.is_server then
            self.spawn_multiplier = self.spawn_multiplier + 1

            local creature_name = self.breeds[self.breed_index].value
            local number_of_creatures = self.spawn_multiplier
            self:add_local_system_message("iterate_creatures", creature_name, number_of_creatures)
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
                
                local creature_name = self.breeds[self.breed_index].value
                local number_of_creatures = self.spawn_multiplier
                self:add_local_system_message("iterate_creatures", creature_name, number_of_creatures)
            end
        end
    end
end

---Turn enemy AI on and off
---@param self table
AlternativeCreatureSpawner.toggle_ai = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then 
        self.ai_disabled = not self.ai_disabled

        self:add_local_system_message("toggle_ai", self.ai_disabled)
    end
end

---Turn enemy spawning on and off
---@param self table
AlternativeCreatureSpawner.toggle_conflict_director = function(self)
    local conflict_director = Managers.state.conflict
    
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then 
        conflict_director.disabled = not conflict_director.disabled

        self:add_local_system_message("toggle_conflict_director", conflict_director.disabled)
    else
        conflict_director.disabled = false
    end
end

---Spawn a creature, that is currently choosen
---@param self table
AlternativeCreatureSpawner.spawn_creature = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then
        local message = ""
        local conflict_director = Managers.state.conflict

        if Managers.player.is_server then
            if  Managers.state.game_mode._level_key == "inn_level" then
                message = "[You can't spawn any creatures within the inn]"
            else
                local breed_id = self.breeds[self.breed_index].id
                if "skaven_horde" == breed_id then
                    for i = 1, self.spawn_multiplier, 1 do
                        conflict_director.horde_spawner:horde()                 
                    end
                elseif "skaven_storm_vermin_patrol" == breed_id then
                    for i = 1, self.spawn_multiplier, 1 do
                        conflict_director:debug_spawn_group(0)
                    end
                else
                    for i = 1, self.spawn_multiplier, 1 do
                        conflict_director:aim_spawning(Breeds[breed_id], false)
                    end
                end

                local position, distance, normal, actor = conflict_director:player_aim_raycast(conflict_director._world, false, "filter_ray_horde_spawn")

                if position ~= nil then
                    message = "spawn_creature"
                else
                    message = "[Invalid spawning location]"
                end
            end
        else
            message = "[In order to spawn creatures, you have to be the host]"
        end

        local creature_name = self.breeds[self.breed_index].value
        local number_of_creatures = self.spawn_multiplier
        self:add_local_system_message(message, creature_name, number_of_creatures)
    end
end

---Removes the last creature, that has been spawned
---@param self table
AlternativeCreatureSpawner.kill_last_creature = function(self)
    if self.get(self.widget_settings.CREATURE_SPAWNER_ENABLED) then 
        local last_spawned_unit = Managers.state.conflict:last_spawned_unit()
        
        if last_spawned_unit then
            local blackboard = Unit.get_data(last_spawned_unit, "blackboard")
            local reason = "ai_despawn" 
            
            Managers.state.conflict:destroy_unit(last_spawned_unit, blackboard, reason)   
            
            local breed_name = self:get_breed_name_by_id(blackboard.breed.name)      
            self:add_local_system_message("despawn_creature", breed_name, 1)
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

        local message = "All creatures were removed"
        self:add_local_system_message(message)
    end
end

--prevents crash when the Grey Seer is spawned
Mods.hook.set(mod_name, "BTTeleportToPortalAction.enter", function(func, self, unit, blackboard, t)
    local mod = AlternativeCreatureSpawner
    if mod.get(mod.widget_settings.CREATURE_SPAWNER_ENABLED) then
        local action_data = self._tree_node.action_data
        local id = action_data.level_portal_id
        local portal_data = blackboard.teleport_portals[id]
    
        if portal_data then
            --if its not passed to the original function, then the grey seer wont ever teleport himself
            func(self, unit, blackboard, t)
        end
    else
        func(self, unit, blackboard, t)
    end
end)

Mods.hook.set(mod_name, "AISystem.update_brains", function (func, self, t, dt)
    local mod = AlternativeCreatureSpawner
    if mod.ai_disabled == false or mod.get(mod.widget_settings.CREATURE_SPAWNER_ENABLED) == false then
        func(self, t, dt)
    end
end)

---Returns the breed name by providing the breed id
---@param self table
---@param breed_id string
---@return string
AlternativeCreatureSpawner.get_breed_name_by_id = function(self, breed_id)
    for _, breed in pairs(self.breeds) do
        if breed.id == breed_id then
            return breed.value
        end
    end

    return "no_breed_name_available"
end

AlternativeCreatureSpawner.message_definitions = {
    iterate_creatures = {
        format_strings = {
            single = "Current Creature: %dx %s",
        },
        format = function (self, previous_message, creature_name, number_of_creatures)
            local message_id = "iterate_creatures"
            local message_template = self.format_strings.single
            return string.format(message_template, number_of_creatures, creature_name), message_id
        end,
    },
    toggle_ai = {
        format_strings = {
            single = "AI Disabled: %s",
        },
        format = function (self, previous_message, ai_disabled)
            local message_template = self.format_strings.single
            local message_id = "toggle_ai"

            return string.format(message_template, ai_disabled), message_id
        end,
    },
    toggle_conflict_director = {
        format_strings = {
            single = "Conflict Director Disabled: %s",
        },
        format = function (self, previous_message, conflict_director_disabled)
            local message_template = self.format_strings.single
            local message_id = "toggle_conflict_director"

            return string.format(message_template, conflict_director_disabled), message_id
        end,
    },
    spawn_creature = {
        format_strings = {
            single = "%dx %s was spawned",
            many = "%dx %s were spawned",
        },
        format = function (self, previous_message, creature_name, number_of_creatures)
            local message_id = "spawn_creature_" .. creature_name

            if previous_message and previous_message.message_id == message_id then
                local i, j = string.find(previous_message.message, "%d+")
                local extracted_number = string.sub(previous_message.message, i, j)
                number_of_creatures = number_of_creatures + (tonumber(extracted_number) or 0)            
            end

            local message_template = number_of_creatures > 1 and self.format_strings.many or self.format_strings.single

            return string.format(message_template, number_of_creatures, creature_name), message_id
        end,
    },
    despawn_creature = {
        format_strings = {
            single = "%dx %s was despawned",
            many = "%dx %s were despawned",
        },
        format = function (self, previous_message, creature_name, number_of_creatures)
            local message_id = "despawn_creature_" .. creature_name
            
            if previous_message and previous_message.message_id == message_id then
                local i, j = string.find(previous_message.message, "%d+")
                local extracted_counter = string.sub(previous_message.message, i, j)
                number_of_creatures = number_of_creatures + (tonumber(extracted_counter) or 0)
            end
            
            local message_template = number_of_creatures > 1 and self.format_strings.many or self.format_strings.single

            return string.format(message_template, number_of_creatures, creature_name), message_id
        end,
    }
}

---Adds local system messages with counter in order to prevent spamming messages into the chat chat box.
---Message defintions allow chat box message to be updated instead of being replaced by a new message.
---@param self table
---@param message string The new message to be appended into the chat box
---@param ... any Values which are passed to the format function of the message defintions
AlternativeCreatureSpawner.add_local_system_message = function (self, message, ...)
    local chat_manager = Managers.chat
    local chat_gui = chat_manager.chat_gui
    local messages = chat_gui.chat_output_widget.content.message_tables
    local previous_message = #messages > 0 and messages[#messages] or {}
    local message_definition = self.message_definitions[message]

    if message_definition then
        local formatted_message, message_id = message_definition:format(previous_message, ...)

        if previous_message.message_id ~= message_id then
            --add a new message and update in order to get the last message
            chat_manager:add_local_system_message(1, "", true)
            chat_gui:_update_chat_messages()
            previous_message = messages[#messages]
            previous_message.message_id = message_id
        end

        previous_message.message = formatted_message
    else
        if previous_message.repeated_message ~= message then
            chat_manager:add_local_system_message(1, message, true)
            chat_gui:_update_chat_messages()
            previous_message = messages[#messages]
            previous_message.repeated_message = message
            previous_message.number_of_repeated_messages = 1
        else
            previous_message.number_of_repeated_messages = previous_message.number_of_repeated_messages + 1
            previous_message.message = previous_message.repeated_message .. " (" .. previous_message.number_of_repeated_messages .. "x)"
        end 
    end
    
    chat_gui:show_chat()
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
    Mods.option_menu:add_group(group, "Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.SUB_GROUP, true)
    Mods.option_menu:add_item(group, self.widget_settings.CREATURE_SPAWNER_ENABLED)
    Mods.option_menu:add_item(group, self.widget_settings.NEXT_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.PREVIOUS_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.INCREASE_SPAWN_MULTIPLIER)
    Mods.option_menu:add_item(group, self.widget_settings.DECREASE_SPAWN_MULTIPLIER)
    Mods.option_menu:add_item(group, self.widget_settings.TOGGLE_AI)
    Mods.option_menu:add_item(group, self.widget_settings.TOGGLE_CONFLICT_DIRECTOR)
    Mods.option_menu:add_item(group, self.widget_settings.SPAWN_CREATURE)
    Mods.option_menu:add_item(group, self.widget_settings.KILL_LAST_CREATURE )
    Mods.option_menu:add_item(group, self.widget_settings.KILL_ALL_CREATURES)
end

AlternativeCreatureSpawner:create_options()
