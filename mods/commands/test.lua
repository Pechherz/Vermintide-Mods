Mods.debug.clear_log()
Mods.debug.write_log(Mods.debug:table_to_string(AlternativeItemSpawner, "AlternativeItemSpawner", 3))
-- EchoConsole(Application.sysinfo())
-- local local_player_unit = Managers.player:local_player().player_unit
-- local item = "drachenfels_statue"
-- Managers.state.network.network_transmit:send_rpc_server(
--     'rpc_spawn_pickup_with_physics',
--     NetworkLookup.pickup_names[item],
--     Unit.local_position(local_player_unit, 0),
--     Unit.local_rotation(local_player_unit, 0),
--     NetworkLookup.pickup_spawn_types['dropped']
-- )



--Managers.state.game_mode:start_specific_level("dlc_survival_ruins", nil) --> scripts/flow/flow_callback.lua:2084: attempt to perform arithmetic on local 'wave' (a nil value)

-- ConflictUtils.draw_stack_of_balls = function (pos, a, r, g, b)
-- 	QuickDrawer:sphere(pos + Vector3(0, 0, 1), 0.4, Color(a, r, g, b))
-- 	QuickDrawer:sphere(pos + Vector3(0, 0, 1.5), 0.3, Color(a, r * 0.75, g * 0.75, b * 0.75))
-- 	QuickDrawer:sphere(pos + Vector3(0, 0, 2), 0.2, Color(a, r * 0.5, g * 0.5, b * 0.5))
-- 	QuickDrawer:sphere(pos + Vector3(0, 0, 2.5), 0.1, Color(a, r * 0.25, g * 0.25, b * 0.25))
-- end

-- local health_extension = ScriptUnit.extension(player_unit, "health_system")

-- local status_extension = ScriptUnit.extension(player_unit, "status_system")

-- local local_player_unit = Managers.player:local_player().player_unit
-- local health_extension = ScriptUnit.extension(local_player_unit, "health_system")

-- Managers.backend.get_save_data = function(self)
--     return self._save_data
-- end

-- Mods.debug.write_log(Mods.debug:table_to_string(Managers.backend:_get_all_backend_items(), 0,
--     "Managers.backend:_get_loadout()"))

-- for key, value in pairs(ItemMasterList) do
--     if value.rarity == "promo" then
--         Mods.debug.write_log(Mods.debug:table_to_string(value, 2, key))
--     end
-- end


-- all roaming rats are spooked by players and bots
-- Mods.hook.set(mod_name, "BTHesitateAction.run", function(func, self, unit, blackboard, t, dt)
--     return "running"
-- end)


-- local conflict_director = Managers.state.conflict
-- conflict_director.disabled = not conflict_director.disabled






--give promo weapons
-- local item_list = ScriptBackendItem.get_items("witch_hunter", "hat", "unique")
-- Mods.debug.write_log(Mods.debug:table_to_string(item_list, 0, "item_list"))

-- for index, value in pairs(item_list) do
--     local item = ScriptBackendItem.get_item_from_id(value)

--     Mods.debug.write_log(Mods.debug:table_to_string(ItemMasterList[item.key], 0, value))
-- end


-- local tmp = Weapons.handgun_template_1
-- tmp.ammo_data.max_ammo = 2^51

-- tmp.dodge_count = 99
-- -- tmp.buffs.change_dodge_distance.external_optional_multiplier = 0.75
-- -- tmp.buffs.change_dodge_speed.external_optional_multiplier = 1.5

-- tmp.ammo_data.ammo_per_reload = 8
-- tmp.ammo_data.ammo_per_clip = 8
-- tmp.ammo_data.play_reload_anim_on_wield_reload = false

-- tmp.actions.action_one.default.apply_recoil = false
-- tmp.actions.action_two.default.can_abort_reload = true
-- tmp.action_one.default.total_time = 0.66 * 0.2

-- local mod_name = "test"

-- Mods.hook.set(mod_name, "AISystem.update_brains ", function(func, self, ...)
--     func(self, ...)
--     return
-- end)


-- local stored_lobby_data = lobby:get_stored_lobby_data()

-- local matchmaking_manager = Managers.matchmaking
-- matchmaking_manager.set_status_message("test")

-- NOTE: Only has an effect on units currently on the world.

-- local world = Managers.world:world("level_world")
-- for _, unit in ipairs(World.units(world)) do
--     Unit.set_unit_visibility(unit, true)
-- end

-- Mods.debug.clear_log()
-- Mods.debug.write_log(Mods.debug:table_to_string(Steam, 3, "Steam"))
-- Mods.debug.write_log(Mods.debug:table_to_string(Managers.player, 2, "Managers.player"))



-- for key, value in pairs(player_manager._human_players) do
--     EchoConsole(tostring(value.peer_id) .. " " .. Steam.user_name(value.peer_id))
--     EchoConsole(tostring(value.peer_id) .. " " .. Steam.user_country_code(value.peer_id))
-- end

-- local local_player = Managers.player:local_player()
-- local network_manager = Managers.state.network
-- local self_game_object_id = network_manager:unit_game_object_id(local_player.player_unit)

-- local locomotion_extension = ScriptUnit.extension(local_player.player_unit, "locomotion_system")
-- local status_extension = ScriptUnit.extension(local_player.player_unit, "status_system")



-- -- local log_string = Mods.debug:table_to_string(status_extension, 2, "status_extension")
-- Mods.debug.write_log(log_string)

-- status_extension.rpc_status_change_bool("110000109511b5d", 21, false, self_game_object_id, self_game_object_id)

--pull up hanging player
-- StatusUtils.set_pulled_up_network(local_player.player_unit, true, local_player.player_unit)

--knock down player
-- StatusUtils.set_knocked_down_network(local_player.player_unit, true)
-- StatusUtils.set_knocked_down_network(local_player.player_unit, not status_extension.knocked_down)
-- StatusUtils.set_knocked_down_network(local_player.player_unit, not status_extension.knocked_down)


-- local local_player = Managers.player:local_player()
-- local locomotion_extension = ScriptUnit.extension(local_player.player_unit, "locomotion_system")
-- locomotion_extension.teleport_to(locomotion_extension, Vector3(-124, -141, -27))
        

-- local conflict_director = Managers.state.conflict
-- conflict_director.disabled = true


-- Managers.state.debug:set_time_scale(10)

-- Breeds.skaven_rat_ogre.run_speed = 1000
-- Breeds.skaven_clan_rat.weapon_reach = 10
-- Breeds.skaven_clan_rat.run_speed = 100

-- Breeds.skaven_clan_rat.has_running_attack = false
-- Breeds.skaven_clan_rat.default_inventory_template = "loot_rat_sack"
-- Breeds.skaven_clan_rat.default_inventory_templatebase_unit = "units/beings/enemies/skaven_loot_rat/chr_skaven_loot_rat"

-- Breeds.skaven_storm_vermin.default_inventory_template = "default"
-- Breeds.skaven_storm_vermin.aoe_height = 1.0
-- Breeds.skaven_storm_vermin.base_unit = "units/beings/enemies/skaven_clan_rat/chr_skaven_clan_rat"
-- Breeds.skaven_storm_vermin.hit_zones = Breeds.skaven_clan_rat.hit_zones







-- Breeds.skaven_slave.base_unit = "units/beings/enemies/skaven_gutter_runner/chr_skaven_gutter_runner"
-- Breeds.skaven_slave.behavior = "storm_vermin"
-- Breeds.skaven_slave.unit_template = "ai_unit_storm_vermin"
-- Breeds.skaven_slave.hit_zones = Breeds.skaven_storm_vermin.hit_zones

-- Breeds.skaven_rat_ogre.base_unit = "units/beings/enemies/skaven_rat_ogre/chr_skaven_rat_ogre"

-- Weapons.fireball.right_hand_unit = "units/weapons/player/wpn_fireball/wpn_fireball"

-- local last_spawned_unit = Managers.state.conflict:last_spawned_unit()

-- local unit_string = Mods.debug:table_to_string(last_spawned_unit, 1, "last_spawned_unit")
-- Mods.debug.write_log("Is alive: " .. tostring(last_spawned_unit == nil))
-- Mods.debug.write_log(unit_string)


-- StatusUtils.set_dead_network(local_player.player_unit, true)

-- EchoConsole(Steam.user_country_code("110000109511b5d"))
-- Mods.debug.write_log(Steam.user_country_code())
-- GameSettingsDevelopment.show_fps = true
-- GameSettingsDevelopment.help_screen_enabled = false
-- GameSettingsDevelopment.network_revision_check_enabled = true
-- GameSettingsDevelopment.simple_first_person = true
-- GameSettingsDevelopment.disable_shadow_lights_system = false
-- GameSettingsDevelopment.beta = false

-- script_data.hide_fps = false
-- script_data.debug_enabled = true
-- script_data.networked_flow_state_debug = true
-- script_data.network_debug = false
-- script_data.network_debug_connections = true
-- script_data.debug_interactions = true
-- script_data.package_debug = true
-- script_data.debug_behaviour_trees = true
-- script_data.matchmaking_debug = true
-- script_data.use_tech_telemetry = true
-- script_data.use_telemetry = true
-- script_data.extrapolation_debug = true
-- script_data.debug_voip = true
        

