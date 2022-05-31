if Managers.player.is_server then
	local conflict_director = Managers.state.conflict

	conflict_director:debug_spawn_breed(0)
	EchoConsole("Spawn: " .. conflict_director._debug_breed)
end