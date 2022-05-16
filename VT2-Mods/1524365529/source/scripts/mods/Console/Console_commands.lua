local mod = get_mod("Console")

local function toboolean(input) --Simple type translation.
	if input == "1" or input == "true" then return true else return false end
end

local function override_development_parameter_func(parameters)
	local function development_parameter(param)
		return parameters[param]
	end

	Development.parameter = development_parameter
end

--[[List of all console commands, anything with cheat = true will NOT be executed on official realm--]]
mod.ConsoleCommands = {
	echo = {
		tooltip = "Prints an echo message to the chat. [string]",
		cheat = false,
		func = function(var) mod:echo(var) end
	},
	suicide = {
		tooltip = "Kills local player.",
		cheat = false,
		func = function()
				local damage_type = "forced"
				local damage_direction = Vector3(0, 0, 2)
				local status_extension = ScriptUnit.extension(Managers.player:local_player().player_unit, "status_system")
					
				status_extension.wounds = 0
				AiUtils.kill_unit(Managers.player:local_player().player_unit, nil, nil, damage_type, damage_direction)
				end	
	},
	say = {
		tooltip = "Sends a chat message to other players. [string]",
		cheat = false,
		func = function(var) Managers.chat:send_chat_message(1, Managers.player:local_player().peer_id, var) end
	},
	server_name = {
		tooltip = "Get/Set unique server name. [string]",
		tooltipfunc = function() return Managers.matchmaking.lobby:get_stored_lobby_data().unique_server_name  end,
		cheat = false,
		func = function(var)
		local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
		if var == nil then
			--mod:echo(lobby_data.unique_server_name) 
		else
			lobby_data.unique_server_name = var
			Managers.matchmaking.lobby:set_lobby_data(lobby_data)
		end
		end
	},
	list = {
		tooltip = "Print all commands to chat.",
		cheat = false,
		func = function()
		local tabletosort = {}
		
		mod:echo("===CONSOLE COMMAND LIST BEGIN===")
		for index, command in pairs(mod.ConsoleCommands) do 
			table.insert(tabletosort, index)
		end 
		table.sort(tabletosort, function(a, b) return a:lower() < b:lower() end)
		
		for k, v in pairs(tabletosort) do
			local cheatstring = ""
			if mod.ConsoleCommands[v].cheat == true then
				cheatstring = " (CHEAT)" 
			end  
			mod:echo(v .. " - " .. mod.ConsoleCommands[v].tooltip .. cheatstring)
		end		
		mod:echo("===CONSOLE COMMAND LIST END===")
		end
	},
	g_time_scale = {
		tooltip = "Set percentage game time scale. [integer]",
		tooltipfunc = function() return GLOBAL_TIME_SCALE end,
		cheat = true,
		func = function(var)
			local time_scale_value = tonumber(var)
			local time_scale_index = table.find(Managers.state.debug.time_scale_list, time_scale_value)			
			Managers.state.debug.set_time_scale(Managers.state.debug, time_scale_index)		
		end
	},
	g_gravity = {
		tooltip = "Set world gravity. [float]",
		tooltipfunc = function() return PlayerUnitMovementSettings.get_movement_settings_table(Managers.player:local_player().player_unit).gravity_acceleration / -1.120162932790224  end,
		cheat = true,
		func = function(var)
			local world = Managers.world:world("level_world")
			local physics_world = World.get_data(world, "physics_world")
			local players = Managers.player:players()
			
			for id, player in pairs(players) do
				local units_player_movement_setting = PlayerUnitMovementSettings.get_movement_settings_table(player.player_unit)
				
				units_player_movement_setting.gravity_acceleration = tonumber(var) * -1.120162932790224
			end
			physics_world.set_gravity(physics_world,Vector3(0,0,tonumber(var)))
		end
	},
	map = {
		tooltip = "Load a level.",
		tooltipfunc = function() return LevelSettings.Managers.state.game_mode:level_key()  end,
		cheat = true,
		func = function(var) mod.ConsoleVisible = false Managers.state.game_mode:start_specific_level(var) end
	},
	gm_difficulty = {
		tooltip = "Set game mode difficulty. [normal/hard/harder/hardest]",
		tooltipfunc = function() return Managers.state.difficulty.difficulty end,
		cheat = true,
		func = function(var) Managers.state.difficulty:set_difficulty(var) end
	},
	gm_allow_bots = {
		tooltip = "Allow or disallow bots from spawning in game. [boolean]",
		tooltipfunc = function() return tostring(not LevelSettings[Managers.state.game_mode:level_key()].no_bots_allowed) end,
		cheat = true,
		func = function(var)
		
		LevelSettings[Managers.state.game_mode:level_key()].no_bots_allowed = not toboolean(var) 
		if  toboolean(var) == false then 
		for local_player_id, player in pairs(Managers.state.spawn._bot_players) do
			player:despawn()
		end		
			Managers.state.spawn:_clear_bots()
		end
		end		
	},
	player_hero = {
		tooltip = "Set player hero index. [1-Saltzpyre/2-Sienna/3-Bardin/4-Kerilian/5-Kruber]",
		tooltipfunc = function() return Managers.player:local_player():profile_index() end,
		cheat = true,
		func = function(var)
		local peer_id = Managers.player:local_player().peer_id
		local player = Managers.player:player_from_peer_id(peer_id)

		if player.player_unit then

			Managers.state.spawn:delayed_despawn(player)
			if Managers.player.is_server then
					Managers.state.network.network_server:peer_despawned_player(peer_id)
			end			
--		else
			Managers.state.network.profile_synchronizer:request_select_profile(tonumber(var), player:local_player_id())
		end
		
		if Managers.player.is_server then
			Managers.state.network.network_server:peer_respawn_player(peer_id)
		else
			Managers.state.network.network_transmit:send_rpc_server("rpc_client_respawn_player")
		end		

--		local hero_attributes = Managers.backend:get_interface("hero_attributes")
--		local profile_settings = SPProfiles[tonumber(var)]
--		local career_settings = profile_settings.careers[1]
--		local hero_name = profile_settings.display_name		

--		hero_attributes:set(hero_name, "career", 1)		
		end
	},
	player_career = {
		tooltip = "Set player career index. [integer]",
		tooltipfunc = function() return Managers.player:local_player():career_index() end,
		cheat = true,
		func = function(var)
		local player = Managers.player:local_player()
		local player_unit = player.player_unit

		if player.player_unit then

			Managers.state.spawn:delayed_despawn(player)

		end

		local profile_settings = SPProfiles[Managers.player:local_player():profile_index()]
		local hero_attributes = Managers.backend:get_interface("hero_attributes")
		local hero_name = profile_settings.display_name

		hero_attributes:set(hero_name, "career", tonumber(var))

		local peer_id = Managers.player:local_player().peer_id
		if Managers.player.is_server then
			Managers.state.network.network_server:peer_despawned_player(peer_id)
			Managers.state.network.network_server:peer_respawn_player(peer_id)
		else
			Managers.state.network.network_transmit:send_rpc_server("rpc_client_respawn_player")
		end		
		
		Managers.state.network.profile_synchronizer:resync_loadout(Managers.player:local_player():profile_index(), tonumber(var), player)			
		end
	},
	quit = {
		tooltip = "Alt F4 with extra steps",
		cheat = false,
		func = function() Application.quit() end	
	},
	server_kick = {
		tooltip = "Kick player from session. [PlayerID]",
		cheat = true,
		func = function(var) Managers.state.network.network_server:kick_peer(var) mod:chat_broadcast(Steam.user_name(var) .. " Has been kicked!") end	
	},
	players_list = {
		tooltip = "Print player names and IDs to chat.",
		cheat = false,
		func = function() 
		local players = Managers.player:players()

		for id, player in pairs(players) do
			local profile_index = player.profile_index(player)
			local ingame_display_name = (SPProfiles[profile_index] and SPProfiles[profile_index].ingame_short_display_name) or nil
			local localized_display_name = ingame_display_name and Localize(ingame_display_name)
			local equalizer = ""
			
			if localized_display_name == "Kruber" then
				equalizer = "  "
			end
			
			if localized_display_name == "Sienna" then
				equalizer = " "
			end		
			
			if localized_display_name == "Bardin" then
				equalizer = "  "
			end		
			mod:echo(Steam.user_name(player.peer_id) .. " (" .. localized_display_name .. ")" .. equalizer .. " - [" .. player.peer_id .. "]")
		end
		end	
	},
	server_broadcast = {
		tooltip = "Broadcast a system message via chat. [string]",
		cheat = false,
		func = function(var) mod:chat_broadcast(var) end	
	},	
	resource_load_package = {
		tooltip = "Load a resource package. [string]",
		cheat = false,
		func = function(var)
		local packages = Managers.package._packages
		Managers.package:load(var, "console", function() mod:echo("Resource package loaded!") end, true)
		end
	},
	fps_show = {
		tooltip = "Show FPS value. [boolean]",
		tooltipfunc = function() return tostring(GameSettingsDevelopment.show_fps) end,
		cheat = false,
		func = function(var)
		local 	parameters = {
		hide_fps = not toboolean(var),
		}
		override_development_parameter_func(parameters)
		GameSettingsDevelopment.show_fps = toboolean(var)
		end	
	},
	g_pause = {
		tooltip = "Toggle game pause.",
		cheat = true,
		func = function()
		local world = Managers.world:world("level_world")
		local wwise_world = Managers.world:wwise_world(world)

		if not World.get_data(world, "paused") then
			ScriptWorld.pause(world)
			WwiseWorld.pause_all(wwise_world)
		else
			ScriptWorld.unpause(world)
			WwiseWorld.resume_all(wwise_world)
		end
		end	
	},
	g_god = {
		tooltip = "Enable/disable god mode. [boolean]",
		tooltipfunc = function() return tostring(script_data.player_invincible) end,
		cheat = true,
		func = function(var)
		script_data.player_invincible = toboolean(var)
		end	
	},	
	g_infinite_ammo = {
		tooltip = "Enable/disable infinite ammo. [boolean]",
		tooltipfunc = function() return tostring(script_data.infinite_ammo) end,
		cheat = true,
		func = function(var)
		script_data.infinite_ammo = toboolean(var)
		end	
	},
	fps_max = {
		tooltip = "Limit FPS. [integer/0 = disabled]",
		tooltipfunc = function() return tostring(Application.user_setting("max_fps")) end,
		cheat = false,
		func = function(var)
		Application.set_user_setting("max_fps", tonumber(var))
		Application.save_user_settings()
		Framerate.set_playing()		
		end	
	},	
	r_draw_viewmodel = {
		tooltip = "Show first person view model. [boolean]",
		tooltipfunc = function() return tostring(not ScriptUnit.extension(Managers.player:local_player().player_unit, "first_person_system").tutorial_first_person) end,
		cheat = false,
		func = function(var)
		local first_person_extension = ScriptUnit.extension(Managers.player:local_player().player_unit, "first_person_system")
		first_person_extension:tutorial_show_first_person_units(toboolean(var))
		end	
	},		
	hud_draw = {
		tooltip = "Draw HUD. [boolean]",
		cheat = false,
		func = function(var)
		local hudhandle = Managers.player:local_player().network_manager.matchmaking_manager._ingame_ui.ingame_hud
		hudhandle:set_visible(false,false)
		if toboolean(var) then hudhandle.show_hud = false end
		end	
	},
	map_restart = {
		tooltip = "Restart  a level.",
		cheat = true,
		func = function(var) mod.ConsoleVisible = false Managers.state.game_mode:retry_level() end
	},
	list_to_file = {
		tooltip = "Dump all commands to a console_commands.txt in main game folder (file needs to be created manually).",
		cheat = false,
		func = function()
		local tabletosort = {}
		
		local file = io.open("../console_commands.txt", "a+")
		
		if not file then
			mod:echo("console_commands.txt not found in main game folder!")
			return
		end		
		
		for index, command in pairs(mod.ConsoleCommands) do 
			table.insert(tabletosort, index)
		end 
		table.sort(tabletosort, function(a, b) return a:lower() < b:lower() end)
		
		for k, v in pairs(tabletosort) do
			local cheatstring = ""
			if mod.ConsoleCommands[v].cheat == true then
				cheatstring = " (CHEAT)" 
			end
			file:write(v .. " - " .. mod.ConsoleCommands[v].tooltip .. cheatstring .. "\n")			
		end		
		io.close(file)
		end
	},
	inventory_give_item = {
		tooltip = "Add a pickup item to inventory, pass with no parameter to print all pickup names to chat. [string]",
		cheat = true,
		func = function(var)
		
		if var == nil or var == "" then
			mod:echo("===PICKUP LIST BEGIN===")
			local tabletosort = {}
			
			for index, command in pairs(AllPickups) do 
				table.insert(tabletosort, index)
			end 
			table.sort(tabletosort, function(a, b) return a:lower() < b:lower() end)
			
			for k, v in pairs(tabletosort) do
				mod:echo(v)
			end				
			
			mod:echo("===PICKUP LIST END===")
			return
		end
	local player_manager = Managers.player
	local player = player_manager:owner(Managers.player:local_player().player_unit)

	if player then
		local local_bot_or_human = not player.remote
		local player_unit = Managers.player:local_player().player_unit

		if local_bot_or_human then
			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
			local career_extension = ScriptUnit.extension(player_unit, "career_system")
			local pickup_settings = AllPickups[var]
			local slot_name = pickup_settings.slot_name
			local item_name = pickup_settings.item_name
			local slot_data = inventory_extension:get_slot_data(slot_name)

			if slot_data then
				local item_data = slot_data.item_data
				local item_template = BackendUtils.get_item_template(item_data)
				local pickup_item_to_spawn = nil

				if item_template.name == "wpn_side_objective_tome_01" then
					pickup_item_to_spawn = "tome"
				elseif item_template.name == "wpn_grimoire_01" then
					pickup_item_to_spawn = "grimoire"
				end

				if pickup_item_to_spawn then
					local pickup_spawn_type = "dropped"
					local pickup_name_id = NetworkLookup.pickup_names[pickup_item_to_spawn]
					local pickup_spawn_type_id = NetworkLookup.pickup_spawn_types[pickup_spawn_type]
					local position = POSITION_LOOKUP[player_unit]
					local rotation = Unit.local_rotation(player_unit, 0)

					network_transmit:send_rpc_server("rpc_spawn_pickup", pickup_name_id, position, rotation, pickup_spawn_type_id)
				end
			end

			local item_data = ItemMasterList[item_name]
			local unit_template = nil
			local extra_extension_init_data = {}

			inventory_extension:destroy_slot(slot_name)
			inventory_extension:add_equipment(slot_name, item_data, unit_template, extra_extension_init_data)

			local go_id = Managers.state.unit_storage:go_id(player_unit)
			local slot_id = NetworkLookup.equipment_slots[slot_name]
			local item_id = NetworkLookup.item_names[item_name]
			local weapon_skin_id = NetworkLookup.weapon_skins["n/a"]

			if Managers.player.is_server then
				network_transmit:send_rpc_clients("rpc_add_equipment", go_id, slot_id, item_id, weapon_skin_id)
			else
				network_transmit:send_rpc_server("rpc_add_equipment", go_id, slot_id, item_id, weapon_skin_id)
			end

			local wielded_slot_name = inventory_extension:get_wielded_slot_name()

			if wielded_slot_name == slot_name then
				CharacterStateHelper.stop_weapon_actions(inventory_extension, "picked_up_object")
				CharacterStateHelper.stop_career_abilities(career_extension, "picked_up_object")
			end
			inventory_extension:wield(slot_name)
		end
		end
		end
	},
	world_spawn_unit = {
		tooltip = "Spawn an unit in current world. [string]",
		cheat = true,
		func = function(var)
		local world = Managers.world:world("level_world")
		local position = Unit.world_position(Managers.player:local_player().player_unit,0)
		local rotation = Unit.world_rotation(Managers.player:local_player().player_unit,0)
		position = position + Quaternion.forward(rotation) * 3
		rotation = Quaternion.multiply(rotation, Quaternion.look(Quaternion.forward(rotation)))
		World.spawn_unit(world,var,position,rotation)
		end	
	},
	world_show_all_units = {
		tooltip = "Set all units in current world as visible.",
		cheat = true,
		func = function(var)
		local world = Managers.world:world("level_world")
		local world_units = world:units()
		for index, unit in pairs(world_units) do
			Unit.set_unit_visibility( unit, true ) 
		end
		end	
	},	
	noclip = {
		tooltip = "Enable/disable collision with environment. [boolean]",
		tooltipfunc = function() return tostring(not Mover.collides_down(Unit.mover(Managers.player:local_player().player_unit))) end,
		cheat = true,
		func = function(var)
		local mover = Unit.mover(Managers.player:local_player().player_unit)
		if toboolean(var) == true then
			PlayerUnitMovementSettings.get_movement_settings_table(Managers.player:local_player().player_unit).gravity_acceleration = 0
			Mover.set_collision_filter(mover,"default")
		else
			PlayerUnitMovementSettings.get_movement_settings_table(Managers.player:local_player().player_unit).gravity_acceleration = 11
			Mover.set_collision_filter(mover,"filter_player_mover")			
		end
		end	
	},
	ai_notarget = {
		tooltip = "Force AI to ignore the player. [boolean]",
		tooltipfunc = function() return tostring(ScriptUnit.extension(Managers.player:local_player().player_unit, "status_system").invisible) end,
		cheat = true,
		func = function(var)
		local status_extension = ScriptUnit.extension(Managers.player:local_player().player_unit, "status_system")
		status_extension:set_invisible(toboolean(var))
		end	
	},	
	ai_noclip = {
		tooltip = "Enable/disable collision with enemies. [boolean]",
		tooltipfunc = function() return tostring(ScriptUnit.extension(Managers.player:local_player().player_unit, "locomotion_system")._mover_modes.enemy_noclip) end,
		cheat = true,
		func = function(var)
		local status_extension = ScriptUnit.extension(Managers.player:local_player().player_unit, "status_system")
		status_extension:set_noclip(toboolean(var))
		end	
	},	
	workshop_browse = {
		tooltip = "Browse Steam workshop for Vermintide 2.",
		cheat = false,
		func = function(var)
		Steam.open_url("https://steamcommunity.com/app/552500/workshop/")
		end	
	},
	gm_friendly_fire = {
		tooltip = "Enable/disable friendly fire. [boolean]",
		tooltipfunc = function() return tostring(DamageUtils.allow_friendly_fire_ranged(Managers.state.difficulty:get_difficulty_settings(), Managers.player:owner(Managers.player:local_player().player_unit))) end,
		cheat = true,
		func = function(var)
		DifficultySettings[Managers.state.difficulty.difficulty].friendly_fire_ranged = toboolean(var)
		end	
	},
	player_ability_ready = {
		tooltip = "Force ready career ability.",
		cheat = true,
		func = function()
		ScriptUnit.extension(Managers.player:local_player().player_unit, "career_system")._cooldown  = 0
		end	
	},
	player_name = {
		tooltip = "Set player name - only on dedicated server! [string]",
		tooltipfunc = function() return tostring(Managers.player:local_player():name()) end,
		cheat = true,
		func = function(var)
		if not Managers.matchmaking:on_dedicated_server() then
			mod:echo("This function will not work on player hosted servers.")
		else
			Managers.player:local_player()._cached_name = var
			RPC.rpc_set_player_name(network_transmit.server_peer_id, var)
		end		
		end	
	},
	steam_presence_set = {
		tooltip = "Set Steam presence status text. [string]",
		cheat = false,
		func = function(var) Presence.set_presence("status", var) end	
	},	
	screenshot = {
		tooltip = "Capture backbuffer to a .dds file to game main directory.",
		cheat = false,
		func = function()
		local timestamp = os.date("%d.%m.%Y-%H.%M.%S")
		mod.ConsoleVisible = false
		Application.save_render_target("back_buffer", "../screenshot_" .. timestamp .. ".dds")
		end	
	},
	world_spawn_particles = {
		tooltip = "Spawn a particle effect in current world. [string]",
		cheat = true,
		func = function(var)
		local world = Managers.world:world("level_world")
		local position = Unit.world_position(Managers.player:local_player().player_unit,0)
		local rotation = Unit.world_rotation(Managers.player:local_player().player_unit,0)
		position = position + Quaternion.forward(rotation) * 3
		rotation = Quaternion.multiply(rotation, Quaternion.look(Quaternion.forward(rotation)))		
		world:create_particles(var, position, rotation, Vector3(1,1,1))
		end	
	},	
	wwise_pause = {
		tooltip = "Pause all wwise events.",
		cheat = false,
		func = function()
		local world = Managers.world:world("level_world")
		local wwise_world = Managers.world:wwise_world(world)
		WwiseWorld.pause_all(wwise_world)		
		end	
	},		
	wwise_resume = {
		tooltip = "Resume all wwise events.",
		cheat = false,
		func = function()
		local world = Managers.world:world("level_world")
		local wwise_world = Managers.world:wwise_world(world)
		WwiseWorld.resume_all(wwise_world)		
		end	
	},	
	debug_sound_emitter_test = {
		tooltip = "Spawn a dummy sound emitter.",
		cheat = true,
		func = function()
		local world = Managers.world:world("level_world")
		local wwise_world = Managers.world:wwise_world(world)
		local position = Unit.world_position(Managers.player:local_player().player_unit,0)
		local rotation = Unit.world_rotation(Managers.player:local_player().player_unit,0)
		position = position + Quaternion.forward(rotation) * 3
		rotation = Quaternion.multiply(rotation, Quaternion.look(Quaternion.forward(rotation)))
		local emitter = World.spawn_unit(world,"units/beings/player/way_watcher_upgraded/third_person_base/chr_third_person_base",position,rotation)		
		WwiseWorld.pause_all(wwise_world)
		WwiseWorld.trigger_event(wwise_world,"arrow_loop",emitter, 0)
		end	
	},
	r_restart = {
		tooltip = "Restart the renderer.",
		cheat = false,
		func = function()
		mod.ConsoleVisible = false
		Application.apply_user_settings()
		Renderer.bake_static_shadows()		
		end	
	},	
	disconnect = {
		tooltip = "Return to main menu.",
		cheat = false,
		func = function()
		mod.ConsoleVisible = false
		Managers.player:local_player().network_manager.matchmaking_manager._ingame_ui.leave_game = true
		end	
	},	
	lobby_private = {
		tooltip = "Set lobby private status. [boolean]",
		tooltipfunc = function() return tostring(Managers.matchmaking.lobby:get_stored_lobby_data().is_private) end,
		cheat = false,
		func = function(var)
		local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
		local translatedval = ""
		if var == "true" or var == "1" then translatedval = "true" else translatedval = "false" end
		lobby_data.is_private = translatedval
		
		Managers.matchmaking.lobby:set_lobby_data(lobby_data)
		end	
	},	
	lobby_country_code = {
		tooltip = "Set lobby country code. [string]",
		tooltipfunc = function() return tostring(Managers.matchmaking.lobby:get_stored_lobby_data().country_code) end,
		cheat = false,
		func = function(var)
		local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
		lobby_data.country_code = var
		
		Managers.matchmaking.lobby:set_lobby_data(lobby_data)
		end	
	},	
	wwise_trigger_event = {
		tooltip = "Play a sound event. [string]",
		cheat = false,
		func = function(var)
		local world = Managers.world:world("level_world")
		local wwise_world = Managers.world:wwise_world(world)
		wwise_world:trigger_event(var)	
		end	
	},
	ping = {
		tooltip = "Player ping :",
		tooltipfunc = function() return tostring( math.round_with_precision(GameSession.game_object_field(Managers.state.network:game(), Managers.player:local_player().game_object_id, "ping"), 3) .. " ms") end,
		cheat = false,
		func = function()
		return
		end	
	},
	latency = {
		tooltip = "Player latency :",
		tooltipfunc = function() return tostring( math.round_with_precision(GameSession.game_object_field(Managers.state.network:game(), Managers.player:local_player().game_object_id, "ping") * 2 + mod.DeltaTime, 3) .. " ms") end,
		cheat = false,
		func = function()
		return
		end	
	},
	fps_current = {
		tooltip = "Player fps :",
		tooltipfunc = function() return tostring( math.round_with_precision( 1 / mod.DeltaTime, 0)) end,
		cheat = false,
		func = function()
		return
		end	
	},
	animation_play_event = {
		tooltip = "Play an animation event. [string]",
		cheat = true,
		func = function(var)
		Unit.animation_event(Managers.player:local_player().player_unit, var)
		if table.contains(NetworkLookup.anims, var) then CharacterStateHelper.play_animation_event(Managers.player:local_player().player_unit, var) end
		end	
	},
	gm_mutator_list = {
		tooltip = "Print list of mutators to chat, currently active mutators will have '(ACTIVE)' tag.",
		cheat = true,
		func = function()
		
		mod:echo("===MUTATOR LIST BEGIN===")
		for key,value in pairs(MutatorTemplates) do
		local message = key
		if Managers.state.game_mode._mutator_handler:has_mutator(key) then message = message .. " (ACTIVE)" end
		mod:echo(message)
		end
		mod:echo("===MUTATOR LIST END===")
		end
	},	
	gm_mutator_add = {
		tooltip = "Activate a mutator. [string]",
		cheat = true,
		func = function(var)
		Managers.state.game_mode._mutator_handler:_activate_mutator(var, Managers.state.game_mode._mutator_handler._active_mutators, Managers.state.game_mode._mutator_handler._mutator_context)
		Managers.state.game_mode._mutator_handler._mutators_by_name[var] = true
		end
	},
	gm_mutator_remove = {
		tooltip = "Deactivate a mutator. [string]",
		cheat = true,
		func = function(var)
		Managers.state.game_mode._mutator_handler:_deactivate_mutator(var, Managers.state.game_mode._mutator_handler._active_mutators, Managers.state.game_mode._mutator_handler._mutator_context)
		Managers.state.game_mode._mutator_handler._mutators_by_name[var] = false		
		end
	},
	map_force_win = {
		tooltip = "Force victory on current map.",
		cheat = true,
		func = function()
		mod.ConsoleVisible = false 
		Managers.state.game_mode:complete_level()
		end	
	},
	map_force_loose = {
		tooltip = "Force defeat on current map.",
		cheat = true,
		func = function()
		mod.ConsoleVisible = false 
		Managers.state.game_mode:fail_level()
		end	
	},
	find = {
		tooltip = "Find commands with provided pattern. [string]",
		cheat = false,
		func = function(var)
		local tabletosort = {}
		
		mod:echo("===MATCHING COMMAND LIST BEGIN===")
		for index, command in pairs(mod.ConsoleCommands) do 
			table.insert(tabletosort, index)
		end 
		table.sort(tabletosort, function(a, b) return a:lower() < b:lower() end)
		
		for k, v in pairs(tabletosort) do
			local cheatstring = ""
			if mod.ConsoleCommands[v].cheat == true then
				cheatstring = " (CHEAT)" 
			end
			if string.find(v, var) then mod:echo(v .. " - " .. mod.ConsoleCommands[v].tooltip .. cheatstring) end
		end		
		mod:echo("===MATCHING COMMAND LIST END===")
		end
	},
	player_first_person = {
		tooltip = "Set camera to first or third person perspective. [boolean]",
		tooltipfunc = function() return tostring( ScriptUnit.has_extension(Managers.player:local_player().player_unit, "first_person_system").first_person_mode  ) end,
		cheat = true,
		func = function(var)
		local parameters = {
			third_person_mode = not toboolean(var),
		}
		override_development_parameter_func(parameters)		
		ScriptUnit.has_extension(Managers.player:local_player().player_unit, "first_person_system"):set_first_person_mode(toboolean(var), true)
		if toboolean(var) == true then
			CharacterStateHelper.change_camera_state(Managers.player:local_player(), "follow")
		else
			CharacterStateHelper.change_camera_state(Managers.player:local_player(), "follow_third_person_over_shoulder")
		end
		end
	},
	screenshot_mode = {
		tooltip = "Disable entire UI. [boolean]",
		tooltipfunc = function() return tostring( Development.parameter("disable_info_slate_ui")  ) end,
		cheat = true,
		func = function(var)
		local parameters = {
			disable_info_slate_ui = toboolean(var),
			disable_loading_icon = toboolean(var),
			disable_ui = toboolean(var),
			bone_lod_disable = toboolean(var),
			disable_outlines = toboolean(var),
			disable_tutorial_ui = toboolean(var),
		}
		override_development_parameter_func(parameters)
		
		script_data.disable_info_slate_ui = toboolean(var)
		script_data.disable_loading_icon = toboolean(var)
		script_data.disable_ui = toboolean(var)
		script_data.bone_lod_disable = toboolean(var)
		script_data.disable_outlines = toboolean(var)
		script_data.disable_tutorial_ui = toboolean(var)
		end
	},
	g_infinite_stamina = {
		tooltip = "Enable/disable infinite stamina. [boolean]",
		tooltipfunc = function() return tostring(Development.parameter("disable_fatigue_system")) end,
		cheat = true,
		func = function(var)
		local parameters = {
			disable_fatigue_system  = toboolean(var)
		}
		override_development_parameter_func(parameters)
		end	
	},
	g_super_jumps = {
		tooltip = "Enable/disable super jumps. [boolean]",
		tooltipfunc = function() return tostring(script_data.use_super_jumps) end,
		cheat = true,
		func = function(var)
		script_data.use_super_jumps = toboolean(var)
		end	
	},
	g_force_twitch_mode = {
		tooltip = "Force on/off Twitch mode without being connected to Twitch. [boolean]",
		tooltipfunc = function() return tostring(Development.parameter("twitch_debug_voting")) end,
		cheat = false,
		func = function(var)
		local parameters = {
			twitch_debug_voting  = toboolean(var)
		}
		override_development_parameter_func(parameters)	
		Managers.twitch:debug_activate_twitch_game_mode()		
		end	
	},	
	g_attract_mode = {
		tooltip = "Enable/disable attract mode. [boolean]",
		tooltipfunc = function() return tostring(Development.parameter("attract_mode")) end,
		cheat = false,
		func = function(var)
		local parameters = {
			attract_mode  = toboolean(var)
		}
		override_development_parameter_func(parameters)			
		mod.ConsoleVisible = false
		Managers.player:local_player().network_manager.matchmaking_manager._ingame_ui.leave_game = true
		end	
	},		
	player_set_camera_mode = {
		tooltip = "Enable/disable attract mode. [string - follow/follow_third_person/follow_third_person_over_shoulder/attract]",
		cheat = true,
		func = function(var)
		CharacterStateHelper.change_camera_state(Managers.player:local_player(), var)
		end	
	},
	bind = {
		tooltip = "Bind command to a key. [string; key,command,arguments] ",
		cheat = false,
		func = function(var)
		local key, cmd, arg = var:match("([^,]+),([^,]+),([^,]+)")
		if var == nil or key == nil or cmd == nil or arg == nil or mod.ConsoleCommands[cmd] == nil then
			mod:echo("Invalid binding provided, for commands without argument leave single space after 2nd comma.")
			return
		end
		local insides = {
			command = cmd,
			argument = arg
		}
		
		Application.set_user_setting("ConsoleBinds",key, insides)
		Application.save_user_settings()
		mod.Binds = Application.user_setting("ConsoleBinds")
		end	
	},
	clearbinds = {
		tooltip = "Clear all binds.",
		cheat = false,
		func = function(var)
		Application.set_user_setting("ConsoleBinds",{})
		Application.save_user_settings()
		mod.Binds = {}
		end	
	},
	unbind = {
		tooltip = "Unbind a key. [string]",
		cheat = false,
		func = function(var)
		Application.set_user_setting("ConsoleBinds",var, nil)
		Application.save_user_settings()
		mod.Binds = Application.user_setting("ConsoleBinds")
		end	
	},	
	binds_list = {
		tooltip = "Print all bindings to chat.",
		cheat = false,
		func = function()
		mod:echo("===CONSOLE BINDS LIST BEGIN===")
		for k, v in pairs(mod.Binds) do 
			mod:echo(k .. " - " .. v.command .. " " .. v.argument)
		end	
		mod:echo("===CONSOLE BINDS LIST END===")		
		end	
	},
	chat_enable = {
		tooltip = "Enable/disable chat. [boolean]",
		tooltipfunc = function() return tostring(Managers.chat._chat_enabled) end,
		cheat = false,
		func = function(var)
		Managers.chat:set_chat_enabled(toboolean(var))
		Managers.chat.gui_enabled = toboolean(var)	
		end	
	},	
}

for key,value in pairs(script_data) do
if key ~= "settings" and key ~= "ini" and key ~= "eac-untrusted" then
	local insides = {
		tooltip = "Set script data for " .. key .. ". [boolean]",
		tooltipfunc = function() return tostring(script_data.key) end,
		cheat = true,
		func = function(var) script_data.key = toboolean(var) end,
		scriptdata = true,
	}
	
	mod.ConsoleCommands["script_data_" .. key] = insides
end
end

mod.CommandsCount = function()
  local count = 0
  for _ in pairs(mod.ConsoleCommands) do count = count + 1 end
  return count
end