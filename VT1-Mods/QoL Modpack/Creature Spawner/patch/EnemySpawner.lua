local mod, mod_name, oi = Mods.new_mod("EnemySpawner")

mod.widget_settings = {
	SPAWN_ENEMIES = {
		["save"] = "cb_spawning_spawn_enemy",
		["widget_type"] = "checkbox",
		["text"] = "Enemies",
		["default"] = false,
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
					"cb_spawning_enemy_switch",
					"cb_spawning_enemy_switch_modifiers",
					"cb_spawning_enemy_spawn",
					"cb_spawning_enemy_spawn_modifiers",
					"cb_spawning_enemy_despawn",
					"cb_spawning_enemy_despawn_modifiers",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_spawning_enemy_switch",
					"cb_spawning_enemy_switch_modifiers",
					"cb_spawning_enemy_spawn",
					"cb_spawning_enemy_spawn_modifiers",
					"cb_spawning_enemy_despawn",
					"cb_spawning_enemy_despawn_modifiers",
				}
			},
		},
	},
	HK_ENEMY_SWITCH = {
		["save"] = "cb_spawning_enemy_switch",
		["widget_type"] = "keybind",
		["text"] = "Next Breed",
		["default"] = {
			"o",
			oi.key_modifiers.NONE,
		},
		["exec"] = {"EnemySpawner", "action/switch_spawn"},
	},
	HK_ENEMY_SPAWN = {
		["save"] = "cb_spawning_enemy_spawn",
		["widget_type"] = "keybind",
		["text"] = "Spawn",
		["default"] = {
			"p",
			oi.key_modifiers.NONE,
		},
		["exec"] = {"EnemySpawner", "action/spawn"},
	},
	HK_ENEMY_DESPAWN = {
		["save"] = "cb_spawning_enemy_despawn",
		["widget_type"] = "keybind",
		["text"] = "Despawn All",
		["default"] = {
			"i",
			oi.key_modifiers.NONE,
		},
		["exec"] = {"EnemySpawner", "action/remove_all"},
	},
}

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()	
	Mods.option_menu:add_item("spawning", mod.widget_settings.SPAWN_ENEMIES, true)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_ENEMY_SWITCH)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_ENEMY_SPAWN)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_ENEMY_DESPAWN)
end

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()