local event_data = {}
event_data.enemy_tag = "skaven_storm_vermin"
event_data.is_ping = true

local local_player_unit = Managers.player:local_player().player_unit
local dialogue_input = ScriptUnit.extension_input(local_player_unit, "dialogue_system")
dialogue_input:trigger_networked_dialogue_event("seen_enemy", event_data)

Managers.chat:send_chat_message(1, "patrol incoming")
