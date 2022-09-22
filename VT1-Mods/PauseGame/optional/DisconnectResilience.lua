local mod_name = "DisconnectionResilience"

if not network_disconnect_token then
	network_disconnect_token = false
end

if not backend_disconnect_token then
	backend_disconnect_token = false
end

if not backend_reconnect_token then
	backend_reconnect_token = false
end

if not RESILIENCE_DISCONNECTED_PEERS then
	RESILIENCE_DISCONNECTED_PEERS = {}
end

local RPC_DISCO_RESIL_DISCONNECTED = "rpc_disco_resil_disconnected"

Mods.hook.set(mod_name, "StateIngame.connected_to_network", function (func, self)
	local result, err = pcall(func, self)
	if result == false and not network_disconnect_token then
		network_disconnect_token = true
		script_data.disable_gamemode_end = true
		EchoConsole("DisconnectionResilience : Lost connection to the network.")
		if not Managers.player.is_server then
			Mods.network.send_rpc_server(RPC_DISCO_RESIL_DISCONNECTED, true)
		end
	end
	if result == true and network_disconnect_token then
		network_disconnect_token = false
		if not backend_disconnect_token then
			script_data.disable_gamemode_end = false
			-- if Managers.state.debug.time_paused and Managers.player.is_server then
			if Managers.state.debug.time_paused and Managers.player.is_server and not freezealltoken then
				Managers.state.debug.set_time_scale(Managers.state.debug, Managers.state.debug.time_scale_index)
			end

			if not Managers.player.is_server then
				Mods.network.send_rpc_server(RPC_DISCO_RESIL_DISCONNECTED, false)
			end
		end
		EchoConsole("DisconnectionResilience : Regained connection to the network.")
	end
	return true
end)

Mods.hook.set(mod_name, "BackendManager._update_error_handling", function (func, self)
	return
end)

Mods.hook.set(mod_name, "BackendManager._destroy_backend", function (func, self)
	return
end)

Mods.hook.set(mod_name, "BackendManager._post_error", function (func, ...)
	return
end)

Mods.hook.set(mod_name, "ProgressionUnlocks.is_unlocked", function (func, unlock_name, level)
	if (network_disconnect_token or backend_disconnect_token) and (unlock_name == "forge" or unlock_name == "altar" or unlock_name == "quests") then
		return
	end
	
	return func(unlock_name, level)		
end)

Mods.hook.set(mod_name, "InteractionDefinitions.forge_access.client.can_interact", function (func, ...)
	local experience = ScriptBackendProfileAttribute.get("experience")
	if experience == -1 or network_disconnect_token or backend_disconnect_token then
		return false
	end
	return func(...)
end)

Mods.hook.set(mod_name, "InteractionDefinitions.altar_access.client.can_interact", function (func, ...)
	local experience = ScriptBackendProfileAttribute.get("experience")
	if experience == -1 or network_disconnect_token or backend_disconnect_token then
		return false
	end
	return func(...)
end)

Mods.hook.set(mod_name, "InteractionDefinitions.quest_access.client.can_interact", function (func, ...)
	local experience = ScriptBackendProfileAttribute.get("experience")
	if experience == -1 or network_disconnect_token or backend_disconnect_token then
		return false
	end
	return func(...)
end)

local laststate = "connection_entities_loaded"
Mods.hook.set(mod_name, "ScriptBackend.update", function (func, ...)
	local CONNECTION_STATE_NAMES = {}
	CONNECTION_STATE_NAMES[Backend.CONNECTION_UNINITIALIZED] = "connection_uninitialized"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_INITIALIZED] = "connection_initialized"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_CONNECTING] = "connection_connecting"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_CONNECTED] = "connection_connected"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_WAITING_AUTH_TICKET] = "connection_waiting_auth_ticket"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_AUTHENTICATING] = "connection_authenticating"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_AUTHENTICATED] = "connection_authenticated"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_DISCONNECTING] = "connection_disconnecting"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_ENTITIES_LOADED] = "connection_entities_loaded"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_ERROR] = "connection_error"
	local state = CONNECTION_STATE_NAMES[Backend.state()]
	-- if state ~= laststate then
		-- if state ~= "connection_initialized" then
			-- local status, err = pcall(EchoConsole, state)
		-- end
		-- laststate = state
	-- end

	if state == "connection_entities_loaded" and backend_disconnect_token then
		backend_disconnect_token = false
		backend_reconnect_token = false
		if not network_disconnect_token then
			script_data.disable_gamemode_end = false
			-- if Managers.state.debug and Managers.state.debug.time_paused and Managers.player.is_server then
			if Managers.state.debug and Managers.state.debug.time_paused and Managers.player.is_server and not freezealltoken then
				Managers.state.debug.set_time_scale(Managers.state.debug, Managers.state.debug.time_scale_index)
			end

			if Managers.player and not Managers.player.is_server and Managers.state.debug then
				Mods.network.send_rpc_server(RPC_DISCO_RESIL_DISCONNECTED, false)
			end
		end
		local status, err = pcall(EchoConsole, "DisconnectionResilience : Regained connection to the backend.")
	end

	if state == "connection_connecting" then
		backend_reconnect_token = false
	end

	if state == "connection_initialized" then
		if Managers.player.is_server then	-- Xq: added condition
			if not backend_disconnect_token then
				local status, err = pcall(EchoConsole, "DisconnectionResilience : Lost connection to the backend.")
				backend_disconnect_token = true
				script_data.disable_gamemode_end = true

				if not Managers.player.is_server and Managers.state.debug then
					Mods.network.send_rpc_server(RPC_DISCO_RESIL_DISCONNECTED, true)
				end
			end
			if not backend_reconnect_token and not network_disconnect_token then
				local status, err = pcall(EchoConsole, "DisconnectionResilience : Attempting reconnection to the backend.")
				if err == nil then
					backend_reconnect_token = true
					Managers.backend = BackendManager:new()
					Managers.backend:signin()
				end
			end
		end
	end

	local peer_is_disconnected = false

	for peer, bool in pairs(RESILIENCE_DISCONNECTED_PEERS) do
		if Managers.player:players_at_peer(peer) == nil then
			RESILIENCE_DISCONNECTED_PEERS[peer] = nil
			bool = false
		end		

		if bool then
			peer_is_disconnected = true
		end
	end

	if peer_is_disconnected then
		script_data.disable_gamemode_end = true
	elseif not network_disconnect_token and not backend_disconnect_token then
		script_data.disable_gamemode_end = false

		-- if Managers.state.debug and Managers.state.debug.time_paused and Managers.player.is_server then
		if Managers.state.debug and Managers.state.debug.time_paused and Managers.player.is_server and not freezealltoken then
			Managers.state.debug.set_time_scale(Managers.state.debug, Managers.state.debug.time_scale_index)
		end
	end

	return func(...)
end)

Mods.hook.set(mod_name, "GameModeManager.complete_level", function (func, self)
	func(self)
	if script_data.disable_gamemode_end and Managers.state.game_mode._game_mode_key ~= "inn" then
		Managers.chat:send_system_chat_message(1, "DisconnectionResilience : Victory was achieved. Freezing game state until connection to the network and backend is reestablished for all players.", 0, true)
		Managers.state.debug.set_time_paused(Managers.state.debug)
	end
end)

if not FAILURE_WAS_ANNOUNCED then
	FAILURE_WAS_ANNOUNCED = false
end
if not FAILURE_TIMESTAMP then
	FAILURE_TIMESTAMP = 0
end
Mods.hook.set(mod_name, "GameModeAdventure.evaluate_end_conditions", function(func, self, round_started, dt, t)
	if not script_data.disable_gamemode_end then
		FAILURE_WAS_ANNOUNCED = false
		FAILURE_TIMESTAMP = 0
		return func(self, round_started, dt, t)
	end

	local spawn_manager = Managers.state.spawn
	local humans_dead = spawn_manager.all_humans_dead(spawn_manager)
	local level_failed = self._level_failed

	if (humans_dead or level_failed) and not FAILURE_WAS_ANNOUNCED then
		Managers.chat:send_system_chat_message(1, "DisconnectionResilience : You were defeated. Freezing game state until connection to the network and backend is reestablished for all players.", 0, true)
		FAILURE_WAS_ANNOUNCED = true
		FAILURE_TIMESTAMP = t
	end

	if FAILURE_WAS_ANNOUNCED and not Managers.state.debug.time_paused then
		if t - 3 > FAILURE_TIMESTAMP then
			Managers.state.debug.set_time_paused(Managers.state.debug)
		end
	end

	return false
end)

Mods.hook.set(mod_name, "GameModeSurvival.evaluate_end_conditions", function(func, self, round_started, dt, t)
	if not script_data.disable_gamemode_end then
		FAILURE_WAS_ANNOUNCED = false
		FAILURE_TIMESTAMP = 0
		return func(self, round_started, dt, t)
	end

	local spawn_manager = Managers.state.spawn
	local humans_dead = spawn_manager.all_humans_dead(spawn_manager)
	local level_failed = self._level_failed

	if (humans_dead or level_failed) and not FAILURE_WAS_ANNOUNCED then
		Managers.chat:send_system_chat_message(1, "DisconnectionResilience : You were defeated. Freezing game state until connection to the network and backend is reestablished for all players.", 0, true)
		FAILURE_WAS_ANNOUNCED = true
		FAILURE_TIMESTAMP = t
	end

	if FAILURE_WAS_ANNOUNCED and not Managers.state.debug.time_paused then
		if t - 3 > FAILURE_TIMESTAMP then
			Managers.state.debug.set_time_paused(Managers.state.debug)
		end
	end

	return false
end)

Mods.network.register(RPC_DISCO_RESIL_DISCONNECTED, function(sender_id, peer_is_disconnected)
	local player = Managers.player:player_from_peer_id(sender_id, 1)
	local player_name = player._cached_name

	if peer_is_disconnected and not RESILIENCE_DISCONNECTED_PEERS[sender_id] then
		EchoConsole("DisconnectionResilience : Player '" .. player_name .. "' has been disconnected from the game network.")
	elseif not peer_is_disconnected and RESILIENCE_DISCONNECTED_PEERS[sender_id] then
		EchoConsole("DisconnectionResilience : Player '" .. player_name .. "' has been reconnected to the game network.")
	end

	RESILIENCE_DISCONNECTED_PEERS[sender_id] = peer_is_disconnected	

	for peer_id, is_dc in pairs(RESILIENCE_DISCONNECTED_PEERS) do
		if Managers.player:players_at_peer(peer_id) == nil then
			RESILIENCE_DISCONNECTED_PEERS[peer_id] = nil
		end
	end
end)


Mods.hook.set(mod_name, "StateLoading.on_exit", function(func, self, application_shutdown)
	if PLATFORM == "win32" then
		local max_fps = Application.user_setting("max_fps")

		if max_fps == nil or max_fps == 0 then
			Application.set_time_step_policy("no_throttle")
		else
			Application.set_time_step_policy("throttle", max_fps)
		end
	end

	if self._registered_rpcs then
		self:_unregister_rpcs()
	end

	local skip_signin = self.parent.loading_context.skip_signin

	if application_shutdown then
		self:_destroy_network()
	elseif self._teardown_network then
		self:_destroy_network()
	else
		local loading_context = {
			level_transition_handler = self._level_transition_handler,
			network_transmit = self._network_transmit,
			checkpoint_data = self._checkpoint_data
		}

		if self._lobby_host then
			loading_context.lobby_host = self._lobby_host
			local level_key = self._level_transition_handler:get_current_level_keys()
			local stored_lobby_host_data = self._lobby_host:get_stored_lobby_data() or {}
			stored_lobby_host_data.level_key = level_key
			stored_lobby_host_data.unique_server_name = stored_lobby_host_data.unique_server_name or LobbyAux.get_unique_server_name()
			stored_lobby_host_data.host = stored_lobby_host_data.host or Network.peer_id()
			stored_lobby_host_data.num_players = stored_lobby_host_data.num_players or 1
			stored_lobby_host_data.country_code = rawget(_G, "Steam") and Steam.user_country_code()

			self._lobby_host:set_lobby_data(stored_lobby_host_data)

			loading_context.network_server = self._network_server

			self._network_server:unregister_rpcs()
			self._network_server.voip:set_input_manager(nil)
		else
			loading_context.lobby_client = self._lobby_client
			loading_context.network_client = self._network_client
			
			if self._network_client then
				self._network_client:unregister_rpcs()
				self._network_client.voip:set_input_manager(nil)
			else
				EchoConsole("_network_client: " .. tostring(_network_client))
			end
		end

		loading_context.show_profile_on_startup = self.parent.loading_context.show_profile_on_startup
		local difficulty = self:_get_game_difficulty()
		loading_context.difficulty = difficulty
		self.parent.loading_context = loading_context
	end

	self._profile_synchronizer = nil

	if self._network_event_delegate then
		self._network_event_delegate:destroy()

		self._network_event_delegate = nil
	end

	Managers.state:destroy()

	if self._first_time_view then
		self._first_time_view:destroy()

		self._first_time_view = nil

		self:unload_first_time_view_packages()
	end

	if self._loading_view then
		self._loading_view:destroy()

		self._loading_view = nil
	end

	self._machine:destroy(application_shutdown)

	if self.parent.loading_context then
		self.parent.loading_context.host_to_migrate_to = nil
		self.parent.loading_context.restart_network = nil
		self.parent.loading_context.players = nil
		self.parent.loading_context.local_player_index = nil
		self.parent.loading_context.skip_signin = skip_signin

		if self._restart_network then
			self.parent.loading_context.restart_network = true
		end
	end

	local package_manager = Managers.package

	if self._ui_package_name and (package_manager:has_loaded(self._ui_package_name, "global_loading_screens") or package_manager:is_loading(self._ui_package_name)) then
		package_manager:unload(self._ui_package_name, "global_loading_screens")
	end

	ScriptWorld.destroy_viewport(self._world, self._viewport_name)
	Managers.world:destroy_world(self._world)
	Managers.music:trigger_event("Stop_loading_screen_music")

	if application_shutdown or self._popup_id == nil then
		print("StateLoading added a popup right before exiting")
	end

	Managers.popup:cancel_all_popups()
	Managers.popup:remove_input_manager(application_shutdown)
	Managers.chat:set_input_manager(nil)
	Managers.chat:enable_gui(true)

	if not Managers.play_go:installed() then
		Managers.play_go:set_install_speed("slow")
	end

	if PLATFORM == "ps4" then
		Managers.account:set_realtime_multiplay_state("loading", false)
	end
end)

-- Xq: added mechanism to recreate the steam lobby after disconnect to prevent crash (tearing down music sync)
local last_joined_lobby_id = nil

local debug_timer = 0
local create_lobby_timeout = 0
local stored_lobby_data = {}
local lobby_refresh_state = "idle"
local lobby_refresh_timer = 0

Mods.hook.set(mod_name, "LobbyMembers.update", function(func, self)
	func(self)
	
	local is_joined = function (lobby_input)
		local lobby_state = lobby_input.lobby:state()
		local state = LobbyInternal.state_map[lobby_state]

		return state == LobbyState.JOINED
	end
	
	local set_lobby_data = function (lobby_input, lobby_data_table)
		lobby_input.lobby_data_table = lobby_data_table

		if lobby_input.state == LobbyState.JOINED then
			local lobby = lobby_input.lobby

			if PLATFORM == "ps4" then
				lobby:set_data_table(lobby_data_table)
			else
				for key, value in pairs(lobby_data_table) do
					lobby:set_data(key, value)
				end
			end
		end
	end
	
	local system_time = os.time()
	local matchmaking_valid = Managers and Managers.matchmaking and Managers.matchmaking.lobby
	local is_host = (matchmaking_valid and Managers.matchmaking.lobby.is_joined and true) or false	-- is_joined function doesn't exist in lobby_client
	
	local host_id = self.lobby:lobby_host()
	local stored_host_id
	if host_id and host_id ~= "" then
		stored_host_id = host_id
	end
	
	local self_peer_id = Network.peer_id()
	for i,peer_id in pairs(self.members_left) do
		if peer_id == self_peer_id then
			table.remove(self.members_left, i)
			self.members[peer_id] = true
			
			local current_members = self.lobby:members()
			local lobby_state = self.lobby:state()	-- 2 = FAILED ?
			if #current_members == 0 and lobby_state == 2 then
				if system_time > create_lobby_timeout then
					-- if is_host then
						create_lobby_timeout = system_time + 20
						EchoConsole("Steam lobby failed >> creating new lobby.")
						lobby_refresh_state = "exit_old_lobby"
						lobby_refresh_timer = system_time
					-- elseif matchmaking_valid then
						-- EchoConsole("Lobby recreation is for host only, stopping process due to being client")
					-- end
				end
				--
			end
			
		end
	end
	
	if system_time >= lobby_refresh_timer then
		if lobby_refresh_state == "exit_old_lobby" then
			lobby_refresh_timer = system_time +1
			if is_host then
				lobby_refresh_state	= "create_new_lobby"
			else
				lobby_refresh_state	= "rejoin_host_lobby"
			end
			--
			stored_lobby_data	= Managers.matchmaking and Managers.matchmaking.lobby:get_stored_lobby_data()
			EchoConsole("Leaving old steam lobby")
			Network.leave_steam_lobby(self.lobby)
			--
		elseif lobby_refresh_state == "create_new_lobby" then
			lobby_refresh_timer = system_time +1
			lobby_refresh_state	= "set_lobby_data"
			--
			local development_port = Development.parameter("server_port") or GameSettingsDevelopment.network_port
			local port_increment = LOBBY_PORT_INCREMENT or 0
			development_port = development_port + port_increment
			local lobby_port = (LEVEL_EDITOR_TEST and GameSettingsDevelopment.editor_lobby_port) or development_port
			local network_options = {
				privacy = LobbyPrivacy.PUBLIC,
				project_hash = "bulldozer",
				max_members = 4,
				config_file_name = "global",
				lobby_port = lobby_port
			}
			-- if not Managers.matchmaking.lobby.is_joined then
				-- -- This player was a client >> change client to host
				-- Managers.matchmaking.lobby = LobbyHost:new(network_options)	-- THIS CAUSES CRASH
			-- else
				self.lobby = LobbyInternal.create_lobby(network_options)
			-- end
			
			EchoConsole("New steam lobby created")
			--
		elseif lobby_refresh_state == "set_lobby_data" then
			-- if Managers.matchmaking.lobby:is_joined() then
			if is_joined(Managers.matchmaking.lobby) then
				if Managers.matchmaking then
					stored_lobby_data.num_players = 1
					-- Managers.matchmaking.lobby:set_lobby_data(stored_lobby_data)
					set_lobby_data(Managers.matchmaking.lobby, stored_lobby_data)
					EchoConsole("Steam lobby data updated")
					EchoConsole("Clients can now rejoin the lobby")
				end
				--
				lobby_refresh_state	= "idle"
			end
			--
		elseif lobby_refresh_state == "rejoin_host_lobby" then
			-- local lobby_data = LobbyInternal.get_lobby_data_from_id(stored_lobby_data.id)
			-- if type(lobby_data) == "table" then
				-- print("Dc resilience mod: printing debug data (lobby_data)")
				-- for key,value in pairs(lobby_data) do
					-- print(tostring(key) .. " | " .. tostring(value))
				-- end
			-- end
			-- EchoConsole(stored_lobby_data == lobby_data)
			-- EchoConsole(lobby_data)
			-- self.lobby = LobbyInternal.join_lobby(lobby_data)
			print("Trying to rejoin lobby with id: " .. tostring(last_joined_lobby_id))
			self.lobby = LobbyInternal.join_lobby({id = last_joined_lobby_id})
			EchoConsole("Trying to rejoin the host's lobby")
			if self.lobby then
				lobby_refresh_state	= "idle"
			else
				lobby_refresh_state	= "create_new_lobby"
			end
		end
	end
	
	-- if system_time >= debug_timer then
		-- debug_timer = system_time +1
		-- EchoConsole("**********")
		-- EchoConsole("fatal_error: " .. tostring(Network.fatal_error()))
		-- EchoConsole("game_session: " .. tostring(Network.game_session()))
		-- EchoConsole("LobbyInternal.network_initialized: " .. tostring(LobbyInternal.network_initialized()))
		-- EchoConsole("#self.lobby:members(): " .. tostring(#self.lobby:members()))
		-- EchoConsole("self.lobby: " .. tostring(self.lobby))
		-- EchoConsole("Managers.matchmaking.lobby: " .. tostring(Managers.matchmaking.lobby))
	-- end
	--
end)

Mods.hook.set(mod_name, "LobbyInternal.join_lobby", function(func, lobby_data)
	if lobby_refresh_state ~= "rejoin_host_lobby" then
		last_joined_lobby_id = lobby_data.id
	end
	return func(lobby_data)
end)

