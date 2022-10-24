--[[
	Type in the chat: /servername <name>
--]]

local args = {...}

if #args == 1 then
	local name = args[1]
	local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()

	lobby_data.host = 0
	lobby_data.unique_server_name = name

	Managers.matchmaking.lobby:set_lobby_data(lobby_data)

	EchoConsole("Server name set")
	
	return true
else
	return false
end