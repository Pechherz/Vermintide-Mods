-- EchoConsole()
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

-- local player_manager_units = Managers.player._players
-- -- Mods.debug.clear_log()
-- -- Mods.debug.write_log(Mods.debug:table_to_string(player_manager, 1, "units"))

-- for key, value in pairs(player_manager_units) do

--     EchoConsole(tostring(value.player_unit))
--     if value.player_unit ~= nil then

--         local locomotion_extension = ScriptUnit.extension(value.player_unit, "locomotion_system")
--         local conflict_director = Managers.state.conflict
--         local position, distance, normal, actor = conflict_director:player_aim_raycast(conflict_director._world, false,
--             "filter_ray_horde_spawn")

--         if position ~= nil and locomotion_extension ~= nil then
--             locomotion_extension.teleport_to(locomotion_extension, position)
--         end
--     end

-- end

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

local conflict_director = Managers.state.conflict
conflict_director.disabled = false
script_data.player_invincible = true
-- script_data.use_super_jumps = not script_data.use_super_jumps

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




-- -- NOTE: Only has an effect on units currently on the world.
-- local world = Managers.world:world("level_world")
-- for _, unit in ipairs(World.units(world)) do
--     Unit.set_unit_visibility(unit, true)
-- end
