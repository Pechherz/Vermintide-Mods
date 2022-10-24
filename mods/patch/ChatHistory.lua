local mod_name = "ChatHistory"
-- Keymap
ChatHistoryKeyMap = {
	win32 = {
		["up_pressed"]			= {"keyboard", "up", "pressed"},
		["down_pressed"]		= {"keyboard", "down", "pressed"},
		["enter"]				= {"keyboard", "enter", "pressed"},
	},
}
ChatHistoryKeyMap.xb1 = ChatHistoryKeyMap.win32

ChatHistory = {}
ChatHistory.CHATHISTORY = {
	messages = {},
	position = 0
}

ChatHistory.pressed = function(key)
	local input_service = Managers.input:get_service(mod_name)
	
	if input_service then
		return input_service.get(input_service, key)
	else
		return false
	end
end

ChatHistory.block = function()
	local input_service = Managers.input:get_service(mod_name)
	
	if input_service then
		for _, obj in pairs(Managers.input.input_devices) do
			obj.blocked_access["ChatHistory"] = true
		end
		input_service:set_blocked(true)
	end
end

ChatHistory.unblock = function()
	local input_service = Managers.input:get_service(mod_name)
	
	if input_service then
		for _, obj in pairs(Managers.input.input_devices) do
			obj.blocked_access["ChatHistory"] = nil
		end
		input_service:set_blocked(nil)
	end
end

Mods.hook.set(mod_name, "ChatGui.update", function(func, self, ...)
	if ChatHistory.pressed("up_pressed") then
		if #ChatHistory.CHATHISTORY.messages > ChatHistory.CHATHISTORY.position then
			ChatHistory.CHATHISTORY.position = ChatHistory.CHATHISTORY.position + 1

			self.chat_index = 1
			self.chat_message = ChatHistory.CHATHISTORY.messages[ChatHistory.CHATHISTORY.position]
			self.chat_index = string.len(self.chat_message) + 1
		end
	elseif ChatHistory.pressed("down_pressed") then
		self.chat_index = 1
		if ChatHistory.CHATHISTORY.position > 1 then
			ChatHistory.CHATHISTORY.position = ChatHistory.CHATHISTORY.position - 1	
					
			self.chat_message = ChatHistory.CHATHISTORY.messages[ChatHistory.CHATHISTORY.position]			
		else
			self.chat_message = ""
			ChatHistory.CHATHISTORY.position = 0
		end
		self.chat_index = string.len(self.chat_message) + 1
	elseif ChatHistory.pressed("enter") then
		ChatHistory.CHATHISTORY.position = 0

		if self.chat_message ~= "" and ChatHistory.CHATHISTORY.messages[1] ~= self.chat_message then
			table.insert(ChatHistory.CHATHISTORY.messages, 1, self.chat_message)
			
			if #ChatHistory.CHATHISTORY.messages > 10 then
				table.remove(ChatHistory.CHATHISTORY.messages, 11)
			end
		end
	end

	func(self, ...)
end)

Mods.hook.set(mod_name, "ChatGui.block_input", function(func, ...)
	func(...)
	
	ChatHistory.unblock()
end)

Mods.hook.set(mod_name, "ChatGui.unblock_input", function(func, ...)
	func(...)
	
	ChatHistory.block()
end)

Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, ...)
	func(...)
	
	ChatHistory.init()
end)

Mods.hook.set(mod_name, "StateInGameRunning.event_game_actually_starts", function(func, ...)
	func(...)
	
	ChatHistory.init()
end)

ChatHistory.init = function()
	local input_manager = Managers.input

	input_manager:create_input_service(mod_name, "ChatHistoryKeyMap")
	input_manager:map_device_to_service(mod_name, "keyboard")
	input_manager:map_device_to_service(mod_name, "mouse")
	input_manager:map_device_to_service(mod_name, "gamepad")
end

ChatHistory.init()
