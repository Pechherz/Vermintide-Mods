-- StatusSystem.rpc_status_change_bool = function (self, sender, status_id, status_bool, game_object_id, other_object_id)
-- 	local unit = self.unit_storage:unit(game_object_id)

-- 	if not unit or not Unit.alive(unit) then
-- 		return
-- 	end

-- 	local other_unit = self.unit_storage:unit(other_object_id)
-- 	local status_ext = ScriptUnit.extension(unit, "status_system")
-- 	local status = NetworkLookup.statuses[status_id]
-- 	local level = LevelHelper:current_level(self.world)

-- 	if status == "pushed" then
-- 		status_ext:set_pushed(status_bool)
-- 	elseif status == "pounced_down" then
-- 		status_ext:set_pounced_down(status_bool, other_unit)
-- 	elseif status == "dead" then
-- 		status_ext:set_dead(status_bool)
-- 	elseif status == "knocked_down" then
-- 		status_ext:set_knocked_down(status_bool)
-- 	elseif status == "revived" then
-- 		status_ext:set_revived(status_bool, other_unit)
-- 	elseif status == "catapulted" then
-- 		status_ext:set_catapulted(status_bool)
-- 	elseif status == "pack_master_pulling" then
-- 		status_ext:set_pack_master("pack_master_pulling", status_bool, other_unit)
-- 	elseif status == "pack_master_dragging" then
-- 		status_ext:set_pack_master("pack_master_dragging", status_bool, other_unit)
-- 	elseif status == "pack_master_hoisting" then
-- 		status_ext:set_pack_master("pack_master_hoisting", status_bool, other_unit)
-- 	elseif status == "pack_master_hanging" then
-- 		status_ext:set_pack_master("pack_master_hanging", status_bool, other_unit)
-- 	elseif status == "pack_master_dropping" then
-- 		status_ext:set_pack_master("pack_master_dropping", status_bool, other_unit)
-- 	elseif status == "pack_master_released" then
-- 		status_ext:set_pack_master("pack_master_released", status_bool, other_unit)
-- 	elseif status == "pack_master_unhooked" then
-- 		status_ext:set_pack_master("pack_master_unhooked", status_bool, other_unit)
-- 	elseif status == "crouching" then
-- 		status_ext:set_crouching(status_bool)
-- 	elseif status == "pulled_up" then
-- 		status_ext:set_pulled_up(status_bool, other_unit)
-- 	elseif status == "ladder_climbing" then
-- 		local ladder_unit = Level.unit_by_index(level, other_object_id)

-- 		status_ext:set_is_on_ladder(status_bool, ladder_unit)
-- 	elseif status == "ledge_hanging" then
-- 		local ledge_unit = Level.unit_by_index(level, other_object_id)

-- 		status_ext:set_is_ledge_hanging(status_bool, ledge_unit)
-- 	elseif status == "ready_for_assisted_respawn" then
-- 		local flavour_unit = Level.unit_by_index(level, other_object_id)

-- 		status_ext:set_ready_for_assisted_respawn(status_bool, flavour_unit)
-- 	elseif status == "assisted_respawning" then
-- 		status_ext:set_assisted_respawning(status_bool, other_unit)
-- 	elseif status == "respawned" then
-- 		status_ext:set_respawned(status_bool)
-- 	elseif status == "overchage_exploding" then
-- 		status_ext:set_overcharge_exploding(status_bool)
-- 	elseif status == "dodging" then
-- 		status_ext:set_is_dodging(status_bool)
-- 	else
-- 		assert("Unhandled status %s", tostring(status))
-- 	end

-- 	if Managers.player.is_server then
-- 		Managers.state.network.network_transmit:send_rpc_clients_except("rpc_status_change_bool", sender, status_id, status_bool, game_object_id, other_object_id)
-- 	end
-- end

-- Mods.hook.set(mod_name, "StatusSystem.rpc_status_change_bool", function(func, self, sender, status_id, status_bool, game_object_id, other_object_id)
--     local log_table = {
--         sender = sender, 
--         status_id = status_id, 
--         status = NetworkLookup.statuses[status_id],
--         status_bool = status_bool, 
--         game_object_id = game_object_id, 
--         other_object_id = other_object_id,
--     }

--     local log_string = Mods.debug:table_to_string(log_table, 2, "log_table")
--     Mods.debug.write_log(log_string)
    
--     func(self, sender, status_id, status_bool, game_object_id, other_object_id)
-- end)