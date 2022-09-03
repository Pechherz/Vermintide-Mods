local mod = GiveOtherItems
local player_unit = Managers.player:local_player().player_unit
local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
local slot_name = inventory_extension:get_wielded_slot_name()


if Managers.player.is_server then
	if slot_name == "slot_healthkit" or slot_name == "slot_potion" or slot_name == "slot_grenade" then
		local item_template = inventory_extension:get_wielded_slot_item_template()
		local item_name = ""

		if item_template.pickup_data and item_template.pickup_data.pickup_name then
			item_name = item_template.pickup_data.pickup_name
		elseif item_template.is_grimoire then
			item_name = "grimoire"
		end

		-- Remove item
		inventory_extension:destroy_slot(slot_name)

		-- Switch to melee weapon
		inventory_extension:wield("slot_melee")

		-- Spawn item
		Managers.state.network.network_transmit:send_rpc_server(
			'rpc_spawn_pickup_with_physics',
			NetworkLookup.pickup_names[item_name],
			Unit.local_position(player_unit, 0),
			Unit.local_rotation(player_unit, 0),
			NetworkLookup.pickup_spawn_types['dropped']
		)

		-- Feedback
		if mod.get(mod.widget_settings.ECHO) then
			EchoConsole("Dropped " .. item_name)
		end
	end
end
