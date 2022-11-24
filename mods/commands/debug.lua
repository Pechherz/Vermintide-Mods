-- LevelSettings in matchmaking_manager.lua bots in inn erlauben

Mods.debug.clear_log()
Mods.debug.write_log(Mods.debug:table_to_string(UIAtlasHelper, "UIAtlasHelper", 3))
Mods.debug.write_log(Mods.debug:table_to_string(ui_atlas_settings, "ui_atlas_settings", 3))






-- EchoConsole("Has changed?:" .. tostring(AlternativeItemSpawner:has_custom_category_changed()))



-- EchoConsole(last_message.number_of_repeated_messages)
-- local s_unit = nil
-- local world = Managers.world:world("level_world")
-- local unit_spawner = Managers.state.unit_spawner
-- local node = Unit.node(unit, item_setting.node)

-- s_unit = World.spawn_unit(world, package_name)
-- World.link_unit(world, s_unit, unit, node)
-- equipment_3p_spawned_items[s_unit] = s_unit

-- local i_pos = item_setting.position
-- local pos_offset = i_pos ~= nil and Vector3(i_pos[1], i_pos[2], i_pos[3]) or Vector3(0, 0, 0)
-- Unit.teleport_local_position(s_unit, 0, pos_offset)

-- local i_rot = item_setting.rotation
-- local rot_offset = i_rot ~= nil and Vector3(i_rot[1], i_rot[2], i_rot[3]) or Vector3(0, 0, 0)
-- local rotation = Quaternion.from_euler_angles_xyz(rot_offset[1], rot_offset[2], rot_offset[3])
-- Unit.teleport_local_rotation(s_unit, 0, rotation)

-- Mods.debug.write_log(Mods.debug:table_to_string(Managers.player._human_players, "Managers.player._human_players", 3))

-- Mods.debug.write_log(Mods.debug:table_to_string(AchievementTemplates, "AchievementTemplates", 3))
-- Mods.debug.write_log(Mods.debug:table_to_string(achievement_manager.completed_achievements, "achievement_manager.completed_achievements", 3))
-- Mods.debug.write_log(Mods.debug:table_to_string(achievement_manager.completed_achievements, "achievement_manager.completed_achievements", 3))


-- Mods.debug.write_log(Mods.debug:table_to_string(Managers.player:local_player(), 1, "Managers.player:local_player()"))
-- -- Mods.debug.write_log(Mods.debug:table_to_string(Managers.chat, 1, "Managers.chat"))
-- local local_player_unit = Managers.player:local_player().player_unit
-- local health_extension = ScriptUnit.extension(local_player_unit, "health_system")
-- Mods.debug.write_log(Mods.debug:table_to_string(health_extension, 1, "health_extension"))

-- local damage_extension = ScriptUnit.extension(local_player_unit, "damage_system")
-- Mods.debug.write_log(Mods.debug:table_to_string(damage_extension, 1, "damage_system"))

-- Mods.debug.write_log(Mods.debug:table_to_string(Managers.backend, 1, "Managers.backend"))
-- Mods.debug.write_log(Mods.debug:table_to_string(ItemMasterList, 0, "ItemMasterList"))

-- EchoConsole(health_extension:die())
-- EchoConsole(health_extension:reset())
-- health_extension:reset()
-- health_extension:add_damage(150)
-- EchoConsole(GenericHealthExtension.get_max_health(health_extension))

-- EchoConsole("Red sword and dagger rarity: " .. ItemMasterList.we_dual_wield_sword_dagger_1001.rarity)
-- ItemMasterList.we_dual_wield_sword_dagger_1001.rarity = "common"
-- ItemMasterList.we_dual_wield_sword_dagger_1001.description = "description_exotic_empire_soldier_es_repeating_handgun"

-- local conflict_director = Managers.state.conflict
-- conflict_director.disabled = not conflict_director.disabled

-- EchoConsole("position: " .. tostring(position))
-- EchoConsole("distance: " .. tostring(distance))
-- EchoConsole("normal: " .. tostring(normal))
-- EchoConsole("actor: " .. tostring(actor))



-- script_data.use_super_jumps = not script_data.use_super_jumps
-- script_data.infinite_ammo = not script_data.infinite_ammo

-- Mods.debug.clear_log()
-- Mods.debug.write_log(Mods.debug:table_to_string(Steam, 0, "Steam"))
-- Mods.debug.write_log(Steam.open_overlay_store())



-- local conflict_director = Managers.state.conflict
-- local position, distance, normal, actor = conflict_director:player_aim_raycast(conflict_director._world, false,
--     "filter_ray_projectile")

-- -- Mods.debug.write_log(Mods.debug:table_to_string(position, 3, "position"))

-- EchoConsole(tostring(position))

-- local grenade_templates = {
--     "frag_grenade_t1",
--     "frag_grenade_t2"
-- }


-- Managers.state.network.network_transmit:send_rpc_server(
--     'rpc_spawn_pickup',
--     NetworkLookup.pickup_names[grenade_templates[math.random(1, 2)]],
--     position,
--     Quaternion.axis_angle(Vector3(0, 0, 0), 0),
--     NetworkLookup.pickup_spawn_types['dropped']
-- )

-- local local_peer_id = Network.peer_id()
-- local player_manager = Managers.player
-- local spawn_manager = Managers.state.spawn
-- local conflict_director = Managers.state.conflict
-- local local_player_id = player_manager.next_available_local_player_id(player_manager, local_peer_id)

-- local bot_player = player_manager.add_bot_player(player_manager, "dwarf_ranger", local_peer_id, "default", 3, local_player_id)
-- bot_player.create_game_object(bot_player)
-- EchoConsole("local_player_id: " .. local_player_id)
-- 				-- self._bot_players[local_player_id] = bot_player
-- spawn_manager._bot_players[local_player_id] = bot_player


-- local statuses = spawn_manager._player_statuses
-- local status_slot_index = bot_player.status_slot_index
-- local status = statuses[status_slot_index]
-- local is_initial_spawn = true
-- local profile_synchronizer = spawn_manager._profile_synchronizer
-- local position, distance, normal, actor = conflict_director:player_aim_raycast(conflict_director._world, false, "filter_ray_projectile")
-- profile_synchronizer.set_profile_peer_id(profile_synchronizer, 3, local_peer_id, local_player_id)
-- local rotation = Quaternion.axis_angle(Vector3(0, 0, 0), 0)

-- bot_player.spawn(bot_player, position, rotation, is_initial_spawn, 1, 1, nil, nil, nil)
-- status.spawn_state = "spawned"


-- script_data.ai_bots_disabled = true
-- script_data.debug_player_position = true
-- script_data.debug_player_movementspeed = true
-- -- script_data.debug_player_animations = true
-- -- script_data.debug_first_person_player_animations = true
-- script_data.visualize_ledges = true
-- script_data.buff_debug = true
-- script_data.ledge_hanging_fall_and_die_turned_off = true
-- script_data.debug_enabled = true


-- local grudgeraker = Weapons.grudge_raker_template_1_t3
-- grudgeraker.ammo_data.reload_time = 0.0
-- grudgeraker.shot_count = 20
-- grudgeraker.apply_recoil = false
-- grudgeraker.fire_time = 0.0
-- grudgeraker.active_reload_time = 0.0
-- grudgeraker.max_penetrations = 10
-- grudgeraker.reload_time = 0.0
-- grudgeraker.total_time = 0.0
