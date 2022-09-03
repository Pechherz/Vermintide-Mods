local mod_name = "HornblowerPotionHelper"

HornblowerPotionHelper = {
	SETTINGS = {
		ENABLED = {
			["save"] = "cb_hornblower_potion_helper_enabled",
			["widget_type"] = "stepper",
			["text"] = "Enabled",
			["tooltip"] = "Hornblower Potion Helper Enabled\n" ..
				"Higher chance for potions before gate to be speed potions.\n" ..
				"Choose before loading in map.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default second option is enabled. In this case Off
		},
	},
}

--gate point 1: x = 12.3988, y = 4.96342
--gate point 2: x = 16.9348, y = 27.5019
-- local point_1_x = 12.3988
-- local point_1_y = 4.96342
-- local slope = (27.5019 - 4.96342) / (16.9348 - 12.3988)

local mod = HornblowerPotionHelper

local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings

HornblowerPotionHelper.create_options = function()
	Mods.option_menu:add_group("hornblower", "Hornblower Potion Helper")

	Mods.option_menu:add_item("hornblower", mod.SETTINGS.ENABLED, true)
end

local str_to_spd_chance = 0.66
local spd_to_str_chance = 0.5

Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, ...)
	func(self, ...)

	safe_pcall(function()
		if Managers.player.is_server and get(mod.SETTINGS.ENABLED) then
			local level_id = LevelHelper:current_level_settings().level_id

			if level_id == "magnus" then
				if self.hornblower_potions_next_round_start == nil then
					self.hornblower_potions_next_round_start = true
				end

				local game_mode_manager = Managers.state.game_mode
				if game_mode_manager then
					local round_started = game_mode_manager.is_round_started(game_mode_manager)

					if not round_started then
						if self.hornblower_potions_next_round_start then
							local unit_storage = (Managers and Managers.state and Managers.state.unit_spawner.unit_storage) or false

							if unit_storage then
								local items = unit_storage.map_goid_to_unit
								local num_str_potions_switched = 0

								for go_id, unit in pairs(items) do
									if ScriptUnit.has_extension(unit, "pickup_system") then
										local pickup_system = ScriptUnit.extension(unit, "pickup_system")
										local pickup_name = pickup_system.pickup_name
										local pickup_x = POSITION_LOOKUP[unit].x
										local pickup_y = POSITION_LOOKUP[unit].y
										local pickup_z = POSITION_LOOKUP[unit].z

										-- Approximately before gate
										if pickup_name and pickup_name == "damage_boost_potion" and pickup_x < 15 and math.random() < str_to_spd_chance then
											if not Managers.state.unit_spawner:is_marked_for_deletion(unit) then
													Managers.state.unit_spawner:mark_for_deletion(unit)
											end
											
											Managers.state.network.network_transmit:send_rpc_server(
												"rpc_spawn_pickup",
												-- "rpc_spawn_pickup_with_physics",
												NetworkLookup.pickup_names["speed_boost_potion"],
												Vector3(pickup_x, pickup_y, pickup_z),
												Unit.world_rotation(unit, 0),
												NetworkLookup.pickup_spawn_types.dropped
											)
											
											num_str_potions_switched = num_str_potions_switched + 1
										end
									end
								end
								
								local num_spd_potions_switched = 0
								
								for go_id, unit in pairs(items) do
									if ScriptUnit.has_extension(unit, "pickup_system") then
										local pickup_system = ScriptUnit.extension(unit, "pickup_system")
										local pickup_name = pickup_system.pickup_name
										local pickup_x = POSITION_LOOKUP[unit].x
										local pickup_y = POSITION_LOOKUP[unit].y
										local pickup_z = POSITION_LOOKUP[unit].z
										
										-- Approximately after gate
										if pickup_name and pickup_name == "speed_boost_potion" and pickup_x > 15 and math.random() < spd_to_str_chance and num_spd_potions_switched < num_str_potions_switched then
											if not Managers.state.unit_spawner:is_marked_for_deletion(unit) then
													Managers.state.unit_spawner:mark_for_deletion(unit)
											end
											
											Managers.state.network.network_transmit:send_rpc_server(
												"rpc_spawn_pickup",
												-- "rpc_spawn_pickup_with_physics",
												NetworkLookup.pickup_names["damage_boost_potion"],
												Vector3(pickup_x, pickup_y, pickup_z),
												Unit.world_rotation(unit, 0),
												NetworkLookup.pickup_spawn_types.dropped
											)
											
											num_spd_potions_switched = num_spd_potions_switched + 1
										end
									end
								end
								self.hornblower_potions_next_round_start = false
							end
						end
					else
						self.hornblower_potions_next_round_start = true
					end
				end
			end
		end
	end)
end)

mod.create_options()
