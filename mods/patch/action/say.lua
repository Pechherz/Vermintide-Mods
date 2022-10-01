-- PlayerDialogue:say()

local local_player_unit = Managers.player:local_player().player_unit
local dialogue_input = ScriptUnit.extension_input(local_player_unit, "dialogue_system")
local event_data = FrameTable.alloc_table()
-- -- event_data.stance_type = "defensive"
-- event_data.stance_type = "offensive"
-- event_data.source_name = "witch_hunter"
-- event_data.player_profile = "witch_hunter"
-- dialogue_input:trigger_dialogue_event("stance_triggered", event_data)

-- local event_data = FrameTable.alloc_table()
-- event_data.target = "witch_hunter"
-- event_data.source_name = "witch_hunter"
-- event_data.player_profile = "empire_soldier"
-- event_data.is_ping = true
-- dialogue_input:trigger_networked_dialogue_event("friendly_fire", event_data)

-- event_data.source_name = "empire_soldier"
-- event_data.target_name  = "empire_soldier"
-- event_data.player_profile = "empire_soldier"
-- event_data.is_ping = true
-- dialogue_input:trigger_networked_dialogue_event("ledge_hanging", event_data)

-- event_data.enemy_tag = "skaven_poison_wind_globadier"
-- event_data.is_ping = true
-- dialogue_input:trigger_networked_dialogue_event("seen_enemy", event_data)

-- event_data.enemy_tag = "skaven_storm_vermin"
-- event_data.is_ping = true
-- dialogue_input:trigger_networked_dialogue_event("seen_enemy", event_data)

-- event_data.target = "empire_soldier"
-- event_data.source_name = "empire_soldier"
-- event_data.player_profile = "witch_hunter"
-- event_data.player_profile = "empire_soldier"

-- dialogue_input:trigger_networked_dialogue_event("friendly_fire", event_data)

local event_data = FrameTable.alloc_table()
event_data.item_tag = "ammo"
event_data.distance = 2
event_data.is_ping = true
dialogue_input:trigger_networked_dialogue_event("seen_item", event_data)

-- local event_data = FrameTable.alloc_table()
-- event_data.item_tag = "potion"
-- event_data.distance = 2
-- event_data.is_ping = true
-- dialogue_input:trigger_networked_dialogue_event("seen_item", event_data)

-- local event_data = FrameTable.alloc_table()
-- event_data.item_tag = "bomb"
-- event_data.distance = 2
-- event_data.is_ping = true
-- dialogue_input:trigger_networked_dialogue_event("seen_item", event_data)

-- local event_data = FrameTable.alloc_table()
-- event_data.item_tag = "heal"
-- event_data.distance = 2
-- event_data.is_ping = true
-- dialogue_input:trigger_networked_dialogue_event("seen_item", event_data)

-- local event_data = FrameTable.alloc_table()
-- event_data.item_tag = "health_flask"
-- event_data.distance = 2
-- event_data.is_ping = true
-- dialogue_input:trigger_networked_dialogue_event("seen_item", event_data)

-- event_data = {
--     dialogue_name_nopre = "gameplay_healing_empire_soldier",
--     distance = 0,
--     height_distance = 0,
--     dialogue_name = "pwh_gameplay_healing_empire_soldier",
--     sound_event = "pwh_gameplay_healing_empire_soldier_01",
--     speaker_name = "witch_hunter",
--     speaker = local_player_unit

-- }
-- dialogue_input:trigger_dialogue_event("heard_speak", event_data)

-- dialogue_input:play_voice("pdr_gameplay_casual_quotes_03") --bardin sing
-- dialogue_input:play_voice("pdr_gameplay_globadier_guck_04") --Get out of hear
-- dialogue_input:play_voice("pdr_gameplay_globadier_guck_06") --pick up your feets, move!
-- dialogue_input:play_voice("pdr_objective_wizards_tower_commenting_paintings_04") --my assesment, umgak
-- dialogue_input:play_voice("pdr_gameplay_chieftain_banter_reply_03")
-- dialogue_input:play_voice("pdr_objective_wizards_tower_commenting_paintings_02")
-- dialogue_input:play_voice("pdr_objective_wizards_tower_commenting_paintings_03")

-- dialogue_input:play_voice("pwh_gameplay_activating_magic_weapon_offensive_04")
-- dialogue_input:play_voice("pwe_gameplay_friendly_fire_witch_hunter_04")
-- dialogue_input:play_voice("pwh_curse_01") --by the comet
-- dialogue_input:play_voice("pwh_curse_02") --thetanists arse
-- dialogue_input:play_voice("pwh_curse_03") --by all the crypts in sylvania
-- dialogue_input:play_voice("pwh_curse_04") --Malefic blasphemie
-- dialogue_input:play_voice("pwh_curse_05") --Demons Bell
-- dialogue_input:play_voice("pwh_curse_06") --archlectors tentacles
-- dialogue_input:play_voice("pwh_curse_07") --damn all to the 77 hells
-- dialogue_input:play_voice("pwh_curse_08") --shout and scum
-- dialogue_input:play_voice("pwh_curse_09") --rats in balefire
-- dialogue_input:play_voice("pwh_curse_10") --Fugmars Teeth
-- dialogue_input:play_voice("pwh_curse_11") -- Dead Mans pits
-- dialogue_input:play_voice("pwh_curse_12") --by the six holies
-- dialogue_input:play_voice("pwh_gameplay_self_heal_02") --Holy Sigmar, Bless this ravaged body
-- dialogue_input:play_voice("pwe_gameplay_low_on_health_06") --
-- dialogue_input:play_voice("pwe_gameplay_low_on_health_05") --
-- dialogue_input:play_voice("pdr_objective_interacting_with_objective_01") --
-- dialogue_input:play_voice("pwe_gameplay_armoured_enemy_witch_hunter") --
