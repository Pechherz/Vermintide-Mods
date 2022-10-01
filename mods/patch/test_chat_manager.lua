-- local mod_name = "test_chat_manager"

-- Mods.hook.set(mod_name, "ChatManager.send_system_chat_message_to_all_except", function(func, self, channel_id, message_id, localization_param, excluded_peer_id, pop_chat)
--     fassert(self:has_channel(channel_id), "Haven't registered channel: %s", tostring(channel_id))

-- 	local is_system_message = true
-- 	pop_chat = pop_chat or false
-- 	local is_dev = false

-- 	if self.is_server then
-- 		local my_peer_id = self.my_peer_id
-- 		local members = self:channel_members(channel_id)

-- 		for _, member in pairs(members) do
-- 			if member ~= my_peer_id and member ~= excluded_peer_id then
-- 				RPC.rpc_chat_message(member, channel_id, excluded_peer_id, message_id, localization_param, is_system_message, pop_chat, is_dev)
-- 			end
-- 		end
-- 	else
-- 		local host_peer_id = self.host_peer_id

-- 		if host_peer_id then
-- 			RPC.rpc_chat_message(host_peer_id, channel_id, excluded_peer_id, message_id, localization_param, is_system_message, pop_chat, is_dev)
-- 		end
-- 	end

-- 	if message_id == "system_chat_player_joined_the_game" or message_id == "system_chat_player_left_the_game" then
-- 		local country_code = rawget(_G, "Steam") and Steam.user_country_code(excluded_peer_id)
-- 		localization_param = localization_param .. " (" .. country_code .. ")"
-- 	end

-- 	local message_sender = "SYSTEM"
-- 	local message = string.format(Localize(message_id), localization_param)

-- 	self:_add_message_to_list(channel_id, message_sender, message, is_system_message, pop_chat, is_dev)
-- end)
