-- local mod_name = "test"

-- Mods.hook.set(mod_name, "DialogueSystem.on_add_extension",
--     function(func, self, world, unit, extension_name, extension_init_data)
--         local extension = {
--             user_memory = {},
--             context = {
--                 health = 1
--             },
--             local_player = extension_init_data.local_player
--         }
--         local dialogue_system = self
--         local input = MakeTableStrict({
--             trigger_dialogue_event = function(self, event_name, event_data, identifier)
--                 if not dialogue_system.is_server then
--                     return
--                 end

--                 local input_event_queue = dialogue_system.input_event_queue
--                 local input_event_queue_n = dialogue_system.input_event_queue_n
--                 input_event_queue[input_event_queue_n + 1] = unit
--                 input_event_queue[input_event_queue_n + 2] = event_name
--                 input_event_queue[input_event_queue_n + 3] = event_data
--                 input_event_queue[input_event_queue_n + 4] = identifier or ""
--                 dialogue_system.input_event_queue_n = input_event_queue_n + 4

--                 -- Mods.debug.write_log("event_name: " ..
--                 --     event_name .. "\n" .. Mods.debug:table_to_string(event_data, 3, "event_data") .. "\n")
--             end,
--             trigger_networked_dialogue_event = function(self, event_name, event_data, identifier)
--                 if LEVEL_EDITOR_TEST then
--                     return
--                 end

--                 if dialogue_system.is_server then
--                     local input_event_queue = dialogue_system.input_event_queue
--                     local input_event_queue_n = dialogue_system.input_event_queue_n
--                     input_event_queue[input_event_queue_n + 1] = unit
--                     input_event_queue[input_event_queue_n + 2] = event_name
--                     input_event_queue[input_event_queue_n + 3] = event_data
--                     input_event_queue[input_event_queue_n + 4] = identifier or ""
--                     dialogue_system.input_event_queue_n = input_event_queue_n + 4

--                     return
--                 end

--                 -- Mods.debug.write_log("event_name: " ..
--                 --     event_name .. "\n" .. Mods.debug:table_to_string(event_data, 3, "event_data") .. "\n")

--                 local event_data_array_temp_types = FrameTable.alloc_table()
--                 local event_data_array_temp = FrameTable.alloc_table()
--                 local event_data_array_temp_n = table.table_to_array(event_data, event_data_array_temp)

--                 for i = 1, event_data_array_temp_n, 1 do
--                     local value = event_data_array_temp[i]

--                     if type(value) == "number" then
--                         assert(value % 1 == 0, "Tried to pass non-integer value to dialogue event")
--                         assert(value >= 0, "Tried to send a dialogue data number smaller than zero")

--                         event_data_array_temp[i] = value + 1
--                         event_data_array_temp_types[i] = true

--                         EchoConsole(event_data_array_temp[i])
--                         EchoConsole(event_data_array_temp_types[i])
--                         EchoConsole("\n")
--                     else
--                         local value_id = NetworkLookup.dialogue_event_data_names[value]
--                         event_data_array_temp[i] = value_id
--                         event_data_array_temp_types[i] = false

--                         EchoConsole(event_data_array_temp[i])
--                         EchoConsole(event_data_array_temp_types[i])
--                         EchoConsole("\n")
--                     end
--                 end

--                 local go_id = NetworkUnit.game_object_id(unit)
--                 local event_id = NetworkLookup.dialogue_events[event_name]

--                 fassert(go_id, "No game object id for unit %s.", unit)

--                 local network_manager = Managers.state.network

--                 network_manager.network_transmit:send_rpc_server("rpc_trigger_dialogue_event", go_id, event_id,
--                     event_data_array_temp, event_data_array_temp_types)
--             end,
--             play_voice = function(self, sound_event)
--                 local wwise_source_id = WwiseUtils.make_unit_auto_source(dialogue_system.world, extension.play_unit,
--                     extension.voice_node)

--                 if wwise_source_id ~= extension.wwise_source_id then
--                     extension.wwise_source_id = wwise_source_id
--                     local switch_name = extension.wwise_voice_switch_group
--                     local switch_value = extension.wwise_voice_switch_value

--                     if switch_name and switch_value then
--                         WwiseWorld.set_switch(dialogue_system.wwise_world, switch_name, switch_value, wwise_source_id)
--                         WwiseWorld.set_source_parameter(dialogue_system.wwise_world, wwise_source_id, "vo_center_percent"
--                             , extension.vo_center_percent)
--                     end

--                     if extension.faction == "player" then
--                         WwiseWorld.set_switch(dialogue_system.wwise_world, "husk", NetworkUnit.is_husk_unit(unit),
--                             wwise_source_id)
--                     end
--                 end

--                 return WwiseWorld.trigger_event(dialogue_system.wwise_world, sound_event, wwise_source_id)
--             end,
--             play_voice_debug = function(self, sound_event)
--                 local wwise_source_id = WwiseUtils.make_unit_auto_source(dialogue_system.world, extension.play_unit,
--                     extension.voice_node)
--                 local switch_name = extension.wwise_voice_switch_group
--                 local switch_value = extension.wwise_voice_switch_value

--                 if switch_name and switch_value then
--                     WwiseWorld.set_source_parameter(dialogue_system.wwise_world, wwise_source_id, "vo_center_percent",
--                         extension.vo_center_percent)
--                 end

--                 if extension.faction == "player" then
--                 end

--                 return WwiseWorld.trigger_event(dialogue_system.wwise_world, sound_event, wwise_source_id)
--             end
--         })

--         GarbageLeakDetector.register_object(input, "dialogue_input")

--         extension.input = input

--         self.tagquery_database:add_object_context(unit, "user_memory", extension.user_memory)
--         self.tagquery_database:add_object_context(unit, "user_context", extension.context)

--         if extension_init_data.faction then
--             extension.faction = extension_init_data.faction

--             assert(self.faction_memories[extension_init_data.faction], "No such faction %q",
--                 tostring(extension_init_data.faction))
--             self.tagquery_database:add_object_context(unit, "faction_memory",
--                 self.faction_memories[extension_init_data.faction])

--             extension.faction_memory = self.faction_memories[extension_init_data.faction]
--         end

--         ScriptUnit.set_extension(unit, "dialogue_system", extension, input)

--         self.unit_input_data[unit] = input
--         self.unit_extension_data[unit] = extension

--         if extension_init_data.breed_name then
--             local breed = Breeds[extension_init_data.breed_name]

--             if breed.wwise_voice_switch_group then
--                 extension.wwise_voice_switch_group = breed.wwise_voice_switch_group
--                 extension.wwise_voice_switch_value = breed.wwise_voices[math.random(1, #breed.wwise_voices)]

--                 if script_data.sound_debug then
--                     printf("[DialogueSystem] Spawned breed %s - using switch group '%s' with '%s'",
--                         extension_init_data.breed_name, extension.wwise_voice_switch_group,
--                         extension.wwise_voice_switch_value)
--                 end
--             end

--             if DialogueSettings.breed_types_trigger_on_spawn[extension_init_data.breed_name] and self.is_server then
--                 self.entity_manager:system("surrounding_aware_system"):add_system_event(unit, "enemy_spawn", math.huge,
--                     "breed_type", extension_init_data.breed_name)
--             end
--         elseif extension_init_data.wwise_voice_switch_group ~= nil then
--             extension.wwise_voice_switch_group = extension_init_data.wwise_voice_switch_group
--             extension.wwise_voice_switch_value = extension_init_data.wwise_voice_switch_value
--         end

--         return extension
--     end)
