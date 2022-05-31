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