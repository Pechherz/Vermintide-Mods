local mod_name = "BotImprovements"

--[[
	===Change Log===
Version 20221016 - Different Bots Experimental Branch by VernonKun
* This branch of the mod is to experiment with ideas and scripts that make bots act more similar to human players. This doesn't necessarily make bots better in terms of win rate, but hopefully would make bots more fun to play with in some sense, for example, human players will need more awareness to defend for themselves as bots don't always stick with humans. Change log below:
* Added bot paths in the form of "navmesh transitions" in some maps. This was a feature of an unreleased version of Different Bots in September 2021
* Gave bots more freedom to melee further rats, this includes increased forced regroup distance and melee decision range for trash rats
* Changed target selection, in particular bots prioritize trash rats attacking them to intercept their attacks
* Disabled follow positions when another human is too close to the followed human
* Increased ammo requirement for shooting ambients and increased effectiveness of the ambient shooting reduction option
* Implemented functionality for bots to consider map geometry when making some dodge decisions
* Partially rewritten defense decisions, so bots don't push for nearby teammates, and bots will try to dodge small number of attacks instead of blocking them
* Forced regroup based on proximity of teammates including bots
* Let bots pick up items more actively
* Let bots dodge while shooting or drinking healing draughts
* Stop bots from engaging melee enemies if stamina is low and teammates are far from the target
* Stop bots from rushing patrols unless they have good stamina traits and have enough stamina
* Let bots (try to) dodge assassins and packmasters (given sufficient special tokens)
* Let bots predict and avoid poison globe landing spot (TODO: check effect on rats)
* Bots don't move away from trash rats for optimal headshot distance to avoid baiting running attack (WIP: more engage position change)

TODO:
* Add more bot paths
* Sniping task distribution, check available ammo in clip etc.
* Check melee block cancel timing
* Improve ogre fighting behaviors if possible, e.g. consider path finding and map geometry when running away
* Read original AIBotGroupSystem._assign_destination_points
* Ranged AoE and penetration optimization
* Let bots ping specials (and not interact with special performance tokens...)
* Weapon usage consider traits
* No need to block cancel when swift slaying is active
* Make push attack
* Let bots pick up respawned players in some places
* Let bots dodge while drinking healing draughts and push beforehand if surrounded
* Check trash running attacks dodge timing
* Control bot dodge direction, especially during kiting
* Medkit command shouldn't require holding the key
* Let bots do jump shot
* When bot snipe specials, consider other body parts if head is not visible
* Revise melee weapon combo / attack decision
* Melee engage position based on self and target movement speed
* Dodge while charging attack etc.
* Bot dodges consider enemies' rotation mid attack
* Stop bots teleporting into ogre and SV attacks, or make them temporarily invincible
* Tweak defense decision based offense tokens (bots may stop attacking and so don't interrupt attacking rats)
* Improve bot melee engage positions
* Bots select melee weapon combo based on enemy positions etc.
* Make bots target non-staggered rats over staggered rats
* ...

Version 20220116 - The original version of Different Bots by Xq that this mod is based on.
Relevant link: https://steamcommunity.com/sharedfiles/filedetails/?id=2262580549
--]]

--[[
	===Original Acknowledgement===
	
	authors (as it is in original QoL bot file): grimalackt, iamlupo, walterr
	
	Changes from there to this version: Xq

	Bot Improvements.
	
	Special thanks to..

	Creators of Quality of Life Modpack and its associated mods. Without this package I wouldn't have gotten into modding in the first place. Thank you for your efforts to Vermintide.

	VernonKun for providing lots of ideas and the huge work he has done with testing the bots and recording the test runs during development.

	Zaphio for providing ideas and helping me out with lua & getting started with modding.


	Also thanks for testing & feedback (alphabetic order)..

	endrsgm
	Karl Power
	MistLight
	nesya
	Són
	SUMER
	Willow	
--]]

local DEBUG_ENABLED							= false
--edit--
-- local ENABLE_DEBUG_FEEDS					= false
local ENABLE_DEBUG_FEEDS					= true
--edit--
local DEBUG_PARAMETER_20191029				= false
local DEBUG_NO_RANGED_ATTACKS				= false
local DEBUG_NO_MELEE_ATTACKS				= false
local DEBUG_ALWAYS_LIGHT_MELEE_ATTACKS		= false
local DEBUG_ALWAYS_HEAVY_MELEE_ATTACKS		= false	-- overrides DEBUG_ALWAYS_LIGHT_MELEE_ATTACKS
local ENABLE_PICKUP_ON_PING_DEBUG_OUTPUT	= false

local MANUAL_HEAL_DISABLED = 1
local MANUAL_HEAL_OPTIONAL = 2
local MANUAL_HEAL_MANDATORY = 3

local oi = OptionsInjector

BotImprovements = {
	SETTINGS = {
		FILE_ENABLED = {
			["save"] = "cb_db_bot_improvements_file_enabled",
			["widget_type"] = "stepper",
			["text"] = "Bot improvements enabled",
			["tooltip"] =  "Master enable bit for all bot improvements\n" ..
				"Set this OFF to disable all bot improvements",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		BOT_TO_AVOID = {
			["save"] = "cb_db_bot_improvements_bot_to_avoid",
			["widget_type"] = "stepper",
			["text"] = "Choose Least Preferred Bot",
			["tooltip"] = "Choose the bot which by default you don't want in your lobby.\n" ..
				"A player joining / leaving may still cause the bot to appear.",
			["value_type"] = "number",
			["options"] = {
				-- 1=WH, 2=BW, 3=DR, 4=WE, 5=ES
				{text = "Victor Saltzpyre", value = 1},
				{text = "Sienna Fuegonasus", value = 2},
				{text = "Bardin Goreksson", value = 3},
				{text = "Kerillian", value = 4},
				{text = "Markus Kruber", value = 5}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		OVERRIDE_LEFT_PLAYER = {
			["save"] = "cb_db_override_left_player",
			["widget_type"] = "stepper",
			["text"] = "Override Leaving Player Bot",
			["tooltip"] =  "Override Leaving Player Bot\n" ..
				"Reverts back to default bot if a player leaves with the normally unused bot (Saltzpyre or Sienna, depending on above setting).",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default first option is enabled. In this case On
		},
		NO_CHASE_RATLING = {
			["save"] = "cb_db_bot_improvements_no_chase_ratling",
			["widget_type"] = "stepper",
			["text"] = "Bots Should Not Chase Ratlings",
			["tooltip"] = "Bots Should Not Chase Ratlings\n" ..
				"Prevents bots from running off to melee Ratling Gunners.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default first option is enabled. In this case ON
		},
		NO_CHASE_GLOBADIER = {
			["save"] = "cb_db_bot_improvements_no_chase_globadier",
			["widget_type"] = "stepper",
			["text"] = "Bots Should Not Chase Globadiers",
			["tooltip"] = "Bots Should Not Chase Globadiers\n" ..
				"Prevents bots from running off to melee Globadiers.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default first option is enabled. In this case ON
		},
		NO_SEEK_COVER = {
			["save"] = "cb_db_bot_improvements_no_seek_cover",
			["widget_type"] = "stepper",
			["text"] = "Bots Should Ignore Ratling Fire",
			["tooltip"] = "Bots Should Ignore Ratling Fire\n" ..
				"Prevents bots from running off to seek cover from Ratling " ..
				"Gunner fire, even if they are being shot (use with caution).",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default first option is enabled. In this case ON
		},
		BETTER_MELEE = {
			["save"] = "cb_db_bot_improvements_better_melee",
			["widget_type"] = "stepper",
			["text"] = "Improved Bot Melee Choices",
			["tooltip"] = "Improved Bot Melee Choices\n" ..
				"Improves bots' decision-making about which melee attack to use.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		BETTER_RANGED = {
			["save"] = "cb_db_bot_improvements_better_ranged",
			["widget_type"] = "stepper",
			["text"] = "Improved Bot Ranged Behavior",
			["tooltip"] = "Improved ranged behavior\n" ..
				"Improves bot aim speed and willingness to shoot",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		VENT_ALLOWED = {
			["save"] = "cb_db_vent_allowed",
			["widget_type"] = "stepper",
			["text"] = "Bots Vent Overcharge",
			["tooltip"] =  "Heat weapon handling\n" ..
				"If enabled, bots are allowed to vent heat off from their heat based ranged weapons in the same way they'd reload their ammo based weapons.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default second option is enabled. In this case ON
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_db_vent_hp_threshold",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_db_vent_hp_threshold",
					}
				},
			},
		},
        VENT_HP_THRESHOLD = {
			["save"]		= "cb_db_vent_hp_threshold",
			["widget_type"]	= "slider",
			["text"]		= "Vent Health Threshold",
			["tooltip"]		= "Heat management\n" ..
							  "Defines health threshold below which the bot stops trading its health for vented overcharge.",
			["range"]		= {0, 100},
			["default"]		= 75,
	    },
		SUB_GROUP_HEALING = {
			["save"] = "cb_db_sub_group_healing",
			["widget_type"] = "dropdown_checkbox",
			["text"] = "Healing Related Options",
			["default"] = false,
			["hide_options"] = {
				{
					true,
					mode = "show",
					options = {
						"cb_db_bot_improvements_manual_heal",
						"cb_bot_improvements_manual_heal_toggle",
						-- "cb_db_low_hp_autoheal",
						-- "cb_db_low_hp_autoheal_toggle",
						"cb_db_no_manual_heal_optimization",
						"cb_db_heal_only_if_wounded",
						"cb_db_heal_only_if_wounded_toggle",
						"cb_db_max_healing_distance",
						"cb_db_pass_draughts_to_humans",
						"cb_db_pass_draughts_to_humans_hotkey",
					},
				},
				{
					false,
					mode = "hide",
					options = {
						"cb_db_bot_improvements_manual_heal",
						"cb_bot_improvements_manual_heal_toggle",
						-- "cb_db_low_hp_autoheal",
						-- "cb_db_low_hp_autoheal_toggle",
						"cb_db_no_manual_heal_optimization",
						"cb_db_heal_only_if_wounded",
						"cb_db_heal_only_if_wounded_toggle",
						"cb_db_max_healing_distance",
						"cb_db_pass_draughts_to_humans",
						"cb_db_pass_draughts_to_humans_hotkey",
					},
				},
			},
		},
		MANUAL_HEAL = {
			["save"] = "cb_db_bot_improvements_manual_heal",
			["widget_type"] = "dropdown",
			["text"] = "Manual Control of Bot Healing",
			["tooltip"] = "Manual Control of Bot Healing\n" ..
				"Allows manual control of bot healing.\n\n" ..
				"Holding numpad 0 will make one of the bots heal you, if it has a medkit.\n" ..
				"Holding numpad 1, 2, or 3 will make a bot heal the hero at the 1st, 2nd, or 3rd " ..
				"position on the HUD (which may be itself).\n\n" ..
				"-- OFF --\nThe feature is disabled, bots heal automatically as usual.\n\n" ..
				"-- AS WELL AS AUTO --\nBots will still heal automatically, but you can also " ..
					"manually force them to heal.\n\n" ..
				"-- INSTEAD OF AUTO --\nBots will only heal if you manually force them to do so.",
			["value_type"] = "number",
			["options"] = {
				{text = "Off", value = MANUAL_HEAL_DISABLED},
				{text = "As Well as Auto", value = MANUAL_HEAL_OPTIONAL},
				{text = "Instead of Auto", value = MANUAL_HEAL_MANDATORY},
			},
			["default"] = 2, -- Default second option is enabled. In this case MANUAL_HEAL_OPTIONAL
			["hide_options"] = {
				{
					1,
					mode = "hide",
					options = {
						"cb_db_bot_improvements_manual_heal_hotkey1",
						"cb_db_bot_improvements_manual_heal_hotkey2",
						"cb_db_bot_improvements_manual_heal_hotkey3",
						"cb_db_bot_improvements_manual_heal_hotkey4",
					}
				},
				{
					2,
					mode = "show",
					options = {
						"cb_db_bot_improvements_manual_heal_hotkey1",
						"cb_db_bot_improvements_manual_heal_hotkey2",
						"cb_db_bot_improvements_manual_heal_hotkey3",
						"cb_db_bot_improvements_manual_heal_hotkey4",
					}
				},
				{
					3,
					mode = "show",
					options = {
						"cb_db_bot_improvements_manual_heal_hotkey1",
						"cb_db_bot_improvements_manual_heal_hotkey2",
						"cb_db_bot_improvements_manual_heal_hotkey3",
						"cb_db_bot_improvements_manual_heal_hotkey4",
					}
				},
			},
		},
		MANUAL_HEAL_KEY1 = {
			["save"] = "cb_db_bot_improvements_manual_heal_hotkey1",
			["widget_type"] = "modless_keybind",
			["text"] = "Heal First Hero",
			["default"] = {
				"numpad 0",
			},
		},
		MANUAL_HEAL_KEY2 = {
			["save"] = "cb_db_bot_improvements_manual_heal_hotkey2",
			["widget_type"] = "modless_keybind",
			["text"] = "Heal Second Hero",
			["default"] = {
				"numpad 1",
			},
		},
		MANUAL_HEAL_KEY3 = {
			["save"] = "cb_db_bot_improvements_manual_heal_hotkey3",
			["widget_type"] = "modless_keybind",
			["text"] = "Heal Third Hero",
			["default"] = {
				"numpad 2",
			},
		},
		MANUAL_HEAL_KEY4 = {
			["save"] = "cb_db_bot_improvements_manual_heal_hotkey4",
			["widget_type"] = "modless_keybind",
			["text"] = "Heal Fourth Hero",
			["default"] = {
				"numpad 3",
			},
		},
		NO_MANUAL_HEAL_OPTIMIZATION = {
			["save"]		= "cb_db_no_manual_heal_optimization",
			["widget_type"] = "checkbox",
			["text"]		= "Manual Healing Ignores Optimization",
			["tooltip"]		= "Healing behavior\n"..
							  "If checked, bots won't try to optimize heal usage when manually commanded to use heals.",
			["default"]		= false,
		},
		-- HEALSHARE_NEEDS_WOUNDED = {
			-- ["save"]		= "cb_db_healshare_needs_wounded",
			-- ["widget_type"] = "checkbox",
			-- ["text"]		= "Healshare Requires Wounded Teammate",
			-- ["tooltip"]		= "Healing behavior\n"..
							  -- "If checked bot's use healshare to heal others only if there is at least one wounded teammate. Note! on Deathwish difficulty this setting is automatically considered \"off\".",
			-- ["default"]		= false,
		-- },
		HEAL_ONLY_IF_WOUNDED = {
			["save"]		= "cb_db_heal_only_if_wounded",
			["widget_type"] = "dropdown",
			["text"]		= "Heal Only If Wounded",
			["tooltip"]		= "Healing behavior\n"..
							  "Select if bots should be using healing items only when wounded. \"If healshare\" means that bot(s) carrying healshare trinket won't heal unless they or one of their teammates is wounded. \"Always\" Means bots never heal unless they are wounded.\n\nNote!\n* This affects only automatic healing behavior.\n* On Deathwish difficulty this setting is automatically considered \"off\".",
			["value_type"]	= "number",
			["options"]		=
			{
				{text = "If Healshare", value = 1},
				{text = "Always", value = 2},
				{text = "Off", value = 3},
			},
			["default"]		= 1, -- Default first option, in this case "If Healshare"
		},
        MAX_HEALING_DISTANCE = {
			["save"]		= "cb_db_max_healing_distance",
			["widget_type"]	= "slider",
			["text"]		= "Healing Check Distance",
			["tooltip"]		= "Healing behavior\n" ..
							  "Bots that are past this distance from the heal target won't try to heal the target and won't be considered when determining which heal should be used.\n\n" ..
							  "Bots use this range also when forced to find a recipient to pass healing draughts to.",
			["range"]		= {3, 20},
			["default"]		= 5,
	    },
		PASS_DRAUGHTS_TO_HUMANS = {
			["save"]		= "cb_db_pass_draughts_to_humans",
			["widget_type"]	= "dropdown",
			["text"]		= "Bots Pass Draughts to Humans",
			["tooltip"]		= "Bot item management:\n" ..
							  "Choose when bots should be passing healing draughts to humans. \n " ..
							  "\"Always\" option means that the bots always pass draughts to humans. \n " ..
							  "\"Always To Healshare\" option means that the bots always pass draughts to humans with healshare equipped, but won't do so otherwise. \n " ..
							  "\"Never\" option means that the bots never pass draughts to humans. \n " ..
							  "\"Default\" option means using the default heal passing logic.\n\n" ..
							  "Note! Forcing bots to pass draughts with hotkey ignores this setting.",
			["value_type"]	= "number",
			["options"]		=
			{
				{text = "Always", value = 1},
				{text = "Always To Healshare", value = 2},
				{text = "Never", value = 3},
				{text = "Default", value = 4},
			},
			["default"]		= 3, -- Default second option, in this case "Auto"
		},
		PASS_DRAUGHTS_TO_HUMANS_HOTKEY = {
			["save"] = "cb_db_pass_draughts_to_humans_hotkey",
			["widget_type"] = "modless_keybind",
			["text"] = "Force Bots To Pass Heals To Humans With Key",
			["default"] = {
				"numpad 6",
			},
		},
		LOOT_GRIMOIRES = {
			["save"] = "cb_db_bot_improvements_loot_grimoires",
			["widget_type"] = "stepper",
			["text"] = "Bots Pick Up Pinged Grimoires",
			["tooltip"] = "Bots Pick Up Pinged Grimoires\n" ..
				"Allows bots to pick up a grimoire when a human player pings the grimoire.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		LOOT_TOMES = {
			["save"] = "cb_db_bot_improvements_loot_tomes",
			["widget_type"] = "stepper",
			["text"] = "Bots Pick Up Pinged Tomes",
			["tooltip"] = "Bots Pick Up Pinged Tomes\n" ..
				"Allows bots to pick up a tome when a human player pings the tome.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		FORCE_LOOT_PINGED_ITEM = {
			["save"] = "cb_db_force_loot_pinged_item",
			["widget_type"] = "modless_keybind",
			["text"] = "Force Loot Key",
			["tooltip"] = "Force loot key\n" ..
				"Forces the bots to ignore human inventory and\n"..
				"pick up the pinged item if they can",
			["default"] = {
				"numpad 5",
			},
		},
		SMALL_AMMO_NEEDS_FORCING = {
			["save"] = "cb_db_small_ammo_needs_forcing",
			["widget_type"] = "stepper",
			["text"] = "Bots Need Forcing To Pick Small Ammo",
			["tooltip"] = "Item management\n" ..
				"When enabled and playing solo, the Force Loot Key needs to be pressed for bots to pick up pinged small ammo refills. Note! Force Loot Key is always needed when playing with multiple non disabled humans in the lobby.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default second option is enabled. In this case Off
		},
		HP_BASED_LOOT_PINGED_HEAL = {
			["save"] = "cb_db_hp_based_loot_pinged_heal",
			["widget_type"] = "stepper",
			["text"] = "Custom Pinged Heal Priority",
			["tooltip"] = "Item management\n" ..
				"Allows the player to customize the heal pickup priority when\n"..
				"bots pick up heals due to the force loot feature.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_db_hp_based_health_weight",
						"cb_db_hp_based_wounded_weight",
						"cb_db_hp_based_grim_weight",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_db_hp_based_health_weight",
						"cb_db_hp_based_wounded_weight",
						"cb_db_hp_based_grim_weight",
					}
				},
			},
		},
        HP_BASED_HEALTH_WEIGHT = {
			["save"]		= "cb_db_hp_based_health_weight",
			["widget_type"]	= "slider",
			["text"]		= "Health weight factor",
			["tooltip"]		= "Behavior modifier\n" ..
							  "Define how much current hitpoint percentage of the bot should matter when using custom heal pickup priority.",
			["range"]		= {0, 5},
			["default"]		= 3,
	    },
        HP_BASED_WOUNDED_WEIGHT = {
			["save"]		= "cb_db_hp_based_wounded_weight",
			["widget_type"]	= "slider",
			["text"]		= "Wounded weight factor",
			["tooltip"]		= "Behavior modifier\n" ..
							  "Define how much wounded state of the bot (being on white hp) should matter when using custom heal pickup priority.",
			["range"]		= {0, 5},
			["default"]		= 3,
	    },
        HP_BASED_GRIM_WEIGHT = {
			["save"]		= "cb_db_hp_based_grim_weight",
			["widget_type"]	= "slider",
			["text"]		= "Grimoire weight factor",
			["tooltip"]		= "Behavior modifier\n" ..
							  "Define how much a grimoire carried by the bot should matter when using custom heal pickup priority.",
			["range"]		= {0, 5},
			["default"]		= 3,
	    },
		KEEP_TOMES = {
			["save"] = "cb_db_bot_improvements_keep_tomes",
			["widget_type"] = "stepper",
			["text"] = "Bots Keep Tomes",
			["tooltip"] = "Bots Keep Tomes\n" ..
				"Stop bots from exchanging tomes for healing items, \n"..
				"unless the healing item is pinged.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		PING_STORMVERMINS = {
			["save"] = "cb_db_bot_improvements_ping_stormvermins",
			["widget_type"] = "stepper",
			["text"] = "Bots Ping Attacking Stormvermins",
			["tooltip"] = "Bots Ping Attacking Stormvermins\n" ..
				"Allows bots to ping stormvermins that are targeting them. " ..
				"Limited to one stormvermin at a time.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		FOLLOW = {
			["save"] = "cb_db_follow_host",
			["widget_type"] = "stepper",
			["text"] = "Follow the host",
			["tooltip"] =  "Follow Host\n" ..
				"Bots will prioritize following the host.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default first option is enabled. In this case ON
		},
		CONSERVE_SNIPER_AMMO = {
			["save"] = "cb_db_bot_improvements_conserve_sniper_ammo",
			["widget_type"] = "stepper",
			["text"] = "Conserve Sniper Ammo",
			["tooltip"] =  "Sniper weapon handling\n" ..
				"Disallow bots to shoot clan & slave rats with sniper type weapons such as handguns.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default second option is enabled. In this case ON
		},
		HELP_WITH_BREAKABLES_OBJECTIVES = {
			["save"] = "cb_db_help_with_breakables_objectives",
			["widget_type"] = "stepper",
			["text"] = "Bots attack breakable objectives",
			["tooltip"] =  "Breakable objectives\n" ..
				"If enabled, bots will attack breakable objectives once the breakables have been damaged.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default second option is enabled. In this case ON
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_db_breakables_objectives_threshold",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_db_breakables_objectives_threshold",
					}
				},
			},
		},
        BREAKABLES_OBJECTIVES_THRESHOLD = {
			["save"]		= "cb_db_breakables_objectives_threshold",
			["widget_type"]	= "slider",
			["text"]		= "Breakable objective health threshold",
			["tooltip"]		= "Breakable objectives\n" ..
							  "Defines health threshold for breakable objectives below which bots don't launch any new attacks against it. Note! Attacks which the bots have already started will usually still hit the breakable.",
			["range"]		= {0, 100},
			["default"]		= 0,
	    },
		DEFEND_MISSION_OBJECTIVES = {
			["save"] = "cb_db_defend_mission_objectives",
			["widget_type"] = "stepper",
			["text"] = "Defend mission objectives",
			["tooltip"] =  "Objective defense\n" ..
				"Bots will pay more attention to mission defense objectives \n" ..
				"when player they are following is close enough to them",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default second option is enabled. In this case On
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_db_defend_mission_objectives_toggle_key_enable",
						"cb_db_defend_mission_objectives_toggle_key",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_db_defend_mission_objectives_toggle_key_enable",
						"cb_db_defend_mission_objectives_toggle_key",
					}
				},
			},
		},
		DEFEND_MISSION_OBJECTIVES_TOGGLE_KEY_ENABLE = {
			["save"] = "cb_db_defend_mission_objectives_toggle_key_enable",
			["widget_type"] = "stepper",
			["text"] = "Enable hotkey for objective defense toggle.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 1, -- Off
		},
		DEFEND_MISSION_OBJECTIVES_TOGGLE_KEY = {
			["save"] = "cb_db_defend_mission_objectives_toggle_key",
			["widget_type"] = "modless_keybind",
			["text"] = "Toggle objective defense",
			["default"] = {
				"numpad 4",
			},
		},
		AUTOEQUIP = {
			["save"] = "cb_db_autoequip",
			["widget_type"] = "stepper",
			["text"] = "Autoequip bots from a loadout slot",
			["tooltip"] =  "Autoequip bots from a loadout slot\n" ..
				"Autoequip bots from a dedicated loadout slot.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_db_autoequip_slot",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_db_autoequip_slot",
					}
				},
			},
		},
		AUTOEQUIP_SLOT = {
			["save"] = "cb_db_autoequip_slot",
			["widget_type"] = "stepper",
			["text"] = "Loadout slot to use",
			["tooltip"] = "Loadout slot to use\n" ..
				"Autoequip bot from this loadout slot.\n" ..
				"ONLY CHANGEABLE IN INN!",
			["value_type"] = "number",
			["options"] = (function()
					local stepper = {}
					for i=1,9 do
						table.insert(stepper, {text = tostring(i), value = i})
					end
					return stepper
					end)(),
			["default"] = 1, -- Default to 1
			["disabled_outside_inn"] = true, -- disabled_outside_inn setting only implemented on stepper widgets!
		},
		BOT_INFO_GUARD_BREAK = {
			["save"]		= "cb_db_bot_info_guard_break",
			["widget_type"]	= "stepper",
			["text"]		= "Warning on Bot Guard Break",
			["tooltip"]		= "Warning message:\n"..
							  "Print a local chat line when a bot's guard is broken",
			["value_type"]	= "boolean",
			["options"]		=
			{
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"]		= 2, -- Default = first option. In this case ON
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_db_bot_info_guard_break_global_message",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_db_bot_info_guard_break_global_message",
					}
				},
			},
		},
		BOT_INFO_GUARD_BREAK_GLOBAL_MESSAGE = {
			["save"]		= "cb_db_bot_info_guard_break_global_message",
			["widget_type"] = "checkbox",
			["text"]		= "Global warning message",
			["tooltip"]		= "Message visibility:\n"..
							  "Make the guard break message visible to all players in the lobby. Adds <> around the message.",
			["default"]		= false,
		},
		BOT_AGGRESSIVE_MELEE_MODE = {
			["save"]		= "cb_db_bot_melee_aggressive_mode",
			["widget_type"]	= "stepper",
			["text"]		= "Aggressive Melee Behavior",
			["tooltip"]		= "Behavior modifier:\n" .. 
							  "Increases the bots' allowance to attack with melee weapons at the cost of " .. 
							  "increased risk to take hits in return. Affects mostly cataclysm and above.",
			["value_type"]	= "boolean",
			["options"]		=
			{
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"]		= 2, -- Default = first option. In this case On
		},
		CC_ATTACKS_ALLOWED = {
			["save"]		= "cb_db_bot_cc_attacks_allowed",
			["widget_type"]	= "stepper",
			["text"]		= "Allow bots to use crowd control attacks.",
			["tooltip"]		= "Behavior modifier:\n" ..
				"Allows bots to use charged attacks with select melee weapons to control crowds. " ..
				"Note that the nature of charged attacks may lead them being more suspectible to taking damage.\n",
			["value_type"]	= "boolean",
			["options"]		=
			{
				{text = "On", value = true},
				{text = "Off", value = false},
			},
			["default"]		= 1, -- Default second option, in this case ON
			["hide_options"] =
			{
				{
					true,
					mode	= "show",
					options	=
					{
						"cb_db_cc_attacks_shield_hammer",
						"cb_db_cc_attacks_shield_axe",
						"cb_db_cc_attacks_shield_mace",
						"cb_db_cc_attacks_shield_sword",
						"cb_db_bot_cc_attacks_2h_hammers",
					}
				},
				{
					false,
					mode	= "hide",
					options	=
					{
						"cb_db_cc_attacks_shield_hammer",
						"cb_db_cc_attacks_shield_axe",
						"cb_db_cc_attacks_shield_mace",
						"cb_db_cc_attacks_shield_sword",
						"cb_db_bot_cc_attacks_2h_hammers",
					}
				},
			},
		},
		CC_ATTACKS_SHIELD_HAMMER = {
			["save"]		= "cb_db_cc_attacks_shield_hammer",
			["widget_type"] = "checkbox",
			["text"]		= "Allow CC attacks with dwarf shield & hammer",
			["default"]		= true,
		},
		CC_ATTACKS_SHIELD_AXE = {
			["save"]		= "cb_db_cc_attacks_shield_axe",
			["widget_type"] = "checkbox",
			["text"]		= "Allow CC attacks with dwarf shield & axe",
			["default"]		= true,
		},
		CC_ATTACKS_SHIELD_MACE = {
			["save"]		= "cb_db_cc_attacks_shield_mace",
			["widget_type"] = "checkbox",
			["text"]		= "Allow CC attacks with soldier shield & mace",
			["default"]		= true,
		},
		CC_ATTACKS_SHIELD_SWORD = {
			["save"]		= "cb_db_cc_attacks_shield_sword",
			["widget_type"] = "checkbox",
			["text"]		= "Allow CC attacks with soldier shield & sword",
			["default"]		= true,
		},
		CC_ATTACKS_2H_HAMMERS = {
			["save"]		= "cb_db_bot_cc_attacks_2h_hammers",
			["widget_type"] = "checkbox",
			["text"]		= "Allow CC attacks with two-hand hammers",
			["default"]		= true,
		},
		KB_AGAINST_ARMOR = {
			["save"]		= "cb_db_bot_kb_against_armor",
			["widget_type"]	= "stepper",
			["text"]		= "Killing Blow Against Armor",
			["tooltip"]		= "Behavior modifier:\n" ..
							  "Allows bots to use non armor piercing light attacks against armored targets if their melee weapon has Killing Blow trait.",
			["value_type"]	= "boolean",
			["options"]		=
			{
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"]		= 2, -- Default = first option. In this case ON
		},
		PERFORMANCE_REDUCTION_SHOW = {
			["save"]		= "cb_db_performance_reduction_show",
			["widget_type"]	= "stepper",
			["text"]		= "Bot performance reduction",
			["tooltip"]		= "Behavior modifier:\n" ..
							  "Are bots taking away your fun? With these settings you can define the performance maximum for each field.",
			["value_type"]	= "boolean",
			["options"]		=
			{
				{text = "Show", value = true},
				{text = "Hide", value = false},
			},
			["default"]		= 2, -- Default second option, in this case "hide"
			["hide_options"] =
			{
				{
					true,
					mode	= "show",
					options	=
					{
						"cb_db_cap_sliders_melee",
						"cb_db_cap_sliders_ranged",
						"cb_db_cap_sliders_specials",
						"cb_db_ignore_specials_pings",
						"cb_db_reduce_ambient_shooting",
					}
				},
				{
					false,
					mode	= "hide",
					options	=
					{
						"cb_db_cap_sliders_melee",
						"cb_db_cap_sliders_ranged",
						"cb_db_cap_sliders_specials",
						"cb_db_ignore_specials_pings",
						"cb_db_reduce_ambient_shooting",
					}
				},
			},
		},
        CAP_SLIDERS_MELEE = {
			["save"]		= "cb_db_cap_sliders_melee",
			["widget_type"]	= "slider",
			["text"]		= "Melee performance maximum",
			["tooltip"]		= "Bot melee performance\n" ..
							  "Maximum allowed melee performance for bots.",
			["range"]		= {0, 100},
			["default"]		= 100,
	    },
        CAP_SLIDERS_RANGED = {
			["save"]		= "cb_db_cap_sliders_ranged",
			["widget_type"]	= "slider",
			["text"]		= "Ranged performance maximum",
			["tooltip"]		= "Bot ranged performance\n" ..
							  "Maximum allowed ranged performance for bots.",
			["range"]		= {0, 100},
			["default"]		= 100,
	    },
        CAP_SLIDERS_SPECIALS = {
			["save"]		= "cb_db_cap_sliders_specials",
			["widget_type"]	= "slider",
			["text"]		= "Specials performance maximum",
			["tooltip"]		= "Bot specials performance\n" ..
							  "Maximum allowed specials performance for bots. Note that 0 here just sets their performance against special enemies to minimum. It doesn't make them fully passive in this field.",
			["range"]		= {0, 100},
			["default"]		= 100,
	    },
        IGNORE_SPECIALS_PINGS = {
			["save"]		= "cb_db_ignore_specials_pings",
			["widget_type"] = "checkbox",
			["text"]		= "Bots ignore special pings",
			["tooltip"]		= "Bot specials performance\n" ..
							  "When enabled, pinging a special enemy doesn't speed up bots' reaction time against the enemy anymore.",
			["default"]		= false,
	    },
        REDUCE_AMBIENT_SHOOTING = {
			["save"]		= "cb_db_reduce_ambient_shooting",
			["widget_type"] = "checkbox",
			["text"]		= "Reduce ambient shooting",
			["tooltip"]		= "Bot shooting behavior\n" ..
							  "When enabled, bots will be less trigger happy when it comes to ambient enemies.",
			["default"]		= true,
	    },
		TRADING_PREFER_ENABLE = {
			["save"]		= "cb_db_trading_prefer_enable",
			["widget_type"]	= "stepper",
			["text"]		= "Enable Bot Trading Preferences",
			["tooltip"]		= "Bot item management:\n" ..
							  "Allows you to set preferences which type of potions / bombs you'd prefer bots to give you. The bots will still pass you other types as well if none of them carries the preferred type or the bot carrying the preferred type is too far away.",
			["value_type"]	= "boolean",
			["options"]		=
			{
				{text = "On", value = true},
				{text = "Off", value = false},
			},
			["default"]		= 2, -- Default second option, in this case "Off"
			["hide_options"] =
			{
				{
					false,
					mode = "hide",
					options =
					{
						"cb_db_trading_prefer_potion",
						"cb_db_trading_prefer_grenade",
						"cb_db_trading_prefer_max_distance",
					}
				},
				{
					true,
					mode = "show",
					options =
					{
						"cb_db_trading_prefer_potion",
						"cb_db_trading_prefer_grenade",
						"cb_db_trading_prefer_max_distance",
					}
				},
			},
		},
		TRADING_PREFER_POTION =
		{
			["save"] = "cb_db_trading_prefer_potion",
			["widget_type"] = "dropdown",
			["text"] = "Human Preferred Potion",
			["tooltip"] = "Potion preferred by humans\n" ..
				"Choose which potion you'd like the bots to pass humans first. The bots will still pass other types if none of them carries the requested type or the bot carrying the requested type is too far away. Different potion option makes the bots give different type of potion than what was last given to them.",
			["value_type"] = "number",
			["options"] =
			{
				{text = "No Preference",		value = 0},
				{text = "Strength Potion",		value = 1},
				{text = "Speed Potion",			value = 2},
				{text = "Different Potion",		value = 3},
			},
			["default"] = 1, -- Default first option (no preference)
		},
		TRADING_PREFER_GRENADE =
		{
			["save"] = "cb_db_trading_prefer_grenade",
			["widget_type"] = "dropdown",
			["text"] = "Human Preferred Grenade",
			["tooltip"] = "Grenade preferred by humans\n" ..
				"Choose which grenade you'd like the bots to pass humans first. The bots will still pass other types if none of them carries the requested type or the bot carrying the requested type is too far away. Different grenade option makes the bots give different type of grenade than what was last given to them.",
			["value_type"] = "number",
			["options"] =
			{
				{text = "No Preference",		value = 0},
				{text = "Frag Grenade",			value = 1},
				{text = "Fire Grenade",			value = 2},
				{text = "Different Grenade",	value = 3},
			},
			["default"] = 1, -- Default first option (no preference)
		},
        TRADING_PREFER_MAX_DISTANCE =
		{
			["save"]		= "cb_db_trading_prefer_max_distance",
			["widget_type"]	= "slider",
			["text"]		= "Trading Preference Maximum Distance",
			["tooltip"]		= "Preference distance\n" ..
							  "Defines the distance past which the bot(s) carrying the preferred item type is considered too far away. Once so, other bots are allowed to pass you non-preferred items too.",
			["range"]		= {4, 20},
			["default"]		= 20,
	    },
		
		--
		--
		NO_SEEK_COVER_TOGGLE = {
			["save"] = "cb_bot_improvements_no_seek_cover_toggle",
			["widget_type"] = "keybind",
			["text"] = "Toggle Ignore Ratling Fire",
			["default"] = {
				"numpad 6",
			},
			["exec"] = {"patch/action", "bot_no_seek_cover_toggle"},
		},
		MANUAL_HEAL_TOGGLE = {
			["save"] = "cb_bot_improvements_manual_heal_toggle",
			["widget_type"] = "keybind",
			["text"] = "Toggle Automatic Healing",
			["default"] = {
				"numpad .",
			},
			["exec"] = {"patch/action", "bot_auto_heal_toggle"},
		},
		LOOT_AMMO_CRATE = {
			["save"] = "cb_bot_ammo_loot_crate",
			["widget_type"] = "stepper",
			["text"] = "Bots Pick Up Pinged Ammo Crates",
			["tooltip"] = "Bots Pick Up Pinged Ammo Crates\n" ..
				"Bots will refill their ammo when a human player is near a pinged ammo crate.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		LOOT_AMMO_SMALL = {
			["save"] = "cb_bot_ammo_loot_small",
			["widget_type"] = "stepper",
			["text"] = "Bots Pick Up Pinged Small Ammo",
			["tooltip"] = "Bots Pick Up Pinged Small Ammo\n" ..
				"Bots will pick up a small ammo refill when a human player pings it. " ..
				"Bots will only pick up ammo when no human players are missing ammo.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1,
		},
		LOOT_AMMO_SMALL_TOGGLE = {
			["save"] = "cb_bot_ammo_loot_small_toggle",
			["widget_type"] = "keybind",
			["text"] = "Toggle Small Ammo Pickup",
			["default"] = {
				"numpad 7",
			},
			["exec"] = {"patch/action", "bot_loot_ammo_small_toggle"},
		},
		KEEP_TOMES_TOGGLE = {
			["save"] = "cb_bot_improvements_keep_tomes_toggle",
			["widget_type"] = "keybind",
			["text"] = "Toggle Keep Tomes",
			["default"] = {
				"numpad 4",
			},
			["exec"] = {"patch/action", "bot_keep_tomes_toggle"},
		},
		FOLLOW_TOGGLE = {
			["save"] = "cb_follow_host_toggle",
			["widget_type"] = "keybind",
			["text"] = "Toggle Follow Host",
			["default"] = {
				"numpad 5",
			},
			["exec"] = {"patch/action", "bot_follow_host_toggle"},
		},
		TELEPORT_KEY = {
			["save"] = "cb_bot_improvements_force_teleport_hotkey",
			["widget_type"] = "keybind",
			["text"] = "Force Bots to Teleport to Host (if alive)",
			["default"] = {
				"numpad +",
			},
			["exec"] = {"patch/action", "callbots"},
		},
		LOW_HP_AUTOHEAL = {
			["save"]		= "cb_db_low_hp_autoheal",
			["widget_type"] = "checkbox",
			["text"]		= "Low HP Autoheal",
			["tooltip"]		= "Healing behavior\n"..
							  "If checked, bots will automatically heal when under 25% HP. On Deathwish difficulty this setting is automatically considered \"on\".",
			["default"]		= false,
		},
		LOW_HP_AUTOHEAL_TOGGLE = {
			["save"]		= "cb_db_low_hp_autoheal_toggle",
			["widget_type"] = "keybind",
			["text"]		= "Toggle Low HP Autoheal",
			["default"] = {
				"numpad 4",
			},
			["exec"] = {"patch/action", "bot_low_hp_auto_heal_toggle"},
		},
		HEAL_ONLY_IF_WOUNDED_TOGGLE = {
			["save"]		= "cb_db_heal_only_if_wounded_toggle",
			["widget_type"] = "keybind",
			["text"]		= "Toggle Heal Only If Wounded",
			["default"] = {
				"numpad 4",
			},
			["exec"] = {"patch/action", "bot_heal_only_if_wounded_toggle"},
		},
	},
}

local me = BotImprovements

local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings

-- ############################################################################################################
-- ##### Options ##############################################################################################
-- ############################################################################################################
--[[
	Create options
--]]

BotImprovements.create_options = function()
	Mods.option_menu:add_group("bot_improvements", "Bot Improvements")

	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.FILE_ENABLED, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BOT_TO_AVOID, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.OVERRIDE_LEFT_PLAYER, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.AUTOEQUIP, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.AUTOEQUIP_SLOT)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BETTER_MELEE, true)
	-- Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BOT_AGGRESSIVE_MELEE_MODE, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BOT_INFO_GUARD_BREAK, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BOT_INFO_GUARD_BREAK_GLOBAL_MESSAGE)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CC_ATTACKS_ALLOWED, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CC_ATTACKS_SHIELD_HAMMER)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CC_ATTACKS_SHIELD_AXE)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CC_ATTACKS_SHIELD_MACE)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CC_ATTACKS_SHIELD_SWORD)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CC_ATTACKS_2H_HAMMERS)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.KB_AGAINST_ARMOR, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BETTER_RANGED, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.VENT_ALLOWED, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.VENT_HP_THRESHOLD)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CONSERVE_SNIPER_AMMO, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.PERFORMANCE_REDUCTION_SHOW, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CAP_SLIDERS_MELEE)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CAP_SLIDERS_RANGED)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.CAP_SLIDERS_SPECIALS)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.IGNORE_SPECIALS_PINGS)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.REDUCE_AMBIENT_SHOOTING)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.NO_CHASE_RATLING, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.NO_CHASE_GLOBADIER, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.NO_SEEK_COVER, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.NO_SEEK_COVER_TOGGLE, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.SUB_GROUP_HEALING, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_KEY1)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_KEY2)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_KEY3)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_KEY4)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_TOGGLE)
		-- Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOW_HP_AUTOHEAL)
		-- Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOW_HP_AUTOHEAL_TOGGLE)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.NO_MANUAL_HEAL_OPTIMIZATION)
		-- Mods.option_menu:add_item("bot_improvements", me.SETTINGS.HEALSHARE_NEEDS_WOUNDED)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.HEAL_ONLY_IF_WOUNDED)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.HEAL_ONLY_IF_WOUNDED_TOGGLE)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MAX_HEALING_DISTANCE)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.PASS_DRAUGHTS_TO_HUMANS)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.PASS_DRAUGHTS_TO_HUMANS_HOTKEY)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.TRADING_PREFER_ENABLE, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.TRADING_PREFER_POTION)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.TRADING_PREFER_GRENADE)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.TRADING_PREFER_MAX_DISTANCE)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOOT_GRIMOIRES, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOOT_TOMES, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.KEEP_TOMES, true)
	-- Mods.option_menu:add_item("bot_improvements", me.SETTINGS.KEEP_TOMES_TOGGLE, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.FORCE_LOOT_PINGED_ITEM, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.SMALL_AMMO_NEEDS_FORCING, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.HP_BASED_LOOT_PINGED_HEAL, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.HP_BASED_HEALTH_WEIGHT)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.HP_BASED_WOUNDED_WEIGHT)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.HP_BASED_GRIM_WEIGHT)
	-- Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOOT_AMMO_SMALL, true)
	-- Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOOT_AMMO_SMALL_TOGGLE, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.PING_STORMVERMINS, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.FOLLOW, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.FOLLOW_TOGGLE, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.HELP_WITH_BREAKABLES_OBJECTIVES, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BREAKABLES_OBJECTIVES_THRESHOLD)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.DEFEND_MISSION_OBJECTIVES, true)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.DEFEND_MISSION_OBJECTIVES_TOGGLE_KEY_ENABLE)
		Mods.option_menu:add_item("bot_improvements", me.SETTINGS.DEFEND_MISSION_OBJECTIVES_TOGGLE_KEY)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.TELEPORT_KEY, true)
end

-- ####################################################################################################################
-- ##### Implementation ###############################################################################################
-- ####################################################################################################################

-- ************* some utility functions *************

-- shorthand to print out variables saparate with '|'
local debug_print_variables = function(...)
	local print_string = false
	for _,data in pairs({...}) do
		if not print_string then
			print_string = tostring(data)
		else
			print_string = print_string .. " | " .. tostring(data)
		end
	end
	
	EchoConsole(print_string)
	
	return
end

-- shorthand to print out contents of a table
local debug_print_table = function(arg)
	EchoConsole("-----------------------------")
	if type(arg) == "table" then
		for key, value in pairs(arg) do
			debug_print_variables(key, value)
		end
	else
		EchoConsole("arg is of type " .. tostring(type(arg)) .. " not a table")
	end
end

local number_to_string = function(num, decimals)
	local ret = tostring(num)
	
	local int = math.floor(num)
	local fract = math.abs(num%1)
	if fract > 0 then
		ret = tostring(int) .. "." .. string.sub(tostring(fract),3, 2+decimals)
	end
	
	return ret
end

local new_frame_checker = function()
	local ret = 
	{
		_fresh = Vector3(0,0,0),
		
		is_new_frame = function(self)
			return tostring(self._fresh) ~= "Vector3(0, 0, 0)"
		end,
		
		update = function(self) 
			self._fresh = Vector3(0,0,0)
			return
		end,
	}
	
	return ret
end

-- shorthand to check is a unit is alive based on its health extension
local is_unit_alive = function(unit)
	-- this checks only if the unit still exists and has a body / corpse
	if not unit or not Unit.alive(unit) then
		return false
	end
	
	-- but a units should be considered dead if it has 0 health even if the corpse is still lying around..
	local health_extension	= ScriptUnit.has_extension(unit, "health_system")
	local is_alive			= (health_extension and health_extension:is_alive()) or false
	
	return is_alive
end

-- check if the given unit is inside gas / fire patch / triggered barrel effect area
local is_unit_in_aoe_explosion_threat_area_data = {}
local is_unit_in_aoe_explosion_threat_area = function(unit)
	if not unit then
		return false
	end
	
	local t = os.clock()
	if not is_unit_in_aoe_explosion_threat_area_data[unit] then
		is_unit_in_aoe_explosion_threat_area_data[unit] =
		{
			expires_at = 0,
			ret = false,
		}
	end
	
	local ret = false
	if t > is_unit_in_aoe_explosion_threat_area_data[unit].expires_at then
		local unit_pos		= POSITION_LOOKUP[unit] or Unit.local_position(unit, 0) or false
		local nav_world		= Managers.state.entity:system("ai_system"):nav_world()
		local group_system	= Managers.state.entity:system("ai_bot_group_system")
		--
		if unit_pos and nav_world and group_system then
			local in_threat_area, _		= group_system:_selected_unit_is_in_disallowed_nav_tag_volume(nav_world, unit_pos)
			ret = in_threat_area
		end
		
		is_unit_in_aoe_explosion_threat_area_data[unit].ret = ret
		is_unit_in_aoe_explosion_threat_area_data[unit].expires_at = t + 0.1	--0.2
	else
		ret = is_unit_in_aoe_explosion_threat_area_data[unit].ret
	end
	
	-- clean garbage data out of the data table
	for unit,_ in pairs(is_unit_in_aoe_explosion_threat_area_data) do
		if not is_unit_alive(unit) then
			is_unit_in_aoe_explosion_threat_area_data[unit] = nil
		end
	end
	
	return ret
end

-- get number current of bots & humans that are not disabled
local get_able_bot_human_data = function()
	local human_count = 0
	local bot_count = 0
	local human_list = {}
	local bot_list = {}
	for _,owner in pairs(Managers.player:players()) do
		local status_extension = ScriptUnit.has_extension(owner.player_unit, "status_system")
		local enabled = status_extension and not status_extension:is_disabled()
		if enabled then
			if owner.bot_player then
				bot_count = bot_count + 1
				table.insert(bot_list, owner.player_unit)
			else
				human_count = human_count + 1
				table.insert(human_list, owner.player_unit)
			end
		end
	end
	
	return bot_count, human_count, bot_list, human_list
end

local utils = 
{
	save = {},
	new_save = function()
		local ret = {}
		ret.frame_check	= new_frame_checker()
		ret.reuse_count	= 0
		ret.ret			= {}
		return ret
	end,
	
	
	get_unit_data = function(self, unit, data_key)
		
		local save_key	= "get_unit_data"
		local arg		= data_key
		local func		= function(unit, data_key)
			local get_item_name = function(inventory_extension, slot_name)
				local item_name = ""
				if inventory_extension and slot_name then
					local slot_data	= inventory_extension:get_slot_data(slot_name)
					local item_data	= slot_data and slot_data.item_data
					item_name		= (item_data and item_data.name) or item_name
				end
				return item_name
			end
			local TRINKET_KEYS = 
			{
				healshare 	= "medpack_spread_area",
				potshare	= "potion_spread_area",
				dove		= "heal_self_on",
				lichebone	= "reduce_grimo",
				sisterhood	= "shared_damage",
				taurus		= "hp_increase_kd",
			}
			local HEALTH_KEYS = 
			{
				hp_percent	= true,
				hp_max		= true,
				hp_current	= true,
				hp_missing	= true,
			}
			local ret = false
			
			if TRINKET_KEYS[data_key] then
				local attachment_extension = ScriptUnit.has_extension(unit, "attachment_system")
				if attachment_extension then
					local trinket_slots = 
					{
						"slot_trinket_1",
						"slot_trinket_2",
						"slot_trinket_3",
					}
					for _,slot in pairs(trinket_slots) do
						local slot_data = attachment_extension._attachments.slots[slot]
						local trinket_id = slot_data and slot_data.item_data.key
						local trinket_data = slot_data and ItemMasterList[trinket_id]
						local trinket_traits = trinket_data and trinket_data.traits
						if trinket_traits then
							for _, trait_string in pairs(trinket_traits) do
								if trait_string then
									ret = ret or string.find(trait_string, TRINKET_KEYS[data_key])
								end
							end
						end
						
						if ret then
							break
						end
					end
				end
				--
			elseif data_key == "wounded" then
				local status_extension = ScriptUnit.has_extension(unit, "status_system")
				ret	= (status_extension and not status_extension:has_wounds_remaining()) or false
				--
			elseif data_key == "disabled" then
				local status_extension = ScriptUnit.has_extension(unit, "status_system")
				ret	= (status_extension and status_extension:is_disabled()) or false
				--
			elseif data_key == "heal_item" then
				local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
				ret = (inventory_extension and get_item_name(inventory_extension, "slot_healthkit")) or false
				--
			elseif data_key == "potion_item" then
				local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
				ret = (inventory_extension and get_item_name(inventory_extension, "slot_potion")) or false
				--
			elseif data_key == "grenade_item" then
				local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
				ret = (inventory_extension and get_item_name(inventory_extension, "slot_grenade")) or false
				--
			elseif HEALTH_KEYS[data_key] then
				ret = 0
				local health_extension = ScriptUnit.has_extension(unit, "health_system")
				local max_hp = (health_extension and health_extension.health) or 100
				local current_damage = (health_extension and health_extension.damage) or 0
				local current_hp = max_hp - current_damage
				local health_percent = current_hp / max_hp
				
				if data_key == "hp_percent" then
					ret = health_percent
				elseif data_key == "hp_max" then
					ret = max_hp
				elseif data_key == "hp_current" then
					ret = current_hp
				elseif data_key == "hp_missing" then
					ret = current_damage
				end
				--
			elseif data_key == "tome" then
				ret = self:get_unit_data(unit, "heal_item") == "wpn_side_objective_tome_01"
				--
			elseif data_key == "draught" then
				ret = self:get_unit_data(unit, "heal_item") == "potion_healing_draught_01"
				--
			elseif data_key == "medkit" then
				ret = self:get_unit_data(unit, "heal_item") == "healthkit_first_aid_kit_01"
				--
			elseif data_key == "grimoire" then
				ret = self:get_unit_data(unit, "potion_item") == "wpn_grimoire_01"
				--
			elseif data_key == "speed_potion" then
				ret = self:get_unit_data(unit, "potion_item") == "potion_speed_boost_01"
				--
			elseif data_key == "strength_potion" then
				ret = self:get_unit_data(unit, "potion_item") == "potion_damage_boost_01"
				--
			elseif data_key == "frag_grenade" then
				local grenade_name = self:get_unit_data(unit, "grenade_item")
				ret = grenade_damage == "grenade_frag_01" or grenade_name == "grenade_frag_02"
				--
			elseif data_key == "fire_grenade" then
				local grenade_name = self:get_unit_data(unit, "grenade_item")
				ret = grenade_damage == "grenade_fire_01" or grenade_name == "grenade_fire_02"
				--
			elseif data_key == "_melee_item_data" then
				local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
				local slot_data = inventory_extension and inventory_extension:equipment().slots["slot_melee"]
				ret = slot_data and slot_data.item_data
				--
			elseif data_key == "melee_weapon_type" then
				local item_data = self:get_unit_data(unit, "_melee_item_data")
				ret = (item_data and item_data.item_type) or ""
				--
			elseif data_key == "stamina" then
				ret = 0
				local status_extension = ScriptUnit.has_extension(unit, "status_system")
				if status_extension then
					local current_fatigue, max_fatigue = status_extension:current_fatigue_points()				
					ret = max_fatigue - current_fatigue
				end
				--
			elseif data_key == "_ranged_item_data" then
				local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
				local slot_data = inventory_extension and inventory_extension:equipment().slots["slot_ranged"]
				ret = slot_data and slot_data.item_data
				--
			elseif data_key == "ranged_weapon_type" then
				local item_data = self:get_unit_data(unit, "_ranged_item_data")
				ret = (item_data and item_data.item_type) or ""
				--
			elseif data_key == "heat_weapon" then
				local heat_weapons = 
				{
					dr_drakefire_pistols = true,
					bw_staff_beam = true,
					bw_staff_firball = true,
					bw_staff_geiser = true,
					bw_staff_spear = true,
					bw_staff_firefly_flamewave = true,
				}
				local weapon_type = self:get_unit_data(unit, "ranged_weapon_type")
				ret = weapon_type and heat_weapons[weapon_type]
				--
			elseif data_key == "ammo_weapon" then
				ret = not self:get_unit_data(unit, "heat_weapon")
				--
			elseif data_key == "ammo_percent" then
				local item_data = self:get_unit_data(unit, "_ranged_item_data")
				local item_template = item_data and BackendUtils.get_item_template(item_data)
				local ammo_data = item_template and item_template.ammo_data
				
				if ammo_data then
					local right_unit = slot_data.right_unit_1p
					local left_unit = slot_data.left_unit_1p
					local ammo_extension = (right_unit and ScriptUnit.has_extension(right_unit, "ammo_system") and ScriptUnit.extension(right_unit, "ammo_system")) or (left_unit and ScriptUnit.has_extension(left_unit, "ammo_system") and ScriptUnit.extension(left_unit, "ammo_system"))
					
					if ammo_extension then	-- for some reason ammo extension can be nil even when the function gets this far..
						ret = ammo_extension:total_remaining_ammo() / ammo_extension:max_ammo_count()
					else
						ret = 1 -- this happens due to missing clients' ammo extension
						--
					end
				else
					-- no ammo data >> fire weapon
					local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
					if inventory_extension and inventory_extension.current_overcharge_status then
						-- fire weapon / overcharge status for local player / bots
						local current_oc, threshold_oc, max_oc = inventory_extension:current_overcharge_status("slot_ranged")
						-- Added checks to return clause to prevent chrashes with anyweapon mod. Thanks to VernonKun for reporting the issue and providing sample solution.
						ret = (current_oc and max_oc and (1 - (current_oc/max_oc))) or 0
					else
						ret = 0 -- this happens due to missing clients' overcharge data
					end
				end
			end
			
			return ret
		end
		
		local failsafe_values =
		{
			disabled			= true,
			wounded				= false,
			heal_item			= "",
			potion_item			= "",
			grenade_item		= "",
			healshare			= false,
			potshare			= false,
			dove				= false,
			lichebone			= false,
			sisterhood			= false,
			taurus				= false,
			hp_percent			= 0,
			hp_max				= 1,
			hp_current			= 0,
			hp_missing			= 1,
			tome				= false,
			draught				= false,
			medkit				= false,
			grimoire			= false,
			speed_potion		= false,
			strength_potion		= false,
			frag_grenade		= false,
			fire_grenade		= false,
			_melee_item_data	= false,
			melee_weapon_type	= "",
			stamina				= 0,
			_ranged_item_data	= false,
			ranged_weapon_type	= "",
			heat_weapon			= false,
			ammo_weapon			= false,
			ammo_percent		= 1,
		}
		
		-- common
		local unit_key = unit
		if unit_key == nil then
			unit_key = "nil"
		end
		
		local save_data = self.save[save_key] or self.new_save()
		if save_data.frame_check:is_new_frame() then
			save_data.frame_check:update()
			-- EchoConsole(save_data.reuse_count)
			save_data.reuse_count = 0
			-- table.clear(save_data.ret)
			save_data.ret = {}
		end
		
		if not save_data.ret[unit_key] then
			save_data.ret[unit_key] = {}
		end
		
		if save_data.ret[unit_key][data_key] == nil then
			save_data.ret[unit_key][data_key] = 
			{
				valid = false,
				value = true,
			}
		end
		
		if not save_data.ret[unit_key][data_key].valid then
			local success, ret = pcall(func, unit, data_key)
			if not success then
				EchoConsole("get_unit_data error: " .. tostring(ret))
				ret = failsafe_values[data_key] or "nil"
			end
			save_data.ret[unit_key][data_key].valid = true
			save_data.ret[unit_key][data_key].value = ret
			self.save[save_key] = save_data
			return ret
		else
			self.save[save_key].reuse_count = self.save[save_key].reuse_count +1
			return save_data.ret[unit_key][data_key].value
		end
		return nil
	end,
	
	
	
	
	-- func_name = function(self, arg_name)
		-- local save_key	= "func_name"
		-- local arg		= arg_name
		-- local func		= function(arg_name)
			-- local ret = {}
			-- ...
			-- return ret
		-- end
		
		-- -- common
		-- local save_data = self.save[save_key] or self.new_save()
		-- if save_data.frame_check:is_new_frame() then
			-- save_data.frame_check:update()
			-- table.clear(save_data.ret)
		-- end
		
		-- if not save_data.ret[arg] then
			-- save_data.ret[arg] = 
			-- {
				-- valid = false,
				-- value = false
			-- }
		-- end
		
		-- if save_data.ret[arg].valid then
			-- return save_data.ret[arg].value
		-- else
			-- local ret = func(arg)
			-- save_data.ret[arg].valid = true
			-- save_data.ret[arg].value = ret
			-- self.save[save_key] = save_data
			-- return ret
		-- end
		-- return nil
	-- end,
}

-- create new area check element for box type area
local new_area_check_box = function(point1, point2)
	
	local ret =
	{
		x_min = math.min(point1.x, point2.x),
		x_max = math.max(point1.x, point2.x),
		y_min = math.min(point1.y, point2.y),
		y_max = math.max(point1.y, point2.y),
		z_min = math.min(point1.z, point2.z),
		z_max = math.max(point1.z, point2.z),
		in_area = function(self, point)
			local ret = true
			if point.x < self.x_min or point.x > self.x_max then ret = false end
			if point.y < self.y_min or point.y > self.y_max then ret = false end
			if point.z < self.z_min or point.z > self.z_max then ret = false end
			return ret
		end,
	}
	return ret
end

-- create new area check element for sphere type area
local new_area_check_sphere = function(point1, radius)
	
	local ret =
	{
		x = point1.x,
		y = point1.y,
		z = point1.z,
		r = radius,
		in_area = function(self, point)
			local center = Vector3(self.x,self.y,self.z)
			local ret = Vector3.length(center - point) <= self.r
			return ret
		end,
	}
	return ret
end

-- create new area check element for cylinder type area, above = z offset from ref to ceiling, below = z offset from ref to floor
local new_area_check_cylinder = function(ref_point, radius, above, below)
	
	local ret =
	{
		ref = Vector3Box(ref_point),
		r = radius,
		top = ref_point.z + above,
		bottom = ref_point.z - below,
		in_area = function(self, point)
			local ref = self.ref:unbox()
			local point_r = Vector3.length(Vector3.flat(point - ref))
			local ret = point_r < self.r and point.z < self.top and point.z > self.bottom
			return ret
		end,
	}
	return ret
end

-- create new area check element for hollow sphere type area, return success if the point is outside inner_r but inside outer_r
local new_area_check_hollow_sphere = function(ref_point, inner_r, outer_r)
	
	local ret =
	{
		ref = Vector3Box(ref_point),
		r_i = inner_r,
		r_o = outer_r,
		in_area = function(self, point)
			local ref = self.ref:unbox()
			local point_r = Vector3.length(Vector3.flat(point - ref))
			local ret = point_r > self.r_i and point_r < self.r_o
			return ret
		end,
	}
	return ret
end

--edit--
-- Vernon: optimization
local get_mission_defend_position = function(follow_target_position)
	local defend_position = false
	local angle_offset = false
	local manual_positions = false
	
	if follow_target_position then
		local level_id = LevelHelper:current_level_settings().level_id
		if level_id == "dlc_survival_magnus" then	-- town meeting
			local defend_positions =
			{
				Vector3(28.64, -40.46, 2.58),		-- tunnel near the tents
			}
			
			local stand_positions = 
			{
				{
					Vector3(28.71, -38.46, 2.37),
					Vector3(30.18, -39.39, 2.34),
					Vector3(29.53, -39.04, 2.35),
				},
			}
			
			for i=1,#defend_positions do
				local pos = defend_positions[i]
				local diff = follow_target_position - pos
				if Vector3.length(diff) < 4.5 and math.abs(diff.z) < 3 then
					defend_position = pos
					manual_positions = stand_positions[i]
				end
			end
			--
		elseif level_id == "magnus" then	-- Horn of Magnus, end event
			local defend_positions =
			{
				Vector3(266.34, -149.77, 89.18),		-- next to the window
			}
			
			local stand_positions = 
			{
				{
					Vector3(264.46, -150.20, 89.20),
					Vector3(265.40, -148.07, 89.26),
					Vector3(264.95, -149.06, 89.23),
				},
			}
			
			for i=1,#defend_positions do
				local pos = defend_positions[i]
				local diff = follow_target_position - pos
				if Vector3.length(diff) < 4.5 and math.abs(diff.z) < 3 then
					defend_position = pos
					manual_positions = stand_positions[i]
				end
			end
			--
		elseif level_id == "wizard" then	-- wizard's tower
			local defend_positions =
			{
				Vector3(209, -42, 80),		-- ward 1
				Vector3(220, -21, 80),		-- ward 2
				Vector3(194.44, -9.84, 76),	-- ward 3
				Vector3(186.51, -26.87, 76)	-- ward 4
			}
			
			local angle_offsets = 
			{
				0,
				0,
				0,
				0,
			}
			
			for i=1,#defend_positions do
				local pos = defend_positions[i]
				local diff = follow_target_position - pos
				if Vector3.length(diff) < 7 and math.abs(diff.z) < 3 then
					defend_position = pos
					angle_offset = angle_offsets[i]
				end
			end
			--
		elseif level_id == "courtyard_level" then	-- well watch
			local defend_positions =
			{
				Vector3(11, 24.36, 0),			-- well 1
				Vector3(-18.98, -7.34, 2)		-- well 2
			}
			
			local angle_offsets = 
			{
				60,
				0,
			}
			
			for i=1,#defend_positions do
				local pos = defend_positions[i]
				local diff = follow_target_position - pos
				if Vector3.length(diff) < 7 then
					defend_position = pos
					angle_offset = angle_offsets[i]
				end
			end
			--
			
		elseif level_id == "dlc_portals" then	-- summoner's peak
			local defend_positions =
			{
				Vector3(-33.66,-52.23,-2),	-- generator 1
				Vector3(79,-23,27)			-- generator 3
			}
			
			local angle_offsets = 
			{
				15,
				0,
			}
			
			for i=1,#defend_positions do
				local pos = defend_positions[i]
				local diff = follow_target_position - pos
				if Vector3.length(diff) < 7 then
					defend_position = pos
					angle_offset = angle_offsets[i]
				end
			end
			--
		-- elseif level_id == "dlc_survival_magnus" then	-- town meeting, debug
			-- local defend_positions =
			-- {
				-- Vector3(47.68,18.44,2.65),	-- debug point
			-- }
			
			-- local angle_offsets = 
			-- {
				-- 0,
			-- }
			
			-- for i=1,#defend_positions do
				-- local pos = defend_positions[i]
				-- local diff = follow_target_position - pos
				-- if Vector3.length(diff) < 7 then
					-- defend_position = pos
					-- angle_offset = angle_offsets[i]
				-- end
			-- end
			-- --
		end
	end
	
	if not angle_offset then angle_offset = 0 end
	
	local stand_position = false
	-- local stand_distance = 2.5
	-- local angle_offset_rad = angle_offset * math.pi/180
	-- local base_angle_offset_rad = 120 * math.pi/180
	-- local stand_v1 = Vector3(math.sin(base_angle_offset_rad * 0 + angle_offset_rad),	math.cos(base_angle_offset_rad * 0 + angle_offset_rad),	0)
	-- local stand_v2 = Vector3(math.sin(base_angle_offset_rad * 1 + angle_offset_rad),	math.cos(base_angle_offset_rad * 1 + angle_offset_rad),	0)
	-- local stand_v3 = Vector3(math.sin(base_angle_offset_rad * 2 + angle_offset_rad),	math.cos(base_angle_offset_rad * 2 + angle_offset_rad),	0)
	--
	if defend_position then
		stand_position = {}
		
		local stand_distance = 2.5
		local angle_offset_rad = angle_offset * math.pi/180
		local base_angle_offset_rad = 120 * math.pi/180
		local stand_v1 = Vector3(math.sin(base_angle_offset_rad * 0 + angle_offset_rad),	math.cos(base_angle_offset_rad * 0 + angle_offset_rad),	0)
		local stand_v2 = Vector3(math.sin(base_angle_offset_rad * 1 + angle_offset_rad),	math.cos(base_angle_offset_rad * 1 + angle_offset_rad),	0)
		local stand_v3 = Vector3(math.sin(base_angle_offset_rad * 2 + angle_offset_rad),	math.cos(base_angle_offset_rad * 2 + angle_offset_rad),	0)
		
		if manual_positions then
			table.insert(stand_position, manual_positions[1])
			table.insert(stand_position, manual_positions[2])
			table.insert(stand_position, manual_positions[3])
		else
			table.insert(stand_position, defend_position + stand_v1 * stand_distance)
			table.insert(stand_position, defend_position + stand_v2 * stand_distance)
			table.insert(stand_position, defend_position + stand_v3 * stand_distance)
		end
	end
	
	return defend_position, stand_position
end
--edit--

local forced_bot_teleport = function(bot_unit, destination)
	local unit = bot_unit
	local unit_owner = Managers.player:unit_owner(unit)
	if destination and Unit.alive(unit) and unit_owner.bot_player then	-- this function is supposed to teleport only bots
		local blackboard = Unit.get_data(unit, "blackboard")
		local status_extension = ScriptUnit.has_extension(unit, "status_system")
		if status_extension and not status_extension:is_disabled() then
			blackboard.teleport_stuck_loop_counter = nil
			blackboard.teleport_stuck_loop_start_time = nil
			-- teleport
			local locomotion_extension = ScriptUnit.extension(unit, "locomotion_system")
			locomotion_extension.teleport_to(locomotion_extension, destination)
			blackboard.has_teleported = true
			blackboard.navigation_extension:teleport(destination)
			blackboard.ai_system_extension:clear_failed_paths()
			blackboard.follow.needs_target_position_refresh = true
		end
	end
	
	return
end

is_forced_teleport_needed_data =
{
	wizard = 
	{
		{	-- TP to the first chest
			target = new_area_check_cylinder(Vector3(-75.6005, 211.879, 20.2335), 2.5, 2, 0.5),
			from   = new_area_check_sphere(Vector3(-75.6005, 211.879, 20.2335), 10),
		},
		{	-- TP to for the library right side skip (forward)
			target = new_area_check_cylinder(Vector3(-63.7019, 179.025, 38.2212), 3, 2, 0.1),
			from   = new_area_check_hollow_sphere(Vector3(-63.7019, 179.025, 38.2212), 10, 15),
		},
		{	-- TP to for the library left side skip (forward)
			target = new_area_check_cylinder(Vector3(-38.2064, 189.955, 38.2531), 2, 0.2, 0.5),
			from   = new_area_check_hollow_sphere(Vector3(-38.2064, 189.955, 38.2531), 4, 15),
		},
		{	-- TP to for the library left side skip (backward)
			target = new_area_check_cylinder(Vector3(-45.8972, 193.918, 38.307), 2, 0.2, 0.5),
			from   = new_area_check_hollow_sphere(Vector3(-45.8972, 193.918, 38.307), 4, 15),
		},
	},
	farm =
	{
		{	-- TP to a land platformin wheat & chaff
			target = new_area_check_cylinder(Vector3(-56.7184, 8.14464, 77.7023), 3, 1, 0.5),
			from   = new_area_check_cylinder(Vector3(-56.7184, 8.14464, 77.7023), 15, 0, 4),
		},
	},
	dlc_castle =
	{
		{	-- trap door from statue room to catacombs
			target	= new_area_check_sphere(Vector3(32.23,218.76,-23,92), 5),
			from	= new_area_check_cylinder(Vector3(31.9648, 222.595, -2.0002), 7, 3, 3),
		},
		{	-- tp to fix bots failing the jump to grim #2
			target	= new_area_check_box(Vector3(7.30,177.20,-0.5), Vector3(49.10,146.86,2.5)),
			from	= new_area_check_cylinder(Vector3(31.9786, 160.032, -3.5805), 5, 3, 0),
		},
		{
			-- tp to get bots out of the corridoor leading away from grim #1
			target	= new_area_check_sphere(Vector3(-34.69,-93.98,-14), 3),
			from	= new_area_check_box(Vector3(-35.9834, -89.1575, -14.5), Vector3(-16.8185, -62.106, -12.5)),
		},
		{
			-- grim #1 railing jump down
			target	= new_area_check_cylinder(Vector3(-7.66865, -56.1015, -14.0687), 10, 3, 0.5),
			from	= new_area_check_box(Vector3(0.366995, -63.8697, -10.4275), Vector3(-15.709, -47.5199, -6.9275)),
		},
	},
	dlc_dwarf_interior =
	{
		{	-- jump down to grim #2
			target	= new_area_check_cylinder(Vector3(-164.272, -2.84617, -8.18211), 3, 1.7, 1),
			from	= new_area_check_cylinder(Vector3(-161.451, -3.02136, -4.36534), 5, 3, 2),
		},
		{	-- jump over first gap to grim #2
			target	= new_area_check_cylinder(Vector3(-163.979, 10.0175, -11.2992), 3, 2, 1),
			from	= new_area_check_cylinder(Vector3(-163.822, -0.0269129, -11.3124), 3, 2, 1),
		},
		{	-- jump puzzle away from grim #2
			target	= new_area_check_sphere(Vector3(-160.228, 24.1531, -10.3134), 5),
			from	= new_area_check_cylinder(Vector3(-163.792, 13.192, -11.3124), 10, 3, 10),
		},
	},
}

local is_forced_teleport_needed = function(unit, follow_unit)
	local ret = false
	local unit_pos			= (Unit.alive(unit) and POSITION_LOOKUP[unit]) or false
	local follow_unit_pos	= (Unit.alive(follow_unit) and POSITION_LOOKUP[follow_unit]) or false
	
	
	if unit_pos and follow_unit_pos then
		local level_id = LevelHelper:current_level_settings().level_id		
		
		if level_id == "cemetery" then	-- garden of morr (ladders near one of the upper chains in the cauldron event)
			if	(Vector3.length(follow_unit_pos - Vector3(22,17,1)) < 10 and math.abs(follow_unit_pos.z - 1) < 2) and
				(Vector3.length(unit_pos - Vector3(11,20,-6)) < 4 or Vector3.length(unit_pos - Vector3(22,25,-8)) < 4) then
				ret = Vector3(22,17,1)
			end
		elseif level_id == "end_boss" then -- white rat, make bots TP to you when you go to the grim location (so you can tell them to grab it)
			if Vector3.length(follow_unit_pos - Vector3(269.45, -79.79, 141.42)) < 3 and
				Vector3.length(unit_pos - Vector3(269.45, -79.79, 141.42)) > 4 then
				ret = Vector3(269.45, -79.79, 141.42)
			end
		elseif level_id == "dlc_stromdorf_town" then
			-- reaching out, stuck spot in the marketplace
			if	(Vector3.length(follow_unit_pos - unit_pos) > 8) and
				(Vector3.length(unit_pos - Vector3(94.90,-13.75,9.94)) < 1) then
				ret = Vector3(98.62,-18.79,9.79)
			
			-- reaching out, maze, telepor over the fence where players commonly jump over to avoid patrol
			-- (by default the bots don't know how to jump there)
			elseif	(Vector3.length(follow_unit_pos - Vector3(74.95,22.42,10.80)) < 4) and
					(Vector3.length(unit_pos - Vector3(85.00,24.49,10.50)) < 4 or Vector3.length(unit_pos - Vector3(88.97,16.57,10.47)) < 4) then
				ret = Vector3(74.95,22.42,10.80)
			end
		elseif level_id == "docks_short_level" then
			if	(Vector3.length(follow_unit_pos - Vector3(8.73,6.41,0.34)) < 4 and (follow_unit_pos.z - 0.34) > -0.2) and (Vector3.length(unit_pos - Vector3(8.39,-0.17,-2.97)) < 3 or Vector3.length(unit_pos - Vector3(8.98,-2.46,-3.23)) < 3 or Vector3.length(unit_pos - Vector3(10.65,4.45,-3.33)) < 3) then
				ret = Vector3(3.37,7.08,0.18)
			elseif (Vector3.length(follow_unit_pos - Vector3(8.93,1.66,-3.37)) < 4 and (follow_unit_pos.z - -3.37) > -0.2) and (Vector3.length(unit_pos - Vector3(8.73,6.41,0.34)) < 10 and math.abs(unit_pos.z - 0.34) < 1) then
				ret = Vector3(2.73, 0.00,-2.70)
			elseif (Vector3.length(follow_unit_pos - Vector3(53.32,5.46,0.84)) < 5) and ((Vector3.length(unit_pos - Vector3(48.54,0.65,4.95)) < 7 and math.abs(unit_pos.z - 4.95) < 1) or Vector3.length(unit_pos - Vector3(37.53,-2.46,0.68)) < 4) then
				ret = follow_unit_pos
			end
			--
		elseif is_forced_teleport_needed_data[level_id] then
			local data = is_forced_teleport_needed_data[level_id]
			for _, check in pairs(data) do
				local target_check = check.target
				local from_check = check.from
				if target_check:in_area(follow_unit_pos) and not target_check:in_area(unit_pos) and from_check:in_area(unit_pos) then
					ret = follow_unit_pos
					break
				end
			end
		end
	end
	
	return ret
end

local forced_jump_data = 
{
	dlc_castle = 
	{
		new_area_check_sphere(Vector3(-0.204, 152.924, 0.028), 0.2),
		new_area_check_sphere(Vector3(-0.07, 153.372, 0), 0.2),
	},
	dlc_survival_magnus =
	{
		new_area_check_sphere(Vector3(33.7118, -23.8778, 3.80752), 0.5),
		new_area_check_sphere(Vector3(74.4246, -1.63045, 4.23789), 0.5),
	},
	wizard =
	{
		new_area_check_sphere(Vector3(106.684, 116.395, 63.2324), 1),
	},
	farm =
	{
		new_area_check_sphere(Vector3(-49.018, 84.5061, 83.8335), 1),
	},
}

local is_forced_jump_needed = function(unit)
	local pos = unit and POSITION_LOOKUP[unit]
	local level_id = LevelHelper:current_level_settings().level_id		
	
	if pos and level_id and forced_jump_data[level_id] then
		for _,check in pairs(forced_jump_data[level_id]) do
			if check:in_area(pos) then
				return true
			end
		end
	end
	
	return false
end

local debug_show_interval_save = 0
local debug_show_interval = function(print_message)
	local current_time = Managers.time:time("game")
	local interval = current_time-debug_show_interval_save
	if print_message then
		EchoConsole("Cycle time = " .. tostring(interval))
	end
	debug_show_interval_save = current_time
	return interval
end

local pickup_item_category_match = function(name_a, name_b)
	local ret = false
	
	-- Full list of item names intended to be covered by this function
	-- potion_speed_boost_01
	-- potion_damage_boost_01
	-- wpn_grimoire_01
	-- wpn_side_objective_tome_01
	-- grenade_frag_01
	-- grenade_frag_02
	-- grenade_fire_01
	-- grenade_fire_02
	-- potion_healing_draught_01
	-- healthkit_first_aid_kit_01
	
	if name_a == name_b then
		-- exact name match >> always category match too
		ret = true
	else
		-- names don't match exactly >> go through the special cases
		if name_a == "grenade_frag_01" and name_b == "grenade_frag_02" then
			ret = true
		elseif name_a == "grenade_frag_02" and name_b == "grenade_frag_01" then
			ret = true
		elseif name_a == "grenade_fire_01" and name_b == "grenade_fire_02" then
			ret = true
		elseif name_a == "grenade_fire_02" and name_b == "grenade_fire_01" then
			ret = true
		end
	end
	
	return ret
end

local update_weapon_templates_for_charged_shot_support = function()
	
	-- volleybow: change charged shots to close range only, also change hipfire aim node to head
	Weapons.repeating_crossbow_template_1.attack_meta_data.max_range_charged = 7
	Weapons.repeating_crossbow_template_1_co.attack_meta_data.max_range_charged = 7
	Weapons.repeating_crossbow_template_1_t2.attack_meta_data.max_range_charged = 7
	Weapons.repeating_crossbow_template_1_t3.attack_meta_data.max_range_charged = 7
	Weapons.repeating_crossbow_template_1.attack_meta_data.charge_above_range = 3
	Weapons.repeating_crossbow_template_1_co.attack_meta_data.charge_above_range = 3
	Weapons.repeating_crossbow_template_1_t2.attack_meta_data.charge_above_range = 3
	Weapons.repeating_crossbow_template_1_t3.attack_meta_data.charge_above_range = 3
	Weapons.repeating_crossbow_template_1.attack_meta_data.aim_at_node = "j_head"
	Weapons.repeating_crossbow_template_1_co.attack_meta_data.aim_at_node = "j_head"
	Weapons.repeating_crossbow_template_1_t2.attack_meta_data.aim_at_node = "j_head"
	Weapons.repeating_crossbow_template_1_t3.attack_meta_data.aim_at_node = "j_head"
	
	-- handguns: make bots take aim earlier to avoid misses
	Weapons.handgun_template_1.attack_meta_data.charge_above_range = 5
	Weapons.handgun_template_1_co.attack_meta_data.charge_above_range = 5
	Weapons.handgun_template_1_t2.attack_meta_data.charge_above_range = 5
	Weapons.handgun_template_1_t3.attack_meta_data.charge_above_range = 5
	Weapons.handgun_template_1.attack_meta_data.charge_against_armoured_enemy = true
	Weapons.handgun_template_1_co.attack_meta_data.charge_against_armoured_enemy = true
	Weapons.handgun_template_1_t2.attack_meta_data.charge_against_armoured_enemy = true
	Weapons.handgun_template_1_t3.attack_meta_data.charge_against_armoured_enemy = true
	Weapons.handgun_template_1.attack_meta_data.aim_at_node = "j_head"
	Weapons.handgun_template_1_co.attack_meta_data.aim_at_node = "j_head"
	Weapons.handgun_template_1_t2.attack_meta_data.aim_at_node = "j_head"
	Weapons.handgun_template_1_t3.attack_meta_data.aim_at_node = "j_head"
	
	-- crossbows: make bots take aim earlier to avoid misses
	Weapons.crossbow_template_1.attack_meta_data.charge_above_range = 5
	Weapons.crossbow_template_1_co.attack_meta_data.charge_above_range = 5
	Weapons.crossbow_template_1_t2.attack_meta_data.charge_above_range = 5
	Weapons.crossbow_template_1_t3.attack_meta_data.charge_above_range = 5
	Weapons.crossbow_template_1.attack_meta_data.charge_against_armoured_enemy = true
	Weapons.crossbow_template_1_co.attack_meta_data.charge_against_armoured_enemy = true
	Weapons.crossbow_template_1_t2.attack_meta_data.charge_against_armoured_enemy = true
	Weapons.crossbow_template_1_t3.attack_meta_data.charge_against_armoured_enemy = true
	Weapons.crossbow_template_1.attack_meta_data.aim_at_node_charged = "j_head"
	Weapons.crossbow_template_1_co.attack_meta_data.aim_at_node_charged = "j_head"
	Weapons.crossbow_template_1_t2.attack_meta_data.aim_at_node_charged = "j_head"
	Weapons.crossbow_template_1_t3.attack_meta_data.aim_at_node_charged = "j_head"
	Weapons.crossbow_template_1.attack_meta_data.aim_at_node = "j_head"
	Weapons.crossbow_template_1_co.attack_meta_data.aim_at_node = "j_head"
	Weapons.crossbow_template_1_t2.attack_meta_data.aim_at_node = "j_head"
	Weapons.crossbow_template_1_t3.attack_meta_data.aim_at_node = "j_head"
	
	-- hagbane (originally missing shoot_charged for bots, adjusted minimum allowed distance to charge to reduce light attack spam)
	local new_hagbane_action_two_default_allowed_action_chain = 
	{
		{
			sub_action = "shoot_charged",
			start_time = 0.3,
			action = "action_one",
			input = "action_one",
			end_time = math.huge
		},
		{
			sub_action = "shoot_charged",
			start_time = 0.3,
			action = "action_one",
			input = "action_one_mouse",
			end_time = math.huge
		},
		{
			softbutton_threshold = 0.75,
			start_time = 0.3,
			action = "action_one",
			sub_action = "shoot_charged",
			input = "action_one_softbutton_gamepad",
			end_time = math.huge
		},
		{
			sub_action = "default",
			start_time = 0,
			action = "action_wield",
			input = "action_wield",
			end_time = math.huge
		}
	}
	Weapons.shortbow_hagbane_template_1.attack_meta_data.charge_above_range = 5  -- min range to start charging (for bots)
	Weapons.shortbow_hagbane_template_1_co.attack_meta_data.charge_above_range = 5
	Weapons.shortbow_hagbane_template_1_t2.attack_meta_data.charge_above_range = 5
	Weapons.shortbow_hagbane_template_1_t3.attack_meta_data.charge_above_range = 5
	Weapons.shortbow_hagbane_template_1.actions.action_two.default.allowed_chain_actions = new_hagbane_action_two_default_allowed_action_chain
	Weapons.shortbow_hagbane_template_1_co.actions.action_two.default.allowed_chain_actions = new_hagbane_action_two_default_allowed_action_chain
	Weapons.shortbow_hagbane_template_1_t2.actions.action_two.default.allowed_chain_actions = new_hagbane_action_two_default_allowed_action_chain
	Weapons.shortbow_hagbane_template_1_t3.actions.action_two.default.allowed_chain_actions = new_hagbane_action_two_default_allowed_action_chain
	Weapons.shortbow_hagbane_template_1.attack_meta_data.aim_at_node = "j_spine"
	Weapons.shortbow_hagbane_template_1_co.attack_meta_data.aim_at_node = "j_spine"
	Weapons.shortbow_hagbane_template_1_t2.attack_meta_data.aim_at_node = "j_spine"
	Weapons.shortbow_hagbane_template_1_t3.attack_meta_data.aim_at_node = "j_spine"
	
	-- drakefires (no attack metadate by default)
	local new_drakefire_attack_meta_data =
	{
		aim_at_node = "j_head",	
		aim_at_node_charged = "j_spine",
		minimum_charge_time = 0.35,
		charged_attack_action_name = "shoot_charged",
		can_charge_shot = true,
		charge_above_range = 0,
		max_range_charged = 6,
		charge_when_obstructed = false,
		ignore_enemies_for_obstruction = true,
		charge_against_armoured_enemy = true
	}
	Weapons.brace_of_drakefirepistols_template_1.attack_meta_data = new_drakefire_attack_meta_data
	Weapons.brace_of_drakefirepistols_template_1_co.attack_meta_data = new_drakefire_attack_meta_data
	Weapons.brace_of_drakefirepistols_template_1_t2.attack_meta_data = new_drakefire_attack_meta_data
	Weapons.brace_of_drakefirepistols_template_1_t3.attack_meta_data = new_drakefire_attack_meta_data
	
	-- brace_of_pistols (enabled charged shots)
	local new_brace_of_pistols_attack_meta_data =
	{
		aim_at_node = "j_head",	
		aim_at_node_charged = "j_spine",
		can_charge_shot = true,
		charge_above_range = 0,
		max_range_charged = 6,
		charge_when_obstructed = false,
		ignore_enemies_for_obstruction = true,
		charge_against_armoured_enemy = true
	}
	Weapons.brace_of_pistols_template_1.attack_meta_data = new_brace_of_pistols_attack_meta_data
	Weapons.brace_of_pistols_template_1_co.attack_meta_data = new_brace_of_pistols_attack_meta_data
	Weapons.brace_of_pistols_template_1_t2.attack_meta_data = new_brace_of_pistols_attack_meta_data
	Weapons.brace_of_pistols_template_1_t3.attack_meta_data = new_brace_of_pistols_attack_meta_data
	
	-- longbow (reduced charge_above_range so the bots actually use charged shot every now and then)
	Weapons.longbow_template_1.attack_meta_data.charge_above_range = 5  -- min range to start charging (for bots)
	Weapons.longbow_template_1_co.attack_meta_data.charge_above_range = 5
	Weapons.longbow_template_1_t2.attack_meta_data.charge_above_range = 5
	Weapons.longbow_template_1_t3.attack_meta_data.charge_above_range = 5
	Weapons.longbow_template_1.attack_meta_data.minimum_charge_time = 0.75
	Weapons.longbow_template_1_co.attack_meta_data.minimum_charge_time = 0.75
	Weapons.longbow_template_1_t2.attack_meta_data.minimum_charge_time = 0.75
	Weapons.longbow_template_1_t3.attack_meta_data.minimum_charge_time = 0.75
	
	-- trueflight (originally missing shoot_charged for bots, missing attack_meta_data, adjusted minimum allowed distance to charge to reduce light attack spam)
	local new_trueflight_action_two_default_allowed_action_chain = 
	{
		{
			sub_action = "shoot_charged",
			start_time = 0.65,
			action = "action_one",
			input = "action_one",
			end_time = math.huge
		},
		{
			sub_action = "shoot_charged",
			start_time = 0.65,
			action = "action_one",
			input = "action_one_mouse",
			end_time = math.huge
		},
		{
			softbutton_threshold = 0.75,
			start_time = 0.5,
			action = "action_one",
			sub_action = "shoot_charged",
			input = "action_one_softbutton_gamepad",
			end_time = math.huge
		},
		{
			sub_action = "default",
			start_time = 0,
			action = "action_wield",
			input = "action_wield",
			end_time = math.huge
		}
	}
	local new_trueflight_attack_meta_data =
	{
		aim_at_node = "j_spine",
		charged_attack_action_name = "shoot_charged",
		ignore_enemies_for_obstruction_charged = true,
		can_charge_shot = true,
		aim_at_node_charged = "j_head",
		minimum_charge_time = 0.75,
		charge_above_range = 6,
		charge_when_obstructed = false,
		ignore_enemies_for_obstruction = false,
		charge_against_armoured_enemy = true
	}
	Weapons.longbow_trueflight_template_1.attack_meta_data = new_trueflight_attack_meta_data
	Weapons.longbow_trueflight_template_1_co.attack_meta_data = new_trueflight_attack_meta_data
	Weapons.longbow_trueflight_template_1_t2.attack_meta_data = new_trueflight_attack_meta_data
	Weapons.longbow_trueflight_template_1_t3.attack_meta_data = new_trueflight_attack_meta_data
	Weapons.longbow_trueflight_template_1.actions.action_two.default.allowed_chain_actions = new_trueflight_action_two_default_allowed_action_chain
	Weapons.longbow_trueflight_template_1_co.actions.action_two.default.allowed_chain_actions = new_trueflight_action_two_default_allowed_action_chain
	Weapons.longbow_trueflight_template_1_t2.actions.action_two.default.allowed_chain_actions = new_trueflight_action_two_default_allowed_action_chain
	Weapons.longbow_trueflight_template_1_t3.actions.action_two.default.allowed_chain_actions = new_trueflight_action_two_default_allowed_action_chain
	
	-- shortbow (reduced charge_above_range so the bots actually use charged shot every now and then)
	-- Weapons.shortbow_template_1.attack_meta_data.charge_above_range = 5  -- min range to start charging (for bots)
	-- Weapons.shortbow_template_1_co.attack_meta_data.charge_above_range = 5
	-- Weapons.shortbow_template_1_t2.attack_meta_data.charge_above_range = 5
	-- Weapons.shortbow_template_1_t3.attack_meta_data.charge_above_range = 5
	Weapons.shortbow_template_1.attack_meta_data.charge_above_range = 20  -- min range to start charging (for bots)
	Weapons.shortbow_template_1_co.attack_meta_data.charge_above_range = 20
	Weapons.shortbow_template_1_t2.attack_meta_data.charge_above_range = 20
	Weapons.shortbow_template_1_t3.attack_meta_data.charge_above_range = 20
	Weapons.shortbow_template_1.attack_meta_data.aim_at_node = "j_spine"
	Weapons.shortbow_template_1_co.attack_meta_data.aim_at_node = "j_spine"
	Weapons.shortbow_template_1_t2.attack_meta_data.aim_at_node = "j_spine"
	Weapons.shortbow_template_1_t3.attack_meta_data.aim_at_node = "j_spine"
	Weapons.shortbow_template_1.attack_meta_data.aim_at_node_charged = "j_head"
	Weapons.shortbow_template_1_co.attack_meta_data.aim_at_node_charged = "j_head"
	Weapons.shortbow_template_1_t2.attack_meta_data.aim_at_node_charged = "j_head"
	Weapons.shortbow_template_1_t3.attack_meta_data.aim_at_node_charged = "j_head"
	
	-- repeating_pistols is missing attack_meta_data - no change at the moment
	
	-- bolt staff (defined minimum range to use charged)
	Weapons.staff_spark_spear_template_1.attack_meta_data.charge_above_range = 5  -- min range to start charging (for bots)
	Weapons.staff_spark_spear_template_1_co.attack_meta_data.charge_above_range = 5
	Weapons.staff_spark_spear_template_1_t2.attack_meta_data.charge_above_range = 5
	Weapons.staff_spark_spear_template_1_t3.attack_meta_data.charge_above_range = 5
	
	-- beam staff (missing attack_meta_data)
	local new_beam_staff_attack_meta_data =
	{
		aim_at_node = "j_spine",	
		aim_at_node_charged = "j_head",
		can_charge_shot = true,
		minimum_charge_time = 0.5,
		charged_attack_action_name = "charged_beam",
		charge_above_range = 6,
		max_range = 6,
		max_range_charged = 50,
		charge_when_obstructed = false,
		ignore_enemies_for_obstruction = true,
		charge_against_armoured_enemy = true
	}
	Weapons.staff_blast_beam_template_1.attack_meta_data = new_beam_staff_attack_meta_data
	Weapons.staff_blast_beam_template_1_co.attack_meta_data = new_beam_staff_attack_meta_data
	Weapons.staff_blast_beam_template_1_t2.attack_meta_data = new_beam_staff_attack_meta_data
	Weapons.staff_blast_beam_template_1_t3.attack_meta_data = new_beam_staff_attack_meta_data
	
	-- fireball staff (missing attack_meta_data)
	local new_fireball_staff_attack_meta_data =
	{
		aim_at_node = "j_head",	
		aim_at_node_charged = "c_rightfoot",
		can_charge_shot = true,
		minimum_charge_time = 0.65,
		charged_attack_action_name = "shoot_charged",
		charge_above_range = 6,
		max_range_charged = 20,
		charge_when_obstructed = false,
		ignore_enemies_for_obstruction = true,
		charge_against_armoured_enemy = false
	}
	Weapons.staff_fireball_fireball_template_1.attack_meta_data = new_fireball_staff_attack_meta_data
	Weapons.staff_fireball_fireball_template_1_co.attack_meta_data = new_fireball_staff_attack_meta_data
	Weapons.staff_fireball_fireball_template_1_t2.attack_meta_data = new_fireball_staff_attack_meta_data
	Weapons.staff_fireball_fireball_template_1_t3.attack_meta_data = new_fireball_staff_attack_meta_data
--edit--
	-- repeater handgun
	-- Weapons.repeating_handgun_template_1.attack_meta_data.aim_at_node = "j_head"
	-- Weapons.repeating_handgun_template_1_co.attack_meta_data.aim_at_node = "j_head"
	-- Weapons.repeating_handgun_template_1_t2.attack_meta_data.aim_at_node = "j_head"
	-- Weapons.repeating_handgun_template_1_t3.attack_meta_data.aim_at_node = "j_head"
--edit--
	-- conflag staff (missing attack_meta_data)
	local new_conflag_staff_attack_meta_data =
	{
		aim_at_node = "j_head",	
		aim_at_node_charged = "j_head",
		can_charge_shot = true,
		minimum_charge_time = 0.25,
		charged_attack_action_name = "geiser_launch",
		charge_above_range = 6,
		max_range_charged = 20,
		charge_when_obstructed = false,
		ignore_enemies_for_obstruction = true,
		charge_against_armoured_enemy = false
	}
	Weapons.staff_fireball_geiser_template_1.attack_meta_data = new_conflag_staff_attack_meta_data
	Weapons.staff_fireball_geiser_template_1_co.attack_meta_data = new_conflag_staff_attack_meta_data
	Weapons.staff_fireball_geiser_template_1_t2.attack_meta_data = new_conflag_staff_attack_meta_data
	Weapons.staff_fireball_geiser_template_1_t3.attack_meta_data = new_conflag_staff_attack_meta_data
	
	-- Not related to charged shot support but his fixes the incorrect hit effect (=decals left to props whn you hit them) on sword.
	-- The original hit effect for swings #1 and #2 where that of the 2h hammers. Thanks to VernonKun for pointing this out.
	Weapons.one_handed_sword_shield_template_1.actions.action_one.light_attack_left.hit_effect = "melee_hit_sword_1h"
	Weapons.one_handed_sword_shield_template_1_co.actions.action_one.light_attack_left.hit_effect = "melee_hit_sword_1h"
	Weapons.one_handed_sword_shield_template_1_t2.actions.action_one.light_attack_left.hit_effect = "melee_hit_sword_1h"
	Weapons.one_handed_sword_shield_template_1_t3.actions.action_one.light_attack_left.hit_effect = "melee_hit_sword_1h"
	Weapons.one_handed_sword_shield_template_1.actions.action_one.light_attack_last.hit_effect = "melee_hit_sword_1h"
	Weapons.one_handed_sword_shield_template_1_co.actions.action_one.light_attack_last.hit_effect = "melee_hit_sword_1h"
	Weapons.one_handed_sword_shield_template_1_t2.actions.action_one.light_attack_last.hit_effect = "melee_hit_sword_1h"
	Weapons.one_handed_sword_shield_template_1_t3.actions.action_one.light_attack_last.hit_effect = "melee_hit_sword_1h"
	
	-- update sub_action lookup_data (the loop is direct copy from the original)
	for item_template_name, item_template in pairs(Weapons) do
		item_template.name = item_template_name
		item_template.crosshair_style = item_template.crosshair_style or "dot"
		local actions = item_template.actions

		for action_name, sub_actions in pairs(actions) do
			for sub_action_name, sub_action_data in pairs(sub_actions) do
				local lookup_data = {
					item_template_name = item_template_name,
					action_name = action_name,
					sub_action_name = sub_action_name
				}
				sub_action_data.lookup_data = lookup_data
				local allowed_chain_actions = sub_action_data.allowed_chain_actions

				if allowed_chain_actions and actions.action_use_consumable then
					local add_action = true

					for i = 1, #allowed_chain_actions, 1 do
						local chain_action_data = allowed_chain_actions[i]

						if chain_action_data.input == "action_use_consumable" then
							add_action = false

							break
						end
					end

					if add_action then
						allowed_chain_actions[#allowed_chain_actions + 1] = {
							start_time = 0.3,
							first_possible_sub_action = true,
							action = "action_use_consumable",
							input = "action_use_consumable"
						}
					end
				end
			end
		end
	end
	
	return
end

-- retreive ammo information
local get_ammo_percentage = function(unit)
	if not unit then
		return 2
	end
	
	local FIRE_WEAPON = 2
	local status_extension = ScriptUnit.has_extension(unit, "status_system")
	
	if Unit.alive(unit) and status_extension and not status_extension:is_disabled() then
		local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
		local slot_data = inventory_extension:equipment().slots["slot_ranged"]
		local item_data = slot_data.item_data
		local item_template = BackendUtils.get_item_template(item_data)
		local ammo_data = item_template.ammo_data
		
		if ammo_data then
			local right_unit = slot_data.right_unit_1p
			local left_unit = slot_data.left_unit_1p
			local ammo_extension = (right_unit and ScriptUnit.has_extension(right_unit, "ammo_system") and ScriptUnit.extension(right_unit, "ammo_system")) or (left_unit and ScriptUnit.has_extension(left_unit, "ammo_system") and ScriptUnit.extension(left_unit, "ammo_system"))
			
			if ammo_extension then	-- for some reason ammo extension can be nil even when the function gets this far..
				return ammo_extension:total_remaining_ammo() / ammo_extension:max_ammo_count()
			else
				-- some debug texts
				-- EchoConsole("-----------------------")
				-- EchoConsole("ammo_extension: " .. tostring(ammo_extension))
				-- EchoConsole("right_unit: " .. tostring(right_unit))
				-- EchoConsole("left_unit: " .. tostring(left_unit))
				-- EchoConsole("item type: " .. tostring(item_data.item_type))
				
				-- By default the game doesn't seem to send ammo information from clients to the host so for clients only crude
				-- ammo type check can be made based on equipped weapon's item type
				if	item_data.item_type == "dr_drakefire_pistols" or 
					item_data.item_type == "bw_staff_firball" or 
					item_data.item_type == "bw_staff_beam" or 
					item_data.item_type == "bw_staff_geiser" or 
					item_data.item_type == "bw_staff_spear" or 
					item_data.item_type == "bw_staff_firefly_flamewave" then
					--
					return FIRE_WEAPON	-- the client has heat based weapon
				else
					-- Note!!! this will result clients always showing with "full ammo"
					return 1	-- the client has ammo based weapon
				end
				--
			end
		else
			-- no ammo data >> fire weapon
			if inventory_extension.current_overcharge_status then
				-- fire weapon / overcharge status for local player / bots
				local current_oc, threshold_oc, max_oc = inventory_extension.current_overcharge_status(inventory_extension, "slot_ranged")
				-- Added checks to return clause to prevent chrashes with anyweapon mod. Thanks to VernonKun for reporting the issue and providing sample solution.
				return (current_oc and threshold_oc and max_oc and (FIRE_WEAPON + 1 - (current_oc/max_oc))) or FIRE_WEAPON
			else
				-- fire weapon for network players
				return FIRE_WEAPON
			end
		end
	end
	
	return 2	-- default response
end

local function distance_to_target(self, target_unit, blackboard)
	local aim_position = self._aim_position(self, target_unit, blackboard)
	local current_position = blackboard.first_person_extension:current_position()
	
	if aim_position and current_position then
		return Vector3.distance(aim_position, current_position)
	end
	return 1
end

local function check_alignment_to_target(unit, target_unit, opt_infront_angle, opt_flank_angle)
	-- determine if the bot is flanking the target unit (thanks Fatshark for putting this to your bot movement code)
	local infront_angle	= opt_infront_angle or 90	-- deg forward cone
	local flank_angle	= opt_flank_angle or 120	-- deg flank cone
	local flanking_target_unit = false
	local infront_of_target_unit = false
	
	local self_position = POSITION_LOOKUP[unit]	-- taking copies of the position vectors because the z-coordinate is modified when determining positioning towards the enemy
	local target_unit_pos = POSITION_LOOKUP[target_unit]
	if self_position and target_unit_pos then
		-- ignore Z-axiz difference when determining the flanking vs in-front
		local self_position_copy = Vector3.copy(self_position)
		local target_unit_pos_copy = Vector3.copy(target_unit_pos)
		Vector3.set_z(self_position_copy,0)
		Vector3.set_z(target_unit_pos_copy,0)
		local enemy_offset = target_unit_pos_copy - self_position_copy
		local enemy_rot = Unit.local_rotation(target_unit, 0)
		local enemy_dir = Quaternion.forward(enemy_rot)
		local dot = Vector3.dot(enemy_dir, enemy_offset)
		local div = Vector3.length(enemy_dir) * Vector3.length(enemy_offset)
		if div ~= 0 then
			-- normalize the dot product so that it actually is reduced into a cosine of the angle between
			-- the enemy's facing direction vector and the bot-enemy vector in xy-plane
			dot = dot / div
		end
		
		-- check where the bot is in relation to the target, dot = -1 >>> dead in front, dot = +1 >>> directly behind
		local infront_angle_compare	= math.cos(((180-(infront_angle * 0.5)) / 180) * math.pi)
		local flank_angle_compare	= math.cos(((flank_angle * 0.5) / 180) * math.pi)
		if infront_angle_compare > dot then
			infront_of_target_unit = true
		end
		if flank_angle_compare < dot then
			flanking_target_unit = true
		end
	else
		-- This seems to happen randomly, happened once when I opened a chest with lootd die inside, then again during the end run of drachenfels.
		-- this definitely happens when bots are close to destructible objects such as doors / barricades
	end
	return infront_of_target_unit, flanking_target_unit
end

--[[
local function get_proximite_enemies(self_unit, check_range, max_height_offset)
	-- max_height_offset is optional argument
	if max_height_offset == nil then
		max_height_offset = math.huge
	end
	
	local prox_enemies = {}
	table.clear(prox_enemies)
	local self_pos = POSITION_LOOKUP[self_unit]
	
	if self_pos then
		local search_position = Vector3.copy(self_pos)
		
		local query_tmp = {}
		local enemy_broadphase = Managers.state.entity:system("ai_system").broadphase
		local num_hits = Broadphase.query(enemy_broadphase, search_position, check_range, query_tmp)
		local index = 1

		for i = 1, num_hits, 1 do
			local unit = query_tmp[i]

			if is_unit_alive(unit) then
				local enemy_pos = POSITION_LOOKUP[unit]
				local enemy_offset = enemy_pos - search_position
				local blackboard = Unit.get_data(unit, "blackboard")
				local is_valid_target = ScriptUnit.has_extension(unit, "ai_group_system") and blackboard.target_unit

				if is_valid_target and math.abs(enemy_offset.z) < max_height_offset then
					local breed = Unit.get_data(unit, "breed")
					
					if breed and breed.name ~= "critter_pig" and breed.name ~= "critter_rat" then
						prox_enemies[index] = unit
						index = index + 1
					end
				end
			end
		end

		table.clear(query_tmp)
	end

	return prox_enemies
end
--]]

-- check if the enemy unit is positioned between self and ally
local is_positioned_between_self_and_ally = function(self_unit, ally_unit, enemy_unit)
	if self_unit and ally_unit and enemy_unit then
		local self_pos	= POSITION_LOOKUP[self_unit]
		local ally_pos	= POSITION_LOOKUP[ally_unit]
		local enemy_pos	= POSITION_LOOKUP[enemy_unit]
		if self_pos and ally_pos and enemy_pos then
			local ally_dist = Vector3.distance(self_pos, ally_pos)
			local zone_dist = math.sqrt((ally_dist^2) + (2^2)) + 2
			
			local self_to_enemy_dist = Vector3.distance(self_pos, enemy_pos)
			local ally_to_enemy_dist = Vector3.distance(ally_pos, enemy_pos)
			
			if self_to_enemy_dist < ally_dist and ally_to_enemy_dist < ally_dist and (self_to_enemy_dist + ally_to_enemy_dist) < zone_dist then
				-- the enemy is positioned between self and ally
				return true
			end
		end
	end
	
	return false
end

local check_line_of_sight = function(self_unit, target_unit, pos1, pos2)
	--[[ some pressudy pastes for further rework
	local camera_position = blackboard.first_person_extension:current_position()
	local attack_meta_data = item_template.attack_meta_data or {}
	aim_at_node = attack_meta_data.aim_at_node or "j_spine",
	aim_at_node_charged = attack_meta_data.aim_at_node_charged or attack_meta_data.aim_at_node or "j_spine",
	--]]
	local obstructed_by_static = true
	
	if (self_unit and target_unit) or (pos1 and pos2) then
		local world = Managers.state.spawn.world
		local physics_world = World.get_data(world, "physics_world")
		local self_pos_raw = false
		local target_pos_raw = false
		local z_offset = 0
		
		if self_unit and target_unit then
			self_pos_raw	= POSITION_LOOKUP[self_unit]	-- this returns coordinates at the floor level where the actor stands
			target_pos_raw	= POSITION_LOOKUP[target_unit]	-- this returns coordinates at the floor level where the actor stands
			z_offset		= 1.5
		else
			self_pos_raw	= pos1
			target_pos_raw	= pos2
			z_offset		= 0
		end
		
		if self_pos_raw and target_pos_raw then
			local self_pos		= Vector3(self_pos_raw.x,	self_pos_raw.y,		self_pos_raw.z + z_offset)
			local target_pos	= Vector3(target_pos_raw.x,	target_pos_raw.y,	target_pos_raw.z + z_offset)
			local dir			= Vector3.normalize(target_pos-self_pos)
			local dist			= Vector3.length(target_pos-self_pos)
			
			if Vector3.length(dir) < 0.001 then
				-- prevents zero length dir raycast crash
				return false
			end
			
			physics_world:prepare_actors_for_raycast(self_pos, dir, 0.01, 0.5, dist*dist)
			local hit, hit_pos = physics_world:immediate_raycast(self_pos, dir, dist, "closest", "collision_filter", "filter_ai_line_of_sight_check")
			if not hit then obstructed_by_static = false end
		end
	end
	
	return not obstructed_by_static
end

local get_spawned_rats_by_breed = function(breed_name)
	local breed_key = breed_name
	local spawn_table = Managers.state.conflict._spawned_units_by_breed[breed_key]
	local ret = {}
	for _,breed_unit in pairs(spawn_table) do
		if is_unit_alive(breed_unit) then
			ret[#ret+1] = breed_unit	-- numerically indexed lua arrays start at index 1, not 0
		end
	end
	
	return ret
end

local get_spawned_stormvermin = function()
	local ret = {}
	local spawns = get_spawned_rats_by_breed("skaven_storm_vermin")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	spawns = get_spawned_rats_by_breed("skaven_storm_vermin_commander")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	
	return ret
end

local get_spawned_trash = function()
	local ret = {}
	local spawns = get_spawned_rats_by_breed("skaven_slave")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	spawns = get_spawned_rats_by_breed("skaven_clan_rat")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	
	return ret
end

local get_spawned_specials = function()
	local ret = {}
	local spawns = get_spawned_rats_by_breed("skaven_gutter_runner")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	spawns = get_spawned_rats_by_breed("skaven_ratling_gunner")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	spawns = get_spawned_rats_by_breed("skaven_pack_master")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	spawns = get_spawned_rats_by_breed("skaven_poison_wind_globadier")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	
	return ret
end

local get_spawned_bosses = function()
	local ret = {}
	local spawns = get_spawned_rats_by_breed("skaven_rat_ogre")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	spawns = get_spawned_rats_by_breed("skaven_storm_vermin_champion")
	for _,unit in pairs(spawns) do ret[#ret+1] = unit end
	
	return ret
end

local get_spawned_enemies = function(pos, range, height_offset)
	local ret = {}
	local use_range = true
	
	if not pos then
		pos = Vector3(0,0,0)
	end
	
	if not range then
		use_range = false
		range = math.huge
	end
	
	if not height_offset then
		height_offset = math.huge
	end
	
	local loot_rats		= get_spawned_rats_by_breed("skaven_loot_rat")
	local trash			= get_spawned_trash()
	local stormvermin	= get_spawned_stormvermin()
	local specials		= get_spawned_specials()
	local bosses		= get_spawned_bosses()
	
	local enemies = {}
	for _,unit in pairs(loot_rats) do
		table.insert(enemies, unit)
	end
	for _,unit in pairs(trash) do
		table.insert(enemies, unit)
	end
	for _,unit in pairs(stormvermin) do
		table.insert(enemies, unit)
	end
	for _,unit in pairs(specials) do
		table.insert(enemies, unit)
	end
	for _,unit in pairs(bosses) do
		table.insert(enemies, unit)
	end
	
	if use_range then
		for _,unit in pairs(enemies) do
			local enemy_pos = POSITION_LOOKUP[unit]
			local offset = pos and enemy_pos and (pos - enemy_pos)
			local distance = offset and Vector3.length(offset)
			local z_offset = offset and offset.z
			local in_range = offset and z_offset < height_offset and distance < range
			
			if in_range then
				table.insert(ret, unit)
			end
		end
	else
		ret = enemies
	end
	
	return ret
end

local function get_proximite_enemies(self_unit, check_range, max_height_offset)
	local ret = {}
	local self_pos = self_unit and POSITION_LOOKUP[self_unit]
	if self_pos then
		ret = get_spawned_enemies(self_pos, check_range, max_height_offset)
	end
	return ret
end

-- check if a secondary target unit is within the specified cone centered to the line from self to target
local is_secondary_within_cone = function(self_unit, target_unit, secondary_unit, cone_angle_deg)
	local ret = false
	if Unit.alive(self_unit) and Unit.alive(target_unit) and Unit.alive(secondary_unit) then
		local self_pos = POSITION_LOOKUP[self_unit]
		local target_pos = POSITION_LOOKUP[target_unit]
		local secondary_pos = POSITION_LOOKUP[secondary_unit]
		local target_vector = target_pos - self_pos
		local secondary_vector = secondary_pos - self_pos
		
		if Vector3.length(target_vector) > 0 and Vector3.length(secondary_vector) > 0 then
			-- essentially, calculate the dot product of normalized self-target, self-secondary vectors = cosine of the angle between those two vectors
			local secondary_deviation_angle_cos = Vector3.dot(Vector3.normalize(target_vector), Vector3.normalize(secondary_vector))
			-- then get the actual angle from the cosine and convert it into degrees
			local secondary_deviation_angle_deg = (math.acos(secondary_deviation_angle_cos) / math.pi) * 180
			
			-- "cone_angle_deg/2" because secondary_deviation_angle_deg equals half of the opening angle of the cone inside which the secondary currently is
			if secondary_deviation_angle_deg <= (cone_angle_deg/2) then
				ret = true
			end
		end
	end
	
	return ret
end

local get_equipped_weapon_info = function(unit)

	local inventory_ext = ScriptUnit.has_extension(unit,"inventory_system")
	if inventory_ext then
		local wielded_slot_name = inventory_ext.get_wielded_slot_name(inventory_ext)
		local slot_data = inventory_ext.get_slot_data(inventory_ext, wielded_slot_name)
		local item_type = false
		local item_template = false
		if slot_data and slot_data.item_data then
			item_type = slot_data.item_data.item_type or false
			item_template = BackendUtils.get_item_template(slot_data.item_data) or false
		end
		
		local equipment = inventory_ext:equipment()
		
		local right_hand_unit = equipment.right_hand_wielded_unit
		local left_hand_unit = equipment.left_hand_wielded_unit
		
		-- local weapon_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit
		
		local right_weapon_extension = right_hand_unit and ScriptUnit.has_extension(right_hand_unit, "weapon_system")
		local left_weapon_extension = left_hand_unit and ScriptUnit.has_extension(left_hand_unit, "weapon_system")
		
		local weapon_unit = nil
		if right_weapon_extension and right_weapon_extension.current_action_settings then
			weapon_unit = right_hand_unit
		elseif left_weapon_extension and left_weapon_extension.current_action_settings then
			weapon_unit = left_hand_unit
		else
			weapon_unit = right_hand_unit or left_hand_unit
		end
		
		return item_type, weapon_unit, item_template
	end
	
	return false, false, false
end

local get_weapon_range_mod = function(weapon_template)
	-- go throught the weapon's action data and add bot_melee_range if its missing
	local min_range_mod = math.huge
	if weapon_template and weapon_template.actions and weapon_template.actions.action_one then
		for key,data in pairs(weapon_template.actions.action_one) do
			if (string.find(key,"light") == 1 or string.find(key,"heavy") == 1) and data.range_mod then
				min_range_mod = math.min(data.range_mod, min_range_mod)
			end
		end
	end
	
	if min_range_mod > 100 then	-- prevent the initial math.huge causing a mess
		min_range_mod = 1
	end
	
	return min_range_mod
end

-- get_equipped_weapon_length is intended to be used with melee weapons only
local get_equipped_weapon_length = function(unit)
	local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(unit)
	local weapon_extension = ScriptUnit.has_extension(weapon_unit, "weapon_system")
	local damage_unit = (weapon_extension and weapon_extension.actual_damage_unit) or false
	local weapon_pose, weapon_half_extents = false, false
	if damage_unit then
		weapon_pose, weapon_half_extents = Unit.box(damage_unit)
	end
	local weapon_half_length = (weapon_half_extents and weapon_half_extents.z) or false
	
	local range_mod = get_weapon_range_mod(weapon_template)
	weapon_half_length = weapon_half_length and weapon_half_length * range_mod
	
	return (weapon_half_length and weapon_half_length*2) or false
end

-- return actual current health %, health_extension:current_health_percent() doesn't count in effect of lichebones / like
local get_bot_current_health_percent = function(bot_unit)
	
	local health_extension = ScriptUnit.has_extension(bot_unit, "health_system")
	local max_hp = (health_extension and health_extension.health) or 100
	local current_damage = (health_extension and health_extension.damage) or 0
	local current_hp = max_hp - current_damage
	
	local health_precent = current_hp / max_hp
	
	return health_precent
end

-- check if the given position is in area where heal swapping is denied
local is_in_heal_swap_denial_area = function(pos)
	local ret = false
	local map_name = LevelHelper:current_level_settings().level_id
	
	if map_name == "magnus" then	-- horn of magnus, end event, before dropping down
		if	(pos.x > 233 and pos.x < 249) and
			(pos.y > -149 and pos.y < -122) and
			(pos.z > 89 and pos.z < 94) then
			ret = true
		end
		--
	elseif map_name == "forest_ambush" then	-- engines of war, end event heal cluster
		if	(pos.x > 495 and pos.x < 506) and
			(pos.y > 87 and pos.y < 95) and
			(pos.z > -1 and pos.z < 5) then
			ret = true
		end
	elseif map_name == "wizard" then
		if Vector3.length(pos - Vector3(203.27,-24.30,78.34)) < 20 then -- wizard's tower ward event, after the drop
			ret = true
		end
		--
	elseif map_name == "dlc_stromdorf_town" then	-- Reaching out, the chest in the boss area
		if Vector3.length(pos - Vector3(-25.90, -48.54, 2.10)) < 3 then
			ret = true
		end
		--
	-- elseif map_name == "dlc_survival_magnus" then	-- town meeting, for testing purposes
		-- if Vector3.length(pos - Vector3(47.50, 37.89, 4.35)) < 5 then
			-- ret = true
		-- end
		-- --
	end
	
	return ret
end

-- check_players_near_pickup	-	used to check for human presence / need for the item before bots takes it
-- retuns bool, bool
-- #1 true when there is an able human with appropriate slot empty in the area where the pickup is
-- #2 true when there is any able player within the specified grabbing distance
local check_players_near_pickup = function(pickup_unit, nearby_distance, grabbing_distance, pickup_distance_exceptions)
	
	local exceptions = false
	if pickup_distance_exceptions then
		local level_id = LevelHelper:current_level_settings().level_id
		for key, data in pairs(pickup_distance_exceptions) do
			if key == level_id then
				if not exceptions then
					exceptions = {}
				end
				table.insert(exceptions, data)
			end
		end
	end
	
	-- grabbing_distance and nearby_distance are optional arguments >> define default values for them
	if grabbing_distance == nil then grabbing_distance = 3.5 end
	if nearby_distance == nil then nearby_distance = 20 end
	
	local player_near_with_empty_slot = false
	local player_in_grabbing_distance = false
	
	local players = Managers.player:players()
	local pickup_pos = (Unit.alive(pickup_unit) and POSITION_LOOKUP[pickup_unit]) or false
	
	local pickup_extension = ScriptUnit.has_extension(pickup_unit, "pickup_system")
	local pickup_settings = pickup_extension and pickup_extension:get_pickup_settings()
	local pickup_slot = (pickup_settings and pickup_settings.slot_name) or false
	-- slot_healthkit	(heals, tomes)
	-- slot_potion		(potions, grims)
	-- slot_grenade		(grenades)
	-- slot_level_event	(explosive barrel, sack, statue, ...)
	
	local is_consumable_ammo = not pickup_slot and pickup_extension and pickup_extension.pickup_name == "all_ammo_small"
	local is_ammo_crate = not pickup_slot and pickup_extension and pickup_extension.pickup_name == "all_ammo"
	local bot_count, human_count = get_able_bot_human_data()
	
	if pickup_pos and (pickup_slot or is_consumable_ammo or is_ammo_crate) then
		for _,loop_owner in pairs(players) do
			if not loop_owner.bot_player then -- this loop checks for human players only
				local loop_unit = loop_owner.player_unit
				local loop_status_extension	= ScriptUnit.has_extension(loop_unit, "status_system")
				local loop_inventory_extension	= ScriptUnit.has_extension(loop_unit, "inventory_system")
				local loop_extensions_ok = loop_status_extension and loop_inventory_extension
				if loop_extensions_ok then
					local loop_disabled = loop_status_extension:is_disabled()
					if not loop_disabled then -- if the human is disabled then he/she isn't going to be pickuing up anything
						local loop_pos = POSITION_LOOKUP[loop_unit]
						local loop_pickup_distance = Vector3.length(loop_pos - pickup_pos)
						if exceptions then
							for _,data in pairs(exceptions) do
								if data.check:in_area(loop_pos) then
									grabbing_distance = data.distance
									-- debug_print_variables(grabbing_distance, loop_pickup_distance)
								end
							end
						end
						
						if not player_near_with_empty_slot and loop_pickup_distance < nearby_distance then -- check if a human player is somewhere near
							if pickup_slot then	-- ok, human player is near, does the player have something in the appropriate slot?
								local loop_inventory_item_data = loop_inventory_extension.get_slot_data(loop_inventory_extension, pickup_slot) or false
								if not loop_inventory_item_data then
									-- no >> then there is a player near with empty slot..
									player_near_with_empty_slot = true
								end
							elseif is_consumable_ammo then
								-- for consumable ammo, bots pick it only if playing solo with them or using forced pickup feature
								if human_count > 1 then
									player_near_with_empty_slot = true
								end
								--
							elseif is_ammo_crate then
								-- item in question is not consumable >> bots can loot it freely
								player_near_with_empty_slot = false
							end
						end
						if not player_in_grabbing_distance and loop_pickup_distance < grabbing_distance then -- check if a player is within reach of the item
							player_in_grabbing_distance = true
						end
						--
					end
				end
			end
		end
	end
	
	return player_near_with_empty_slot, player_in_grabbing_distance
end

-- Check if the equipped weapon of player / bot unit is sufficiently charged to execute a heavy attack.
-- In case of weapons with homing projectiles, the weapons also needs to be locked on to target.
local is_weapon_charged = function(self_unit)
	local ranged_weapon_charged = false
	local melee_weapon_charged = false
	
	-- get the equipped weapon's slot name
	local inventory_extension = ScriptUnit.has_extension(self_unit,"inventory_system")
	local wielded_slot_name = (inventory_extension and inventory_extension.get_wielded_slot_name(inventory_extension)) or false
	local melee_equipped = wielded_slot_name == "slot_melee"
	local ranged_equipped = wielded_slot_name == "slot_ranged"
	local trueflight_aim_active = false
	local trueflight_aim_target = false
	
	if wielded_slot_name then -- the wielded item must have a slot name..
		if self_unit then -- this check is probably redundant, but self_unit must be defined..
			local self_owner = Managers.player:unit_owner(self_unit)
			local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(self_unit)
			if weapon_unit then
				-- get the current action chain of the equipped weapon
				local weapon_extension = ScriptUnit.has_extension(weapon_unit, "weapon_system")
				local spread_extension = ScriptUnit.has_extension(weapon_unit, "spread_system")
				local action = weapon_extension and weapon_extension.current_action_settings
				
				-- analyze the action chain, most of the local definitions have been taken from the game's original code
				if action then
					local current_time = Managers.time:time("game")
					local current_time_in_action = current_time - weapon_extension.action_time_started
					local attack_speed_modifier = ActionUtils.apply_attack_speed_buff(1, self_unit)
					local release_input = false
					local light_attack = false
					
					if weapon_extension.actions and weapon_extension.actions.true_flight_bow_aim then
						trueflight_aim_active = true
						trueflight_aim_target = weapon_extension.actions.true_flight_bow_aim.target
					end
					
					-- now when we have the current action chain, go throught the current allowed sub-actions and
					-- determine if heavy attack would be the result of the appropriate input at this moment in time
					for _,chain_info in pairs(action.allowed_chain_actions) do
						if chain_info and chain_info.sub_action then
							local start_time = chain_info.start_time or 0
							local end_time = chain_info.end_time or math.huge
							local modified_start_time = start_time / attack_speed_modifier
							local after_start = current_time_in_action > modified_start_time
							local before_end = current_time_in_action < end_time
							local sub_action = chain_info.sub_action
							
							-- sub_action:
							-- conflag		geiser_launch
							-- fireball		shoot_charged
							-- beam			charged_beam
							-- bolt			shoot_charged
							-- bolt			shoot_charged_2
							-- bolt			shoot_charged_3
							-- bow			shoot_charged
							-- snipers		zoomed_shot		
							-- wolleybow	zoomed_shot		
							-- rep_handgun	bullet_spray		
							-- rep_pistol	bullet_spray		
							-- brace		fast_shot
							-- >> keywords: geiser, charged, zoomed, spray, fast_shot
							
							if ranged_equipped then
								-- for ranged attacks its enough taht we find action_one tied sub-action that
								-- has one of the select search words in it
								local ranged_keyword_match =	string.find(sub_action,"geiser") or
																string.find(sub_action,"charged") or
																string.find(sub_action,"zoomed") or
																string.find(sub_action,"spray") or
																string.find(sub_action,"fast_shot")
								-- use this for ranged
								
								local spread_ok = true
								if self_owner.bot_player and weapon_type == "bw_staff_beam" and spread_extension then
									-- for bots, beam staff requires special handling due to large inaccuracy right after starting the beam
									local pitch, yaw = spread_extension:get_current_pitch_and_yaw()
									
									-- also, stop bot trying to snipe the ogre with beam staff if the ogre isn't roughly facing the bot (broil the ogre with the beam instead) 
									local blackboard = Unit.get_data(self_unit, "blackboard")
									local target_unit = blackboard.target_unit
									local target_breed = target_unit and Unit.get_data(target_unit, "breed")
									local target_type = target_breed and target_breed.name
									local alignment_ok = true
									if target_type == "skaven_rat_ogre" then
										local in_front, flanking = check_alignment_to_target(self_unit, target_unit)
										alignment_ok = in_front
									end
									
									local self_pos = POSITION_LOOKUP[self_unit]
									local target_pos = POSITION_LOOKUP[target_unit]
									local target_distance = (self_pos and target_pos and Vector3.length(self_pos - target_pos)) or 1
									
									local pitch_yaw_threshold =	(target_distance < 15 and 1) or
																(target_distance < 25 and 0.7) or 0.5
									
									spread_ok = pitch < pitch_yaw_threshold and yaw < pitch_yaw_threshold and alignment_ok
								end
								
								if spread_ok and after_start and before_end and (chain_info.input == "action_one" or (not self_owner.bot_player and chain_info.input == "action_one_mouse")) and ranged_keyword_match then
									ranged_weapon_charged = true
								end
							end
							
							if melee_equipped then
								-- for melee actions we really need to go through the whole chain..
								-- use this for melee
								if after_start and before_end and not light_attack then
									if chain_info.input == "action_one_release" then
										if string.find(sub_action,"light") then
											light_attack = true
										else
											release_input = true
										end
									end
								end
							end
						end
					end
					
					-- .. and check that there is no subaction for input "action_one_release" that results into a light attack
					if not light_attack and release_input then
						-- this does not trigger when charging ranged weapon
						melee_weapon_charged = true
					end
				end
			end
		end
	end
	
	local weapon_charged = (melee_equipped and melee_weapon_charged) or (ranged_equipped and ranged_weapon_charged and (not trueflight_aim_active or trueflight_aim_target ~= nil))
	
	return weapon_charged
end

-- Check if the equipped melee weapon is ready to push
local is_weapon_ready_to_push = function(self_unit)
	local ready_to_push = false
	
	-- get the equipped weapon's slot name
	local inventory_extension = ScriptUnit.has_extension(self_unit,"inventory_system")
	local wielded_slot_name = (inventory_extension and inventory_extension.get_wielded_slot_name(inventory_extension)) or false
	local melee_equipped = wielded_slot_name == "slot_melee"
	
	if melee_equipped then -- only melee weapons can push
		if self_unit then -- this check is probably redundant, but self_unit must be defined..
			local self_owner = Managers.player:unit_owner(self_unit)
			local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(self_unit)
			if weapon_unit then
				-- get the current action chain of the equipped weapon
				local weapon_extension = ScriptUnit.has_extension(weapon_unit, "weapon_system")
				local action = weapon_extension and weapon_extension.current_action_settings
				
				-- analyze the action chain
				if action then
					local current_time = Managers.time:time("game")
					local current_time_in_action = current_time - weapon_extension.action_time_started
					local attack_speed_modifier = ActionUtils.apply_attack_speed_buff(1, self_unit)
					
					-- now when we have the current action chain, go throught the current allowed sub-actions and
					-- determine if push would be the result of the appropriate input at this moment in time
					for _,chain_info in pairs(action.allowed_chain_actions) do
						if chain_info and chain_info.sub_action then
							local start_time = chain_info.start_time or 0
							local end_time = chain_info.end_time or math.huge
							local modified_start_time = start_time / attack_speed_modifier
							local after_start = current_time_in_action > modified_start_time
							local before_end = current_time_in_action < end_time
							local sub_action = chain_info.sub_action
							
							if after_start and before_end and chain_info.input == "action_one" and sub_action == "push" then
								ready_to_push = true
							end
							
						end
					end
				end
			end
		end
	end
	
	return ready_to_push
end

-- This function forces bot to reload its renged weapon if there is no enemies nearby.
-- Also forces the bot to wield melee weapon if it has no target enemy.
-- Does NOT make heat weapon carriers vent.
local reload_bot_ranged_weapon = function(d)
	local self_unit			= d.unit
	local target_unit		= d.melee.target_unit
	local blackboard		= Unit.get_data(d.unit, "blackboard")
	local ally_needs_pickup	= blackboard.target_ally_need_type == "knocked_down" or blackboard.target_ally_need_type == "ledge" or blackboard.target_ally_need_type == "hook"
	local may_reload		= target_unit == nil and (d.equipped.ranged or d.equipped.melee) and not ally_needs_pickup
	
	-- force bot to reload only if it has no current target
	if may_reload then
		--  check first that the ranged weapon needs reloading..
		if d.equipped.ranged_can_reload then
			-- then check if ranged weapon is equipped
			if not d.equipped.ranged then
				-- if not then equip it
				d.extensions.input:wield("slot_ranged")
			else
				-- if equipped, then initiate reload
				local weapon_extension	= d.equipped.weapon_extension
				local ammo_extension	= weapon_extension and weapon_extension.ammo_extension
				if ammo_extension and ammo_extension:can_reload() then
					ammo_extension:start_reload(true)
				end
			end
		else
			-- if there is no need to reload
			if d.equipped.ranged then
				-- but ranged is equipped
				local weapon_extension	= d.equipped.weapon_extension
				local ammo_extension	= weapon_extension and weapon_extension.ammo_extension
				if not ammo_extension or not ammo_extension:is_reloading() then
					-- then swap back to melee if the bot is not reloading
					d.extensions.input:wield("slot_melee")
				end
			end
		end
	else
		--
	end
	
	return
end

-- This function forces bot to vent its renged weapon if there is no enemies nearby.
-- Also forces the bot to wield melee weapon if it has no target enemy.
local vent_bot_ranged_weapon = function(d, combat)
	local self_unit			= d.unit
	local target_unit		= d.melee.target_unit
	local no_target			= target_unit == nil
	local blackboard		= Unit.get_data(d.unit, "blackboard")
	local ally_needs_pickup	= blackboard.target_ally_need_type == "knocked_down" or blackboard.target_ally_need_type == "ledge" or blackboard.target_ally_need_type == "hook"
	local area_threat		= is_unit_in_aoe_explosion_threat_area(d.unit)
	local venting_allowed	= d.enough_hp_to_vent and not area_threat and not ally_needs_pickup
	
	if d.equipped.ranged or d.equipped.melee then
		if combat then
			-- this function should be called with "combat" flag only from the ranged shot obstruction check function
			-- >> ranged is always equipped and melee should not be swapped after venting
			local needs_to_vent		= venting_allowed and d.overheated and not d.regroup.enabled
			if needs_to_vent then
				-- start venting
				d.token.ranged_vent	= true
			else
				-- stop venting
				d.token.ranged_vent	= false
			end
		elseif no_target then
			-- this function is called without "combat" flag from the target selection in which case the bot's target needs
			-- also be nil in order for the venting_allowwed to resolve true >> vent fully and swap to melee after venting
			local needs_to_vent		= venting_allowed and (d.equipped.heat_amount > d.vent_heat_threshold) and not d.regroup.enabled
			if needs_to_vent then
				if d.equipped.melee then
					-- swap to ranged so the bot can vent
					d.extensions.input:wield("slot_ranged")
				else
					-- start venting
					d.token.ranged_vent	= true
				end
			else
				if d.is_venting then
					-- stop venting
					d.token.ranged_vent	= false
				elseif d.equipped.ranged then
					-- swap back to melee if the bot is not venting
					d.extensions.input:wield("slot_melee")
				end
			end
		end
	end
end

--edit start--

local get_hotkey_state = function(key)
	local key_index = Keyboard.button_index(key)
	local chat_active = (Managers.chat.chat_gui.chat_focused and true) or false
	
	if key_index then
		return (not chat_active) and Keyboard.button(key_index) > 0.5
	else
		EchoConsole("invalid hotkey : <" .. tostring(key) .. ">")
		return false
	end
end

--[[
local manual_heal_command_key_last_state = {}
local manual_heal_command_save = {}
local last_echo_time = 0

local get_hotkey_state = function(key)
	local chat_active = (Managers.chat.chat_gui.chat_focused and true) or false
	if chat_active then
		return false
	end
	
	-- local key_index = Keyboard.button_index(key)
	
	-- if key_index and Keyboard.button(key_index) > 0.5 then
		-- EchoConsole("key = " .. key)
	-- end
	
	-- local heal_command_keys = {
		-- get(me.SETTINGS.MANUAL_HEAL_KEY1),
		-- get(me.SETTINGS.MANUAL_HEAL_KEY2),
		-- get(me.SETTINGS.MANUAL_HEAL_KEY3),
		-- get(me.SETTINGS.MANUAL_HEAL_KEY4),
	-- }
	-- local heal_command_index = nil
	-- local is_heal_command_key = false
	-- for i = 1, 4, 1 do
		-- if heal_command_keys[i] == key then
			-- heal_command_index = i
			-- is_heal_command_key = true
		-- end
	-- end
	
	local heal_command_index = (key == get(me.SETTINGS.MANUAL_HEAL_KEY1) and 0) or
								(key == get(me.SETTINGS.MANUAL_HEAL_KEY2) and 1) or
								(key == get(me.SETTINGS.MANUAL_HEAL_KEY3) and 2) or 
								(key == get(me.SETTINGS.MANUAL_HEAL_KEY4) and 3) or nil
								 
	-- if is_heal_command_key then 
	if heal_command_index then
		local t = Managers.time:time("game")
		if last_echo_time < t then
			last_echo_time = t + 1
			
			EchoConsole("heal command pressed")
			EchoConsole("heal_command_index = " .. heal_command_index)
		end
		--------------
		-- Vernon TODO: make the hold press state work only for medkit healing (otherwise might double heal with draughts)

		-- local selected_player = nil
		-- local selected_player_id = heal_command_index - 1
		
		-- local ingame_ui = Managers.matchmaking.ingame_ui
		-- local unit_frames_handler = ingame_ui and ingame_ui.ingame_hud.unit_frames_handler
		-- if unit_frames_handler then
			-- The unit frames and player_data are never nil, although player might be.
			-- Vernon TODO: check for true solo...
			-- selected_player = unit_frames_handler._unit_frames[selected_player_id + 1].player_data.player
		-- end
		-- local selected_unit = selected_player and selected_player.player_unit

		--------------
		local key_index = Keyboard.button_index(key)
		if key_index then
			-- local t = Managers.time:time("game")
			local key_pressed = Keyboard.button(key_index) > 0.5
			EchoConsole("key_pressed = " .. tostring(key_pressed))
			
			-- only detects state change from unpressed to pressed
			if key_pressed and not manual_heal_command_key_last_state[key] then
				if (not manual_heal_command_save[key]) or (manual_heal_command_save[key] < t) then
					manual_heal_command_save[key] = t + 2.1
				else
					manual_heal_command_save[key] = nil
				end
			end
			
			manual_heal_command_key_last_state[key] = key_pressed
			
			if manual_heal_command_save[key] and (t <= manual_heal_command_save[key]) then
				-- manual_heal_command_save[key] = nil
				
				return true
			elseif manual_heal_command_save[key] and (manual_heal_command_save[key] < t) then
				manual_heal_command_save[key] = nil
			end
			
			return false
		else
			EchoConsole("invalid hotkey : <" .. tostring(key) .. ">")
			return false
		end
	-- original function below
	else
		local key_index = Keyboard.button_index(key)
		local chat_active = (Managers.chat.chat_gui.chat_focused and true) or false
		
		if key_index then
			-- return (not chat_active) and Keyboard.button(key_index) > 0.5
			return Keyboard.button(key_index) > 0.5
		else
			EchoConsole("invalid hotkey : <" .. tostring(key) .. ">")
			return false
		end
	end
end
--]]
--edit end--

-- Vernon: new functions
--[[
local refine_dodge_movement = function(d, move_x, move_y)
	if not move_x or not move_y then
		local move_direction = d.extensions.input:get("move_controller")
		move_x = move_x or move_direction.x or 0
		move_y = move_y or move_direction.y or 0
	end
	
	move_y = math.min(move_y, 0)
	
	-- side dodge for assassins and packmasters
	if d.defense.need_to_dodge_packmaster or d.defense.need_to_dodge_assassin then
		move_y = 0
		if move_x == 0 then
			-- Vernon TODO: make this random?
			move_x = -1
		end
	-- back dodge for ogres
	elseif #d.defense.threat_boss > 0 then
		move_x = 0
		if move_y == 0 then
			move_y = -1
		end
	end
	
	-- check for stationary dodge
	if move_x == 0 and move_y == 0 then
		move_y = -1
	-- normalize otherwise
	else
		local length = math.sqrt(move_x * move_x + move_y * move_y)
		move_x = move_x / length
		move_y = move_y / length
	end
	
	return move_x, move_y
end
--]]

local fix_dodge_movement = function(move_x, move_y)
	move_y = math.min(move_y, 0)

	-- check for stationary dodge
	if move_x == 0 and move_y == 0 then
		move_y = -1
	-- normalize otherwise
	else
		local length = math.sqrt(move_x * move_x + move_y * move_y)
		move_x = move_x / length
		move_y = move_y / length
	end
	
	return move_x, move_y
end

local world_direction_to_local_direction = function(unit, world_vector)
	if not unit or not world_vector then
		return
	end
	
	local rot = Unit.local_rotation(unit, 0)	-- Vernon: this should be a "flat" rotation from testing
	local inverse_rot = Quaternion.inverse(rot)
	local local_vector = Quaternion.rotate(inverse_rot, world_vector)
	
	return local_vector
end

local local_direction_to_world_direction = function(unit, local_vector)
	if not unit or not local_vector then
		return
	end
	
	local rot = Unit.local_rotation(unit, 0)	-- Vernon: this should be a "flat" rotation from testing
	local world_vector = Quaternion.rotate(rot, local_vector)
	
	return world_vector
end

local side_dodge_direction = function(d, threat_pos, original_move_direction)
	if not d or not threat_pos then
		if original_move_direction then
			return original_move_direction.x, original_move_direction.y
		else
			return
		end
	end

	local offset = Vector3.flat(threat_pos - d.position)
	-- Vernon: rotate by 90 degrees anti-clockwise top-down
	-- local rotated_offset = Vector3(-offset.y, offset.x, offset.z)
	local rotated_offset = Vector3(-offset.y, offset.x, 0)
	local move_direction_left = world_direction_to_local_direction(d.unit, rotated_offset)
	-- local move_direction_right = Vector3(-move_direction_left.y, -move_direction_left.x, move_direction_left.z)
	local move_direction_right = Vector3(-move_direction_left.y, -move_direction_left.x, 0)
	
	-- Vernon: check the dodge direction doesn't change too much after fixing...
	-- Vernon: 1.7 is about 30 degrees off... switching to 1.2 (39.8 degrees) because back-left and back-right should be considered too
	if 0 < move_direction_left.y and math.abs(move_direction_left.x) < move_direction_left.y * 1.2 then		--1.7
		return fix_dodge_movement(move_direction_right.x, move_direction_right.y)
	elseif 0 < move_direction_right.y and math.abs(move_direction_right.x) < move_direction_right.y * 1.2 then	--1.7
		return fix_dodge_movement(move_direction_left.x, move_direction_left.y)
	-- Vernon: in case both directions are acceptable, choose left or right dodge that is better aligned with the original direction
	elseif Vector3.dot(move_direction_right, original_move_direction) > 0 then
		return fix_dodge_movement(move_direction_right.x, move_direction_right.y)
	else
		return fix_dodge_movement(move_direction_left.x, move_direction_left.y)
	end
end

local back_dodge_direction = function(d, threat_pos, original_move_direction)
	if not d or not threat_pos then
		if original_move_direction then
			return original_move_direction.x, original_move_direction.y
		else
			return
		end
	end
	
	local offset = Vector3.flat(d.position - threat_pos)	-- Vernon: reversed direction already
	local move_direction_back = world_direction_to_local_direction(d.unit, offset)
	local move_direction_left = Vector3(-move_direction_back.y, move_direction_back.x, 0)
	local move_direction_right = Vector3(move_direction_left.y, -move_direction_left.x, 0)
	local dot_back = Vector3.dot(move_direction_back, offset)
	local dot_left = Vector3.dot(move_direction_left, offset)
	local dot_right = Vector3.dot(move_direction_right, offset)

--[[
	if move_direction_back.y <= 0 or (0 < move_direction_back.y and math.abs(move_direction_back)) then
		return fix_dodge_movement(move_direction_back.x, move_direction_back.y)
	-- Vernon TODO: unless bots are coded to change facing direction before dodging, just try to dodge left or right
	else
		-- Vernon: in this case threat is at the back of the bot, so rotate left is left
		-- local rotated_offset = Vector3(-offset.y, offset.x, offset.z)
		local rotated_offset = Vector3(-offset.y, offset.x, 0)
		local move_direction_left = world_direction_to_local_direction(d.unit, rotated_offset)
		-- local move_direction_right = Vector3(-move_direction_left.y, -move_direction_left.x, move_direction_left.z)
		local move_direction_right = Vector3(-move_direction_left.y, -move_direction_left.x, 0)
		local dot = Vector3.dot(move_direction_right, original_move_direction)
		if Vector3.dot(move_direction_right, original_move_direction) > 0
	end
--]]

	-- Vernon: choose one from back, left or right that aligns with the offset the best
	if dot_left <= dot_back then
		if dot_right <= dot_back then
			return fix_dodge_movement(move_direction_back.x, move_direction_back.y)
		-- Vernon: dot_left <= dot_back < dot_right
		else
			return fix_dodge_movement(move_direction_right.x, move_direction_right.y)
		end
	-- Vernon: dot_back < dot_left
	else
		if dot_right <= dot_left then
			return fix_dodge_movement(move_direction_left.x, move_direction_left.y)
		-- Vernon: dot_back < dot_left < dot_right
		else
			return fix_dodge_movement(move_direction_right.x, move_direction_right.y)
		end
	end
end

local refine_dodge_movement = function(d, move_x, move_y)
	local original_move_direction = d.extensions.input:get("move_controller")
	
	if not move_x or not move_y then
		move_x = move_x or original_move_direction.x or 0
		move_y = move_y or original_move_direction.y or 0
	end
	
	local move_direction = Vector3(move_x, move_y, 0)
	
	-- d.defense.pos_trash_to_dodge = nil	-- Vernon: added data
	-- d.defense.pos_fast_trash_to_dodge = nil	-- Vernon: added data
	-- d.defense.pos_sv_sweep_to_dodge = nil	-- Vernon: added data
	-- d.defense.pos_sv_overhead_to_dodge = nil	-- Vernon: added data
	-- d.defense.pos_ogre_to_dodge = nil	-- Vernon: added data
	-- d.defense.pos_packmaster_to_dodge = nil	-- Vernon: added data
	-- d.defense.pos_assassin_to_dodge = nil	-- Vernon: added data
	
	-- Vernon: for now ranked by damage then stamina block cost on cata, so ...
	-- Vernon: SV overhead > ogre overhead (unblockable) > assassins (they do direct damage and harder to kill) > packmasters > ogre punch > SV sweep > trash running attack > trash standing attack etc.
	-- Vernon: other difficulties might see a different priority
	-- Vernon TODO: Could also average out multiple threats (side dodge or back dodge) to determine the dodge direction
	
	local num_threat_trash			= #d.defense.threat_trash
	local num_threat_stormvermin	= #d.defense.threat_stormvermin
	-- local num_threat_boss				= #d.defense.threat_boss
	-- local num_threat_boss_unblockable	= #d.defense.threat_boss_unblockable
	
	if num_threat_stormvermin > 0 and d.defense.pos_sv_overhead_to_dodge then
		return side_dodge_direction(d, d.defense.pos_sv_overhead_to_dodge, move_direction)
	end
	
	if #d.defense.threat_boss_unblockable > 0 and d.defense.pos_ogre_to_dodge then
		return back_dodge_direction(d, d.defense.pos_ogre_to_dodge, move_direction)
	end
	
	if d.defense.need_to_dodge_assassin then
		if d.defense.pos_assassin_to_dodge then
			return side_dodge_direction(d, d.defense.pos_assassin_to_dodge, move_direction)
		else
			move_y = 0
			if move_x == 0 then
				-- Vernon TODO: make this random?
				move_x = -1
			end
		end
	end
	
	if d.defense.need_to_dodge_packmaster then
		if d.defense.pos_packmaster_to_dodge then
			return side_dodge_direction(d, d.defense.pos_packmaster_to_dodge, move_direction)
		else
			move_y = 0
			if move_x == 0 then
				-- Vernon TODO: make this random?
				move_x = -1
			end
		end
	end
	
	if #d.defense.threat_boss > 0 and d.defense.pos_ogre_to_dodge then
		return back_dodge_direction(d, d.defense.pos_ogre_to_dodge, move_direction)
	end
	
	if num_threat_stormvermin > 0 and d.defense.pos_sv_overhead_to_dodge then
		return back_dodge_direction(d, d.defense.pos_sv_overhead_to_dodge, move_direction)
	end
	
	if num_threat_trash > 0 and d.defense.pos_fast_trash_to_dodge then
		return side_dodge_direction(d, d.defense.pos_fast_trash_to_dodge, move_direction)
	end
	
	-- if num_threat_trash > 0 and d.defense.pos_trash_to_dodge then
	-- Vernon: basically just dodge in any direction in this case...
	
	return fix_dodge_movement(move_x, move_y)
end

local function position_is_infront_of_target_unit(pos, target_unit, opt_infront_angle)
	local infront_angle	= opt_infront_angle or 90	-- deg forward cone
	local target_unit_pos = POSITION_LOOKUP[target_unit]
	
	if pos and target_unit_pos then
		local pos_copy = Vector3.copy(pos)
		local target_unit_pos_copy = Vector3.copy(target_unit_pos)
		Vector3.set_z(pos_copy,0)
		Vector3.set_z(target_unit_pos_copy,0)
		local enemy_offset = target_unit_pos_copy - pos_copy
		local enemy_rot = Unit.local_rotation(target_unit, 0)
		local enemy_dir = Quaternion.forward(enemy_rot)
		local dot = Vector3.dot(enemy_dir, enemy_offset)
		local div = Vector3.length(enemy_dir) * Vector3.length(enemy_offset)
		if div ~= 0 then
			dot = dot / div
		end
		
		local infront_angle_compare	= math.cos(((180-(infront_angle * 0.5)) / 180) * math.pi)
		if infront_angle_compare > dot then
			return true
		end
	end
	
	return false
end

local position_is_under_this_stormvermin_aoe = function(pos, sv_unit, sv_blackboard)
	if not sv_blackboard.special_attacking_target then
		return false
	end
	
	local is_sv_overhead = sv_blackboard.action and sv_blackboard.action.name == "special_attack_cleave"
	local is_sv_sweep = sv_blackboard.action and sv_blackboard.action.name == "special_attack_sweep"
	
	if not is_sv_overhead and not is_sv_sweep then
		return false
	end
	
	local in_front_of_loop = false
	local in_front_angle = (is_sv_sweep and 100) or 60
	-- local in_front_of_loop = position_is_infront_of_target_unit(pos, sv_unit, in_front_angle)
	-- Vernon: copied the script to save some distance calculations
	local sv_pos = sv_unit and POSITION_LOOKUP[sv_unit]
	
	if pos and sv_pos then
		local pos_copy = Vector3.copy(pos)
		local target_unit_pos_copy = Vector3.copy(sv_pos)
		Vector3.set_z(pos_copy,0)
		Vector3.set_z(target_unit_pos_copy,0)
		local enemy_offset = target_unit_pos_copy - pos_copy
		local enemy_rot = Unit.local_rotation(sv_unit, 0)
		local enemy_dir = Quaternion.forward(enemy_rot)
		local dot = Vector3.dot(enemy_dir, enemy_offset)
		local div = Vector3.length(enemy_dir) * Vector3.length(enemy_offset)
		if div ~= 0 then
			dot = dot / div
		end
		
		local infront_angle_compare	= math.cos(((180-(in_front_angle * 0.5)) / 180) * math.pi)
		if infront_angle_compare > dot then
			in_front_of_loop = true
		end
	end

	if in_front_of_loop then
		local threat_range = (is_sv_overhead and 5.5) or (is_sv_sweep and 3) or 0
		local distance = pos and sv_pos and Vector3.length(pos - sv_pos)
		if distance < threat_range then
			return true
		end
	end
	
	return false
end

local position_is_under_threat = function(d, pos)
	-- this function checks SV AoE attacks, gas, area threats, ogres and krench, and maybe ratling fire lines
	
	local nav_world		= Managers.state.entity:system("ai_system"):nav_world()
	local group_system	= Managers.state.entity:system("ai_bot_group_system")
	
	if pos and nav_world and group_system then
		local in_threat_area, _		= group_system:_selected_unit_is_in_disallowed_nav_tag_volume(nav_world, pos)
		if in_threat_area then
			return true
		end
	end
	
	for _, loop_unit in pairs(d.enemies.medium_sv) do
		local loop_bb = Unit.get_data(loop_unit, "blackboard")
		
		if position_is_under_this_stormvermin_aoe(pos, loop_unit, loop_bb) then
			return true
		end
	end
	
	for _, loop_unit in pairs(d.enemies.bosses) do
		-- Vernon: most codes modified from _defend function
		local loop_breed = Unit.get_data(loop_unit, "breed")
		local loop_bb = Unit.get_data(loop_unit, "blackboard")
		local loop_distance = pos and POSITION_LOOKUP[loop_unit] and Vector3.length(pos - POSITION_LOOKUP[loop_unit])
		
		-- Vernon TODO: maybe modify this to be the same as d_data_update?
		if loop_breed.name == "skaven_rat_ogre" then
			if loop_bb.target_unit == d.unit and loop_distance and loop_distance < 5 then
				return true
			end
			
			if loop_bb.attacking_target or loop_bb.special_attacking_target then
				local in_front_of_loop = position_is_infront_of_target_unit(pos, loop_unit, 180)	--160
				
				if in_front_of_loop and loop_distance < 4 then
					return true
				end
			end
		end
		
		if loop_breed.name == "skaven_storm_vermin_champion" then
			-- Krench
			-- local extended_defense			= d.defense.krench_extension > d.current_time
			
			if loop_bb.attacking_target or loop_bb.special_attacking_target then
				-- Krench uses aoe attacks so any attack is a threat if bot is in threat area
				
				local attack_initialized	= loop_bb.move_state and loop_bb.move_state == "attacking"
				local attack_anim			= "none"
				if attack_initialized then
					local action	= loop_bb.action
					if action then
						local seq	= loop_bb.action.attack_sequence
						if seq then
							-- if the execuition gets here then attack_next_sequence_index > 1 or.. nil if doing the last action in the chain
							-- this is handled in BTStormVerminAttackAction
							local next_index	= loop_bb.attack_next_sequence_index
							local current_index	= (next_index and next_index -1) or #seq
							attack_anim			= seq[current_index].attack_anim
						else
							attack_anim			= loop_bb.action.attack_anim
						end
					end
				end
				-- attack anim translation..
				-- ***********************
				-- attack_special			= normal overhead
				-- attack_sweep_left		= normal sweep
				-- attack_sweep_right		= normal sweep
				-- charge_attack_step		= prepare for lunge
				-- charge_attack_lunge		= lunge
				-- attack_run_2				= jump strike
				-- attack_charge_special	= prepare charged overhead
				-- attack_charge_shatter	= charged overhead
				-- attack_spin_charge		= prepare charged spin
				-- attack_spin				= charged spin
				
				local spin_reach				= 8
				local krench_target				= loop_bb.special_attacking_target
				local spin_aoe					= attack_anim == "attack_spin" or attack_anim == "attack_spin_charge"
				local line_aoe					= attack_anim == "charge_attack_step" or attack_anim == "charge_attack_lunge" or attack_anim == "attack_charge_shatter"
				local jump_strike				= attack_anim == "attack_run_2"
				local regular_attack			= attack_anim == "attack_special" or attack_anim == "attack_sweep_left" or attack_anim == "attack_sweep_right"
				
				if regular_attack then
					local in_front_of_loop = position_is_infront_of_target_unit(pos, loop_unit, 120)
					if in_front_of_loop and loop_distance < medium_radius then
						return true
					end
				elseif jump_strike then
					local distance_to_krench_target	= (krench_target and POSITION_LOOKUP[krench_target] and pos and Vector3.distance(POSITION_LOOKUP[krench_target], pos)) or 0
					if distance_to_krench_target < 2 then	--3
						return true
					end
				elseif spin_aoe then
					if loop_distance < spin_reach then
						-- d.defense.krench_extension = d.current_time + 0.7
						return true
					end
				elseif line_aoe then
					local in_front_of_loop = position_is_infront_of_target_unit(pos, loop_unit, 60)	--90
					if in_front_of_loop then
						-- d.defense.krench_extension = d.current_time + 0.5
						return true
					end
				end
				--
			-- elseif extended_defense then
				-- table.insert(d.defense.threat_boss,loop_unit)
			end
		end
	end
	
	-- Vernon TODO: add ratling fire lines?
end

-- === collision_filter list ===
--[[
-- filter_player_ray_projectile
-- filter_player_ray_projectile_no_player
-- filter_geiser_check
-- filter_melee_sweep
-- filter_ai_mover
-- filter_enemy_ray_projectile
-- filter_character_trigger
-- filter_bot_ranged_line_of_sight_no_allies_no_enemies
-- filter_bot_ranged_line_of_sight_no_allies
-- filter_bot_ranged_line_of_sight_no_enemies
-- filter_bot_ranged_line_of_sight
-- filter_lookat_pickup_object_ray
-- filter_lookat_object_ray
-- filter_ai_line_of_sight_check
-- filter_melee_sweep_no_player
-- filter_player_hammer_leap_mover
-- filter_player_mover
-- filter_player_hit_box_check
-- filter_player_ray_projectile_static_only
-- filter_player_ray_projectile_ai_only
-- filter_player_ray_projectile_hitbox_only
-- filter_ray_interaction
-- filter_overlap_interaction
-- filter_interactable_in_chest
-- filter_ray_ping
-- filter_physics_projectile_large
-- filter_rat_ogre_melee_slam
-- filter_player_and_husk_trigger
-- filter_ray_projectile
-- filter_ray_aim_assist
-- filter_enemy_player_ray_projectile
-- filter_player_and_enemy_hit_box_check
-- filter_enemy_unit
-- n/a
-- filter_bot_nav_transition_overlap
-- filter_bot_nav_transition_ladder_ray
-- filter_environment_overlap
-- filter_weapon_nailing
-- filter_explosion_overlap_no_player
-- filter_explosion_overlap
-- filter_melee_trigger
-- filter_ground_material_check
-- filter_tutorial
-- filter_camera_sweep
-- filter_ray_horde_spawn
--]]

local can_dodge_in_this_direction_safely = function(d, move_x, move_y)
	-- Vernon: return true/false, reason; reason list is:
	-- no_nav_mesh
	-- obstructed
	-- body_blocked
	-- unsafe
	-- safe
	
	if not move_x or not move_y then
		-- local dodge_input = CharacterStateHelper.get_movement_input(input_ext)
		local move_direction = d.extensions.input:get("move_controller")
		move_x = move_x or move_direction.x or 0
		move_y = move_y or move_direction.y or 0
	end
	
	move_x, move_y = refine_dodge_movement(d, move_x, move_y)
	
	local dodge_direction = Vector3(move_x, move_y, 0)
	dodge_direction = local_direction_to_world_direction(d.unit, dodge_direction)
	local dodge_distance = d.equipped.dodge_distance or 2
	
	-- Vernon: min dodge distance is 1.7 for shields and 2h hammers etc.
	local dodge_goal = d.position + dodge_distance * dodge_direction
	local dodge_goal_half = d.position + (dodge_distance/2) * dodge_direction
	local half_dodge = false
	local cant_use_dodge_goal = false
	
	-- check map geometry
	-- Vernon TODO: maybe add line of sight checks too
	
	local nav_world = Managers.state.bot_nav_transition._nav_world
	local traverse_logic = Managers.state.bot_nav_transition._traverse_logic
	local above		= 0.75	--1
	local below		= 0.75	--1
	local success, z = GwNavQueries.triangle_from_position(nav_world, dodge_goal, above, below)
	if success then
		dodge_goal.z = z
		local mover = Unit.mover(d.unit)
		local fit_half_way = Mover.fits_at(mover, dodge_goal_half + Vector3(0,0,0.2))
		
		if not GwNavQueries.raycango(nav_world, d.position, dodge_goal, traverse_logic) or not fit_half_way or not Mover.fits_at(mover, dodge_goal + Vector3(0,0,0.2)) then
			half_dodge = true
			
			if not GwNavQueries.raycango(nav_world, d.position, dodge_goal_half, traverse_logic) or not fit_half_way then
				return false, "obstructed", half_dodge
			end
		end
	else
		-- cant stand at dodge_goal
		local mover = Unit.mover(d.unit)
		if Mover.fits_at(mover, d.position + dodge_distance * (2/3) * dodge_direction + Vector3(0,0,0.2)) then
			return false, "no_nav_mesh", half_dodge
		else
			half_dodge = true
		end
	end
	
	-- check enemy body blocks
	
	-- PlayerUnitLocomotionExtension.update_script_driven_movement
	-- local ai_units = {}
	-- local num_ai_units = AiUtils.broadphase_query(dodge_goal, query_radius, ai_units)
	
	local enemy_check_list = {}
	enemy_check_list = table.merge(enemy_check_list, d.enemies.near)
	-- Vernon: ogres are too large to be included in near radius
	enemy_check_list = table.merge(enemy_check_list, d.enemies.bosses)
	
	local blocked_right = false
	local blocked_left = false
	
	for _, loop_unit in pairs(enemy_check_list) do
		local loop_breed = Unit.get_data(loop_unit, "breed")
		local loop_radius = (loop_breed.player_locomotion_constrain_radius and loop_breed.player_locomotion_constrain_radius * 2) or nil
		local loop_offset = d.position and POSITION_LOOKUP[loop_unit] and POSITION_LOOKUP[loop_unit] - d.position
		local loop_distance = (loop_offset and Vector3.length(loop_offset)) or math.huge
		
		-- exclude trivial case
		if loop_radius and loop_radius > 0 and loop_distance < dodge_distance + loop_radius then
			--https://en.wikipedia.org/wiki/Vector_projection#Scalar_rejection
			local scalar_rejection = loop_offset.y * move_x - loop_offset.x * move_y
			local distance_to_dodge_path = math.abs(scalar_rejection)
			
			local scalar_projection = Vector3.dot(loop_offset, dodge_direction)
			local distance_along_dodge_path = math.abs(scalar_projection)
			
			-- head on collision
			if distance_to_dodge_path < loop_radius/2 then
				if distance_along_dodge_path < dodge_distance then
					half_dodge = true
					
					if distance_along_dodge_path < dodge_distance/2 then
						return false, "body_blocked", half_dodge
					end
				end
			-- side way collisions
			elseif distance_to_dodge_path < loop_radius and distance_along_dodge_path < dodge_distance/2 then
				if scalar_rejection > 0 then
					blocked_right = true
				elseif scalar_rejection < 0 then
					blocked_left = true
				end
				
				if blocked_right and blocked_left then
					return false, "body_blocked", half_dodge
				end
			end
		end
	end
	
	-- check enemy threats
	if not half_dodge and position_is_under_threat(d, dodge_goal) then
		return false, "unsafe", half_dodge
	elseif half_dodge and position_is_under_threat(d, dodge_goal_half) then
		return false, "unsafe", half_dodge
	end
	
	return true, "safe", half_dodge
end

-- Vernon: below should be replaced by threat positions already
--[[
local calculate_dodge_direction = function(d)
	local self_pos = d.position
	local dodge_distance = d.equipped.dodge_distance
	
	local dodge_goals = {
		back = self_pos + dodge_distance * Vector3(0, -1, 0),
		right = self_pos + dodge_distance * Vector3(1, 0, 0),
		left = self_pos + dodge_distance * Vector3(-1, 0, 0),
		back_right = self_pos + dodge_distance * Vector3(0.7071, -0.7071, 0),
		back_left = self_pos + dodge_distance * Vector3(-0.7071, -0.7071, 0),
		
		half_back = self_pos + (dodge_distance/2) * Vector3(0, -1, 0),
		half_right = self_pos + (dodge_distance/2) * Vector3(1, 0, 0),
		half_left = self_pos + (dodge_distance/2) * Vector3(-1, 0, 0),
		half_back_right = self_pos + (dodge_distance/2) * Vector3(0.7071, -0.7071, 0),
		half_back_left = self_pos + (dodge_distance/2) * Vector3(-0.7071, -0.7071, 0),
	}
	
	
end
--]]

-- statistics_tracker_data
tracker_data =
{
	stat_trackers			= {},
	_resolve_tracker_key = function(unit)
		if not unit then
			return "default_tracker"
		end
		
		local owner		= Managers.player:unit_owner(unit)
		local name		= owner and owner:name()
		
		if not name then
			return "default_tracker"
		end
		
		local is_bot	= owner.bot_player
		name = (is_bot and "BOT " .. name) or name
		
		return name
	end,
	
	add_to_unit_tracker = function(self, unit, key, value)
		local tracker = self:get_unit_tracker(unit)
		if not tracker[key] then
			tracker[key] = 0
		end
		
		tracker[key] = tracker[key] + value
		
		return
	end,
	get_unit_tracker_value = function(self, unit, key)
		local tracker = self:get_unit_tracker(unit)
		return tracker:get_value(key)
	end,
	get_unit_tracker = function(self, unit)
		local tracker = 
		{
			name = "default name",
			get_value = function(self, key)
				if self[key] then
					return self[key]
				end
				return 0
			end,
		}
		
		local tracker_key = self._resolve_tracker_key(unit)
		
		if tracker_key == "default_tracker" then
			return tracker
		end
		
		tracker.name = tracker_key
		
		if not self.stat_trackers[tracker_key] then
			self.stat_trackers[tracker_key] = tracker
		end
		
		return self.stat_trackers[tracker_key]
	end,
}

-- storage for some debug data
debug_data = 
{
	damage_tracker_humans	= 0,
	damage_tracker_bots		= 0,
	stagger_tracker_humans	= 0,
	stagger_tracker_bots	= 0,
}

local ranged_keep_distance_default = 4	--3.5

-- bot settings store mainly static data that define the bot configuration
-- there is some dynamic data too though
local bot_settings =
{
	trash_SV_detection_distance = 20,
	assigned_enemies = {},
	breakable_objectives = {},
	
	lookup = 
	{
		can_interrupt_gutter = -- list weapons that can interrupt stabbing gutters with light attacks
		{
			-- melee weapons
			es_2h_war_hammer		= true,
			dr_2h_hammer			= true,
			dr_1h_axes				= true,
			wh_1h_axes				= true,
			dr_1h_hammer			= true,
			es_1h_mace				= true,
			dr_1h_hammer_shield		= true,
			es_1h_mace_shield		= true,
			dr_2h_picks				= true,
			es_2h_sword_exec		= true,
			wh_1h_falchions			= true,
			bw_morningstar			= true,
			ww_2h_axe				= true,
			
			-- ranged
			es_handgun				= true,	-- handguns technically can't interrupt the gutter,
			dr_handgun				= true, -- but on anything below deathwish the gutter instantly dies to the damage
			es_repeating_handgun	= true,
			es_blunderbuss			= true,	-- shotguns technically can't interrupt the gutter,
			dr_grudgeraker			= true, -- but should kill it when fired close range
			dr_drakefire_pistols	= true,
			wh_brace_of_pisols		= true,
			bw_staff_firball		= true,
			bw_staff_geiser			= true,
			bw_staff_beam			= true, -- beam / beam snipe won't interrupt gutter, beam shotgun does
		},
		
		cc_light_melee_chain_length = 
		{
			default				= math.huge,
			es_1h_sword			= 2,
			es_1h_mace			= 2,
			-- es_2h_sword			= no need to cancel chain
			es_2h_sword_exec	= 2,
			es_2h_war_hammer	= 1,
			es_1h_sword_shield	= 2,
			es_1h_mace_shield	= 2,
			
			bw_1h_sword			= 2,
			bw_flame_sword		= 2,
			-- bw_morningstar		= first swing is the head bong, rest are multi-target >> better not to cancel chain
			bw_morningstar		= 4,
			-- bw_dagger			= 4,
			
			dr_1h_axes			= 3,
			dr_1h_hammer		= 2,
			dr_2h_axes			= 1,
			dr_2h_hammer		= 1,
			-- dr_2h_picks			= no need to cancel chain
			-- dr_1h_axe_shield	= 3,
			dr_1h_hammer_shield	= 2,
			
			ww_1h_sword			= 2,
			ww_sword_and_dagger	= 2,
			-- ww_dual_swords		= 2,
			ww_dual_swords		= 3,
			-- ww_dual_daggers		= 4,
			ww_2h_axe			= 1,
			
			wh_1h_axes			= 3,
			wh_1h_falchions		= 2,
			wh_fencing_sword	= 2,	-- Vernon: light spam is faster than block canceling
			-- wh_2h_sword			= no need to cancel chain
		},

		-- Vernon: Ogre DPS sheet: https://docs.google.com/spreadsheets/d/1M973dlN783JlzwuwDqQuq7fc24850JeBzBzNbGZi_fo/edit#gid=1035311592
		ogre_light_melee_chain_length_block = 
		{
			-- default				= math.huge,
			-- es_1h_sword			= 2,
			-- es_1h_mace			= 2,
			-- es_2h_sword			= no need to cancel chain
			-- es_2h_sword_exec	= 2,
			es_2h_war_hammer	= 1,
			-- es_1h_sword_shield	= 2,
			es_1h_mace_shield	= 3,
			
			-- bw_1h_sword			= 2,
			-- bw_flame_sword		= 2,
			-- bw_morningstar		= first swing is the head bong, rest are multi-target >> better not to cancel chain
			bw_morningstar		= 2,
			-- bw_dagger			= 4,
			
			dr_1h_axes			= 3,	-- Vernon: for mobility
			dr_1h_hammer		= 2,
			dr_2h_axes			= 1,
			dr_2h_hammer		= 1,
			-- dr_2h_picks			= no need to cancel chain
			-- dr_1h_axe_shield	= 3,
			dr_1h_hammer_shield	= 3,
			
			-- ww_1h_sword			= 2,
			-- ww_sword_and_dagger	= 2,
			-- ww_dual_swords		= 2,
			ww_dual_swords		= 3,
			-- ww_dual_daggers		= 4,
			ww_2h_axe			= 1,
			
			wh_1h_axes			= 3,	-- Vernon: for mobility
			wh_1h_falchions		= 2,
			-- wh_fencing_sword	= 2,
			-- wh_2h_sword			= no need to cancel chain
		},
		
		-- Vernon TODO: implement QQ cancel
		ogre_light_melee_chain_length_switch = {
			dr_2h_axes			= 1,
			dr_2h_hammer		= 1,
			ww_2h_axe			= 1,
		},
		
		-- Vernon TODO: implement block cancel for charged attack
		ogre_use_melee_heavy_attack = {
			es_1h_mace			= true,
			dr_2h_picks			= true,
			dr_1h_hammer		= true,
			wh_1h_falchions		= {
				chain_length = 1,
				condition = "flanking",
			},
		},
		
		ranged_keep_distance = {
			bw_staff_beam = {
				charged = ranged_keep_distance_default,
			},
			bw_staff_firball = {
				both = ranged_keep_distance_default,
			},
			bw_staff_geiser = {
				both = ranged_keep_distance_default,
			},
			bw_staff_spear = {
				both = ranged_keep_distance_default,
			},
			dr_crossbow = {
				both = ranged_keep_distance_default,
			},
			dr_drakefire_pistols = {
				normal = ranged_keep_distance_default,
			},
			dr_grudgeraker = {
				normal = 3,
			},
			dr_handgun = {
				both = ranged_keep_distance_default,
			},
			es_blunderbuss = {
				normal = 3,
			},
			es_handgun = {
				both = ranged_keep_distance_default,
			},
			es_repeating_handgun = {
				both = ranged_keep_distance_default,
			},
			wh_brace_of_pisols = {
				normal = ranged_keep_distance_default,
			},
			wh_crossbow = {
				both = ranged_keep_distance_default,
			},
			wh_repeating_pistol = {
				normal = ranged_keep_distance_default,
				charged = 3,
			},
			wh_repeating_crossbow = {
				both = ranged_keep_distance_default,
			},
			ww_hagbane = {
				both = ranged_keep_distance_default,
			},
			ww_longbow = {
				both = ranged_keep_distance_default,
			},
			ww_shortbow = {
				both = ranged_keep_distance_default,
			},
			ww_trueflight = {
				both = ranged_keep_distance_default,
			},
		},
		
		push_radius = 
		{
			default				= 2,
			es_1h_mace_shield	= 2.5,
			es_1h_sword_shield	= 2.5,
			es_2h_war_hammer	= 2.5,
			es_2h_sword			= 2.25,
			es_2h_sword_exec	= 2.25,
			dr_1h_axe_shield	= 2.5,
			dr_1h_hammer_shield	= 2.5,
			dr_2h_hammer		= 2.5,
			wh_2h_sword			= 2.25,
		},
		
		token_damage_balancing = 
		{
			default				= 1,
			es_1h_mace_shield	= 1.4,
			es_1h_sword_shield	= 1.2,
			dr_1h_hammer_shield	= 1.4,
			dr_1h_axe_shield	= 1.2,
		},
		
		token_stagger_balancing = 
		{
			default				= 1,
			bw_staff_geiser		= 0.3,
			bw_staff_beam		= 0.5,
			ww_hagbane			= 0.75,
		},
		
		token_push_balancing = 
		{
			default				= 1,
		},
		
		-- certain spots where bots are allowed to pick up pinged items with more
		-- distance between human and the item
		pickup_distance_exceptions = 
		{
			courtyard_level = 
			{
				check		= new_area_check_sphere(Vector3(1.83, -21.88, -2.31), 2),
				distance	= 4.5,
			}
		},
		
		path_preload = 
		{
			loading_done = false,
			bridge =	-- black powder
			{
				-- entry format
				-- {
					-- Vector3Box(from),
					-- Vector3Box(via),
					-- Vector3Box(to),
					-- Vector3Box(bot needs to jump),
				-- },
				{Vector3Box(180.671, -31.1885, 43.1629), Vector3Box(180.671, -31.1885, 43.1629), Vector3Box(183.302, -34.2733, 39.733), true,},		-- First srop-down into the main map area.
				{Vector3Box(186.737, -87.8236, 50.8341), Vector3Box(186.737, -87.8236, 50.8341), Vector3Box(184.391, -89.3185, 46.2506), true,},	-- Jump-down as workaround for the unusable (to bots) ladder from midroof near the watchtower
				{Vector3Box(183.866, -83.6498, 50.68), Vector3Box(182.003, -84.5817, 49.7865), Vector3Box(181.335, -84.9243, 48.2304), false,},		-- Drop-down as workaround for the unusable (to bots) ladder from midroof near the watchtower
				{Vector3Box(184.115, -74.2467, 54.9819), Vector3Box(184.168, -74.2843, 54.9834), Vector3Box(187.501, -72.6791, 51.163), true,},		-- Jump down from the watchtower to the midway roof
				{Vector3Box(169.268, -44.9116, 51.3446), Vector3Box(169.442, -45.2012, 51.3468), Vector3Box(171.787, -49.2888, 47.5508), false,},	-- Stairs shortcut down on the rait side elevated staircase
				{Vector3Box(165.372, -74.6817, 52.0606), Vector3Box(166.872, -75.4271, 51.6519), Vector3Box(168.535, -73.9077, 46.3431), false,},	-- "usual barrel route" dropdown from far up left barrel location
				{Vector3Box(172.363, -72.6716, 46.7828), Vector3Box(172.906, -72.8192, 46.9171), Vector3Box(177.528, -69.6926, 44.8203), true,},	-- "usual barrel route" follow-up jump from far up left barrel location
				{Vector3Box(170.899, -73.7168, 46.8174), Vector3Box(171.675, -75.1153, 46.5702), Vector3Box(172.557, -76.9271, 42.8735), false,},	-- "usual barrel route" follow-up drop-down from far up left barrel location
				{Vector3Box(218.735, -75.0447, 48.9768), Vector3Box(218.735, -75.0447, 48.9768), Vector3Box(217.038, -71.9311, 46.0272), false,},	-- drop-down to skip some stairs directly left of the ship on roofs
				{Vector3Box(198.443, -66.7933, 45.8872), Vector3Box(198.443, -66.7933, 45.8872), Vector3Box(200.525, -66.5568, 41.5935), false,},	-- drop-down (level 2 to 1) to skip some stairs directly left of the ship
				{Vector3Box(194.88, -71.6293, 50.5161), Vector3Box(194.88, -71.6293, 50.5161), Vector3Box(195.098, -66.4288, 45.7915), true, },		-- jump-down (level 3 to 2) directly left of the ship
				{Vector3Box(207.51, -72.0888, 51.2154), Vector3Box(209, -71.1953, 50.7364), Vector3Box(211.113, -70.2542, 46.2165), false,},		-- drop-down (level 3 to 2) directly left of the ship
				{Vector3Box(160.945, -48.3989, 41.0507), Vector3Box(160.945, -48.3989, 41.0507), Vector3Box(159.848, -49.2337, 41.0089), true,},	-- narrow path behind a small shed on the ground level forward right of the ship, a
				{Vector3Box(159.848, -49.2337, 41.0089), Vector3Box(159.848, -49.2337, 41.0089), Vector3Box(160.945, -48.3989, 41.0507), true,},	-- narrow path behind a small shed on the ground level forward right of the ship, b
				{Vector3Box(150.316, -93.5049, 47.6737), Vector3Box(150.623, -93.5562, 47.4661), Vector3Box(153.516, -95.9735, 45.8292), true,},	-- spiral staircase a
				{Vector3Box(153.516, -95.9735, 45.8292), Vector3Box(153.516, -95.9735, 45.8292), Vector3Box(150.316, -93.5049, 47.6737), true,},	-- spiral staircase b
				{Vector3Box(149.508, -91.3667, 48.9263), Vector3Box(149.508, -91.3667, 48.9263), Vector3Box(146.617, -94.2411, 46.7349), true,},	-- jump from spiral staircase to nearby scaffolding
				{Vector3Box(143.776, -97.1394, 46.726), Vector3Box(143.776, -97.1394, 46.726), Vector3Box(138.43, -96.7685, 39.8629), false,},		-- jump from the scaffolding to ground level
				{Vector3Box(180.757, -65.7026, 43.8739), Vector3Box(179.767, -64.0084, 42.2821), Vector3Box(179.37, -64.0508, 39.3981), false,},	-- drop-down near plank bridge 1
				{Vector3Box(169.938, -52.182, 44.957), Vector3Box(167.938, -53.1838, 44.3445), Vector3Box(166.671, -53.5916, 40.4571), false,},		-- drop-down near plank bridge 2
				{Vector3Box(143.441, -82.6352, 42.9735), Vector3Box(143.552, -83.1105, 42.9417), Vector3Box(145.117, -87.07, 42.4676), true,},		-- broken bridge a
				{Vector3Box(144.605, -86.0848, 42.964), Vector3Box(144.423, -85.5499, 43.2714), Vector3Box(142.88, -82.6423, 42.9915), true,},		-- broken bridge b
				{Vector3Box(148.965, -86.8702, 41.7427), Vector3Box(148.795, -86.826, 41.7449), Vector3Box(147.335, -84.3075, 39.4166), true,},		-- broken bridge alternative jump-down
				{Vector3Box(147.466, -94.2548, 41.9964), Vector3Box(147.14, -94.2891, 41.9987), Vector3Box(143.105, -92.8896, 40.1804), true,},		-- small skip near the base of the spiral staircase a
				{Vector3Box(145.021, -92.1614, 41.3904), Vector3Box(145.237, -92.4805, 41.4247), Vector3Box(147.441, -94.2415, 41.9964), true,},	-- small skip near the base of the spiral staircase b
				{	-- trick bots into using "broken" ladder to clinb up
					Vector3Box(184.175, -90.0554, 46.2485),
					Vector3Box(184.633, -89.7879, 46.2487),
					Vector3Box(187.062, -88.3779, 50.8541),
					true,
				},
			},
			dlc_stromdorf_town =	-- reaching out
			{
				{Vector3Box(81.8789, 23.5218, 10.7313), Vector3Box(81.8789, 23.5218, 10.7313), Vector3Box(79.0311, 23.007, 10.5464), true,},		-- back alleys, fence jump
				{Vector3Box(48.8374, -13.3297, 9.86157), Vector3Box(47.8988, -13.3297, 10.1204), Vector3Box(43.638, -13.9308, 10.2678), true,},		-- Stumpfstrasse a
				{Vector3Box(46.001, -17.2111, 10.3501), Vector3Box(46.001, -17.2111, 10.3501), Vector3Box(47.1664, -17.3082, 11.2782), true,},		-- Stumpfstrasse b1
				{Vector3Box(48.567, -15.6739, 11.5904), Vector3Box(48.567, -15.6739, 11.5904), Vector3Box(50.268, -11.999, 9.87677), true,},		-- Stumpfstrasse b2
				{Vector3Box(-7.31625, -51.281, 4.23926), Vector3Box(-7.31625, -51.281, 4.23926), Vector3Box(-4.84301, -53.0442, 4.22527), true,},	-- Gerber Tannery Yard a
				{Vector3Box(-4.48335, -52.7786, 4.22526), Vector3Box(-4.48335, -52.7786, 4.22526), Vector3Box(-6.60218, -50.5785, 4.23938), true,},	-- Gerber Tannery Yard b
			},
			wizard =	-- wizard's tower
			{
				{Vector3Box(212.945, -22.8586, 79.564), Vector3Box(211.228, -21.8288, 79.1241), Vector3Box(209.79, -20.8791, 75.8246), false,},		-- ward event area, shortcut to ladder
				{Vector3Box(216.117, -15.2671, 83.6734), Vector3Box(216.117, -15.2671, 83.6734), Vector3Box(220.79, -17.3356, 79.9714), false,},	-- ward event area, shortcut from elevated hold spot to ward right from exit
				{Vector3Box(-77.0349, 210.621, 20.2506), Vector3Box(-78.2406, 209.374, 19.8646), Vector3Box(-78.7698, 208.467, 16.0251), false,},	-- drop-down from first chest
				{Vector3Box(-66.6795, 181.438, 38.2212), Vector3Box(-66.3655, 182.995, 37.7906), Vector3Box(-66.4434, 182.404, 35.0862), false,},	-- drop-down related to the library 1 right side skip (backwards)
				{Vector3Box(-37.3619, 176.67, 35.2886), Vector3Box(-37.3619, 176.67, 35.2886), Vector3Box(-34.7228, 175.139, 34.2976), true,},		-- jump on second floor at the end of the library 1, forward
				{Vector3Box(-34.8817, 175.117, 34.245), Vector3Box(-34.8817, 175.117, 34.245), Vector3Box(-37.6512, 176.225, 35.2847), true,},		-- jump on second floor at the end of the library 1, backward
				{Vector3Box(-72.8036, 191.125, 31.0465), Vector3Box(-71.0276, 190.972, 30.654), Vector3Box(-70.7828, 191.186, 27.2535), false,},	-- drop-down 1 from level 2 to level 1 close to start of library 1
				{Vector3Box(-66.047, 197.442, 31.258), Vector3Box(-67.8612, 195.628, 32.3128), Vector3Box(-68.4991, 195.784, 27.2433), false,},		-- drop-down 2 from level 2 to level 1 close to start of library 1
				{Vector3Box(-53.4924, 192.667, 31.0576), Vector3Box(-51.9703, 191.78, 30.6341), Vector3Box(-51.3959, 191.364, 27.439), false,},		-- drop-down 3 from level 2 to level 1 close to start of library 1
				{Vector3Box(-68.4002, 186.679, 33.1055), Vector3Box(-68.5103, 184.991, 32.5622), Vector3Box(-67.3041, 185.904, 29.0773), false,},	-- drop-down to skip part of the stairs close to start of library 1
				{Vector3Box(-54.0797, 195.723, 38.3238), Vector3Box(-55.0243, 194.07, 37.9149), Vector3Box(-55.2699, 193.589, 35.1002), false,},	-- drop-down from level 3 to platform above level 2 in library 1
				{Vector3Box(-14.5504, 161.685, 38.1128), Vector3Box(-16.0167, 162.5, 37.682), Vector3Box(-16.148, 162.53, 34.3314), false,},		-- drop-down 1 from level 2 to level 1 in staircase hall
				{Vector3Box(-22.6438, 164.722, 38.1633), Vector3Box(-20.7869, 164.18, 37.7612), Vector3Box(-20.5916, 164.005, 34.3529), false,},	-- drop-down 2 from level 2 to level 1 in staircase hall
				{Vector3Box(-15.4925, 150.991, 38.1128), Vector3Box(-13.8933, 150.994, 37.5954), Vector3Box(-13.5532, 151.298, 34.2855), false,},	-- drop-down 3 from level 2 to level 1 in staircase hall
				{Vector3Box(-27.3164, 154.219, 38.1841), Vector3Box(-25.5594, 153.516, 37.7733), Vector3Box(-25.6295, 153.47, 34.0956), false,},	-- drop-down 4 from level 2 to level 1 in staircase hall
				{Vector3Box(-19.673, 150.751, 38.1128), Vector3Box(-21.4072, 151.426, 37.7261), Vector3Box(-21.6277, 151.534, 34.2654), false,},	-- drop-down 5 from level 2 to level 1 in staircase hall
				{Vector3Box(-22.6206, 169.188, 42.0395), Vector3Box(-22.6206, 169.188, 42.0395), Vector3Box(-24.3878, 164.285, 38.2196), false,},	-- drop-down 1 from level 3 to level 2 in staircase hall
				{Vector3Box(-12.703, 157.072, 42.1221), Vector3Box(-11.1913, 156.344, 41.7304), Vector3Box(-9.62943, 156.676, 37.913), false,},		-- drop-down 2 from level 3 to level 2 in staircase hall
				{Vector3Box(-28.2859, 156.384, 42.1013), Vector3Box(-27.2449, 158.779, 43.0197), Vector3Box(-26.0395, 160.387, 38.1841), false,},	-- drop-down 3 from level 3 to level 2 in staircase hall
				{Vector3Box(-11.8906, 158.79, 46.1129), Vector3Box(-10.1783, 158.017, 45.6927), Vector3Box(-9.95906, 158.152, 42.059), false,},		-- drop-down 1 from level 4 to level 3 in staircase hall
				{Vector3Box(97.3522, 144.052, 48.9647), Vector3Box(97.797, 142.258, 48.5521), Vector3Box(98.1085, 141.944, 44.9294), false,},		-- drop-down 1 to first room bottom floor after illusion room
				{Vector3Box(100.015, 136.23, 49.0155), Vector3Box(99.5296, 137.932, 48.6028), Vector3Box(99.6306, 137.738, 44.9864), false,},		-- drop-down 2 to first room bottom floor after illusion room
				{Vector3Box(102.179, 127.346, 52.4559), Vector3Box(104.07, 127.834, 52.0904), Vector3Box(104.641, 127.926, 48.9436), false,},		-- drop-down to first room floor 1 after illusion room
				{Vector3Box(138.816, 81.2296, 55.4174), Vector3Box(138.907, 80.9065, 55.9956), Vector3Box(139.369, 77.7582, 56.8609), true,},		-- jump to a side cavity in the ground floor of mixed gravity room
				{Vector3Box(139.177, 78.2403, 56.9354), Vector3Box(139.177, 78.2403, 56.9354), Vector3Box(138.435, 81.9981, 55.7223), true,},		-- jump from a side cavity in the ground floor of mixed gravity room
				{Vector3Box(162.467, 90.9229, 58.6135), Vector3Box(162.017, 92.7993, 58.3049), Vector3Box(161.583, 94.19, 55.6381), false,},		-- drop-down to library 2
				{Vector3Box(142.398, 124.554, 59.1123), Vector3Box(142.898, 122.113, 58.7968), Vector3Box(143.045, 121.81, 56.5896), false,},		-- drop-down 1 in library 2
				{Vector3Box(143.797, 124.191, 57.072), Vector3Box(143.797, 124.191, 57.072), Vector3Box(143.236, 121.689, 56.5896), true,},			-- drop-down 2 in library 2 (jump, narrow path between wall and bookshelf)
				{Vector3Box(143.248, 121.731, 56.5894), Vector3Box(143.248, 121.731, 56.5894), Vector3Box(144.07, 125.133, 57.072), true,},			-- jump in library 2 (narrow path between wall and bookshelf)
				{Vector3Box(131.656, 119.393, 64.6117), Vector3Box(132.131, 117.649, 64.2351), Vector3Box(132.06, 117.926, 60.4531), false,},		-- drop-down to floor 1 of mixed gravity room from library 2
				{Vector3Box(107.804, 112.957, 63.1616), Vector3Box(108.183, 111.44, 62.7348), Vector3Box(108.096, 111.838, 58.4519), false,},		-- drop-down when taking the right path to grim 2 on floor 1 in mixed gravity room
				{Vector3Box(134.513, 90.4417, 65.1467), Vector3Box(135.207, 88.5671, 64.7394), Vector3Box(135.76, 86.6388, 60.8342), false,},		-- drop-down when taking the bridge back to the other side from grim 2 on floor 1 in mixed gravity room
				{Vector3Box(107.532, 91.0956, 60.2808), Vector3Box(107.532, 91.0956, 60.2808), Vector3Box(107.134, 93.512, 59.8084), true,},		-- jump past an archway soon after grim 2, forward
				{Vector3Box(107.129, 93.48, 59.8086), Vector3Box(107.129, 93.48, 59.8086), Vector3Box(107.115, 91.0819, 60.2707), true,},			-- jump past an archway soon after grim 2, backward
				{Vector3Box(90.1731, 72.8634, 64.2155), Vector3Box(91.8604, 73.3133, 63.8149), Vector3Box(92.4003, 73.6499, 60.2077), false,},		-- drop-down 1 soon after grim 2, backward
				{Vector3Box(86.0663, 81.4976, 64.2155), Vector3Box(85.0955, 83.0827, 63.8247), Vector3Box(85.133, 84.245, 60.2864), false,},		-- drop-down 2 soon after grim 2, backward
				{Vector3Box(87.6773, 45.6471, 64.2801), Vector3Box(87.9574, 43.6863, 63.9028), Vector3Box(88.028, 43.6426, 62.3319), false,},		-- drop-down 1 to illusion bridge area
				{Vector3Box(83.8823, 44.4697, 64.2801), Vector3Box(84.2541, 42.5658, 63.9), Vector3Box(84.3552, 42.4689, 62.3367), false,},			-- drop-down 2 to illusion bridge area
				{Vector3Box(80.2701, 43.4239, 64.2801), Vector3Box(80.3919, 41.2541, 63.8899), Vector3Box(80.7332, 40.5658, 62.3994), false,},		-- drop-down 3 to illusion bridge area
				{Vector3Box(192.007, -28.0289, 79.6055), Vector3Box(190.45, -27.1539, 79.1978), Vector3Box(189.829, -26.9481, 75.8627), false,},	-- drop-down 1 in ward event area
				{Vector3Box(200.504, -41.0349, 79.728), Vector3Box(200.882, -40.3348, 79.728), Vector3Box(202.444, -37.5592, 75.6207), false,},		-- drop-down 2 in ward event area
				{Vector3Box(205.113, -35.772, 83.6935), Vector3Box(206.842, -36.7418, 83.2904), Vector3Box(207.39, -37.3067, 79.5477), false,},		-- drop-down 3 in ward event area
				{Vector3Box(194.36, -31.7149, 83.7021), Vector3Box(192.661, -30.7443, 83.2924), Vector3Box(191.943, -30.7159, 79.6055), false,},	-- drop-down 4 in ward event area
				{Vector3Box(210.395, -26.7417, 83.6616), Vector3Box(212.117, -27.7414, 83.2365), Vector3Box(212.47, -27.9714, 79.5477), false,},	-- drop-down 5 in ward event area
				{Vector3Box(208.84, -16.6391, 83.6579), Vector3Box(207.949, -18.2647, 83.2324), Vector3Box(208.029, -18.1139, 79.6367), false,},	-- drop-down 6 in ward event area
				{Vector3Box(201.405, -11.4825, 79.6943), Vector3Box(199.816, -10.4608, 79.2303), Vector3Box(197.893, -10.6411, 75.8295), false,},	-- drop-down 7 in ward event area
				{Vector3Box(206.502, -19.0027, 79.3771), Vector3Box(204.998, -18.1115, 78.8787), Vector3Box(205.378, -18.3334, 75.5391), false,},	-- drop-down 8 in ward event area
			},
			dlc_castle =	-- Castle Drachenfels
			{
				{Vector3Box(-154.714, -167.391, -7.56657), Vector3Box(-154.714, -167.391, -7.56657), Vector3Box(-154.321, -164.36, -7.56716), true,},	-- path between rock and a tree to first item spot at the start of the map, a
				{Vector3Box(-154.572, -164.634, -7.56733), Vector3Box(-154.572, -164.634, -7.56733), Vector3Box(-155.036, -167.67, -7.56659), true,},	-- path between rock and a tree to first item spot at the start of the map, b
				-- {	-- drop-down close to the broken bridge before entering to the castle, a
					-- Vector3Box(-180.417, -132.159, -8.18027),
					-- Vector3Box(-180.358, -131.455, -8.39007),
					-- Vector3Box(-180.964, -130.455, -9.9909),
					-- false,
				-- },
				-- {	-- drop-down close to the broken bridge before entering to the castle, b
					-- Vector3Box(-180.687, -129.517, -9.97947),
					-- Vector3Box(-180.248, -128.583, -10.3071),
					-- Vector3Box(-179.879, -127.48, -14.8253),
					-- false,
				-- },
				-- {	-- drop-down 2 close to the broken bridge before entering to the castle
					-- Vector3Box(-163.292, -138.305, -7.89469),
					-- Vector3Box(-163.118, -136.914, -8.40807),
					-- Vector3Box(-163.154, -134.891, -12.2053),
					-- false,
				-- },
				{Vector3Box(-173.607, -139.589, -7.76857), Vector3Box(-173.377, -138.719, -7.80893), Vector3Box(-173.297, -131.618, -15.1501), false,},	-- drop-down 3 close to the broken bridge before entering to the castle
				{Vector3Box(-151.788, -134.147, -11.6776), Vector3Box(-149.909, -132.951, -12.3608), Vector3Box(-149.194, -131.864, -15.0273), false,},	-- small drop-down from cliff to cround close to the broken bridge before entering to the castle
				{Vector3Box(-156.593, -136.107, -10.3486), Vector3Box(-156.593, -136.107, -10.3486), Vector3Box(-154.04, -136.386, -9.50122), true,},	-- jumps back up to the broken bridge, a
				{Vector3Box(-158.437, -135.532, -11.7365), Vector3Box(-157.955, -136.013, -10.9689), Vector3Box(-156.99, -136.229, -10.504), true,},	-- jumps back up to the broken bridge, b
				{Vector3Box(-154.645, -136.527, -9.25236), Vector3Box(-154.645, -136.527, -9.25236), Vector3Box(-156.557, -139.253, -7.60695), true,},	-- jumps back up to the broken bridge, c
				{Vector3Box(-125.977, -123.876, -14.9065), Vector3Box(-124.29, -124.473, -15.4139), Vector3Box(-122.81, -124.645, -17.9523), false,},	-- drop-down to the castle (in case bots fali to learn it from the human)
				{Vector3Box(-19.9101, -63.7872, -9.9275), Vector3Box(-19.9083, -63.0563, -9.9275), Vector3Box(-19.9023, -60.8427, -9.9275), true,},		-- railing jump before grim1 drop-down, a
				{Vector3Box(-20.051, -60.0718, -9.9275), Vector3Box(-20.0938, -60.7612, -9.9275), Vector3Box(-20.1679, -63.9473, -9.9275), true,},		-- railing jump before grim1 drop-down, b
				{Vector3Box(-3.88071, -62.725, -9.92745), Vector3Box(-3.88071, -62.725, -9.92745), Vector3Box(-3.90036, -58.191, -14.0448), true,},		-- jump down 1 to grim 1
				{Vector3Box(-4.39922, -48.8968, -9.92745), Vector3Box(-4.39922, -48.8968, -9.92745), Vector3Box(-4.58533, -52.8601, -14.0514), true,},	-- jump down 2 to grim 1
				{Vector3Box(-0.431794, -36.0016, -9.9275), Vector3Box(-1.025, -35.9958, -9.9275), Vector3Box(-3.76788, -36.1165, -9.9275), true,},		-- jump over the railing 1 soon after grim 1, a
				{Vector3Box(-3.76788, -36.1165, -9.9275), Vector3Box(-2.95943, -35.9835, -9.9275), Vector3Box(-0.431794, -36.0016, -9.9275), true,},	-- jump over the railing 1 soon after grim 1, b
				{Vector3Box(-0.138374, -23.9471, -9.9275), Vector3Box(-1.04452, -23.9962, -9.9275), Vector3Box(-4.173, -23.9162, -9.9275), true,},		-- jump over the railing 2 soon after grim 1, a
				{Vector3Box(-4.173, -23.9162, -9.9275), Vector3Box(-3.12319, -24.075, -9.9275), Vector3Box(-0.138374, -23.9471, -9.9275), true,},		-- jump over the railing 2 soon after grim 1, b
				{Vector3Box(-2.11406, 4.21252, -7.66802), Vector3Box(-3.43589, 4.30677, -8.10517), Vector3Box(-4.36648, 4.30126, -11.9166), false,},	-- drop-down from a chest beit after grim 1 (in case bots fail to learn it)
				{Vector3Box(-12.4911, 63.8856, 0), Vector3Box(-13.2331, 64.0515, 0), Vector3Box(-16.6969, 63.8222, -3.99965), true,},					-- jump down 1 after tome 2
				{Vector3Box(-12.4815, 44.071, 0), Vector3Box(-13.141, 44.0601, 0), Vector3Box(-16.9353, 43.9919, -3.99965), true,},						-- jump down 2 after tome 2
				{Vector3Box(-13.9576, 52.0748, 0.239896), Vector3Box(-15.5626, 52.0748, -0.345711), Vector3Box(-15.435, 52.0288, -3.09858), false,},	-- drop-down after tome 2
				{Vector3Box(-34.0685, 72.6867, -4), Vector3Box(-34.0685, 72.6867, -4), Vector3Box(-34.1869, 74.5103, -3.99886), true,},					-- fenced statue area after dining hall, a
				{Vector3Box(-31.9996, 74.2338, -3.82839), Vector3Box(-31.9996, 74.2338, -3.82839), Vector3Box(-31.9708, 71.6712, -3.99965), true,},		-- fenced statue area after dining hall, b
				{Vector3Box(-16.4988, 91.0201, -3.18094), Vector3Box(-16.4988, 91.0201, -3.18094), Vector3Box(-17.2562, 94.2132, -3.92445), true,},		-- stuck spot after dining hall, right path (broken fence), a
				{Vector3Box(-18.9249, 92.802, -3.95838), Vector3Box(-18.4243, 92.4015, -3.23328), Vector3Box(-16.1735, 90.7422, -3.35266), true,},		-- stuck spot after dining hall, right path (broken fence), b
				{Vector3Box(-48.8865, 166.674, 0.938076), Vector3Box(-48.8865, 166.674, 0.938076), Vector3Box(-48.9384, 168.969, 1.76593), true,},		-- jump over broken pillar a (1/2)
				{Vector3Box(-49.0382, 168.918, 1.78483), Vector3Box(-50.014, 171.148, 1.49785), Vector3Box(-50.0124, 171.857, 0.0641482), false,},		-- jump over broken pillar a (2/2)
				{Vector3Box(-49.5833, 169.697, 0.744201), Vector3Box(-49.5255, 169.577, 0.990737), Vector3Box(-49.2931, 168.089, 1.86632), true,},		-- jump over broken pillar b (1/2)
				{Vector3Box(-49.6208, 167.971, 1.92095), Vector3Box(-49.0034, 166.365, 1.62071), Vector3Box(-49.0059, 165.912, 0.690324), false,},		-- jump over broken pillar b (2/2)
				{Vector3Box(-50.8154, 189.186, 0.685649), Vector3Box(-50.8154, 189.186, 0.685649), Vector3Box(-52.44, 189.48, 1.68401), true,},			-- jump to elevated side path half way between tome 3 and drop to statue event area (1/2)
				{Vector3Box(-51.969, 190.27, 2.14005), Vector3Box(-51.3705, 190.722, 2.19909), Vector3Box(-50.4443, 191.995, 2.5396), true,},			-- jump to elevated side path half way between tome 3 and drop to statue event area (2/2)
				{Vector3Box(-50.5102, 193.052, 2), Vector3Box(-50.5102, 193.052, 2), Vector3Box(-49.6716, 191.49, 2.0002), true,},						-- jump 1 from elevated side path half way between tome 3 and drop to statue event area (1/2)
				{Vector3Box(-49.6993, 190.672, 2.0002), Vector3Box(-49.6993, 188.798, 1.53464), Vector3Box(-49.5198, 187.929, 0.0646315), false,},		-- jump 1 from elevated side path half way between tome 3 and drop to statue event area (2/2)
				{Vector3Box(-35.8465, 193.712, 2.0002), Vector3Box(-35.9977, 192.93, 2), Vector3Box(-36.0807, 189.706, 0.00653599), true,},				-- jump 2 from elevated side path half way between tome 3 and drop to statue event area
				{Vector3Box(-19.0192, 193.474, 2), Vector3Box(-19.0192, 193.474, 2), Vector3Box(-19.4088, 189.665, 0.00956013), true,},					-- jump 3 from elevated side path half way between tome 3 and drop to statue event area
				{Vector3Box(5.28484, 153.12, 0), Vector3Box(5.28484, 153.12, 0), Vector3Box(5.11149, 148.174, 0.02392), true,},							-- transition past navmesh gap near drop-down to statue event area, a
				{Vector3Box(5.11149, 148.174, 0.02392), Vector3Box(5.11149, 148.174, 0.02392), Vector3Box(5.37152, 151.571, 0), true,},					-- transition past navmesh gap near drop-down to statue event area, b
				{Vector3Box(27.9143, 160.092, 8.9407e-007), Vector3Box(27.9143, 160.092, 8.9407e-007), Vector3Box(32.3819, 160.653, -3.61592), true,},	-- jump down to the statue event area
				{Vector3Box(32.092, 161.207, -3.6438), Vector3Box(32.0922, 163.214, -4.14385), Vector3Box(32.1702, 164.702, -7.00031), false,},			-- drop-down to the statue event area from the wooden platform
				{Vector3Box(22.6321, 224.18, 0.200174), Vector3Box(22.6321, 224.18, 0.200174), Vector3Box(19.4681, 221.051, -3.04826), true,},			-- statue event jump down railing 1
				{Vector3Box(41.583, 225.298, 0.658723), Vector3Box(41.583, 225.298, 0.658723), Vector3Box(43.1363, 221.207, -2.99992), true,},			-- statue event jump down railing 2
				{Vector3Box(20.0183, 222.15, 4.17972), Vector3Box(21.417, 222.252, 3.70492), Vector3Box(23.5012, 223.231, -0.306383), false,},			-- drop-down from upper left statue
				{Vector3Box(28.42, 230.916, 2.18016), Vector3Box(28.4953, 229.606, 1.71421), Vector3Box(29.2062, 227.839, -1.99857), false,},			-- drop-down 1 next to the center statue
				{Vector3Box(35.8164, 231.007, 2.18456), Vector3Box(35.6016, 229.503, 1.70615), Vector3Box(35.2097, 227.43, -2.0002), false,},			-- drop-down 2 next to the center statue
				{Vector3Box(36.6393, 269.961, -27.9278), Vector3Box(36.07, 269.964, -27.9278), Vector3Box(33.2798, 270.054, -27.9278), true,},			-- exit run railing jump 1, a
				{Vector3Box(33.2798, 270.054, -27.9278), Vector3Box(34.0114, 270.059, -27.9278), Vector3Box(36.6393, 269.961, -27.9278), true,},		-- exit run railing jump 1, b
				{Vector3Box(30.836, 282.063, -27.9278), Vector3Box(30.1074, 282.032, -27.9278), Vector3Box(26.9253, 282.038, -27.9278), true,},			-- exit run railing jump 2, a
				{Vector3Box(26.9253, 282.038, -27.9278), Vector3Box(27.8052, 282.033, -27.9278), Vector3Box(30.836, 282.063, -27.9278), true,},			-- exit run railing jump 2, b
				{Vector3Box(32.9795, 289.905, -27.9278), Vector3Box(33.8837, 289.906, -27.9278), Vector3Box(36.7744, 289.909, -27.9278), true,},		-- exit run railing jump 3, a
				{Vector3Box(36.7744, 289.909, -27.9278), Vector3Box(36.1138, 289.908, -27.9278), Vector3Box(32.9795, 289.905, -27.9278), true,},		-- exit run railing jump 3, b
				{Vector3Box(49.2153, 306.255, -32.0002), Vector3Box(49.1915, 306.849, -32.0002), Vector3Box(49.1531, 309.173, -32.0002), true,},		-- exit run railing jump 4, a
				{Vector3Box(49.1531, 309.173, -32.0002), Vector3Box(49.1399, 309.979, -32.0002), Vector3Box(49.2153, 306.255, -32.0002), true,},		-- exit run railing jump 4, b
			},
			magnus =	-- Horn of Magnus
			{
				{Vector3Box(-104.021, 83.4174, 9.33301), Vector3Box(-104.689, 81.8514, 8.88951), Vector3Box(-104.119, 81.4261, 5.23127), false,},	-- drop-down to pigsty area from the elevated supply spot path 1
				{Vector3Box(-106.898, 71.3713, 7.16578), Vector3Box(-107.672, 69.8712, 6.77534), Vector3Box(-108.336, 67.9948, 3.20212), false,},	-- drop-down to pigsty area from the elevated supply spot path 2
				{Vector3Box(-104.94, 24.0028, 6.84204), Vector3Box(-103.135, 23.8907, 6.14198), Vector3Box(-102.169, 22.567, 3.4291), false,},		-- stone archway drop-down a bit after the pigsty
				{Vector3Box(-52.3847, 23.5709, 2.39912), Vector3Box(-52.3847, 23.5709, 2.39912), Vector3Box(-49.5511, 23.5477, 1.40461), true,},	-- church barricade
				{Vector3Box(-49.916, 24.7312, 1.45847), Vector3Box(-50.1925, 25.1, 2.32444), Vector3Box(-53.06, 23.9163, 1.81702), true,},			-- church barricade, back to the alley
				{Vector3Box(9.4309, 31.7226, 2.372), Vector3Box(9.4309, 32.1129, 3.01949), Vector3Box(7.47355, 35.1446, 2.00749), true,},			-- barrel event area, spot unreachable by default, entry
				{Vector3Box(7.19991, 34.9159, 2.00393), Vector3Box(7.19991, 34.9159, 2.00393), Vector3Box(5.87202, 31.6097, 0.631142), true,},		-- barrel event area, spot unreachable by default, exit
				{Vector3Box(115.801, -30.5024, 10.6073), Vector3Box(114.427, -31.6017, 10.1547), Vector3Box(112.541, -31.7821, 6.7853), false,},	-- staircase drop-down before Oliver's Inn 1
				{Vector3Box(111.523, -53.8778, 20.705), Vector3Box(111.523, -53.8778, 20.705), Vector3Box(108.658, -54.1117, 20.6836), true,},		-- staircase jump-down before Oliver's Inn 2
				{Vector3Box(236.548, -146.787, 95.953), Vector3Box(236.844, -146.288, 95.0613), Vector3Box(236.913, -145.763, 91.1601), false,},	-- final event, drop-down from the shelter close to horn
				-- {	-- final event, jump from the chest lid (unstable)
					-- Vector3Box(260.617, -132.304, 87.2122),
					-- Vector3Box(260.907, -131.261, 88.2191),
					-- Vector3Box(259.95, -135.402, 88.8145),
					-- true,
				-- },
			},
			sewers_short =	-- smuggler's run
			{
				{Vector3Box(-124.501, 15.9301, -5.89148), Vector3Box(-124.461, 15.8838, -5.89217), Vector3Box(-121.717, 14.6315, -4.23641), true,},		-- pipe jump before first gate event, bit unstable
				{Vector3Box(-116.671, 32.4624, -5.88662), Vector3Box(-116.671, 32.4624, -5.88662), Vector3Box(-116.634, 36.1493, -8.72335), true,},		-- waterfall drop-down (jump) to gate 1 fight area (failsafe)
				{Vector3Box(-156.1, 141.015, -0.485605), Vector3Box(-156.1, 141.015, -0.485605), Vector3Box(-157.16, 143.373, -1.08359), true,},		-- jump-down shortcut to long detour along the edge, midway between gate events, 1a
				{Vector3Box(-157.538, 143.203, -1.08331), Vector3Box(-157.538, 143.203, -1.08331), Vector3Box(-158.04, 140.93, -0.406708), true,},		-- jump-up shortcut to long detour along the edge, midway between gate events, 1b
				{Vector3Box(-164.024, 143.759, -1.08331), Vector3Box(-164.024, 143.759, -1.08331), Vector3Box(-164.181, 140.93, -0.467136), true,},		-- jump-down shortcut to long detour along the edge, midway between gate events, 2a
				{Vector3Box(-164.248, 141.533, -0.485605), Vector3Box(-164.248, 141.533, -0.485605), Vector3Box(-164.024, 143.759, -1.08359), true,},	-- jump-up shortcut to long detour along the edge, midway between gate events, 2b
				{Vector3Box(-228.318, 157.828, -0.395649), Vector3Box(-228.318, 157.828, -0.395649), Vector3Box(-228.6, 160.683, -0.469415), true,},	-- jump over broken bar wall to a "cell" before second gate event, a
				{Vector3Box(-228.596, 160.798, -0.465986), Vector3Box(-228.596, 160.798, -0.465986), Vector3Box(-228.245, 156.621, -0.393552), true,},	-- jump over broken bar wall to a "cell" before second gate event, b
			},
			city_wall =	-- man the ramparts
			{
				{Vector3Box(52.4005, 89.4851, 6.1008), Vector3Box(52.4005, 89.4851, 6.1008), Vector3Box(50.147, 85.275, 0.805063), true,},			-- drop-down to the lower level supply spot sortly after the first elevator
				{Vector3Box(77.4243, 9.06487, 16.5957), Vector3Box(77.4243, 9.06487, 16.5957), Vector3Box(80.063, 8.38277, 12.4736), false,},		-- drop-down to the supply drop in the middle tower
				{Vector3Box(49.0348, -27.129, 20.8644), Vector3Box(47.351, -27.129, 20.4436), Vector3Box(46.9145, -27.3052, 18.1954), false,},		-- a small shortcut for the "sniper skip"
				{Vector3Box(40.8648, -29.2689, 18.3828), Vector3Box(40.7795, -29.2689, 18.3494), Vector3Box(37.6181, -29.6311, 18.2422), true,},	-- jump to item spot near "sniper skip"
				{Vector3Box(38.0361, -29.5586, 18.2512), Vector3Box(38.0361, -29.5586, 18.2512), Vector3Box(40.9812, -29.0866, 18.3802), true,},	-- jump from item spot near "sniper skip"
				{Vector3Box(37.0116, -31.1709, 18.2952), Vector3Box(37.57, -32.9857, 17.9251), Vector3Box(38.3499, -33.9138, 15.1458), false,},		-- drop-down from item spot near "sniper skip"
				{Vector3Box(40.4317, -60.4412, 15.1458), Vector3Box(40.4317, -60.4412, 15.1458), Vector3Box(40.9014, -63.6886, 17.185), true,},		-- jump on the fallen statue before entering the chain area
				{Vector3Box(72.5652, -85.1348, 17.4631), Vector3Box(73.7769, -84.1279, 17.0185), Vector3Box(76.1161, -83.608, 12.5379), false,},	-- drop-down 1 near first chain
				{Vector3Box(80.1809, -78.4445, 17.5103), Vector3Box(78.7938, -79.3692, 17.0734), Vector3Box(78.96, -79.2083, 12.7206), false,},		-- drop-down 2 near first chain
				{Vector3Box(71.8158, -128.538, 21.8682), Vector3Box(71.8158, -128.538, 21.8682), Vector3Box(70.0763, -126.067, 21.8159), true,},	-- hole in wall near chain right to the closed gate, a
				{Vector3Box(70.1272, -126.153, 21.8152), Vector3Box(70.1272, -126.153, 21.8152), Vector3Box(71.6458, -128.416, 21.8382), true,},	-- hole in wall near chain right to the closed gate, b
			},
			docks_short_level =	-- waterfront
			{
				{Vector3Box(48.6548, -4.2708, 4.73367), Vector3Box(47.1041, -4.2708, 4.32439), Vector3Box(45.9893, -4.16875, 0.686002), false,},		-- ladder near pillar warehouse exit, drop-down
				{Vector3Box(48.6439, -5.45416, 4.73337), Vector3Box(48.6439, -5.45416, 4.73337), Vector3Box(44.03, -4.51, 4.80129), true,},				-- jump to roof (1) near the above ladder
				{Vector3Box(42.8703, -15.7552, 4.78399), Vector3Box(42.8805, -16.9504, 3.99475), Vector3Box(43.4035, -14.9544, -0.398299), false,},		-- drop down 1 from roof 1
				{Vector3Box(40.4848, -2.70256, 4.55886), Vector3Box(38.7966, -2.70256, 4.0426), Vector3Box(39.0425, -2.3462, 0.685654), false,},		-- drop down 2 from roof 1
				{Vector3Box(40.6885, -3.47322, 4.56256), Vector3Box(40.6885, -3.47322, 4.56256), Vector3Box(37.7485, -3.0672, 4.62716), true,},			-- jump to roof 2
				{Vector3Box(38.1752, -2.84864, 4.64125), Vector3Box(39.7876, -2.84579, 4.22794), Vector3Box(38.6857, -2.69038, 0.675384), false,},		-- drop down 1 from roof 2
				{Vector3Box(22.2449, -2.35773, 4.49766), Vector3Box(20.4287, -2.35656, 3.96334), Vector3Box(22.4187, -1.5169, -0.195428), false,},		-- drop down 2 from roof 2
				{Vector3Box(41.6149, -28.0653, 0.179866), Vector3Box(41.6149, -28.0653, 0.179866), Vector3Box(41.8609, -26.3952, 0.738013), true,},		-- passage next to boxes (1/2) near the market square
				{Vector3Box(41.3937, -26.344, 0.73763), Vector3Box(41.7656, -24.4824, 0.363525), Vector3Box(41.6515, -23.6337, -1.0889), false,},		-- passage next to boxes (2/2) near the market square
				{Vector3Box(28.1173, -26.2822, 0.746099), Vector3Box(28.202, -24.9278, 0.258326), Vector3Box(27.3006, -24.2845, -1.0935), false,},		-- drop-down at the market square
				{Vector3Box(30.0638, -3.45913, 0.65041), Vector3Box(30.0638, -3.45913, 0.65041), Vector3Box(27.0631, -8.10786, -4.45421), true,},		-- jump down to waterline at the market square
				{Vector3Box(22.4052, -6.31655, -1.10626), Vector3Box(24.0775, -6.3172, -1.56483), Vector3Box(25.5467, -7.2314, -4.4903), false,},		-- drop down 1 to waterline at the market square
				{Vector3Box(40.6749, -16.5233, -1.23549), Vector3Box(39.2526, -16.5199, -1.69374), Vector3Box(39.2894, -16.2503, -3.80621), false,},	-- drop down 2 to waterline at the market square
				{Vector3Box(36.6608, -16.7052, -3.78433), Vector3Box(37.3477, -17.0699, -2.94484), Vector3Box(40.6921, -18.1169, -1.21888), true,},		-- jump up from waterline at the market square
				{Vector3Box(13.3148, 6.2593, 0.246406), Vector3Box(13.0894, 6.40497, 0.231784), Vector3Box(9.07, 5.65, 0.339922), true,},				-- jump over 1 broken floor near ladder 2, a
				{Vector3Box(10.0552, 6.0474, 0.339922), Vector3Box(10.0857, 6.0474, 0.340575), Vector3Box(14.3298, 6.13, 0.260791), true,},				-- jump over 1 broken floor near ladder 2, b
				{Vector3Box(11.0458, 3.74048, -3.33378), Vector3Box(11.0458, 3.74048, -3.33378), Vector3Box(9.04798, 5.74634, 0.339922), true,},		-- trick bots into using ladder 2 to climb up
				{Vector3Box(8.66565, 6.94374, 0.341345), Vector3Box(8.88214, 8.32495, -0.094117), Vector3Box(9.17896, 8.12, -2.99212), false,},			-- drop-down 1 to skip ladder 2 climb down
				{Vector3Box(13.3148, 6.2593, 0.246406), Vector3Box(11.9673, 7.29249, -0.253306), Vector3Box(10.4533, 7.81989, -2.96583), false,},		-- drop-down 2 to skip ladder 2 climb down
				{Vector3Box(-12.2521, 28.8931, 2.615), Vector3Box(-10.4783, 29.5496, 1.96414), Vector3Box(-9.90906, 29.7179, 0.895961), false,},		-- drop-down 1 near barrel warehouse entrance
				{Vector3Box(-12.3468, 17.3067, 3.31604), Vector3Box(-11.7977, 15.6594, 2.68283), Vector3Box(-11.096, 14.5022, 0.221394), false,},		-- drop-down 2 near barrel warehouse entrance
				{Vector3Box(-9.10516, 41.0846, 1.51627), Vector3Box(-8.86985, 40.0904, -0.704929), Vector3Box(-8.75746, 40.4832, -2.13822), false,},	-- drop-down 1 to a ledge at the waterline near barrel warehouse
				{Vector3Box(-4.82679, 48.0513, 1.55483), Vector3Box(-4.10116, 48.7887, 0.367664), Vector3Box(-5.07739, 49.167, -2.17506), false,},		-- drop-down 2 to a ledge at the waterline near barrel warehouse
				{Vector3Box(-12.1452, 48.2481, 1.52555), Vector3Box(-12.428, 49.09, 0.900037), Vector3Box(-12.4622, 49.0084, -2.04242), false,},		-- drop-down 3 to a ledge at the waterline near barrel warehouse
				{Vector3Box(-11.6009, 32.843, 1.23399), Vector3Box(-11.6009, 32.843, 1.23399), Vector3Box(-13.6811, 32.1741, 2.41553), true,},			-- jump-up a ledge at the waterline near barrel warehouse
				{Vector3Box(5.77171, 21.4551, 0.78375), Vector3Box(5.77117, 23.3448, 0.399279), Vector3Box(5.94202, 25.1481, -2.94929), false,},		-- drop-down 1 to a ledge at the waterline near start
				{Vector3Box(14.5143, 22.9693, 0.513352), Vector3Box(15.5882, 23.0694, -0.755862), Vector3Box(15.1894, 24.783, -2.961), false,},			-- drop-down 2 to a ledge at the waterline near start
				{Vector3Box(28.2934, 23.2112, 0.71272), Vector3Box(26.8058, 23.5087, 0.625514), Vector3Box(25.741, 25.4421, -3.18603), false,},			-- skip part of the ramp near start
				{Vector3Box(61.2991, 16.7663, 0.717395), Vector3Box(61.2991, 16.7663, 0.717395), Vector3Box(64.27, 16.86, 1.47398), true,},				-- pathing behind boxes near pillar warehouse entrance, a1
				{Vector3Box(64.4285, 16.1648, 1.47398), Vector3Box(64.4285, 14.3633, 1.0812), Vector3Box(64.3579, 14.2665, 0.704032), false,},			-- pathing behind boxes near pillar warehouse entrance, a2
				{Vector3Box(65.2114, 14.4752, 0.660277), Vector3Box(65.2114, 14.4752, 0.660277), Vector3Box(63.98, 17.15, 1.47398), true,},				-- pathing behind boxes near pillar warehouse entrance, b1
				{Vector3Box(63.2848, 16.8713, 1.47398), Vector3Box(61.4642, 16.8713, 1.06849), Vector3Box(61.4076, 16.7774, 0.71249), false,},			-- pathing behind boxes near pillar warehouse entrance, b2
				{Vector3Box(103.758, 16.0271, 4.28391), Vector3Box(103.045, 17.808, 3.86793), Vector3Box(102.478, 18.3737, 0.377654), false,},			-- drop-down near crane near pillar warehouse entrance
				{Vector3Box(89.5334, 10.1042, 7.49828), Vector3Box(87.4301, 9.17003, 7.14853), Vector3Box(86.896, 9.46831, 4.20948), false,},			-- drop-down 1 (1/2) to pillar warehouse
				{Vector3Box(89.854, 9.73757, 4.23299), Vector3Box(90.5299, 8.04773, 3.91284), Vector3Box(90.6781, 7.51923, 0.453528), false,},			-- drop-down 1 (2/2) to pillar warehouse
				{Vector3Box(94.482, 6.17643, 7.44529), Vector3Box(95.0828, 4.37125, 7.05211), Vector3Box(95.0114, 4.33452, 6.43467), false,},			-- drop-down 2 (1/2) to pillar warehouse
				{Vector3Box(95.172, 3.91887, 6.44202), Vector3Box(95.6093, 2.38851, 6.06142), Vector3Box(95.6039, 2.57218, 0.535565), false,},			-- drop-down 2 (2/2) to pillar warehouse
				{Vector3Box(100.504, -11.7948, 4.18342), Vector3Box(100.706, -10.0478, 3.43439), Vector3Box(100.334, -9.13056, 0.515072), false,},		-- drop-down from level 1 to ground level near pillar 2 in pillar warehouse
				{Vector3Box(98.5603, -4.4211, 7.4857), Vector3Box(98.123, -3.76356, 8.47436), Vector3Box(96.7812, -2.13393, 9.34426), true,},			-- part 1 of "cage path" in pillar warehouse
				{Vector3Box(96.7455, -2.62588, 9.36095), Vector3Box(96.7455, -2.62588, 9.36095), Vector3Box(92.1596, -3.70617, 9.73898), true,},		-- part 2 of "cage path" in pillar warehouse
				{Vector3Box(85.1786, 2.84162, 12.4903), Vector3Box(85.1786, 2.84162, 12.4903), Vector3Box(87.3097, 6.24054, 10.6415), true,},			-- part 3 of "cage path" in pillar warehouse
				{Vector3Box(86.4377, 6.88713, 10.6415), Vector3Box(85.4635, 8.10489, 10.2175), Vector3Box(84.4654, 7.67591, 7.95336), false,},			-- part 4 of "cage path" in pillar warehouse
				{Vector3Box(85.0636, 8.34066, 7.95441), Vector3Box(85.0636, 8.34066, 7.95441), Vector3Box(87.0777, 11.0594, 7.27784), true,},			-- part 5 of "cage path" in pillar warehouse
				{Vector3Box(69.754, 1.34484, 11.3755), Vector3Box(68.2355, 0.399382, 10.3183), Vector3Box(66.7297, -0.53599, 6.73448), false,},			-- part 6 of "cage path" in pillar warehouse
				{Vector3Box(72.1268, -2.83506, 4.73219), Vector3Box(72.1284, -4.26478, 4.27911), Vector3Box(72.4562, -5.36509, 0.54757), false,},		-- drop-down (1/2) from pillar 4 in pillar warehouse
				{Vector3Box(70.0952, -0.935156, 7.23448), Vector3Box(71.1093, -0.777161, 6.4566), Vector3Box(71.2797, -1.97125, 4.73219), false,},		-- drop-down (2/2) from pillar 4 in pillar warehouse
				{Vector3Box(67.8253, -8.19856, 3.57922), Vector3Box(69.224, -7.63257, 2.90369), Vector3Box(70.6317, -7.09227, 0.565549), false,},		-- drop-down ship for part of the staris at pillar 4 in pillar warehouse
				{Vector3Box(88.0618, -18.1152, 8.5668), Vector3Box(88.0618, -18.1152, 8.5668), Vector3Box(92.8177, -20, 8.66578), true,},				-- upper path jumps (1/2) from pillar 2 to pillar 3 in pillar warehouse, a
				{Vector3Box(86.6423, -21.8418, 8.63441), Vector3Box(86.6423, -21.8418, 8.63441), Vector3Box(87.16, -17.192, 8.5693), true,},			-- upper path jumps (2/2) from pillar 2 to pillar 3 in pillar warehouse, a
				{Vector3Box(87.5339, -18.3065, 8.5668), Vector3Box(87.5339, -18.3065, 8.5668), Vector3Box(86.7597, -21.1752, 8.63461), true,},			-- upper path jumps (1/2) from pillar 2 to pillar 3 in pillar warehouse, b
				{Vector3Box(91.5118, -19.0149, 8.66578), Vector3Box(91.5109, -18.8769, 8.66642), Vector3Box(87.35, -18.1138, 8.5693), true,},			-- upper path jumps (2/2) from pillar 2 to pillar 3 in pillar warehouse, b
				{Vector3Box(94.1733, -8.02995, 7.43523), Vector3Box(93.583, -6.37749, 7.02609), Vector3Box(92.2116, -4.87314, 3.27527), false,},		-- drop-down to on top of the bridge cage from pillar 2 in pillar warehouse
				{Vector3Box(50.1749, -22.7385, 1.81959), Vector3Box(48.4819, -22.7388, 1.56699), Vector3Box(47.0282, -22.0247, -1.109), false,},		-- drop-down to the market square after pillar warehouse
				{Vector3Box(-27.5352, 20.1252, 5.70178), Vector3Box(-29.4272, 21.154, 5.19568), Vector3Box(-30.0385, 21.837, 3.55372), false,},			-- drop-down to barrel warehouse (1/2)
				{Vector3Box(-25.0652, 18.8189, 7.33873), Vector3Box(-26.321, 18.8189, 7.09157), Vector3Box(-26.1267, 18.8358, 5.67405), false,},		-- drop-down to barrel warehouse (2/2)
				{Vector3Box(-35.6459, 28.2668, 7.95397), Vector3Box(-35.003, 26.564, 6.98014), Vector3Box(-36.2774, 24.7182, 3.20803), false,},			-- drop-down to skip part of the stairs leading to barrel 1 in barrel warehouse
				{Vector3Box(-43.8246, 23.1804, 9.73828), Vector3Box(-43.4008, 21.8243, 8.69204), Vector3Box(-45.9205, 20.0924, 5.24866), false,},		-- drop-down 1 (1/2) from the scaffolding in barrel warehouse
				{Vector3Box(-46.5337, 20.1306, 5.26083), Vector3Box(-47.7973, 21.1571, 4.85019), Vector3Box(-47.9353, 22.2666, 3.26927), false,},		-- drop-down 1 (2/2) from the scaffolding in barrel warehouse
				{Vector3Box(-28.6058, 10.6307, 11.0838), Vector3Box(-29.0692, 12.1958, 10.6993), Vector3Box(-25.7958, 14.6925, 5.65738), false,},		-- drop-down 2 from the scaffolding in barrel warehouse
				{Vector3Box(-46.8594, 17.3221, 13.0664), Vector3Box(-46.9001, 17.3619, 13.0121), Vector3Box(-50.5105, 16.3723, 13.3282), true,},		-- jump past a gap on the scaffolding in barrel warehouse, a
				{Vector3Box(-49.4114, 16.2328, 13.3282), Vector3Box(-48.8853, 16.4343, 13.2954), Vector3Box(-45.9511, 17.0465, 13.1058), true,},		-- jump past a gap on the scaffolding in barrel warehouse, b
				{Vector3Box(-34.0304, 28.1293, 17.8935), Vector3Box(-32.785, 26.9563, 17.3064), Vector3Box(-31.3178, 27.3685, 13.4044), false,},		-- drop-down to skip barrel 5 ladder climb-down on the scaffolding in barrel warehouse
				{Vector3Box(-21.2442, 22.7852, 16.3218), Vector3Box(-22.3503, 23.5962, 15.9092), Vector3Box(-21.9339, 23.3964, 12.5342), false,},		-- drop-down to skip barrel 3 ladder climb-down on the scaffolding in barrel warehouse
				{Vector3Box(-46.4004, 7.19227, 13.0955), Vector3Box(-45.9454, 7.35791, 12.9485), Vector3Box(-40.61, 5.5062, 9.20947), true,},			-- shortcut from barrel 2 to barrel 4 on the scaffolding in barrel warehouse
				{Vector3Box(-3.20747, -16.1117, 2.19554), Vector3Box(-1.39983, -16.6273, 1.73637), Vector3Box(-0.461066, -16.8165, -1.10386), false,},	-- drop-down 1 to the market square after barrel warehouse
				{Vector3Box(-4.19484, -33.368, 2.21594), Vector3Box(-2.35852, -33.368, 1.71182), Vector3Box(-0.983696, -32.9591, -1.11471), false,},	-- drop-down 2 to the market square after barrel warehouse
				{Vector3Box(-4.38484, -43.5194, 2.16867), Vector3Box(-2.53341, -43.5194, 1.75559), Vector3Box(-1.38547, -43.7956, -1.00545), false,},	-- drop-down 3 to the market square after barrel warehouse
			},
			dlc_castle_dungeon =	-- the dungeons
			{
				{Vector3Box(131.334, 1.0091, 11.5564), Vector3Box(132.058, 2.16415, 11.1706), Vector3Box(131.411, 5.00737, 8.0372), true,},			-- Jump over a staricase railing soon after first small darkness section
				{Vector3Box(120.795, 37.3784, 17.9995), Vector3Box(120.886, 37.7428, 18.6484), Vector3Box(124.877, 38.1961, 16.6046), true,},		-- Jump over a railing to the 1st tome area (to prevent bots learning bad transition here)
				{Vector3Box(133.997, 34.5977, 16.592), Vector3Box(133.997, 34.5977, 16.592), Vector3Box(139.007, 33.553, 10.15), false,},			-- Drop-down from 1st tome area (bots take a bit damage here as they can't drop on top of the pillar)
				{Vector3Box(87.9849, 20.8944, 10.1754), Vector3Box(86.2194, 20.8963, 9.64307), Vector3Box(85.6174, 21.0185, 5.29682), false,},		-- Drop-down 1 in the skull event area
				{Vector3Box(82.0652, 21.4218, 10.1754), Vector3Box(83.8593, 21.4218, 9.61457), Vector3Box(86.3479, 21.4204, 5.34516), false,},		-- Drop-down 2 in the skull event area
				{Vector3Box(95.7452, 8.67214, 8.20422), Vector3Box(96.9446, 8.67214, 7.82727), Vector3Box(98.1506, 8.79224, 4.04641), false,},		-- Double drop-down in the skull event area 1/2
				{Vector3Box(92.1352, 8.94484, 10.1754), Vector3Box(93.8813, 8.92484, 9.56928), Vector3Box(94.2163, 8.70914, 8.15681), false,},		-- Double drop-down in the skull event area 2/2
				{Vector3Box(60.1859, 0.481373, 10.3958), Vector3Box(60.1859, 0.481373, 10.3958), Vector3Box(63.6194, -0.0705487, 7.27128), true,},	-- Hilly area jump-down 1 just before dark half of the map
				{Vector3Box(54.8089, -10.1142, 12.42), Vector3Box(54.8089, -10.1142, 12.42), Vector3Box(56.0403, -13.1099, 7.3132), true,},			-- Hilly area jump-down 2 just before dark half of the map
				{Vector3Box(46.8218, -9.64232, 11.8822), Vector3Box(46.8218, -9.64232, 11.8822), Vector3Box(44.2769, -9.4201, 8.0705), true,},		-- Hilly area jump-down 3 just before dark half of the map
				{Vector3Box(19.4197, -17.2627, 7.82748), Vector3Box(19.4197, -17.2627, 7.82748), Vector3Box(22.3814, -17.0671, 3.57289), true,},	-- Jump-down to the dark half of the map
				{Vector3Box(12.1594, 23.4321, -6.43781), Vector3Box(12.1594, 23.4321, -6.43781), Vector3Box(11.9616, 26.6338, -10.453), true,},		-- Jump-down 1 to the pit near trap-chect in the darkness
				{Vector3Box(19.8765, 23.0499, -6.73924), Vector3Box(19.8765, 23.0499, -6.73924), Vector3Box(19.6406, 26.4023, -10.453), true,},		-- Jump-down 2 to the pit near trap-chect in the darkness
				{Vector3Box(31.8058, 23.5961, -6.40121), Vector3Box(31.8058, 23.5961, -6.40121), Vector3Box(31.8194, 26.6919, -10.453), true,},		-- Jump-down 3 to the pit near trap-chect in the darkness
				{Vector3Box(64.9676, 13.8459, -6.33894), Vector3Box(64.9676, 13.8459, -6.33894), Vector3Box(65.1238, 16.133, -9.9275), true,},		-- Jump-down 1 to the ground from darkness wooden beam passage
				{Vector3Box(70.4768, 13.6948, -6.03746), Vector3Box(70.4768, 12.222, -7.11738), Vector3Box(69.4342, 11.2695, -9.9275), true,},		-- Jump-down 2 to the ground from darkness wooden beam passage
				{Vector3Box(75.7952, 16.144, -5.96191), Vector3Box(75.8115, 16.144, -6.32663), Vector3Box(77.969, 15.7246, -9.88781), true,},		-- Jump-down 3 to the ground from darkness wooden beam passage
				{Vector3Box(84.8193, 13.6948, -6.08335), Vector3Box(85.498, 13.9021, -6.37132), Vector3Box(85.2771, 16.0971, -9.91189), true,},		-- Jump-down 4 to the ground from darkness wooden beam passage
			},
			dlc_portals =	-- summoner's peak
			{
				{	-- jump over a gap right after the bridge after first portal, a
					Vector3Box(26.8152, -42.4976, 4.67527),
					Vector3Box(26.8152, -42.4976, 4.67527),
					Vector3Box(24.2541, -42.0455, 5.09376),
					true,
				},
				{	-- jump over a gap right after the bridge after first portal, b
					Vector3Box(24.2155, -42.3574, 5.10995),
					Vector3Box(24.2155, -42.3574, 5.10995),
					Vector3Box(27.5821, -43.0644, 4.65349),
					true,
				},
				{	-- trick bots into using the first ladder instead of running around
					Vector3Box(30.3248, -41.6933, 10.3097),
					Vector3Box(30.6464, -42.001, 10.3059),
					Vector3Box(33.5718, -44.3329, 16.0495),
					true,
				},
			},
			farm =	-- wheat and chaff
			{
				{	-- pass through along the outer edge of the house left from the start, a
					Vector3Box(-58.6234, 77.5027, 81.965),
					Vector3Box(-58.6234, 77.5027, 81.965),
					Vector3Box(-60.6887, 75.8498, 81.9227),
					true,
				},
				{	-- pass through along the outer edge of the house left from the start, b
					Vector3Box(-60.0548, 75.9908, 81.9434),
					Vector3Box(-59.7635, 76.2025, 81.965),
					Vector3Box(-58.4534, 77.5491, 81.9642),
					true,
				},
				{	-- drop-down 1 on the rocks near the house left from the start
					Vector3Box(-48.2766, 90.4064, 85.1259),
					Vector3Box(-49.6377, 89.8109, 84.2609),
					Vector3Box(-49.1673, 90.0454, 83.1691),
					false,
				},
				{	-- drop-down 2 on the rocks near the house left from the start (jump)
					Vector3Box(-44.4701, 94.6171, 85.4961),
					Vector3Box(-44.4701, 94.6171, 85.4961),
					Vector3Box(-44.7517, 97.5262, 83.647),
					true,
				},
				{	-- drop-down 3 on the rocks near the house left from the start
					Vector3Box(-47.3408, 97.9108, 83.5228),
					Vector3Box(-48.5636, 98.8279, 82.8369),
					Vector3Box(-49.5827, 99.2501, 81.2038),
					false,
				},
				{	-- drop-down 4 on the rocks near the house left from the start
					Vector3Box(-39.0084, 87.3212, 85.163),
					Vector3Box(-38.1393, 85.7568, 83.7745),
					Vector3Box(-37.6137, 85.0379, 82.1359),
					false,
				},
				{	-- drop-down 5 on the rocks near the house left from the start (jump)
					Vector3Box(-37.1206, 92.3762, 85.3023),
					Vector3Box(-37.1206, 92.3762, 85.3023),
					Vector3Box(-33.5889, 90.6558, 82.3444),
					true,
				},
				{	-- drop-down 6 on the rocks near the house left from the start
					Vector3Box(-30.7572, 92.3416, 81.7384),
					Vector3Box(-28.4031, 92.6555, 80.4448),
					Vector3Box(-27.1696, 92.5004, 77.7639),
					false,
				},
				{	-- drop-down 7 on the rocks near the house left from the start
					Vector3Box(-33.4461, 84.3748, 81.7339),
					Vector3Box(-32.2138, 82.4605, 79.8539),
					Vector3Box(-31.9921, 82.4114, 77.6322),
					false,
				},
				{	-- jump-up 1 on the rocks near the house left from the start
					Vector3Box(-39.3119, 98.4214, 83.6427),
					Vector3Box(-39.2597, 98.1535, 83.6874),
					Vector3Box(-39.1611, 96.8765, 85.2544),
					true,
				},
				{	-- jump-up 2 on the rocks near the house left from the start
					Vector3Box(-49.206, 84.567, 83.8835),
					Vector3Box(-49.3205, 84.1807, 85.0246),
					Vector3Box(-50.5031, 83.5584, 86.3994),
					true,
				},
				{	-- jump-up 3 on the rocks near the house left from the start
					Vector3Box(-47.2062, 100.005, 81.5106),
					Vector3Box(-46.4348, 100.059, 81.7371),
					Vector3Box(-41.935, 97.7537, 83.6628),
					true,
				},
				{	-- drop-down from hollow tree trunk near the house left from the start
					Vector3Box(-32.5048, 100.227, 81.6322),
					Vector3Box(-30.5248, 100.631, 80.7948),
					Vector3Box(-29.295, 100.194, 78.247),
					false,
				},
				{	-- drop-down 1 near farm
					Vector3Box(-24.2115, 76.6447, 76.0806),
					Vector3Box(-23.0947, 74.5507, 74.6931),
					Vector3Box(-22.7196, 73.8989, 72.5179),
					false,
				},
				{	-- drop-down 2 near farm
					Vector3Box(-32.5799, 72.4086, 76.4075),
					Vector3Box(-31.7025, 70.4355, 75.0665),
					Vector3Box(-31.3593, 69.8005, 73.3566),
					false,
				},
				{	-- drop-down 3 near farm
					Vector3Box(-41.9549, 59.1094, 75.4081),
					Vector3Box(-40.5012, 59.6685, 74.6694),
					Vector3Box(-39.2561, 59.8277, 72.5704),
					false,
				},
				{	-- jump over farm fence 1 a
					Vector3Box(-21.1898, 65.1805, 72.6096),
					Vector3Box(-21.3901, 65.4453, 72.6107),
					Vector3Box(-22.6205, 67.1554, 72.6878),
					true,
				},
				{	-- jump over farm fence 1 b
					Vector3Box(-22.3678, 66.9205, 72.6716),
					Vector3Box(-22.1817, 66.6792, 72.6542),
					Vector3Box(-21.021, 65.1059, 72.6187),
					true,
				},
				{	-- jump over farm fence 2 a
					Vector3Box(-12.5961, 55.8124, 73.215),
					Vector3Box(-12.5138, 55.5333, 73.2258),
					Vector3Box(-12.0317, 53.7998, 72.9396),
					true,
				},
				{	-- jump over farm fence 2 b
					Vector3Box(-11.9552, 53.8782, 72.9458),
					Vector3Box(-12.029, 54.1539, 72.9651),
					Vector3Box(-12.4706, 55.805, 73.2059),
					true,
				},
				{	-- jump over farm fence 3 a
					Vector3Box(-9.97622, 66.8332, 73.0074),
					Vector3Box(-10.2212, 66.7966, 72.9942),
					Vector3Box(-11.8218, 66.2129, 72.9776),
					true,
				},
				{	-- jump over farm fence 3 b
					Vector3Box(-11.9233, 65.9657, 72.9808),
					Vector3Box(-11.5774, 66.1455, 72.9855),
					Vector3Box(-10.068, 66.931, 73.0012),
					true,
				},
				{	-- pass through a broken wall at the farm yeard, a
					Vector3Box(1.35698, 33.5865, 72.8798),
					Vector3Box(1.35698, 33.5865, 72.8798),
					Vector3Box(-0.694226, 31.6984, 72.7947),
					true,
				},
				{	-- pass through a broken wall at the farm yeard, b
					Vector3Box(-0.533642, 31.9261, 72.8031),
					Vector3Box(-0.516425, 31.9277, 72.9816),
					Vector3Box(1.08035, 34.6162, 72.8348),
					true,
				},
				{	-- jump over a ladder hole at the farm yeard, a
					Vector3Box(-1.75218, 27.3451, 72.7359),
					Vector3Box(-1.76083, 27.5265, 72.7366),
					Vector3Box(-3.63449, 29.4546, 72.8123),
					true,
				},
				{	-- jump over a ladder hole at the farm yeard, b
					Vector3Box(-3.55621, 28.8608, 72.7359),
					Vector3Box(-3.42565, 28.8411, 72.7366),
					Vector3Box(-1.34531, 27.2683, 72.7441),
					true,
				},
				{	-- jump over a broken wall at the farm yeard, a
					Vector3Box(17.18, 42.8146, 72.7834),
					Vector3Box(17.18, 42.8146, 72.7834),
					Vector3Box(19.8576, 44.2515, 72.79),
					true,
				},
				{	-- jump over a broken wall at the farm yeard, b
					Vector3Box(19.7833, 44.4246, 72.7747),
					Vector3Box(19.7833, 44.4246, 72.7747),
					Vector3Box(17.0706, 43.2738, 72.7775),
					true,
				},
				{	-- drop-down 1 near the farm yeard (jump)
					Vector3Box(-7.76274, 61.5462, 75.9147),
					Vector3Box(-7.76274, 61.5462, 75.9147),
					Vector3Box(-11.4188, 60.7964, 73.0928),
					true,
				},
				{	-- drop-down 2 near the farm yeard
					Vector3Box(-3.96199, 67.7491, 75.8966),
					Vector3Box(-4.64128, 69.4523, 75.226),
					Vector3Box(-4.6692, 70.6291, 73.1716),
					false,
				},
				{	-- drop-down 3 near the farm yeard
					Vector3Box(4.05424, 68.1227, 75.8472),
					Vector3Box(3.7717, 70.1005, 75.2311),
					Vector3Box(4.19294, 71.2789, 73.2383),
					false,
				},
				{	-- drop-down 4 near the farm yeard
					Vector3Box(6.50465, 67.4884, 76.0876),
					Vector3Box(6.70933, 65.4416, 75.6338),
					Vector3Box(6.78955, 63.8952, 72.682),
					false,
				},
				{	-- drop-down 5 near the farm yeard
					Vector3Box(0.124811, 66.3458, 75.776),
					Vector3Box(0.781866, 64.732, 75.3778),
					Vector3Box(1.59603, 63.3647, 72.6436),
					false,
				},
				{	-- drop-down 6 near the farm yeard
					Vector3Box(-3.88068, 60.3106, 75.9405),
					Vector3Box(-3.1995, 58.4941, 74.9666),
					Vector3Box(-2.84705, 57.4373, 72.739),
					false,
				},
				{	-- drop-down 1 at the farm yeard scaffolding
					Vector3Box(4.07987, 26.6048, 75.6749),
					Vector3Box(4.45272, 28.4696, 75.2256),
					Vector3Box(4.53414, 29.2041, 72.8234),
					false,
				},
				{	-- drop-down 2 at the farm yeard scaffolding
					Vector3Box(8.9289, 25.8504, 75.6545),
					Vector3Box(9.16962, 27.6581, 75.2483),
					Vector3Box(9.23628, 28.4786, 73.0957),
					false,
				},
				{	-- drop-down 3 at the farm yeard scaffolding
					Vector3Box(16.554, 28.7595, 75.8242),
					Vector3Box(15.8802, 30.4439, 75.2761),
					Vector3Box(15.5112, 30.9654, 72.8294),
					false,
				},
				{	-- pass through a narrow gap at the farm yeard scaffolding, a
					Vector3Box(9.99808, 24.347, 75.7406),
					Vector3Box(9.99808, 24.347, 75.7406),
					Vector3Box(12.8469, 24.1817, 75.8293),
					true,
				},
				{	-- pass through a narrow gap at the farm yeard scaffolding, b
					Vector3Box(12.7775, 23.8859, 75.8288),
					Vector3Box(12.7775, 23.8859, 75.8288),
					Vector3Box(9.91146, 24.3591, 75.7765),
					true,
				},
				{	-- drop-down 1 at the farm yeard
					Vector3Box(21.4552, 46.9152, 76.8456),
					Vector3Box(23.2512, 47.5542, 76.0006),
					Vector3Box(24.0104, 47.9253, 72.8104),
					false,
				},
				{	-- drop-down 2 at the farm yeard
					Vector3Box(19.2706, 42.1676, 76.72),
					Vector3Box(17.5946, 41.897, 76.2868),
					Vector3Box(15.7231, 42.3945, 72.7731),
					false,
				},
				{	-- pass through the farm yard tunnel, a
					Vector3Box(4.48272, 28.2555, 67.5291),
					Vector3Box(3.84654, 28.2883, 67.5771),
					Vector3Box(1.71619, 28.7073, 68.0786),
					true,
				},
				{	-- pass through the farm yard tunnel, b
					Vector3Box(0.850808, 28.9804, 68.2102),
					Vector3Box(2.2361, 28.721, 67.8113),
					Vector3Box(4.2151, 28.3674, 67.5429),
					true,
				},
				{	-- jump over swamp farm fence 1 a
					Vector3Box(-24.4643, -21.0569, 75.6823),
					Vector3Box(-24.4643, -21.0569, 75.6823),
					Vector3Box(-23.9864, -18.0339, 75.2716),
					true,
				},
				{	-- jump over swamp farm fence 1 b
					Vector3Box(-24.2178, -19.1895, 75.3597),
					Vector3Box(-24.2178, -19.1895, 75.3597),
					Vector3Box(-24.9075, -21.4135, 75.7155),
					true,
				},
				{	-- jump over swamp farm fence 2 a
					Vector3Box(-31.9243, -12.9852, 75.0871),
					Vector3Box(-31.8999, -12.9359, 75.0892),
					Vector3Box(-31.0515, -11.2232, 75.0153),
					true,
				},
				{	-- jump over swamp farm fence 2 b
					Vector3Box(-31.1245, -11.3688, 75.0326),
					Vector3Box(-31.1245, -11.3688, 75.0326),
					Vector3Box(-31.132, -13.3884, 75.1584),
					true,
				},
				{	-- jump over swamp farm fence 3 a
					Vector3Box(-37.2737, -10.0812, 74.7044),
					Vector3Box(-37.2273, -10.0151, 74.6747),
					Vector3Box(-36.0665, -8.04829, 74.4768),
					true,
				},
				{	-- jump over swamp farm fence 3 b
					Vector3Box(-36.0905, -8.0904, 74.4729),
					Vector3Box(-36.0905, -8.0904, 74.4729),
					Vector3Box(-37.5377, -10.6285, 74.7375),
					true,
				},
				{	-- jump over swamp farm fence 4 a
					Vector3Box(-48.6115, -2.1679, 74.4865),
					Vector3Box(-48.6115, -2.1679, 74.4865),
					Vector3Box(-46.3153, -1.67675, 74.4796),
					true,
				},
				{	-- jump over swamp farm fence 4 b
					Vector3Box(-47.1115, -1.17684, 74.4823),
					Vector3Box(-47.1115, -1.17684, 74.4823),
					Vector3Box(-48.6115, -2.1679, 74.4859),
					true,
				},
				{	-- jump over swamp farm fence 5 a
					Vector3Box(-20.356, -5.80188, 75.2744),
					Vector3Box(-20.356, -5.80188, 75.2744),
					Vector3Box(-22.5745, -6.89071, 75.0828),
					true,
				},
				{	-- jump over swamp farm fence 5 b
					Vector3Box(-22.1898, -6.67694, 75.0794),
					Vector3Box(-22.1898, -6.67694, 75.0794),
					Vector3Box(-20.356, -5.80188, 75.3031),
					true,
				},
				{	-- jump over swamp farm fence 6 a
					Vector3Box(-23.0888, -1.93828, 74.7976),
					Vector3Box(-23.0888, -1.93828, 74.7976),
					Vector3Box(-24.521, -3.34483, 74.9467),
					true,
				},
				{	-- jump over swamp farm fence 6 b
					Vector3Box(-24.2689, -3.00892, 74.8924),
					Vector3Box(-24.2689, -3.00892, 74.8924),
					Vector3Box(-22.6081, -1.58988, 74.851),
					true,
				},
				{	-- jump over swamp farm fence 7 a
					Vector3Box(-25.9593, 2.04845, 74.5335),
					Vector3Box(-25.9593, 2.04845, 74.5335),
					Vector3Box(-27.9006, 0.780392, 74.4599),
					true,
				},
				{	-- jump over swamp farm fence 7 b
					Vector3Box(-27.3249, 1.16662, 74.5079),
					Vector3Box(-27.3249, 1.16662, 74.5079),
					Vector3Box(-25.6123, 2.38168, 74.5025),
					true,
				},
				{	-- jump up to a dirt platform 1 near swamp farm
					Vector3Box(-49.9848, 0.455628, 74.4803),
					Vector3Box(-49.4099, 0.45563, 75.29),
					Vector3Box(-48.02, 2.81578, 76.1951),
					true,
				},
				{	-- drop-down 1 from a dirt platform 1 near swamp farm
					Vector3Box(-48.41, 0.78555, 76.5694),
					Vector3Box(-50.0175, -0.178954, 76.2293),
					Vector3Box(-50.6702, -0.878519, 74.5087),
					false,
				},
				{	-- drop-down 2 from a dirt platform 1 near swamp farm
					Vector3Box(-43.7132, 1.14904, 76.3442),
					Vector3Box(-42.1264, 0.615666, 75.8514),
					Vector3Box(-40.96, 0.437368, 73.8324),
					false,
				},
				{	-- drop-down 3 from a dirt platform 1 near swamp farm
					Vector3Box(-45.5852, 5.49099, 75.7261),
					Vector3Box(-45.8037, 7.21933, 74.8665),
					Vector3Box(-45.8234, 7.94908, 73.4904),
					false,
				},
				{	-- drop-down 1 from a dirt platform 2 near swamp farm
					Vector3Box(-55.9878, 4.16526, 77.661),
					Vector3Box(-55.0222, 2.61888, 76.9928),
					Vector3Box(-54.6806, 1.57969, 74.6824),
					false,
				},
				{	-- drop-down 2 from a dirt platform 2 near swamp farm
					Vector3Box(-56.366, 13.4074, 76.9897),
					Vector3Box(-58.1484, 14.4471, 75.986),
					Vector3Box(-59.0172, 14.8729, 73.9301),
					false,
				},
				{	-- drop-down 1 from right side sack location
					Vector3Box(-79.2151, 9.95258, 79.7896),
					Vector3Box(-80.7065, 9.95258, 79.4207),
					Vector3Box(-83.0047, 10.0526, 75.2988),
					false,
				},
				{	-- drop-down 2 from right side sack location
					Vector3Box(-74.3048, 10.5471, 79.9039),
					Vector3Box(-72.9587, 10.5471, 79.5293),
					Vector3Box(-72.1161, 10.6988, 76.5758),
					false,
				},
				{	-- jump 1 off of a bridge
					Vector3Box(-88.6004, 34.5671, 76.3839),
					Vector3Box(-88.6004, 34.5671, 76.3839),
					Vector3Box(-94.7497, 33.8257, 75.1543),
					true,
				},
				{	-- jump 2 off of a bridge
					Vector3Box(-87.3486, 28.6434, 75.9758),
					Vector3Box(-87.1679, 28.6075, 75.9451),
					Vector3Box(-85.3622, 28.3107, 73.6166),
					true,
				},
				{	-- jump on top of a small rock next to giant tree
					Vector3Box(-70.1723, 37.5109, 75.7256),
					Vector3Box(-70.1723, 37.5109, 75.7256),
					Vector3Box(-69.5192, 38.4334, 76.5816),
					true,
				},
				{	-- drop-down 1 off of a bridge 2
					Vector3Box(-71.3649, 46.1228, 76.6341),
					Vector3Box(-69.5523, 44.4776, 77.3628),
					Vector3Box(-69.7325, 44.7453, 73.4565),
					false,
				},
				{	-- drop-down 2 off of a bridge 2
					Vector3Box(-72.6517, 49.1173, 76.6577),
					Vector3Box(-74.2448, 50.7103, 77.5229),
					Vector3Box(-74.8824, 51.0449, 74.1842),
					false,
				},
				{	-- drop-down 1 near wagon
					Vector3Box(-58.0261, 44.73, 76.1908),
					Vector3Box(-59.0136, 43.4862, 75.7155),
					Vector3Box(-59.3251, 42.1086, 73.5014),
					false,
				},
				{	-- jump over wagon fence 1 a
					Vector3Box(-59.5021, 49.6134, 76.1769),
					Vector3Box(-59.4832, 49.3976, 76.1566),
					Vector3Box(-59.1155, 47.7744, 76.1862),
					true,
				},
				{	-- jump over wagon fence 1 b
					Vector3Box(-59.1659, 47.2704, 76.2543),
					Vector3Box(-59.1659, 47.2704, 76.2543),
					Vector3Box(-59.3185, 50.1833, 76.229),
					true,
				},
				{	-- jump 1 over wagon fence 2 a
					Vector3Box(-71.5047, 53.2724, 77.2634),
					Vector3Box(-71.5047, 53.2724, 77.2634),
					Vector3Box(-70.864, 49.8728, 76.7663),
					true,
				},
				{	-- jump 1 over wagon fence 2 b
					Vector3Box(-70.7967, 51.2156, 77.0208),
					Vector3Box(-70.7967, 51.2156, 77.0208),
					Vector3Box(-71.5712, 53.0671, 77.2605),
					true,
				},
				{	-- jump 2 over wagon fence 2 a
					Vector3Box(-69.0161, 55.0075, 76.9718),
					Vector3Box(-69.0161, 55.0075, 76.9718),
					Vector3Box(-67.6004, 53.7771, 76.8252),
					true,
				},
				{	-- jump 2 over wagon fence 2 b
					Vector3Box(-67.6589, 53.8231, 76.8098),
					Vector3Box(-67.6589, 53.8231, 76.8098),
					Vector3Box(-69.0161, 55.0075, 77.0272),
					true,
				},
				{	-- jump up to a tree trunk near wagon farm
					Vector3Box(-80.5448, 60.8306, 74.7819),
					Vector3Box(-80.9324, 60.7365, 75.2986),
					Vector3Box(-82.7047, 62.0258, 76.0519),
					true,
				},
				{	-- jump down from a tree trunk near wagon farm
					Vector3Box(-82.2068, 63.2074, 76.052),
					Vector3Box(-82.2068, 63.4457, 76.582),
					Vector3Box(-80.2755, 63.7907, 75.0898),
					true,
				},
				{	-- jump up the bump
					Vector3Box(-108.946, 63.2232, 86.4926),
					Vector3Box(-108.946, 63.2232, 86.4926),
					Vector3Box(-106.687, 62.7804, 87.6738),
					true,
				},
				{	-- drop down from the bump
					Vector3Box(-107.219, 63.1902, 87.5586),
					Vector3Box(-108.27, 64.2417, 86.872),
					Vector3Box(-108.676, 64.4974, 86.053),
					false,
				},
				{	-- jump up the bump 2
					Vector3Box(-105.185, 61.2587, 88.0346),
					Vector3Box(-105.185, 61.2587, 88.0346),
					Vector3Box(-106.64, 59.42, 89.2783),
					true,
				},
				{	-- drop down 1 from the bump 2
					Vector3Box(-104.677, 59.7317, 89.319),
					Vector3Box(-104.287, 60.5104, 89.1671),
					Vector3Box(-104.361, 61.3533, 88.02),
					false,
				},
				{	-- drop down 2 from the bump 2
					Vector3Box(-106.01, 55.1148, 89.9279),
					Vector3Box(-106.35, 54.1366, 89.572),
					Vector3Box(-106.73, 51.0229, 87.3355),
					false,
				},
				{	-- dropping down a small ledge
					Vector3Box(-98.8148, 48.4579, 85.8374),
					Vector3Box(-98.1291, 47.7371, 85.4661),
					Vector3Box(-97.2915, 47.1664, 84.211),
					false,
				},
				{	-- jumping up a small ledge
					Vector3Box(-97.961, 47.5737, 84.2831),
					Vector3Box(-97.961, 47.5737, 84.2831),
					Vector3Box(-100.161, 48.856, 85.6426),
					true,
				},
				{	-- drop-down from a high up cliff near wagon farm
					Vector3Box(-98.176, 38.7723, 84.1939),
					Vector3Box(-97.599, 39.794, 84.156),
					Vector3Box(-91.9754, 47.6822, 78.2842),
					false,
				},
			},
			dlc_survival_ruins =	-- the Fall
			{
				{	-- drop-down shortcut near crane
					Vector3Box(Vector3(-2.72895, 5.33484, 31.5608)),
					Vector3Box(Vector3(-2.72895, 3.47751, 31.1391)),
					Vector3Box(Vector3(-2.68282, 1.98325, 28.4534)),
					false,
				},
				{	-- another drop-down shortcut near crane (from plank bridge)
					Vector3Box(-9.32494, 2.39707, 31.1196),
					Vector3Box(-7.63683, 2.39805, 30.5827),
					Vector3Box(-6.20248, 3.93728, 26.7217),
					false,
				},
				{	-- another drop-down shortcut near crane
					Vector3Box(-6.38427, -0.964844, 29.4994),
					Vector3Box(-6.38756, 1.12189, 28.8471),
					Vector3Box(-6.8534, 2.33984, 26.4053),
					false,
				},
				{	-- another drop-down shortcut near crane
					Vector3Box(-2.18919, -8.43006, 29.3194),
					Vector3Box(-2.41358, -10.6725, 28.978),
					Vector3Box(-2.93636, -10.6776, 24.8069),
					false,
				},
				{	-- drop-down 1 from the roof over chest ended wood bridge
					Vector3Box(18.7799, 33.7511, 28.6153),
					Vector3Box(19.0631, 35.6076, 28.3162),
					Vector3Box(18.9366, 36.0081, 24.7586),
					false,
				},
				{	-- drop-down 2 from the roof over chest ended wood bridge
					Vector3Box(19.3651, 28.7466, 28.3761),
					Vector3Box(20.5321, 28.7469, 27.8516),
					Vector3Box(20.5375, 28.6969, 24.8099),
					false,
				},
				{	-- drop-down 3 from the roof over chest ended wood bridge
					Vector3Box(26.3997, 22.7852, 28.1978),
					Vector3Box(26.3997, 24.4951, 27.9932),
					Vector3Box(26.3704, 25.958, 24.7372),
					false,
				},
				{	-- drop-down from broken room corner at the yeard
					Vector3Box(39.1252, -4.95484, 25.0173),
					Vector3Box(39.766, -3.81891, 24.5588),
					Vector3Box(40.1206, -3.55197, 22.367),
					false,
				},
				{	-- small drop-down near the cage left to the holdout bridge
					Vector3Box(-4.63515, -11.246, 24.8069),
					Vector3Box(-4.63515, -13.9328, 23.6582),
					Vector3Box(-2.7709, -13.3673, 21.6418),
					false,
				},
				{	-- small drop-down to skip part of the stairs between the crane and the holdout bridge
					Vector3Box(6.28893, -16.9297, 29.6237),
					Vector3Box(6.06135, -18.3107, 29.2361),
					Vector3Box(7.44981, -18.4281, 25.5218),
					false,
				},
				{	-- drop-down 1 from window to lower level left to the holdout bridge
					Vector3Box(10.8025, -19.1835, 25.4234),
					Vector3Box(12.4436, -19.2811, 24.9975),
					Vector3Box(14.4383, -18.8922, 21.168),
					false,
				},
				{	-- drop-down 2 from window to lower level left to the holdout bridge
					Vector3Box(13.0984, -17.0852, 25.7276),
					Vector3Box(13.3274, -18.3167, 25.2365),
					Vector3Box(15.0759, -17.992, 21.1906),
					false,
				},
				{	-- drop-down 3 from window to lower level left to the holdout bridge
					Vector3Box(16.91, -17.0668, 25.691),
					Vector3Box(17.0864, -18.2926, 25.1056),
					Vector3Box(17.0035, -18.86, 20.6817),
					false,
				},
				{	-- drop-down from window to lower level right to the holdout bridge
					Vector3Box(32.6887, -12.8991, 24.6599),
					Vector3Box(33.2304, -14.689, 24.2099),
					Vector3Box(33.4, -16.5907, 20.6313),
					false,
				},
				{	-- drop-down 1 to yard from 2nd floor near the inside hold corner
					Vector3Box(17.6229, 6.54622, 28.8515),
					Vector3Box(17.4043, 5.23413, 28.5341),
					Vector3Box(17.8218, 2.97625, 24.5388),
					false,
				},
				{	-- drop-down 2 to yard from 2nd floor near the inside hold corner
					Vector3Box(23.1652, 7.06088, 28.8429),
					Vector3Box(22.6473, 5.54991, 28.4325),
					Vector3Box(22.8122, 4.3549, 24.4714),
					false,
				},
				{	-- drop-down 3 to yard from 2nd floor near the inside hold corner
					Vector3Box(24.8752, 8.93794, 28.8429),
					Vector3Box(26.2784, 8.40235, 28.4734),
					Vector3Box(28.0465, 7.77085, 24.6882),
					false,
				},
				{	-- drop-down to the holdout bridge from the next floor up
					Vector3Box(24.7635, -17.0295, 29.7113),
					Vector3Box(24.9186, -18.2866, 29.1769),
					Vector3Box(24.8136, -19.7993, 24.8841),
					false,
				},
				{	-- drop-down to the yard from the holdout bridge's direction
					Vector3Box(32.1047, -4.20255, 28.7651),
					Vector3Box(31.892, -2.54832, 28.2932),
					Vector3Box(31.9626, -1.60097, 24.565),
					false,
				},
				{	-- drop-down 1 to skip part of the yard wall stairs
					Vector3Box(14.8052, -5.27444, 28.0007),
					Vector3Box(16.6225, -5.27444, 27.2188),
					Vector3Box(17.4877, -5.55104, 24.6653),
					false,
				},
				{	-- drop-down 2 to skip part of the yard wall stairs
					Vector3Box(12.5252, -3.24339, 30.8448),
					Vector3Box(14.1002, -3.09466, 30.3256),
					Vector3Box(14.5442, -3.48323, 27.6199),
					false,
				},
				{	-- drop-down 1 near the inside hold corner to one floor down (outside)
					Vector3Box(20.9148, 9.12725, 32.8418),
					Vector3Box(19.6653, 8.74851, 32.4107),
					Vector3Box(19.6203, 8.87443, 28.8399),
					false,
				},
				{	-- drop-down 2 near the inside hold corner to one floor down (outside)
					Vector3Box(15.1852, 10.8448, 32.8418),
					Vector3Box(15.9984, 9.60455, 30.2825),
					Vector3Box(15.7273, 10.018, 28.8173),
					false,
				},
				{	-- drop-down 3 near the inside hold corner to one floor down (outside)
					Vector3Box(12.7152, 8.94506, 32.8042),
					Vector3Box(14.4974, 8.94506, 31.9395),
					Vector3Box(16.0927, 8.9149, 28.8375),
					false,
				},
			},
			dlc_survival_magnus =	-- town meeting
			{
				{Vector3Box(23.2439, 15.9473, 6.49419), Vector3Box(21.9079, 16.8334, 6.0519), Vector3Box(20.9, 16.86, 2.59749), false,},			-- drop-dopwn 1 from planks near west?? side gate
				{Vector3Box(24.0035, 16.2276, 6.51165), Vector3Box(25.3167, 15.4413, 6.12854), Vector3Box(26.1804, 13.6085, 2.65544), false,},		-- drop-dopwn 2 from planks near west?? side gate
				{Vector3Box(34.4522, 5.79384, 4.21277), Vector3Box(34.4522, 5.79384, 4.21277), Vector3Box(36.3954, 3.9566, 4.74332), true,},		-- Jump to the center statue using the usual sales stand
				{Vector3Box(45.5926, -3.50699, 6.58258), Vector3Box(47.161, -4.41191, 6.24286), Vector3Box(47.5478, -4.48532, 3.1478), false,},		-- drop-down 1 from the central statue
				{Vector3Box(41.9441, 4.07429, 6.33832), Vector3Box(43.1427, 5.6353, 6.0043), Vector3Box(43.6086, 7.18884, 3.03218), false,},		-- drop-down 2 from the central statue
				{Vector3Box(35.6862, -1.75663, 6.43201), Vector3Box(35.4206, -1.85086, 6.42995), Vector3Box(32.3222, -1.71934, 2.93494), true,},	-- drop-down 3 (jump) from the central statue
				{Vector3Box(76.5576, -4.01231, 3.43905), Vector3Box(76.5576, -4.01231, 3.43905), Vector3Box(76.687, -2.0578, 4.23789), true,},		-- board pile jump 1, a
				{Vector3Box(76.6249, -1.66712, 4.23789), Vector3Box(77.0815, 0.0681225, 3.85015), Vector3Box(76.9582, 0.0606761, 3.53997), false,},	-- board pile drop 1, a
				{Vector3Box(76.8495, -0.613075, 3.56695), Vector3Box(76.8495, -0.613075, 3.56695), Vector3Box(76.389, -2.6318, 4.23789), true,},	-- board pile jump 1, b
				{Vector3Box(76.2281, -3.01322, 4.23789), Vector3Box(75.6974, -4.79242, 3.8392), Vector3Box(75.6571, -4.74143, 3.48778), false,},	-- board pile drop 1, b
				{Vector3Box(75.0459, -1.91112, 4.23789), Vector3Box(74.1358, -1.55476, 4.23789), Vector3Box(72.5751, -0.947215, 5.35859), true,},	-- board pile jump 2
				{Vector3Box(73.5589, -1.285, 5.35859), Vector3Box(75.1401, -1.91747, 4.96383), Vector3Box(75.0748, -1.8924, 4.23789), false,},		-- board pile drop 2, a
				{Vector3Box(69.7374, 0.0919257, 5.35859), Vector3Box(68.3456, 0.867477, 4.98047), Vector3Box(67.8813, 0.917274, 3.2138), false,},	-- board pile drop 2, b
				{Vector3Box(70.2495, 0.779954, 5.35859), Vector3Box(70.2346, 0.791832, 5.35849), Vector3Box(67.1198, 3.54136, 5.37788), true,},		-- board pile jump 3, a
				{Vector3Box(78.865, 8.05349, 4.84215), Vector3Box(78.4993, 7.93159, 4.83304), Vector3Box(76.9072, 6.08573, 5.35859), true,},		-- board pile jump 3, b
				{Vector3Box(63.6064, 1.43252, 5.35859), Vector3Box(63.6064, -0.299923, 4.97554), Vector3Box(63.5946, -0.712212, 3.25877), false,},	-- board pile drop 3, a
				{Vector3Box(63.2069, 10.0071, 5.35859), Vector3Box(63.3251, 11.8978, 4.95636), Vector3Box(63.334, 12.2546, 3.10106), false,},		-- board pile drop 3, b
				{Vector3Box(70.4748, 4.71948, 5.35859), Vector3Box(70.077, 3.06195, 4.97603), Vector3Box(70.2897, 2.74824, 3.3355), false,},		-- board pile drop 3, c
				{Vector3Box(72.56, 9.31057, 6.35832), Vector3Box(73.0037, 11.0302, 5.96149), Vector3Box(73.1153, 11.5271, 3.51686), false,},		-- board pile drop 3, d
				{Vector3Box(76.7518, 6.01434, 5.35849), Vector3Box(76.7518, 6.01434, 5.35849), Vector3Box(78.7923, 8.83094, 4.85569), true,},		-- board pile drop (jump) 3, e
				{Vector3Box(71.7718, -16.8044, 3.69492), Vector3Box(71.3085, -17.5859, 3.73497), Vector3Box(70.0803, -19.5551, 3.77381), true,},	-- jump over fence near "far" chest, a
				{Vector3Box(69.9817, -19.8381, 3.78188), Vector3Box(70.3279, -19.0916, 3.77213), Vector3Box(71.1857, -17.1744, 3.73914), true,},	-- jump over fence near "far" chest, b
				{Vector3Box(80.8836, 6.66742, 4.02221), Vector3Box(80.8836, 6.66742, 4.02221), Vector3Box(79.4863, 9.16878, 4.87868), true,},		-- small jump to stones on the side of the "far" chest
				{Vector3Box(80.1193, 8.38317, 4.97128), Vector3Box(80.9549, 6.84216, 4.37581), Vector3Box(81.0535, 6.82473, 3.92802), false,},		-- small drop from stones near "far" chest
				{Vector3Box(36.0985, -10.6709, 3.60746), Vector3Box(36.0985, -10.6709, 3.9547), Vector3Box(36.6782, -14.87, 3.17155), true,},		-- jump over obstacle 1, a
				{Vector3Box(36.4876, -13.8774, 3.33128), Vector3Box(36.4876, -13.862, 3.11628), Vector3Box(35.8698, -12.3325, 4.04418), true,},		-- jump over obstacle 1, b
			},
		},
	},
	
	menu_settings =
	{
		key_save = {},
		bot_file_enabled					= false,
		manual_heal							= false,
		auto_heal							= false,
		no_manual_heal_optimization			= false,
		heal_only_if_wounded				= 1,
		heal_only_if_wounded_healshare		= false,
		heal_only_if_wounded_all			= false,
		max_healing_distance				= 5,
		pass_draughts_to_humans				= "Default",
		pass_draughts_to_humans_key			= "numpad 6",
		pass_draughts_to_humans_forced		= false,
		better_melee						= false,
		better_ranged						= false,
		keep_tomes							= false,
		pickup_tomes						= false,
		pickup_grims						= false,
		force_loot_key						= "numpad 5",
		force_loot							= false,
		hp_based_loot_pinged_heal			= false,
		hp_based_health_weight				= 3,
		hp_based_wounded_weight				= 3,
		hp_based_grim_weight				= 3,
		bot_to_avoid						= false,
		ignore_ratling_fire					= false,
		no_chase_ratlings					= false,
		no_chase_globadiers					= false,
		always_follow_host					= false,
		snipers_shoot_trash					= false,
		ping_stormvermin					= false,
		aggressive_melee					= false,
		info_guard_break					= false,
		info_guard_break_global_message		= false,
		cc_attacks_allowed					= false,
		cc_attacks_shield_hammer			= false,
		cc_attacks_shield_axe				= false,
		cc_attacks_shield_mace				= false,
		cc_attacks_shield_sword				= false,
		cc_attacks_2h_hammers				= false,
		kb_against_armor					= false,
		defend_objectives_key				= "numpad 4",
		defend_objectives_key_enabled		= false,
		defend_objectives					= nil,
		help_with_breakables_objectives		= false,
		breakables_objectives_threshold		= 0,
		cap_melee							= 1,
		cap_ranged							= 1,
		cap_specials						= 1,
		ignore_specials_pings				= false,
		reduce_ambient_shooting				= false,
		vent_allowed						= false,
		vent_hp_threshold					= 0.5,
		vent_heat_threshold					= 2,
		trading_prefer_potion				= 0,
		trading_prefer_grenade				= 0,
		trading_prefer_enable				= false,
		trading_prefer_strength				= false,
		trading_prefer_speed				= false,
		trading_prefer_different_potion		= false,
		trading_prefer_frag					= false,
		trading_prefer_fire					= false,
		trading_prefer_different_grenade	= false,
		trading_prefer_max_distance			= math.huge,
		small_ammo_needs_forcing			= false,
		
		update = function(self)
			local PASS_DRAUGHTS_TO_HUMANS_DECODE =
			{
				"Always",
				"Healshare",
				"Never",
				"Default",
			}
			local deathwish_enabled					= (rawget(_G, "deathwishtoken") and true) or false
			-- read the normal setting values
			self.bot_file_enabled					= get(me.SETTINGS.FILE_ENABLED)
			self.manual_heal						= get(me.SETTINGS.MANUAL_HEAL)
			self.auto_heal							= self.manual_heal == 1 or self.manual_heal == 2
			self.manual_heal						= self.manual_heal == 2 or self.manual_heal == 3
			self.no_manual_heal_optimization		= get(me.SETTINGS.NO_MANUAL_HEAL_OPTIMIZATION)
			self.heal_only_if_wounded				= get(me.SETTINGS.HEAL_ONLY_IF_WOUNDED) or 1
			self.heal_only_if_wounded_healshare		= (self.heal_only_if_wounded == 1 or self.heal_only_if_wounded == 2) and not deathwish_enabled
			self.heal_only_if_wounded_all			= self.heal_only_if_wounded == 2 and not deathwish_enabled
			self.max_healing_distance				= (get(me.SETTINGS.MAX_HEALING_DISTANCE)) or 5
			self.pass_draughts_to_humans			= PASS_DRAUGHTS_TO_HUMANS_DECODE[(get(me.SETTINGS.PASS_DRAUGHTS_TO_HUMANS) or 4)] or "Default"
			self.pass_draughts_to_humans_key		= get(me.SETTINGS.PASS_DRAUGHTS_TO_HUMANS_HOTKEY) or "numpad 6"
			self.pass_draughts_to_humans_forced		= get_hotkey_state(self.pass_draughts_to_humans_key)
			self.better_melee						= get(me.SETTINGS.BETTER_MELEE)
			self.better_ranged						= get(me.SETTINGS.BETTER_RANGED)
			self.keep_tomes							= get(me.SETTINGS.KEEP_TOMES)
			self.pickup_tomes						= get(me.SETTINGS.LOOT_TOMES)
			self.pickup_grims						= get(me.SETTINGS.LOOT_GRIMOIRES)
			self.force_loot_key						= get(me.SETTINGS.FORCE_LOOT_PINGED_ITEM) or "numpad 5"
			self.force_loot							= get_hotkey_state(self.force_loot_key)
			self.hp_based_loot_pinged_heal			= get(me.SETTINGS.HP_BASED_LOOT_PINGED_HEAL)
			self.hp_based_health_weight				= (get(me.SETTINGS.HP_BASED_HEALTH_WEIGHT)) or 3
			self.hp_based_wounded_weight			= (get(me.SETTINGS.HP_BASED_WOUNDED_WEIGHT)) or 3
			self.hp_based_grim_weight				= (get(me.SETTINGS.HP_BASED_GRIM_WEIGHT)) or 3
			self.bot_to_avoid						= get(me.SETTINGS.BOT_TO_AVOID)
			self.ignore_ratling_fire				= get(me.SETTINGS.NO_SEEK_COVER)
			self.no_chase_ratlings					= get(me.SETTINGS.NO_CHASE_RATLING)
			self.no_chase_globadiers				= get(me.SETTINGS.NO_CHASE_GLOBADIER)
			self.always_follow_host					= get(me.SETTINGS.FOLLOW)
			self.snipers_shoot_trash				= not get(me.SETTINGS.CONSERVE_SNIPER_AMMO)
			self.ping_stormvermin					= get(me.SETTINGS.PING_STORMVERMINS)
			self.aggressive_melee					= true	--get(me.SETTINGS.BOT_AGGRESSIVE_MELEE_MODE)
			self.info_guard_break					= get(me.SETTINGS.BOT_INFO_GUARD_BREAK)
			self.info_guard_break_global_message	= get(me.SETTINGS.BOT_INFO_GUARD_BREAK_GLOBAL_MESSAGE)
			self.cc_attacks_allowed					= get(me.SETTINGS.CC_ATTACKS_ALLOWED)
			self.cc_attacks_shield_hammer			= get(me.SETTINGS.CC_ATTACKS_SHIELD_HAMMER)
			self.cc_attacks_shield_axe				= get(me.SETTINGS.CC_ATTACKS_SHIELD_AXE)
			self.cc_attacks_shield_mace				= get(me.SETTINGS.CC_ATTACKS_SHIELD_MACE)
			self.cc_attacks_shield_sword			= get(me.SETTINGS.CC_ATTACKS_SHIELD_SWORD)
			self.kb_against_armor					= get(me.SETTINGS.KB_AGAINST_ARMOR)
			self.cc_attacks_2h_hammers				= get(me.SETTINGS.CC_ATTACKS_2H_HAMMERS)
			self.help_with_breakables_objectives	= get(me.SETTINGS.HELP_WITH_BREAKABLES_OBJECTIVES)
			self.breakables_objectives_threshold	= (get(me.SETTINGS.BREAKABLES_OBJECTIVES_THRESHOLD) or 100) / 100
			self.vent_allowed						= get(me.SETTINGS.VENT_ALLOWED)
			self.vent_hp_threshold					= (get(me.SETTINGS.VENT_HP_THRESHOLD) or 100) / 100
			
			self.trading_prefer_enable				= get(me.SETTINGS.TRADING_PREFER_ENABLE)
			self.trading_prefer_potion				= get(me.SETTINGS.TRADING_PREFER_POTION)	-- option 0 = no preference
			self.trading_prefer_strength			= self.trading_prefer_potion == 1
			self.trading_prefer_speed				= self.trading_prefer_potion == 2
			self.trading_prefer_different_potion	= self.trading_prefer_potion == 3
			self.trading_prefer_grenade				= get(me.SETTINGS.TRADING_PREFER_GRENADE)	-- option 0 = no prefernece
			self.trading_prefer_frag				= self.trading_prefer_grenade == 1
			self.trading_prefer_fire				= self.trading_prefer_grenade == 2
			self.trading_prefer_different_grenade	= self.trading_prefer_grenade == 3
			self.trading_prefer_max_distance		= get(me.SETTINGS.TRADING_PREFER_MAX_DISTANCE) or 20
			self.small_ammo_needs_forcing			= get(me.SETTINGS.SMALL_AMMO_NEEDS_FORCING)
			
			-- mission defence setting uses hotkey toggle that is updated in different manner
			self.defend_objectives_key			= get(me.SETTINGS.DEFEND_MISSION_OBJECTIVES_TOGGLE_KEY) or "numpad 4"
			self.defend_objectives_key_enabled	= get(me.SETTINGS.DEFEND_MISSION_OBJECTIVES_TOGGLE_KEY_ENABLE)
			if self.defend_objectives == nil or not self.defend_objectives_key_enabled then
				self.defend_objectives = get(me.SETTINGS.DEFEND_MISSION_OBJECTIVES)
			end
			if self.defend_objectives_key_enabled and get_hotkey_state(self.defend_objectives_key) then
				if not self.key_save.defend_objectives_key then
					self.defend_objectives = not self.defend_objectives
					EchoConsole((self.defend_objectives and "Objective defense ON") or "Objective defense OFF")
					self.key_save.defend_objectives_key = true
				end
			else
				self.key_save.defend_objectives_key = false
			end
			
			local melee_cap = get(me.SETTINGS.CAP_SLIDERS_MELEE) or 100
			self.cap_melee = melee_cap / 100
			
			local ranged_cap = get(me.SETTINGS.CAP_SLIDERS_RANGED) or 100
			self.cap_ranged = ranged_cap / 100
			
			local specials_cap = get(me.SETTINGS.CAP_SLIDERS_SPECIALS) or 100
			self.cap_specials = specials_cap / 100
			
			self.ignore_specials_pings = get(me.SETTINGS.IGNORE_SPECIALS_PINGS)
			self.reduce_ambient_shooting = get(me.SETTINGS.REDUCE_AMBIENT_SHOOTING)
			
			
			return
		end,
	},
	
	scaler_data = 
	{
		init_token = true,
		
		init_value_human = 200,
		init_value_bot = 220,
		taken_final_scaling = 0.9,
		taken_drain_tick_strength = 0.6,
		next_taken_drain_tick = 0,
		next_offense_token_tick = 0,
		
		damage_taken_buffer_debt_leak_factor = 0.333,
		damage_taken_human_bot_ratio = 1.1,
		damage_taken_boss_factor = 0.666,
		damage_taken_buffer = 0,
		damage_taken_buffer_size = 37.5 * 1.0,
		damage_taken_debt = 0,				-- init at level start
		damage_taken_debt_buffer = 0,
		damage_taken_debt_cumulative = 0,
		damage_taken_debt_trasfer_factor = 1/30,
		damage_taken_debt_trasfer_min = 0.1,	-- init at level start
		damage_taken_debt_trasfer_max = 2.5,	-- init at level start
		damage_taken_debt_trasfer_next_tick = 0,
		damage_taken_bot_average = 0,
		damage_taken_human_average = 0,
		damage_taken_token_available = 1,		-- init at level start
		damage_taken_token_table = {},
		damage_taken_roll_count = 0,
		damage_taken_last_check = 0,
		
		stagger_weight = 0.7,
		stagger_bot_push_weight = 0.15,
		damage_weight = 1.667,
		grenade_damage_weight = 0.833,
		kill_weight = 0,
		
		offense_token_tick = 0.333,
		offense_token_tick_objective = 5,
		offense_tokens = 0,
		offense_token_passive_cap = 100,
		offense_token_passive_cap_objective = 175,
		offense_ranged_range = 20,
		offense_max_delay_ranged = 1.5,
		offense_ranged_scaling_start = 50,
		offense_ranged_scaling_stop = 300,
		offense_time_pool = 0,
		offense_time_pool_timer = 0,
		
		bot_specials_balance = 0,
		bot_specials_balance_effective_max = 5,
		bot_specials_balance_effective_min = 0,
		specials_pinged_by_human = {},		-- unit keyed list of special enemies pinged by humans
		specials_damaged_by_human = {},		-- unit keyed list of special enemies damaged by humans
		specials_release_denied = {},		-- unit keyed list of release denial times for disabling special enemies
		
		is_allowed_to_release_from_disabler = function(self, disabler_unit)
			if disabler_unit and Unit.alive(disabler_unit) and self.specials_release_denied[disabler_unit] then
				local current_time						= Managers.time:time("game")
				local ping_extension					= ScriptUnit.has_extension(disabler_unit, "ping_system")
				local enemy_is_pinged					= (ping_extension and ping_extension._pinged) or false
				local enemy_has_been_pinged				= self.specials_pinged_by_human[disabler_unit]
				local enemy_has_been_damaged_by_human	= self.specials_damaged_by_human[disabler_unit]
				local release_allowed					= current_time >= self.specials_release_denied[disabler_unit] or enemy_has_been_pinged or enemy_is_pinged or enemy_has_been_damaged_by_human
				
				return release_allowed
			end
			
			return true
		end,
		
		add_offense_tokens = function(self, amount)
			local bot_count, human_count, bot_list, human_list = get_able_bot_human_data()
			local passive_cap = self.offense_token_passive_cap * self:get_difficulty_modifier_life()
			local ranged_threshold_tokens = 0.8 * (self.offense_ranged_scaling_stop - self.offense_ranged_scaling_start) + self.offense_ranged_scaling_start
			
			if bot_count > 0 then
				self.offense_tokens = math.min(self.offense_tokens + amount, passive_cap * 10)
			elseif self.offense_tokens < math.max(passive_cap * 2, ranged_threshold_tokens) then
				self.offense_tokens = self.offense_tokens + amount
			end
		end,
		
		use_offense_tokens = function(self, amount)
			self.offense_tokens = math.max(self.offense_tokens - amount, 0)
		end,
		
		carry_objective_levels = 
		{
			farm				= {template_name = "sack"},						-- wheat & chaff
			bridge				= {template_name = "explosive_barrel"},			-- black powder
			magnus				= {template_name = "explosive_barrel"},			-- horn of magnus
			merchant			= {template_name = "sack"},						-- supply & demand
			dlc_castle			= {template_name = "drachenfels_statue"},		-- castle drachenfels
			dlc_dwarf_interior	= {template_name = "dwarf_explosive_barrel"},	-- khazid kro
			-- example_level_id = 		-- example
			-- {
				-- template_name = "example_item_template_name",	-- weapon_template.name
				-- area = -- optional
				-- {
					-- new_area_check_box(Vector3(x1,y1,z1), Vector3(x2,y2,z2)),	-- example area
					-- new_area_check_sphere(Vector3(x,y,z), radius),				-- example area
				-- },
			-- },
		},
		
		offense_token_tick_boost_end_time = 0,
		offense_token_tick_boost_enabled = function(self)
			local level_id = LevelHelper:current_level_settings().level_id
			local level_settings = self.carry_objective_levels[level_id]
			
			local ret = false
			if level_settings then
				local humans = Managers.player:human_players()
				local human_positions = {}
				for _,loop_owner in pairs(humans) do
					local loop_unit = loop_owner.player_unit
					local loop_status_extension = ScriptUnit.has_extension(loop_unit, "status_system")
					local loop_is_disabled = loop_status_extension and loop_status_extension:is_disabled()
					if not loop_is_disabled then
						local _, __, loop_weapon_template = get_equipped_weapon_info(loop_unit)
						if loop_weapon_template and loop_weapon_template.name == level_settings.template_name then
							human_positions[loop_unit] = POSITION_LOOKUP[loop_unit] or Vector3(0,0,0)
						end
					end
				end
				
				for _,loop_position in pairs(human_positions) do
					if level_settings.area then
						for __,area_data in pairs(level_settings.area) do
							if area_data:in_area(loop_position) then
								ret = true
								break
							end
						end
					else
						ret = true
					end
					
					if ret then break end
				end
			end
			
			return ret
		end,
		
		difficulty_damage = 
		{
			easy				= 0.107,	--				4		>> 0.107
			normal				= 0.16,		--				6		>> 0.16
			hard				= 0.32,		--				12		>> 0.32
			harder				= 0.667,	-- nightmare	25		>> 0.667
			hardest				= 1,		-- cataclysm	37,5	>> 1
			survival_hard		= 0.32,		-- veteran		12		>> 0.32
			survival_harder		= 0.667,	-- champion		25		>> 0.667
			survival_hardest	= 1.5,		-- heroic		56,25	>> 1.5
		},
		
		difficulty_life = 
		{
			easy				= 0.343,	-- easy			12/35		>> 0.343
			normal				= 0.414,	-- normal		14.5/35		>> 0.414
			hard				= 0.514,	-- hard			18/35		>> 0.514
			harder				= 0.657,	-- nightmare	23/35		>> 0.657
			hardest				= 1,		-- cataclysm	35/35		>> 1
			survival_hard		= 0.514,	-- veteran		18/35		>> 0.514
			survival_harder		= 0.657,	-- champion		23/35		>> 0.657
			survival_hardest	= 1,		-- heroic		35/35		>> 1
		},
		
		specials_lookup = 
		{
			human_count_factor =
			{
				1,		-- not really used
				1.75,
				1,
				0.6,
				1,		-- not really used
			},
			assist_multiplier = 0.5,
			balance_settings =
			{
				{
					vision_index			= 0,
					vision_distance			= 50,
					must_have_dealt_damage	= false,
				},
				{
					vision_index			= 3,
					vision_distance			= 50,
					must_have_dealt_damage	= false,
				},
				{
					vision_index			= 3,
					vision_distance			= 30,
					must_have_dealt_damage	= false,
				},
				{
					vision_index			= 3,
					vision_distance			= 18,
					must_have_dealt_damage	= false,
				},
				{
					vision_index			= 3,
					vision_distance			= 11,
					must_have_dealt_damage	= false,
				},
				{
					vision_index			= 3,
					vision_distance			= 11,
					must_have_dealt_damage	= true,
				},
			},
			release_settings = 
			{
				default				= {minimum = 0, maximum = 2,},
				easy				= {minimum = 0, maximum = 2,},
				normal				= {minimum = 0, maximum = 2,},
				hard				= {minimum = 0, maximum = 2,},
				harder				= {minimum = 0, maximum = 2,},
				hardest				= {minimum = 0, maximum = 1,},
				survival_hard		= {minimum = 0, maximum = 2,},
				survival_harder		= {minimum = 0, maximum = 2,},
				survival_hardest	= {minimum = 0, maximum = 1,},
				specials_release_delay_threshold_min = 0.25,	-- ally hp% at which (and below) the bots use minimum delay when releasing disabled allies from specials
				specials_release_delay_threshold_max = 1,		-- ally hp% at which (and above) the bots use maximum delay when releasing disabled allies from specials
			},
			has_dealt_damage = {},
			initiative = {},
		},
		
		get_specials_release_delay = function(self, ally_unit)
			if not Unit.alive(ally_unit) then
				return 0
			end
			
			local ally_owner			= Managers.player:unit_owner(ally_unit)
			local ally_is_bot			= ally_owner and ally_owner.bot_player
			local current_difficulty	= Managers.state.difficulty.difficulty
			local release_settings		= self.specials_lookup.release_settings
			local release_delays		= release_settings[current_difficulty] or release_settings.default
			local delay_min				= release_delays.minimum
			local delay_max				= release_delays.maximum
			local threshold_min			= release_settings.specials_release_delay_threshold_min
			local threshold_max			= release_settings.specials_release_delay_threshold_max
			local ally_hp				= get_bot_current_health_percent(ally_unit)
			local clamped_hp			= math.clamp(ally_hp, threshold_min, threshold_max)
			local delay_factor			= (clamped_hp - threshold_min) / (threshold_max - threshold_min)
			local delay_scaled			= delay_min + delay_factor * (delay_max - delay_min)
			
			-- apply performance based scaling
			local cap_specials			= (get(me.SETTINGS.CAP_SLIDERS_SPECIALS) or 100) / 100
			local specials_balance_max	= self.bot_specials_balance_effective_max
			local specials_balance_min	= self.bot_specials_balance_effective_min
			local clamp_max				= specials_balance_max
			local clamp_min				= specials_balance_min + ((specials_balance_max - specials_balance_min) * (1 - cap_specials))
			local clamped_balance		= math.clamp(self.bot_specials_balance, clamp_min, clamp_max)
			local specials_performance	= (clamped_balance - clamp_min) / (clamp_max - clamp_min)	-- 0 = full performance, 1 = worst performance
			local performance_factor	= (ally_is_bot and 0.5) or 0.5 + (0.5 * specials_performance)
			
			delay_scaled				= delay_scaled * performance_factor
			
			return delay_scaled
		end,
		
		get_difficulty_modifier_life = function(self)
			local current_difficulty = Managers.state.difficulty.difficulty
			local difficulty_scaler = self.difficulty_life[current_difficulty] or 0.514
			return difficulty_scaler
		end,
		
		get_difficulty_modifier_damage = function(self)
			local current_difficulty = Managers.state.difficulty.difficulty
			local difficulty_scaler = self.difficulty_damage[current_difficulty] or 0.514
			return difficulty_scaler
		end,
		
	},
	melee = 
	{
		engage_distance = 
		{
			default = 14,
			
			skaven_clan_rat = 5,
			skaven_slave = 5,
			
			skaven_storm_vermin_commander = 5,
			skaven_storm_vermin = 5,
			
			skaven_pack_master = 14,
			skaven_poison_wind_globadier = 14,
			skaven_ratling_gunner = 14,
			skaven_gutter_runner = 14,
			
			skaven_storm_vermin_champion = 14,
			skaven_rat_ogre = 14,
			
		},
	},
	forced_regroup = 
	{
		--edit--
		toggle_threshold = 1,	--1.5	--2		--1
		distance = 14,	--16	--14	--7
		distance_reduced = 5.5,		--7		--5.5
		distance_with_human = 10,	--14	--10
		distance_with_boss = 21,
		nearby_human_check_distance = 7,	--14	--7
		nearby_boss_check_distance = 14,
		--edit--
	},
	trading = 
	{
		active_trades =
		{
			can_accept_heal_item = {},
			can_accept_potion = {},
			can_accept_grenade = {},
		},
		wasjusttraded = {},
		last_grenade_given_to_bots = "",
		last_potion_given_to_bots = "",
		last_trade_time = -3,
	},
	ammo_threshold = 
	{
		--edit--
		-- default = 0.5,
		default = 0.65,
		--edit--
		special = 0,
	},
	heat_threshold = 
	{
		--edit--
		-- default = 0.5,
		default = 0.65,
		--edit--
		special = 0.9,
		vent_threshold_factor = 0.3,
		passive_threshold_factor = 0.85,
	},
	default =
	{
		melee_range =
		{
			default = 12,
		},
		immediate_threat_range = 7,
	},
	skaven_rat_ogre = 
	{
		--edit--
		melee_range =
		{
			default = 6,
			reduced = 4.5,	--4,		--2.5,	-- when flanking
			condition = "flanking",
		},
		--edit--
	},
	skaven_storm_vermin_champion = 
	{
		melee_range =
		{
			default = 6,
		},
	},
	skaven_gutter_runner = 
	{
		melee_range =
		{
			--edit--
			default = 2,
			-- default = 3,
			--edit--
		},
		immediate_threat_range = 14,
		immediate_threat_range_pinged = 25,
	},
	skaven_pack_master = 
	{
		melee_range =
		{
			--edit--
			default = 2,
			-- default = 3,
			--edit--
			reduced = -1,	-- when packmaster is near
			condition = "too_close",
			condition_range = 7,
		},
		immediate_threat_range = 12,	--10	--14
		immediate_threat_range_pinged = 18,		--15	--25
	},
	skaven_poison_wind_globadier = 
	{
		melee_range =
		{
			--edit--
			default = 2,
			-- default = 3,
			--edit--
		},
		immediate_threat_range = 14,
		immediate_threat_range_pinged = 40,
	},
	skaven_ratling_gunner = 
	{
		melee_range =
		{
			--edit--
			default = 2,
			-- default = 3,
			--edit--
		},
		immediate_threat_range = 14,
		immediate_threat_range_pinged = 20,		--25
	},
	skaven_storm_vermin = 
	{
		melee_range =
		{
			default = 5,
			--edit--
			reduced = 3,
			-- reduced = 4,
			--edit--
			condition = "no_aoe_threat",
		},
	},
	skaven_storm_vermin_commander = 
	{
		melee_range =
		{
			default = 5,
			--edit--
			reduced = 3,
			-- reduced = 4,
			--edit--
			condition = "no_aoe_threat",
		},
	},
	skaven_clan_rat = 
	{
		melee_range =
		{
			--edit--
			-- default = 5,
			reduced = 4,
			default = 7,
			-- reduced = 3,
			--edit--
			condition = "no_aoe_threat",
		},
	},
	skaven_slave = 
	{
		melee_range =
		{
			--edit--
			-- default = 5,
			reduced = 4,
			default = 6,
			-- reduced = 3,
			--edit--
			condition = "no_aoe_threat",
		},
	},
	skaven_loot_rat = 
	{
		melee_range =
		{
			default = 5,
			--edit--
			reduced = 4,
			-- reduced = 3,
			--edit--
			condition = "no_aoe_threat",
		},
	},
	skaven_grey_seer = 
	{
		melee_range =
		{
			default = 12,
		},
	},
	dodge = 
	{
		recalculate_time = 0.2		--0.125
	},
}

-- create default dynamic data
local d_data_create_default = function(owner)
	local d = {}
	
	d.fresh = false
	
	d.sniper_ranged = -- sniper ammo is reserved for non-trash units
	{
		es_handgun		= true,
		-- ww_longbow		= true,
		ww_trueflight	= true,
		-- bw_staff_beam	= true,
		dr_crossbow		= true,
		dr_handgun		= true,
		wh_crossbow		= true,
		-- bw_staff_spear = true,
	}
	
	d.anti_armor_melee = -- anti-armor weapons should prioritize stormvermin higher
	{
		es_2h_war_hammer	= true,
		dr_2h_hammer		= true,
		dr_1h_axes			= true,
		dr_2h_axes			= true,
		dr_2h_picks			= true,
		dr_1h_axe_shield	= true,
		ww_2h_axe			= true,
		wh_1h_axes			= true,
	}
	
	d.unit								= owner.player_unit
	d.owner								= owner
	d.name								= owner.character_name
	d.current_time						= Managers.time:time("game")
	d.current_hitpoint_percentage		= 1
	d.position							= false
	d.disabled							= false	-- true if this bot is disabled
	d.overheated						= false
	d.keep_last_stormvermin_alive		= false
	d.melee_attack_allowed				= true	-- if false the bot is not allowed to attack with melee
	d.ranged_attack_allowed				= true	-- if false the bot is not allowed to attack with ranged
	d.reduced_ambient_shooting			= false	-- if true, the bot should try to avoid shooting ambient enemies
	d.last_ranged_kill					= 0		-- time when the bot did its last ranged kill
	d.take_damage_cooldown				= 0		-- time before which the bot is not allowed to intentionally take in damage
	d.teleport_allowed_timer_duration	= 6
	d.teleport_allowed_timer			= 0
	d.teleport_allowed					= false
	d.follow_target						= false	-- follow target's unit id
	d.follow_target_position			= false	-- follow target's position
	d.extensions_ready					= false	-- true if all extension data hae been loaded (for the d.unit)
	d.melee_reach_tracker				= 0
	d.vent_allowed						= false
	d.vent_hp_threshold					= 0.5
	d.vent_heat_threshold				= 2
	d.vent_cooldown						= 0
	d.using_melee						= true
	d.using_ranged						= false
	d.has_enough_ammo					= false
	d.is_venting						= false
	d.enough_hp_to_vent					= false	
	d.warded_krench_as_target			= false
	d.ranged_not_yet_wielded			= true	-- init to true on creation to workaround a bug that causes bots not to get some weapon buffs after spawning
	
	d.unstuck_data = {}
	d.unstuck_data.is_stuck				= false
	d.unstuck_data.last_update			= false
	d.unstuck_data.last_attack			= false
	d.unstuck_data.last_position		= false
	
	d.offense_scaler_melee_multiplier	= 0
	d.offense_scaler_ranged_multiplier	= 0
	
	d.settings = {}
	d.settings.bot_file_enabled					= false	-- false = all bot improvements are disabled
	d.settings.manual_heal						= false
	d.settings.better_melee						= false
	d.settings.better_ranged					= false
	d.settings.keep_tomes						= false
	d.settings.pickup_tomes						= false
	d.settings.pickup_grims						= false
	d.settings.force_loot_key					= false
	d.settings.force_loot						= false
	d.settings.hp_based_loot_pinged_heal		= false
	d.settings.hp_based_health_weight			= 3
	d.settings.hp_based_wounded_weight			= 3
	d.settings.hp_based_grim_weight				= 3
	d.settings.bot_to_avoid						= false
	d.settings.ignore_ratling_fire				= false
	d.settings.no_chase_ratlings				= false
	d.settings.no_chase_globadiers				= false
	d.settings.always_follow_host				= false
	d.settings.snipers_shoot_trash				= false
	d.settings.ping_stormvermin					= false
	d.settings.defend_objectives				= nil
	d.settings.defend_objectives_key			= false
	d.settings.defend_objectives_key_enabled	= false
	-- d.settings.aggressive_melee					= true
	d.settings.info_guard_break					= false
	d.settings.info_guard_break_global_message	= false
	d.settings.trading_prefer_enable			= false
	d.settings.trading_prefer_strength			= false
	d.settings.trading_prefer_speed				= false
	d.settings.trading_prefer_different_potion	= false
	d.settings.trading_prefer_frag				= false
	d.settings.trading_prefer_fire				= false
	d.settings.trading_prefer_different_grenade	= false
	d.settings.trading_prefer_max_distance		= math.huge
	d.settings.small_ammo_needs_forcing			= false
	
	d.extensions = {}
	d.extensions.status				= false
	d.extensions.inventory			= false
	d.extensions.buff				= false
	d.extensions.input				= false
	d.extensions.overcharge			= false
	
	d.equipped = {}
	d.equipped.melee				= false
	d.equipped.melee_weapon_template	= false
	d.equipped.melee_chain_position	= 0
	d.equipped.melee_chain_state	= "none"
	d.equipped.anti_armor			= false
	d.equipped.ranged				= false
	d.equipped.sniper				= false
	d.equipped.heat_weapon			= false
	d.equipped.ranged_can_reload	= false
	d.equipped.ranged_ammo			= false
	d.equipped.weapon_unit			= false
	d.equipped.weapon_id			= false
	d.equipped.weapon_template		= false
	d.equipped.weapon_extension		= false
	d.equipped.dodge_distance		= 2
	
	d.equipped.heat_amount				= 0
	d.equipped.heat_threshold			= 0
	d.equipped.heat_max					= 0
	d.equipped.ranged_weapon_template	= false
	d.equipped.ranged_weapon_extension	= false
	d.equipped.melee_weapon_extension	= false
	
	d.enemies = {}
	d.enemies.push				= {}	-- unit array of push range enemies
	d.enemies.melee				= {}	-- unit array of close range enemies, 3.5u
	d.enemies.near				= {}	-- unit array of close range enemies, 5u
	d.enemies.medium			= {}	-- unit array of medium range enemies, 7u
	d.enemies.far				= {}	-- unit array of long range enemies, 20u
	d.enemies.bosses			= {}	-- unit array of all alive bosses
	d.enemies.specials			= {}	-- unit array of all alive specials
	d.enemies.melee_control_arc = {}	-- units in the bot's control weapon's control arc
	d.enemies.medium_sv			= {}	-- Vernon: added data
	d.enemies.closest_boss_distance = math.huge	-- Vernon: added data
	
	d.defense = {}
	d.defense.krench_extension		= 0
	d.defense.awareness = {}
	d.defense.awareness.attacks		= {}
	d.defense.awareness.cleaned		= d.current_time
	d.defense.current_stamina		= false -- 0..x indicates amount of stamina the bot has left, 2 stamina = 1 shield in the UI
	d.defense.dodge_count_left		= 2		-- Vernon: 2 is the default for weapon templates
	d.defense.is_dodging			= false	-- Vernon: added data
	d.defense.can_dodge				= true	-- Vernon: added data
	d.defense.on_ground				= true	-- Vernon: added data
	d.defense.last_calculate_dodge_time = nil
	d.defense.need_dodge_direction_fix = false
	
	d.defense.closest_able_ally_distance	= math.huge	-- Vernon: added data
	d.defense.closest_human_distance = math.huge	-- Vernon: added data
	d.defense.closest_bot_distance	= math.huge	-- Vernon: added data
	
	-- d.defense.attacking_stormvermin	= {}	-- Vernon: added data
	-- d.defense.attacking_stormvermin_uninterruptible	= {}	-- Vernon: added data
	d.defense.threat_stormvermin	= {} -- array of threatening stormvermin around the bot
	-- d.defense.threat_stormvermin_uninterruptible = {}	-- Vernon: added data
	-- d.defense.attacking_stormvermin_general	= {}	-- Vernon: added data
	-- d.defense.attacking_stormvermin_general_uninterruptible	= {}	-- Vernon: added data
	d.defense.threat_sv_general = {}	-- Vernon: added data
	d.defense.threat_sv_general_uninterruptible = {}	-- Vernon: added data
	-- d.defense.is_sv_push_target		= false
	d.defense.must_push_gutter		= false -- true is the bot can interrupt stabbing gutter with push
	d.defense.assassin_on_field		= false
	
	d.defense.threat_boss			= {}	-- array of threatening bosses around the bot
	d.defense.threat_boss_unblockable = {}	-- Vernon: added data
	d.defense.attacking_trash		= {}	-- Vernon: added data
	d.defense.threat_trash			= {}	-- array of threatening trash rats around the bot
	d.defense.attacking_trash_general = {}	-- Vernon: added data
	d.defense.threat_trash_general	= {}	-- array of rats threatening any player around the bot (within the bot's push range)
	d.defense.threat_running_attack = false -- true if there is a threat from a thrash rat's running attack
	
	d.defense.attacking_sv_overhead				= {}
	d.defense.attacking_sv_sweep				= {}
	-- d.defense.threat_stormvermin				= {}
	d.defense.threat_sv_overhead				= {}
	d.defense.threat_sv_sweep					= {}
	d.defense.threat_sv_push					= {}
	d.defense.threat_sv_overhead_in_push_range	= false
	d.defense.threat_sv_sweep_in_push_range		= false
	d.defense.threat_sv_push_in_push_range		= false
	
	d.defense.is_boss_target		= false	-- Vernon: added data
	d.defense.in_front_of_boss		= false	-- Vernon: added data
	d.defense.need_to_dodge_packmaster = false	-- Vernon: added data
	d.defense.need_to_dodge_assassin = false	-- Vernon: added data
	d.defense.process_push_jumping_assassin = false	-- Vernon: added data
	d.defense.jumping_assassin_distance = math.huge	-- Vernon: added data
	d.defense.distance_to_assassin_flight_path = math.huge	-- Vernon: added data
	
	d.defense.pos_trash_to_dodge = nil	-- Vernon: added data
	d.defense.pos_fast_trash_to_dodge = nil	-- Vernon: added data
	d.defense.pos_sv_sweep_to_dodge = nil	-- Vernon: added data
	d.defense.pos_sv_overhead_to_dodge = nil	-- Vernon: added data
	d.defense.pos_ogre_to_dodge = nil	-- Vernon: added data
	d.defense.pos_packmaster_to_dodge = nil	-- Vernon: added data
	d.defense.pos_assassin_to_dodge = nil	-- Vernon: added data
	
	d.defense.pos_threat_to_side_dodge = nil	-- Vernon: added data
	d.defense.pos_threat_to_back_dodge = nil	-- Vernon: added data
	
	d.objective_defence =
	{
		enabled			= false,	-- true if objective defence is currently active
		position		= false,	-- position of the objective defence target
		bot_positions	= false,	-- array of bot stand positions around the defense objective
	}
	
	d.regroup = {}
	d.regroup.enabled				= false	-- true if forced regroup is active and the bot must return to the regroup anchor
	d.regroup.position				= false	-- Vector3 position of the forced regroup anchor
	d.regroup.distance				= false	-- distance between the bot location and the regroup position
	d.regroup.distance_threshold	= false	-- current distance threshold for forced regroup
	
	d.melee = {}
	d.melee.target_unit						= false -- unit id for the melee target unit
	d.melee.target_position					= false -- Vector3 position of the melee target unit
	d.melee.target_offset					= false -- Vector3 form self >> target
	d.melee.target_distance					= false -- Vector3.length of target_offset
	d.melee.target_breed					= false -- breed id of the target enemy
	d.melee.aim_position					= false -- Vector3 position of the target unit's node the bot targets
	d.melee.is_aiming						= false -- true if the bot should aim at its current target
	d.melee.may_engage						= false -- true if the bot should actively engage its current target
	d.melee.has_line_of_sight				= false -- true if the bot has line of sight to its ranged target
	d.melee.threats_outside_control_angle	= false	-- true if there are rat threats outsid the arc the bot's control weapon can manage
	
	d.heal = {}
	d.heal.target_unit			= false
	
	d.token = {}
	d.token.jump				= false
	d.token.dodge				= false
	d.token.push				= false
	d.token.block				= false
	d.token.block_override		= false
	d.token.melee_light			= false
	d.token.melee_heavy			= false
	d.token.melee_expire		= 0
	d.token.ranged_light		= false
	d.token.ranged_heavy		= false
	d.token.ranged_vent			= false
	d.token.take_damage			= false
	d.token.heal				= false
	
	d.stepping_fix = {}
	d.stepping_fix.old_velocity			= Vector3Box(Vector3(1,0,0))
	d.stepping_fix.old_position			= Vector3Box(Vector3(0,0,0))
	d.stepping_fix.turn_counter			= 0
	d.stepping_fix.turn_counter2		= 0
	d.stepping_fix.turn_counter_timer	= 0
	d.stepping_fix.is_stepping_timer	= 0
	
	d.items =
	{
		tome			= false,
		medkit			= false,
		draught			= false,
		
		grim			= false,
		speed_potion	= false,
		strength_potion	= false,
		
		fire_grenade	= false,
		frag_grenade	= false,
	}
	
	d.get_custom_hp_weight = function(self)
		local status_extension	= self.extensions.status
		local hp				= self.current_hitpoint_percentage
		local wounded			= (status_extension and not status_extension:has_wounds_remaining() and 1) or 0
		local grim				= (self.items.grim and 1) or 0
		local hp_weight			= self.settings.hp_based_health_weight
		local wounded_weight	= self.settings.hp_based_wounded_weight
		local grim_weight		= self.settings.hp_based_grim_weight
		
		return hp*hp_weight + (1-wounded)*wounded_weight + (1-grim)*grim_weight
	end
	
	d.key_save = 
	{
		defend_objectives_key = false,
	}
	
	owner.d_data = d
	
	return
end

local d_data_update = function(d)
	
	-- update the freshness check
	d.fresh = Vector3(0,0,0)
	
	-- check if the current stored unit is still valid
	local unit_is_valid = false
	for _, loop_owner in pairs(Managers.player:bots()) do
		if loop_owner.player_unit == d.unit then
			unit_is_valid = true
		end
	end
	
	if d.owner.player_unit ~= d.unit then
		unit_is_valid = false
	end
	
	-- When bot dies / despawns, the d.unit becomes invalid and needs to be re-aquired
	if not Unit.alive(d.unit) or not unit_is_valid then
		d.unit					= d.owner.player_unit	-- unit needs refresh
		d.name					= d.owner.character_name
		d.extensions_ready		= false		-- extensions need refresh
		d.extensions.status		= false
		d.extensions.inventory	= false
		d.extensions.buff		= false
		d.extensions.input		= false
		d.extensions.overcharge	= false
		d.token.block_override	= false
	end
	
	-- some general updates
	local local_player_unit = (Managers.player and Managers.player:local_player() and Managers.player:local_player().player_unit) or d.unit
	local local_player_status_extension = ScriptUnit.has_extension(local_player_unit, "status_system")
	local local_player_disabled = local_player_status_extension and local_player_status_extension:is_disabled()
	
	local blackboard				= Unit.get_data(d.unit, "blackboard")
	if not blackboard then
		return
	end
	
	d.current_time					= Managers.time:time("game")
	d.current_hitpoint_percentage	= get_bot_current_health_percent(d.unit)
	d.position						= POSITION_LOOKUP[d.unit]
	d.follow_target					= (d.settings.always_follow_host and not local_player_disabled and local_player_unit) or blackboard.ai_bot_group_extension.data.follow_unit
	d.follow_target_position		= (d.follow_target and POSITION_LOOKUP[d.follow_target]) or d.position
	
	-- update extensions as needed
	if not d.extensions_ready then
		d.extensions.status				= ScriptUnit.has_extension(d.unit, "status_system")
		d.extensions.inventory			= ScriptUnit.has_extension(d.unit, "inventory_system")
		d.extensions.buff				= ScriptUnit.has_extension(d.unit, "buff_system")
		d.extensions.input				= ScriptUnit.has_extension(d.unit, "input_system")
		d.extensions_ready				= (d.extensions.status and d.extensions.inventory and d.extensions.buff and d.extensions.input and true) or false
	end
	
	-- update extension dependent data
	local wounded = false
	if d.extensions_ready then
		d.disabled = d.extensions.status:is_disabled()
		local catapulted = d.extensions.status.catapulted
		local pushed = d.extensions.status.pushed
		
		if d.teleport_allowed_timer == nil then d.teleport_allowed_timer = 0 end
		if d.disabled or pushed or catapulted then
			d.teleport_allowed_timer = d.current_time + d.teleport_allowed_timer_duration
			d.teleport_allowed = false
		elseif d.current_time > d.teleport_allowed_timer then
			d.teleport_allowed = true
		else
			d.teleport_allowed = false
		end
		
		wounded = d.extensions.status:is_wounded()
	else
		d.teleport_allowed = false
	end
	
	if not d.unstuck_data.last_update then
		d.unstuck_data.last_update		= d.current_time
		d.unstuck_data.last_attack		= d.current_time
		d.unstuck_data.last_position	= Vector3Box(d.position)
	end
	
	
	-- ***********************************************
	-- ** update equipped weapon information        **
	-- ***********************************************
	
	local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(d.unit)
	local equipped_slot	= (d.extensions.inventory and d.extensions.inventory:get_wielded_slot_name()) or false
	d.equipped.melee			= equipped_slot == "slot_melee"
	d.equipped.ranged			= equipped_slot == "slot_ranged"
	if d.equipped.melee then
		d.equipped.weapon_unit		= weapon_unit
		d.equipped.weapon_id		= weapon_type
		d.equipped.weapon_template	= weapon_template
		d.equipped.weapon_extension	= ScriptUnit.has_extension(weapon_unit, "weapon_system")
		d.equipped.anti_armor		= d.anti_armor_melee[weapon_type] or false
		d.equipped.ranged_ammo		= false
		--
		d.equipped.melee_weapon_template	= weapon_template
		d.equipped.melee_weapon_extension = ScriptUnit.has_extension(weapon_unit, "weapon_system")
		d.equipped.dodge_distance	= (weapon_template.dodge_distance and weapon_template.dodge_distance * 2) or 2
		--
	elseif d.equipped.ranged then
		d.equipped.weapon_unit			= weapon_unit
		d.equipped.weapon_id			= weapon_type
		d.equipped.weapon_template		= weapon_template
		d.equipped.weapon_extension		= ScriptUnit.has_extension(weapon_unit, "weapon_system")
		d.equipped.ranged_can_reload	= (d.equipped.weapon_extension.ammo_extension and d.equipped.weapon_extension.ammo_extension:can_reload()) or false
		d.equipped.sniper				= d.sniper_ranged[weapon_type] or false
		--
		d.equipped.ranged_weapon_template	= weapon_template
		d.equipped.ranged_weapon_extension	= ScriptUnit.has_extension(weapon_unit, "weapon_system")
		d.equipped.dodge_distance	= (weapon_template.dodge_distance and weapon_template.dodge_distance * 2) or 2
		--
	else
		d.equipped.weapon_unit		= false
		d.equipped.weapon_id		= false
		d.equipped.weapon_template	= false
		d.equipped.weapon_extension	= false
		d.equipped.dodge_distance	= (weapon_template.dodge_distance and weapon_template.dodge_distance * 2) or 2
	end
	
	d.equipped.ranged_ammo	= get_ammo_percentage(d.unit)
	if d.equipped.ranged_ammo >= 2 then
		d.equipped.heat_weapon	= true
		d.equipped.ranged_ammo	= d.equipped.ranged_ammo-2
	else
		d.equipped.heat_weapon	= false
	end
	
	d.equipped.heat_amount				= 0
	d.equipped.heat_threshold			= 0
	d.equipped.heat_max					= 0
	local predicted_vent_damage_tick	= 200
	if not d.extensions.inventory:has_ammo_consuming_weapon_equipped() then
		if not d.extensions.overcharge then
			local slot_data							= d.extensions.inventory:get_slot_data("slot_ranged")
			local right_hand_overcharge_extension	= ScriptUnit.has_extension(slot_data.right_unit_1p, "overcharge_system") and ScriptUnit.extension(slot_data.right_unit_1p, "overcharge_system")
			local left_hand_overcharge_extension	= ScriptUnit.has_extension(slot_data.left_unit_1p, "overcharge_system") and ScriptUnit.extension(slot_data.left_unit_1p, "overcharge_system")
			d.extensions.overcharge					= right_hand_overcharge_extension or left_hand_overcharge_extension or false
		end
		
		if d.extensions.overcharge then
			d.equipped.heat_amount			= d.extensions.overcharge:get_overcharge_value()
			d.equipped.heat_threshold		= d.extensions.overcharge:get_overcharge_threshold()
			d.equipped.heat_max				= d.extensions.overcharge:get_max_value()
			if d.extensions.buff then
				local has_channeling_rune	= d.extensions.buff:has_buff_type("reduced_vent_damage")
				predicted_vent_damage_tick	=  2 + d.equipped.heat_amount / 8	-- formula taken from player_unit_overcharge_extension
				if has_channeling_rune then
					predicted_vent_damage_tick = d.extensions.buff:apply_buffs_to_value(predicted_vent_damage_tick, StatBuffIndex.REDUCED_VENT_DAMAGE)
				end
			end
		end
	end
	
	local health_extension		= ScriptUnit.has_extension(d.unit, "health_system")
	local max_hp				= (health_extension and health_extension.health) or 100
	local current_damage		= (health_extension and health_extension.damage) or 0
	local current_hp			= max_hp - current_damage
	local venting_threats_life	= (current_hp - predicted_vent_damage_tick) < 5
	
	d.enough_hp_to_vent					= d.vent_allowed and ((d.current_hitpoint_percentage > d.vent_hp_threshold and not venting_threats_life and not wounded) or d.equipped.heat_amount < d.equipped.heat_threshold)
	d.vent_allowed						= bot_settings.menu_settings.vent_allowed			-- bot won't vent if its not allowed
	d.vent_hp_threshold					= bot_settings.menu_settings.vent_hp_threshold		-- bot won't vent if its hp% is below this point
	d.vent_heat_threshold				= bot_settings.menu_settings.vent_heat_threshold	-- bot won't vent below this point
	
	
	-- ***********************************************
	-- ** update equipped items information         **
	-- ***********************************************
	
	if d.extensions.inventory then
		local carried_heal		= d.extensions.inventory:get_item_name("slot_healthkit")
		local carried_potion	= d.extensions.inventory:get_item_name("slot_potion")
		local carried_grenade	= d.extensions.inventory:get_item_name("slot_grenade")
		
		d.items.tome			= carried_heal == "wpn_side_objective_tome_01"
		d.items.medkit			= carried_heal == "healthkit_first_aid_kit_01"
		d.items.draught			= carried_heal == "potion_healing_draught_01"
		
		d.items.grim			= carried_potion == "wpn_grimoire_01"
		d.items.speed_potion	= carried_potion == "potion_speed_boost_01"
		d.items.strength_potion	= carried_potion == "potion_damage_boost_01"
		
		d.items.fire_grenade	= carried_grenade == "grenade_fire_01" or carried_grenade == "grenade_fire_02"
		d.items.frag_grenade	= carried_grenade == "grenade_frag_01" or carried_grenade == "grenade_frag_02"
	end
	
	-- ***********************************************
	-- ** update enemy lists                        **
	-- ***********************************************
	
	local filter_unit_list_by_distance = function(distance, unit_list)
		if unit_list == nil then
			unit_list = d.enemies.far
		end
		local validity_check = false
		if distance == nil then
			distance = math.huge
			validity_check = true
		end
		
		local ret = {}
		for _,loop_unit in pairs(unit_list) do
			local loop_position = POSITION_LOOKUP[loop_unit]
			local loop_bb		= Unit.get_data(loop_unit, "blackboard")
			local loop_breed	= Unit.get_data(loop_unit, "breed")
			local valid_target	= not validity_check or not (loop_breed.name == "skaven_clan_rat" or loop_breed.name == "skaven_slave") or (loop_bb.target_unit or loop_bb.attacking_target or loop_bb.special_attacking_target)
			if valid_target and Vector3.length(d.position - loop_position) < distance then
				table.insert(ret,loop_unit)
			end
		end
		
		return ret
	end
	
	local max_height_offset	= 3
	local far_radius		= bot_settings.trash_SV_detection_distance
	local medium_radius		= bot_settings.trash_SV_detection_distance * (7/20)
	local near_radius		= bot_settings.trash_SV_detection_distance * (5/20)
	local melee_radius		= bot_settings.trash_SV_detection_distance * (3.5/20)
	local push_radius		= (bot_settings.lookup.push_radius[d.equipped.weapon_id] or bot_settings.lookup.push_radius.default) + 0.5
	
	d.enemies.far		= get_proximite_enemies(d.unit, far_radius, max_height_offset)
	d.enemies.far		= filter_unit_list_by_distance()
	d.enemies.medium	= filter_unit_list_by_distance(medium_radius, d.enemies.far)
	d.enemies.near		= filter_unit_list_by_distance(near_radius, d.enemies.medium)
	d.enemies.melee		= filter_unit_list_by_distance(melee_radius, d.enemies.near)
	d.enemies.push		= filter_unit_list_by_distance(push_radius, d.enemies.near)
	d.enemies.bosses	= get_spawned_bosses()
	d.enemies.specials	= get_spawned_specials()
	d.enemies.medium_sv	= {}
	d.enemies.closest_boss_distance = math.huge
	
	-- ***********************************************
	-- ** identify immediate threats around the bot **
	-- ***********************************************
	
	-- clean the awareness table as needed
	if d.current_time - d.defense.awareness.cleaned > 5 then
		for key,_ in pairs(d.defense.awareness.attacks) do
			if not Unit.alive(key) then
				d.defense.awareness.attacks[key] = nil
			end
		end
		d.defense.awareness.cleaned = d.current_time
	end
	
	local current_fatigue, max_fatigue = d.extensions.status:current_fatigue_points()
	local aggressive_melee_exceptions = 
	{
		ww_2h_axe			= 0.2,
		dr_2h_axes			= 0.2,
		dr_1h_axe_shield	= 0.2,
		dr_1h_hammer_shield	= 0.2,
		dr_2h_hammer		= 0.2,
		es_1h_sword_shield	= 0.2,
		es_1h_mace_shield	= 0.2,
		es_2h_war_hammer	= 0.2,
	}
	local aggressive_melee_allowance = (d.equipped.weapon_id and aggressive_melee_exceptions[d.equipped.weapon_id]) or 0.6
	
	d.defense.current_stamina = max_fatigue - current_fatigue
	d.defense.dodge_count_left = d.extensions.status.dodge_count - d.extensions.status.dodge_cooldown
	d.defense.is_dodging = d.extensions.status:get_is_dodging()
	d.defense.can_dodge = d.extensions.status:can_dodge(d.current_time)
	d.defense.on_ground = true
	local locomotion_extension = ScriptUnit.extension(d.unit, "locomotion_system")
	if locomotion_extension then
		d.defense.on_ground = locomotion_extension:is_colliding_down()
	end
	
	d.defense.closest_able_ally_distance = math.huge
	for _, player in pairs(Managers.player:players()) do
		local loop_unit = player.player_unit
		-- local ally_is_bot	= player.bot_player
		-- local ally_is_human	= not ally_is_bot
		if loop_unit ~= d.unit then
			local status_extension = ScriptUnit.has_extension(loop_unit, "status_system")
			local enabled = status_extension and not status_extension:is_disabled()
			if enabled then
				local loop_position = POSITION_LOOKUP[loop_unit]
				local loop_distance = loop_position and Vector3.length(d.position - loop_position)
				if loop_distance and d.defense.closest_able_ally_distance and d.defense.closest_able_ally_distance < loop_distance then
					d.defense.closest_able_ally_distance = loop_distance
				end
			end
		end
	end
	
	d.defense.attacking_trash = {}
	d.defense.threat_trash = {}
	d.defense.attacking_trash_general = {}
	d.defense.threat_trash_general = {}
	
	d.defense.threat_stormvermin = {}
	d.defense.threat_sv_general = {}
	d.defense.threat_sv_general_uninterruptible = {}
	-- d.defense.is_sv_push_target = false
	
	d.defense.attacking_sv_overhead				= {}
	d.defense.attacking_sv_sweep				= {}
	d.defense.threat_sv_overhead				= {}
	d.defense.threat_sv_sweep					= {}
	d.defense.threat_sv_push					= {}
	d.defense.threat_sv_overhead_in_push_range	= false
	d.defense.threat_sv_sweep_in_push_range		= false
	d.defense.threat_sv_push_in_push_range		= false
	
	if (d.defense.must_push_gutter and d.current_time >= d.defense.must_push_gutter) or d.disabled then
		d.defense.must_push_gutter = false
	end
	d.defense.threat_boss = {}
	d.defense.threat_boss_unblockable = {}
	d.defense.in_front_of_boss = false
	d.defense.is_boss_target = false
	d.defense.threat_running_attack = false
	
	d.defense.pos_trash_to_dodge = nil
	d.defense.pos_fast_trash_to_dodge = nil
	d.defense.pos_sv_sweep_to_dodge = nil
	d.defense.pos_sv_overhead_to_dodge = nil
	d.defense.pos_ogre_to_dodge = nil
	
	local count_standing_trash_to_dodge = 0
	local count_fast_trash_to_dodge = 0		-- Vernon: running attack or sloped attack
	local count_sv_sweep_to_dodge = 0
	local count_sv_overhead_to_dodge = 0
	local count_ogre_to_dodge = 0
	
	for _,loop_unit in pairs(d.enemies.push) do
		local loop_breed = Unit.get_data(loop_unit, "breed")
		local loop_bb = Unit.get_data(loop_unit, "blackboard")
		if loop_breed.name == "skaven_slave" or loop_breed.name == "skaven_clan_rat" then
			-- if the trash rat is attacking against anything in general, add it to general threat list
			if loop_bb.attacking_target and not loop_bb.attack_finished and not loop_bb.attack_aborted then
				table.insert(d.defense.attacking_trash_general,loop_unit)
				if loop_bb.attack_anim == "attack_pounce" then
					-- standing attack
					if not d.defense.awareness.attacks[loop_unit] then
						d.defense.awareness.attacks[loop_unit] = d.current_time
					elseif d.current_time - d.defense.awareness.attacks[loop_unit] > aggressive_melee_allowance then
						table.insert(d.defense.threat_trash_general,loop_unit)
					end
				else
					table.insert(d.defense.threat_trash_general,loop_unit)
				end
			end
		-- Vernon: add SV general threat data
		elseif loop_breed.name == "skaven_storm_vermin_commander" or loop_breed.name == "skaven_storm_vermin" then
			if loop_bb.special_attacking_target or (loop_bb.attacking_target and not loop_bb.attack_finished and not loop_bb.attack_aborted) then
				local is_sv_overhead = loop_bb.action and loop_bb.action.name == "special_attack_cleave"
				local is_sv_sweep = loop_bb.action and loop_bb.action.name == "special_attack_sweep"
				local is_sv_push = not is_sv_overhead and not is_sv_sweep
				
				-- table.insert(d.defense.attacking_stormvermin_general,loop_unit)
				-- if is_sv_overhead or is_sv_push then
					-- table.insert(d.defense.attacking_stormvermin_general_uninterruptible,loop_unit)
				-- end
				
				if not d.defense.awareness.attacks[loop_unit] then
					d.defense.awareness.attacks[loop_unit] = d.current_time
				end
				
				local enemy_attack_duration = d.current_time - d.defense.awareness.attacks[loop_unit]
				
				if not is_sv_push and enemy_attack_duration > aggressive_melee_allowance then
					table.insert(d.defense.threat_sv_general,loop_unit)
					if is_sv_overhead or is_sv_push then
						table.insert(d.defense.threat_sv_general_uninterruptible,loop_unit)
					end
				end
				
				-- Vernon: include SV push attack as a threat so other bots can try to interrupt
				if is_sv_push then
					table.insert(d.defense.threat_sv_general,loop_unit)
					table.insert(d.defense.threat_sv_general_uninterruptible,loop_unit)
				end
			end
		elseif loop_breed.name == "skaven_gutter_runner" then
			-- gutter on top of its target (= stabbing its target)
			if	loop_bb.target_dist < 0.1 then
				if not bot_settings.scaler_data.specials_release_denied[loop_unit] then
					local denial_time = bot_settings.scaler_data:get_specials_release_delay(loop_bb.target_unit)
					bot_settings.scaler_data.specials_release_denied[loop_unit] = d.current_time + denial_time
				end
				local may_release_ally = bot_settings.scaler_data:is_allowed_to_release_from_disabler(loop_unit)
				
				if may_release_ally and not bot_settings.lookup.can_interrupt_gutter[d.equipped.weapon_id] and d.defense.current_stamina >= 1 then
					d.defense.must_push_gutter = d.current_time + 0.5
				end
			else
				d.defense.must_push_gutter = false
				bot_settings.scaler_data.specials_release_denied[loop_unit] = nil
			end
		end
	end
	
	for _,loop_unit in pairs(d.enemies.medium) do
		local loop_breed = Unit.get_data(loop_unit, "breed")
		local loop_bb = Unit.get_data(loop_unit, "blackboard")
		local loop_distance = Vector3.length(d.position - POSITION_LOOKUP[loop_unit])
		-- check the nearby trash rats for threats
		if loop_breed.name == "skaven_slave" or loop_breed.name == "skaven_clan_rat" then
			-- trash rats
			if (loop_bb.attacking_target == d.unit or loop_bb.special_attacking_target == d.unit) and not loop_bb.attack_finished and not loop_bb.attack_aborted then
				table.insert(d.defense.attacking_trash,loop_unit)
				if loop_bb.attack_anim == "attack_pounce" then
					-- standing attack
					if not d.defense.awareness.attacks[loop_unit] then
						d.defense.awareness.attacks[loop_unit] = d.current_time
					elseif d.current_time - d.defense.awareness.attacks[loop_unit] > aggressive_melee_allowance and DamageUtils.check_infront(loop_unit, d.unit) then
						table.insert(d.defense.threat_trash,loop_unit)
						
						d.defense.pos_trash_to_dodge = (d.defense.pos_trash_to_dodge and d.defense.pos_trash_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
						count_standing_trash_to_dodge = count_standing_trash_to_dodge + 1
					end
				elseif loop_bb.attack_anim == "attack_move" then
					-- running attack
					if loop_distance < 3.5 then	--3.75	--4		-- Vernon: the distance will determine the defense timing
						table.insert(d.defense.threat_trash,loop_unit)
						d.defense.threat_running_attack = true
						
						d.defense.pos_fast_trash_to_dodge = (d.defense.pos_fast_trash_to_dodge and d.defense.pos_fast_trash_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
						count_fast_trash_to_dodge = count_fast_trash_to_dodge + 1
					end
				elseif DamageUtils.check_infront(loop_unit, d.unit) then
					-- other attacks
					table.insert(d.defense.threat_trash,loop_unit)
					
					d.defense.pos_fast_trash_to_dodge = (d.defense.pos_fast_trash_to_dodge and d.defense.pos_fast_trash_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
					count_fast_trash_to_dodge = count_fast_trash_to_dodge + 1
				end
			else
				d.defense.awareness.attacks[loop_unit] = nil
			end
			--
		elseif loop_breed.name == "skaven_storm_vermin_commander" or loop_breed.name == "skaven_storm_vermin" then
			-- stormvermin
			-- Vernon: add medium range SV list
			table.insert(d.enemies.medium_sv,loop_unit)
			
			-- Vernon: when using d.defense.threat_stormvermin I am mainly thinking about sweeps and overheads, so I make the corresponding change
			if loop_bb.special_attacking_target or (loop_bb.attacking_target == d.unit and not loop_bb.attack_finished and not loop_bb.attack_aborted) then
				-- attacking_target for push, special_attacking_target for other attacks
				-- stormvermin use aoe attacks so any attack is a threat if bot is in threat area
				-- Vernon: push is single target
				local is_sv_overhead = loop_bb.action and loop_bb.action.name == "special_attack_cleave"
				local is_sv_sweep = loop_bb.action and loop_bb.action.name == "special_attack_sweep"
				local is_sv_push = not is_sv_overhead and not is_sv_sweep
				local in_front_angle = (is_sv_sweep and 100) or 60
				local loop_in_front, loop_flanking = check_alignment_to_target(d.unit, loop_unit, in_front_angle, 90)
				local threat_range = (is_sv_overhead and 5.5) or (is_sv_sweep and 3) or -1	--0
				
				if not d.defense.awareness.attacks[loop_unit] then
					d.defense.awareness.attacks[loop_unit] = d.current_time
				end
				
				local enemy_attack_duration = d.current_time - d.defense.awareness.attacks[loop_unit]
				
				-- Vernon: only consider the real SV attacks as threat
				if (is_sv_overhead or is_sv_sweep) and loop_in_front and loop_distance < threat_range then
					if is_sv_overhead then
						table.insert(d.defense.attacking_sv_overhead,loop_unit)
						
						d.defense.pos_sv_overhead_to_dodge = (d.defense.pos_sv_overhead_to_dodge and d.defense.pos_sv_overhead_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
						count_sv_overhead_to_dodge = count_sv_overhead_to_dodge + 1
					elseif is_sv_sweep then
						table.insert(d.defense.attacking_sv_sweep,loop_unit)
						
						d.defense.pos_sv_sweep_to_dodge = (d.defense.pos_sv_sweep_to_dodge and d.defense.pos_sv_sweep_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
						count_sv_sweep_to_dodge = count_sv_sweep_to_dodge + 1
					end
					
					if enemy_attack_duration > aggressive_melee_allowance then
						table.insert(d.defense.threat_stormvermin,loop_unit)
						if is_sv_overhead then
							table.insert(d.defense.threat_sv_overhead,loop_unit)
						elseif is_sv_sweep then
							table.insert(d.defense.threat_sv_sweep,loop_unit)
						end
					end
				end
				
				-- Vernon: push attack is almost instant?
				if is_sv_push and DamageUtils.check_infront(loop_unit, d.unit) then
					-- table.insert(d.defense.attacking_stormvermin,loop_unit)
					-- table.insert(d.defense.attacking_stormvermin_uninterruptible,loop_unit)
					table.insert(d.defense.threat_sv_push,loop_unit)
					
					-- d.defense.is_sv_push_target = true
				end
				
				-- Vernon: currently unused...
				if loop_distance < 2.7 and enemy_attack_duration > aggressive_melee_allowance then
					if is_sv_overhead then
						d.defense.threat_sv_overhead_in_push_range = true
					elseif is_sv_sweep then
						d.defense.threat_sv_sweep_in_push_range = true
					else
						d.defense.threat_sv_push_in_push_range = true
					end
				end
			else
				d.defense.awareness.attacks[loop_unit] = nil
			end
		elseif loop_breed.name == "skaven_rat_ogre" then
			local loop_in_front_wide, _ = check_alignment_to_target(d.unit, loop_unit, 120)
			
			if loop_in_front_wide then
				d.defense.in_front_of_boss = true
			end

			if loop_bb.attacking_target or loop_bb.special_attacking_target then
				local is_ogre_slam = loop_bb.action and loop_bb.action.name == "melee_slam"		-- Vernon: overhead (unblockable)
				local is_ogre_shove = loop_bb.action and (loop_bb.action.name == "melee_shove" or loop_bb.action.name == "fling_skaven")	-- Vernon: forward punch / side punch
				
				if not d.defense.awareness.attacks[loop_unit] then
					d.defense.awareness.attacks[loop_unit] = d.current_time
				end
				
				local enemy_attack_duration = d.current_time - d.defense.awareness.attacks[loop_unit]
				-- local shove_attack_time = (loop_bb.action and loop_bb.action.attack_time and math.min(loop_bb.action.attack_time, 2)) or 2
				-- local shove_attack_time = (loop_bb.action and loop_bb.action.attack_time and math.min(loop_bb.action.attack_time, 1.5)) or 1.5
				local shove_attack_time = 1.2
				
				if is_ogre_slam and enemy_attack_duration < 0.9 then	--0.7	--0.5	--0.4	--0.3	--0.7	--0.9
					-- Vernon TODO: check if position of target unit is changing or not
					local fwd = loop_bb.target_unit and loop_unit and Vector3.normalize(POSITION_LOOKUP[loop_bb.target_unit] - POSITION_LOOKUP[loop_unit])
					local hit_pos = fwd and (POSITION_LOOKUP[loop_unit] + fwd * 1.75 + Vector3(0, 0, 1.25))
					
					if hit_pos and d.position.z < hit_pos.z + 2.5 and hit_pos.z < d.position.z + 4.4 and Vector3.length(Vector3.flat(d.position - hit_pos)) < 1.8 then
						table.insert(d.defense.threat_boss,loop_unit)
						table.insert(d.defense.threat_boss_unblockable,loop_unit)
						
						d.defense.pos_ogre_to_dodge = (d.defense.pos_ogre_to_dodge and d.defense.pos_ogre_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
						count_ogre_to_dodge = count_ogre_to_dodge + 1
					end
				elseif is_ogre_shove and loop_distance < 4.5 and enemy_attack_duration < shove_attack_time then	--5		--5.5
					local loop_in_front, loop_flanking = check_alignment_to_target(d.unit, loop_unit, 180, 180)
					
					if loop_in_front or (loop_distance < 4 and not loop_flanking) then	--3
					-- if loop_in_front then
						table.insert(d.defense.threat_boss,loop_unit)
						
						d.defense.pos_ogre_to_dodge = (d.defense.pos_ogre_to_dodge and d.defense.pos_ogre_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
						count_ogre_to_dodge = count_ogre_to_dodge + 1
					end
				end
			else
				d.defense.awareness.attacks[loop_unit] = nil
			end
		end
	end
	
	-- Vernon: average out all threat directions to determina dodge direction
	if d.defense.pos_trash_to_dodge and count_standing_trash_to_dodge > 0 then
		d.defense.pos_trash_to_dodge = d.defense.pos_trash_to_dodge / count_standing_trash_to_dodge
	end
	if d.defense.pos_fast_trash_to_dodge and count_fast_trash_to_dodge > 0 then
		d.defense.pos_fast_trash_to_dodge = d.defense.pos_fast_trash_to_dodge / count_fast_trash_to_dodge
	end
	if d.defense.pos_sv_sweep_to_dodge and count_sv_sweep_to_dodge > 0 then
		d.defense.pos_sv_sweep_to_dodge = d.defense.pos_sv_sweep_to_dodge / count_sv_sweep_to_dodge
	end
	if d.defense.pos_sv_overhead_to_dodge and count_sv_overhead_to_dodge > 0 then
		d.defense.pos_sv_overhead_to_dodge = d.defense.pos_sv_overhead_to_dodge / count_sv_overhead_to_dodge
	end
	if d.defense.pos_ogre_to_dodge and count_ogre_to_dodge > 0 then
		d.defense.pos_ogre_to_dodge = d.defense.pos_ogre_to_dodge / count_ogre_to_dodge
	end
	
	-- Krench is handled in a separate case due to his fast long range aoe style attacks (lunges, shatters)
	for _,loop_unit in pairs(d.enemies.bosses) do
		local loop_breed = Unit.get_data(loop_unit, "breed")
		local loop_bb = Unit.get_data(loop_unit, "blackboard")
		local loop_distance = Vector3.length(d.position - POSITION_LOOKUP[loop_unit])
		
		if loop_bb.target_unit == d.unit then
			d.defense.is_boss_target = true
		end
		
		if loop_distance < d.enemies.closest_boss_distance then
			d.enemies.closest_boss_distance = loop_distance
		end
		
		if loop_breed.name == "skaven_storm_vermin_champion" then
			-- Krench
			local extended_defense			= d.defense.krench_extension > d.current_time
			
			-- Vernon: for ogre this is done in the loop above
			local loop_in_front, loop_flanking = check_alignment_to_target(d.unit, loop_unit, 120, 120)
			if loop_in_front or not loop_flanking then
				d.defense.in_front_of_boss = true
			end
			
			if loop_bb.attacking_target or loop_bb.special_attacking_target then
				-- Krench uses aoe attacks so any attack is a threat if bot is in threat area
				
				local attack_initialized	= loop_bb.move_state and loop_bb.move_state == "attacking"
				local attack_anim			= "none"
				if attack_initialized then
					local action	= loop_bb.action
					if action then
						local seq	= loop_bb.action.attack_sequence
						if seq then
							-- if the execuition gets here then attack_next_sequence_index > 1 or.. nil if doing the last action in the chain
							-- this is handled in BTStormVerminAttackAction
							local next_index	= loop_bb.attack_next_sequence_index
							local current_index	= (next_index and next_index -1) or #seq
							attack_anim			= seq[current_index].attack_anim
						else
							attack_anim			= loop_bb.action.attack_anim
						end
					end
				end
				-- attack anim translation..
				-- ***********************
				-- attack_special			= normal overhead
				-- attack_sweep_left		= normal sweep
				-- attack_sweep_right		= normal sweep
				-- charge_attack_step		= prepare for lunge
				-- charge_attack_lunge		= lunge
				-- attack_run_2				= jump strike
				-- attack_charge_special	= prepare charged overhead
				-- attack_charge_shatter	= charged overhead
				-- attack_spin_charge		= prepare charged spin
				-- attack_spin				= charged spin
				
				local spin_reach				= 8
				local krench_target				= loop_bb.special_attacking_target
				local distance_to_krench_target	= (krench_target and d.unit and POSITION_LOOKUP[krench_target] and POSITION_LOOKUP[d.unit] and Vector3.distance(POSITION_LOOKUP[krench_target], POSITION_LOOKUP[d.unit])) or 0
				local spin_aoe					= attack_anim == "attack_spin" or attack_anim == "attack_spin_charge"
				local line_aoe					= attack_anim == "charge_attack_step" or attack_anim == "charge_attack_lunge" or attack_anim == "attack_charge_shatter"
				local jump_strike				= attack_anim == "attack_run_2"
				local regular_attack			= attack_anim == "attack_special" or attack_anim == "attack_sweep_left" or attack_anim == "attack_sweep_right"
				
				if regular_attack then
					local loop_in_front, loop_flanking = check_alignment_to_target(d.unit, loop_unit, 120, 120)
					if loop_distance < medium_radius and not loop_flanking then
						table.insert(d.defense.threat_boss,loop_unit)
					end
				elseif jump_strike then
					if distance_to_krench_target < 3 then
						table.insert(d.defense.threat_boss,loop_unit)
					end
				elseif spin_aoe then
					if loop_distance < spin_reach then
						table.insert(d.defense.threat_boss,loop_unit)
						d.defense.krench_extension = d.current_time + 0.7
					end
				elseif line_aoe then
					local loop_in_front, loop_flanking = check_alignment_to_target(d.unit, loop_unit, 90, 270)
					if not loop_flanking or loop_distance < 3 then
						table.insert(d.defense.threat_boss,loop_unit)
						d.defense.krench_extension = d.current_time + 0.5
					end
				end
				--
			elseif extended_defense then
				table.insert(d.defense.threat_boss,loop_unit)
			end
		end
	end

	local control_weapon_arcs = 
	{
		dr_1h_axe_shield	= 60,
		dr_1h_hammer_shield	= 60,
		dr_2h_hammer		= 120,	--100
		es_1h_sword_shield	= 60,
		es_1h_mace_shield	= 60,
		es_2h_war_hammer	= 120,	--100
	}
	
	-- Vernon: use the control arc codes for general melee weapons
	local control_arc = control_weapon_arcs[d.equipped.weapon_id] or 75		--60	--false
	d.melee.threats_outside_control_angle = false
	d.enemies.melee_control_arc = {}
	if control_arc and d.melee.target_unit then
		for _, loop_unit in pairs(d.defense.threat_trash) do
			if not is_secondary_within_cone(d.unit, d.melee.target_unit, loop_unit, control_arc) then
				d.melee.threats_outside_control_angle = true
				break
			end
		end
		
		for _, loop_unit in pairs(d.enemies.melee) do
			if is_secondary_within_cone(d.unit, d.melee.target_unit, loop_unit, control_arc) then
				table.insert(d.enemies.melee_control_arc, loop_unit)
			end
		end
	end
	
	-- ***********************************************
	-- ** update objective defence data             **
	-- ***********************************************
	if d.settings.defend_objectives then
		d.objective_defence.position, d.objective_defence.bot_positions = get_mission_defend_position(d.follow_target_position)
		d.objective_defence.enabled = (d.objective_defence.position and true) or false
	else
		d.objective_defence.enabled			= false
		d.objective_defence.position		= false
		d.objective_defence.bot_positions	= false
	end
	
	-- ***********************************************
	-- ** update ambient shooting allowance         **
	-- ***********************************************
	
	local aggroed_trash	= 0
	local aggroed_SV	= 0
	for _,loop_unit in pairs(d.enemies.far) do
		local loop_bb		= Unit.get_data(loop_unit, "blackboard")
		local loop_breed	= Unit.get_data(loop_unit, "breed")
		local is_agroed		= loop_bb.target_unit or loop_bb.attacking_target or loop_bb.special_attacking_target
		if is_agroed then
			if loop_breed.name == "skaven_clan_rat" or loop_breed.name == "skaven_slave" then
				aggroed_trash = aggroed_trash+1
			elseif loop_breed.name == "skaven_storm_vermin" or loop_breed.name == "skaven_storm_vermin_commander" then
				aggroed_SV = aggroed_SV+1
			end
		end
	end
	
	local may_shoot_ambients = not d.reduced_ambient_shooting
	if bot_settings.menu_settings.reduce_ambient_shooting and not d.objective_defence.enabled then
		if not may_shoot_ambients then
			may_shoot_ambients = aggroed_trash > 11 or aggroed_SV > 2 or (aggroed_SV == 2 and aggroed_trash > 8) or #d.enemies.bosses > 0
		else
			may_shoot_ambients = aggroed_trash > 5 or aggroed_SV > 1 or #d.enemies.bosses > 0
		end
	else
		may_shoot_ambients = true
	end
	d.reduced_ambient_shooting = not may_shoot_ambients
	
	
	-- ***********************************************
	-- ** update regroup data                       **
	-- ***********************************************
	
	if d.objective_defence.enabled then
		d.regroup.position				= d.objective_defence.position
		d.regroup.distance_threshold	= bot_settings.forced_regroup.distance_reduced
		d.regroup.distance				= Vector3.length(d.position - d.regroup.position)
	else
		d.regroup.position				= d.follow_target_position
		d.regroup.distance_threshold	= bot_settings.forced_regroup.distance
		d.regroup.distance				= Vector3.length(d.position - d.regroup.position)
		local distance_threshold_updated = false
		
		-- re-assign the distance_threshold if there is a nearby boss
		for _,loop_unit in pairs(d.enemies.bosses) do
			local loop_position = POSITION_LOOKUP[loop_unit]
			local loop_distance = Vector3.length(d.position - loop_position)
			if loop_distance < bot_settings.forced_regroup.nearby_boss_check_distance then
				d.regroup.distance_threshold	= bot_settings.forced_regroup.distance_with_boss
				distance_threshold_updated		= true
			end
		end
		
		-- re-assign the distance_threshold if there is a nearby human
		if not distance_threshold_updated then
			local nearest_human = 
			{
				position = false,
				distance = math.huge,
			}
			
			for _,loop_owner in pairs(Managers.player:human_players()) do
				local loop_unit = loop_owner.player_unit
				if loop_unit ~= d.follow_target then
					local loop_position = POSITION_LOOKUP[loop_unit]
					local loop_distance = loop_position and Vector3.length(d.position - loop_position)
					if loop_distance and loop_distance < nearest_human.distance then
						nearest_human.position = loop_position
						nearest_human.distance = loop_distance
					end
				end
			end
			
			if nearest_human.position and nearest_human.distance < bot_settings.forced_regroup.nearby_human_check_distance then
				-- there is a human close enough (other than the follow target)..
				
				-- check that the bot is not too far away from the follow target
				if	d.regroup.distance > d.regroup.distance_threshold and
					d.regroup.distance < bot_settings.forced_regroup.distance_with_human and
					nearest_human.distance < bot_settings.forced_regroup.distance_with_human then
					--
					d.regroup.distance = nearest_human.distance
					d.regroup.position = nearest_human.position
				end
			end
		end
		
		-- re-assign the distance_threshold if there are nearby enemies
		if not distance_threshold_updated then
			if (d.defense.closest_able_ally_distance > 3.5 and (#d.enemies.near > 4 or #d.enemies.medium > 7 or #d.enemies.medium_sv > 1))
				or (#d.enemies.near > 5 or #d.enemies.medium > 9 or #d.enemies.medium_sv > 2)
				or d.defense.assassin_on_field then
				--
				d.regroup.distance_threshold	= bot_settings.forced_regroup.distance_reduced
				distance_threshold_updated		= true
			end
		end
		
	end
	
	-- apply the toggle threshold as needed
	if d.regroup.enabled then
		d.regroup.distance_threshold = d.regroup.distance_threshold - bot_settings.forced_regroup.toggle_threshold
	end
	
	-- check if the forced regroup should be active or not
	if d.regroup.distance > d.regroup.distance_threshold or d.warded_krench_as_target then
		d.regroup.enabled = true
	else
		d.regroup.enabled = false
	end
	
	-- ******************************************************************
	-- ** check if there is a need to keep the last stormvermin alive  **
	-- ******************************************************************
	
	local level_id				= LevelHelper:current_level_settings().level_id
	local last_stand_map		= level_id and (level_id == "dlc_survival_magnus" or level_id == "dlc_survival_ruins")
	local alive_sv				= get_spawned_stormvermin()
	local alive_trash			= get_spawned_trash()
	local alive_bosses			= get_spawned_bosses()
	local target_breed			= d.melee.target_breed
	local target_is_stormvermin	= target_breed and (target_breed.name == "skaven_storm_vermin" or target_breed.name == "skaven_storm_vermin_commander")
	local able_human			= false
	for _, loop_owner in pairs(Managers.player:human_players()) do
		local loop_unit				= loop_owner.player_unit
		local loop_status_extension	= ScriptUnit.has_extension(loop_unit, "status_system")
		--
		 if loop_status_extension and not loop_status_extension:is_disabled() then
			able_human		= true
			break
		 end
	end
	d.keep_last_stormvermin_alive = able_human and last_stand_map and target_is_stormvermin and #alive_sv < 2 and #alive_trash < 20 and #alive_bosses < 1
	
end

local get_d_data = function(self_unit)
	if self_unit == nil then
		return false
	end
	
	local self_owner = Managers.player:unit_owner(self_unit)
	
	if not self_owner then
		return false
	end
	
	local blackboard = Unit.get_data(self_unit, "blackboard")
	local d = self_owner.d_data
	
	-- check if d_data actually exist
	if not d then
		-- if not >> try to generate it
		d_data_create_default(self_owner)
		d_data_update(self_owner.d_data)
		local d_tmp = self_owner.d_data
		
		if blackboard.target_unit then
			-- update target info to d_data
			d_tmp.melee.target_unit			= blackboard.target_unit
			d_tmp.melee.target_position		= POSITION_LOOKUP[d_tmp.melee.target_unit]
			d_tmp.melee.target_offset		= d_tmp.melee.target_position - d_tmp.position
			d_tmp.melee.target_distance		= Vector3.length(d_tmp.melee.target_offset)
			d_tmp.melee.target_breed		= Unit.get_data(d_tmp.melee.target_unit, "breed")
			d_tmp.melee.aim_position		= BTBotMeleeAction._aim_position(nil,d_tmp.melee.target_unit,nil)
			d_tmp.melee.is_aiming			= d_tmp.regroup.distance < d_tmp.regroup.distance_threshold + 1
			d_tmp.melee.may_engage			= Vector3.length(d_tmp.regroup.position - d_tmp.melee.target_position) < (d_tmp.regroup.distance_threshold-0.1)
			d_tmp.melee.has_line_of_sight	= check_line_of_sight(d_tmp.unit, d_tmp.melee.target_unit)
		else
			-- no target
			d_tmp.melee.target_unit			= nil
			d_tmp.melee.target_position		= d_tmp.position
			d_tmp.melee.target_offset		= Vector3(0,0,-1000)
			d_tmp.melee.target_distance		= math.huge
			d_tmp.melee.target_breed		= nil
			d_tmp.melee.aim_position		= nil
			d_tmp.melee.is_aiming			= false
			d_tmp.melee.may_engage			= false
			d_tmp.melee.has_line_of_sight	= false
		end
	end
	
	d = self_owner.d_data

	-- check again, now there really should be d_data
	if not d then
		-- if not, complain about it
		EchoConsole("*** d_data generation failed ***")
	end
	
	-- if the data has not been updated on this frame >> update it
	if tostring(d.fresh) ~= "Vector3(0, 0, 0)" then
		d_data_update(self_owner.d_data)
	end
	
	d.settings = bot_settings.menu_settings
	
	return d
end

-- check if the bot (self_unit) is allowed to pick up the healslot item (item_unit)
local may_pick_healslot_item = function(self_unit, item_unit, may_swap_heals, may_drop_tome, may_pick_tome, forced_to_loot)
	
	if may_swap_heals	== nil then may_swap_heals	= true end
	if may_drop_tome	== nil then may_drop_tome	= true end
	if may_pick_tome	== nil then may_pick_tome	= true end
	if forced_to_loot	== nil then forced_to_loot	= false end
	
	local d				= get_d_data(self_unit)
	local self_owner	= Managers.player:owner(self_unit)
	local self_name		= self_owner.character_name
	local bots			= Managers.player:bots()
	local bot_data		= {}
	
	local pickup_extension	= ScriptUnit.has_extension(item_unit, "pickup_system")
	local pickup_settings	= pickup_extension and pickup_extension:get_pickup_settings()
	local pickup_name		= (pickup_settings and pickup_settings.item_name) or "no pickup settings"
	--edit start--
	local pickup_pos		= POSITION_LOOKUP[item_unit]
	--edit end--
	local item_is_draught	= false
	local item_is_medkit	= false
	local item_is_tome		= false
	if pickup_name == "potion_healing_draught_01"	then item_is_draught = true end
	if pickup_name == "healthkit_first_aid_kit_01"	then item_is_medkit = true end
	if pickup_name == "wpn_side_objective_tome_01"	then item_is_tome = true end
	
	-- collect needed info about bot status, trinket, and current healslot item
	for _,loop_owner in pairs(bots) do
		
		local loop_name = loop_owner.character_name
		local loop_unit = loop_owner.player_unit
		local loop_d	= get_d_data(loop_unit)
		--edit start--
		local loop_pos	= POSITION_LOOKUP[loop_unit]
		local loop_dist = (loop_pos and pickup_pos and Vector3.distance(loop_pos, pickup_pos)) or 0
		--edit end--
		local status_extension		= ScriptUnit.has_extension(loop_unit, "status_system")
		local inventory_extension	= ScriptUnit.has_extension(loop_unit, "inventory_system")
		local buff_extension		= ScriptUnit.has_extension(loop_unit, "buff_system")
		local extensions_ok = status_extension and inventory_extension and buff_extension and pickup_extension
		
		if extensions_ok and not status_extension:is_disabled() then
			if not bot_data[loop_name] then
				bot_data[loop_name] = {}
			end
			
			local inventory_item_name	= inventory_extension.get_item_name(inventory_extension, "slot_healthkit")
			local potion_name			= inventory_extension.get_item_name(inventory_extension, "slot_potion")
			
			local hp			= get_bot_current_health_percent(loop_unit)
			local light_hurt	= (hp < 0.667 and true) or false
			local heavy_hurt	= (hp < 0.333 and true) or false
			local wounded		= (not status_extension:has_wounds_remaining() and true) or false
			local hp_compare	= loop_d:get_custom_hp_weight()
			local draught		= false
			local tome			= false
			local medkit		= false
			local empty_slot	= false
			local dove			= false
			local healshare		= false
			local grim			= false
			
			if inventory_item_name then
				if inventory_item_name == "potion_healing_draught_01"	then draught = true	end
				if inventory_item_name == "healthkit_first_aid_kit_01"	then medkit = true	end
				if inventory_item_name == "wpn_side_objective_tome_01"	then tome = true	end
			else
				empty_slot = true
			end
			
			if potion_name then
				if potion_name == "wpn_grimoire_01" then grim = true end
			end
			
			if buff_extension:has_buff_type("heal_self_on_heal_other") then		dove = true			end
			if buff_extension:has_buff_type("medpack_spread_area") then			healshare = true	end
			
			local need_tome					= not dove and not healshare and not tome and not wounded
			local need_draught				= healshare and not draught
			local need_medkit				= dove and not medkit and not (healshare and draught)
			local extra_tome				= tome and (dove or healshare)
			local extra_draught				= draught and not healshare
			local extra_medkit				= medkit and not dove
			local grim_empty_slot			= grim and empty_slot
			local light_hurt_no_heal		= light_hurt and not draught and not medkit
			local heavy_hurt_no_heal		= heavy_hurt and not draught and not medkit
			local wounded_no_heal			= wounded and not draught and not medkit
			local grim_light_hurt_no_heal	= grim and light_hurt_no_heal
			local grim_heavy_hurt_no_heal	= grim and heavy_hurt_no_heal
			local grim_wounded_no_heal		= grim and wounded_no_heal
			local wrong_heal_item			= not ((healshare and draught) or (dove and medkit)) and not tome
			local healshare_no_heal			= healshare and not(draught or medkit)
			local need_tome_empty_slot		= need_tome and empty_slot
			
			bot_data[loop_name].hp_compare				= hp_compare
			bot_data[loop_name].light_hurt				= light_hurt
			bot_data[loop_name].wounded					= wounded
			bot_data[loop_name].draught					= draught
			bot_data[loop_name].tome					= tome
			bot_data[loop_name].grim					= grim
			bot_data[loop_name].medkit					= medkit
			bot_data[loop_name].empty_slot				= empty_slot
			bot_data[loop_name].dove					= dove
			bot_data[loop_name].healshare				= healshare
			bot_data[loop_name].healshare_no_heal		= healshare_no_heal
			bot_data[loop_name].need_tome				= need_tome
			bot_data[loop_name].need_tome_empty_slot	= need_tome_empty_slot
			bot_data[loop_name].need_draught			= need_draught
			bot_data[loop_name].need_medkit				= need_medkit
			bot_data[loop_name].extra_tome				= extra_tome
			bot_data[loop_name].extra_draught			= extra_draught
			bot_data[loop_name].extra_medkit			= extra_medkit
			bot_data[loop_name].grim_empty_slot			= grim_empty_slot
			bot_data[loop_name].light_hurt_no_heal		= light_hurt_no_heal
			bot_data[loop_name].heavy_hurt_no_heal		= heavy_hurt_no_heal
			bot_data[loop_name].wounded_no_heal			= wounded_no_heal
			bot_data[loop_name].grim_light_hurt_no_heal	= grim_light_hurt_no_heal
			bot_data[loop_name].grim_heavy_hurt_no_heal	= grim_heavy_hurt_no_heal
			bot_data[loop_name].grim_wounded_no_heal	= grim_wounded_no_heal
			bot_data[loop_name].wrong_heal_item			= wrong_heal_item
			--edit start--
			bot_data[loop_name].distance_to_pickup		= loop_dist
			--edit end--
		end
	end
	
	-- bot data collected >> now we can resolve (bot) team  flags
	local db = bot_data[self_name]
	local other_medkit = false
	local other_need_draught = false
	local other_need_medkit = false
	local other_need_tome = false
	local other_extra_draught = false
	local other_extra_medkit = false
	local other_extra_tome = false
	local other_empty_slot = false
	local other_empty_dove = false
	local other_empty_healshare = false
	local team_healshare = false
	local team_healshare_enabled = false
	local other_grim_empty_slot = false
	local other_light_hurt_no_heal = false
	local other_heavy_hurt_no_heal = false
	local other_wounded_no_heal = false
	local other_grim_light_hurt_no_heal = false
	local other_grim_heavy_hurt_no_heal = false
	local other_grim_wounded_no_heal = false
	local other_wrong_heal_item = false
	local other_healshare_no_heal = false
	local other_need_tome_empty_slot = false
	local most_hurt_bot = {name = "", hp_compare = math.huge}
	--edit start--
	local most_needy_healshare	= {name = false, hp_compare = math.huge}
	local most_needy_dove		= {name = false, hp_compare = math.huge}
	--edit end--
	--
	for name,data in pairs(bot_data) do
		if name ~= self_name then
			if data.medkit					then other_medkit = true					end
			if data.need_draught			then other_need_draught = true				end
			if data.need_medkit				then other_need_medkit = true				end
			if data.need_tome				then other_need_tome = true					end
			if data.empty_slot				then other_empty_slot = true				end
			if data.extra_draught			then other_extra_draught = true				end
			if data.extra_medkit			then other_extra_medkit = true				end
			if data.extra_tome				then other_extra_tome = true				end
			if data.grim_empty_slot			then other_grim_empty_slot = true			end
			if data.light_hurt_no_heal		then other_light_hurt_no_heal = true		end
			if data.heavy_hurt_no_heal		then other_heavy_hurt_no_heal = true		end
			if data.wounded_no_heal			then other_wounded_no_heal = true			end
			if data.grim_light_hurt_no_heal	then other_grim_light_hurt_no_heal = true	end
			if data.grim_heavy_hurt_no_heal	then other_grim_heavy_hurt_no_heal = true	end
			if data.grim_wounded_no_heal	then other_grim_wounded_no_heal = true		end
			if data.wrong_heal_item			then other_wrong_heal_item = true			end
			if data.healshare_no_heal		then other_healshare_no_heal = true			end
			if data.need_tome_empty_slot	then other_need_tome_empty_slot = true		end
		end
		--
		if data.healshare then team_healshare = true end
		if (data.medkit or data.draught) and data.healshare then team_healshare_enabled = true end
		--edit start--
		if data.healshare_no_heal and data.hp_compare < most_needy_healshare.hp_compare and data.distance_to_pickup < 10 then
			most_needy_healshare.name		= name
			most_needy_healshare.hp_compare	= data.hp_compare
		end
		
		if data.dove and not data.medkit and data.hp_compare < most_needy_dove.hp_compare and data.distance_to_pickup < 10 then
			most_needy_dove.name		= name
			most_needy_dove.hp_compare	= data.hp_compare
		end
		--edit end--
		--
		if	not data.medkit and
			not data.draught and
			data.hp_compare < most_hurt_bot.hp_compare then
			--
			most_hurt_bot.name			= name
			most_hurt_bot.hp_compare	= data.hp_compare
		end
	end
	--edit start--
	if most_needy_healshare.name then
		bot_data[most_needy_healshare.name].most_needy_healshare = true
		most_needy_healshare = true
	else
		most_needy_healshare = false
	end
	
	if most_needy_dove.name then
		bot_data[most_needy_dove.name].most_needy_dove = true
		most_needy_dove = true
	else
		most_needy_dove = false
	end
	--edit end--
	--
	local is_most_hurt_no_heal	= self_name == most_hurt_bot.name
	local other_need_swap		= (other_need_draught and other_extra_draught and not item_is_draught) or (other_need_medkit and other_extra_medkit and not item_is_medkit)
	local healshare_needs_heal	= team_healshare and not team_healshare_enabled
	local has_what_other_need	= (db.extra_draught and other_need_draught) or 
								  (db.extra_medkit and other_need_medkit) or 
								  (db.extra_medkit and not db.healshare and other_healshare_no_heal) or 
								  (db.extra_tome and other_need_tome) or 
								  (not item_is_draught and db.extra_draught and not (db.heavy_hurt or db.wounded) and (other_heavy_hurt_no_heal or other_wounded_no_heal))
	
	-- now with all the data gathered, implemet decision tree for draughts, medkits, and tomes
	-- do note that there is a separate function for checkinf nearby human needs
	if forced_to_loot and d.settings.hp_based_loot_pinged_heal and (item_is_draught or item_is_medkit) then
		if is_most_hurt_no_heal then
			return true
		else
			return false
		end
		--
	elseif item_is_draught and not db.draught then
		if db.tome and not may_drop_tome					then return false end
		if db.dove and not db.need_draught and db.medkit	then return false end
		--edit start--
		if db.most_needy_healshare							then return true end
		if most_needy_healshare								then return false end
		--edit end--
		if db.need_draught									then return true end
		if other_need_draught								then return false end
		if has_what_other_need								then return true end
		if other_need_swap									then return false end
		if db.grim_wounded_no_heal							then return true end
		if other_grim_wounded_no_heal						then return false end
		if db.wounded_no_heal								then return true end
		if other_wounded_no_heal							then return false end
		if db.grim_heavy_hurt_no_heal						then return true end
		if other_grim_heavy_hurt_no_heal					then return false end
		if db.heavy_hurt_no_heal							then return true end
		if other_heavy_hurt_no_heal							then return false end
		if db.grim_light_hurt_no_heal						then return true end
		if other_grim_light_hurt_no_heal					then return false end
		if db.light_hurt_no_heal							then return true end
		if other_light_hurt_no_heal							then return false end
		if db.grim_empty_slot								then return true end
		if other_grim_empty_slot							then return false end
		if db.empty_slot									then return true end
		if other_empty_slot									then return false end
		if db.tome and may_swap_heals						then return false end
		if db.medkit and not may_swap_heals					then return false end
		return true
		--
	elseif item_is_medkit and not db.medkit then
		if db.tome and not may_drop_tome			then return false end
		if db.healshare and db.draught				then return false end
		if has_what_other_need						then return true end
		if other_need_swap							then return false end
		--edit start--
		if db.most_needy_healshare					then return true end
		if most_needy_healshare						then return false end
		--edit end--
		if db.healshare and healshare_needs_heal	then return true end
		if healshare_needs_heal						then return false end
		--edit start--
		if db.most_needy_dove						then return true end
		if most_needy_dove							then return false end
		--edit end--
		if db.need_medkit							then return true end
		if other_need_medkit						then return false end
		if db.healshare_no_heal						then return true end
		if other_healshare_no_heal					then return false end
		if db.grim_wounded_no_heal					then return true end
		if other_grim_wounded_no_heal				then return false end
		if db.wounded_no_heal						then return true end
		if other_wounded_no_heal					then return false end
		if db.grim_heavy_hurt_no_heal				then return true end
		if other_grim_heavy_hurt_no_heal			then return false end
		if db.heavy_hurt_no_heal					then return true end
		if other_heavy_hurt_no_heal					then return false end
		if db.grim_light_hurt_no_heal				then return true end
		if other_grim_light_hurt_no_heal			then return false end
		if db.light_hurt_no_heal					then return true end
		if other_light_hurt_no_heal					then return false end
		if db.grim_empty_slot						then return true end
		if other_grim_empty_slot					then return false end
		if db.empty_slot							then return true end
		if other_empty_slot							then return false end
		if db.tome and may_swap_heals				then return false end
		if db.draught and not may_swap_heals		then return false end
		return true
		--
	elseif item_is_tome and not db.tome then
		if not db.empty_slot and not may_pick_tome	then return false end
		if db.need_tome_empty_slot					then return true end
		if other_need_tome_empty_slot				then return false end
		if has_what_other_need						then return true end
		if other_need_swap							then return false end
		if db.need_tome								then return true end
		if other_need_tome							then return false end
		if db.empty_slot							then return true end
		if other_empty_slot							then return false end
		if db.wrong_heal_item						then return true end
		if other_wrong_heal_item					then return false end
		if db.medkit								then return true end
		if other_medkit								then return false end
		return true
		--
	end
	
	return false
end

-- This function determines if the bot given with "self_unit" is the one that should pick up the "item_unit"
local may_pick_potionslot_item_frame_checker = new_frame_checker()
local may_pick_potionslot_item_bot_data = {}
local may_pick_potionslot_item = function(self_unit, item_unit, may_pick_grims)
	
	if not self_unit or not item_unit then
		return false
	end
	
	if may_pick_grims == nil then may_pick_grims = false end
	
	local pickup_extension	= ScriptUnit.has_extension(item_unit, "pickup_system")
	
	-- once in a frame..
	if may_pick_potionslot_item_frame_checker:is_new_frame() then
		may_pick_potionslot_item_frame_checker:update()
		
		--go through the bots to determine the current status of each bot
		may_pick_potionslot_item_bot_data = {}
		local bot_data = {}
		local bots = Managers.player:bots()

		for _,loop_owner in pairs(bots) do
			
			local loop_unit				= loop_owner.player_unit
			local status_extension		= ScriptUnit.has_extension(loop_unit, "status_system")
			local inventory_extension	= ScriptUnit.has_extension(loop_unit, "inventory_system")
			local buff_extension		= ScriptUnit.has_extension(loop_unit, "buff_system")
			local extensions_ok			= status_extension and inventory_extension and buff_extension and pickup_extension
			
			if extensions_ok and not status_extension:is_disabled() then
				if not bot_data[loop_unit] then
					bot_data[loop_unit] = {}
				end
				
				local data = {}
				
				local healslot_item_name			= inventory_extension.get_item_name(inventory_extension, "slot_healthkit")
				local potionslot_item_name			= inventory_extension.get_item_name(inventory_extension, "slot_potion")
				
				local hp				= get_bot_current_health_percent(loop_unit)
				local wounded			= (not status_extension:has_wounds_remaining() and true) or false
				local tome				= false
				local empty_slot		= false
				local grim				= false
				local speed_potion		= false
				local strength_potion	= false
				local taurus			= false
				local lichebone			= false
				local potshare			= false
				local defensive_trait	= false
				local shield			= false
				
				if healslot_item_name then
					if healslot_item_name == "wpn_side_objective_tome_01"	then tome		= true end
				end
				
				
				if potionslot_item_name then
					if potionslot_item_name == "wpn_grimoire_01"		then grim				= true end
					if potionslot_item_name == "potion_speed_boost_01"	then speed_potion		= true end
					if potionslot_item_name == "potion_damage_boost_01"	then strength_potion	= true end
				else
					empty_slot = true
				end
				
				if buff_extension:has_buff_type("hp_increase_kd")			then taurus		= true	end
				if buff_extension:has_buff_type("curse_protection")			then lichebone	= true	end
				if buff_extension:has_buff_type("potion_spread_area_tier1") then potshare	= true	end
				if buff_extension:has_buff_type("potion_spread_area_tier2") then potshare	= true	end
				if buff_extension:has_buff_type("potion_spread_area_tier3") then potshare	= true	end
				
				local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(loop_unit)
				local shield_weapon =
				{
					es_1h_mace_shield	= true,
					es_1h_sword_shield	= true,
					dr_1h_axe_shield	= true,
					dr_1h_hammer_shield	= true,
				}
				
				if shield_weapon[weapon_type]									then shield = true end
				if buff_extension:has_buff_type("full_fatigue_on_block_broken")	then defensive_trait = true	end	-- second wind
				if buff_extension:has_buff_type("max_fatigue")					then defensive_trait = true	end	-- perfect balance
				if buff_extension:has_buff_type("no_block_fatigue_cost")		then defensive_trait = true	end	-- improved guard
				if buff_extension:has_buff_type("no_push_fatigue_cost")			then defensive_trait = true	end	-- improved pommel
				if buff_extension:has_buff_type("fatigue_regen_proc")			then defensive_trait = true	end	-- endurance
				
				local grim_score = hp
				
				if empty_slot		then grim_score = grim_score + 1 end
				if not tome			then grim_score = grim_score + 2 end
				if not wounded		then grim_score = grim_score + 4 end
				if not potshare		then grim_score = grim_score + 8 end
				if defensive_trait	then grim_score = grim_score + 16 end
				if shield			then grim_score = grim_score + 32 end
				if taurus			then grim_score = grim_score + 64 end
				if lichebone		then grim_score = grim_score + 128 end
				if grim				then grim_score = 0 end
				
				local pick_speed	= empty_slot or strength_potion
				local pick_strength	= empty_slot or speed_potion
				local need_potion	= empty_slot and potshare
				
				data.grim_score		= grim_score
				data.pick_speed		= pick_speed
				data.pick_strength	= pick_strength
				data.need_potion	= need_potion
				data.empty_slot		= empty_slot
				
				bot_data[loop_unit] = data
			end
		end
		
		local best_grim_score	= -1
		local best_grim_unit  	= nil
		local team_need_potion	= false
		local team_empty_slot	= false
		
		for _,loop_owner in pairs(bots) do
			local loop_unit	= loop_owner.player_unit
			local data = loop_unit and bot_data[loop_unit]
			if data then
				if data.grim_score > best_grim_score then
					best_grim_score	= data.grim_score
					best_grim_unit	= loop_unit
				end
				if data.need_potion then team_need_potion	= true end
				if data.empty_slot	then team_empty_slot	= true end
			end
		end
		
		for _,loop_owner in pairs(bots) do
			local loop_unit	= loop_owner.player_unit
			local data = loop_unit and bot_data[loop_unit]
			if data then
				if loop_unit ~= best_grim_unit then
					bot_data[loop_unit].pick_grim = false
				else
					bot_data[loop_unit].pick_grim = true
				end
				
				-- this bot shouldn't pick up the potion if it doesn't need it and one of the other bots do
				if team_need_potion then
					if not data.need_potion then
						bot_data[loop_unit].pick_speed		= false
						bot_data[loop_unit].pick_strength	= false
					end
				end
				
				-- this bot shouldn't pick up the potion if it has something in slot and one of the other bots has an empty slot
				if team_empty_slot and not data.empty_slot then
						bot_data[loop_unit].pick_speed		= false
						bot_data[loop_unit].pick_strength	= false
				end
			end
		end
		
		may_pick_potionslot_item_bot_data = bot_data
	end
	
	local pickup_settings	= pickup_extension and pickup_extension:get_pickup_settings()
	local pickup_name		= (pickup_settings and pickup_settings.item_name) or "no pickup settings"
	local item_is_speed		= false
	local item_is_strength	= false
	local item_is_grim		= false
	if pickup_name == "wpn_grimoire_01"			then item_is_grim = true end
	if pickup_name == "potion_speed_boost_01"	then item_is_speed = true end
	if pickup_name == "potion_damage_boost_01"	then item_is_strength = true end
	
	local ret = false
	local bot_data = may_pick_potionslot_item_bot_data[self_unit]
	if bot_data then
		if item_is_grim		and bot_data.pick_grim and may_pick_grims	then ret = true end
		if item_is_speed	and bot_data.pick_speed						then ret = true end
		if item_is_strength	and bot_data.pick_strength					then ret = true end
	end
	
	return ret
end

-- This function determines if the bot given with "self_unit" is the one that should pick up the "item_unit"
local may_pick_grenadeslot_item_frame_checker = new_frame_checker()
local may_pick_grenadeslot_item_bot_data = {}
local may_pick_grenadeslot_item = function(self_unit, item_unit)
	
	if not self_unit or not item_unit then
		return false
	end
	
	local pickup_extension	= ScriptUnit.has_extension(item_unit, "pickup_system")
	
	-- once in a frame..
	if may_pick_grenadeslot_item_frame_checker:is_new_frame() then
		may_pick_grenadeslot_item_frame_checker:update()
		
		--go through the bots to determine the current status of each bot
		may_pick_grenadeslot_item_bot_data = {}
		local pickup_settings	= pickup_extension and pickup_extension:get_pickup_settings()
		local pickup_name		= (pickup_settings and pickup_settings.item_name) or "no pickup settings"
		local bot_data = {}
		local bots = Managers.player:bots()

		for _,loop_owner in pairs(bots) do
			
			local loop_unit				= loop_owner.player_unit
			local status_extension		= ScriptUnit.has_extension(loop_unit, "status_system")
			local inventory_extension	= ScriptUnit.has_extension(loop_unit, "inventory_system")
			local extensions_ok			= status_extension and inventory_extension and pickup_extension
			
			if extensions_ok and not status_extension:is_disabled() then
				if not bot_data[loop_unit] then
					bot_data[loop_unit] = {}
				end
				
				local data = {}
				
				local grenadeslot_item_name	= inventory_extension.get_item_name(inventory_extension, "slot_grenade")
				
				local frag_grenade			= grenadeslot_item_name == "grenade_frag_01" or grenadeslot_item_name == "grenade_frag_02"
				local fire_grenade			= grenadeslot_item_name == "grenade_fire_01" or grenadeslot_item_name == "grenade_fire_02"
				local item_is_frag_grenade	= pickup_name == "grenade_frag_01" or pickup_name == "grenade_frag_02"
				local item_is_fire_grenade	= pickup_name == "grenade_fire_01" or pickup_name == "grenade_fire_02"
				local empty_slot			= not frag_grenade and not fire_grenade
				local can_pick_grenade		= empty_slot or (item_is_frag_grenade and not frag_grenade) or (item_is_fire_grenade and not fire_grenade)
				
				data.empty_slot				= empty_slot
				data.can_pick_grenade		= can_pick_grenade
				data.pick_grenade			= can_pick_grenade
				
				bot_data[loop_unit]			= data
			end
		end
		
		local team_empty_slot = false
		for _,loop_owner in pairs(bots) do
			local loop_unit	= loop_owner.player_unit
			local data = loop_unit and bot_data[loop_unit]
			if data then
				if data.empty_slot then team_empty_slot = true end
			end
		end
		
		for _,loop_owner in pairs(bots) do
			local loop_unit	= loop_owner.player_unit
			local data = loop_unit and bot_data[loop_unit]
			if data then
				if team_empty_slot and not data.empty_slot then
					bot_data[loop_unit].pick_grenade = false
				end
			end
		end
		
		may_pick_grenadeslot_item_bot_data = bot_data
	end
	
	local ret = false
	local bot_data = may_pick_grenadeslot_item_bot_data[self_unit]
	if bot_data then
		if bot_data.pick_grenade == true then ret = true end
	end
	
	return ret
end

-- function that retrieves the name of the item in the requested slot
-- any error or no item in the slot returns false or equivalent value
-- otherwise the name of the item os returned
-- supports heal, potion, and grenade slots
local get_slot_item_name = function(unit, slot)
	local name = false
	local slot_is_valid = slot == "slot_healthkit" or slot == "slot_potion" or slot == "slot_grenade"
	
	if unit and is_unit_alive(unit) and slot_is_valid then
		local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
		name = (inventory_extension and inventory_extension:get_item_name(slot)) or false
	end
	
	return name
end

-- this function returns a table of equipped heal / potion / grenade items on the unit (bot / human)
local get_equipped_item_info = function(unit)
	local items =
	{
		tome			= false,
		medkit			= false,
		draught			= false,
		
		grim			= false,
		speed_potion	= false,
		strength_potion	= false,
		
		fire_grenade	= false,
		frag_grenade	= false,
	}
	
	-- while host uses simple_inventory_extension, a client uses simple_husk_inventory_extension..
	-- the latter doesn't define get_item_name member method so I made a local version of it here to be used in this function
	local get_item_name = function(inventory_extension, slot_name)
		local ret = ""
		if inventory_extension and slot_name then
			local slot_data	= inventory_extension:get_slot_data(slot_name)
			local item_data	= slot_data and slot_data.item_data
			local item_name	= item_data and item_data.name
			ret = item_name or ret
		end
		return ret
	end
	
	if unit then
		local owner = Managers.player:unit_owner(unit)
		if owner then
			if owner.bot_player then
				local d = get_d_data(unit)
				items = table.clone(d.items)
			else
				local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
				if inventory_extension then
					local carried_heal		= get_item_name(inventory_extension, "slot_healthkit")
					local carried_potion	= get_item_name(inventory_extension, "slot_potion")
					local carried_grenade	= get_item_name(inventory_extension, "slot_grenade")
					
					items.tome				= carried_heal == "wpn_side_objective_tome_01"
					items.medkit			= carried_heal == "healthkit_first_aid_kit_01"
					items.draught			= carried_heal == "potion_healing_draught_01"
					
					items.grim				= carried_potion == "wpn_grimoire_01"
					items.speed_potion		= carried_potion == "potion_speed_boost_01"
					items.strength_potion	= carried_potion == "potion_damage_boost_01"
					
					items.fire_grenade		= carried_grenade == "grenade_fire_01" or carried_grenade == "grenade_fire_02"
					items.frag_grenade		= carried_grenade == "grenade_frag_01" or carried_grenade == "grenade_frag_02"
				end
			end
		end
	end
	
	return items
end


local find_best_healer = function(target_unit, ignore_human_healers)
	local deathwish_enabled			= (rawget(_G, "deathwishtoken") and true) or false
	local healshare_needs_wounded	= bot_settings.menu_settings.heal_only_if_wounded_healshare
	local max_healing_distance		= bot_settings.menu_settings.max_healing_distance
	local human_list				= {}
	local bot_list					= {}
	local player_list				= {}
	
	for _,owner in pairs(Managers.player:players()) do
		local status_extension = ScriptUnit.has_extension(owner.player_unit, "status_system")
		local enabled = status_extension and not status_extension:is_disabled()
		if enabled then
			if owner.bot_player then
				table.insert(bot_list, owner.player_unit)
			else
				table.insert(human_list, owner.player_unit)
			end
			table.insert(player_list, owner.player_unit)
		end
	end
	
	local HEALSHARE_RANGE			= 15
	local GRIM_WEIGHT				= 1.5	-- final multiplier
	local target_aoe_threat			= is_unit_in_aoe_explosion_threat_area(target_unit)
	local team_healshare_potential	= 0
	local team_wounded				= false
	local player_data				= {}
	local team_healshare_ready		= false
	local team_dove_ready			= false
	
	-- gather information about potential healers and heal effectiveness
	for _,healer_unit in pairs(player_list) do
		-- some info regarding the healer's current status
		local health_extension	= ScriptUnit.has_extension(healer_unit, "health_system")
		local hp_missing		= (health_extension and health_extension.damage) or 0
		local hp_max			= (health_extension and health_extension.health) or 100
		local hp_current		= hp_max - hp_missing
		local status_extension	= ScriptUnit.has_extension(healer_unit, "status_system")
		local wounded			= (status_extension and not status_extension:has_wounds_remaining() and not deathwish_enabled and true) or false
		local buff_extension	= ScriptUnit.has_extension(healer_unit, "buff_system")
		local dove				= (buff_extension and buff_extension:has_buff_type("heal_self_on_heal_other") and true) or false
		local healshare			= (buff_extension and buff_extension:has_buff_type("medpack_spread_area") and true) or false
		local item_info			= get_equipped_item_info(healer_unit)
		local medkit			= item_info.medkit
		local draught			= item_info.draught
		local grim				= item_info.grim
		local healshare_ready	= (healshare and (draught or medkit) and true) or false
		local dove_ready		= (dove and medkit and true) or false
		
		-- if this bot is already healing or healsharing the target ally then select this bot automatically as the best healer
		local healer_pos		= POSITION_LOOKUP[healer_unit]
		local target_pos		= POSITION_LOOKUP[target_unit]
		local target_distance	= (healer_pos and target_pos and Vector3.distance(healer_pos, target_pos)) or math.huge
		local blackboard		= Unit.get_data(healer_unit, "blackboard")
		local targeting_target	= blackboard and blackboard.target_ally_unit == target_unit
		--edit start--
		-- local is_healing_target	= blackboard and blackboard.is_healing_other == true
		local is_healing_other	= blackboard and blackboard.is_healing_other
		local is_healing_self	= blackboard and blackboard.is_healing_self
		local is_healing_target	= (is_healing_other and targeting_target) or (is_healing_self and healer_unit == target_unit)
		--edit end--
		local is_healsharing	= blackboard and blackboard.is_healing_self == true and healshare and target_distance < HEALSHARE_RANGE
		--edit start--
		-- if (targeting_target and is_healing_target) then
		if is_healing_target then
		--edit end--
			-- this bot is healing the target already >> this bot is the best healer
			return healer_unit, false
		elseif is_healsharing then
			-- this bot is healshareing the target already >> this bot is the best healer
			return healer_unit, healer_unit
		end
		
		-- some info about the heal potential if various heals are used on this unit
		--edit start--
		-- local health_extension			= ScriptUnit.has_extension(healer_unit, "health_system")
		--edit end--
		local wounded_heal_potential	= (wounded and hp_current < hp_max and hp_current) or 0
		local grim_factor				= (grim and GRIM_WEIGHT) or 1
		local healshare_potential		= (hp_missing * 0.2 + wounded_heal_potential) * grim_factor
		local medkit_potential			= (hp_missing * 0.8 + wounded_heal_potential) * grim_factor
		local draught_potential			= (math.min(hp_missing, 75) + wounded_heal_potential) * grim_factor
		
		-- can this unit heal the target using a healshare
		local healshare_range_ok	= target_distance < HEALSHARE_RANGE
		local can_healshare_target	= healshare_ready and healshare_range_ok
		
		team_healshare_ready		= team_healshare_ready or healshare_ready
		team_dove_ready				= team_dove_ready or dove_ready
		team_healshare_potential	= team_healshare_potential + healshare_potential
		team_wounded				= team_wounded or wounded
		
		local data =
		{
			hp_max					= hp_max,
			hp_current				= hp_current,
			hp_missing				= hp_missing,
			wounded					= wounded,
			dove					= dove,
			healshare				= healshare,
			healshare_potential		= healshare_potential,
			medkit_potential		= medkit_potential,
			draught_potential		= draught_potential,
			medkit					= medkit,
			draught					= draught,
			grim					= grim,
			healshare_ready			= healshare_ready,
			dove_ready				= dove_ready,
			can_healshare_target	= can_healshare_target,
		}
		player_data[healer_unit] = data
	end
	
	if not player_data[target_unit] then
		-- happend when healing is evaluated for disabled target
		return false, false
	end
	
	
	
	-- find out who is best healshare / dove / medkit / draught user
	local target_owner = Managers.player:unit_owner(target_unit)
	local target_is_bot = target_owner and target_owner.bot_player
	local best_healshare = nil
	local best_healshare_potential = 0
	local best_dove = nil
	local best_dove_potential = 0
	local best_medkit = nil
	local best_medkit_potential = 0
	local best_draught = target_unit
	local best_draught_potential = ((not ignore_human_healers or target_is_bot) and player_data[target_unit].draught and not player_data[target_unit].healshare and  player_data[target_unit].draught_potential * (player_data[target_unit].draught_potential / 75)) or 0
	--
	for healer_unit, data in pairs(player_data) do
		local healer_owner		= Managers.player:unit_owner(healer_unit)
		local is_bot			= healer_owner and healer_owner.bot_player
		local healer_pos		= POSITION_LOOKUP[healer_unit]
		local target_pos		= POSITION_LOOKUP[target_unit]
		local target_distance	= healer_pos and target_pos and Vector3.distance(healer_pos, target_pos)
		
		local HEALSHARE_REFERENCE_EFFECTIVENESS = 2.5	-- heal one to full from grey (self) and bring one teammate along out of white
		if deathwish_enabled then HEALSHARE_REFERENCE_EFFECTIVENESS = 1.1 end -- 70% heal on self + 20% for two teammates
		
		if is_bot or not ignore_human_healers then
			local healer_aoe_threat	= is_unit_in_aoe_explosion_threat_area(healer_unit)
			local may_use_medkit	= not healer_aoe_threat and not target_aoe_threat
			-- healshare carrier uses healshare on the target
			if data.can_healshare_target and (team_wounded or not healshare_needs_wounded) then
				-- find out how effective the heal would be if this unit would use it
				local healshare_potential = 0
				local healshare_effectiveness = 0
				for loop_unit, loop_data in pairs(player_data) do
					local loop_pos		= POSITION_LOOKUP[loop_unit]
					local loop_distance	= healer_pos and loop_pos and Vector3.distance(healer_pos, loop_pos)
					if loop_distance < HEALSHARE_RANGE then
						healshare_potential		= healshare_potential + loop_data.healshare_potential
						healshare_effectiveness	= healshare_effectiveness + (loop_data.healshare_potential / loop_data.hp_max)
					end
				end
				
				if data.draught then
					healshare_potential		= healshare_potential - data.healshare_potential + data.draught_potential
					healshare_effectiveness	= healshare_effectiveness + ((data.draught_potential - data.healshare_potential) / data.hp_max)
				elseif data.medkit then
					healshare_potential		= healshare_potential - data.healshare_potential + data.medkit_potential
					healshare_effectiveness	= healshare_effectiveness + ((data.medkit_potential - data.healshare_potential) / data.hp_max)
				end
				
				healshare_potential = healshare_potential * (healshare_effectiveness / HEALSHARE_REFERENCE_EFFECTIVENESS)
				
				if healshare_potential > best_healshare_potential then
					best_healshare_potential	= healshare_potential
					best_healshare				= healer_unit
				end
			end
			
			-- dove carrier uses dove on the target
			if data.dove_ready and may_use_medkit then
				local DOVE_REFERENCE_EFFECTIVENESS = 1.6
				--edit start--
				-- local distance_factor		= (0.2 * (max_healing_distance - target_distance) / max_healing_distance) + 0.8
				local distance_factor		= ((target_distance < max_healing_distance) and ((0.2 * (max_healing_distance - target_distance) / max_healing_distance) + 0.8)) or 0
				--edit end--
				local dove_potential		= (data.medkit_potential + player_data[target_unit].medkit_potential)
				local dove_effectiveness	= data.medkit_potential / data.hp_max + player_data[target_unit].medkit_potential / player_data[target_unit].hp_max
				
				dove_potential = dove_potential * (dove_effectiveness / DOVE_REFERENCE_EFFECTIVENESS) * distance_factor
				
				if dove_potential > best_dove_potential then
					best_dove_potential	= dove_potential
					best_dove			= healer_unit
				end
			end
			
			-- medkit carrier uses medkit on the target, note that dove heals / healshare healing self are handled in above branches
			--edit start--
			-- if data.medkit and not data.dove and (not data.healshare or target_unit ~= healer_unit) and may_use_medkit then
			if data.medkit and not data.dove and may_use_medkit then
			--edit end--
				local MEDKIT_REFERENCE_EFFECTIVENESS = (data.healshare and HEALSHARE_REFERENCE_EFFECTIVENESS) or 0.8
				-- local dove_bias_factor	= (data.dove and 1) or 1.5	-- give non-dove medkit carriers some bias over dove carriers so doves won't waste their medkits so easily
				--edit start--
				-- local distance_factor		= (0.2 * (max_healing_distance - target_distance) / max_healing_distance) + 0.8
				local distance_factor		= ((target_distance < max_healing_distance) and ((0.2 * (max_healing_distance - target_distance) / max_healing_distance) + 0.8)) or 0
				local healshare_factor		= (data.healshare and 0.1) or 1
				--edit end--
				-- local medkit_potential		= player_data[target_unit].medkit_potential * distance_factor * dove_bias_factor
				local medkit_potential		= player_data[target_unit].medkit_potential
				local medkit_effectiveness	= player_data[target_unit].medkit_potential / player_data[target_unit].hp_max
				
				--edit start--
				-- medkit_potential = medkit_potential * (medkit_effectiveness / MEDKIT_REFERENCE_EFFECTIVENESS) * distance_factor
				medkit_potential = medkit_potential * (medkit_effectiveness / MEDKIT_REFERENCE_EFFECTIVENESS) * distance_factor * healshare_factor
				--edit end--
				
				if medkit_potential > best_medkit_potential then
					best_medkit_potential	= medkit_potential
					best_medkit				= healer_unit
				end
			end
		end
	end
	
	local best_healer			= false
	local best_target			= false
	local best_heal_potential	= 0
	if best_healshare_potential > best_heal_potential then
		best_heal_potential = best_healshare_potential
		best_healer			= best_healshare
		best_target			= best_healshare
		-- debug_print_variables("healshare", best_healshare_potential)
	end
	if best_dove_potential > best_heal_potential then
		best_heal_potential = best_dove_potential
		best_healer			= best_dove
		best_target			= false
		-- debug_print_variables("dove", best_dove_potential)
	end
	if best_medkit_potential > best_heal_potential then
		best_heal_potential = best_medkit_potential
		best_healer			= best_medkit
		best_target			= false
		-- debug_print_variables("medkit", best_medkit_potential)
	end
	if best_draught_potential > best_heal_potential then
		best_heal_potential = best_draught_potential
		best_healer			= best_draught
		best_target			= false
		-- debug_print_variables("draught", best_draught_potential)
	end
	
	return best_healer, best_target -- best_healer, target_override
	
	-- 
end


local find_best_healer_forced = function(target_ally_unit)
	if not target_ally_unit then
		return false, false
	end
	
	local deathwish_enabled			= (rawget(_G, "deathwishtoken") and true) or false
	local max_healing_distance		= bot_settings.menu_settings.max_healing_distance
	local healshare_needs_wounded	= bot_settings.menu_settings.heal_only_if_wounded_healshare
	
	local target_ally_owner			= Managers.player:unit_owner(target_ally_unit)
	if target_ally_owner and not target_ally_owner.bot_player then
		return find_best_healer(target_ally_unit, true)
	end
	
	local bot_list					= {}
	local player_list				= {}
	
	for _,owner in pairs(Managers.player:players()) do
		local status_extension = ScriptUnit.has_extension(owner.player_unit, "status_system")
		local enabled = status_extension and not status_extension:is_disabled()
		if enabled then
			if owner.bot_player then
				table.insert(bot_list, owner.player_unit)
			end
			table.insert(player_list, owner.player_unit)
		end
	end
	
	local team_healshare_receive_potential = 0
	local team_wounded		= false
	local player_data		= {}
	for _,unit in pairs(player_list) do
		local data				= {}
		data.is_bot				= Managers.player:unit_owner(unit).bot_player
		local health_extension	= ScriptUnit.has_extension(unit, "health_system")
		data.hp_missing			= (health_extension and health_extension.damage) or 0
		data.hp_max				= (health_extension and health_extension.health) or 100
		data.hp_current			= data.hp_max - data.hp_missing
		local item_info			= get_equipped_item_info(unit)
		data.medkit				= item_info.medkit
		data.draught			= item_info.draught
		data.grim				= item_info.grim
		local status_extension	= ScriptUnit.has_extension(unit, "status_system")
		data.wounded			= (status_extension and not status_extension:has_wounds_remaining() and true) or false
		local buff_extension	= ScriptUnit.has_extension(unit, "buff_system")
		data.dove				= (buff_extension and buff_extension:has_buff_type("heal_self_on_heal_other") and true) or false
		data.healshare			= (buff_extension and buff_extension:has_buff_type("medpack_spread_area") and true) or false
		
		-- if this bot is already healing or healsharing the target ally then select this bot automatically as the best healer
		local healer_pos		= POSITION_LOOKUP[unit]
		local target_pos		= POSITION_LOOKUP[target_ally_unit]
		local target_distance	= (healer_pos and target_pos and Vector3.distance(healer_pos, target_pos)) or math.huge
		local blackboard		= Unit.get_data(unit, "blackboard")
		local targeting_ally	= blackboard and blackboard.target_ally_unit == target_ally_unit
		local is_healing_ally	= blackboard and blackboard.is_healing_other == true
		local is_healsharing	= blackboard and blackboard.is_healing_self == true and data.healshare and target_distance < 15
		if (targeting_ally and is_healing_ally) then
			return unit, false
		elseif is_healsharing then
			return unit, unit
		end
		
		data.healshare_receive_potential	= data.hp_missing * 0.2
		data.medkit_receive_potential		= data.hp_missing * 0.8
		data.draught_self_potential			= math.min(75, data.hp_missing)
		data.medkit_self_potential			= data.medkit_receive_potential
		
		team_wounded						= team_wounded or data.wounded
		team_healshare_receive_potential	= team_healshare_receive_potential + data.healshare_receive_potential
		player_data[unit] = data
	end

	-- find out the best healer for target_ally_unit
	local target_data			= player_data[target_ally_unit]
	local best_healer			= false
	local target_override		= false		
	local best_heal_potential	= 0
	local target_pos			= POSITION_LOOKUP[target_ally_unit]
	--
	if not target_data then
		return false, false
	end
	
	if not (target_data.draught or target_data.medkit) then
		-- the target has no heal on hand >> someone else (bot) needs to heal it >> use the auto heal function to find one
		return find_best_healer(target_ally_unit, true)
		--
	elseif target_data.dove and target_data.medkit then
		-- if the bot has dove then its better to find someone else to heal with the medkit
		local best_heal_target = false
		local most_health_missing = 0
		for _,unit in pairs(player_list) do
			local unit_pos = POSITION_LOOKUP[unit]
			local distance = (unit_pos and target_pos and Vector3.distance(unit_pos, target_pos)) or math.huge
			if unit ~= target_ally_unit and distance < max_healing_distance then
				local wounded_weight	= (player_data[unit].wounded and player_data[unit].hp_current) or 0
				local grim_multiplier	= (player_data[unit].grim and 1.2) or 1
				local missing_hp		= (player_data[unit].hp_missing + wounded_weight) * grim_multiplier
				if player_data[unit].hp_missing > most_health_missing then
					best_heal_target	= unit
					most_health_missing	= player_data[unit].hp_missing
				end
			end
		end
		
		if best_heal_target then
			-- the target_ally_unit heals someone else instead of themself
			best_healer		= target_ally_unit
			target_override	= best_heal_target
		else
			-- no hurt teammates around >> use the medkit on self
			best_healer = target_ally_unit
		end
		--
	elseif target_data.healshare then
		if healshare_needs_wounded then
			-- check if there are extra heals lying around
			local extra_draught_nearby = false
			local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
			local available_pickups	= ai_bot_group_system._available_health_pickups
			for pickup_unit, info in pairs(available_pickups) do
				local pickup_extension = ScriptUnit.has_extension(pickup_unit, "pickup_system")
				local pickup_name = (pickup_extension and pickup_extension.pickup_name) or ""
				if Unit.alive(pickup_unit) and pickup_name == "healing_draught" then
					local human_near_with_empty_slot, human_can_reach_heal = check_players_near_pickup(pickup_unit, 20)
					local heal_pos = POSITION_LOOKUP[pickup_unit]
					local heal_distance = (heal_pos and target_pos and Vector3.distance(heal_pos, target_pos)) or math.huge
					if not human_near_with_empty_slot and human_can_reach_heal and heal_distance < 5 then
						extra_draught_nearby = true
					end
				end
			end
			
			if extra_draught_nearby then
				return target_ally_unit, false
			end
			
			-- check if there are wounded near the healshare carrier (withing the healshare range)
			-- also check if there is another bot nearby that can heal this bot
			local wounded_count = 0
			local ally_can_heal = false
			for _,unit in pairs(player_list) do
				local unit_pos = POSITION_LOOKUP[unit]
				local distance = (unit_pos and target_pos and Vector3.distance(unit_pos, target_pos)) or math.huge
				if distance < 15 and player_data[unit].wounded then
					wounded_count = wounded_count + 1
				end
				
				if distance < max_healing_distance and player_data[unit].is_bot and player_data[unit].medkit then
					ally_can_heal = true
				end
			end
			
			if wounded_count > 0 or not ally_can_heal then
				-- use the heal on self
				best_healer = target_ally_unit
			else
				-- use auto heal function to find a healer
				return find_best_healer(target_ally_unit, true)
			end
				
			
		else
			-- use auto heal function to find a healer
			return find_best_healer(target_ally_unit, true)
		end
	else
		-- use the heal on self
		best_healer = target_ally_unit
	end
	
	return best_healer, target_override
	
end

local find_best_human_to_receive_draught = function(unit)
	local humans	= Managers.player:human_players()
	local allies	= Managers.player:players()
	local giver_pos	= POSITION_LOOKUP[unit]
	
	local best_score = -1
	local best_unit = nil
	for _,owner in pairs(humans) do
		repeat
			local unit			= owner.player_unit
			local pos			= POSITION_LOOKUP[unit]
			if not pos or not giver_pos or Vector3.distance(pos, giver_pos) > bot_settings.menu_settings.max_healing_distance then break end
			if utils:get_unit_data(unit, "disabled") then break end
			if utils:get_unit_data(unit, "heal_item") ~= "" then break end
			local potion_name	= utils:get_unit_data(unit, "potion_item")
			local grim			= potion_name and potion_name == "wpn_grimoire_01"
			local hp_percent	= utils:get_unit_data(unit, "hp_percent")
			local wounded		= utils:get_unit_data(unit, "wounded")
			local healshare		= utils:get_unit_data(unit, "healshare")
			local healshare_priority = false
			
			if healshare then
				-- this human has a healshare
				local healshare_pos = POSITION_LOOKUP[unit]
				local wounded_count = 0
				for _,owner in pairs(allies) do
					local unit = owner.player_unit
					if not utils:get_unit_data(unit, "disabled") and utils:get_unit_data(unit, "wounded") then
						local pos = POSITION_LOOKUP[unit]
						local distance = (healshare_pos and pos and Vector3.distance(pos, healshare_pos)) or math.huge
						if distance < 15 then
							wounded_count = wounded_count +1
						end
					end
				end
				
				if wounded_count > 1 then
					healshare_priority = true
				end
			end
			
			local score = 1-hp_percent
			score = (wounded and score +2) or score
			score = (wounded and grim and score +4) or score
			score = (healshare_priority and score +8) or score
			
			if score > best_score then
				best_score	= score
				best_unit	= unit
			end
			
		until true
	end
	
	-- priority = 
	-- healshare (if 2+ wounded allies near healshare)
	-- wounded grim
	-- wounded
	-- least hp
	
	return best_unit
end

-- **************************************************************
-- ************* hookrat has been busy here (hooks) *************
-- **************************************************************

-- Fix to bot (and third person mod) beam & drakefire bugged particle effects
-- 
-- By VernonKun
--
-- ThirdPersonBotBeamDrakeParticleFix
Mods.hook.set(mod_name, "ActionBeam.client_owner_start_action", function(func, self, new_action, t)
	func(self, new_action, t)
	
	local owner_unit = self.owner_unit
	local owner_player = owner_unit and Managers.player:owner(owner_unit)
	local is_bot = owner_player and owner_player.bot_player
	local is_third_person_mod = Mods.ThirdPerson and Mods.ThirdPerson.SETTINGS and Mods.ThirdPerson.SETTINGS.ACTIVE and Mods.ThirdPerson.SETTINGS.ACTIVE.save and Application.user_setting(Mods.ThirdPerson.SETTINGS.ACTIVE.save)
	
	if is_bot or is_third_person_mod then
		if self.beam_effect then
			World.destroy_particles(self.world, self.beam_effect)
			self.beam_effect = nil
		end
		
		local world = self.world
		local beam_effect_3p = new_action.particle_effect_trail_3p
		if world and beam_effect_3p then
			self.beam_effect = World.create_particles(world, beam_effect_3p, Vector3.zero())
			self.beam_effect_length_id = World.find_particles_variable(world, beam_effect_3p, "trail_length")
		end
	end
end)

Mods.hook.set(mod_name, "ActionCharge.client_owner_start_action", function(func, self, new_action, t)
	func(self, new_action, t)
	
	local owner_unit = self.owner_unit
	local owner_player = owner_unit and Managers.player:owner(owner_unit)
	local is_bot = owner_player and owner_player.bot_player
	local is_third_person_mod = Mods.ThirdPerson and Mods.ThirdPerson.SETTINGS and Mods.ThirdPerson.SETTINGS.ACTIVE and Mods.ThirdPerson.SETTINGS.ACTIVE.save and Application.user_setting(Mods.ThirdPerson.SETTINGS.ACTIVE.save)
	
	if is_bot or is_third_person_mod then
		if self.particle_id then
			World.destroy_particles(self.world, self.particle_id)
			self.particle_id = nil
		end

		if self.left_particle_id then
			World.destroy_particles(self.world, self.left_particle_id)
			self.left_particle_id = nil
		end
	end
end)
-- \ThirdPersonBotBeamDrakeParticleFix

--[[
	Prioritize Saltzpyre bot over Sienna when choosing which bots will be spawned. By Walterr.

	Only one line of this function is modified, but I have to replace the whole thing ...
	
	-- Xq, modified so that player may choose least preferred bot instead of just Saltzpyre / Sienna choice
--]]
SpawnManager._update_available_profiles = function (self, profile_synchronizer, available_profile_order, available_profiles)
	local delta = 0
	local bots = 0
	local humans = 0

	-- (1=WH, 2=BW, 3=DR, 4=WE, 5=ES).
	local bot_to_avoid = get(me.SETTINGS.BOT_TO_AVOID) or 1
	local profile_indexes = {}
	for i=1,5 do
		if i ~= bot_to_avoid then
			table.insert(profile_indexes, i)
		end
	end
	table.insert(profile_indexes, bot_to_avoid)	-- the last one is left out
	
	for _,profile_index in ipairs(profile_indexes) do
		local owner_type = profile_synchronizer.owner_type(profile_synchronizer, profile_index)

		if owner_type == "human" then
			humans = humans + 1
			local index = table.find(available_profile_order, profile_index)

			if index then
				table.remove(available_profile_order, index)

				available_profiles[profile_index] = false
				delta = delta - 1
			end
		elseif (owner_type == "available" or owner_type == "bot") and not table.contains(available_profile_order, profile_index) then
			table.insert(available_profile_order, 1, profile_index)

			available_profiles[profile_index] = true
			delta = delta + 1
		end

		if owner_type == "bot" then
			bots = bots + 1
		end
	end

	if self._forced_bot_profile_index then
		local forced_bot_profile_index = self._forced_bot_profile_index
		local index = table.find(available_profile_order, forced_bot_profile_index)
		local available = (index and profile_synchronizer.owner_type(profile_synchronizer, forced_bot_profile_index) == "available") or false

		fassert(available, "Bot profile (%s) is not available!", SPProfilesAbbreviation[forced_bot_profile_index])

		if index ~= 1 then
			available_profile_order[index] = available_profile_order[1]
			available_profile_order[1] = available_profile_order[index]
		end
	end

	return delta, humans, bots
end

--[[
	Will make the bots stick closer to players, especially during swarms. By Walterr.
--]]
-- this hook should be mostly obsolete now.. TODO: check it
--[[
Mods.hook.set(mod_name, "AISystem.update_brains", function (func, self, ...)
	local result = func(self, ...)

	-- if get(me.SETTINGS.FILE_ENABLED) then
		-- local fight_melee = BotActions.default.fight_melee
		-- local aggro_level = (self.number_ordinary_aggroed_enemies * 2 / 3)
		-- fight_melee.engage_range_near_follow_pos = math.max(3, 15 - aggro_level)
		-- fight_melee.engage_range = math.max(3, 6 - aggro_level)
		-- fight_melee.engage_range_near_follow_pos_horde = math.max(3, 9 - aggro_level)
		
		-- -- added Xq
		-- local fight_melee_priority_target = BotActions.default.fight_melee_priority_target
		-- fight_melee_priority_target.engage_range = 14
		-- fight_melee_priority_target.engage_range_near_follow_pos = 14
		-- fight_melee_priority_target.override_engage_range_to_follow_pos = 14
		-- fight_melee_priority_target.override_engage_range_to_follow_pos_horde = 14
	-- end
	
	return result
end)
--]]

local dodge_is_blocked_by_map = function(unit, unit_pos, dodge_pos)
	if not dodge_pos then
		return true
	end
	
	local nav_world = Managers.state.bot_nav_transition._nav_world
	local traverse_logic = Managers.state.bot_nav_transition._traverse_logic
	local above		= 0.75	--1
	local below		= 0.75	--1
	local success, z = GwNavQueries.triangle_from_position(nav_world, dodge_pos, above, below)
	if not success then
		return true
	else
		if not unit_pos then
			return true
		end
		
		dodge_pos.z = z
		local mover = Unit.mover(unit)
		
		if not GwNavQueries.raycango(nav_world, unit_pos, dodge_pos, traverse_logic) or not Mover.fits_at(mover, dodge_pos + Vector3(0,0,0.2)) then
			return true
		end
	end
	
	return false
end

-- Vernon: add some fuzziness in the logic so bots don't keep stepping at one spot
-- Vernon: expire time is based on move speed 4m/s
local map_too_tight_last_check = {}

local map_too_tight = function(d)
	-- Vernon: if the bot can't dodge back or can't dodge in >=2 directions, move towards the boss (ogre only?) to not get surrounded
	if not d then
		return false
	end
	
	if map_too_tight_last_check[d.unit] and d.current_time <= map_too_tight_last_check[d.unit].expire then
		return map_too_tight_last_check[d.unit].result
	elseif map_too_tight_last_check[d.unit] and map_too_tight_last_check[d.unit].expire < d.current_time then
		map_too_tight_last_check[d.unit] = nil
	end
	
	local back_distance_to_check = 3	--2
	local side_distance_to_check = 2.5	--2
	
	local self_rot = Unit.local_rotation(d.unit, 0)		-- Vernon: this should be a "flat" rotation from testing
	local direction = Quaternion.forward(self_rot)
	
	local back_pos = d.position + back_distance_to_check * direction
--[[
	local success, z = GwNavQueries.triangle_from_position(nav_world, back_pos, above, below)
	if not success then
		return true
	else
		back_pos.z = z
		local mover = Unit.mover(d.unit)
		
		if not GwNavQueries.raycango(nav_world, d.position, back_pos, traverse_logic) or not Mover.fits_at(mover, back_pos + Vector3(0,0,0.2)) then
			return true
		end
	end
--]]
	if dodge_is_blocked_by_map(d.unit, d.position, back_pos) then
		map_too_tight_last_check[d.unit] = {
			result = true,
			expire = d.current_time + 0.5 + 0.4 * math.random()
		}
		
		return true
	end
	
	local left_dir = Vector3(-direction.y, direction.x, 0)
	local left_pos = d.position + side_distance_to_check * left_dir
	local right_pos = d.position - side_distance_to_check * left_dir
	
	if dodge_is_blocked_by_map(d.unit, d.position, left_pos) and dodge_is_blocked_by_map(d.unit, d.position, right_pos) then
		map_too_tight_last_check[d.unit] = {
			result = true,
			expire = d.current_time + 0.5 + 0.4 * math.random()
		}
		
		return true
	end
	
	map_too_tight_last_check[d.unit] = {
		result = false,
		expire = d.current_time + 0.25	--0.1	--0.25
	}
	
	return false
end

-- prevent bots from trying to close the distance and melee certain distant enemies
Mods.hook.set(mod_name, "PlayerBotBase._enemy_path_allowed", function (func, self, enemy_unit)
	local breed = enemy_unit and Unit.get_data(enemy_unit, "breed")
	local self_unit = self._unit
	local target_unit = enemy_unit
	
	if not breed then
		return func(self, enemy_unit)
	end
	
	if (breed == Breeds.skaven_ratling_gunner and get(me.SETTINGS.NO_CHASE_RATLING)) or (breed == Breeds.skaven_poison_wind_globadier and get(me.SETTINGS.NO_CHASE_GLOBADIER)) then
		return false
	elseif breed.name == "skaven_rat_ogre" or breed.name == "skaven_storm_vermin_champion" then
	-- elseif breed.name == "skaven_storm_vermin_champion" then
		-- melee combat positioning handles bot position when the ogre/Krench gets close enough..
		-- No need for the bots to melee rush an ogre/Krench that approaches from the distance!
		-- return false
		
		-- Vernon: add map geometry conditions
		-- Vernon TODO: add conditions on ogre HP
		local d = get_d_data(self_unit)
		if not d then
			return func(self, enemy_unit)
		end
		
		return map_too_tight(d)
	end

	return func(self, enemy_unit)
end)

-- prevent bots from seeking cover from ratling fire, no changes to this hook from QoL
Mods.hook.set(mod_name, "PlayerBotBase._in_line_of_fire", function(func, ...)
	if get(me.SETTINGS.NO_SEEK_COVER) then
		return false, false
	end

	return func(...)
end)

local update_target_enemy_frame_checker = new_frame_checker()
Mods.hook.set(mod_name, "PlayerBotBase._update_target_enemy", function(func, self, dt, t)
	local self_unit		= self._unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local active_bots	= Managers.player:bots()
	
	-- update menu setting states
	bot_settings.menu_settings:update()
	
	if self_unit == nil or self_owner == nil or not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, dt, t)
	end
	
	-- get and update d_data
	local d = get_d_data(self_unit)
	
	if not d then
		return func(self, dt, t)
	end 
	
	Profiler.start("update target enemy")

	-- While I generally don't use the data generated by these functions I'll leave the calls active in case something else in the code uses it.
	local pos = POSITION_LOOKUP[self._unit]
	
	Profiler.start("update_slot_target")
	self:_update_slot_target(dt, t, pos)
	Profiler.stop("update_slot_target")
	Profiler.start("update_proximity_target")
	self:_update_proximity_target(dt, t, pos)
	Profiler.stop("update_proximity_target")
	
	-- update offensive scalers
	local cap_melee = bot_settings.menu_settings.cap_melee
	local cap_ranged = bot_settings.menu_settings.cap_ranged
	local bot_count, human_count, bot_list, human_list = get_able_bot_human_data()
	local new_frame = update_target_enemy_frame_checker:is_new_frame()
	local offense_token_passive_cap = bot_settings.scaler_data.offense_token_passive_cap * bot_settings.scaler_data:get_difficulty_modifier_life()
	--edit start--
	-- Vernon TODO: testing
	-- bot_settings.scaler_data.offense_tokens = 1000
	-- local offense_scaler_melee_multiplier = math.clamp(((bot_settings.scaler_data.offense_tokens / 2) / offense_token_passive_cap),0,cap_melee)
	local offense_scaler_melee_multiplier = math.clamp(((bot_settings.scaler_data.offense_tokens / 1.25) / offense_token_passive_cap),0,cap_melee)
	--edit end--
	local offense_scaler_ranged_multiplier = 0
	if new_frame then
		update_target_enemy_frame_checker:update()
		local offense_ranged_scaling_start	= bot_settings.scaler_data.offense_ranged_scaling_start * bot_settings.scaler_data:get_difficulty_modifier_life()
		local offense_ranged_scaling_stop	= bot_settings.scaler_data.offense_ranged_scaling_stop * bot_settings.scaler_data:get_difficulty_modifier_life()
		offense_scaler_ranged_multiplier = math.clamp(((bot_settings.scaler_data.offense_tokens - offense_ranged_scaling_start)/(offense_ranged_scaling_stop - offense_ranged_scaling_start)),0,cap_ranged)
		bot_settings.scaler_data.offense_ranged_range = offense_scaler_ranged_multiplier * bot_settings.trash_SV_detection_distance
		d.ranged_attack_allowed = d.current_time >= d.last_ranged_kill + (bot_settings.scaler_data.offense_max_delay_ranged * (1-offense_scaler_ranged_multiplier))
		
		if t >= bot_settings.scaler_data.offense_time_pool_timer then
			bot_settings.scaler_data.offense_time_pool_timer = math.max(bot_settings.scaler_data.offense_time_pool_timer+1,t-5)
			bot_settings.scaler_data.offense_time_pool = bot_settings.scaler_data.offense_time_pool + offense_scaler_melee_multiplier
			local melee_time_factor = math.clamp(bot_settings.scaler_data.offense_time_pool,0,1)
			for _,loop_unit in pairs(bot_list) do
				local loop_d = get_d_data(loop_unit)
				if loop_d then
					if math.random() < melee_time_factor then
						loop_d.melee_attack_allowed = true
						bot_settings.scaler_data.offense_time_pool = bot_settings.scaler_data.offense_time_pool - 1/bot_count
					else
						loop_d.melee_attack_allowed = false
					end
				end
			end
		end
		
		if t > bot_settings.scaler_data.damage_taken_debt_trasfer_next_tick then
			while bot_settings.scaler_data.damage_taken_debt_trasfer_next_tick <= t do
				bot_settings.scaler_data.damage_taken_debt_trasfer_next_tick = bot_settings.scaler_data.damage_taken_debt_trasfer_next_tick + 1
			end
			local factor		= bot_settings.scaler_data.damage_taken_debt_trasfer_factor
			local tick_min		= math.min(bot_settings.scaler_data.damage_taken_debt_trasfer_min, math.max(bot_settings.scaler_data.damage_taken_debt_buffer,0))
			local tick_max		= bot_settings.scaler_data.damage_taken_debt_trasfer_max
			local tick_value	= math.clamp(bot_settings.scaler_data.damage_taken_debt_buffer * factor, tick_min, tick_max)
			bot_settings.scaler_data.damage_taken_debt			= bot_settings.scaler_data.damage_taken_debt + tick_value
			bot_settings.scaler_data.damage_taken_debt_buffer	= bot_settings.scaler_data.damage_taken_debt_buffer - tick_value
			
		end
		
		-- check for tokens lost due to despawning bots
		local total_take_damage_token_count = 0
		for key, data in pairs(bot_settings.scaler_data.damage_taken_token_table) do
			if not Unit.alive(key) then
				bot_settings.scaler_data.damage_taken_token_table[key] = nil
				bot_settings.scaler_data.damage_taken_token_available = bot_settings.scaler_data.damage_taken_token_available + 1
			else
				total_take_damage_token_count = total_take_damage_token_count + 1
			end
		end
		total_take_damage_token_count = total_take_damage_token_count + bot_settings.scaler_data.damage_taken_token_available
		
		for key, data in pairs(bot_settings.scaler_data.specials_release_denied) do
			if not Unit.alive(key) then
				bot_settings.scaler_data.specials_release_denied[key] = nil
			end
		end
	end
	
	d.offense_scaler_melee_multiplier = offense_scaler_melee_multiplier
	d.offense_scaler_ranged_multiplier = offense_scaler_ranged_multiplier
	
	if ENABLE_DEBUG_FEEDS and get_hotkey_state("0") then
		local scaler_data = bot_settings.scaler_data
		if not bot_settings.scaler_data.debug_key_0 then
			EchoConsole("-------------------------------")
			EchoConsole("Off. tokens / cap: " .. number_to_string(bot_settings.scaler_data.offense_tokens / offense_token_passive_cap,2))
			EchoConsole("Bot attack% melee:" .. number_to_string(offense_scaler_melee_multiplier * 100,2))
			EchoConsole("Bot attack% ranged:" .. number_to_string(offense_scaler_ranged_multiplier * 100,2))
			EchoConsole("Bot specials balance:" .. number_to_string(bot_settings.scaler_data.bot_specials_balance,2))
			EchoConsole("Human damage taken:" .. number_to_string(scaler_data.damage_taken_human_average,2))
			EchoConsole("Human damage taken buffered:" .. number_to_string(scaler_data.damage_taken_buffer,2))
			EchoConsole("Bot damage taken:" .. number_to_string(scaler_data.damage_taken_bot_average,2))
			EchoConsole("Bot damage taken goal:" .. number_to_string(scaler_data.damage_taken_debt_cumulative,2))
			bot_settings.scaler_data.debug_key_0 = true
		end
	else
		bot_settings.scaler_data.debug_key_0 = false
	end
	
	-- reload ranged weapon if idle and reload is needed
	--edit start--
	-- if d.equipped.heat_weapon then
		-- vent_bot_ranged_weapon(d, false)
	-- else
		-- reload_bot_ranged_weapon(d)
	-- end
	--edit end--
	
	-- at the start of the map, briefly force wield ranged weapon to ensure melee weapon static buffs get loaded properly
	if d.ranged_not_yet_wielded then
		if d.extensions_ready then
			d.extensions.input:wield("slot_ranged")
			local current_slot = d.extensions.inventory:get_wielded_slot_name()
			if current_slot == "slot_ranged" then
				d.ranged_not_yet_wielded = false
			end
		end
	end
	
	local current_time = d.current_time
	-- clear item trading list id more than 3s has passed since last trade
	if current_time-bot_settings.trading.last_trade_time > 3 then
		bot_settings.trading.wasjusttraded = {}
	end
	
	-- check if token boost is needed
	if bot_settings.scaler_data:offense_token_tick_boost_enabled() then
		bot_settings.scaler_data.offense_token_tick_boost_end_time = current_time + 2
	end
	
	
	if current_time > bot_settings.scaler_data.next_offense_token_tick then
		bot_settings.scaler_data.next_offense_token_tick = current_time + 1
		local offense_token_difficulty_scaling = bot_settings.scaler_data:get_difficulty_modifier_life()
		local tick_strength = bot_settings.scaler_data.offense_token_tick * offense_token_difficulty_scaling
		local tick_cap = offense_token_passive_cap
		
		if current_time <= bot_settings.scaler_data.offense_token_tick_boost_end_time then
			tick_strength	= bot_settings.scaler_data.offense_token_tick_objective * offense_token_difficulty_scaling
			tick_cap		= bot_settings.scaler_data.offense_token_passive_cap_objective * offense_token_difficulty_scaling
		end
		
		if bot_settings.scaler_data.offense_tokens < tick_cap then
			bot_settings.scaler_data:add_offense_tokens(tick_strength)
		end
	end
	
	
	local alive_bosses				= d.enemies.bosses
	local alive_specials			= d.enemies.specials
	local players					= Managers.player:players()				-- table of entities (priority targets are gutters / packmasters that stab/drag players in the default system)
	local bot_count					= #active_bots
	
	
	local blackboard				= self._blackboard
	local self_pos					= d.position
	local follow_unit				= d.follow_target
	local follow_unit_pos			= d.follow_target_position
	local self_anti_armor			= d.equipped.anti_armor
	local defend_pos				= (d.objective_defence.enabled and d.objective_defence.position) or d.position
	local prox_enemies				= d.enemies.far
	local near_enemies				= d.enemies.near
	local priority_enemy			= blackboard.priority_target_enemy
	local sniper_target_selection	= d.equipped.ranged and not d.settings.snipers_shoot_trash and d.equipped.sniper
	
	
	-- check for available brakable objectives
	for key,data in pairs(bot_settings.breakable_objectives) do
		if Unit.alive(data.unit) and data.health_extension:is_alive() and data.health_extension:current_health_percent() >= bot_settings.menu_settings.breakables_objectives_threshold and bot_settings.menu_settings.help_with_breakables_objectives then
			if data.area:in_area(d.position) then
				-- bot is within range of one >> make it the bot's breakable target
				blackboard.breakable_object = data.unit
				break
			end
		else
			-- this breakable objective has been destroyed or too heavily damaged >> remove it from the list
			if blackboard.breakable_object == data.unit then
				blackboard.breakable_object = nil
			end
			bot_settings.breakable_objectives[key] = nil
			-- debug_print_variables("Removed destroyed breakable objective", data.unit)
		end
	end
	
	--edit start--
	-- reload ranged weapon if idle and reload is needed
	if not blackboard.breakable_object then
		if d.equipped.heat_weapon then
			vent_bot_ranged_weapon(d, false)
		else
			reload_bot_ranged_weapon(d)
		end
	end
	--edit end--
	
	-- check that the current target exists and is alive
	local target_alive = is_unit_alive(d.melee.target_unit)
	if not target_alive then
		d.melee.target_unit = nil
		blackboard.target_unit = nil
	end
	
	if follow_unit then
		forced_bot_teleport(self_unit, is_forced_teleport_needed(self_unit, follow_unit))
		--edit start--
		d.token.jump = d.token.jump or is_forced_jump_needed(self_unit)
		--edit end--
	end
	
	local separation_check_units = {}
	for _,loop_player in pairs(players) do
		local loop_unit	= loop_player.player_unit
		local loop_pos	= POSITION_LOOKUP[loop_unit]
		local loop_dist	= self_pos and loop_pos and Vector3.distance(self_pos, loop_pos)
		if loop_dist and loop_dist < 7 and Unit.alive(loop_unit) then
			table.insert(separation_check_units, loop_unit)
		end
	end
	
	-- determine the closest trash rat / stormvermin
	local separation_threat	=
	{
		unit = nil,
		distance = math.huge,
		human = false
	}
	local closest_trash	=
	{
		unit = nil,
		distance = math.huge
	}
	
	--edit--
	local closest_trash_threat =
	{
		unit = nil,
		distance = math.huge
	}
	--edit--
	
	local closest_sv =
	{
		unit = nil,
		distance = math.huge
	}
	
	--edit--
	local closest_sv_threat =
	{
		unit = nil,
		distance = math.huge
	}
	--edit--
	
	local closest_special =
	{
		unit = nil,
		distance = math.huge,
		immediate_threat = false
	}
	local closest_boss =
	{
		unit		= nil,
		distance	= math.huge,
		targets_me	= false,
		flanking	= false,
		warded		= false,
	}
	
	if not self_owner.specials_awareness then
		self_owner.specials_awareness = {}
	end
	
	local cap_specials = bot_settings.menu_settings.cap_specials
	local detected_specials = {}
	local special_is_alive = {}
	
	d.defense.assassin_on_field = false
	
	-- update specials preception data
	local MIN_DETECTION_TIME = 0.5
	local MAX_DETECTION_TIME = 4
	for _,loop_unit in pairs(alive_specials) do
		local loop_breed		= Unit.get_data(loop_unit, "breed")
		local is_pack_master	= loop_breed.name == "skaven_pack_master"
		local is_gutter_runner	= loop_breed.name == "skaven_gutter_runner"
		local is_ratling_gunner	= loop_breed.name == "skaven_ratling_gunner"
		local is_globadier		= loop_breed.name == "skaven_poison_wind_globadier"
		local loop_los			= check_line_of_sight(self_unit, loop_unit)
		local ping_extension	= ScriptUnit.has_extension(loop_unit, "ping_system")
		local is_pinged			= (ping_extension and ping_extension._pinged) or false
		
		if is_pinged then
			bot_settings.scaler_data.specials_pinged_by_human[loop_unit] = true
			if not bot_settings.scaler_data.specials_lookup.initiative[loop_unit] then
				bot_settings.scaler_data.specials_lookup.initiative[loop_unit] = "human"
			end
		end
		
		-- generate reverse lookup for alive specials
		special_is_alive[loop_unit] = true
		
		-- initialize the array element if needed
		if self_owner.specials_awareness[loop_unit] == nil then
			self_owner.specials_awareness[loop_unit] = 0
		end
		
		-- TODO: check this
		-- local perception_scaler_min = 0 -- MIN_DETECTION_TIME / MAX_DETECTION_TIME
		local perception_scaler_min = MIN_DETECTION_TIME / MAX_DETECTION_TIME
		
		if loop_los then
			-- if the special is visible to the bot >> build up awareness
			local loop_pos			= POSITION_LOOKUP[loop_unit]
			local loop_offset		= self_pos and loop_pos and loop_pos - self_pos
			local loop_dist			= (loop_offset and Vector3.length(loop_offset)) or 1
			
			local perception_scaler = 1
			local balance_factor	= 1
			local balance_settings	= bot_settings.scaler_data.specials_lookup.balance_settings[1]
			if loop_dist > 1 then
				local specials_balance_max	= bot_settings.scaler_data.bot_specials_balance_effective_max
				local specials_balance_min	= bot_settings.scaler_data.bot_specials_balance_effective_min
				local clamp_max				= specials_balance_max
				local clamp_min				= specials_balance_min + ((specials_balance_max - specials_balance_min) * (1 - cap_specials))
				local bot_specials_balance = math.clamp(bot_settings.scaler_data.bot_specials_balance, clamp_min, clamp_max)
				balance_factor = math.max(bot_specials_balance,1)
				local balance_index = 3
				if bot_settings.scaler_data.bot_specials_balance > clamp_max then
					balance_index = 5
				elseif bot_settings.scaler_data.bot_specials_balance < clamp_min then
					balance_index = 1
				else
					balance_index = math.floor(((bot_specials_balance - clamp_min) / (clamp_max - clamp_min)) * (5-1)) + 1
				end
				balance_settings = bot_settings.scaler_data.specials_lookup.balance_settings[balance_index] or balance_settings
				local scaled_max_detection_time = MAX_DETECTION_TIME * balance_factor
				
				-- update the perception_scaler_min to reflect the current scaling factor
				perception_scaler_min = MIN_DETECTION_TIME / scaled_max_detection_time
				
				local self_rot = Unit.local_rotation(self_unit, 0)
				local self_dir = Quaternion.forward(self_rot)	-- should produce already normalized vector
				local loop_cos = Vector3.dot(Vector3.normalize(self_dir), Vector3.normalize(loop_offset))	-- 1 = dead ahead, -1 = right behind
				local loop_scaler = 1.4 ^ balance_settings.vision_index	-- bot_specials_balance
				local loop_scaled_cos = math.cos(math.min(math.acos(loop_cos) * loop_scaler, math.pi))	-- range = 1 .. -1
				perception_scaler = ((loop_scaled_cos+1)/2)^1.2		-- range = 1..0
				perception_scaler = (1-perception_scaler_min) * perception_scaler + perception_scaler_min	-- 1 .. perception_scaler_min
			end
			
			if is_pack_master and loop_dist < 7 then	-- humans can hear nearby pack master (unless it bugs) why bots would be any different
				-- effectively guarantees the packmaster to be detected in maximum of 0.5s (scaled with current balance)
				local max_time = 0.5 * balance_factor
				perception_scaler = math.max(perception_scaler, MIN_DETECTION_TIME / max_time)
				--
			elseif is_gutter_runner then	-- the bot has "heard" gutter que so it pays extra attention to surroundings
				-- effectively gives minimum detection time down to 50% of normal minimum
				local max_time = MIN_DETECTION_TIME * (balance_factor^1.861)
				perception_scaler = math.max(perception_scaler*2,MIN_DETECTION_TIME / max_time)
				
				d.defense.assassin_on_field = true
				--
			elseif is_ratling_gunner then	-- ratlings are detected fast when they are shooting
				local loop_bb = Unit.get_data(loop_unit, "blackboard")
				if loop_bb.move_state == "attacking" then
					-- effectively guarantees the shooting ratling to be detected in maximum of 0.5s (scaled with current balance)
					local max_time = 0.5 * (balance_factor^1.861)
					perception_scaler = math.max(perception_scaler, MIN_DETECTION_TIME / max_time)
				end
				--
			end
			
			-- guarantee minimum detection speed
			if perception_scaler < perception_scaler_min then
				perception_scaler = perception_scaler_min
			end
			
			-- scaling overrides normal minimums
			if loop_dist > balance_settings.vision_distance or
			   (balance_settings.must_have_dealt_damage and not bot_settings.scaler_data.specials_lookup.has_dealt_damage[loop_unit]) then
				perception_scaler = 0
			end
			
			-- if the enemy is pinged then it will be detected at maximum rate, regardless of scaling
			if is_pinged and not bot_settings.menu_settings.ignore_specials_pings then
				-- bots can shoot PINGED gas rats as fast as they can due to the near instant throws they can do
				local pinged_detection_time = (is_globadier and 0.05) or MIN_DETECTION_TIME
				perception_scaler = math.max(perception_scaler, MIN_DETECTION_TIME / pinged_detection_time)
			end
			
			if self_owner.specials_awareness[loop_unit] == nil then
				self_owner.specials_awareness[loop_unit] = (dt * perception_scaler)
			elseif self_owner.specials_awareness[loop_unit] < 5 then
				self_owner.specials_awareness[loop_unit] = self_owner.specials_awareness[loop_unit] + (dt * perception_scaler)
			end
		else
			-- the special is not visible >> awareness decays slowly
			self_owner.specials_awareness[loop_unit] = self_owner.specials_awareness[loop_unit] - (dt * (1/8))
			if self_owner.specials_awareness[loop_unit] < 0 then
				self_owner.specials_awareness[loop_unit] = 0
			end
		end
		
		local may_target_disabler = bot_settings.scaler_data:is_allowed_to_release_from_disabler(loop_unit)
		
		if may_target_disabler and self_owner.specials_awareness[loop_unit] >= MIN_DETECTION_TIME then
			-- the special has been visible long enough >> add it to the detected list
			table.insert(detected_specials, loop_unit)
		end
	end
	
	-- clean dead / removed units from the specials_awareness table
	for loop_unit,_ in pairs(self_owner.specials_awareness) do
		if not Unit.alive(loop_unit) or not special_is_alive[loop_unit] then
			self_owner.specials_awareness[loop_unit] = nil
		end
	end
	
	-- clean dead / removed units from the specials pinged table
	for loop_unit,_ in pairs(bot_settings.scaler_data.specials_pinged_by_human) do
		if not Unit.alive(loop_unit) then
			bot_settings.scaler_data.specials_pinged_by_human[loop_unit] = nil
		end
	end
	
	-- clean dead / removed units from the specials damaged table
	for loop_unit,_ in pairs(bot_settings.scaler_data.specials_damaged_by_human) do
		if not Unit.alive(loop_unit) then
			bot_settings.scaler_data.specials_damaged_by_human[loop_unit] = nil
		end
	end
	
	-- check proximite enemies
	for _,loop_unit in pairs(prox_enemies) do
		local loop_breed		= Unit.get_data(loop_unit, "breed")
		local loop_blackboard	= Unit.get_data(loop_unit, "blackboard")
		local loop_pos			= POSITION_LOOKUP[loop_unit]
		local loop_offset		= defend_pos and loop_pos and loop_pos - defend_pos
		local loop_dist			= loop_offset and Vector3.length(loop_offset)
		local loop_dist_self	= self_pos and loop_pos and Vector3.distance(self_pos, loop_pos)
		local height_modifier	= (math.abs(loop_offset.z) > 0.2 and math.abs(loop_offset.z)*0.75) or 0
		local loop_is_after_me	= loop_blackboard and (loop_blackboard.target_unit == self_unit or loop_blackboard.attacking_target == self_unit or loop_blackboard.special_attacking_target == self_unit)
		local loop_is_attacking_me	= loop_blackboard and (loop_blackboard.attacking_target == self_unit or loop_blackboard.special_attacking_target == self_unit)
		local loop_is_staggered = loop_blackboard and loop_blackboard.stagger and loop_blackboard.stagger > 0
		
		-- add some extra to the check distance of enemies that are far away from other players
		-- to encourage the bots not to spread out too wide
		for _,player in pairs(players) do
			local loop2_unit = player.player_unit
			if Unit.alive(loop2_unit) then
				local loop2_pos = POSITION_LOOKUP[loop2_unit]
				local loop2_dist = (loop2_pos and loop_pos and Vector3.length(loop2_pos - loop_pos)) or 0
				loop_dist = loop_dist + math.max((loop2_dist*0.05),0)
			end
		end
		
		if loop_dist and loop_blackboard and loop_blackboard.target_unit then
			if ((loop_breed.name == "skaven_clan_rat" or loop_breed.name == "skaven_slave") and (not bot_settings.assigned_enemies[loop_unit] or bot_settings.assigned_enemies[loop_unit] == self_unit or #prox_enemies < bot_count or loop_is_after_me)) or (loop_breed.name == "skaven_loot_rat" and loop_dist < bot_settings.skaven_loot_rat.melee_range.default) then
				-- ** trash rats **
				-- if this bot has anti-armor weapon then it should try to avoid unarmored targets if armored ones are close
				if self_anti_armor then loop_dist = loop_dist +1 end
				
				-- if the target is above / below past a threashold then it should be less attractive than targets on the same plane.
				loop_dist = loop_dist + height_modifier
				--
				if loop_dist < closest_trash.distance then
					closest_trash.unit		= loop_unit
					closest_trash.distance	= loop_dist
				end
				
				-- Vernon: if this rat has started attack the bot
				if loop_is_attacking_me and loop_dist < closest_trash_threat.distance then
					closest_trash_threat.unit		= loop_unit
					closest_trash_threat.distance	= loop_dist
				end
			elseif loop_breed.name == "skaven_storm_vermin_commander" or loop_breed.name == "skaven_storm_vermin" then
				-- ** stormvermin **
				-- if this bot does not have anti-armor weapon then it should try to avoid armored targets if unarmored ones are close
				if not self_anti_armor then loop_dist = loop_dist +1 end
				
				-- if the target is above / below past a threashold then it should be less attractive than targets on the same plane.
				loop_dist = loop_dist + height_modifier
				--
				if loop_dist < closest_sv.distance then
					closest_sv.unit		= loop_unit
					closest_sv.distance	= loop_dist
				end
				
				-- Vernon: if this rat has started attack the bot
				if loop_is_attacking_me and loop_dist < closest_sv_threat.distance then
					closest_sv_threat.unit		= loop_unit
					closest_sv_threat.distance	= loop_dist
				end
			end	-- specials / ogres are handled separately
		end
			
		-- find group separation threats
		-- separation threat can be any non-boss enemy unit that is positioned between team members
		for _,separation_check_unit in pairs(separation_check_units) do
			if loop_breed.name ~= "skaven_rat_ogre" and loop_breed.name ~= "skaven_storm_vermin_champion" and loop_dist_self < separation_threat.distance then
				local is_separation_threat = is_positioned_between_self_and_ally(self_unit, separation_check_unit, loop_unit)
				if is_separation_threat then
					separation_threat.unit		= loop_unit
					separation_threat.distance	= loop_dist_self
				end
			end
		end
	end
	
	-- count the amount of nearby trash units that may threaten the bot (=are targeting it)
	local trash_threat_count = #d.defense.threat_stormvermin + #d.defense.threat_trash
	
	-- process special enemy information
	-- Vernon: add info so bots can (try to) dodge packmasters and assassins
	d.defense.need_to_dodge_packmaster = false
	d.defense.need_to_dodge_assassin = false
	d.defense.process_push_jumping_assassin = false
	d.defense.jumping_assassin_distance = math.huge
	d.defense.distance_to_assassin_flight_path = math.huge
	
	d.defense.pos_packmaster_to_dodge = nil
	d.defense.pos_assassin_to_dodge = nil
	local count_packmaster_to_dodge = 0
	local count_assassin_to_dodge = 0
	
	for _,loop_unit in pairs(detected_specials) do
		local loop_breed	= Unit.get_data(loop_unit, "breed")
		local loop_los		= check_line_of_sight(self_unit, loop_unit)
		-- if loop_los and loop_breed then
		if loop_breed and loop_los then
			local loop_pos			= POSITION_LOOKUP[loop_unit]
			local loop_dist			= self_pos and loop_pos and Vector3.distance(self_pos, loop_pos)
			local loop_bb	= Unit.get_data(loop_unit, "blackboard")
			if loop_dist then
				local immediate_threat_range		= (bot_settings[loop_breed.name] and bot_settings[loop_breed.name].immediate_threat_range) or bot_settings.default.immediate_threat_range
				local blocking_melee_distance		= (bot_settings[loop_breed.name] and bot_settings[loop_breed.name].melee_range and bot_settings[loop_breed.name].melee_range.reduced) or 0
				if	(loop_dist < closest_special.distance and closest_trash_threat.distance > blocking_melee_distance) or
					(loop_dist < closest_special.distance and loop_dist < immediate_threat_range and closest_trash_threat.distance > 3) then
					--
					closest_special.unit	 = loop_unit
					closest_special.distance = loop_dist
					--
					local immediate_threat_range_pinged = (bot_settings[loop_breed.name] and bot_settings[loop_breed.name].immediate_threat_range_pinged) or immediate_threat_range
					local ping_extension		= ScriptUnit.has_extension(loop_unit, "ping_system")
					local is_pinged				= (ping_extension and ping_extension._pinged) or false
					if loop_dist < immediate_threat_range or (is_pinged and loop_dist < immediate_threat_range_pinged) then
						closest_special.immediate_threat = true
					end
				end
				
				if bot_settings.scaler_data.bot_specials_balance and bot_settings.scaler_data.bot_specials_balance < 5 then
					if loop_breed.name == "skaven_pack_master" and (loop_bb.target_unit == self_unit or loop_bb.drag_target_unit == self_unit)
						and loop_bb.action and loop_bb.action.name == "grab_attack" and not loop_bb.attack_finished and not loop_bb.attack_aborted then
						--
						local dodge_timing_min_distance = 1
						local dodge_timing_max_distance = 5
						local dodge_timing_offset = 0.1 + 0.5 * (math.clamp(loop_dist, dodge_timing_min_distance, dodge_timing_max_distance) - dodge_timing_min_distance) / (dodge_timing_max_distance - dodge_timing_min_distance)
						
						-- EchoConsole("loop_dist = " .. loop_dist)
						-- EchoConsole("dodge_timing_offset = " .. dodge_timing_offset)
						
						if not d.defense.awareness.attacks[loop_unit] then
							d.defense.awareness.attacks[loop_unit] = d.current_time
						elseif d.current_time - d.defense.awareness.attacks[loop_unit] > dodge_timing_offset and DamageUtils.check_infront(loop_unit, self_unit) then
							d.defense.need_to_dodge_packmaster = true
							d.defense.need_to_dodge_packmaster = true
							
							d.defense.pos_packmaster_to_dodge = (d.defense.pos_packmaster_to_dodge and d.defense.pos_packmaster_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
							count_packmaster_to_dodge = count_packmaster_to_dodge + 1
						end
					end
					
					-- Vernon: assassin dodge timing should base on distance, trying 0s delay for close range and 0.4s for far range (start_jump time is 0.3s total)
					local dodge_timing_min_distance = 10
					local dodge_timing_max_distance = 20	--15
					local dodge_timing_offset = 0.4 * (math.clamp(loop_dist, dodge_timing_min_distance, dodge_timing_max_distance) - dodge_timing_min_distance) / (dodge_timing_max_distance - dodge_timing_min_distance)
						
					if loop_breed.name == "skaven_gutter_runner" and loop_bb.jump_data
						and ((loop_bb.jump_data.start_jump and loop_bb.jump_data.start_jump - 0.3 + dodge_timing_offset < current_time) or (loop_bb.jump_data.state == "in_air")) then
						--
						-- EchoConsole("loop_dist = " .. loop_dist)
						-- EchoConsole("dodge_timing_offset = " .. dodge_timing_offset)
						
						-- Vernon: this will be handled in _defend fuinction
						d.defense.process_push_jumping_assassin = true
						d.defense.jumping_assassin_distance = loop_dist
						
						local target_offset_flat = Vector3.flat(self_pos - loop_pos)
						local jump_velocity = loop_bb.jump_data and loop_bb.jump_data.jump_velocity_boxed:unbox()
						if not jump_velocity then
							jump_velocity = loop_bb.locomotion_extension and loop_bb.locomotion_extension:current_velocity()
						end
						jump_velocity = Vector3.flat(jump_velocity)
						
						local dot = Vector3.dot(target_offset_flat, jump_velocity)
						local jump_velocity_length_sq = Vector3.dot(jump_velocity, jump_velocity)
						
						if jump_velocity and dot > 0 then
							-- local vector_rejection = (Vector3.length(jump_velocity) > 0.1 and target_offset_flat - (dot / Vector3.dot(jump_velocity, jump_velocity)) * jump_velocity) or Vector3.zero()
							-- local vector_rejection = (jump_velocity_length_sq > 0.01 and target_offset_flat - (dot / jump_velocity_length_sq) * jump_velocity) or Vector3.zero()
							-- d.defense.distance_to_assassin_flight_path = Vector3.length(vector_rejection)
							-- https://en.wikipedia.org/wiki/Vector_projection#Scalar_rejection
							local scalar_rejection = (jump_velocity_length_sq > 0.01 and (target_offset_flat.y * jump_velocity.x - target_offset_flat.x * jump_velocity.y) / jump_velocity_length_sq) or 0
							d.defense.distance_to_assassin_flight_path = math.abs(scalar_rejection)
							
							-- Vernon: grab radius is 1m and player radius is 0.5m
							if (loop_bb.target_unit == self_unit) or (d.defense.distance_to_assassin_flight_path < 1) then
								d.defense.need_to_dodge_assassin = true
								
								d.defense.pos_assassin_to_dodge = (d.defense.pos_assassin_to_dodge and d.defense.pos_assassin_to_dodge + POSITION_LOOKUP[loop_unit]) or POSITION_LOOKUP[loop_unit]
								count_assassin_to_dodge = count_assassin_to_dodge + 1
							end
						end
					end
				end
			end
		end
	end
	
	if d.defense.pos_packmaster_to_dodge and count_packmaster_to_dodge > 0 then
		d.defense.pos_packmaster_to_dodge = d.defense.pos_packmaster_to_dodge / count_packmaster_to_dodge
	end
	if d.defense.pos_assassin_to_dodge and count_assassin_to_dodge > 0 then
		d.defense.pos_assassin_to_dodge = d.defense.pos_assassin_to_dodge / count_assassin_to_dodge
	end
	
	-- process boss information
	for _,loop_unit in pairs(alive_bosses) do
		local loop_breed	= Unit.get_data(loop_unit, "breed")
		local loop_los		= check_line_of_sight(self_unit, loop_unit)
		if loop_breed and loop_los then
			local loop_bb	= Unit.get_data(loop_unit, "blackboard")
			
			local loop_pos	= POSITION_LOOKUP[loop_unit]
			local loop_dist	= self_pos and loop_pos and Vector3.distance(self_pos, loop_pos)
			if loop_dist and loop_dist < closest_boss.distance then
				local _ = false
				_, closest_boss.flanking = check_alignment_to_target(self_unit, loop_unit)
				closest_boss.unit = loop_unit
				closest_boss.distance = loop_dist
				
				if loop_bb.ward_active then
					-- ward_active here is Krench's shield bubble
					closest_boss.warded = true
				end
				
				if loop_bb.target_unit == self_unit then
					closest_boss.targets_me = true
					break
				end
			end
		end
	end
	
	local may_target_disabler = bot_settings.scaler_data:is_allowed_to_release_from_disabler(priority_enemy)

	
	blackboard.opportunity_target_enemy = nil
	blackboard.urgent_target_enemy		= nil
	d.warded_krench_as_target			= false
	
	-- assign the target enemy unit
	
	if priority_enemy and may_target_disabler then	-- enemy that is disabling an ally
		-- EchoConsole("priority threat: " .. tostring(priority_enemy))
		blackboard.target_unit = priority_enemy
	elseif closest_special.unit and closest_special.immediate_threat then
		-- EchoConsole("immediate special threat: " .. tostring(closest_special.unit))
		blackboard.opportunity_target_enemy = closest_special.unit
		blackboard.opportunity_target_distance = closest_special.distance
		blackboard.target_unit = closest_special.unit
	elseif closest_boss.unit and											-- there must be a boss to target it
		   not closest_boss.warded and
		   (
			#prox_enemies == 1 or											-- only 1 enemy around (the boss)
			(closest_boss.distance < 7 and closest_boss.targets_me) or		-- nearby boss boss targets this bot
			(closest_boss.distance < 5 and not closest_boss.flanking) or	-- this bot is in front of the boss and too close (target it to enable bot flanking behavior)
			#near_enemies < 2												-- there is max 1 other enemy nearby
		   ) then
		--
		-- EchoConsole("closest boss (conditioned)")
		blackboard.urgent_target_enemy = closest_boss.unit
		blackboard.urgent_target_distance = closest_boss.distance
		blackboard.target_unit = closest_boss.unit
		d.warded_krench_as_target = closest_boss.warded
	-- elseif closest_special.unit and closest_trash.distance > 3.5 and closest_sv_threat.distance > 3.5  then
	elseif closest_special.unit and closest_trash.distance > 3.5 and closest_sv.distance > 3.5  then
		-- debug_print_variables("closest special (conditioned)", number_to_string(closest_trash.distance,2))
		blackboard.opportunity_target_enemy = closest_special.unit
		blackboard.opportunity_target_distance = closest_special.distance
		blackboard.target_unit = closest_special.unit
	-- Vernon: prioritize attacking rat so attack of the bot can intercept it
	elseif closest_trash_threat.unit and closest_trash_threat.distance < 2.7 then		--3
		blackboard.target_unit = closest_trash_threat.unit
	elseif sniper_target_selection and closest_sv.unit then
		blackboard.target_unit = closest_sv.unit
	elseif separation_threat.unit then
		-- EchoConsole("separation threat (no sniper)")
		blackboard.target_unit = separation_threat.unit
	-- Vernon: only non-sniper move to engage rats?
	elseif not sniper_target_selection and (closest_trash.unit or closest_sv.unit) then
		-- EchoConsole("closest trash/SV (no sniper)")
		if closest_trash.distance < closest_sv.distance then
			blackboard.target_unit = closest_trash.unit
		else
			blackboard.target_unit = closest_sv.unit
		end
	elseif closest_special.unit then
		-- EchoConsole("special threat: " .. tostring(closest_special.unit))
		blackboard.opportunity_target_enemy = closest_special.unit
		blackboard.opportunity_target_distance = closest_special.distance
		blackboard.target_unit = closest_special.unit
	elseif closest_boss.unit and closest_boss.distance < 14 then
		-- EchoConsole("closest boss (<14u)")
		blackboard.urgent_target_enemy = closest_boss.unit
		blackboard.urgent_target_distance = closest_boss.distance
		blackboard.target_unit = closest_boss.unit
		d.warded_krench_as_target = closest_boss.warded
	elseif sniper_target_selection and closest_trash.unit then
		-- EchoConsole("closest trash (sniper)")
		blackboard.target_unit = closest_trash.unit	-- the bot must target something in order for it to defend itself
	elseif blackboard.target_unit then
		-- EchoConsole("cancel target")
		blackboard.target_unit = nil
		d.token.melee_light = false
		d.token.melee_heavy = false
	end
	
	-- clean assigned enemies table
	-- make sure there is no enemies that are assigned to non-active bots (happens when player joins mid combat)
	for key,assigned_unit in pairs(bot_settings.assigned_enemies) do
		if assigned_unit == self_unit then
			bot_settings.assigned_enemies[key] = nil
		else
			local assigned_to_inactive_bot = true
			for _, loop_owner in pairs(active_bots) do
				local loop_unit			= loop_owner.player_unit
				local loop_d			= get_d_data(loop_unit)
				
				local loop_is_disabled	= not loop_d or loop_d.disabled
				if assigned_unit == loop_unit and not loop_is_disabled then
					assigned_to_inactive_bot = false
					break
				end
			end
			
			-- the enemy has disabled bot assigned to it >> remove the assignement
			if assigned_to_inactive_bot then
				bot_settings.assigned_enemies[key] = nil
			end
		end
	end
	
	
	-- assign self to current target enemy
	if blackboard.target_unit then
		bot_settings.assigned_enemies[blackboard.target_unit] = self_unit
	end
	
	
	if blackboard.target_unit then
		-- update target info to d_data
		d.melee.target_unit			= blackboard.target_unit
		d.melee.target_breed		= Unit.get_data(d.melee.target_unit, "breed")
		d.melee.aim_position		= BTBotMeleeAction._aim_position(nil,d.melee.target_unit,nil)
		local self_melee_position	= blackboard.first_person_extension:current_position()
		
		d.melee.target_position		= POSITION_LOOKUP[d.melee.target_unit]
		d.melee.target_offset		= d.melee.target_position - d.position
		d.melee.target_distance		= (self_melee_position and d.melee.aim_position and Vector3.length(self_melee_position - d.melee.aim_position)) or Vector3.length(d.melee.target_offset)
		d.melee.is_aiming			= d.regroup.distance < d.regroup.distance_threshold + 1
		d.melee.may_engage			= Vector3.length(d.regroup.position - d.melee.target_position) < (d.regroup.distance_threshold-0.1)
		d.melee.has_line_of_sight	= check_line_of_sight(d.unit, d.melee.target_unit)
		
	else
		-- no target
		d.melee.target_unit			= nil
		d.melee.target_position		= d.position
		d.melee.target_offset		= Vector3(0,0,-1000)
		d.melee.target_distance		= math.huge
		d.melee.target_breed		= nil
		d.melee.aim_position		= nil
		d.melee.is_aiming			= false
		d.melee.may_engage			= false
		d.melee.has_line_of_sight	= false
	end
	
	Profiler.stop("update target enemy")
end)

-- Rework the decision tree on the question if bots should use light or heavy melee attacks
Mods.hook.set(mod_name, "BTBotMeleeAction._attack", function(func, self, unit, blackboard, input_ext, target_unit)
	local self_unit				= unit
	local self_owner			= Managers.player:unit_owner(self_unit)
	local d						= get_d_data(self_unit)
	
	if not d or not d.settings.better_melee or not d.settings.bot_file_enabled then
		return func(self, unit, blackboard, input_ext, target_unit)
	end
	
	d.unstuck_data.last_attack	= d.current_time	-- so the bot doesn't start jumping if its "stuck" because of wall of rats
	
	if not target_unit or not Unit.alive(target_unit) or not d.equipped.melee or d.keep_last_stormvermin_alive then
		return
	end
	
	
	-- By default bots perform a push when switching straight from block to attack.
	-- This seems an oversight since it happens due to lingering _defend_held attribute.
	-- The condition check below removes this behavior.
	if input_ext._defend_held then
		return
	end
	
	-- this function can be called outside the botfile too to break static objects
	-- so retreiving breed via Unit functions and not from d_data
	local target_breed = Unit.get_data(target_unit, "breed")
	if not target_breed then
		-- the bot is attacking a barricade / like static object
		input_ext["tap_attack"](input_ext)	
		return
	end
	
	local prox_enemies			= d.enemies.melee
	local target_armor			= target_breed.armor_category or 1
	--edit--
	-- local prox_enemies_target	= get_proximite_enemies(target_unit,3)
	local prox_enemies_target	= get_proximite_enemies(target_unit,2.5)
	--edit--
	local target_is_ogre		= target_breed.name == "skaven_rat_ogre"
	local _, is_flanking_target	= check_alignment_to_target(self_unit, target_unit)
	
	-- TODO: this needs more thought
	local slow_attack_allowed	= #d.defense.threat_boss == 0 and #d.defense.threat_stormvermin == 0
	
	local trash_rats_near		= #d.defense.threat_trash > 0
	local weapon_type			= d.equipped.weapon_id
	local weapon_template		= d.equipped.weapon_template
	
	local DEFAULT_ATTACK_META_DATA = {
		tap_attack = {
			penetrating = false,
			arc = 0
		},
		hold_attack = {
			penetrating = true,
			arc = 2
		}
	}
	local weapon_meta_data = weapon_template.attack_meta_data or DEFAULT_ATTACK_META_DATA
	
	-- few weapons need override to their default template values in order for the choice tree to choose correct options
	if weapon_type == "dr_2h_picks" then
		weapon_meta_data.tap_attack.penetrating = true
		weapon_meta_data.tap_attack.arc = 1
		
	elseif	weapon_type == "dr_1h_hammer" or
			weapon_type == "es_1h_mace" or
			weapon_type == "ww_sword_and_dagger" then
		--
		weapon_meta_data.tap_attack.penetrating = false
		weapon_meta_data.tap_attack.arc = 1
	end
	
	local cc_enabled_shields = 
	{
		es_1h_sword_shield	= d.settings.cc_attacks_shield_sword,
		dr_1h_axe_shield	= d.settings.cc_attacks_shield_axe,
		es_1h_mace_shield	= d.settings.cc_attacks_shield_mace,
		dr_1h_hammer_shield	= d.settings.cc_attacks_shield_hammer,
	}
	
	local hammers_2h =
	{
		es_2h_war_hammer	= true,
		dr_2h_hammer		= true,
	}
	
	--edit--
	local use_cc_attack = false
	if d.settings.cc_attacks_allowed and not d.melee.threats_outside_control_angle then
		if cc_enabled_shields[weapon_type] then
			use_cc_attack = #prox_enemies_target > 3
		elseif hammers_2h[weapon_type] and d.settings.cc_attacks_2h_hammers then
			use_cc_attack =  #d.enemies.melee_control_arc > 2
		end
	end
	--edit--
	
	-- ##############################################################
	-- start of the choice tree
	-- idea here is to make the bots favor the fast light attacks over charged attacks against unarmored targets
	-- they should use charged attacks only when attacking an armored target and even then prefer light attack if that one is also penetrating
	
	local kb_against_armor = bot_settings.menu_settings.kb_against_armor
	local penetrating_light_attack	= weapon_meta_data.tap_attack and weapon_meta_data.tap_attack.penetrating
	local killing_blow_light_attack	= d.extensions.buff:has_buff_type("light_killing_blow_proc")
	local killing_blow_heavy_attack	= d.extensions.buff:has_buff_type("heavy_killing_blow_proc")
	
	local must_use_light_attack_against_armor = penetrating_light_attack or (killing_blow_light_attack and kb_against_armor)
	
	d.token.melee_light = true
	d.token.melee_heavy = false
	
	--edit--
	local use_heavy_for_ogre = bot_settings.lookup.ogre_use_melee_heavy_attack[d.equipped.weapon_id]
	local condition_for_heavy = "none"
	
	if type(use_heavy_for_ogre) == "table" then
		condition_for_heavy = use_heavy_for_ogre.condition
	end
	
	for attack_input, attack_meta_data in pairs(weapon_meta_data) do
		if attack_input == "hold_attack" then
			if	(target_armor == 2 and not must_use_light_attack_against_armor and not trash_rats_near and slow_attack_allowed) or
				(use_cc_attack and slow_attack_allowed) or
				-- (killing_blow_heavy_attack and target_is_ogre and is_flanking_target) then
				(target_is_ogre and (killing_blow_heavy_attack or use_heavy_for_ogre) and (condition_for_heavy ~= "flanking" or is_flanking_target)) then
				--
				d.token.melee_light = false
				d.token.melee_heavy = true
			end
		end
	end
	--edit--
	
	if DEBUG_ALWAYS_LIGHT_MELEE_ATTACKS then
		d.token.melee_light = true
		d.token.melee_heavy = false
	end
	
	if DEBUG_ALWAYS_HEAVY_MELEE_ATTACKS then
		d.token.melee_light = false
		d.token.melee_heavy = true
	end
	
	d.token.melee_expire = d.current_time + 1
	
	return
end)

-- Note! Based on how "BTBotMeleeAction._update_melee" works, this function should always return true or false
-- true:	defense action is needed and the bot is not allowed to attack
-- false:	no need to defend and the bot can attack freely
Mods.hook.set(mod_name, "BTBotMeleeAction._defend", function(func, self, unit, blackboard, target_unit, input_ext, t, in_melee_range)
	local self_unit		= unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_melee or not d.settings.bot_file_enabled then
		return func(self, unit, blackboard, target_unit, input_ext, t, in_melee_range)
	end
	
	local has_second_wind = d.extensions.buff:has_buff_type("full_fatigue_on_block_broken")
	
	d.token.melee_light	= false
	d.token.melee_heavy	= false
	d.token.dodge		= false
	d.token.block		= false
	d.token.push		= false
	
	-- Vernon: handle ogres / Krench
	local num_enemies_push				= #d.enemies.push
	
	local num_threat_boss				= #d.defense.threat_boss
	local num_threat_boss_unblockable	= #d.defense.threat_boss_unblockable
	
	-- check if there are enemies behind this bot
	local rats_behind_bot = false
	for _,loop_unit in pairs(d.enemies.push) do
		local infront, behind = check_alignment_to_target(loop_unit, self_unit, 90, 110)
		if behind then
			rats_behind_bot = true
			break
		end
	end
	
	-- Vernon: need to push earlier when surrounded by trash rats and an ogre
	if d.enemies.closest_boss_distance < 4.5 and (d.defense.in_front_of_boss or d.defense.is_boss_target) and (rats_behind_bot or num_enemies_push > 2) and d.defense.current_stamina >= 3 then
		d.token.push = true
	end
	
	if num_threat_boss > 0 then
		if (rats_behind_bot or num_enemies_push - num_threat_boss > 1) and d.defense.current_stamina >= 1 then
			d.token.push = true
		end
		
		-- the only ogre threat is overhead, which is unblockable
		if num_threat_boss == num_threat_boss_unblockable then
			d.token.dodge = true
		-- there are some shove attack threats or other blockable attacks
		else
			d.token.block = true
			d.token.dodge = true
		end
	end
	
	-- Vernon: handle assassins and packmasters
	if d.defense.need_to_dodge_packmaster or d.defense.need_to_dodge_assassin then
		d.token.dodge = true
	end
	
	-- Vernon: if the bot reach here, it should have melee weapons equipped
	-- if d.defense.process_push_jumping_assassin and d.defense.jumping_assassin_distance < 1 then
		-- local status_extension = ScriptUnit.extension(self_unit, "status_system")
		
		-- if d.defense.jumping_assassin_distance < 2.5 and status_extension and status_extension:is_blocking() then
			-- d.token.push = true
		-- elseif d.defense.jumping_assassin_distance < 5 then
			-- d.token.block = true
		-- end
	-- end

	-- Vernon: new SV defense logic below
--[[
	-- Vernon: list of data
	d.defense.attacking_trash
	d.defense.threat_trash
	d.defense.attacking_trash_general
	d.defense.threat_trash_general
	
	-- d.defense.attacking_stormvermin
	-- d.defense.attacking_stormvermin_uninterruptible
	-- d.defense.threat_stormvermin
	-- d.defense.threat_stormvermin_uninterruptible
	-- d.defense.attacking_stormvermin_general
	-- d.defense.attacking_stormvermin_general_uninterruptible
	-- d.defense.threat_stormvermin_general
	-- d.defense.threat_stormvermin_general_uninterruptible
	-- d.defense.can_push_stormvermin
	-- d.defense.is_sv_push_target
	
	--------------------------
	
	d.defense.attacking_sv_overhead
	d.defense.attacking_sv_sweep
	d.defense.threat_stormvermin
	d.defense.threat_sv_overhead
	d.defense.threat_sv_sweep
	d.defense.threat_sv_push
	d.defense.threat_sv_overhead_in_push_range
	d.defense.threat_sv_sweep_in_push_range
	d.defense.threat_sv_push_in_push_range

	d.defense.threat_sv_general
	d.defense.threat_sv_general_uninterruptible
--]]
	local dodge_failed = false
	local dodged_sv = false
	
	local has_devastating_blow = d.extensions.buff:has_buff_type("push_increase")
	local has_heavy_push = has_devastating_blow or (d.equipped.melee and d.equipped.weapon_template.defense_meta_data and d.equipped.weapon_template.defense_meta_data.push == "heavy")

	-- Vernon: handles SV threats against this bot first
	
	local num_attacking_trash					= #d.defense.attacking_trash
	local num_attacking_trash_general			= #d.defense.attacking_trash_general
	local num_threat_trash						= #d.defense.threat_trash
	local num_threat_trash_general				= #d.defense.threat_trash_general
	
	local num_attacking_sv_overhead				= #d.defense.attacking_sv_overhead
	local num_attacking_sv_sweep				= #d.defense.attacking_sv_sweep
	local num_threat_stormvermin				= #d.defense.threat_stormvermin
	local num_threat_sv_overhead				= #d.defense.threat_sv_overhead
	local num_threat_sv_sweep					= #d.defense.threat_sv_sweep
	local num_threat_sv_push					= #d.defense.threat_sv_push
	local num_threat_sv_general					= #d.defense.threat_sv_general
	local num_threat_sv_general_uninterruptible	= #d.defense.threat_sv_general_uninterruptible
	
	-- Vernon: if block or push is needed, stamina will be spent (!) and regen delay from dodging will not matter
	-- Vernon TODO: (!) except stamina traits
	-- Vernon: for dodging SV attacks no need to wait until the attack is about to hit
	-- if (num_threat_stormvermin > 0 or num_threat_sv_push > 0) and d.defense.dodge_count_left and d.defense.dodge_count_left >= -1
	if (num_attacking_sv_overhead > 0 or num_attacking_sv_sweep > 0 or num_threat_sv_push > 0) and d.defense.dodge_count_left and d.defense.dodge_count_left >= -1
		and (not d.defense.last_calculate_dodge_time or bot_settings.dodge.recalculate_time < d.current_time - d.defense.last_calculate_dodge_time)
		and not d.token.dodge and not d.defense.is_dodging and d.defense.can_dodge and d.defense.on_ground then
		--
		-- d.token.dodge = true
		
		d.defense.last_calculate_dodge_time = d.current_time
		
		local move_x, move_y = refine_dodge_movement(d)
		
		local dodge_safe, reason, half_dodge = can_dodge_in_this_direction_safely(d, move_x, move_y)
		
		if dodge_safe then
			dodged_sv = true
			d.token.dodge = true
		-- elseif reason ~= "no_nav_mesh" then
		elseif reason ~= "no_nav_mesh" or half_dodge then
			dodge_failed = true
			d.token.dodge = true
		else
			dodge_failed = true
		end
	end
	
	-- push is in block state so push anyway even when some SVs are possibly out of push range
	if not dodged_sv and has_heavy_push and (num_threat_stormvermin > 0 or num_threat_sv_push > 0) then
		d.token.block = true
		if d.defense.current_stamina >= 1 then
			d.token.push = true
		end
	end

	-- Vernon note: it might be the case even when the push doesn't stagger overhead, ...
	-- Vernon note: it's better to push because stamina will be depleted anyway...
	-- Vernon note: unless >7 stamina or has improved guard
	-- if not dodged_sv and not has_heavy_push and (num_threat_stormvermin > 0 or num_threat_sv_push > 0) then
	if not dodged_sv and not has_heavy_push and (num_threat_stormvermin > 0 or (num_threat_sv_push > 0 and num_threat_trash > 0)) then
		d.token.block = true
		if d.defense.current_stamina >= 1 then
			d.token.push = true
		end
	end
	
	-- Vernon: handles SV threats against teammates next, i.e. pushing for value
	
	-- if has_heavy_push and d.defense.current_stamina >= 3 then
	-- if has_heavy_push and d.defense.current_stamina >= 3 and (num_attacking_sv_overhead > 0 or num_attacking_sv_sweep > 0 or num_threat_sv_push > 0 or num_attacking_trash > 1) then
	if has_heavy_push and d.defense.current_stamina >= 3 and (num_threat_stormvermin > 0 or num_threat_sv_push > 0 or num_threat_trash > 1) then
		if num_threat_sv_general > 2 or num_threat_sv_general_uninterruptible > 1 then
			d.token.push = true
		-- elseif (num_threat_sv_general > 1 or num_threat_sv_general_uninterruptible > 0) and (num_enemies_push > 4 or num_threat_trash_general > 1 or num_attacking_trash_general > 2) then
		elseif (num_threat_sv_general > 1 or num_threat_sv_general_uninterruptible > 0) and (num_enemies_push > 6 or num_threat_trash_general > 1 or num_attacking_trash_general > 2) then
			d.token.push = true
		end
	end
	
	-- if not has_heavy_push and d.defense.current_stamina >= 3 then
	-- if not has_heavy_push and d.defense.current_stamina >= 3 and (num_attacking_sv_sweep > 0 or num_attacking_trash > 1) then
	if not has_heavy_push and d.defense.current_stamina >= 3 and (num_threat_sv_sweep > 0 or num_threat_trash > 1) then
		-- if num_threat_sv_general - num_threat_sv_general_uninterruptible > 1 then
			-- d.token.push = true
		-- end
		if num_threat_sv_general - num_threat_sv_general_uninterruptible > 2 then
			d.token.push = true
		-- elseif (num_threat_sv_general - num_threat_sv_general_uninterruptible > 1) and (num_enemies_push > 4 or num_threat_trash_general > 1 or num_attacking_trash_general > 2) then
		elseif (num_threat_sv_general - num_threat_sv_general_uninterruptible > 1) and (num_enemies_push > 6 or num_threat_trash_general > 1 or num_attacking_trash_general > 2) then
			d.token.push = true
		end
	end
	
	-- Vernon: handle trash rats
	
	local melee_weapon_light_single_target_only = {
		bw_morningstar			= true,
		bw_dagger				= true,
		dr_1h_axes				= true,
		dr_1h_axe_shield		= true,
		dr_2h_axes				= true,
		dr_2h_hammer			= true,
		es_2h_war_hammer		= true,
		wh_1h_axes				= true,
		ww_dual_daggers			= true,
	}
	local num_trash_try_to_hit = (d.equipped.weapon_id and melee_weapon_light_single_target_only[d.equipped.weapon_id] and 1) or 2
	
	if (num_threat_trash > num_trash_try_to_hit or d.melee.threats_outside_control_angle or num_threat_trash_general > 7) and d.defense.current_stamina >= 1 then
		d.token.push = true
	end
	
	-- Vernon: try to dodge small number of trash attacks, provided the bot is not doing other defensive actions and has enough stamina
	-- Vernon: also try to dodge when out of stamina
	--https://github.com/Aussiemon/Vermintide-1-Source-Code/blob/fa42ceee4bb17ff5eaa348a0e367caced81d5712/scripts/unit_extensions/default_player_unit/states/player_character_state_helper.lua#L87
	--https://github.com/Aussiemon/Vermintide-1-Source-Code/blob/fa42ceee4bb17ff5eaa348a0e367caced81d5712/scripts/unit_extensions/default_player_unit/states/player_character_state_standing.lua#L101
	--https://github.com/Aussiemon/Vermintide-1-Source-Code/blob/fa42ceee4bb17ff5eaa348a0e367caced81d5712/scripts/unit_extensions/default_player_unit/states/player_character_state_dodging.lua#L40
	local start_dodge = false
	local calculate_dodge = false
	
	if not dodged_sv and not dodge_failed and (not d.defense.last_calculate_dodge_time or bot_settings.dodge.recalculate_time < d.current_time - d.defense.last_calculate_dodge_time)
		and not d.token.dodge and not d.defense.is_dodging and d.defense.can_dodge and d.defense.on_ground then
		--
		if num_threat_trash > 0 and (num_threat_trash == 1 or (num_threat_trash <= num_trash_try_to_hit and not d.melee.threats_outside_control_angle))
			-- and not d.defense.threat_running_attack
			and d.defense.dodge_count_left and d.defense.dodge_count_left >= 0
			and d.defense.current_stamina >= 3
			-- and #d.enemies.melee < 5
			and #d.enemies.melee < 10
			-- and not d.token.push and not d.token.block then
			then
			--
			calculate_dodge = true
		elseif num_threat_trash == 1 and d.defense.current_stamina < 1
			-- and d.defense.dodge_count_left and d.defense.dodge_count_left >= 1 and #d.enemies.melee < 5 and not has_second_wind then	--4
			and d.defense.dodge_count_left and d.defense.dodge_count_left >= 1 then	--4
			--
			calculate_dodge = true
		end
		
		if calculate_dodge then
			d.defense.last_calculate_dodge_time = d.current_time
			
			local move_x, move_y = refine_dodge_movement(d)
			
			local dodge_safe, reason, half_dodge = can_dodge_in_this_direction_safely(d, move_x, move_y)
			
			if dodge_safe then
				-- d.token.dodge = true
				-- start_dodge = true
				if d.defense.current_stamina < 3 or (not d.defense.threat_running_attack) or (not half_dodge) then
				-- if d.defense.current_stamina < 3 or (not half_dodge) then
					d.token.dodge = true
					start_dodge = true
				end
			end
		end
	end
	
	if d.defense.last_calculate_dodge_time and 5 < d.current_time - d.defense.last_calculate_dodge_time then
		d.defense.last_calculate_dodge_time = nil
	end
	
	if not dodged_sv and not start_dodge and num_threat_trash > 0 and (d.defense.current_stamina >= 1 or has_second_wind) then
		d.token.block = true
	end
	
	-- Vernon: if out of stamina with second wind, try to block a trash attack for stamina regen, provided situation is safe (disabled for now)
	-- if d.defense.current_stamina < 1 and has_second_wind and #d.defense.threat_trash == 1 and #d.enemies.melee < 4 and #d.defense.threat_stormvermin == 0 then
		-- d.token.block = true
	-- end
	
	-- Vernon: still block when guard broken will not cause disaster e.g. only one enemy nearby
	-- Vernon TODO: add HP condition?
	if not dodged_sv and not start_dodge
		-- and d.defense.current_stamina < 1
		-- and (num_threat_trash + num_threat_stormvermin + math.max(num_threat_boss - num_threat_boss_unblockable, 0) == 1)
		-- and (num_threat_trash + num_threat_stormvermin == 1)
		and ((num_threat_trash == 1 and (num_attacking_sv_overhead + num_attacking_sv_sweep == 0)) or (num_threat_stormvermin == 1 and num_attacking_trash == 0))
		and #d.enemies.melee <= 1
		then
		--
		d.token.block = true
	end
	
	-- Vernon: below possibly buggy
	-- if d.token.push and d.defense.current_stamina >= 1 then
		-- d.token.block = false
	-- end
	
	if d.defense.is_dodging or not d.defense.can_dodge or not d.defense.on_ground then
		d.token.dodge = false
	end

	if d.token.block or d.token.push or d.token.dodge then
		if d.token.take_damage then
			bot_settings.scaler_data.damage_taken_last_check = d.current_time
		end
		
		while d.current_time - bot_settings.scaler_data.damage_taken_last_check > 0.1 do
			bot_settings.scaler_data.damage_taken_last_check = bot_settings.scaler_data.damage_taken_last_check + 0.1
			bot_settings.scaler_data.damage_taken_roll_count = math.min(bot_settings.scaler_data.damage_taken_roll_count +1, 1)
		end
		
		while(bot_settings.scaler_data.damage_taken_roll_count > 0) do
			local rng_check = math.clamp(bot_settings.scaler_data.damage_taken_debt / (bot_settings.scaler_data:get_difficulty_modifier_damage() * 37.5 * 15), 0, 1)
			if not d.token.take_damage then
				if bot_settings.scaler_data.damage_taken_token_available > 0 and d.current_time > d.take_damage_cooldown and math.random() < rng_check then
					bot_settings.scaler_data.damage_taken_token_available = bot_settings.scaler_data.damage_taken_token_available - 1
					bot_settings.scaler_data.damage_taken_token_table[d.unit] = true
					d.token.take_damage = d.current_time + 1
				end
			end
			
			bot_settings.scaler_data.damage_taken_roll_count = math.max(bot_settings.scaler_data.damage_taken_roll_count-1, 0)
		end
		
		if d.token.take_damage and d.current_time > d.token.take_damage then
			bot_settings.scaler_data.damage_taken_token_available = bot_settings.scaler_data.damage_taken_token_available + 1
			bot_settings.scaler_data.damage_taken_token_table[d.unit] = nil
			d.token.take_damage = false
		end
		
		if #d.defense.threat_boss == 0 and #d.defense.threat_stormvermin == 0 and d.token.take_damage then
			d.token.block	= false
			d.token.push	= false
			d.token.dodge	= false
			return true
		end
	end
	
	blackboard.revive_with_urgent_target = num_threat_boss == 0
	
	-- Vernon: dodging should not stop attacking
	-- if d.token.block or d.token.push or d.token.dodge then
	if d.token.block or d.token.push then
		return true
	end
	
	return false
end)

-- change bot melee aim node to j_head instead of j_spine
Mods.hook.set(mod_name, "BTBotMeleeAction._aim_position", function(func, self, target_unit, blackboard)
	-- no reliable way to get d_data here so aquireing setting values via the access functions
	if not get(me.SETTINGS.BETTER_MELEE) or not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, target_unit, blackboard)
	end
	local node = 0
	local target_breed = Unit.get_data(target_unit, "breed")
	-- other nodes include j_hips j_neck j_spine
	local aim_node = (target_breed and target_breed.bot_melee_aim_node) or "j_head"
	
	if Unit.has_node(target_unit, aim_node) then
		node = Unit.node(target_unit, aim_node)
	end
	
	return Unit.world_position(target_unit, node)
end)

-- Vernon TODO: modify this function to make bots charge melee attack from further away, possibly base on distance and relative velocity
Mods.hook.set(mod_name, "BTBotMeleeAction._update_melee", function(func, self, unit, blackboard, dt, t)
	local self_unit			= unit
	local self_owner		= Managers.player:unit_owner(self_unit)
	local d					= get_d_data(self_unit)
	
	if not d or not d.settings.better_melee or not d.settings.bot_file_enabled then
		return func(self, unit, blackboard, dt, t)
	end
	
	d.using_ranged		= false
	d.using_melee		= true
	
	local action_data				= self._tree_node.action_data
	local brekable_target			= action_data.destroy_object and blackboard.breakable_object
	local target_unit				= brekable_target or d.melee.target_unit
	local melee_bb					= blackboard.melee
	local already_engaged			= melee_bb.engaging
	
	if not AiUtils.unit_alive(target_unit) then
		return true
	end
	
	if not d.equipped.melee then
		d.extensions.input:wield("slot_melee")
		return true
	end
	
	local wants_engage, eval_timer	= nil
	
	local self_pos			= d.position
	local self_input_ext	= d.extensions.input
	
	local self_aim_pos		= d.melee.aim_position
	local target_breed		= d.melee.target_breed
	local target_pos		= d.melee.target_position or d.melee.aim_position
	local target_offset		= d.melee.target_offset
	local target_distance	= d.melee.target_distance
	local is_aiming			= d.melee.is_aiming
	local may_engage		= d.melee.may_engage
	
	if brekable_target then
		self_aim_pos		= self:_aim_position(target_unit, blackboard)
		target_breed		= nil
		target_pos			= Unit.local_position(brekable_target, 0)
		target_offset		= d.position - target_pos
		target_distance		= Vector3.length(target_offset)
		is_aiming			= true
		may_engage			= true
	end
	
	
	local follow_unit		= d.follow_target
	local follow_unit_pos	= d.follow_target_position
	local follow_distance	= Vector3.length(self_pos - follow_unit_pos)
	
	if is_aiming then
		self_input_ext:set_aiming(true, true)
	else
		self_input_ext:set_aiming(false)
	end
	self_input_ext:set_aim_position(self_aim_pos)
	
	local DEFAULT_MELEE_RANGE	= 1.4
	local MAX_MELEE_RANGE		= 3
	
	local current_difficulty			= Managers.state.difficulty.difficulty
	local below_cata					= not(current_difficulty == "hardest" or current_difficulty == "survival_hardest")
	local normalized_damage_taken_debt	= bot_settings.scaler_data.damage_taken_debt / (37.5 * bot_settings.scaler_data:get_difficulty_modifier_damage())
	local reduced_melee_efficiency		= normalized_damage_taken_debt > ((below_cata and 1) or 2.5)
	
	local melee_range			= d.equipped.weapon_template.bot_melee_range or DEFAULT_MELEE_RANGE
	melee_range					= (reduced_melee_efficiency and DEFAULT_MELEE_RANGE) or math.max(melee_range + 0.5, MAX_MELEE_RANGE)
	--edit--
	if target_breed and target_breed.name == "skaven_rat_ogre" then melee_range = math.max(melee_range,4) end	-- ogre's large body requires etending the melee range a bit
	-- if target_breed and target_breed.name == "skaven_rat_ogre" then melee_range = math.max(melee_range,4.5) end	-- ogre's large body requires etending the melee range a bit
	--edit--
	
	local possibly_do_not_engage = {
		skaven_slave = true,
		skaven_clan_rat = true,
		skaven_storm_vermin = true,
		skaven_storm_vermin_commander = true,
		skaven_rat_ogre = true,
		skaven_storm_vermin_champion = true,
	}
	--TODO: exclude low HP ogres and krench?
	
	--Vernon: stop engaging if stamina is too low and teammate is far
	if may_engage and target_breed and possibly_do_not_engage[target_breed.name] then
		local has_second_wind = d.extensions.buff:has_buff_type("full_fatigue_on_block_broken")
		
		if d.defense.current_stamina < 2 and not has_second_wind then
			local prox_enemies_target = get_proximite_enemies(target_unit, 2)
			local ally_distance_to_target = math.huge
			
			for _, player in pairs(Managers.player:players()) do
				local loop_unit = player.player_unit
				if loop_unit ~= d.unit then
					local status_extension = ScriptUnit.has_extension(loop_unit, "status_system")
					local enabled = status_extension and not status_extension:is_disabled()
					if enabled then
						local loop_position = POSITION_LOOKUP[loop_unit]
						local loop_distance = loop_position and target_pos and Vector3.length(target_pos - loop_position)
						if loop_distance and ally_distance_to_target < loop_distance then
							ally_distance_to_target = loop_distance
						end
					end
				end
			end
			
			if (ally_distance_to_target > 2 and #prox_enemies_target > 3) or #prox_enemies_target > 5 then
				may_engage = false
			end
		end	
	end
	
	-- Vernon: stop engaging mass SVs if the bot can't push stagger them
	if may_engage and target_breed and possibly_do_not_engage[target_breed.name] then
		local has_second_wind = d.extensions.buff:has_buff_type("full_fatigue_on_block_broken")
		local has_devastating_blow = d.extensions.buff:has_buff_type("push_increase")
		local has_heavy_push = false
			
		local inventory_ext = ScriptUnit.has_extension(unit,"inventory_system")
		if inventory_ext then
			local slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_melee")
			local weapon_template = false
			if slot_data and slot_data.item_data then
				weapon_template = BackendUtils.get_item_template(slot_data.item_data) or false
			end
			
			has_heavy_push = (weapon_template.defense_meta_data and weapon_template.defense_meta_data.push == "heavy") or false
		end
		
		if (has_devastating_blow or has_heavy_push) and ((d.defense.current_stamina >= 4 and has_second_wind) or d.defense.current_stamina >= 9) then
		else
			local count_sv = 0
			local prox_enemies_target = get_proximite_enemies(target_unit, 3)	--2
			
			for _,loop_unit in pairs(prox_enemies_target) do
				local loop_breed = loop_unit and Unit.get_data(loop_unit, "breed")
				if loop_breed.name == "skaven_storm_vermin_commander" or loop_breed.name == "skaven_storm_vermin" then
					count_sv = count_sv + 1
				end
			end
			
			if count_sv > 5 then
				may_engage = false
			end
			
			count_sv = 0
			prox_enemies_target = get_proximite_enemies(target_unit, 5)	--4.5
			
			for _,loop_unit in pairs(prox_enemies_target) do
				local loop_breed = loop_unit and Unit.get_data(loop_unit, "breed")
				if loop_breed.name == "skaven_storm_vermin_commander" or loop_breed.name == "skaven_storm_vermin" then
					count_sv = count_sv + 1
				end
			end
			
			if count_sv > 9 then	--10
				may_engage = false
			end
		end
	end
	
	local should_engage			= may_engage and ((not is_unit_in_aoe_explosion_threat_area(target_unit) and not is_unit_in_aoe_explosion_threat_area(self_unit)) or is_unit_in_aoe_explosion_threat_area(follow_unit))
	local in_melee_range		= (brekable_target and target_distance <= MAX_MELEE_RANGE) or target_distance < melee_range
	local engage_range_max		= math.min(((target_breed and bot_settings.melee.engage_distance[target_breed.name]) or bot_settings.melee.engage_distance.default), d.regroup.distance_threshold)
	local engage_range_min		= engage_range_max * 0.75
	local height_offset			= (target_offset and math.abs(target_offset.z)) or math.huge
	local in_engage_range		= height_offset < 3.8 and should_engage
	local target_in_front,_ 	= check_alignment_to_target(target_unit, self_unit, 120)
	local defending				= self:_defend(self_unit, blackboard, target_unit, self_input_ext, t, true)
	local attacking				= false
	
	if (in_melee_range and not defending and d.melee_attack_allowed) and (brekable_target or not d.regroup.enabled or (d.regroup.enabled and target_in_front and target_breed.name ~= "skaven_rat_ogre")) and not DEBUG_NO_MELEE_ATTACKS then
		self:_attack(self_unit, blackboard, self_input_ext, target_unit)
		attacking = true
	end
	
	if not attacking then
		d.token.melee_light = false
		d.token.melee_heavy = false
	end
	
	if in_melee_range and should_engage then
		--edit start--
		-- wants_engage = blackboard.aggressive_mode or (already_engaged and t - melee_bb.engage_change_time < 5) or (target_breed and target_breed.name == "skaven_rat_ogre")
		--edit end--
		wants_engage = true
	elseif in_engage_range then
		wants_engage = true
	else
		wants_engage = already_engaged and t - melee_bb.engage_change_time <= 0
	end
	
	-- eval_timer defines how often the BT nodes are re-evaluated.
	-- Vernon TODO: lower timer when enemies are near
	eval_timer = 1
	
	local engage = wants_engage and self:_allow_engage(self_unit, target_unit, blackboard, action_data, already_engaged, self_aim_pos, d.regroup.position)
	
	--edit start--
	-- if d.regroup.enabled or not may_engage then
	if d.regroup.enabled or not should_engage then
	--edit end--
		engage = false
	end

	if engage and not already_engaged then
		self:_engage(t, blackboard)

		already_engaged = true
	elseif not engage and already_engaged then
		self:_disengage(self_unit, t, blackboard)

		already_engaged = false
	end
	
	if already_engaged and (not melee_bb.engage_update_time or melee_bb.engage_update_time < t) then
		self:_update_engage_position(self_unit, blackboard, dt, t)
	end

	return false, self:_evaluation_timer(blackboard, t, eval_timer)
end)

Mods.hook.set(mod_name, "PlayerBotBase._update_rat_ogre_cover", function(func, self)
	local self_unit		= self._unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_melee or not d.settings.bot_file_enabled then
		return func(self)
	end
	
	local prox_enemies = d.enemies.medium
	local blackboard = Unit.get_data(self_unit, "blackboard")
	
	-- check if the ally is disabled
	local ally_status_extension = ScriptUnit.has_extension(blackboard.target_ally_unit, "status_system")
	local ally_disabled = (ally_status_extension and ally_status_extension:is_disabled()) or false
	
	local is_ogre_target = false
	if ally_disabled then
		-- target ally is disabled and needs help >> check if this bot is targeted by a nearby ogre
		for _,enemy_unit in pairs(prox_enemies) do
			local breed = Unit.get_data(enemy_unit, "breed")
			if breed.name == "skaven_rat_ogre" then
				local enemy_bb = Unit.get_data(enemy_unit, "blackboard")
				if self_unit == enemy_bb.target_unit then
					is_ogre_target = true
				end
			end
		end
	end
	
	-- if there is more than 2 enemies near and ogre is targeting this bot >> flee from the ogre to (hopefully) find better place to fight
	if #d.enemies.near > 2 or (is_ogre_target and ally_disabled) then 
		return func(self)
	else
		self._blackboard.navigation_flee_destination_override = nil
	end
	
	return 
	
end)

-- Direct copy from the original
local function check_angle(nav_world, target_position, start_direction, angle, distance)
	local direction = Quaternion.rotate(Quaternion(Vector3.up(), angle), start_direction)
	local check_pos = target_position - direction*distance
	local success, altitude = GwNavQueries.triangle_from_position(nav_world, check_pos, 0.5, 0.5)

	if success then
		check_pos.z = altitude

		return true, check_pos
	else
		return false
	end

	return 
end

-- Almost direct copy from the original
local function get_engage_pos(nav_world, target_unit_pos, engage_from, melee_distance)
	local subdivisions_per_side = 7		--6 -- origally 3
	local angle_inc = math.pi/(subdivisions_per_side + 1)
	local start_direction = Vector3.normalize(Vector3.flat(engage_from))
	local success, pos = check_angle(nav_world, target_unit_pos, start_direction, 0, melee_distance)

	if success then
		return pos
	end

	-- Vernon TODO: at least check which side is better
	for i = 1, subdivisions_per_side, 1 do
		local angle = angle_inc*i
		success, pos = check_angle(nav_world, target_unit_pos, start_direction, angle, melee_distance)

		if success then
			return pos
		end

		success, pos = check_angle(nav_world, target_unit_pos, start_direction, -angle, melee_distance)

		if success then
			return pos
		end
	end

	success, pos = check_angle(nav_world, target_unit_pos, start_direction, math.pi, melee_distance)

	if success then
		return pos
	end
	
	return nil
end

-- Vernon TODO: maybe _update_engage_position can be modified to make bots bait standing attack
Mods.hook.set(mod_name, "BTBotMeleeAction._update_engage_position", function(func, self, unit, blackboard, dt, t)
	local self_unit		= unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_melee or not d.settings.bot_file_enabled then
		return func(self, unit, blackboard, dt, t)
	end
	

	local self_position = d.position
	local target_unit = blackboard.target_unit
	local target_unit_pos = POSITION_LOOKUP[target_unit]

	local OPTIMAL_MELEE_RANGE = 1.5	-- game default = 1.4
	
	if self._tree_node.action_data.destroy_object then
		target_unit_pos = Unit.local_position(blackboard.breakable_object, 0)
		OPTIMAL_MELEE_RANGE = 2
	end

	local engage_position, engage_from = nil
	local attacking_me, breed = self._is_attacking_me(self, unit, target_unit)
	local enemy_offset = target_unit_pos - self_position
	
	local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(unit)
	
	-- add bot_melee_range if its missing
	if not weapon_template.bot_melee_range then
		local weapon_length = get_equipped_weapon_length(unit)
		weapon_template.bot_melee_range = (weapon_length and (weapon_length*0.9)-0.1) or OPTIMAL_MELEE_RANGE
		weapon_template.bot_melee_range = math.max(weapon_template.bot_melee_range, OPTIMAL_MELEE_RANGE)
	end
	
	local breed_melee_distance = (breed and breed.bot_optimal_melee_distance) or OPTIMAL_MELEE_RANGE
	local weapon_melee_distance = (weapon_template and weapon_template.bot_melee_range) or OPTIMAL_MELEE_RANGE
	local melee_distance = math.max(breed_melee_distance,weapon_melee_distance-0.2)
	
	-- Vernon: testing not to frank stormvermins, especially patrol units
	--edit--
	if target_unit and breed.name == "skaven_rat_ogre" then
		local in_front_of_target, flanking_target = check_alignment_to_target(unit, target_unit, 60, 180)
		
		if in_front_of_target then
			melee_distance = math.min(melee_distance + 1.5, 4)		--melee_distance + 1.5	--4	-- used only when the bot is flanking an ogre
		else
			melee_distance = math.min(melee_distance + 1, 3)		--melee_distance + 1		--3.5
		end
	end
		
	-- if breed and breed.bots_should_flank then
	-- if breed and breed.bots_should_flank and breed.name ~= "skaven_storm_vermin" and breed.name ~= "skaven_storm_vermin_commander" then
	if breed and breed.bots_should_flank and breed.name ~= "skaven_storm_vermin" and breed.name ~= "skaven_storm_vermin_commander" and breed.name ~= "skaven_rat_ogre" then
	--edit--
		-- the bot should flank this target
		local flanking = false
		local enemy_rot = Unit.local_rotation(target_unit, 0)
		local enemy_dir = Quaternion.forward(enemy_rot)
		local flank_cos = Vector3.dot(Vector3.normalize(enemy_dir), Vector3.normalize(enemy_offset))
		if 0.940 < flank_cos then flanking = true end	-- 0.966 = 2x 15deg, 0.940 = 2x 20deg, 0.866 = 2x 30deg deg rear sector
		
		local target_bb = nil
		if ScriptUnit.has_extension(target_unit, "ai_system") then
			local target_ai_ext = ScriptUnit.extension(target_unit, "ai_system")
			target_bb = target_ai_ext.blackboard(target_ai_ext)
		end
		
		local targeting_ogre = false
		if breed.name == "skaven_rat_ogre" then
			melee_distance	= 2.9	-- used only when the bot is flanking an ogre
			targeting_ogre	= true
		end
		
		if (target_bb and not target_bb.target_unit ~= unit) or breed.bots_flank_while_targeted then
			-- either this bot is not being targeted or bots should flank this breed even while targetted
			
			if flanking then
				-- if the bot is already flanking the bot's approach vector to the enemy
				-- is set to the current approach direction
				engage_from = enemy_offset or Vector3(1,0,1)
			else
				-- if the bot is not flanking the target then the angle of the bot's approach vector is tilted so the bot will start to move around the enemy
				local normalized_enemy_dir = Vector3.normalize(Vector3.flat(enemy_dir))
				local normalized_enemy_offset = Vector3.normalize(Vector3.flat(enemy_offset))
				local offset_angle = Vector3.flat_angle(-normalized_enemy_offset, normalized_enemy_dir)
				local new_angle = nil
				
				if breed.name == "skaven_rat_ogre" then melee_distance = 3.7 end
				
				if 0 < offset_angle then
					new_angle = offset_angle + math.pi/4
				else
					new_angle = offset_angle - math.pi/4
				end

				local new_rot = Quaternion.multiply(Quaternion(Vector3.up(), -new_angle), enemy_rot)
				engage_from = -Quaternion.forward(new_rot)
			end
			
			-- now that the apporach vector has been resolved and desired distance to the enemy
			-- has been updated as needed, resolve the actual engage position of this iteration
			engage_position = get_engage_pos(blackboard.nav_world, target_unit_pos, engage_from, melee_distance)
			-- EchoConsole("flank target, not attacking me, circling " .. tostring(melee_distance))
			--
		-- make the bot targeted by an ogre to back off when the ogre attacks
		elseif attacking_me and targeting_ogre and Vector3.length(enemy_offset) < melee_distance+1 then
			engage_position = self_position - (2 * Vector3.normalize(enemy_offset))
		-- condition changed so bots that are targeted by an ogre would take a step back if the ogre comes too close
		elseif math.abs(Vector3.length(enemy_offset) - melee_distance) < 0.2 then
			-- if the bot is being targeted by the enemy and is not supposed to flank it while targeted
			-- and the distance to the enemy is already within certain tolerance, set the engage position to current position
			engage_position = self_position
			-- EchoConsole("flank target, in position")
			--
		else
			-- if the bot is being targetted, but the distance to the target is not correct, update the engage position
			engage_position = get_engage_pos(blackboard.nav_world, target_unit_pos, enemy_offset, melee_distance)
			-- EchoConsole("flank target, moving")
			--
		end
	else
		-- the bot doesn't need to flank this target	
		
		local enemy_distance = Vector3.length(enemy_offset)
		local distance_deviation = enemy_distance - melee_distance
		
		if distance_deviation > 1 then
			-- EchoConsole("approach")
			engage_position = get_engage_pos(blackboard.nav_world, target_unit_pos, enemy_offset, melee_distance)
			if self._tree_node.action_data.destroy_object then
				-- get_engage_pos fails for some breakables due to their height offset being
				-- >0.5 to that of the bot's which causes angle check fails >> use target's position as engage position
				engage_position = target_unit_pos
			end
		elseif distance_deviation > 0 then
			-- EchoConsole("fine - pos")
			engage_position = target_unit_pos
		-- Vernon: case target is too close, but don't move away if target is trash rat because that will bait running attack
		-- Vernon: bots will probably move away by dodging anyway
		-- elseif distance_deviation < -0.1 then
		elseif distance_deviation < -1 or (distance_deviation < -0.1 and breed and breed.name ~= "skaven_slave" and breed.name ~= "skaven_clan_rat") then
			-- EchoConsole("fine - neg")
			engage_position = self_position + Vector3.normalize(self_position - target_unit_pos)
		else
			-- EchoConsole("in position")
			engage_position = self_position
		end
	end
	
	if engage_position then
		local melee_bb = blackboard.melee
		local override_box = blackboard.navigation_destination_override
		local override_destination = override_box.unbox(override_box)
		local engage_pos_set = melee_bb.engage_position_set

		assert(not engage_pos_set or Vector3.is_valid(override_destination))

		if not engage_pos_set or 0.1 < Vector3.length(engage_position - override_destination) then
			override_box.store(override_box, engage_position)

			melee_bb.engage_position_set = true
		end

		melee_bb.engage_update_time = t + 0.2
	end

	return 
end)

-- local need_dodge_direction_fix = {}

-- allow bots to dodge backwards if they try to dodge while standing still
Mods.hook.set(mod_name, "CharacterStateHelper.check_to_start_dodge", function(func, unit, input_extension, status_extension, t)

	if not get(me.SETTINGS.BETTER_MELEE)or not get(me.SETTINGS.FILE_ENABLED) then
		return func(unit, input_extension, status_extension, t)
	end
	
	local unit_owner = Managers.player:unit_owner(unit)
	local is_bot = false
	if unit_owner and unit_owner.bot_player then
		is_bot = true
	end
	
	local toggle_stationary_dodge_save = false
	if is_bot then
		toggle_stationary_dodge_save = Application.user_setting("toggle_stationary_dodge")
		Application.set_user_setting("toggle_stationary_dodge",true)
		
		-- get and update d_data
		local self_unit	= unit
		local d = get_d_data(self_unit)
		
		if d and d.settings.better_melee and d.settings.bot_file_enabled and d.defense.need_dodge_direction_fix then
			local move_x, move_y = refine_dodge_movement(d)
			input_extension.move.x = move_x
			input_extension.move.y = move_y
			
			d.defense.need_dodge_direction_fix = false
		end
	end
	
	local start_dodge, dodge_direction = func(unit, input_extension, status_extension, t)
	
	if is_bot then
		Application.set_user_setting("toggle_stationary_dodge",toggle_stationary_dodge_save)
	end
	
	return start_dodge, dodge_direction
	
end)


Mods.hook.set(mod_name, "BTBotShootAction._may_attack", function(func, self, enemy_unit, shoot_blackboard, range_squared, t)
	local self_unit		= shoot_blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(self, enemy_unit, shoot_blackboard, range_squared, t)
	end
	
	local ai_extension = ScriptUnit.has_extension(enemy_unit, "ai_system")

	if not ai_extension then
		return false
	end

	local bb = ai_extension:blackboard()
	local charging = shoot_blackboard.charging_shot
	local sufficiently_charged = not shoot_blackboard.minimum_charge_time or (not shoot_blackboard.always_charge_before_firing and not charging) or (charging and is_weapon_charged(self_unit))
	local max_range_squared = (charging and shoot_blackboard.max_range_squared_charged) or shoot_blackboard.max_range_squared
	
	local breed				= Unit.get_data(enemy_unit, "breed")
	local scaled_target		= breed.name == "skaven_slave" or breed.name == "skaven_clan_rat" or breed.name == "skaven_loot_rat" or breed.name ==  "skaven_storm_vermin" or breed.name ==  "skaven_storm_vermin_commander"
	
	local may_fire = (d.ranged_attack_allowed or not scaled_target) and sufficiently_charged and not shoot_blackboard.obstructed and range_squared < max_range_squared
	
	return may_fire
end)


-- make the bots more eager to switch to melee instead of sticking with ranged weapons in certain situations
Mods.hook.set(mod_name, "BTConditions.bot_in_melee_range", function(func, blackboard)
	local self_unit		= blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or (not d.settings.better_melee and not d.settings.better_ranged) or not d.settings.bot_file_enabled then
		return func(blackboard)
	end
	
	local target_unit				= d.melee.target_unit
	local self_pos					= d.position
	local target_pos				= d.melee.target_position
	local distance_to_target		= d.melee.target_distance
	
	if not AiUtils.unit_alive(target_unit) then
		self_owner.last_melee_range_check = false
		return false
	end

	local has_sniper					= d.equipped.sniper
	local breed							= d.melee.target_breed
	local target_is_trash				= breed.name == "skaven_slave" or breed.name == "skaven_clan_rat" or breed.name == "skaven_loot_rat"
	local target_is_SV					= breed.name == "skaven_storm_vermin" or breed.name == "skaven_storm_vermin_commander"
	local scaler_in_range				= breed.special or breed.boss or (distance_to_target <= bot_settings.scaler_data.offense_ranged_range)
	
	if	(not d.settings.snipers_shoot_trash and has_sniper and target_is_trash) or
		(d.reduced_ambient_shooting and (target_is_trash or target_is_SV)) or
		d.defense.must_push_gutter or
		d.keep_last_stormvermin_alive or
		d.warded_krench_as_target or
		not scaler_in_range then
		--
		self_owner.last_melee_range_check = true
		return true
	end
	
	-- if the target is priority target (gutter / packmaster that has disabled an ally) then check line of sight
	if blackboard.priority_target_enemy == target_unit then
		-- check line of sight to priority target unit as that is not checked in target selection
		-- if priority target is not in line of sight then don't force bot the use ranged (melee out instead)
		local los = d.melee.has_line_of_sight
		if not los then
			-- if there is no line of sight then the bot should pull out melee and chase the enemy
			self_owner.last_melee_range_check = true
			return true
		end
	end
	
	
	local aoe_threat = #d.defense.threat_boss > 0 or #d.defense.threat_stormvermin > 0
	local melee_range = bot_settings.default.melee_range.default
	if bot_settings[breed.name] == nil or bot_settings[breed.name].melee_range == nil then
		EchoConsole("melee_range not defined for " .. tostring(breed.name))
	else
		
		-- check if the bot has enough ammo to shoot
		local has_heat_weapon = d.equipped.heat_weapon
		local ammo = d.equipped.ranged_ammo
		local ammo_threshold = bot_settings.ammo_threshold.default
		local heat_threshold = bot_settings.heat_threshold.default
		if	blackboard.urgent_target_enemy		== target_unit or
			blackboard.opportunity_target_enemy	== target_unit or
			blackboard.priority_target_enemy	== target_unit then
			--
			ammo_threshold = bot_settings.ammo_threshold.special
			heat_threshold = bot_settings.heat_threshold.special
		end
		
		local threshold_factor = (d.enough_hp_to_vent and bot_settings.heat_threshold.vent_threshold_factor) or bot_settings.heat_threshold.passive_threshold_factor
		if d.overheated then
			heat_threshold = heat_threshold * threshold_factor
		end
		
		local ammo_ok = false
		if has_heat_weapon then
			ammo_ok = ammo > (1-heat_threshold)
			if ammo_ok then
				d.overheated = false
			else
				d.overheated = true
				if d.enough_hp_to_vent then
					ammo_ok = true
				end
			end
		else
			ammo_ok = ammo > ammo_threshold
		end
		
		if not ammo_ok then
			-- no ammo >> no ranged attacks
			self_owner.last_melee_range_check = true
			return true
		end
		
		d.has_enough_ammo = ammo_ok
		
		-- ammo ok >> resolve the melee range against this spesific target
		melee_range = bot_settings[breed.name].melee_range.default
		local condition = bot_settings[breed.name].melee_range.condition or false
		
		if condition then
			local reduced_melee_range = bot_settings[breed.name].melee_range.reduced or melee_range
			local flank_angle = (self_owner.last_melee_range_check and 90) or 120
			local in_front, flanking = check_alignment_to_target(self_unit, target_unit, 90, flank_angle)
			local condition_range = bot_settings[breed.name].melee_range.condition_range or false
			
			if	(condition == "too_close"		and condition_range and distance_to_target < condition_range) or
				(condition == "flanking"		and flanking) or
				(condition == "no_aoe_threat"	and not aoe_threat) then
				--
				melee_range = reduced_melee_range
			else
				--
			end
		end
	end
	
	--edit start--
	-- based on quick test trash rats can still reach you if you're 2.883 above them >> limit set to 3
	-- local prox_enemies = get_proximite_enemies(self_unit,math.min(melee_range,3.5), 3)
	local check_range = math.min(melee_range,3.5)
	local prox_enemies = get_proximite_enemies(self_unit,check_range, 3)
	-- local prox_enemy_count = 0
	local use_melee = distance_to_target < check_range
	local enemy_pos = Vector3(0,0,0)
	
	-- count threatening trash around the bot
	for _,enemy_unit in pairs(d.defense.threat_trash) do
		-- if Vector3.distance(self_pos, enemy_pos) < check_range then
			-- prox_enemy_count = prox_enemy_count+1
		-- end
		use_melee = true
	end
	
--[[
	for _,loop_unit in pairs(prox_enemies) do
		local is_my_target = loop_unit == target_unit
		local is_special = breed.special
		local is_boss = breed.boss
		local boss_threat = #d.defense.threat_boss > 0
		-- count all enemies except..
		-- >> the current target enemy if the enemy is boss and no active boss threat
		-- >> specials
		
		if not ((is_my_target and is_boss and boss_threat) or is_special) then
			prox_enemy_count = prox_enemy_count+1
		end
		
		-- if not (loop_unit == target_unit and ((breed.boss and not d.defense.threat_boss) or breed.special)) then
			-- -- count all enemies except the current target enemy if the enemy is boss and no active boss threat or  the enemy is special enemy
			-- prox_enemy_count = prox_enemy_count+1
		-- end
	end
--]]
	
	for _,loop_unit in pairs(prox_enemies) do
		local is_my_target = loop_unit == target_unit
		local is_special = breed.special
		local is_boss = breed.boss
		local boss_threat = #d.defense.threat_boss > 0
		
		if (is_my_target and is_boss) or boss_threat then
			-- prox_enemy_count = prox_enemy_count+1
			use_melee = true
		end
	end
	
	-- local ret = prox_enemy_count > 0 or aoe_threat or DEBUG_NO_RANGED_ATTACKS
	local ret = use_melee or aoe_threat or DEBUG_NO_RANGED_ATTACKS
	self_owner.last_melee_range_check = ret
	return ret
	--edit end--
end)

-- this is handled by the bot file
Mods.hook.set(mod_name, "AIBotGroupSystem._update_opportunity_targets", function(func, self, dt, t)
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, dt, t)
	end
	
	return
end)

-- maximum distance doubled to 50, added some light optimization to the return clause
Mods.hook.set(mod_name, "BTConditions.has_priority_or_opportunity_target", function(func, blackboard)
	local self_unit		= blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(blackboard)
	end
	
	local target = d.melee.target_unit
	
	if not Unit.alive(target) then
		return false
	end

	local distance_ok		= d.melee.target_distance < 50
	local has_line_of_sight	= d.melee.has_line_of_sight
	local result = (target == blackboard.opportunity_target_enemy or target == blackboard.priority_target_enemy or target == blackboard.urgent_target_enemy) and distance_ok and has_line_of_sight
	
	return result
end)


local function get_damage_window_limits(current_time_in_action, action, owner_unit)
	
	if not current_time_in_action or not action or not owner_unit then
		return false, true
	end
	
	local damage_window_start = action.damage_window_start
	local damage_window_end = action.damage_window_end

	if not damage_window_start and not damage_window_end then
		return false
	end

	local anim_time_scale = action.anim_time_scale or 1
	anim_time_scale = ActionUtils.apply_attack_speed_buff(anim_time_scale, owner_unit)
	damage_window_start = damage_window_start / anim_time_scale
	damage_window_end = damage_window_end or action.total_time or math.huge
	damage_window_end = damage_window_end / anim_time_scale
	local after_start = damage_window_start < current_time_in_action
	local before_end = current_time_in_action < damage_window_end

	-- return after_start and before_end
	return after_start, before_end
end

local function is_within_a_chain_window(current_time_in_action, action, owner_unit)
	local attack_speed_modifier = 1
	attack_speed_modifier = ActionUtils.apply_attack_speed_buff(attack_speed_modifier, owner_unit)

	for action, chain_info in pairs(action.allowed_chain_actions) do
		local start_time = chain_info.start_time or 0
		local end_time = chain_info.end_time or math.huge
		local modified_start_time = start_time / attack_speed_modifier
		local after_start = current_time_in_action > modified_start_time
		local before_end = current_time_in_action < end_time

		if after_start and before_end then
			return true
		end
	end

	return false
end


-- 
Mods.hook.set(mod_name, "PlayerBotInput.update", function(func, self, unit, input, dt, context, t)
	local self_unit		= unit
	local current_bot	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or (not d.settings.better_ranged and not d.settings.better_melee) or not d.settings.bot_file_enabled then
		return func(self, unit, input, dt, context, t)
	end
	
	-- this function is executes once / each frame for each character
	table.clear(self._input)
	
	local blackboard		= Unit.get_data(self_unit, "blackboard")
	local fire_shot_token	= (blackboard.shoot and blackboard.shoot.fire_shot_token) or false
	
	if d.token.jump then
		self._input.jump = true
		d.token.jump = false
	end
	
	if d.settings.better_ranged then
		if fire_shot_token then
			blackboard.shoot.fire_shot_token = false
			blackboard.shoot.charging_shot = false
			blackboard.shoot.charge_start_time = nil
			blackboard.shoot.fired = true
			self._fire = true
		end
	end
	
	if d.token.block_override then
		if d.equipped.melee then
			self._defend = true
		else
			d.extensions.input:wield("slot_melee")
		end
	elseif d.settings.better_melee then
		if d.equipped.melee then
			if d.token.block then
				self._defend = true
				if #d.defense.threat_boss == 0 and #d.defense.threat_trash == 0 and #d.defense.threat_stormvermin == 0 then
					d.token.block	= false
				end
			end
			
			if d.token.dodge then
				self.move.y = math.min(self.move.y, 0)
				
				d.token.dodge		= false
				self._dodge			= true
				
				d.defense.need_dodge_direction_fix = true
			end
			
			if d.token.push then
				d.token.push	= false
				d.token.block	= false
				
				if d.equipped.weapon_id == "wh_fencing_sword" then
					-- for some reason, bots fail to push with rapiers, even if self._melee_push is forced using manual debug key
					-- other weapons don't seem to have this issue. This fix is really crude as it bypasses the original system
					--  and just gives the weapon a push order directly via weapon extension >> something to improve in the future whe time permits
					-- 20200524, tested adding weapon_action_hand = "right" to the rapier's push action template >> doesn't solve the underlying issue
					if is_weapon_ready_to_push(self_unit) and d.defense.current_stamina >= 1 then
						self._input.action_two_hold = true
						local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(self_unit)
						local weapon_extension = ScriptUnit.has_extension(weapon_unit, "weapon_system")
						weapon_extension:start_action("action_one", "push", weapon_template.actions, t)
					else
						self._input.action_two_hold = true
					end
				else
					self._melee_push	= true
				end
			end
		end
	end
	
	if t > d.token.melee_expire then
		d.token.melee_light = false
		d.token.melee_heavy = false
	end
	
	if d.settings.better_melee and d.equipped.melee and d.melee.target_unit then
		if d.token.melee_heavy then
			d.token.melee_heavy = false
			if is_weapon_charged(self_unit) then
				-- EchoConsole("launch attack")
				self._input.action_one_release = true
			else
				-- EchoConsole("charging")
				self._input.action_one = true
				self._input.action_one_hold = true
			end
		end
		
		if d.token.melee_light then
			local current_action_settings = d.equipped.weapon_extension.current_action_settings
			local current_time_in_action = (current_action_settings and (t - d.equipped.weapon_extension.action_time_started)) or 0
			local owner_unit = d.equipped.weapon_extension.owner_unit
			local after_start, before_end = get_damage_window_limits(current_time_in_action, current_action_settings, owner_unit)
			local target_alive = is_unit_alive(d.melee.target_unit)
			local preferred_chain_length = bot_settings.lookup.cc_light_melee_chain_length[d.equipped.weapon_id] or bot_settings.lookup.cc_light_melee_chain_length.default
			--edit--
			local target_is_ogre = d.melee.target_breed and (d.melee.target_breed.name == "skaven_rat_ogre")
			if target_is_ogre then
				preferred_chain_length = bot_settings.lookup.ogre_light_melee_chain_length_block[d.equipped.weapon_id] or bot_settings.lookup.cc_light_melee_chain_length.default
			end
			--edit--
			local blocking = current_action_settings and current_action_settings.kind == "block"
			
			if not target_alive then
				d.token.melee_light = false
				d.equipped.melee_chain_state = "cancel"
				self._input.action_one_release = true
				self._defend = true
			elseif not current_action_settings and d.equipped.melee_chain_state ~= "cancel_start" and d.equipped.melee_chain_state ~= "cancel_blocking" then
				if not self._defend_held then
					if d.equipped.melee_chain_position ~= 0 then
						d.equipped.melee_chain_position = 0
					else
						d.equipped.melee_chain_state = "trigger"
						d.equipped.melee_chain_position = 0
						self._input.action_one = true
						-- EchoConsole("chain_reset")
					end
				end
			elseif d.equipped.melee_chain_state == "cancel_start" or d.equipped.melee_chain_state == "cancel_blocking" or d.equipped.melee_chain_state == "cancel_done" or (after_start and not before_end and d.equipped.melee_chain_position >= preferred_chain_length) then
				if d.equipped.melee_chain_state ~= "cancel_start" and d.equipped.melee_chain_state ~= "cancel_blocking" and d.equipped.melee_chain_state ~= "cancel_done" then
					d.equipped.melee_chain_state = "cancel_start"
					self._input.action_one_release = true
					-- EchoConsole("cancel_start")
				elseif d.equipped.melee_chain_state == "cancel_start" then
					local blocking = current_action_settings and current_action_settings.kind == "block"
					if not blocking then
						self._defend = true
						-- EchoConsole("cancel_rise_block")
					else
						-- EchoConsole("cancel_blocking")
						d.equipped.melee_chain_state = "cancel_blocking"
					end
				else
					-- EchoConsole("cancel_lower_block")
					if not current_action_settings then
						d.equipped.melee_chain_state = "cancel_done"
						-- EchoConsole("cancel_done")
					end
				end
			elseif not after_start then
				if d.equipped.melee_chain_state ~= "release" then
					d.equipped.melee_chain_state = "release"
					d.equipped.melee_chain_position = d.equipped.melee_chain_position+1
				end
				self._input.action_one_release = true
			elseif not before_end then
				if not self._defend_held then
					d.equipped.melee_chain_state = "chain trigger"
					self._input.action_one = true
				end
			end
		end
	else
		d.token.melee_heavy	= false
		d.token.melee_light	= false
	end
	
	local venting_in_cooldown = d.current_time < d.vent_cooldown
	
	if d.equipped.ranged and d.token.ranged_vent and not venting_in_cooldown then
--edit--
		-- self._input.weapon_reload		= true
		self._input.weapon_reload_hold	= true	-- havng this and above active causes Vernon's template modifications to cause excessive damage to bots when they vent
--edit--
		d.is_venting					= true
	else
		if d.is_venting then
			d.vent_cooldown				= d.current_time +1
			d.is_venting				= false
		end
	end
	
	
	self._update_movement(self, dt, t)
	self._update_actions(self)
	
	
	return
end)

-- Vernon: change dodge settings for bots
Mods.hook.set(mod_name , "PlayerBotInput.init", function(func, self, extension_init_context, unit, extension_init_data)
	func(self, extension_init_context, unit, extension_init_data)
	
	self.dodge_on_jump_key = false
	self.dodge_on_forward_diagonal = true
	self.double_tap_dodge = false
end)

-- Mods.hook.set(mod_name , "PlayerBotInput._update_movement", function(func, self, dt, t)
	-- func(self, dt, t)
	
-- end)

-- Vernon: reset some tokens upon switching weapons / items if necessary
--[[
Mods.hook.set(mod_name, "PlayerBotInput.wield", function(func, self, slot)
	func(self, slot)
	
	local self_unit		= self.unit
	local current_bot	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or (not d.settings.better_ranged and not d.settings.better_melee) or not d.settings.bot_file_enabled then
		return
	end
	
	
end)
--]]

--edit start--
-- Vernon: I think this part is included in 20220116 version as well
-- greatly improve the bots' ability to learn transitions by following humans
--[[
local transition_init_extra =
{
	unit	= false,
	to		= false,
	
	_valid	= false,
	validate = function(self)
		self._valid = true
	end,
	invalidate = function(self)
		self._valid = false
	end,
	is_valid = function(self)
		return self._valid
	end,
}

local pending_timeout		= 1.5
local pending_transitions	= {}
local force_move_target_update =
--]]
--edit end--

local nav_fix =
{
	timeout = 60,
	pending_transitions = {},
	last_valid_position = {},
	invalid_start_positions =
	{
		wizard =
		{
			Vector3Box(207.421, -23.6088, 78.6209),
			Vector3Box(203.512, -21.4202, 78.6177),
		},
	},
}
local new_transition_time = 0

Mods.hook.set(mod_name , "PlayerWhereaboutsExtension._check_bot_nav_transition", function(func, self, nav_world, input, current_position)
	if bot_settings.menu_settings.bot_file_enabled then
		local is_valid_position = function(pos)
			if pos and Managers and Managers.state and Managers.state.bot_nav_transition then
				local nav_world			= Managers.state.bot_nav_transition._nav_world
				local traverse_logic	= Managers.state.bot_nav_transition._layerless_traverse_logic
				
				if nav_world and traverse_logic then
					local ret, _	= GwNavQueries.triangle_from_position(nav_world, pos, 0.1, 0.3, traverse_logic)
					return ret
				end
			end
			
			return false
		end
		
		local current_time			= Managers.time:time("game")
		local self_unit				= self.unit
		local in_valid_position		= is_valid_position(current_position)
		local is_jumping			= (input.jumped or self._jumping) and not (input.landed or input.no_landing)
		local is_falling			= self._falling
		local last_valid_position	= false
	
		if in_valid_position then
			nav_fix.last_valid_position[self_unit] = Vector3Box(current_position)
			last_valid_position	= current_position
		else
			last_valid_position	= (nav_fix.last_valid_position[self_unit] and nav_fix.last_valid_position[self_unit]:unbox()) or false
		end
		
		
		for unit, transition in pairs(nav_fix.pending_transitions) do
			if current_time - transition.start_time > nav_fix.timeout or current_time < transition.start_time then
				nav_fix.pending_transitions[unit] = nil	-- pending transition has been pending for too long (timeout) or the transition was created in the "future" >> remove it
				-- debug_print_variables("Pending transition timeout")
				--
			elseif self_unit == unit and in_valid_position then
				local from			= transition.from:unbox()
				local via			= transition.via:unbox()
				local to			= current_position
				local has_jumped	= transition.has_jumped
				
				-- if transition_sanity_check(nav_fix.invalid_start_positions, from, to) then
					if math.abs(to.z-from.z) < 0.5 then has_jumped = true end
					Managers.state.bot_nav_transition:create_transition(from, via, to, has_jumped)
					-- debug_print_variables("New transition / f:", from, " v:", via, " t:", to, " j:", has_jumped)
				-- end
				nav_fix.pending_transitions[unit] = nil
			end
			--
		end
		
		if not in_valid_position and last_valid_position then
			-- create popending transition if it doesn't exist yet
			if not nav_fix.pending_transitions[self_unit] then
				nav_fix.pending_transitions[self_unit] =
				{
					start_time	= current_time,
					from					= Vector3Box(last_valid_position),
					via						= Vector3Box(last_valid_position),
					has_jumped				= false,
					has_been_falling		= false,	
					fall_profile			= {Vector3Box(last_valid_position),},
					last_fall_pos			= Vector3Box(last_valid_position),
				}
			end
			
			-- update transition jump status
			if not nav_fix.pending_transitions[self_unit].has_jumped and is_jumping then
				nav_fix.pending_transitions[self_unit].has_jumped	= true
				nav_fix.pending_transitions[self_unit].via			= Vector3Box(current_position)
			end
			
			-- update fall profile
			local data = nav_fix.pending_transitions[self_unit]
			if is_falling then
				nav_fix.pending_transitions[self_unit].has_been_falling = true
				if Vector3.distance(current_position, data.last_fall_pos:unbox()) > 0.1 then
					table.insert(nav_fix.pending_transitions[self_unit].fall_profile, Vector3Box(current_position))
					nav_fix.pending_transitions[self_unit].last_fall_pos = Vector3Box(current_position)
				end
			elseif data.has_been_falling then
				local max_distance			= 0
				local last_fall_position	= data.last_fall_pos:unbox()
				local from_position			= data.from:unbox()
				for _,box in pairs(data.fall_profile) do
					local position = box:unbox()
					local l1 = Vector3.distance(from_position, position)
					local l2 = Vector3.distance(last_fall_position, position)
					if l1 + l2 > max_distance then
						max_distance	= l1 + l2
						nav_fix.pending_transitions[self_unit].via = box
					end
				end
			end
		end
	end
	
	func(self, nav_world, input, current_position)
end)

Mods.hook.set(mod_name , "BotNavTransitionManager.create_transition", function(func, self, from, via, wanted_to, player_jumped, make_permanent)
	local transition_sanity_check = function(invalid_start_positions, from, to)
		local ret = true
		local offset = to - from 
		local level_id = LevelHelper:current_level_settings().level_id
		if offset.z < -6.5 or offset.z > 2 then ret = false end
		if Vector3.length(Vector3.flat(offset)) > 4 and offset.z > -1 then ret = false end
		-- if Vector3.length(offset) < 0.2 then ret = false end
		
		-- deem transition bad if its starting point is around the forbidden positions
		for level, data in pairs(invalid_start_positions) do
			if level == level_id then
				for _, pos in pairs(data) do
					if Vector3.distance(pos:unbox(), from) < 1 then
						EchoConsole("no transition allowed here")
						ret = false
						break
					end
				end
			end
		end
		return ret
	end
	
	local file_enabled		= bot_settings.menu_settings.bot_file_enabled
	local current_time		= Managers.time:time("game")
	local success			= false
	local transition_unit	= nil
	
	if file_enabled then
		if make_permanent or transition_sanity_check(nav_fix.invalid_start_positions, from, wanted_to) then
			success, transition_unit = func(self, from, via, wanted_to, player_jumped, make_permanent)
		end
	else
		success, transition_unit = func(self, from, via, wanted_to, player_jumped, make_permanent)
	end
	
	if success then
		new_transition_time = current_time
	end
	return success, transition_unit
end)

-- improved bot responsiveness when it comes to following human players
-- Vernon: add function to disengage when using ranged weapons
Mods.hook.set(mod_name, "PlayerBotBase._update_movement_target", function(func, self, dt, t)
	-- func(self, dt, t)
	
	local blackboard = self._blackboard
	local unit = self._unit
	local self_pos = POSITION_LOOKUP[unit]
	local nav_world = self._nav_world
	local navigation_ext = blackboard.navigation_extension
	local override_box = blackboard.navigation_destination_override
	local override_melee = blackboard.melee and blackboard.melee.engage_position_set and override_box:unbox()
	--edit start--
	local override_ranged = blackboard.shoot and blackboard.shoot.disengage_position_set and override_box:unbox()
	--edit end--
	local override_rat_ogre_flee = blackboard.navigation_flee_destination_override and blackboard.navigation_flee_destination_override:unbox()
	local moving_towards_follow_position = false
	local follow_bb = blackboard.follow
	local cover_bb = blackboard.taking_cover
	local in_line_of_fire, changed = self:_in_line_of_fire(unit, self_pos, cover_bb.threats, cover_bb.active_threats)
	local cover_position = nil
	local bot_group_system = Managers.state.entity:system("ai_bot_group_system")

	if in_line_of_fire and changed then
		local fails = cover_bb.fails
		local radius = math.min(5 + fails * 5, 40)
		local allowed_forward_dist = radius * 0.4
		local num_found, hidden_cover_units = self:_find_cover(cover_bb.active_threats, self_pos, radius, allowed_forward_dist)
		local found_point, found_unit, occupied_cover_unit, occupied_cover_point = nil

		for i = 1, num_found, 1 do
			local cover_unit = hidden_cover_units[i]
			local pos = Unit.local_position(cover_unit, 0)

			if not cover_bb.failed_cover_points[to_hash(pos)] then
				if bot_group_system:in_cover(cover_unit) then
					occupied_cover_point = occupied_cover_point or pos
					occupied_cover_unit = occupied_cover_unit or cover_unit
				else
					found_point = pos
					found_unit = cover_unit

					break
				end
			end
		end

		found_point = found_point or occupied_cover_point
		found_unit = found_unit or occupied_cover_unit

		if found_point then
			cover_position = found_point

			cover_bb.cover_position:store(cover_position)

			cover_bb.cover_unit = found_unit
			cover_bb.fails = 0

			dprint("found point", cover_position)
			bot_group_system:set_in_cover(unit, found_unit)
		else
			cover_bb.fails = cover_bb.fails + 1

			table.clear(cover_bb.active_threats)
			dprint("failed to find point, forcing re-evaluation")
		end
	elseif not in_line_of_fire and changed then
		cover_bb.cover_position:store(Vector3.invalid_vector())

		cover_bb.cover_unit = nil
		cover_bb.fails = 0
		follow_bb.needs_target_position_refresh = true

		bot_group_system:set_in_cover(unit, nil)
	elseif in_line_of_fire then
		cover_position = cover_bb.cover_position:unbox()
	end

	local obstruction_bb = blackboard.ranged_obstruction_by_static
	local obstruction_unit = obstruction_bb and obstruction_bb.unit

	if cover_bb.active_threats[obstruction_unit] then
		blackboard.ranged_obstruction_by_static = nil
	end

	local target_ally_unit = blackboard.target_ally_unit
	local transport_unit_override = nil
	
	--edit start--
	local alive = Unit.alive
	local PROXIMITY_CHECK_RANGE = 5
	local PROXIMITY_CHECK_RANGE_ALLY_NEEDS_AID = 4.5
	local PROXIMITY_CHECK_RANGE_ALLY_NEEDS_AID_REVIVING = 1.5
	local PROXIMITY_CHECK_RANGE_ALLY_NEEDS_AID_SUPPORT = 15
	local STICKYNESS_DISTANCE_MODIFIER = -0.2
	local FOLLOW_TIMER_LOWER_BOUND = 1
	local FOLLOW_TIMER_UPPER_BOUND = 1.5
	local ENEMY_PATH_FAILED_REPATH_THRESHOLD = 9
	local ENEMY_PATH_FAILED_REPATH_VERTICAL_THRESHOLD = 0.8
	local ALLY_PATH_FAILED_REPATH_THRESHOLD = 0.25
	local FLAT_MOVE_TO_EPSILON = 0.05
	local Z_MOVE_TO_EPSILON = 0.3
	local WANTS_TO_HEAL_THRESHOLD = 0.25
	local WANTS_TO_GIVE_HEAL_TO_OTHER = 0.5
	local SELF_UNIT = nil
	--edit end--

	if alive(target_ally_unit) then
		local ally_status_extension = ScriptUnit.extension(target_ally_unit, "status_system")
		local transport_unit = ally_status_extension:get_inside_transport_unit()

		if alive(transport_unit) and not blackboard.target_ally_needs_aid then
			blackboard.ally_inside_transport_unit = transport_unit
			local transportation_ext = ScriptUnit.extension(blackboard.ally_inside_transport_unit, "transportation_system")
			local has_valid_transportation_unit = transportation_ext.story_state == "stopped_beginning"

			if has_valid_transportation_unit then
				transport_unit_override = LocomotionUtils.new_goal_in_transport(nav_world, unit, target_ally_unit)
			end
		elseif blackboard.ally_inside_transport_unit then
			blackboard.ally_inside_transport_unit = nil
		end
	else
		blackboard.ally_inside_transport_unit = nil
	end
	
	--edit start--
	-- if override_melee then
	if override_melee or override_ranged then
		local rat_ogres = Managers.state.conflict:spawned_units_by_breed("skaven_rat_ogre")

		if table.find(rat_ogres, blackboard.target_unit) and blackboard.target_ally_needs_aid then
			override_melee = nil
			override_ranged = nil
		end
	end
	--edit end--

	-- if override_rat_ogre_flee or cover_position or override_melee then
	if override_rat_ogre_flee or cover_position or override_melee or override_ranged then
		-- local override = transport_unit_override or override_rat_ogre_flee or cover_position or override_melee
		local override = transport_unit_override or override_rat_ogre_flee or cover_position or override_melee or override_ranged
		local offset = override - navigation_ext:destination()

		if Z_MOVE_TO_EPSILON < math.abs(offset.z) or FLAT_MOVE_TO_EPSILON < Vector3.length(Vector3.flat(offset)) then
			local path_callback = (not transport_unit_override and (override_rat_ogre_flee or cover_position) and callback(self, "cb_cover_point_path_result", to_hash(override))) or nil

			navigation_ext:move_to(override, path_callback)

			blackboard.using_navigation_destination_override = true
		end
	else
		follow_bb.follow_timer = follow_bb.follow_timer - dt

		if not follow_bb.needs_target_position_refresh and (follow_bb.follow_timer < 0 or (blackboard.target_ally_needs_aid and navigation_ext:destination_reached())) then
			follow_bb.needs_target_position_refresh = true
		end

		if follow_bb.needs_target_position_refresh then
			local target_position = nil
			local goal_selection_func_name = blackboard.follow.goal_selection_func
			local path_callback = nil
			local enemy_unit = blackboard.target_unit

			if blackboard.revive_with_urgent_target and blackboard.target_ally_needs_aid then
				target_position = self:_alter_target_position(nav_world, self_pos, target_ally_unit, POSITION_LOOKUP[target_ally_unit], blackboard.target_ally_need_type)
				blackboard.interaction_unit = target_ally_unit
				path_callback = callback(self, "cb_ally_path_result", target_ally_unit)

				dprint("path to ally")
			elseif enemy_unit and (enemy_unit == blackboard.priority_target_enemy or enemy_unit == blackboard.urgent_target_enemy) and self:_enemy_path_allowed(enemy_unit) then
				target_position = self:_find_target_position_on_nav_mesh(nav_world, POSITION_LOOKUP[enemy_unit])
				path_callback = callback(self, "cb_enemy_path_result", enemy_unit)

				dprint("path to enemy", enemy_unit, target_position)
			elseif blackboard.target_ally_needs_aid then
				target_position = self:_alter_target_position(nav_world, self_pos, target_ally_unit, POSITION_LOOKUP[target_ally_unit], blackboard.target_ally_need_type)
				blackboard.interaction_unit = target_ally_unit
				path_callback = callback(self, "cb_ally_path_result", target_ally_unit)

				dprint("path to ally")
			elseif goal_selection_func_name and alive(target_ally_unit) then
				local func = LocomotionUtils[goal_selection_func_name]
				target_position = func(nav_world, unit, target_ally_unit)

				dprint("path to goal")
			elseif alive(blackboard.health_pickup) and blackboard.allowed_to_take_health_pickup and t < blackboard.health_pickup_valid_until and (self._last_health_pickup_attempt.unit ~= blackboard.health_pickup or not self._last_health_pickup_attempt.blacklist) then
				local pickup_unit = blackboard.health_pickup
				target_position = self:_find_pickup_position_on_navmesh(nav_world, self_pos, pickup_unit, self._last_health_pickup_attempt)

				if target_position then
					path_callback = callback(self, "cb_health_pickup_path_result", pickup_unit)
					blackboard.interaction_unit = pickup_unit
				end

				dprint("path to health pickup")
			elseif alive(blackboard.mule_pickup) and (self._last_mule_pickup_attempt.unit ~= blackboard.mule_pickup or not self._last_mule_pickup_attempt.blacklist) then
				local pickup_unit = blackboard.mule_pickup
				target_position = self:_find_pickup_position_on_navmesh(nav_world, self_pos, pickup_unit, self._last_mule_pickup_attempt)

				if target_position then
					path_callback = callback(self, "cb_mule_pickup_path_result", pickup_unit)
					blackboard.interaction_unit = pickup_unit
				end

				dprint("path to mule pickup")
			end

			if not target_position and alive(blackboard.ammo_pickup) and blackboard.needs_ammo and t < blackboard.ammo_pickup_valid_until then
				local ammo_position = POSITION_LOOKUP[blackboard.ammo_pickup]
				local dir = Vector3.normalize(self_pos - ammo_position)
				local above = 0.5
				local below = 1.5
				local lateral = 1
				local distance = 0
				target_position = self:_find_position_on_navmesh(nav_world, ammo_position, ammo_position + dir, above, below, INTERACT_RAY_DISTANCE - 0.3, distance)

				if target_position then
					blackboard.interaction_unit = blackboard.ammo_pickup
				end

				dprint("path to ammo pickup")
			end

			if not target_position then
				local ai_bot_group_ext = blackboard.ai_bot_group_extension
				target_position = ai_bot_group_ext.data.follow_position
				moving_towards_follow_position = true
			end

			if target_position then
				blackboard.moving_toward_follow_position = moving_towards_follow_position
				follow_bb.needs_target_position_refresh = false
				follow_bb.follow_timer = math.lerp(FOLLOW_TIMER_LOWER_BOUND, FOLLOW_TIMER_UPPER_BOUND, Math.random())

				follow_bb.target_position:store(target_position)

				local current_destination = nil

				if navigation_ext:destination_reached() then
					current_destination = self_pos
				else
					current_destination = navigation_ext:destination()
				end

				local offset = target_position - current_destination

				if Z_MOVE_TO_EPSILON < math.abs(offset.z) or FLAT_MOVE_TO_EPSILON < Vector3.length(Vector3.flat(offset)) then
					dprint("move to ", target_position)
					navigation_ext:move_to(target_position, path_callback)
				end

				blackboard.using_navigation_destination_override = false
			end
		end

		if blackboard.using_navigation_destination_override then
			navigation_ext:move_to(follow_bb.target_position:unbox())

			blackboard.using_navigation_destination_override = false
		end
	end
	
	local file_enabled		= bot_settings.menu_settings.bot_file_enabled
	if file_enabled then
		local self_unit			= self._unit
		local self_pos			= POSITION_LOOKUP[self_unit]
		local blackboard		= self._blackboard
		local follow_bb			= blackboard.follow
		-- local target_pos		= follow_bb.target_position:unbox()
		local follow_position	= nil
		local follow_unit		= nil
		if blackboard and blackboard.ai_bot_group_extension and blackboard.ai_bot_group_extension.data then
			follow_position	= blackboard.ai_bot_group_extension.data.follow_position
			follow_unit		= blackboard.ai_bot_group_extension.data.follow_unit
		end
		-- if self_pos and target_pos and follow_position then
		local navigation_extension = blackboard.navigation_extension
		if self_pos and follow_position and follow_unit and navigation_extension then
			local max_follow_timer	= math.huge
			local follow_distance	= Vector3.distance(follow_position, self_pos)
			local close_to_follow	= follow_distance < 4
			if t - new_transition_time < 0.5 then
				max_follow_timer	= 0.15
				-- EchoConsole("Newly created transition >> follow timer max = 0.15s")
			elseif (close_to_follow or navigation_extension:destination_reached()) then
				max_follow_timer	= 0.333
				-- EchoConsole("Close to follow pos >> follow timer max = 0.333s")
			end
			
			if follow_bb.follow_timer > max_follow_timer then
				follow_bb.follow_timer = max_follow_timer
			end
			
		end
	end
end)

Mods.hook.set(mod_name, "PlayerBotNavigation._goal_reached", function(func, self, position, goal, previous_goal, t)
	local goal_reached	= func(self, position, goal, previous_goal, t)
	local file_enabled	= bot_settings.menu_settings.bot_file_enabled
	
	if file_enabled and position and goal and previous_goal then
		local path_segment	= goal - previous_goal
		local pos_to_goal	= goal - position
		if Vector3.length(path_segment) > 0.01 and Vector3.length(pos_to_goal) > 0.01 then
			local path_segment_unit	= Vector3.normalize(path_segment)
			local pos_to_goal_unit	= Vector3.normalize(pos_to_goal)
			
			local goal_distance_flat = Vector3.length(Vector3.flat(pos_to_goal))
			local goal_cos = Vector3.dot(path_segment_unit, pos_to_goal_unit)	-- 1 = straight ahead, -1 = directly behind
			
			if goal_cos < 0.174 or goal_distance_flat < 0.1 then	-- check for ~80deg angle, original checks for 90deg angle, also 0.1 is sufficient for positional accuracy
				self._close_to_goal_time	= nil
				goal_reached				= true
			end
			
			-- local self_unit	= self._unit
			-- local owner		= Managers.player:unit_owner(self_unit)
			-- if owner and owner:name() == "Kerillian" then
				-- debug_print_variables("cos_to_goal", number_to_string(goal_cos, 3))
			-- end
		end
		
		--edit--
		if not bot_settings.lookup.path_preload.loading_done then
			if Managers.state.game_mode:is_round_started() then
				local level_id = LevelHelper:current_level_settings().level_id
				local map_data = bot_settings.lookup.path_preload[level_id]
				if map_data then
					for _,data in pairs(map_data) do
						-- EchoConsole("created transition")
						Managers.state.bot_nav_transition:create_transition(data[1]:unbox(), data[2]:unbox(), data[3]:unbox(), data[4], true)
					end
				end
				bot_settings.lookup.path_preload.loading_done = true
			end
		end
		
		-- if not bot_settings.lookup.path_preload.loading_done then
			-- local level_id = LevelHelper:current_level_settings().level_id
			-- if bot_settings.lookup.path_preload[level_id] then
				-- if self._astar and not self._running_astar and self._nav_world and self._traverse_data then
					-- local current_path = bot_settings.lookup.path_preload[level_id][bot_settings.lookup.path_preload.load_index]
					-- local start = current_path[1]:unbox()
					-- local stop = current_path[2]:unbox()
					-- GwNavAStar.start_with_propagation_box(self._astar, self._nav_world, start, stop, 30, self._traverse_data)
					-- bot_settings.lookup.path_preload.load_index = bot_settings.lookup.path_preload.load_index +1
					-- self._running_astar = true
				-- end
			-- else
				-- bot_settings.lookup.path_preload.loading_done = true
			-- end
		-- end
		--edit--
	end
	return goal_reached
end)

-- force bots to jump if they are too far away for mor than 2 seconds without moving or attacking
-- Vernon TODO: check this
--edit--
Mods.hook.set(mod_name, "BTBotFollowAction.run", function(func, self, unit, blackboard, t, dt)
	local bot	= Managers.player:unit_owner(unit)
	local d		= get_d_data(unit)
	
	local running, evaluate = func(self, unit, blackboard, t, dt)
	
	if not d or not d.settings.bot_file_enabled then
		return running, evaluate
	end
	
	local follow_unit = blackboard.ai_bot_group_extension.data.follow_unit
	if follow_unit and bot.bot_player then
		local follow_pos				= d.regroup.position
		local self_pos					= d.position
		local distance_to_follow_unit	= d.regroup.distance
		
		-- if distance_to_follow_unit > d.regroup.distance_threshold then
		if distance_to_follow_unit > bot_settings.forced_regroup.distance then
			local time_passed = t - d.unstuck_data.last_update
			local old_pos = d.unstuck_data.last_position:unbox()
			local distance_travelled = Vector3.length(old_pos-self_pos)
			-- if time_passed > 2 then
			if time_passed > 3 then
				if distance_travelled < 1.333 then
					if t - d.unstuck_data.last_attack > 2 then
						-- jump only if the bot is not actively attacking
						d.token.jump = true
					end
					d.unstuck_data.is_stuck		= true
					--
				else
					d.unstuck_data.is_stuck		= false
				end
				d.unstuck_data.last_update		= t
				d.unstuck_data.last_position	= Vector3Box(d.position)
			end
		else
			d.unstuck_data.is_stuck			= false
			d.unstuck_data.last_position	= Vector3Box(d.position)
			d.unstuck_data.last_update		= t
		end
	end
	
	return running, evaluate
end)
--edit--

-- Improve the bots' willingness to use ranged weapons
local ranged_weapons_charged_shot_data_initialized = false
Mods.hook.set(mod_name, "BTConditions.has_target_and_ammo_greater_than", function(func, blackboard, args)
	local self_unit			= blackboard.unit
	local self_owner		= Managers.player:unit_owner(self_unit) 
	local d					= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(blackboard, args)
	end
	
	if not Unit.alive(blackboard.target_unit) then
		return false
	end
	
	local enemy_ammo_threshold_selector	= (BTConditions.has_priority_or_opportunity_target(blackboard) and "special") or "default"
	local ammo_type_selector			= (d.equipped.heat_weapon and "heat_threshold") or "ammo_threshold"
	local ammo_threshold				= bot_settings[ammo_type_selector][enemy_ammo_threshold_selector]
	
	local threshold_factor				= (d.enough_hp_to_vent and bot_settings.heat_threshold.vent_threshold_factor) or bot_settings.heat_threshold.passive_threshold_factor
	if d.overheated then
		ammo_threshold = ammo_threshold * threshold_factor
	end
	
	-- by default most of the ranged weapons lack sufficient data to support bots using charged shots >> fill in the missing data
	if not ranged_weapons_charged_shot_data_initialized then
		update_weapon_templates_for_charged_shot_support()
		ranged_weapons_charged_shot_data_initialized = true
	end
	
	-- check if the bot has sufficient ammo / heat to shoot
	local ammo			= d.equipped.ranged_ammo
	local ammo_ok		= true
	local overcharge_ok	= true
	
	if d.equipped.heat_weapon then
		overcharge_ok	= ammo > (1 - ammo_threshold)
	else
		ammo_ok			= ammo > ammo_threshold
	end
	
	if overcharge_ok then
		d.overheated = false
	else
		d.overheated = true
	end
	
	if d.overheated and d.enough_hp_to_vent then
		overcharge_ok = true
	end
	
	-- check that there is no patrol rats marching on the background
	local target_unit			= d.melee.target_unit
	local self_pos				= d.position
	local patrol_rats = get_spawned_rats_by_breed("skaven_storm_vermin")
	local patrol_rat_in_firing_cone = false
	--
	for _,patrol_unit in pairs(patrol_rats) do
		local patrol_blackboard	= Unit.get_data(patrol_unit, "blackboard")
		local patrol_target		= patrol_blackboard.target_unit
		local patrol_pos		= POSITION_LOOKUP[patrol_unit]
		local patrol_dist		= Vector3.length(patrol_pos - self_pos)
		local patrol_has_target	= Unit.alive(patrol_target)
		
		if patrol_dist < 50 and is_secondary_within_cone(self_unit, target_unit, patrol_unit, 30) and not patrol_has_target then
			patrol_rat_in_firing_cone = true
		end
	end
	
	-- line of sight is available on d_data
	local has_line_of_sight = d.melee.has_line_of_sight
	
	return ammo_ok and overcharge_ok and has_line_of_sight and not patrol_rat_in_firing_cone
end)

Mods.hook.set(mod_name, "BTConditions.can_see_ally", function(func, blackboard)
	local self_unit		= blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit) 
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.bot_file_enabled then
		return func(blackboard)
	end
	
	-- check that there are no enemies nearby
	-- two trash rats are allowed, anything else and the bot may not use reduced teleport distance
	local prox_enemies = d.enemies.melee	-- check range was 4
	local enemy_threat = false
	if #prox_enemies > 1 then enemy_threat = true end	-- was >2  >> there had to be more than 3 enemies around to block teleport, now fixed to the intended 2
	for _,enemy_unit in pairs(prox_enemies) do
		local breed = Unit.get_data(enemy_unit, "breed")
		if breed.name ~= "skaven_clan_rat" and breed.name ~= "skaven_slave" then
			enemy_threat = true
		end
	end
	
	if d.unstuck_data.is_stuck and not enemy_threat then
		return Unit.alive(blackboard.target_ally_unit) and blackboard.ally_distance < 14
	end
	
	return Unit.alive(blackboard.target_ally_unit) and blackboard.ally_distance < 40
end)

-- Reduce situations where bots get stuck and won't teleport
Mods.hook.set(mod_name, "BTConditions.can_teleport", function(func, blackboard)
	local self_unit		= blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit) 
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.bot_file_enabled then
		return func(blackboard)
	end
	
	local follow_unit = blackboard.ai_bot_group_extension.data.follow_unit

	if not follow_unit then
		return false
	end
	
	-- the bots should never teleport when disabled
	if not self_unit then return false end
	if d.disabled or not d.teleport_allowed then
		return false
	end
	
	local level_settings = LevelHelper:current_level_settings()
	local disable_bot_main_path_teleport_check = level_settings.disable_bot_main_path_teleport_check

	if not disable_bot_main_path_teleport_check then
		local conflict_director = Managers.state.conflict
		local self_segment = conflict_director.get_player_unit_segment(conflict_director, self_unit) or 1
		local target_segment = conflict_director.get_player_unit_segment(conflict_director, follow_unit)
		
		-- allowance increased here to allow the bots to teleport to the same sector where they currently are
		-- instead only forward
		if not target_segment or (target_segment+1) < self_segment then
			return false
		end
	end
	
	return true
end)

-- again increased teleport allowance for bots to enable them to unstuck themselves with teleport
Mods.hook.set(mod_name, "BTConditions.cant_reach_ally", function(func, blackboard)
	local self_unit		= blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit) 
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.bot_file_enabled then
		return func(blackboard)
	end
	
	local follow_unit = blackboard.ai_bot_group_extension.data.follow_unit
	

	if not follow_unit then
		-- EchoConsole("can't reach ally failed: no follow unit")
		return false
	end

	-- the bots should never teleport when disabled
	if not self_unit then return false end
	if d.disabled or not d.teleport_allowed then
		return false
	end
	
	local level_settings = LevelHelper:current_level_settings()
	local disable_bot_main_path_teleport_check = level_settings.disable_bot_main_path_teleport_check
	local is_forwards = nil

	if not disable_bot_main_path_teleport_check then
		local conflict_director = Managers.state.conflict
		local self_segment = conflict_director.get_player_unit_segment(conflict_director, self_unit)
		local target_segment = conflict_director.get_player_unit_segment(conflict_director, follow_unit)

		if not self_segment or not target_segment then
			return false
		end

		-- allowance increased here to allow the bots to teleport to the same sector where they currently are
		-- instead only forward
		local is_backwards = (target_segment+1) < self_segment

		if is_backwards then
			return false
		end

		is_forwards = self_segment < (target_segment+1)
	end
	
	local t = d.current_time
	local navigation_extension = blackboard.navigation_extension
	local fails, last_success = navigation_extension.successive_failed_paths(navigation_extension)
	
	return blackboard.moving_toward_follow_position and (((disable_bot_main_path_teleport_check or is_forwards) and 1) or 5) < fails and 3 < t - last_success and not blackboard.has_teleported
end)
	

-- this is handled elswhere in the bot file
Mods.hook.set(mod_name, "AIBotGroupSystem._update_urgent_targets", function(func, self, dt, t)
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, dt, t)
	end
	
	return
end)

-- updated to use tokens instead of direct commands as the latter
-- causes bots to fail to fire charged shots in certain situations
Mods.hook.set(mod_name, "BTBotShootAction._fire_shot", function(func, self, shoot_blackboard, input_extension)
	local self_unit		= shoot_blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(self, shoot_blackboard, input_extension)
	end
	
	shoot_blackboard.fire_shot_token = true
end)


-- Improves bot aim speed
Mods.hook.set(mod_name, "BTBotShootAction._calculate_aim_speed",
function(func, self, self_unit, dt, current_yaw, current_pitch, wanted_yaw, wanted_pitch, current_yaw_speed, current_pitch_speed)
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(self, self_unit, dt, current_yaw, current_pitch, wanted_yaw, wanted_pitch, current_yaw_speed, current_pitch_speed)
	end
	
	-- this function's execuition is tied to FPS (each character once per frame)

	local target_unit	= d.melee.target_unit
	local self_pos		= d.position
	local target_pos	= d.melee.target_position
	local shot_distance	= d.melee.target_distance or math.huge
	
	local pi = math.pi
	local yaw_offset = (wanted_yaw - current_yaw + pi)%(pi*2) - pi
	local pitch_offset = wanted_pitch - current_pitch
	local yaw_offset_sign = math.sign(yaw_offset)
	local yaw_speed_sign = math.sign(current_yaw_speed)
	
	local offset_multiplier = 8*100*dt
	
	local new_yaw_speed = 0
	if yaw_offset >= 0 then
		new_yaw_speed = math.sqrt(yaw_offset)*offset_multiplier
	else
		new_yaw_speed = -math.sqrt(-yaw_offset)*offset_multiplier
	end
	
	local new_pitch_speed = 0
	if pitch_offset >= 0 then
		new_pitch_speed = math.sqrt(pitch_offset)*offset_multiplier
	else
		new_pitch_speed = -math.sqrt(-pitch_offset)*offset_multiplier
	end
	
	if math.abs(new_pitch_speed)*dt	> math.abs(pitch_offset)	then new_pitch_speed	= pitch_offset/dt end
	if math.abs(new_yaw_speed)*dt	> math.abs(yaw_offset)		then new_yaw_speed		= yaw_offset/dt end
	
	return new_yaw_speed, new_pitch_speed
end)

-- improve bot accuracy with ranged weapons
Mods.hook.set(mod_name, "BTBotShootAction._aim_good_enough", function(func, self, dt, t, shoot_blackboard, yaw_offset, pitch_offset)
	local self_unit		= shoot_blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(self, dt, t, shoot_blackboard, yaw_offset, pitch_offset)
	end
	
	local bb = shoot_blackboard

	if not bb.reevaluate_aim_time then
		bb.reevaluate_aim_time = 0
	end

	local aim_data = bb.aim_data

	if bb.reevaluate_aim_time < t then
		local offset = math.sqrt(pitch_offset*pitch_offset + yaw_offset*yaw_offset)
		
		if (aim_data.max_radius / 50) < offset then
			bb.aim_good_enough = false

			dprint("bad aim - offset:", offset)
		else
			local success = nil
			local num_rolls = bb.num_aim_rolls + 1

			if offset < aim_data.min_radius then
				success = Math.random() < aim_data.min_radius_pseudo_random_c*num_rolls
			else
				local prob = math.auto_lerp(aim_data.min_radius, aim_data.max_radius, aim_data.min_radius_pseudo_random_c, aim_data.max_radius_pseudo_random_c, offset)*num_rolls
				success = Math.random() < prob
			end

			success = true

			if success then
				bb.aim_good_enough = true
				bb.num_aim_rolls = 0

				dprint("fire! - offset:", offset, " num_rolls:", num_rolls)
			else
				bb.aim_good_enough = false
				bb.num_aim_rolls = num_rolls

				dprint("not yet - offset:", offset, " num_rolls:", num_rolls)
			end
		end

		bb.reevaluate_aim_time = t + 0.1
	end
	
	return bb.aim_good_enough
end)

-- apply aim correction for bots to conflag staff's charged attack
Mods.hook.set(mod_name, "BTBotShootAction._wanted_aim_rotation", function(func, self, self_unit, target_unit, current_position, projectile_info, projectile_speed, aim_at_node)
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(self, self_unit, target_unit, current_position, projectile_info, projectile_speed, aim_at_node)
	end
	
	local target_breed = Unit.get_data(target_unit, "breed")
	local weapon_id = d.equipped.weapon_id
	
	if target_breed.name == "skaven_gutter_runner" then
		-- Add override to gutter runner targeting to make bots always aim to their body.
		aim_at_node = "c_spine"
	elseif target_breed.boss and weapon_id == "es_repeating_handgun" then
		-- Add override to bosses so bots always try to headshot them with repeating handgun.
		aim_at_node = "j_head"

--edit--
	elseif target_breed.boss and weapon_id == "ww_shortbow" then
		-- Add override to bosses so bots always try to headshot them with swift bow.
		aim_at_node = "j_head"
--edit--
	end
	
	local passed_projectile_info = false
	
	if projectile_info then
		if projectile_info.projectile_unit_name == "units/weapons/player/spear_projectile/spear_3ps" then
			-- charged bolt
			passed_projectile_info = false
		elseif string.find(projectile_info.projectile_unit_name, "wpn_we_homing_arrow") then
			-- charged trueflight arrow
			passed_projectile_info = false
		else
			passed_projectile_info = projectile_info
		end 
	end
	
	local target_rotation, target_position = func(self, self_unit, target_unit, current_position, passed_projectile_info, projectile_speed, aim_at_node)
	
	if d.equipped.ranged then
		-- local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(self_unit)
		local weapon_type		= d.equipped.weapon_id
		local weapon_unit		= d.equipped.weapon_unit
		local weapon_template	= d.equipped.weapon_template
		
		if weapon_type == "bw_staff_geiser" and projectile_info == nil then	-- conflag staff charged attack
			local max_range = 20
			--edit start--
			-- local target_pos = POSITION_LOOKUP[target_unit]
			local target_pos = Vector3.copy(POSITION_LOOKUP[target_unit])
			if target_pos then
				local target_offset			= Vector3.normalize(Vector3.copy(target_pos - current_position))
				if not target_breed.boss then
					-- target_pos				= target_pos - (2.5 * target_offset)
					target_pos				= target_pos - (0.5 * target_offset)
				end
				target_offset				= target_pos - current_position
				local ret_pos			= Unit.world_position(target_unit, Unit.node(target_unit, aim_at_node))
				-- local target_offset		= target_pos - current_position
			--edit end--
				local flat_distance		= Vector3.length(Vector3.flat(target_offset))
				local angle_to_target	= math.asin(target_offset.z / Vector3.length(target_offset))
				
				local len1	= flat_distance * 8.3 / max_range
				local ang1	= math.pi/2 + angle_to_target
				local sin1	= math.min((len1 * math.sin(ang1)) / max_range, 1)
				local ang2	= math.asin(sin1)
				
				local required_aim_angle = ang2+angle_to_target	-- -pi/2 = straight down, 0 = straight forward, +pi/2 = straight up
				
				local ret_rot = Quaternion.multiply(Quaternion.look(Vector3.normalize(Vector3.flat(ret_pos - current_position)), Vector3.up()), Quaternion(Vector3.right(), required_aim_angle))
				return ret_rot, ret_pos
			end
		end
	end
	
	return target_rotation, target_position
	
end)

Mods.hook.set(mod_name, "BTBotShootAction.enter", function(func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	-- add the shooter's unit info to the shoot blackboard
	blackboard.shoot.unit = blackboard.unit
end)

--edit start--
-- Vernon: add functionality for bots to keep distance while shooting, ported from VT2 vanilla bots
-- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/c0bfbb87d92fb0aa10804260d6f39f4bdda5cb9e/scripts/entity_system/systems/behaviour/nodes/bot/bt_bot_shoot_action.lua#L69
local disengage_above_nav = 3
local disengage_below_nav = 3
local function check_angle_ranged(nav_world, target_position, start_direction, angle, distance)
	local direction = Quaternion.rotate(Quaternion(Vector3.up(), angle), start_direction)
	local check_pos = target_position + direction * distance
	local success, altitude = GwNavQueries.triangle_from_position(nav_world, check_pos, disengage_above_nav, disengage_below_nav)

	if success then
		check_pos.z = altitude

		return true, check_pos
	else
		return false
	end
end

local function get_disengage_pos(nav_world, start_pos, disengage_vector, move_distance)
	local disengage_direction = Vector3.normalize(Vector3.flat(disengage_vector))
	local success, pos = check_angle_ranged(nav_world, start_pos, disengage_direction, 0, move_distance)

	if success then
		return pos
	end

	local subdivisions_per_side = 3
	local angle_inc = (math.pi / 2) / subdivisions_per_side

	for i = 1, subdivisions_per_side, 1 do
		local angle = angle_inc * i
		success, pos = check_angle_ranged(nav_world, start_pos, disengage_direction, angle, move_distance)

		if success then
			return pos
		end

		success, pos = check_angle_ranged(nav_world, start_pos, disengage_direction, -angle, move_distance)

		if success then
			return pos
		end
	end

	return nil
end

local function get_disengage_vector(current_pos, enemy_unit, keep_distance, keep_distance_sq)
	if is_unit_alive(enemy_unit) then
		local target_unit_position = POSITION_LOOKUP[enemy_unit]
		local dist_sq = Vector3.distance_squared(current_pos, target_unit_position)

		if dist_sq < keep_distance_sq and dist_sq > 0 then
			local dist = math.sqrt(dist_sq)

			return (current_pos - target_unit_position) * (keep_distance - dist) / dist
		end
	end

	return nil
end

-- Vernon TODO: check alignment with original movement direction
local update_disengage_position = function (blackboard, t, keep_distance)
	local first_person_ext = blackboard.first_person_extension
	local self_position = first_person_ext:current_position()
	local shoot_bb = blackboard.shoot
	-- local keep_distance = shoot_bb.keep_distance
	local keep_distance_sq = keep_distance * keep_distance
	local num_close_targets = 0
	local disengage_vector = Vector3.zero()
	local proximite_enemies = blackboard.proximite_enemies

	if proximite_enemies then
		for i = 1, #proximite_enemies, 1 do
			local result = get_disengage_vector(self_position, proximite_enemies[i], keep_distance, keep_distance_sq)

			if result then
				num_close_targets = num_close_targets + 1
				disengage_vector = disengage_vector + result
			end
		end
	end

	if num_close_targets <= 0 then
		local target_unit = blackboard.shoot.target_unit
		local result = get_disengage_vector(self_position, target_unit, keep_distance, keep_distance_sq)

		if result then
			num_close_targets = 1
			disengage_vector = result
		end
	end

	local disengage_position, should_stop = nil

	if num_close_targets > 0 then
		local nav_world = blackboard.nav_world
		disengage_vector = Vector3.divide(disengage_vector, num_close_targets)
		disengage_position = get_disengage_pos(nav_world, self_position, disengage_vector, Vector3.length(disengage_vector))
	end

	if disengage_position then
		local override_box = blackboard.navigation_destination_override
		local override_destination = override_box:unbox()
		local disengage_position_set = shoot_bb.disengage_position_set

		if not disengage_position_set or Vector3.distance_squared(disengage_position, override_destination) > 0.01 then
			override_box:store(disengage_position)

			shoot_bb.disengage_position_set = true
			shoot_bb.stop_at_current_position = should_stop
		end

		local min_dist = 5
		local max_dist = 10
		local distance = Vector3.distance(self_position, disengage_position)
		-- local interval = math.auto_lerp(min_dist, max_dist, 0.5, 2, math.clamp(distance, min_dist, max_dist))
		local interval = math.auto_lerp(min_dist, max_dist, 0.5, 1, math.clamp(distance, min_dist, max_dist))
		shoot_bb.disengage_update_time = t + interval
	end
end
--edit end--

-- some updates to the ranged weapon charged shot support, otherwise copied from the original code
Mods.hook.set(mod_name, "BTBotShootAction._aim", function(func, self, unit, blackboard, dt, t)
	if not get(me.SETTINGS.BETTER_RANGED) or not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, unit, blackboard, dt, t)
	end
	
	local target_unit = blackboard.target_unit

	if not Unit.alive(target_unit) then
		return true
	end

	local shoot_bb = blackboard.shoot
	local first_person_ext = blackboard.first_person_extension
	local camera_position = first_person_ext:current_position()
	local camera_rotation = first_person_ext:current_rotation()

	if target_unit ~= shoot_bb.target_unit then
		self:_set_new_aim_target(unit, t, shoot_bb, target_unit, first_person_ext)
	end

	local action_data = self._tree_node.action_data
	local yaw_offset, pitch_offset, wanted_aim_rotation, actual_aim_rotation, actual_aim_position = self:_aim_position(dt, t, unit, camera_position, camera_rotation, target_unit, shoot_bb)

	if shoot_bb.reevaluate_obstruction_time < t then
		if self:_reevaluate_obstruction(unit, shoot_bb, action_data, t, World.get_data(blackboard.world, "physics_world"), camera_position, wanted_aim_rotation, unit, target_unit, actual_aim_position) then
			if not blackboard.ranged_obstruction_by_static then
				blackboard.ranged_obstruction_by_static = {}
				blackboard.ranged_obstruction_by_static.timer = t
			end

			blackboard.ranged_obstruction_by_static.unit = target_unit
		else
			blackboard.ranged_obstruction_by_static = nil
		end
	end

	local input_ext = blackboard.input_extension
	local range_squared = Vector3.distance_squared(camera_position, actual_aim_position)

	--edit start--
	local charging = false
	
	if self:_should_charge(shoot_bb, range_squared, target_unit) then
		self:_charge_shot(shoot_bb, input_ext, t)
		
		charging = true
	end
	
	local self_unit		= unit
	local d				= get_d_data(self_unit)
	
	if d and d.settings.better_melee and d.settings.bot_file_enabled then
		local weapon_id = d.equipped.weapon_id
		local keep_distance = bot_settings.lookup.ranged_keep_distance[weapon_id].both or (charging and bot_settings.lookup.ranged_keep_distance[weapon_id].charged) or ((not charging) and bot_settings.lookup.ranged_keep_distance[weapon_id].normal) or nil
		
		if not shoot_bb.disengage_update_time then
			shoot_bb.disengage_update_time = 0
		end
		
		if keep_distance and shoot_bb.disengage_update_time < t then
			update_disengage_position(blackboard, t, keep_distance)
		end
	else
		shoot_bb.disengage_position_set = false
	end
	--edit end--
	
	input_ext:set_aim_rotation(actual_aim_rotation)

	if self:_aim_good_enough(dt, t, shoot_bb, yaw_offset, pitch_offset) and self:_may_attack(target_unit, shoot_bb, range_squared, t) then
		self:_fire_shot(shoot_bb, input_ext)
	end

	local evaluate = (blackboard.fired and blackboard.next_evaluate < t) or blackboard.next_evaluate_without_firing < t

	if evaluate then
		blackboard.next_evaluate = t + action_data.evaluation_duration
		blackboard.next_evaluate_without_firing = t + action_data.evaluation_duration_without_firing
		blackboard.fired = false
	end
	
	-- Vernon: Let bots dodge while shooting
	-- local self_unit		= unit
	-- local d				= get_d_data(self_unit)
	
	if d and d.settings.better_melee and d.settings.bot_file_enabled then
		if not d.defense.last_calculate_dodge_time or bot_settings.dodge.recalculate_time < d.current_time - d.defense.last_calculate_dodge_time then
			local calculate_dodge = false
			
			if (#d.defense.threat_trash > 0 or #d.defense.threat_stormvermin > 0 or #d.defense.threat_boss > 0 or d.defense.need_to_dodge_packmaster or d.defense.need_to_dodge_assassin)
				and d.defense.dodge_count_left and d.defense.dodge_count_left >= -1 and not d.defense.is_dodging and d.defense.can_dodge and d.defense.on_ground then
				--
				calculate_dodge = true
			end

			if calculate_dodge and not d.token.dodge and not d.defense.is_dodging and d.defense.can_dodge then
				d.defense.last_calculate_dodge_time = d.current_time
				
				local move_x, move_y = refine_dodge_movement(d)

				if can_dodge_in_this_direction_safely(d, move_x, move_y) then
					d.token.dodge = true
				end
			end	
		end
		
		if d.defense.last_calculate_dodge_time and 5 < d.current_time - d.defense.last_calculate_dodge_time then
			d.defense.last_calculate_dodge_time = nil
		end
	end
	
	return false, evaluate
end)

-- changed the obstruction check to ignore other enemies and players
Mods.hook.set(mod_name, "BTBotShootAction._is_shot_obstructed", function(func, self, physics_world, from, direction, self_unit, target_unit, actual_aim_position, collision_filter)
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(self, physics_world, from, direction, self_unit, target_unit, actual_aim_position, collision_filter)
	end
	
	d.using_ranged	= true
	d.using_melee	= false
	
	-- vent overcharge (combat)
	vent_bot_ranged_weapon(d, true)
	
	if not d.melee.has_line_of_sight or d.token.ranged_vent or d.overheated then
		return true, d.melee.target_distance, true
	end
	
	return false
end)

-- bug fix - in original code max_range_squared doesn't use the value specified for charged shot, uses one for normal shot instead
-- also added support to deny charged attacks against armored targets in certain situations
Mods.hook.set(mod_name, "BTBotShootAction._should_charge", function(func, self, shoot_blackboard, range_squared, target_unit)
	local self_unit		= shoot_blackboard.unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.better_ranged or not d.settings.bot_file_enabled then
		return func(self, shoot_blackboard, range_squared, target_unit)
	end
	
	if not shoot_blackboard.can_charge_shot then
		return false
	end

	if shoot_blackboard.obstructed then
		return shoot_blackboard.charge_when_obstructed or false
	end
	
	-- add exception for beam staff to not use sniper attack against trash rats when sniper ammo conservation is on
	local has_beam_staff				= d.equipped.weapon_id == "bw_staff_beam"
	local breed							= d.melee.target_breed
	local target_is_trash				= breed.name == "skaven_slave" or breed.name == "skaven_clan_rat" or breed.name == "skaven_loot_rat"
	
	if has_beam_staff and target_is_trash and not bot_settings.menu_settings.snipers_shoot_trash then
		return false
	end
	
	-- add exception to volleybow to not use charged attackd against anything but ogre
	local has_volleybow					= d.equipped.weapon_id == "wh_repeating_crossbow"
	local target_is_resistant			= breed.name == "skaven_rat_ogre" or breed.name == "skaven_pack_master"
	
	if has_volleybow and not target_is_resistant then
		return false
	end

	--add exception for swift bow to use charged attack against clan rats
	local has_swift_bow					= d.equipped.weapon_id == "ww_shortbow"
	local target_is_clan				= breed.name == "skaven_clan_rat"
	
	if has_swift_bow and target_is_clan then
		return true
	end
	
	local max_range_squared = shoot_blackboard.max_range_squared_charged

	if max_range_squared < range_squared then
		return shoot_blackboard.charge_when_outside_max_range
	end
	
	local target_breed = Unit.get_data(target_unit, "breed")
	local target_armor = (target_breed and target_breed.armor_category) or 1
	
	if target_armor == 2 and not shoot_blackboard.charge_against_armoured_enemy then
		return false
	end
	
	return shoot_blackboard.always_charge_before_firing or shoot_blackboard.charging_shot or (shoot_blackboard.charge_range_squared and shoot_blackboard.charge_range_squared < range_squared) or (shoot_blackboard.charge_against_armoured_enemy and (not target_breed or target_breed.armor_category == 2))
end)

--[[
	Allow bots to loot pinged items. By Walterr, IamLupo and Grimalackt.
	- Xq: added general pinged object variable and support for small ammo & ammo crates
--]]
local pinged_grim = nil
local pinged_tome = nil
local pinged_potion = nil
local pinged_grenade = nil
local pinged_heal = nil
local pinged_ammo = nil
local pinged_ammo_crate = nil
local pinged_storm = nil
local pinged_object = nil

Mods.hook.set(mod_name, "PingTargetExtension.set_pinged", function (func, self, pinged)
	
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, pinged)
	end
	
	if pinged then
		for _,bot in pairs(Managers.player:bots()) do
			if Unit.alive(bot.player_unit) then
				bot.pinged_debug_text_token = true
			end
		end
		
		pinged_object = self._unit
		
		local pickup_extension = ScriptUnit.has_extension(self._unit, "pickup_system")
		local pickup_settings = pickup_extension and pickup_extension:get_pickup_settings()
		local is_inventory_item = pickup_settings and (pickup_settings.type == "inventory_item")
		local health_extension = ScriptUnit.has_extension(self._unit, "health_system") and
			Unit.get_data(self._unit, "breed") and
			(Unit.get_data(self._unit, "breed").name == "skaven_storm_vermin_commander"
			or Unit.get_data(self._unit, "breed").name == "skaven_storm_vermin") and
			ScriptUnit.extension(self._unit, "health_system")
		
		if is_inventory_item and (pickup_settings.item_name == "wpn_grimoire_01") and
				get(me.SETTINGS.LOOT_GRIMOIRES) then
			pinged_grim = self._unit
		else
			pinged_grim = nil
		end

		if is_inventory_item and (pickup_settings.item_name == "wpn_side_objective_tome_01") and
				get(me.SETTINGS.LOOT_TOMES) then
			pinged_tome = self._unit
		else
			pinged_tome = nil
		end

		if is_inventory_item and (pickup_settings.item_name == "potion_speed_boost_01" or
				pickup_settings.item_name == "potion_damage_boost_01") then
			pinged_potion = self._unit
		else
			pinged_potion = nil
		end

		if is_inventory_item and (pickup_settings.item_name == "grenade_frag_01" or
				pickup_settings.item_name == "grenade_frag_02" or
				pickup_settings.item_name == "grenade_fire_01" or
				pickup_settings.item_name == "grenade_fire_02") then
			pinged_grenade = self._unit
		else
			pinged_grenade = nil
		end

		if is_inventory_item and (pickup_settings.item_name == "potion_healing_draught_01" or
				pickup_settings.item_name == "healthkit_first_aid_kit_01") then	
			pinged_heal = self._unit
		else
			pinged_heal = nil
		end

		if health_extension then
			pinged_storm = self._unit
		end
		
		if pickup_extension and pickup_extension.pickup_name == "all_ammo_small" then
			pinged_ammo = self._unit
		else
			pinged_ammo = nil
		end
		
		if pickup_extension and pickup_extension.pickup_name == "all_ammo" then
			pinged_ammo_crate = self._unit
		else
			pinged_ammo_crate = nil
		end
	
	else
		
		if self._unit == pinged_grim then
			pinged_grim = nil
		elseif self._unit == pinged_tome then
			pinged_tome = nil
		elseif self._unit == pinged_potion then
			pinged_potion = nil
		elseif self._unit == pinged_grenade then
			pinged_grenade = nil
		elseif self._unit == pinged_heal then
			pinged_heal = nil
		elseif self._unit == pinged_storm then
			pinged_storm = nil
		elseif self._unit == pinged_ammo then
			pinged_ammo = nil
		elseif self._unit == pinged_ammo_crate then
			pinged_ammo_crate = nil
		end
		
		if self._unit == pinged_object then
			pinged_object = nil
		end
	end

	return func(self, pinged)
end)


--[[
	Add BTConditions.can_loot_pinged_item:
		This checks the logic on whether or not bots can loot a specific item.
	
	- Xq: added support for small ammo pickups & ammo crates, added improved logic on which bot should pick the pinged item
--]]
BTConditions.can_loot_pinged_item = function (blackboard)
	-- Avoids possible crash
	if blackboard.unit == nil then
		return false
	end
	
	if not Unit.alive(pinged_object) or not Unit.alive(blackboard.unit) then
		-- stop spamming the whole function if the pinged item is no more (has been picked up)
		-- same if the bot is not in play
		return false
	end
	
	local self_unit			= blackboard.unit
	local self_unit_owner	= Managers.player:owner(self_unit)
	local d					= get_d_data(self_unit)
	
	if not d or not d.settings.bot_file_enabled then
		return false
	end
	
	-- disabled bots don't pick up stuff
	if d.disabled then
		return false
	end
	
	local force_loot = d.settings.force_loot
	
	-- couple of ranges used in this function
	local BOT_ITEM_PICKUP_DISTANCE = 14
	local PLAYER_NEAR_PICKUP_DISTANCE = 3.5	-- 2.8
	
	-- in case of "the fall" survival map, we want to make sure bots won't
	-- snatch pinged items from the closed cages >> that map uses reduced pickup distance
	local pickup_distance_reduction = false
	if LevelHelper:current_level_settings().level_id == "dlc_survival_ruins" then
		pickup_distance_reduction = true
	end
	
	if pinged_grim then
		-- the conditions on picking up grims are mostly the same as originally in QoL
		-- added condition that the pickup is allowed only for the bot best suited to pick the grim
		local grim_posn = POSITION_LOOKUP[pinged_grim]

		-- Check if a player is near the grimoire
		local player_near_grimoire = false
		for i, player in pairs(Managers.player:human_players()) do
			if grim_posn and player.player_unit and (3.5 > Vector3.distance(POSITION_LOOKUP[player.player_unit], grim_posn)) then
				player_near_grimoire = true
			end
		end
		
		local bot_may_take_grim = may_pick_potionslot_item(self_unit, pinged_grim, bot_settings.menu_settings.pickup_grims)
		
		-- the bot best suited to pick the grim should pick it, not whatever bot happes to process the ping first
		if not bot_may_take_grim then
			return false
		end
		
		if not player_near_grimoire then
			return false
		end

		-- Check distance to grim
		if grim_posn and (14.0 < Vector3.distance(d.position, grim_posn)) then
			return false
		end
		
		if ENABLE_PICKUP_ON_PING_DEBUG_OUTPUT and Unit.alive(pinged_grim) and self_unit_owner.pinged_debug_text_token then
			self_unit_owner.pinged_debug_text_token = false
			EchoConsole(tostring(self_unit_owner.character_name) .. " picked up pinged grim")
		end
		
		blackboard.interaction_unit = pinged_grim
		return true
	end

	if pinged_tome then
		-- the conditions on picking up tomes are mostly the same as originally in QoL
		-- added condition that the pickup is allowed only for the bot best suited to pick the tome
		local tome_posn = POSITION_LOOKUP[pinged_tome]
		local inventory_ext = d.extensions.inventory
		local health_slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_healthkit")

		-- Check if bot already has a tome
		if health_slot_data then
			local item = inventory_ext.get_item_template(inventory_ext, health_slot_data)
  			if item.name == "wpn_side_objective_tome_01" then
				return false
			end
		end
		
		-- check if this bot is allowed to pick the tome (=best bot to pick it)
		if not may_pick_healslot_item(self_unit, pinged_tome, true, true, true) then
			return false
		end 
		
		-- Case : Courier - 2nd tome - grabbing through barrel mini-game
		if tome_posn and tome_posn.x == -73.59222412109375 and tome_posn.y == 250.91647338867187 and tome_posn.z == 9.4020509719848633 and (3.5 < Vector3.distance(d.position, tome_posn)) then
			return false
		end
		-- Case : Wizard's tower - 3rd tome - grabbing from below
		if tome_posn and tome_posn.x == 144.01631164550781 and tome_posn.y == 85.939056396484375 and tome_posn.z == 60.007415771484375 and (d.position.z < tome_posn.z - 0.5) then
			return false
		end
		-- Check distance to tome
		if tome_posn and (7 < Vector3.distance(d.position, tome_posn)) then
			return false
		end
		
		if ENABLE_PICKUP_ON_PING_DEBUG_OUTPUT and Unit.alive(pinged_tome) and self_unit_owner.pinged_debug_text_token then
			self_unit_owner.pinged_debug_text_token = false
			EchoConsole(tostring(self_unit_owner.character_name) .. " picked up pinged tome")
		end
		
		blackboard.interaction_unit = pinged_tome
		return true
	end

	if pinged_potion then
		local potion_posn = POSITION_LOOKUP[pinged_potion]
		local inventory_ext = d.extensions.inventory
		
		local player_nearby_with_empty_slot, player_within_grabbing_distance = check_players_near_pickup(pinged_object, 20, PLAYER_NEAR_PICKUP_DISTANCE)
		if player_nearby_with_empty_slot and not force_loot then return false end
		
		local bot_may_take_potion = may_pick_potionslot_item(self_unit, pinged_potion, true)
		
		-- Xq: changed the slot item check to compare against specific item type instead of just empty / full
		-- Check if bot already has this type of potion
		if not bot_may_take_potion then
			return false
		end

		-- Check distance to potion
		if not DEBUG_PARAMETER_20191029 and potion_posn and ((pickup_distance_reduction and 3.0 < Vector3.distance(d.position, potion_posn)) or BOT_ITEM_PICKUP_DISTANCE < Vector3.distance(d.position, potion_posn) or not player_within_grabbing_distance) then
			return false
		end
		
		-- make sure that multiple bots don't try to snatch the item at the same moment (=during the same frame)
		for _,bot in pairs(Managers.player:bots()) do
			local loop_unit = bot.player_unit
			if Unit.alive(loop_unit) then
				local loop_blackboard = Unit.get_data(loop_unit, "blackboard")
				if loop_unit ~= self_unit and loop_blackboard.interaction_unit == pinged_potion then
					return false
				end
			end
		end
		
		if ENABLE_PICKUP_ON_PING_DEBUG_OUTPUT and Unit.alive(pinged_potion) and self_unit_owner.pinged_debug_text_token then
			self_unit_owner.pinged_debug_text_token = false
			EchoConsole(tostring(self_unit_owner.character_name) .. " picked up pinged potion")
		end
		
		blackboard.interaction_unit = pinged_potion
		return true
	end

	if pinged_grenade then
		local grenade_posn = POSITION_LOOKUP[pinged_grenade]
		local inventory_ext = d.extensions.inventory
		
		local player_nearby_with_empty_slot, player_within_grabbing_distance = check_players_near_pickup(pinged_object, 20, PLAYER_NEAR_PICKUP_DISTANCE)
		if player_nearby_with_empty_slot and not force_loot then return false end
		
		local bot_may_take_grenade = may_pick_grenadeslot_item(self_unit, pinged_grenade)
		
		-- Xq: changed the slot item check to compare against specific item type instead of just empty / full
		-- Check if bot already has this type of grenade
		if not bot_may_take_grenade then
			return false
		end
		
		if not DEBUG_PARAMETER_20191029 and grenade_posn and ((pickup_distance_reduction and 3.0 < Vector3.distance(d.position, grenade_posn)) or BOT_ITEM_PICKUP_DISTANCE < Vector3.distance(d.position, grenade_posn) or not player_within_grabbing_distance) then
			return false
		end
		
		-- make sure that multiple bots don't try to snatch the item at the same moment (=during the same frame)
		for _,bot in pairs(Managers.player:bots()) do
			local loop_unit = bot.player_unit
			if Unit.alive(loop_unit) then
				local loop_blackboard = Unit.get_data(loop_unit, "blackboard")
				if loop_unit ~= self_unit and loop_blackboard.interaction_unit == pinged_grenade then
					return false
				end
			end
		end
		
		if ENABLE_PICKUP_ON_PING_DEBUG_OUTPUT and Unit.alive(pinged_grenade) and self_unit_owner.pinged_debug_text_token then
			self_unit_owner.pinged_debug_text_token = false
			EchoConsole(tostring(self_unit_owner.character_name) .. " picked up pinged grenade")
		end
		
		blackboard.interaction_unit = pinged_grenade
		return true
	end
	
	-- Xq: added support for bots picking up heals when pinged
	if pinged_heal then
		local item_posn = POSITION_LOOKUP[pinged_heal]
		
		local player_nearby_with_empty_slot, player_within_grabbing_distance = check_players_near_pickup(pinged_object, 20, PLAYER_NEAR_PICKUP_DISTANCE)
		if player_nearby_with_empty_slot and not force_loot then return false end
		
		local may_swap_heals = not is_in_heal_swap_denial_area(item_posn) and force_loot == false
		if not may_pick_healslot_item(self_unit, pinged_heal, may_swap_heals, true, true, force_loot) then
			return false
		end 
		
		-- Check distance to grenade
		if not DEBUG_PARAMETER_20191029 and item_posn and ((pickup_distance_reduction and 3.0 < Vector3.distance(d.position, item_posn)) or BOT_ITEM_PICKUP_DISTANCE < Vector3.distance(d.position, item_posn) or not player_within_grabbing_distance) then
			return false
		end

		-- make sure that multiple bots don't try to snatch the item at the same moment (=during the same frame)
		for _,bot in pairs(Managers.player:bots()) do
			local loop_unit = bot.player_unit
			if Unit.alive(loop_unit) then
				local loop_blackboard = Unit.get_data(loop_unit, "blackboard")
				if loop_unit ~= self_unit and loop_blackboard.interaction_unit == pinged_heal then
					return false
				end
			end
		end
		
		if ENABLE_PICKUP_ON_PING_DEBUG_OUTPUT and Unit.alive(pinged_heal) and self_unit_owner.pinged_debug_text_token then
			self_unit_owner.pinged_debug_text_token = false
			EchoConsole(tostring(self_unit_owner.character_name) .. " picked up pinged heal")
		end
		
		blackboard.interaction_unit = pinged_heal
		return true
	end

	-- Xq: added support for consumable ammo pickups
	if pinged_ammo then
		local item_posn = POSITION_LOOKUP[pinged_ammo]
		local ammo = d.equipped.ranged_ammo
		
		local player_nearby_uses_ammo, player_within_grabbing_distance = check_players_near_pickup(pinged_object, 20, PLAYER_NEAR_PICKUP_DISTANCE)
		if (player_nearby_uses_ammo or d.settings.small_ammo_needs_forcing) and not force_loot then return false end
		
		-- No need to pick up ammo if its full..
		-- also, bots shouldn't pick up pinged single use ammo if unless..
		-- * there is just one ammo using human or
		-- * all humans use heat based weapons
		-- (as otherwisre the ping probably isn't really meant for the bots)
		if ammo >= 1 or d.equipped.heat_weapon then
			return false
		end
		
		-- go through all the bots, if there is another bot with less ammo than this bot then this bot shouldn't pick up the ammo
		local bot_with_least_ammo = 
		{
			units = {},
			ammo = math.huge,
		}
		-- first check which bot(s) have least ammo
		for _, bot in pairs(Managers.player:bots()) do
			local loop_d = get_d_data(bot.player_unit)
			local loop_ammo = loop_d and loop_d.equipped.ranged_ammo
			if loop_d and not loop_d.disabled and not loop_d.equipped.heat_weapon and loop_ammo < 1 then
				
				-- the bot is on white (no wounds left) >> pretend it has more ammo than it really has for this comparison
				-- the pretended ammo percentage is current percentage x 3 but always at least 50%
				if not loop_d.extensions.status:has_wounds_remaining() and loop_ammo < 1 then
					loop_ammo = math.max(loop_ammo * 3, 0.5)
				end
				
				if loop_ammo < bot_with_least_ammo.ammo then
					bot_with_least_ammo.ammo	= loop_ammo
					bot_with_least_ammo.units	= {}
					bot_with_least_ammo.units[bot.player_unit] = true
					--
				elseif loop_ammo == bot_with_least_ammo.ammo then
					bot_with_least_ammo.units[bot.player_unit] = true
					--
				end
			end
		end
		-- then check if this bot is on the list, if not then don't pick
		if not bot_with_least_ammo.units[d.unit] then
			return false
		end
		
		-- Check distance to ammo
		if not DEBUG_PARAMETER_20191029 and item_posn and ((pickup_distance_reduction and 3.0 < Vector3.distance(d.position, item_posn)) or BOT_ITEM_PICKUP_DISTANCE < Vector3.distance(d.position, item_posn) or not player_within_grabbing_distance) then
			return false
		end

		-- make sure that multiple bots don't try to snatch the item at the same moment (=during the same frame)
		for _,bot in pairs(Managers.player:bots()) do
			local loop_unit = bot.player_unit
			if Unit.alive(loop_unit) then
				local loop_blackboard = Unit.get_data(loop_unit, "blackboard")
				if loop_unit ~= self_unit and loop_blackboard.interaction_unit == pinged_ammo then
					return false
				end
			end
		end
		
		if ENABLE_PICKUP_ON_PING_DEBUG_OUTPUT and Unit.alive(pinged_ammo) and self_unit_owner.pinged_debug_text_token then
			self_unit_owner.pinged_debug_text_token = false
			EchoConsole(tostring(self_unit_owner.character_name) .. " picked up pinged ammo")
		end
		
		blackboard.interaction_unit = pinged_ammo
		return true
	end

	-- Xq: added support for ammo crate pickups
	if pinged_ammo_crate then
		local item_posn = POSITION_LOOKUP[pinged_ammo_crate]
		local ammo = d.equipped.ranged_ammo
		
		local _, player_within_grabbing_distance = check_players_near_pickup(pinged_object, 20, PLAYER_NEAR_PICKUP_DISTANCE, bot_settings.lookup.pickup_distance_exceptions)
		
		-- No need to pick up ammo if its full..
		if ammo >= 1 or d.equipped.heat_weapon then
			return false
		end
		
		-- Check distance to ammo
		if not DEBUG_PARAMETER_20191029 and item_posn and (BOT_ITEM_PICKUP_DISTANCE < Vector3.distance(d.position, item_posn) or not player_within_grabbing_distance) then
			return false
		end

		if ENABLE_PICKUP_ON_PING_DEBUG_OUTPUT and self_unit_owner.pinged_debug_text_token then
			self_unit_owner.pinged_debug_text_token = false
			EchoConsole(tostring(self_unit_owner.character_name) .. " used pinged ammo crate")
		end
		
		blackboard.interaction_unit = pinged_ammo_crate
		return true
	end

	return false
end

--[[
	Insert InteractAction into BotBehaviors for looting items.
	-- Xq: changed the insertion point in the behavior tree
--]]
local insert_bt_node = function(lua_node)
	local lua_tree = BotBehaviors.default
	for i = 1, math.huge, 1 do
		if not lua_tree[i] then
			EchoConsole("ERROR: insertion point not found")
			return
		elseif lua_tree[i].name == lua_node.name then
			--EchoConsole("ERROR: bt node " .. lua_node.name .. " already inserted")
			return
		elseif lua_tree[i].name == "loot" then	-- was originally "in_combat", changed to "loot" by Xq
			-- this inserts the tree node into the position where the node defined in the elseif condition originally was
			-- the said nodes and all nodes after is are pushed forward by 1 index
			table.insert(lua_tree, i, lua_node)
			return
		end
	end
end
insert_bt_node({
	"BTBotInteractAction",
	condition = "can_loot_pinged_item",
	name = "loot_pinged_item"
})


--[[
	Improve the efficiency with which bots trade items. Patch 1.8.3+. By Grimalackt.
	-- Xq: modified the trade restrictions so that the restriction is removed after three seconds from the last trade
	-- instead of the bot ending up more than 5u away from its follow target
--]]
Mods.hook.set(mod_name, "InventorySystem.rpc_give_equipment", function(func, self, sender, game_object_id, slot_id, item_name_id, position)
	
	func(self, sender, game_object_id, slot_id, item_name_id, position)
	
	if not get(me.SETTINGS.FILE_ENABLED) then
		return
	end
	
	-- Sender is the peer id of the host / client that gave the item but.. it doesn't tell if the sender is bot or human. Bots and host player all use the host's peer id.
	local unit			= self.unit_storage:unit(game_object_id)

	if Unit.alive(unit) and not ScriptUnit.extension(unit, "status_system"):is_dead() then
		local owner = Managers.player:owner(unit)	-- this is the player / bot receiving the item
		if not owner.remote and owner.bot_player then
			-- this triggers when:
			--	player gives item to bot
			--	bot gives item to another bot
			-- this function does NOT trigger when:
			--	bot gives item to player
			local network_manager = Managers.state.network
			bot_settings.trading.wasjusttraded[network_manager.unit_game_object_id(network_manager, unit)] = true
			bot_settings.trading.last_trade_time = Managers.time:time("game")
			local item_name			= NetworkLookup.item_names[item_name_id]
			local item_is_potion	= item_name == "potion_damage_boost_01" or item_name == "potion_speed_boost_01"
			local item_is_grenade	= item_name == "grenade_fire_01" or item_name == "grenade_fire_02" or item_name == "grenade_frag_01" or item_name == "grenade_frag_02"
			
			if item_is_grenade then
				bot_settings.trading.last_grenade_given_to_bots = item_name
			elseif item_is_potion then
				bot_settings.trading.last_potion_given_to_bots = item_name
			end
			-- EchoConsole(NetworkLookup.item_names[item_name_id])
		end
	end
end)

local function can_interact_with_ally(self_unit, target_ally_unit)
	local interactable_extension = ScriptUnit.extension(target_ally_unit, "interactable_system")
	local pickup_unit = interactable_extension.is_being_interacted_with(interactable_extension)
	local can_interact_with_ally = pickup_unit == nil or pickup_unit == self_unit

	return can_interact_with_ally
end

local trading_frame_checker = new_frame_checker()
Mods.hook.set(mod_name, "BTConditions.can_help_in_need_player", function (func, blackboard, args)
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(blackboard, args)
	end
	
	local current_time	= Managers.time:time("game")
	local need_type		= args[1]
	
	if blackboard.target_ally_need_type == need_type then
		if need_type == "can_accept_heal_item" or need_type == "can_accept_potion" or need_type == "can_accept_grenade" then
			-- bot wants to give a heal, potion, or grenade to an ally
			
			-- generate a list of active trades once on each frame
			if trading_frame_checker:is_new_frame() then
				trading_frame_checker:update()
				-- once in a frame, clean the trade data..
				-- heal items
				for key,data in pairs(bot_settings.trading.active_trades.can_accept_heal_item) do
					if current_time > data.expires_at then
						bot_settings.trading.active_trades.can_accept_heal_item[key] = nil
					end
				end
				-- potions
				for key,data in pairs(bot_settings.trading.active_trades.can_accept_potion) do
					if current_time > data.expires_at then
						bot_settings.trading.active_trades.can_accept_potion[key] = nil
					end
				end
				-- grenades
				for key,data in pairs(bot_settings.trading.active_trades.can_accept_grenade) do
					if current_time > data.expires_at then
						bot_settings.trading.active_trades.can_accept_grenade[key] = nil
					end
				end
				
				-- now check each bot for pending trades
				for _,self_owner in pairs(Managers.player:bots()) do
					
					local self_unit				= self_owner.player_unit	-- unit that wants to trade an item
					local self_blackboard		= self_unit and Unit.get_data(self_unit, "blackboard")
					local ally_unit				= self_blackboard and self_blackboard.target_ally_unit	-- unit that would receive the item
					local ally_status_extension	= ally_unit and ScriptUnit.has_extension(ally_unit, "status_system")
					local self_status_extension	= self_unit and ScriptUnit.has_extension(self_unit, "status_system")
					local self_valid			= is_unit_alive(self_unit) and self_status_extension and not self_status_extension:is_disabled()	-- trading parties are valid only if they exists, are alive, and are not disabled
					local ally_valid			= is_unit_alive(ally_unit) and ally_status_extension and not ally_status_extension:is_disabled()
					local ally_need_type		= self_blackboard and self_blackboard.target_ally_need_type
					local valid_ally_need_type	= ally_need_type and (ally_need_type == "can_accept_heal_item" or ally_need_type == "can_accept_potion" or ally_need_type == "can_accept_grenade")	-- this should always be true here, but added a check for safety
					
					if self_valid and ally_valid and not (self_unit == ally_unit) and valid_ally_need_type then
						local active_trades = bot_settings.trading.active_trades[ally_need_type]
						if not active_trades[ally_unit] then
							-- if there is no active trades for the receiving unit then generate a new trade entry for the unit
							active_trades[ally_unit] = 
							{
								distance		= math.huge,
								item_giver		= -1,
								expires_at		= current_time + 10,
								trading_started	= false,
							}
						end
						
						local self_position		= POSITION_LOOKUP[self_unit]
						local ally_position		= POSITION_LOOKUP[ally_unit]
						local distance_to_ally	= self_position and ally_position and Vector3.length(self_position - ally_position)
						
						local network_manager	= Managers.state.network
						local item_id			= network_manager.unit_game_object_id(network_manager, self_unit)
						local may_trade_item	= not bot_settings.trading.wasjusttraded[item_id]
						
						-- update the trade entry if this bot is closer to the trade recipient and the trade is allowed
						if distance_to_ally and distance_to_ally < active_trades[ally_unit].distance and may_trade_item and not active_trades[ally_unit].trading_started then
							-- essentially, what ends here is the closest unit to the recipient that may trade the item to the requested slot
							active_trades[ally_unit].distance	= distance_to_ally
							active_trades[ally_unit].item_giver	= self_unit
							active_trades[ally_unit].expires_at	= current_time + 10
						end
					end
				end
			end
			
			local wasjusttraded = bot_settings.trading.wasjusttraded
			local last_trade_time = bot_settings.trading.last_trade_time
			local ally_distance = blackboard.ally_distance
			local self_unit = blackboard.unit
			local network_manager = Managers.state.network
			local self_unit_id = network_manager.unit_game_object_id(network_manager, self_unit)
			local current_time = Managers.time:time("game")
			
			if 3.75 < ally_distance then
				return false
			end

			local target_ally_unit = blackboard.target_ally_unit
			local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)
			
			local active_trade = bot_settings.trading.active_trades[need_type][target_ally_unit]
			local may_trade_with_target = active_trade and self_unit == active_trade.item_giver
			
			if can_interact_with_ally and not wasjusttraded[self_unit_id] and may_trade_with_target then
				if target_ally_unit == Managers.player:local_player().player_unit then
					active_trade.expires_at			= current_time + 0.1
				else
					active_trade.expires_at			= current_time + 0.6
				end
				active_trade.trading_started	= true
				-- local self_owner	= Managers.player:unit_owner(self_unit)
				-- local ally_owner	= Managers.player:unit_owner(target_ally_unit)
				-- local self_name		= self_owner and self_owner:name() or "no self name"
				-- local ally_name		= ally_owner and ally_owner:name() or "no ally name"
				-- EchoConsole(self_name .. " wants to give item to " .. ally_name)
				
				return true
			end
		else
			local ally_distance = blackboard.ally_distance

			if 2.5 < ally_distance then
				return false
			end

			local self_unit = blackboard.unit
			local target_ally_unit = blackboard.target_ally_unit
			local destination_reached = blackboard.navigation_extension:destination_reached()
			local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)

			if can_interact_with_ally and destination_reached then
				return true
			end
		end
	end

	return
end)

Mods.hook.set(mod_name, "PlayerBotBase._alter_target_position", function (func, self, nav_world, self_position, unit, target_position, reason)
	local network_manager = Managers.state.network
	local unit_id = network_manager.unit_game_object_id(network_manager, self._unit)
	local wasjusttraded = bot_settings.trading.wasjusttraded
	if get(me.SETTINGS.FILE_ENABLED) and (reason == "can_accept_grenade" or reason == "can_accept_potion" or reason == "can_accept_heal_item") and wasjusttraded[unit_id] then
		return
	else
		return func(self, nav_world, self_position, unit, target_position, reason)
	end
end)


--[[
	Allow bots to ping stormvermins attacking them. By Grimalackt.
--]]
BTConditions.can_ping_storm = function (blackboard)
	if not get(me.SETTINGS.PING_STORMVERMINS) then
		return false
	end

	-- Avoids possible crash
	if blackboard.unit == nil then
		return false
	end

	local self_unit = blackboard.unit

	if pinged_storm then
		local health_extension = ScriptUnit.has_extension(pinged_storm, "health_system") and ScriptUnit.extension(pinged_storm, "health_system")

		if health_extension and health_extension.current_health_percent(health_extension) <= 0 then
			pinged_storm = nil
		end
	end

	for _, enemy_unit in pairs(blackboard.proximite_enemies) do
		if Unit.alive(enemy_unit) and Unit.get_data(enemy_unit, "blackboard").target_unit == self_unit and
			(Unit.get_data(enemy_unit, "breed").name == "skaven_storm_vermin_commander" or Unit.get_data(enemy_unit, "breed").name == "skaven_storm_vermin") and
			ScriptUnit.extension(enemy_unit, "health_system").current_health_percent(ScriptUnit.extension(enemy_unit, "health_system")) > 0 and not pinged_storm then
			blackboard.interaction_unit = enemy_unit
			local network_manager = Managers.state.network
			local self_unit_id = network_manager.unit_game_object_id(network_manager, self_unit)
			local enemy_unit_id = network_manager.unit_game_object_id(network_manager, enemy_unit)
			network_manager.network_transmit:send_rpc_server("rpc_ping_unit", self_unit_id, enemy_unit_id)
			return true
		end
	end

	return false
end

local ping_stormvermin_action = {
	"BTBotInteractAction",
	condition = "can_ping_storm",
	name = "ping_stormvermin"
}

insert_bt_node(ping_stormvermin_action)

--[[
	This is literally a bugfix of Fatshark's code. Bots will no longer refuse to revive you if targeted by a stormvermin. By Grimalackt.
--]]
Mods.hook.set(mod_name, "BTConditions.can_revive", function (func, blackboard)
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(blackboard)
	end
	
	if blackboard.target_ally_need_type == "knocked_down" then
		local ally_distance = blackboard.ally_distance

		if 2.25 < ally_distance then
			return false
		end
		
		-- TODO: evaluate if there is a need to prevent bots from trying to revive other bots
		-- when stormvermin are launching attacks that threat the reviver
		
		local self_unit = blackboard.unit
		local target_ally_unit = blackboard.target_ally_unit

		local destination_reached = blackboard.navigation_extension:destination_reached()
		local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)
		local bot_stuck_threshold = 1

		if can_interact_with_ally and (destination_reached or ally_distance < 1.75 or Vector3.length_squared(blackboard.locomotion_extension:current_velocity()) < bot_stuck_threshold*bot_stuck_threshold) then
			return true
		end
	end

	return
end)

-- Xq: give bots more leniency when trying to rescue a player hanging from a ledge
Mods.hook.set(mod_name, "BTConditions.can_rescue_ledge_hanging", function (func, blackboard)
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(blackboard)
	end
	
	local is_there_threat_to_aid = function(self_unit, proximite_enemies, force_aid)
		for _, enemy_unit in pairs(proximite_enemies) do
			if is_unit_alive(enemy_unit) then
				local enemy_blackboard = Unit.get_data(enemy_unit, "blackboard")
				local enemy_breed = enemy_blackboard.breed

				if enemy_blackboard.target_unit == self_unit and (not force_aid or enemy_breed.is_bot_aid_threat) then
					return true
				end
			end
		end

		return false
	end
	
	if blackboard.target_ally_need_type == "ledge" then
		local ally_distance = blackboard.ally_distance

		if ally_distance > 2.25 then
			return false
		end

		local self_unit = blackboard.unit

		if is_there_threat_to_aid(self_unit, blackboard.proximite_enemies, blackboard.force_aid) then
			return false
		end

		local target_ally_unit = blackboard.target_ally_unit
		local self_whereabouts_extension = ScriptUnit.extension(self_unit, "whereabouts_system")
		local self_is_jumping = self_whereabouts_extension._jumping
		local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)

		if can_interact_with_ally and not self_is_jumping then
			return true
		end
	end
end)


--[[
	Allow manual control of bot use of healing items. By Walterr.
--]]

-- Xq: changed the hotkeys to use common interface, "get_hotkey_state" function.
local get_selected_player = function ()
	local selected_player_id =	((get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY1) or "numpad 0") and 0) or
								 (get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY2) or "numpad 1") and 1) or
								 (get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY3) or "numpad 2") and 2) or 
								 (get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY4) or "numpad 3") and 3))
	if not selected_player_id then
		return nil
	end

	local ingame_ui = Managers.matchmaking.ingame_ui
	local unit_frames_handler = ingame_ui and ingame_ui.ingame_hud.unit_frames_handler
	if unit_frames_handler then
		-- The unit frames and player_data are never nil, although player might be.
		-- Vernon TODO: check for true solo...
		return unit_frames_handler._unit_frames[selected_player_id + 1].player_data.player
	end
	return nil
end

local can_perform_heal = function (unit, heal_self)
		local inventory_ext = ScriptUnit.has_extension(unit, "inventory_system")
		local health_slot_data = inventory_ext and inventory_ext:get_slot_data("slot_healthkit")
		if health_slot_data then
			local item_template = inventory_ext:get_item_template(health_slot_data)
			return (heal_self and item_template.can_heal_self) or ((not heal_self) and item_template.can_heal_other)
		end
		return false
end

local bot_heal_info = { player_unit = nil, healing_self = false }

Mods.hook.set(mod_name, "BTConditions.bot_should_heal", function (func, blackboard)	-- bot healing itself
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(blackboard)
	end
	
	local self_unit		= blackboard.unit
	local d				= get_d_data(self_unit)
	local enemy_threat	= not d or #d.defense.threat_boss > 0 or #d.defense.threat_trash > 0 or #d.defense.threat_stormvermin > 0
	
	
	local heal_option	= get(me.SETTINGS.MANUAL_HEAL)
	
	local manual_heal_enabled	= heal_option ~= MANUAL_HEAL_DISABLED
	local auto_heal_enabled		= heal_option ~= MANUAL_HEAL_MANDATORY
	local heal_only_if_wounded	= bot_settings.menu_settings.heal_only_if_wounded_all
	local ret					= false
	
	local has_dove				= utils:get_unit_data(self_unit, "dove")
	local has_medkit			= utils:get_unit_data(self_unit, "medkit")
	local has_draught			= utils:get_unit_data(self_unit, "draught")
	
	local has_heal_item			= has_medkit or has_draught
	if not has_heal_item then
		return false
	end
	
	if manual_heal_enabled then
		-- resolve healing need based on manual heal trigger
		ret = bot_heal_info.healing_self and (bot_heal_info.player_unit == blackboard.unit)
	end
	
	if not ret and not enemy_threat and auto_heal_enabled then
		local is_wounded		= utils:get_unit_data(self_unit, "wounded")
		--edit start--
		-- local is_being_healed	= utils:get_unit_data(self_unit, "is_being_healed")
		local is_being_healed = false
--[[
		is_being_healed = function(unit)
			local ret				= false
			local HEALSHARE_RANGE	= 15
			local self_pos			= POSITION_LOOKUP[unit]
			local self_unit			= unit
			
			if unit and self_pos then
				for _,owner in pairs(Managers.player:bots()) do
					local unit = owner.player_unit
					local pos = unit and POSITION_LOOKUP[unit]
					local distance = pos and self_pos and Vector3.distance(pos, self_pos)
					local blackboard = Unit.get_data(unit, "blackboard")
					if distance and blackboard and unit ~= self_unit then
						local target_ally	= blackboard.target_ally_unit
						local healing_other	= blackboard.is_healing_other
						local healing_self	= blackboard.is_healing_self
						local healshare		= utils:get_unit_data(unit, "healshare")	-- may crash
						
						if healing_other and target_ally == self_unit then
							ret = true
							break
						elseif healshare and healing_self and distance < HEALSHARE_RANGE then
							ret = true
							break
						end	
					end
				end
			end
			
			return ret
		end
--]]
		local HEALSHARE_RANGE	= 15
		-- local unit = self_unit
		local self_pos = POSITION_LOOKUP[self_unit]
		
		if self_unit and self_pos then
			for _,owner in pairs(Managers.player:bots()) do
				local unit = owner.player_unit
				if unit ~= self_unit then
					local pos = unit and POSITION_LOOKUP[unit]
					local distance = pos and self_pos and Vector3.distance(pos, self_pos)
					-- local blackboard = Unit.get_data(unit, "blackboard")
					local blackboard = unit and Unit.get_data(unit, "blackboard")
					-- if distance and blackboard and unit ~= self_unit then
					if distance and blackboard then
						local target_ally	= blackboard.target_ally_unit
						local healing_other	= blackboard.is_healing_other
						local healing_self	= blackboard.is_healing_self
						-- local healshare		= utils:get_unit_data(unit, "healshare")	-- may crash
						local healshare		= unit and utils:get_unit_data(unit, "healshare")	-- may crash
						
						if healing_other and target_ally == self_unit then
							is_being_healed = true
							break
						elseif healshare and healing_self and distance < HEALSHARE_RANGE then
							is_being_healed = true
							break
						end
					end
				end
			end
		end
		--edit end--
		
		if not has_dove or has_draught then
			-- if the bot has no dove then it may heal itself if it is the best healer for itself (or is wounded)
			-- resolve healing need based on bot healing logic
			local best_healer, best_heal_target = find_best_healer(self_unit, true)
			local health_percent	= utils:get_unit_data(self_unit, "hp_percent")
			local is_hurt			= health_percent < 0.25
			local is_best_healer	= best_healer == self_unit and (not best_heal_target or best_heal_target == self_unit)
			local may_heal_self		= false
			if heal_only_if_wounded then
				may_heal_self = is_wounded and (is_hurt or is_best_healer)
			else
				may_heal_self = (is_hurt and is_best_healer) or is_wounded
			end
			ret = may_heal_self
		else
			-- if the bot does have dove and a medkit, but has no-one alse to heal, its still allowed to heal itself if wounded.
			ret = is_wounded
		end
		
		--edit start--
		ret = ret and not is_being_healed
		--edit end--
	end
	
	--edit start--
	-- if not ret and not enemy_threat and auto_heal_enabled and blackboard.target_ally_need_type == "healshare" then
		-- ret = true
	-- end
	--edit end--
	
	return ret
end)

-- Vernon: version 20220116
--[[
-- Xq: allow bots to ignore threat from trash rats if manually commanded to use medkit
Mods.hook.set(mod_name, "BTConditions.can_heal_player", function (func, blackboard)	-- bot healing someone else
	local ret = func(blackboard)
	local self_unit = blackboard.unit
	local d = get_d_data(self_unit)
	local enemy_threat			= not d or #d.defense.threat_boss > 0 or #d.defense.threat_trash > 0 or #d.defense.threat_stormvermin > 0
	local manual_heal_enabled	= bot_settings.menu_settings.manual_heal
	local manual_heal_requested	=	((get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY1) or "numpad 0") and 0) or
									(get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY2) or "numpad 1") and 1) or
									(get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY3) or "numpad 2") and 2) or 
									(get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY4) or "numpad 3") and 3))
	--
	if d and manual_heal_enabled and manual_heal_requested then
		-- the below is almost direct copy from the game's original routine
		if blackboard.target_ally_need_type == "in_need_of_heal" then
			if blackboard.is_healing_other then
				return true
			end
			
			local ally_distance = blackboard.ally_distance
			
			if 2.5 < ally_distance then
				return false
			end
			
			-- Xq: changed the condition so that only SV / bosses are considered possible threats for healing other when heal is ordered by the human
			if not d or #d.defense.threat_stormvermin > 0 or #d.defense.threat_boss > 0 then
				return false
			end
			
			local self_unit = blackboard.unit
			local target_ally_unit = blackboard.target_ally_unit
			local destination_reached = blackboard.navigation_extension:destination_reached()
			local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)
			
			if can_interact_with_ally and destination_reached then
				return true
			end
		end
		
		return
	end
	
	if enemy_threat then ret = false end
	
	return ret
end)
-- \Xq
--]]

--edit start--
-- Vernon: version 20210926
-- Xq: allow bots to ignore threat from trash rats if manually commanded to use medkit
Mods.hook.set(mod_name, "BTConditions.can_heal_player", function (func, blackboard)	-- bot healing someone else
	if not bot_settings.menu_settings.bot_file_enabled then
		return func(blackboard)	-- just call the original
	end
	
	local self_unit				= blackboard.unit
	local target_ally_unit		= blackboard.target_ally_unit
	local manual_heal_enabled	= bot_settings.menu_settings.manual_heal
	local manual_heal_requested	=	manual_heal_enabled and
									((get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY1) or "numpad 0") and 0) or
									(get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY2) or "numpad 1") and 1) or
									(get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY3) or "numpad 2") and 2) or 
									(get_hotkey_state(get(me.SETTINGS.MANUAL_HEAL_KEY4) or "numpad 3") and 3))
	local d = get_d_data(self_unit)
	
	if d and self_unit and target_ally_unit then
		local enemy_threat			= #d.defense.threat_boss > 0 or #d.defense.threat_stormvermin > 0 or (#d.defense.threat_trash > 0 and not manual_heal_requested)
		local correct_ally_need		= blackboard.target_ally_need_type == "in_need_of_heal"
		if not correct_ally_need then
			return false
		end
		
		if blackboard.is_healing_other and not enemy_threat then
			return true
		end
		
		local can_interact			= can_interact_with_ally(self_unit, target_ally_unit)
		local destination_reached	= blackboard.navigation_extension:destination_reached()
		local ally_distance 		= blackboard.ally_distance
		local distance_ok			= ally_distance and ally_distance <= 2.5
		
		if can_interact and correct_ally_need and destination_reached and distance_ok and not enemy_threat then
			return true
			--
		end
		--
	end
	
	return false
end)
--edit end--

-- Xq: Make bots to willingly pass healing draughts to healshare players
local select_ally_by_utility = function(self, unit, blackboard, breed, t)
	local d = get_d_data(unit)
	-- manual heal is disabled so use "default" routine (though modified)
	local WANTS_TO_HEAL_THRESHOLD = 0.25
	local WANTS_TO_GIVE_HEAL_TO_OTHER = 0.5
	local heal_only_if_wounded = bot_settings.menu_settings.heal_only_if_wounded_all
	local self_unit = unit
	local self_pos = POSITION_LOOKUP[unit]
	local closest_ally = nil
	local closest_ally = nil
	local closest_dist = math.huge
	local closest_real_dist = math.huge
	local closest_in_need_type = nil
	local inventory_ext = blackboard.inventory_extension
	local health_slot_data = inventory_ext:get_slot_data("slot_healthkit")
	-- local can_heal_other = false
	local can_heal_other = utils:get_unit_data(self_unit, "medkit")
	-- local can_give_healing_to_other = false
	local can_give_healing_to_other = utils:get_unit_data(self_unit, "draught")
	local self_buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	-- local self_has_healshare = self_buff_extension and self_buff_extension:has_buff_type("medpack_spread_area")
	local self_has_healshare = utils:get_unit_data(self_unit, "healshare")
	-- local self_has_dove = self_buff_extension and self_buff_extension:has_buff_type("heal_self_on_heal_other")
	local self_has_dove = utils:get_unit_data(self_unit, "dove")
	-- local self_health_percent = get_bot_current_health_percent(unit)
	local self_health_percent = utils:get_unit_data(self_unit, "hp_percent")
	local self_status_ext = ScriptUnit.has_extension(unit, "status_system")
	-- local self_is_wounded = self_status_ext and self_status_ext:is_wounded()
	local self_is_wounded = utils:get_unit_data(self_unit, "wounded")
	-- local self_has_grim = inventory_ext:get_item_name("slot_potion") == "wpn_grimoire_01"
	local self_has_grim = utils:get_unit_data(self_unit, "grimoire")
	local self_items = get_equipped_item_info(self_unit)
	local wants_to_heal_self = false
	
	if heal_only_if_wounded then
		wants_to_heal_self = self_is_wounded
	else
		wants_to_heal_self = self_health_percent < WANTS_TO_HEAL_THRESHOLD or self_is_wounded
	end
	
	local self_needs_dove_target = self_has_dove and self_items.medkit and wants_to_heal_self	
	local best_dove_target = false
	if self_needs_dove_target then
		local dove_healer, dove_target = find_best_healer_forced(self_unit)
		best_dove_target = dove_target or dove_healer
	end
	
	local deathwish_enabled			= (rawget(_G, "deathwishtoken") and true) or false
	
	local preferred_speed			= d.settings.trading_prefer_speed
	local preferred_strength		= d.settings.trading_prefer_strength
	local preferred_frag			= d.settings.trading_prefer_frag
	local preferred_fire			= d.settings.trading_prefer_fire
	
	local last_potion_given_to_bots = bot_settings.trading.last_potion_given_to_bots
	if d.settings.trading_prefer_different_potion then
		if last_potion_given_to_bots == "potion_damage_boost_01" then
			preferred_speed	= true
		elseif last_potion_given_to_bots == "potion_speed_boost_01" then
			preferred_strength	= true
		end
	end
	
	local last_grenade_given_to_bots = bot_settings.trading.last_grenade_given_to_bots
	if d.settings.trading_prefer_different_grenade then
		if last_grenade_given_to_bots == "grenade_fire_01" or last_grenade_given_to_bots == "grenade_fire_02" then
			preferred_frag	= true
		elseif last_grenade_given_to_bots == "grenade_frag_01" or last_grenade_given_to_bots == "grenade_frag_02" then
			preferred_fire	= true
		end
	end
	
	local other_bot_has_strength	= false
	local other_bot_has_speed		= false
	local other_bot_has_frag		= false
	local other_bot_has_fire		= false
	for _,loop_owner in pairs(Managers.player:bots()) do
		local loop_unit = loop_owner.player_unit
		if loop_unit ~= self_unit then
			local loop_pos		= POSITION_LOOKUP[loop_unit]
			local loop_distance	= (self_pos and loop_pos and Vector3.distance(self_pos, loop_pos)) or math.huge
			local loop_items	= get_equipped_item_info(loop_unit)
			
			if loop_distance < d.settings.trading_prefer_max_distance then
				if loop_items.strength_potion	then other_bot_has_strength	= true end
				if loop_items.speed_potion		then other_bot_has_speed	= true end
				if loop_items.frag_grenade		then other_bot_has_frag		= true end
				if loop_items.fire_grenade		then other_bot_has_fire		= true end
			end
		end
	end
	
	-- if health_slot_data then
		-- local template = inventory_ext:get_item_template(health_slot_data)
		-- can_heal_other = template.can_heal_other
		-- can_give_healing_to_other = template.can_give_other
	-- end

	local can_give_grenade_to_other = false
	local grenade_slot_data = inventory_ext:get_slot_data("slot_grenade")

	if grenade_slot_data then
		local template = inventory_ext:get_item_template(grenade_slot_data)
		can_give_grenade_to_other = template.can_give_other
	end

	local can_give_potion_to_other = false
	local potion_slot_data = inventory_ext:get_slot_data("slot_potion")

	if potion_slot_data then
		local template = inventory_ext:get_item_template(potion_slot_data)
		can_give_potion_to_other = template.can_give_other
	end
	
	local players = Managers.player:players()

	for k, player in pairs(players) do
		local player_unit	= player.player_unit
		local ally_is_bot	= player.bot_player
		local ally_is_human	= not ally_is_bot

		if AiUtils.unit_alive(player_unit) and player_unit ~= unit then
			local status_ext = ScriptUnit.extension(player_unit, "status_system")
			local utility = 0

			if not status_ext:is_ready_for_assisted_respawn() then
				local in_need_type = nil

				if status_ext:is_knocked_down() then
					in_need_type = "knocked_down"
					utility = 40
				elseif status_ext:get_is_ledge_hanging() and not status_ext:is_pulled_up() then
					in_need_type = "ledge"
					utility = 40
				elseif status_ext:is_hanging_from_hook() then
					in_need_type = "hook"
					utility = 40
				else
					-- local debug_unit = Managers.player:local_player().player_unit
					-- EchoConsole(utils:get_unit_data(debug_unit, "grenade_item") ~= "")
					local ally_unit					= player_unit
					-- local ally_health_percent		= get_bot_current_health_percent(player_unit)	-- since this routine is only called when host, this should work fine with human players too
					local ally_health_percent		= utils:get_unit_data(ally_unit, "hp_percent")
					-- local ally_inventory_ext		= ScriptUnit.extension(player_unit, "inventory_system")
					-- local ally_has_grenade			= ally_inventory_ext:get_slot_data("slot_grenade")
					-- local ally_has_potion			= ally_inventory_ext:get_slot_data("slot_potion")
					-- local ally_has_healsot_item		= ally_inventory_ext:get_slot_data("slot_healthkit")
					local ally_has_grenade			= utils:get_unit_data(ally_unit, "grenade_item") ~= ""
					local ally_has_potion			= utils:get_unit_data(ally_unit, "potion_item") ~= ""
					local ally_has_healsot_item		= utils:get_unit_data(ally_unit, "heal_item") ~= ""
					local ally_can_accept_draught	= not ally_has_healsot_item
					-- local ally_is_wounded			= status_ext:is_wounded()
					local ally_is_wounded			= utils:get_unit_data(ally_unit, "wounded")
					-- local buff_ext					= ScriptUnit.has_extension(player_unit, "buff_system")
					-- local ally_has_healshare		= buff_ext and buff_ext:has_buff_type("medpack_spread_area")
					local ally_has_healshare		= utils:get_unit_data(ally_unit, "healshare")
					local ally_hp_compare			= (ally_is_wounded and ally_health_percent - 0.5) or ally_health_percent
					local self_hp_compare			= (self_is_wounded and self_health_percent - 0.5) or self_health_percent
					-- local ally_items				= get_equipped_item_info(player_unit)
					
					local best_healer, healer_override		= find_best_healer(ally_unit, true)
					local best_human_to_receive_draught		= find_best_human_to_receive_draught(self_unit)
					local is_best_human_to_receive_draught	= best_human_to_receive_draught == ally_unit
					
					local pass_draught_to_human = 
						ally_is_human and ally_can_accept_draught and can_give_healing_to_other and 
						(
							bot_settings.menu_settings.pass_draughts_to_humans == "Always" or									-- Always
							(bot_settings.menu_settings.pass_draughts_to_humans == "Healshare" and ally_has_healshare) or 		-- Healshare
							(bot_settings.menu_settings.pass_draughts_to_humans_forced and is_best_human_to_receive_draught) or	-- Always on hotkey
							(
								bot_settings.menu_settings.pass_draughts_to_humans == "Default" and								-- Use "default" logic
								ally_has_healshare or 
								(
									ally_hp_compare < self_hp_compare and
									(ally_health_percent < WANTS_TO_GIVE_HEAL_TO_OTHER or ally_is_wounded) and
									not self_has_healshare and
									not (self_is_wounded and not ally_is_wounded) and
									(
										not self_has_grim or
										ally_is_wounded
									)
								)
							)
						)
					--
					if self_has_healshare and ((ally_health_percent < WANTS_TO_HEAL_THRESHOLD and deathwish_enabled) or ally_is_wounded) and best_healer == self_unit and healer_override and self_hp_compare < 0.999 then
						-- heal ally / allies via healshare
						-- debug_print_variables("in_need_type	= healshare")
						closest_in_need_type	= "healshare"
						closest_ally			= self_unit
						closest_real_dist		= 0
						--edit start--
						closest_dist			= -math.huge
						--edit end--
						-- in_need_type			= "healshare"
						-- utility					= 25
						break
					elseif ally_unit == best_dove_target then
						-- use dove on an ally (or self if no hurt allies)
						in_need_type	= "in_need_of_heal"
						utility			= 25
					elseif can_heal_other and ((ally_health_percent < WANTS_TO_HEAL_THRESHOLD and not heal_only_if_wounded) or ally_is_wounded) and best_healer == self_unit then
						-- heal ally
						-- debug_print_variables("in_need_type	= in_need_of_heal")
						in_need_type = "in_need_of_heal"
						local health_utility = 1 - ((ally_is_wounded and ally_health_percent * 0.33) or ally_health_percent)
						utility = 10 + health_utility * 15
					elseif pass_draught_to_human then
						-- Xq: pass draught to healthy human if setting for it is enabled
						in_need_type = "pass_draught_to_human"
						utility = 9
					elseif ally_is_bot and can_give_healing_to_other and ally_can_accept_draught and (ally_hp_compare < self_hp_compare) and (ally_health_percent < WANTS_TO_GIVE_HEAL_TO_OTHER or ally_is_wounded) and not self_has_healshare then
						-- pass heal to hurt/wounded teammate
						in_need_type = "can_accept_heal_item"
						local health_utility = 1 - ((ally_is_wounded and ally_health_percent - 0.5) or ally_health_percent)
						utility = 10 + health_utility * 10
					elseif ally_is_bot and can_give_healing_to_other and ally_can_accept_draught and ally_has_healshare and not self_has_healshare then
						-- Xq: pass heal to healshare carrier with priority healshare (bot) < healshare (human)
						in_need_type = "can_accept_heal_item"
						utility = 10
					elseif can_give_grenade_to_other and not ally_has_grenade and not ally_is_bot then
						-- pass grenade to human
						if d.settings.trading_prefer_enable then
							if preferred_frag then
								if self_items.frag_grenade then
									in_need_type = "can_accept_grenade"
									utility = 10
								elseif self_items.fire_grenade and not other_bot_has_frag then
									in_need_type = "can_accept_grenade"
									utility = 10
								end
							elseif preferred_fire then
								if self_items.fire_grenade then
									in_need_type = "can_accept_grenade"
									utility = 10
								elseif self_items.frag_grenade and not other_bot_has_fire then
									in_need_type = "can_accept_grenade"
									utility = 10
								end
							else
								in_need_type = "can_accept_grenade"
								utility = 10
							end
						else
							in_need_type = "can_accept_grenade"
							utility = 10
						end
					elseif can_give_potion_to_other and not ally_has_potion and not ally_is_bot then
						-- pass potion to human
						if d.settings.trading_prefer_enable then
							if preferred_strength then
								-- human prefers strength
								if self_items.strength_potion then
									in_need_type = "can_accept_potion"
									utility = 10
								elseif self_items.speed_potion and not other_bot_has_strength then
									in_need_type = "can_accept_potion"
									utility = 10
								end
							elseif preferred_speed then
								-- human prefers speed
								if self_items.speed_potion then
									in_need_type = "can_accept_potion"
									utility = 10
								elseif self_items.strength_potion and not other_bot_has_speed then
									in_need_type = "can_accept_potion"
									utility = 10
								end
							else
								in_need_type = "can_accept_potion"
								utility = 10
							end
						else
							in_need_type = "can_accept_potion"
							utility = 10
						end
					end
				end
				
				if in_need_type or not ally_is_bot then
					local target_pos = POSITION_LOOKUP[player_unit]
					local allowed_follow_path, allowed_aid_path = self:_ally_path_allowed(player_unit, t)

					if allowed_follow_path then
						if not allowed_aid_path then
							in_need_type = nil
						elseif in_need_type then
							local rat_ogres = Managers.state.conflict:spawned_units_by_breed("skaven_rat_ogre")

							for _, rat_ogre_unit in pairs(rat_ogres) do
								local dist_sq = Vector3.distance_squared(target_pos, POSITION_LOOKUP[rat_ogre_unit])
								local range = (blackboard.target_ally_unit == player_unit and blackboard.target_ally_needs_aid and 16) or 25

								if dist_sq < range then
									in_need_type = nil

									break
								end
							end
						end

						if in_need_type or not ally_is_bot then
							local real_dist = Vector3.distance(self_pos, target_pos)
							local dist = real_dist - utility

							if closest_dist > dist then
								closest_dist = dist
								closest_real_dist = real_dist
								closest_ally = player_unit
								closest_in_need_type = in_need_type
							end
						end
					end
				end
			end
		end
	end
	
	return closest_ally, closest_real_dist, closest_in_need_type
end

local invalid_manual_heal_targets = {}
local last_manual_heal_target = false
Mods.hook.set(mod_name, "PlayerBotBase._select_ally_by_utility", function(func, self, unit, blackboard, breed, t)
	local heal_option = get(me.SETTINGS.MANUAL_HEAL)
	
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, unit, blackboard, breed, t)
	elseif MANUAL_HEAL_DISABLED == heal_option then
		return select_ally_by_utility(self, unit, blackboard, breed, t)
	end
	
	
	-- clean invalid_manual_heal_targets list
	local current_time = Managers.time:time("game")
	for loop_unit, expires_at in pairs(invalid_manual_heal_targets) do
		if current_time > expires_at then
			invalid_manual_heal_targets[loop_unit] = nil
		end
	end
	
	-- if manual heal is enabled in some form use this routine (mostly from QoL)
	local no_manual_heal_optimization	= bot_settings.menu_settings.no_manual_heal_optimization
	local selected_player				= get_selected_player()
	local selected_unit					= selected_player and selected_player.player_unit
	last_manual_heal_target				= selected_unit or last_manual_heal_target
	if invalid_manual_heal_targets[selected_unit] then
		selected_unit = false
	end
	
	local best_healer		= false
	local target_override	= false
	if no_manual_heal_optimization then
		local ally_hp_percent = utils:get_unit_data(selected_unit, "hp_percent")
		if selected_unit and ally_hp_percent < 1 and not utils:get_unit_data(unit, "disabled") then
			-- select healer
			local bots = Managers.player:bots()
			local best_distance = math.huge
			for _, owner in pairs(bots) do
				local unit = owner.player_unit
				local self_pos = POSITION_LOOKUP[unit]
				local ally_pos = POSITION_LOOKUP[selected_unit]
				local ally_distance = (self_pos and ally_pos and Vector3.distance(self_pos, ally_pos)) or math.huge
				if not utils:get_unit_data(unit, "disabled") and can_perform_heal(unit, unit == selected_unit) and ally_distance < best_distance then
					best_distance = ally_distance
					best_healer = unit
				end
			end
		end
	else
		if selected_unit and utils:get_unit_data(selected_unit, "hp_percent") < 1 then
			best_healer, target_override	= find_best_healer_forced(selected_unit)
		end
	end
		
	selected_unit = target_override or selected_unit
	if selected_unit == unit and best_healer == unit then
		bot_heal_info.player_unit	= unit
		bot_heal_info.healing_self	= true
		return nil, math.huge, nil
		--
	elseif selected_unit and best_healer == unit then
		bot_heal_info.player_unit	= unit
		bot_heal_info.healing_self	= false
		return selected_unit, Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[selected_unit]), "in_need_of_heal"
		--
	elseif bot_heal_info.player_unit == unit then
		bot_heal_info.player_unit	= nil
		bot_heal_info.healing_self	= false
		--
	end
	
	-- local ally_unit, real_dist, in_need_type = func(self, unit, blackboard, breed, t)
	local ally_unit, real_dist, in_need_type = select_ally_by_utility(self, unit, blackboard, breed, t)
	
	-- Stop the bot from auto-healing someone if only manual healing is allowed.
	local manual_heal_only = (MANUAL_HEAL_MANDATORY == heal_option)
	local override_ally_need = ally_unit and ("in_need_of_heal" == in_need_type) and (manual_heal_only or bot_heal_info.player_unit)
	
	-- if in_need_type == "healshare" and not manual_heal_only then
		-- -- force the bot to heal self in order to proc healshare
		-- bot_heal_info.player_unit	= unit
		-- bot_heal_info.healing_self	= true
		-- return nil, math.huge, nil
	-- end
	
	-- force bots to  pass draughts to humans if relevant setting is enabled
	override_ally_need = override_ally_need or in_need_type == "pass_draught_to_human"
	
	-- We also need to stop this bot from giving a healing draught to another bot if this bot itself
	-- needs healing and healing is set to manual, otherwise they will keep passing the draught back
	-- and forth to each other.
	if not override_ally_need and ally_unit and ("can_accept_heal_item" == in_need_type) and manual_heal_only and
			Managers.player:unit_owner(ally_unit).bot_player then
		--
		local our_status_extension	= ScriptUnit.has_extension(unit, "status_system")
		local our_health_extension	= ScriptUnit.has_extension(unit, "health_system")
		local our_buff_extension	= ScriptUnit.has_extension(unit, "buff_system")
		local ally_status_extension	= ScriptUnit.has_extension(ally_unit, "status_system")
		local ally_health_extension	= ScriptUnit.has_extension(ally_unit, "health_system")
		local ally_buff_extension	= ScriptUnit.has_extension(ally_unit, "buff_system")
		if our_health_extension and ally_health_extension and our_buff_extension and ally_buff_extension and our_status_extension and ally_status_extension then
			local our_healshare			= our_buff_extension:has_buff_type("medpack_spread_area")
			local our_wounded_state		= not our_status_extension:has_wounds_remaining()
			local our_health_percent	= our_health_extension:current_health_percent()
			our_health_percent			= (our_wounded_state and our_health_percent - 1) or our_health_percent
			
			local ally_healshare		= ally_buff_extension:has_buff_type("medpack_spread_area")
			local ally_wounded_state	= not ally_status_extension:has_wounds_remaining()
			local ally_health_percent	= ally_health_extension:current_health_percent()
			ally_health_percent			= (ally_wounded_state and ally_health_percent - 1) or ally_health_percent
			
			override_ally_need			= (our_health_percent <= ally_health_percent)
			if not our_healshare and ally_healshare then override_ally_need = false end
		end
	end
	
	-- To override the choice of ally, we have to reproduce a chunk of the real _select_ally_by_utility
	if override_ally_need then
		local pass_draught_to_human = in_need_type == "pass_draught_to_human"
		
		in_need_type = nil
		ally_unit = nil
		real_dist = math.huge
		local dist = math.huge

		local inventory_extn = blackboard.inventory_extension
		local grenade_slot_data = inventory_extn:get_slot_data("slot_grenade")
		local can_give_grenade_to_other = grenade_slot_data and inventory_extn:get_item_template(grenade_slot_data).can_give_other

		local potion_slot_data = inventory_extn:get_slot_data("slot_potion")
		local can_give_potion_to_other = potion_slot_data and inventory_extn:get_item_template(potion_slot_data).can_give_other

		local human_players = Managers.player:human_players()
		for _, human_player in pairs(human_players) do
			local human_player_unit = human_player.player_unit

			if AiUtils.unit_alive(human_player_unit) then
				local allowed_follow_path, allowed_aid_path = self:_ally_path_allowed(human_player_unit, t)
				if allowed_follow_path then
					local human_need_type = nil
					local human_dist = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[human_player_unit])
					local utility_dist = human_dist
					local buff_ext = ScriptUnit.has_extension(human_player_unit, "buff_system")
					local ally_has_healshare = buff_ext and buff_ext:has_buff_type("medpack_spread_area")
					
					local health_slot_data = inventory_extn:get_slot_data("slot_healthkit")
					local can_give_healing_to_other = false

					if health_slot_data then
						local template = inventory_extn:get_item_template(health_slot_data)
						can_give_healing_to_other = template.can_give_other
					end
					
					if allowed_aid_path then
						local human_inventory_extn = ScriptUnit.extension(human_player_unit, "inventory_system")
						--
						if can_give_healing_to_other and (ally_has_healshare or pass_draught_to_human) and not human_inventory_extn:get_slot_data("slot_healthkit") then
							-- EchoConsole("pass heal")
							human_need_type = "can_accept_heal_item"
							utility_dist = utility_dist - 10
						elseif can_give_grenade_to_other and not human_inventory_extn:get_slot_data("slot_grenade") then
							human_need_type = "can_accept_grenade"
							utility_dist = utility_dist - 10
						elseif can_give_potion_to_other and not human_inventory_extn:get_slot_data("slot_potion") then
							human_need_type = "can_accept_potion"
							utility_dist = utility_dist - 10
						end
					end

					if utility_dist < dist then
						dist = utility_dist
						ally_unit = human_player_unit
						real_dist = human_dist
						in_need_type = human_need_type
					end
				end
			end
		end
	end

	return ally_unit, real_dist, in_need_type
end)

-- Vernon: Let bots dodge while drinking draught
Mods.hook.set(mod_name, "BTBotHealAction.run", function(func, self, unit, blackboard, t, dt)
	local ret = func(self, unit, blackboard, t, dt)

	local self_unit		= unit
	local d				= get_d_data(self_unit)
	local has_draught	= utils:get_unit_data(self_unit, "draught")
	
	if has_draught and d and d.settings.better_melee and d.settings.bot_file_enabled then
		if not d.defense.last_calculate_dodge_time or bot_settings.dodge.recalculate_time < d.current_time - d.defense.last_calculate_dodge_time then
			local calculate_dodge = false
			
			if (#d.defense.threat_trash > 0 or #d.defense.threat_stormvermin > 0 or #d.defense.threat_boss > 0 or d.defense.need_to_dodge_packmaster or d.defense.need_to_dodge_assassin)
				and d.defense.dodge_count_left and d.defense.dodge_count_left >= -1 and not d.defense.is_dodging and d.defense.can_dodge and d.defense.on_ground then
				--
				calculate_dodge = true
			end

			if calculate_dodge and not d.token.dodge and not d.defense.is_dodging and d.defense.can_dodge then
				d.defense.last_calculate_dodge_time = d.current_time
				
				local move_x, move_y = refine_dodge_movement(d)
				
				if can_dodge_in_this_direction_safely(d, move_x, move_y) then
					d.token.dodge = true
				end
			end	
		end
		
		if d.defense.last_calculate_dodge_time and 5 < d.current_time - d.defense.last_calculate_dodge_time then
			d.defense.last_calculate_dodge_time = nil
		end
	end
	
	return ret
end)

local MAX_PICKUP_RANGE_SQ = 10 * 10		--14 * 14	--4 * 4

--[[
	Stops bots from exchanging tomes for medical supplies, unless they are wounded enough to use them on the spot, or the item is pinged. By Grimalackt.
--]]
Mods.hook.set(mod_name, "AIBotGroupSystem._update_health_pickups", function(func, self, dt, t)
	func(self, dt, t)
	
	-- Xq: improve the bot automatic heal pickup priority >> the bots should be picking up heals best suited for them
	-- instead of "who manages to pick it up fist"
	local keep_tomes = bot_settings.menu_settings.keep_tomes
	if get(me.SETTINGS.FILE_ENABLED) then
		-- gather bot follow_positions
		local follow_positions = {}
		for unit, data in pairs(self._bot_ai_data) do
			local follow_unit = data.follow_unit
			local follow_pos = (follow_unit and POSITION_LOOKUP[follow_unit]) or false
			if follow_pos then table.insert(follow_positions,follow_pos) end
		end
		
		-- filter health pickups based on their distance to bot follow positions
		local available_pickups = self._available_health_pickups
		local health_pickups_close_enough = {}
		for unit,info in pairs(available_pickups) do
			if Unit.alive(unit) and info.template.can_heal_self then
				local unit_pos = POSITION_LOOKUP[unit]
				if unit_pos then
					for _,follow_pos in pairs(follow_positions) do
						if Vector3.distance_squared(unit_pos, follow_pos) < MAX_PICKUP_RANGE_SQ then
							local index = #health_pickups_close_enough+1
							health_pickups_close_enough[index] = {}
							health_pickups_close_enough[index].unit = unit
							health_pickups_close_enough[index].info = info
							health_pickups_close_enough[index].pos = unit_pos
							health_pickups_close_enough[index].assigned = false
							break
						end
					end
				end
			end
		end
		
		-- re-assign the pickups
		for unit, data in pairs(self._bot_ai_data) do
			local status_extension = ScriptUnit.has_extension(unit, "status_system")
			local self_pos = POSITION_LOOKUP[unit]
			local blackboard = Unit.get_data(unit, "blackboard")
			blackboard.allowed_to_take_health_pickup = false
			blackboard.force_use_health_pickup = false
			blackboard.health_pickup = nil
			blackboard.health_dist = nil
			blackboard.health_pickup_valid_until = nil
			
			if status_extension and not status_extension:is_disabled() then
				for _,health_pickup_info in pairs(health_pickups_close_enough) do
					if not health_pickup_info.assigned then
						local may_pick = may_pick_healslot_item(unit, health_pickup_info.unit, false, not keep_tomes, false)
						local human_needs, human_within_reach = check_players_near_pickup(health_pickup_info.unit)
						if may_pick and not human_needs then
							blackboard.allowed_to_take_health_pickup = true
							blackboard.health_pickup = health_pickup_info.unit
							blackboard.health_dist = Vector3.length(self_pos - health_pickup_info.pos)
							blackboard.health_pickup_valid_until = math.huge
							health_pickup_info.assigned = true
							break
						end
					end
				end
			end
		end
	end
	-- /Xq
	
	if get(me.SETTINGS.FILE_ENABLED) then
		-- Check whether any bots are trying to travel too far in order to pick up
		-- a healing item. If they are, tell them not to.
		for unit, data in pairs(self._bot_ai_data) do
			local blackboard = Unit.get_data(unit, "blackboard")
			if blackboard.allowed_to_take_health_pickup then
				local pickup_pos = POSITION_LOOKUP[blackboard.health_pickup]
				local follow_unit = data.follow_unit
				local out_of_range = follow_unit and (Vector3.distance_squared(POSITION_LOOKUP[follow_unit], pickup_pos) > MAX_PICKUP_RANGE_SQ)
				if out_of_range then
					blackboard.allowed_to_take_health_pickup = false
				end
			end
		end
	end
	
	if get(me.SETTINGS.KEEP_TOMES) then
		local need_next_bot = nil
		local need_next_bot_pickup = nil
		local valid_bots = 0
		for unit, _ in pairs(self._bot_ai_data) do
			local blackboard = Unit.get_data(unit, "blackboard")
			local health_extension = ScriptUnit.has_extension(unit, "health_system")
			local inventory_ext = ScriptUnit.has_extension(unit, "inventory_system")
			local health_slot_data = inventory_ext and inventory_ext.get_slot_data(inventory_ext, "slot_healthkit")
			local status_extension = ScriptUnit.has_extension(unit, "status_system")
			local current_health = 1
			local healthy = true

			-- Check if bot already has a tome
			if health_extension and status_extension and health_slot_data ~= nil then
				local item = inventory_ext.get_item_template(inventory_ext, health_slot_data)
				if item.name == "wpn_side_objective_tome_01" and blackboard.allowed_to_take_health_pickup and not (blackboard.health_pickup == pinged_heal) then
					if not status_extension.is_knocked_down(status_extension) then
						current_health = health_extension.current_health_percent(health_extension)
					end
					local pickup_extension = ScriptUnit.has_extension(blackboard.health_pickup, "pickup_system")
					local pickup_settings = pickup_extension and pickup_extension:get_pickup_settings()
					if (current_health <= 0.5 or status_extension.wounded) and (pickup_settings.item_name == "potion_healing_draught_01") then
						healthy = false
					elseif (current_health <= 0.2 or status_extension.wounded) and (pickup_settings.item_name == "healthkit_first_aid_kit_01") then
						healthy = false
					end
					if healthy then
						blackboard.allowed_to_take_health_pickup = false
						need_next_bot = unit
						need_next_bot_pickup = blackboard.health_pickup
						valid_bots = valid_bots + 1
					end
				end
			end
		end
		if need_next_bot and valid_bots < 3 then
			for unit, _ in pairs(self._bot_ai_data) do
				if unit ~= need_next_bot then
					local blackboard = Unit.get_data(unit, "blackboard")
					local health_extension = ScriptUnit.has_extension(unit, "health_system")
					local inventory_ext = ScriptUnit.has_extension(unit, "inventory_system")
					local health_slot_data = inventory_ext and inventory_ext.get_slot_data(inventory_ext, "slot_healthkit")
					local status_extension = ScriptUnit.has_extension(unit, "status_system")
					local current_health = 1
					local healthy = true
					
					if health_extension and inventory_ext and status_extension then
						-- Check if bot already has a tome
						if health_slot_data == nil and Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[need_next_bot_pickup]) < 15 then
							blackboard.allowed_to_take_health_pickup = true
							blackboard.health_pickup = need_next_bot_pickup
							blackboard.health_dist = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[need_next_bot_pickup])
							blackboard.health_pickup_valid_until = math.huge
							return
						end
						if health_slot_data ~= nil then
							local item = inventory_ext.get_item_template(inventory_ext, health_slot_data)
							if item.name == "wpn_side_objective_tome_01" and Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[need_next_bot_pickup]) < 15 then
								if not status_extension.is_knocked_down(status_extension) then
									current_health = health_extension.current_health_percent(health_extension)
								end

								local pickup_extension = ScriptUnit.has_extension(need_next_bot_pickup, "pickup_system")
								local pickup_settings = pickup_extension and pickup_extension:get_pickup_settings()

								if (current_health <= 0.5 or status_extension.wounded) and (pickup_settings.item_name == "potion_healing_draught_01") then
									healthy = false
								elseif (current_health <= 0.2 or status_extension.wounded) and (pickup_settings.item_name == "healthkit_first_aid_kit_01") then
									healthy = false
								end
								if not healthy then
									blackboard.allowed_to_take_health_pickup = true
									blackboard.health_pickup = need_next_bot_pickup
									blackboard.health_dist = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[need_next_bot_pickup])
									blackboard.health_pickup_valid_until = math.huge
									return
								end
							end
						end
					end
				end
			end
		end
	end
end)

--[[
	Checks whether any bots are trying to travel too far in order to pick up
	a potion or grenade. If they are, tell them not to.
--]]
Mods.hook.set(mod_name, "AIBotGroupSystem._update_mule_pickups", function (orig_func, self, ...)
	orig_func(self, ...)
	if get(me.SETTINGS.FILE_ENABLED) then
		for unit, data in pairs(self._bot_ai_data) do
			local blackboard = Unit.get_data(unit, "blackboard")
			if blackboard.mule_pickup then
				local pickup_pos = POSITION_LOOKUP[blackboard.mule_pickup]
				local follow_unit = data.follow_unit
				local out_of_range = follow_unit and (Vector3.distance_squared(POSITION_LOOKUP[follow_unit], pickup_pos) > MAX_PICKUP_RANGE_SQ)
				if out_of_range then
					blackboard.mule_pickup = nil
				end
			end
		end
	end
end)

-- Xq: Reduce travel distance also to ammo pickups
Mods.hook.set(mod_name, "AIBotGroupSystem._update_pickups_near_player", function (func, self, unit, t)
	-- run the original function first
	func(self, unit, t)
	
	if get(me.SETTINGS.FILE_ENABLED) then
		-- then act as if the pickup has already been used in case its too far
		local MAX_PICKUP_RANGE = math.sqrt(MAX_PICKUP_RANGE_SQ)
		local bot_ai_data = self._bot_ai_data
		for _, data in pairs(bot_ai_data) do
			local blackboard = data.blackboard
			local ammo_dist = data.ammo_dist
			if ammo_dist and ammo_dist > MAX_PICKUP_RANGE then
				blackboard.ammo_pickup = nil
				data.ammo_dist = nil
			end
		end
	end
end)

-- ####################################################################################################################
-- ##### follow host ##################################################################################################
-- ####################################################################################################################
--
-- Check if player is active
--
me.player_is_enabled = function(player)
	if player and player.player_unit then
		local status_ext = ScriptUnit.has_extension(player.player_unit, "status_system")

		if status_ext then
			return not ScriptUnit.extension(player.player_unit, "status_system"):is_disabled()
		end
	end

	return false
end

--
-- With player data we want to generate new bot position where they need to stand
-- Xq: coded in support for alternative fixed positions in case of mission objective defense, also changed the stand positions when following the host
--
-- Vernon: 20210926 version
me.generate_points = function(ai_bot_group_system, player)
	-- debug_print_variables("***************")
	local points = nil

	local validate_point = function(point)
		local alt_offsets =
		{
			Vector3(0,-1,0),
			Vector3(-0.5,-0.866,0),
			Vector3(-0.866,-0.5,0),
			Vector3(-1,0,0),
			Vector3(-0.866,0.5,0),
			Vector3(-0.5,0.866,0),
			Vector3(0,1,0),
			Vector3(0.5,0.866,0),
			Vector3(0.866,0.5,0),
			Vector3(1,0,0),
			Vector3(0.866,-0.5,0),
			Vector3(0.5,-0.866,0),
		}
		local ret = point
		if ret then
			ret = Vector3.copy(point)
			local nav_world	= Managers.state.bot_nav_transition._nav_world
			local above		= 2.5
			local below		= 2.5
			
			local success, z = GwNavQueries.triangle_from_position(nav_world, ret, above, below)
			
			if success then
				ret.z = z
			else
				local z_diff = math.huge
				local result = false
				for _,offset in pairs(alt_offsets) do
					local try = Vector3.copy(ret) + offset * 1.5
					local success, z = GwNavQueries.triangle_from_position(nav_world, try, above, below)
					if success then
						local diff = math.abs(z-ret.z)
						if diff < z_diff then
							z_diff = diff
							result = Vector3.copy(try)
							result.z = z
						end
					end
				end
				if result then
					-- debug_print_variables(result)
					ret = result
				end
			end
		end
		return ret
	end
	
	-- Collect data
	local player_unit = player.player_unit
	local player_pos = POSITION_LOOKUP[player_unit]
	local player_pos_nav = (player_pos and validate_point(player_pos)) or false
	-- debug_print_variables(player_pos, player_pos_nav)
	player_pos = player_pos_nav or Vector3(0, 0, -1000)
	local num_bots = ai_bot_group_system._num_bots
	local nav_world = Managers.state.bot_nav_transition._nav_world -- Managers.state.entity:system("ai_system"):nav_world()
	local traverse_logic = Managers.state.bot_nav_transition._traverse_logic
	
	--  no mission specific standing ponts needed >> assign points as per normal routine
	local disallowed_at_pos, current_mapping = ai_bot_group_system:_selected_unit_is_in_disallowed_nav_tag_volume(nav_world, player_pos)
	if disallowed_at_pos then
		local origin_point = ai_bot_group_system:_find_origin(nav_world, player_unit)

		points = ai_bot_group_system:_find_destination_points_outside_volume(nav_world, player_pos, current_mapping, origin_point, num_bots)
	else

		points = {}
		local player_rotation			= Unit.local_rotation(player_unit, 0)
		local player_forward			= Quaternion.forward(player_rotation)
		local first_person_extension	= ScriptUnit.has_extension(player_unit, "first_person_system")
		local camera_rotation			= first_person_extension and first_person_extension:current_rotation()
		local camera_forward			= (camera_rotation and Quaternion.forward(camera_rotation)) or player_forward
		local forward_angle_offset		= Vector3.flat_angle(Vector3(1,0,0), Vector3.normalize(Vector3.flat(camera_forward))) + math.pi
		local stand_distance			= 2
		local angle_offset_rad			= (-30 * math.pi/180) - forward_angle_offset
		local base_angle_offset_rad		= 120 * math.pi/180
		local stand_v1 = Vector3(math.sin(base_angle_offset_rad * 0 + angle_offset_rad),	math.cos(base_angle_offset_rad * 0 + angle_offset_rad),	0)
		local stand_v2 = Vector3(math.sin(base_angle_offset_rad * 1 + angle_offset_rad),	math.cos(base_angle_offset_rad * 1 + angle_offset_rad),	0)
		local stand_v3 = Vector3(math.sin(base_angle_offset_rad * 2 + angle_offset_rad),	math.cos(base_angle_offset_rad * 2 + angle_offset_rad),	0)
		table.insert(points,player_pos + stand_v1 * stand_distance)
		table.insert(points,player_pos + stand_v2 * stand_distance)
		table.insert(points,player_pos + stand_v3 * stand_distance)
		
		local points_nav =
		{
			validate_point(points[1]),
			validate_point(points[2]),
			validate_point(points[3]),
		}
		
		points[1] = points_nav[1] or points_nav[2] or points_nav[3] or player_pos
		points[2] = points_nav[2] or points_nav[3] or points_nav[1] or player_pos
		points[3] = points_nav[3] or points_nav[1] or points_nav[2] or player_pos
		-- debug_print_variables(points_nav[1], points_nav[2], points_nav[3], player_pos)
		-- local check_points =
		-- {
			-- player_pos =
			-- {
				-- Vector3(player_pos.x, player_pos.y, player_pos.z + 0.5),
				-- Vector3(player_pos.x, player_pos.y, player_pos.z + 1.25),
				-- Vector3(player_pos.x, player_pos.y, player_pos.z + 2.5),
			-- },
			-- points = 
			-- {
				-- Vector3(points[1].x, points[1].y, points[1].z + 1.5),
				-- Vector3(points[2].x, points[2].y, points[2].z + 1.5),
				-- Vector3(points[3].x, points[3].y, points[3].z + 1.5),
			-- },
		-- }
		
		
		local check1 =	-- check_line_of_sight(false, false, check_points.player_pos[1],	check_points.points[1]) and 
						-- check_line_of_sight(false, false, check_points.player_pos[2],	check_points.points[1]) and
						-- check_line_of_sight(false, false, check_points.player_pos[3],	check_points.points[1]) and
						GwNavQueries.raycango(nav_world, points[1], player_pos, traverse_logic)
						
		local check2 =	-- check_line_of_sight(false, false, check_points.player_pos[1],	check_points.points[2]) and 
						-- check_line_of_sight(false, false, check_points.player_pos[2],	check_points.points[2]) and
						-- check_line_of_sight(false, false, check_points.player_pos[3],	check_points.points[2]) and
						GwNavQueries.raycango(nav_world, points[2], player_pos, traverse_logic)
						
		local check3 =	-- check_line_of_sight(false, false, check_points.player_pos[1],	check_points.points[3]) and 
						-- check_line_of_sight(false, false, check_points.player_pos[2],	check_points.points[3]) and
						-- check_line_of_sight(false, false, check_points.player_pos[3],	check_points.points[3]) and
						GwNavQueries.raycango(nav_world, points[3], player_pos, traverse_logic)
						
		-- debug_print_variables(check1, check2, check3)
		-- if not (check1 or check2 or check3) then
			-- points[1] = player_pos
			-- points[2] = player_pos
			-- points[3] = player_pos
		-- else
			points[1] = (check1 and points[1]) or (check2 and points[2]) or (check3 and points[3]) or player_pos
			points[2] = (check2 and points[2]) or (check3 and points[3]) or (check1 and points[1]) or player_pos
			points[3] = (check3 and points[3]) or (check1 and points[1]) or (check2 and points[2]) or player_pos
			
		-- end
		
		-- for _,point in pairs(points) do
			-- local max_height_offset = 2.5
			-- local success, altitude = GwNavQueries.triangle_from_position(nav_world, point, max_height_offset, max_height_offset)
			-- if success then
				-- point.z = altitude
			-- end
		-- end
		
	end

	return points
end

-- Vernon: 20220116 version
--[[
me.generate_points = function(ai_bot_group_system, player)
	local points = nil

	-- Collect data
	local player_unit = player.player_unit
	local player_pos = POSITION_LOOKUP[player_unit]
	local num_bots = ai_bot_group_system._num_bots
	local nav_world = Managers.state.entity:system("ai_system"):nav_world()
	
	--  no mission specific standing ponts needed >> assign points as per normal routine
	local disallowed_at_pos, current_mapping = ai_bot_group_system:_selected_unit_is_in_disallowed_nav_tag_volume(nav_world, player_pos)
	if disallowed_at_pos then
		local origin_point = ai_bot_group_system:_find_origin(nav_world, player_unit)

		points = ai_bot_group_system:_find_destination_points_outside_volume(nav_world, player_pos, current_mapping, origin_point, num_bots)
	else

		points = {}
		local player_rotation			= Unit.local_rotation(player_unit, 0)
		local player_forward			= Quaternion.forward(player_rotation)
		local first_person_extension	= ScriptUnit.has_extension(player_unit, "first_person_system")
		local camera_rotation			= first_person_extension and first_person_extension:current_rotation()
		local camera_forward			= (camera_rotation and Quaternion.forward(camera_rotation)) or player_forward
		local forward_angle_offset		= Vector3.flat_angle(Vector3(1,0,0), Vector3.normalize(Vector3.flat(camera_forward))) + math.pi
		local stand_distance			= 2
		local angle_offset_rad			= (-30 * math.pi/180) - forward_angle_offset
		local base_angle_offset_rad		= 120 * math.pi/180
		local stand_v1 = Vector3(math.sin(base_angle_offset_rad * 0 + angle_offset_rad),	math.cos(base_angle_offset_rad * 0 + angle_offset_rad),	0)
		local stand_v2 = Vector3(math.sin(base_angle_offset_rad * 1 + angle_offset_rad),	math.cos(base_angle_offset_rad * 1 + angle_offset_rad),	0)
		local stand_v3 = Vector3(math.sin(base_angle_offset_rad * 2 + angle_offset_rad),	math.cos(base_angle_offset_rad * 2 + angle_offset_rad),	0)
		table.insert(points,player_pos + stand_v1 * stand_distance)
		table.insert(points,player_pos + stand_v2 * stand_distance)
		table.insert(points,player_pos + stand_v3 * stand_distance)
		
		local check_points =
		{
			player_pos =
			{
				Vector3(player_pos.x, player_pos.y, player_pos.z + 0.5),
				Vector3(player_pos.x, player_pos.y, player_pos.z + 1.25),
				Vector3(player_pos.x, player_pos.y, player_pos.z + 2.5),
			},
			points = 
			{
				Vector3(points[1].x, points[1].y, points[1].z + 1.5),
				Vector3(points[2].x, points[2].y, points[2].z + 1.5),
				Vector3(points[3].x, points[3].y, points[3].z + 1.5),
			},
		}
		
		local check1 =	check_line_of_sight(false, false, check_points.player_pos[1],	check_points.points[1]) and 
						check_line_of_sight(false, false, check_points.player_pos[2],	check_points.points[1]) and
						check_line_of_sight(false, false, check_points.player_pos[3],	check_points.points[1])
						
		local check2 =	check_line_of_sight(false, false, check_points.player_pos[1],	check_points.points[2]) and 
						check_line_of_sight(false, false, check_points.player_pos[2],	check_points.points[2]) and
						check_line_of_sight(false, false, check_points.player_pos[3],	check_points.points[2])
						
		local check3 =	check_line_of_sight(false, false, check_points.player_pos[1],	check_points.points[3]) and 
						check_line_of_sight(false, false, check_points.player_pos[2],	check_points.points[3]) and
						check_line_of_sight(false, false, check_points.player_pos[3],	check_points.points[3])
						
		if not (check1 or check2 or check3) then
			points[1] = player_pos
			points[2] = player_pos
			points[3] = player_pos
		else
			points[1] = (check1 and points[1]) or (check2 and points[2]) or (check3 and points[3])
			points[2] = (check2 and points[2]) or (check3 and points[3]) or (check1 and points[1])
			points[3] = (check3 and points[3]) or (check1 and points[1]) or (check2 and points[2])
			
		end
		
		for _,point in pairs(points) do
			local max_height_offset = 2.5
			local success, altitude = GwNavQueries.triangle_from_position(nav_world, point, max_height_offset, max_height_offset)
			if success then
				point.z = altitude
			end
		end
		
	end

	return points
end
--]]

-- Vernon: Stop repositioning when another human is too close to the followed target
local old_follow_position = {}
Mods.hook.set(mod_name, "AIBotGroupSystem._assign_destination_points",
function (func, self, bot_ai_data, points, follow_unit, follow_unit_table)
	func(self, bot_ai_data, points, follow_unit, follow_unit_table)
	
	local any_bot = false
	for _,bot in pairs(Managers.player:bots()) do
		if bot and bot.player_unit then
			any_bot = bot
		end
		break
	end
	local d = any_bot and get_d_data(any_bot.player_unit)
	
	if not d or not bot_settings.menu_settings.bot_file_enabled then
		return
	end
	
	local follow_host = bot_settings.menu_settings.always_follow_host
	
	local follow_owner = false
	
	if follow_host then
		follow_owner = Managers.player:local_player()
	else
		follow_owner = Managers.player:unit_owner(follow_unit)
	end
	
	if not follow_owner then return end
	
	local player					= follow_owner
	local player_unit				= player.player_unit
	local player_position			= POSITION_LOOKUP[player_unit]
	local player_status_extension	= ScriptUnit.has_extension(player.player_unit, "status_system")
	--edit start--
	-- local may_follow_player			= player_status_extension and not (player_status_extension:is_dead() or player_status_extension:is_ready_for_assisted_respawn())
	local may_follow_player			= player_status_extension and not player_status_extension:is_disabled() -- if the player is disabled, let the default routine assing the points 
	--edit end--
	
	if (follow_unit and may_follow_player) or (follow_unit_table and table.has_item(follow_unit_table, player_unit)) then
		local destination_points	= me.generate_points(self, player)
		local inventory_extension	= ScriptUnit.has_extension(player_unit,"inventory_system")
		local slot_name				= inventory_extension and inventory_extension:get_wielded_slot_name()
		local player_moved			= player_position and old_follow_position[player_unit] and Vector3.length(old_follow_position[player_unit]:unbox() - player_position) > 0.001
		
		local too_close_to_human = false
		local human_players = Managers.player:human_players()
		for _, human_player in pairs(human_players) do
			local loop_unit = human_player.player_unit
			local loop_status_extension	= ScriptUnit.has_extension(loop_unit, "status_system")
			local loop_active = loop_status_extension and not (loop_status_extension:is_dead() or loop_status_extension:is_ready_for_assisted_respawn())
			if loop_active then
				local loop_pos = POSITION_LOOKUP[loop_unit]
				local loop_distance_squared = loop_pos and player_position and Vector3.distance_squared(loop_pos, player_position)
				-- Vernon: follow positions are 2m away from followed target
				if loop_distance_squared and 1*1 < loop_distance_squared and loop_distance_squared < 3*3 then
					too_close_to_human = true
				end
			end
		end
		
		local repositioning_denied	= not player_moved and (not slot_name or slot_name == "slot_healthkit" or slot_name == "slot_potion" or slot_name == "slot_grenade")
		repositioning_denied = repositioning_denied or (too_close_to_human and not d.objective_defence.enabled)
		
		if destination_points then
			local i = 1
			local used_points = {}
			-- Update bots with new positions
			for unit, data in pairs(bot_ai_data) do
				local loop_pos		= POSITION_LOOKUP[unit]
				if loop_pos then
					local best_distance	= math.huge
					local best_point	= false
					for _,point in pairs(destination_points) do
						if not used_points[point] then
							local distance = Vector3.length(loop_pos - point)
							if distance < best_distance then
								if best_point then used_points[best_point] = nil end
								used_points[point] = true
								best_point		= point
								best_distance	= distance
							end
						end
					end
					
					
					data.follow_unit = player_unit
					
					-- Vernon: use index instead of always first position
					-- best_point = best_point or destination_points[1]
					best_point = best_point or destination_points[i]
					local old_position = (old_follow_position[unit] and old_follow_position[unit]:unbox()) or false
					if old_position then
						local reposition_distance_required = (too_close_to_human and 1.5) or 1
						if not repositioning_denied and Vector3.length(old_position - best_point) > reposition_distance_required then
							data.follow_position = best_point
							old_follow_position[unit] = Vector3Box(best_point)
						else
							data.follow_position = old_position
						end
					else
						data.follow_position = best_point
						old_follow_position[unit] = Vector3Box(best_point)
					end
				end
				i = i + 1
			end
		end
		
		if player_position then
			old_follow_position[player_unit] = Vector3Box(player_position)
		end
	end
	
	-- clear garbage data out from the old follow position table
	for key,data in pairs(old_follow_position) do
		if not Unit.alive(key) then
			old_follow_position[key] = nil
		end
	end
	
	--edit start--
	-- if d.objective_defence.enabled then
	if d.objective_defence.enabled and may_follow_player then
	--edit end--
		local player_unit = follow_unit
		if follow_host then
			player_unit = Managers.player:local_player().player_unit
		end
		
		local player_pos = (player_unit and POSITION_LOOKUP[player_unit]) or false
		
		if player_pos  then
			local _,stand_position = get_mission_defend_position(player_pos)
			if stand_position then
				-- mission specific stand points needed >> assign points accordingly
				local i = 1
				-- Update bots with new positions
				for unit, data in pairs(bot_ai_data) do
					data.follow_position = stand_position[i]
					i = i + 1
				end
			end
		end
	end
	
	return
end)

-- ####################################################################################################################
-- ##### don't use wizard bot when wizard player laeves ###############################################################
-- ####################################################################################################################
local NUM_PLAYERS = 4
local CONSUMABLE_SLOTS = {
	"slot_healthkit",
	"slot_potion",
	"slot_grenade"
}

-- Xq: added support for "least preferred bot" to work also when a player leaves
Mods.hook.set(mod_name, "SpawnManager._update_bot_spawns", function (func, self, dt, t)
	if not get(me.SETTINGS.OVERRIDE_LEFT_PLAYER) then
		return func(self, dt, t)
	end

	local player_manager = Managers.player
	local profile_synchronizer = self._profile_synchronizer
	local available_profile_order = self._available_profile_order
	local available_profiles = self._available_profiles
	local profile_release_list = self._bot_profile_release_list
	local delta, humans, bots = self._update_available_profiles(self, profile_synchronizer, available_profile_order, available_profiles)

	for local_player_id, bot_player in pairs(self._bot_players) do
		local profile_index = bot_player.profile_index

		if not available_profiles[profile_index] then
			local peer_id = bot_player.network_id(bot_player)
			local local_player_id = bot_player.local_player_id(bot_player)
			profile_release_list[profile_index] = true
			local bot_unit = bot_player.player_unit

			if bot_unit then
				bot_player.despawn(bot_player)
			end

			local status_slot_index = bot_player.status_slot_index

			self._free_status_slot(self, status_slot_index)
			player_manager.remove_player(player_manager, peer_id, local_player_id)

			self._bot_players[local_player_id] = nil
		end
	end

	local allowed_bots = math.min(NUM_PLAYERS - humans, (not script_data.ai_bots_disabled or 0) and (script_data.cap_num_bots or NUM_PLAYERS))
	local bot_delta = allowed_bots - bots
	local local_peer_id = Network.peer_id()

	if 0 < bot_delta then
		local i = 1
		local bots_spawned = 0
		
		local bot_to_avoid = get(me.SETTINGS.BOT_TO_AVOID) or 1
		local profile_indexes = {}
		for i=1,5 do
			if i ~= bot_to_avoid then
				table.insert(profile_indexes, i)
			end
		end
		table.insert(profile_indexes, bot_to_avoid)
		
		available_profile_order = {}
		for _,profile_index in ipairs(profile_indexes) do
			if available_profiles[profile_index] then
				table.insert(available_profile_order, profile_index)
			end
		end

		while bots_spawned < bot_delta do
			local profile_index = available_profile_order[i]

			fassert(profile_index, "Tried to add more bots than there are profiles available")

			local owner_type = profile_synchronizer.owner_type(profile_synchronizer, profile_index)

			if owner_type == "available" then
				local local_player_id = player_manager.next_available_local_player_id(player_manager, local_peer_id)
				local bot_player = player_manager.add_bot_player(player_manager, SPProfiles[profile_index].display_name, local_peer_id, "default", profile_index, local_player_id)
				local is_initial_spawn, status_slot_index = self._assign_status_slot(self, local_peer_id, local_player_id, profile_index)
				bot_player.status_slot_index = status_slot_index

				profile_synchronizer.set_profile_peer_id(profile_synchronizer, profile_index, local_peer_id, local_player_id)
				bot_player.create_game_object(bot_player)

				self._bot_players[local_player_id] = bot_player
				self._spawn_list[#self._spawn_list + 1] = bot_player
				bots_spawned = bots_spawned + 1
				self._forced_bot_profile_index = nil
			end

			i = i + 1
		end
	elseif bot_delta < 0 then
		local bots_despawned = 0
		local i = 1

		while bots_despawned < -bot_delta do
			local profile_index = available_profile_order[i]

			fassert(profile_index, "Tried to remove more bots than there are profiles belonging to bots")

			local owner_type = profile_synchronizer.owner_type(profile_synchronizer, profile_index)

			if owner_type == "bot" then
				local bot_player, bot_local_player_id = nil

				for local_player_id, player in pairs(self._bot_players) do
					if player.profile_index == profile_index then
						bot_player = player
						bot_local_player_id = local_player_id

						break
					end
				end

				fassert(bot_player, "Did not find bot player with profile_index profile_index %i", profile_index)

				profile_release_list[profile_index] = true
				local bot_unit = bot_player.player_unit

				if bot_unit then
					bot_player.despawn(bot_player)
				end

				local status_slot_index = bot_player.status_slot_index

				self._free_status_slot(self, status_slot_index)
				player_manager.remove_player(player_manager, local_peer_id, bot_local_player_id)

				self._bot_players[bot_local_player_id] = nil
				bots_despawned = bots_despawned + 1
			end

			i = i + 1
		end
	end

	local statuses = self._player_statuses

	if self._network_server:has_all_peers_loaded_packages() then
		for _, bot_player in ipairs(self._spawn_list) do
			local bot_local_player_id = bot_player.local_player_id(bot_player)
			local bot_peer_id = bot_player.network_id(bot_player)

			if player_manager.player(player_manager, bot_peer_id, bot_local_player_id) == bot_player then
				local status_slot_index = bot_player.status_slot_index
				local status = statuses[status_slot_index]
				local position = status.position:unbox()
				local rotation = status.rotation:unbox()
				local is_initial_spawn = false

				if status.health_state ~= "dead" and status.health_state ~= "respawn" and status.health_state ~= "respawning" then
					local consumables = status.consumables
					local ammo = status.ammo

					bot_player.spawn(bot_player, position, rotation, is_initial_spawn, ammo.slot_melee, ammo.slot_ranged, consumables[CONSUMABLE_SLOTS[1]], consumables[CONSUMABLE_SLOTS[2]], consumables[CONSUMABLE_SLOTS[3]])
				end

				status.spawn_state = "spawned"
			end
		end

		table.clear(self._spawn_list)
	end

	return
end)
Mods.hook.front(mod_name, "SpawnManager._update_bot_spawns")

-- ####################################################################################################################
-- ##### autoequip bots from a dedicated loadout slot #################################################################
-- ####################################################################################################################
local LOADOUT_SETTING = "cb_saved_loadouts"
Mods.hook.set(mod_name, "BackendUtils.get_loadout_item", function (func, profile, slot)
	if not get(me.SETTINGS.AUTOEQUIP) then
		return func(profile, slot)
	end

	if profile == "all" then
		return
	end

	local profile_index = 0
	for _,profile_data in ipairs(SPProfiles) do
		profile_index = profile_index + 1
		if profile_data.display_name == profile then
			break
		end
	end

	local item_data = nil

	if SPProfiles[profile_index] and Managers.state.network then
		if Managers.state.network.profile_synchronizer:owner_type(profile_index) == "bot" then
			local loadout = Application.user_setting(LOADOUT_SETTING, profile, get(me.SETTINGS.AUTOEQUIP_SLOT))
			local backend_id = loadout and loadout[slot] or nil
			if backend_id and ScriptBackendItem.get_key(backend_id) then
				item_data = BackendUtils.get_item_from_masterlist(backend_id) or nil
			end
			if item_data then
				return item_data
			end
		end
	end

	local backend_id = ScriptBackendItem.get_loadout_item_id(profile, slot)
	item_data = (backend_id and BackendUtils.get_item_from_masterlist(backend_id)) or nil

	return item_data
end)
Mods.hook.front(mod_name, "BackendUtils.get_loadout_item")

-- ####################################################################################################################
-- ##### Block on Path Search by Aussiemon ############################################################################
-- ####################################################################################################################

-- ##########################################################
-- ################## Functions #############################

me.manual_block = function(unit, blackboard, should_block, t)
	if unit and Unit.alive(unit) and blackboard and blackboard.input_extension then
		local input_extension = blackboard.input_extension
		
		if should_block then
			input_extension:wield("slot_melee")
			input_extension._defend = true
			blackboard._block_start_time_BIE = t
			
		elseif t > (blackboard._block_start_time_BIE + 1) then
			input_extension._defend = false
			blackboard._block_start_time_BIE = nil
		end
	end
end


-- ##########################################################
-- #################### Hooks ###############################

-- ## Bots Block on Path Search - Teleport to Ally Action ##
-- Start blocking as the teleport action begins
-- Xq: initialize teleport loop stuck detection data
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.enter", function (func, self, unit, blackboard, t)
	
	if not get(me.SETTINGS.FILE_ENABLED) then 
		return func(self, unit, blackboard, t)
	end 
	
	me.manual_block(unit, blackboard, true, t)
	
	-- initialize loop counter and record start time for teleport loop stuck detection (="watchdog" timer / counter)
	if not blackboard.teleport_stuck_loop_start_time then
		blackboard.teleport_stuck_loop_counter = 0
		blackboard.teleport_stuck_loop_start_time = t
	end
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	return result
end)

local is_teleport_denied_to_position = function(self_unit, pos)
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d then
		return true
	end

	local level_id = LevelHelper:current_level_settings().level_id
	
	if #d.defense.threat_boss > 0 then
		-- the bots shouldn't try to teleport when a boss is posing an immediate threat to them
		return true
	end
	
	-- add level spesific teleport denial zones to prevent bots from teleporting inside walls / past closed mission gates / such
	
	if level_id == "dlc_dwarf_interior" then
		if	pos.x > -120 and pos.x < -108 and
			pos.y > -8 and pos.y < 4 and
			pos.z > 7 and pos.z < 11 then
			-- Khazid Kro, behind the boiler room gates
			return true
		end
		
	elseif level_id == "dlc_castle" then
		if	pos.x > 49 and pos.x < 54 and
			pos.y > 146 and pos.y < 170 and
			pos.z > 0 and pos.z < 4 then
			-- Castle Drachenfels, behind a wall near grim #2
			return true
		end
		
	end
	
	return false
end

-- Continue blocking as the teleport action runs
-- Xq: prevent fall damage on successful teleport (when bot teleports mid jump from elevated position to much lower position)
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.run", function (func, self, unit, blackboard, t)
	
	local self_unit		= unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.bot_file_enabled then 
		return func(self, unit, blackboard, t)
	end
	me.manual_block(unit, blackboard, true, t)
	
	
	-- Xq: make sure the bot teleports to its follow target if their current target is not disabled
	-- (disabled = dead or pounced or knocked down or packmastered or hanging on ledge or hanging on hook or needs rescue)
	local current_time = d.current_time
	local follow_unit = blackboard.ai_bot_group_extension.data.follow_unit
	local target_unit = blackboard.target_ally_unit
	local target_status_extension = ScriptUnit.has_extension(target_unit, "status_system")
	if target_unit and follow_unit and target_status_extension and not target_status_extension:is_disabled() then
		blackboard.target_ally_unit = follow_unit
	end
	
	-- the rest is mostly taken directly from the original sources
	
	local MAX_ALLOWED_TELEPORT_DISTANCE = 10
	local target_ally_unit = blackboard.target_ally_unit
	local tp_bb = blackboard.teleport
	local a_star = tp_bb.a_star
	local state = tp_bb.state
	

	if Unit.alive(target_ally_unit) and state == "init" then
		local target_pos = POSITION_LOOKUP[target_ally_unit]
		local pos = LocomotionUtils.new_random_goal_uniformly_distributed(blackboard.nav_world, nil, target_pos, 2, 5, 5)

		if pos then
			tp_bb.run_start_time = current_time
			tp_bb.position:store(pos)

			tp_bb.state = "a_star_search"

			GwNavAStar.start(a_star, blackboard.nav_world, target_pos, pos, Managers.state.bot_nav_transition:traverse_logic())
		end
	elseif state == "a_star_search" and GwNavAStar.processing_finished(a_star) then
		if GwNavAStar.path_found(a_star) and GwNavAStar.path_distance(a_star) < MAX_ALLOWED_TELEPORT_DISTANCE and 0 < GwNavAStar.node_count(a_star) then
			local node_count = GwNavAStar.node_count(a_star)
			local destination = GwNavAStar.node_at_index(a_star, node_count)
			local locomotion_extension = ScriptUnit.extension(unit, "locomotion_system")
			local tp_run_duration = current_time - tp_bb.run_start_time
			
			if is_teleport_denied_to_position(unit, destination) or tp_run_duration > 3 then
				if tp_run_duration >= 3 then
					EchoConsole("re-initializing teleport routine, time passed: " .. tostring(tp_run_duration))
				end
				tp_bb.state = "init"
			else
				locomotion_extension.teleport_to(locomotion_extension, destination)

				tp_bb.state = "done"
				blackboard.has_teleported = true

				blackboard.navigation_extension:teleport(destination)
				blackboard.ai_system_extension:clear_failed_paths()

				blackboard.follow.needs_target_position_refresh = true

				blackboard.teleport_stuck_loop_counter = nil
				blackboard.teleport_stuck_loop_start_time = nil
				
				-- Xq: reset falling height after teleport so bots don't take damage when teleporting mid-jump from elevated postion to lower position
				local status_extension = ScriptUnit.has_extension(unit, "status_system")
				if status_extension and status_extension.fall_height then
					status_extension.fall_height = destination.z
				end
				
				return "done"
			end
		else
			tp_bb.state = "init"
		end
	end

	return "running"
end)

-- Cancel blocking when the teleport action ends
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.leave", function (func, self, unit, blackboard, t)
	
	local self_unit		= unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local d				= get_d_data(self_unit)
	
	if not d or not d.settings.bot_file_enabled then 
		return func(self, unit, blackboard, t)
	end
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	
	me.manual_block(unit, blackboard, false, t)
	
	-- Xq: check if teleport loop is stuck (=has been restarted > 100 times or has been running for more than 5s)
	-- if so force the bot to teleport to the target's current coordinated
	if blackboard.teleport_stuck_loop_start_time then
		if (t - blackboard.teleport_stuck_loop_start_time) > 5 and blackboard.teleport_stuck_loop_counter > 100 then
			local follow_unit = blackboard.ai_bot_group_extension.data.follow_unit
			local destination = POSITION_LOOKUP[follow_unit]
			local status_extension = ScriptUnit.has_extension(unit, "status_system")
			if status_extension and not status_extension:is_disabled() then	-- still don't teleport on top of disabled player
				blackboard.teleport_stuck_loop_counter = nil
				blackboard.teleport_stuck_loop_start_time = nil
				-- teleport
				local locomotion_extension = ScriptUnit.extension(unit, "locomotion_system")
				locomotion_extension.teleport_to(locomotion_extension, destination)
				blackboard.has_teleported = true
				blackboard.navigation_extension:teleport(destination)
				blackboard.ai_system_extension:clear_failed_paths()
				blackboard.follow.needs_target_position_refresh = true
				
				-- reset falling height after teleport so bots don't take damage when teleporting mid-jump from elevated postion to lower position
				if status_extension and status_extension.fall_height then
					status_extension.fall_height = destination.z
				end
				
				EchoConsole("Teleport loop stuck - forced teleport to follow target")
			end
		else
			blackboard.teleport_stuck_loop_counter = blackboard.teleport_stuck_loop_counter+1
		end
	end
	d.unstuck_data.is_stuck = false
	
	return result
end)

Mods.hook.set(mod_name, "BTBotHealOtherAction.enter", function (func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	self._start_time = t
	return
end)

Mods.hook.set(mod_name, "BTBotHealOtherAction.run", function (func, self, unit, blackboard, t, dt)
	local ret = func(self, unit, blackboard, t, dt)
	
	local file_enabled = bot_settings.menu_settings.bot_file_enabled
	if file_enabled and self._start_time and t - self._start_time > 10 then
		local owner = Managers.player:unit_owner(unit)
		local name = (owner and owner:name()) or "unknown"
		EchoConsole(name .. " : BTBotHealOtherAction took over 10s >> terminating action")
		ret = "failed"
	end
	
	return ret
end)

-- ## Bots Block on Path Search - Nil Action ##
-- Start blocking when the nil action ends, and hold the block until the game decides to release it
Mods.hook.set(mod_name, "BTNilAction.leave", function (func, self, unit, blackboard, t)
	
	if get(me.SETTINGS.FILE_ENABLED) then 
		me.manual_block(unit, blackboard, true, t)
	end
	
	-- Original Function
	return func(self, unit, blackboard, t)
end)

-- Xq: bots hold bloock while in elevator
Mods.hook.set(mod_name, "LinkerTransportationExtension._link_transported_unit", function (func, self, unit_to_link, teleport_on_enter)
	
	local unit			= unit_to_link
	local owner			= Managers.player:owner(unit)
	
	if get(me.SETTINGS.FILE_ENABLED) then
		if owner.bot_player then	-- check is needed because the player is also "linked"
			local d = get_d_data(owner.player_unit)
			if d then
				d.token.block_override = true
			end
		end
	end
	
	return func(self, unit_to_link, teleport_on_enter)
end)

-- Xq: and likewise, bots can stop blocking when they exit the elevator
Mods.hook.set(mod_name, "LinkerTransportationExtension._unlink_transported_unit", function (func, self, unit_to_unlink)
	
	local unit			= unit_to_unlink
	local owner			= Managers.player:owner(unit)
	
	if get(me.SETTINGS.FILE_ENABLED) then
		if owner.bot_player then	-- check is needed because the player is also "unlinked"
			local d = get_d_data(owner.player_unit)
			if d then
				d.token.block_override = false
			end
		end
	end
	
	return func(self, unit_to_unlink)
end)

-- set ranged_not_yet_wielded to workaround weapon traits not applying bug
-- Mods.hook.set(mod_name, "GenericStatusExtension.set_dead", function (func, self, ...)
Mods.hook.set(mod_name, "GenericStatusExtension.set_ready_for_assisted_respawn", function (func, self, ready, ...)
	local file_enabled = bot_settings.menu_settings.bot_file_enabled
	if file_enabled and ready then
		local self_unit = self.unit
		local self_owner = Managers.player:unit_owner(self_unit)
		if self_owner and self_owner.bot_player then
			local d = get_d_data(self_unit)
			if d then
				d.ranged_not_yet_wielded = true
			end
		end
	end
	return func(self, ready, ...)
end)

-- Xq: Print out info text when a bot gets a guard break
Mods.hook.set(mod_name, "GenericStatusExtension.set_block_broken", function (func, self, block_broken)
	if bot_settings.menu_settings.info_guard_break then 
		local unit = self.unit
		local owner = unit and Managers.player:unit_owner(unit)
		if owner and owner.bot_player and block_broken then
			local bot_name = owner.character_name
			local message = tostring(bot_name) .. ": guard break"
			if bot_settings.menu_settings.info_guard_break_global_message then
				Managers.chat:send_system_chat_message(1, message, 0, true)
			else
				EchoConsole(message)
			end
		end
	end
	func(self, block_broken)
end)

-- Xq: Fix a bug in the original code where bot (likely human too) blocking your ranged shot that has pierced an enemy first with an off-balance shield would crash the game.
-- When this happened the crash message showed "attempt to index local 'breed' (a nil value)" pointing to buff_function_templates.lua
-- The code is almost direct copy from the sources.. there is likely a better way to implement this fix..
--edit--
--[[
Mods.hook.set(mod_name, "GenericStatusExtension.blocked_attack", function (func, self, fatigue_type, attacking_unit)
	
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, fatigue_type, attacking_unit)
	end
	
	local unit = self.unit
	local inventory_extension = self.inventory_extension
	local equipment = inventory_extension:equipment()
	local network_manager = Managers.state.network
	local blocking_unit = nil

	self:set_has_blocked(true)

	local player = self.player

	if player then
		if not player.remote then
			local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
			local first_person_unit = first_person_extension:get_first_person_unit()
			local t = Managers.time:time("game")
			local time_blocking = t - self.raise_block_time
			local timed_block = time_blocking <= 0.3

			if Managers.state.controller_features and player.local_player then
				Managers.state.controller_features:add_effect("rumble", {
					rumble_effect = "block"
				})
			end

			Unit.animation_event(first_person_unit, "parry_hit_reaction")

			local buff_extension = self.buff_extension
			local _, procced = buff_extension:apply_buffs_to_value(0, StatBuffIndex.NO_BLOCK_FATIGUE_COST)

			if not procced then
				self:add_fatigue_points(fatigue_type, "block")
			end

			blocking_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit
			local _, procced = buff_extension:apply_buffs_to_value(0, StatBuffIndex.DAMAGE_ON_TIMED_BLOCK)

			if timed_block and procced and Unit.alive(attacking_unit) then
				local wielded_slot_name = inventory_extension:get_wielded_slot_name()
				local slot_data = inventory_extension:get_slot_data(wielded_slot_name)
				local item_data = slot_data.item_data
				local item_name = item_data.name
				local damage_source_id = NetworkLookup.damage_sources[item_name]
				local unit_id = network_manager:unit_game_object_id(unit)
				local hit_unit_id = network_manager:unit_game_object_id(attacking_unit)
				local attack_template_id = NetworkLookup.attack_templates.damage_on_timed_block
				local hit_zone_id = NetworkLookup.hit_zones.full
				local attack_direction = Vector3.normalize(POSITION_LOOKUP[attacking_unit] - POSITION_LOOKUP[unit])
				local backstab_multiplier = 1
				local hawkeye_multiplier = 0

				network_manager.network_transmit:send_rpc_server("rpc_attack_hit", damage_source_id, unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, NetworkLookup.attack_damage_values["n/a"], NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)
			end

			_, procced = buff_extension:apply_buffs_to_value(0, StatBuffIndex.INCREASE_DAMAGE_TO_ENEMY_BLOCK)
			local breed = Unit.get_data(attacking_unit, "breed")
			
			-- Xq: added breed into the condition to prevent the game from trying to apply off-balance to a human due to a shot
			-- that gets blocked by a bot's (likely human's too) shield after piercing a live enemy
			if (procced or script_data.debug_legendary_traits) and Unit.alive(attacking_unit) and ScriptUnit.has_extension(attacking_unit, "buff_system") and breed then
				local buff_system = Managers.state.entity:system("buff_system")
				
				buff_system:add_buff(attacking_unit, "increase_incoming_damage", unit)
			end
		else
			Unit.animation_event(unit, "parry_hit_reaction")

			blocking_unit = equipment.right_hand_wielded_unit_3p or equipment.left_hand_wielded_unit_3p
		end

		Managers.state.entity:system("play_go_tutorial_system"):register_block()
	end

	if blocking_unit then
		local unit_pos = POSITION_LOOKUP[blocking_unit]
		local unit_rot = Unit.world_rotation(blocking_unit, 0)
		local particle_position = unit_pos + Quaternion.up(unit_rot) * Math.random() * 0.5 + Quaternion.right(unit_rot) * 0.1

		World.create_particles(self.world, "fx/wpnfx_sword_spark_parry", particle_position)
	end
end)
--]]
--edit--

-- Xq: Stop sienna bot doing friendly fire ticks with conflag staff's geiser attack
Mods.hook.set(mod_name, "ActionGeiser.fire", function (func, self, reason)
	local ret = false
	local self_unit = self.owner_unit
	local self_owner = Managers.player:unit_owner(self_unit)
	if self_owner.bot_player then
		local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
		local ff_setting_save = difficulty_settings.friendly_fire_ranged
		difficulty_settings.friendly_fire_ranged = false
		ret = func(self, reason)
		difficulty_settings.friendly_fire_ranged = ff_setting_save
	else
		ret = func(self, reason)
	end
	
	return ret
end)

-- Xq: track damage being done by bots and humans, also track damage received by the same
local add_damage_frame_checker = new_frame_checker()
local add_damage_tracker		= {}
local add_damage_weapon_factor	= {}
Mods.hook.set(mod_name, "GenericUnitDamageExtension.add_damage", function (func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit)
	
	if not get(me.SETTINGS.FILE_ENABLED) then
		return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit)
	end
	
	local current_time = Managers.time:time("game")
	
	-- to remove overkill damage the damage instances against each unit need to be tracked on fram basis
	if add_damage_frame_checker:is_new_frame() then
		-- at the start of each new frame the tracking list is reset
		add_damage_frame_checker:update()
		add_damage_tracker			= {}
		add_damage_weapon_factor	= {}
	end
	
	local scaler_data = bot_settings.scaler_data
	local local_player_unit = Managers.player:local_player().player_unit
	local self_unit = self.unit									-- self.unit = unit being damaged
	local self_owner = Managers.player:unit_owner(self_unit)	-- only humans / bots have owner
	local self_is_server = Managers.player.is_server and self_unit == local_player_unit
	local self_health_extension = ScriptUnit.has_extension(self_unit, "health_system")
	
	-- now that the unit being damaged is known, add its health to the tracking table if its not there yet
	if not add_damage_tracker[self_unit] then
		local self_current_health = (self_health_extension and self_health_extension.health - self_health_extension.damage) or false
		add_damage_tracker[self_unit] = self_current_health
	end
	
	-- and then use the tracking table's health value when determining the effective damage this attac causes to the target unit
	local self_current_health = add_damage_tracker[self_unit]
	local self_effective_damage = (self_current_health and math.min(self_current_health, damage_amount)) or false
	if self_effective_damage then
		-- also update the tracking table's health so further damage instances on this frame use the correct health value
		-- instead of the one that the target unit had at the start of the frame
		add_damage_tracker[self_unit] = add_damage_tracker[self_unit] - self_effective_damage
	end
	
	local grenade_damage = damage_source_name == "grenade_frag_01" or damage_source_name == "grenade_frag_02" or damage_source_name == "grenade_fire_01" or damage_source_name == "grenade_fire_02"
	
	local self_breed = Unit.get_data(self_unit, "breed")
	local self_is_alive = (self_current_health and self_current_health > 0) or false
	local self_status_extension = ScriptUnit.has_extension(self_unit, "status_system")
	local self_is_disabled = (self_status_extension and self_status_extension:is_disabled()) or false
	if not self_owner then self_is_disabled = true end
	
	
	-- attacker_unit = unit that does the damage
	local attacker_breed = Unit.get_data(attacker_unit, "breed")
	local attacker_owner = Managers.player:unit_owner(attacker_unit)
	local attacker_area_damage_extension = ScriptUnit.has_extension(attacker_unit, "area_damage_system")
	local attacker_is_boss = attacker_breed and (attacker_breed.name == "skaven_rat_ogre" or attacker_breed.name == "skaven_storm_vermin_champion")
	
	local valid_aoe_attacker = (attacker_area_damage_extension and not attacker_area_damage_extension.owner_player and attacker_area_damage_extension.damage_source and attacker_area_damage_extension.damage_source ~= "n/a") or false
	local attacker_is_valid = (attacker_breed or valid_aoe_attacker) and damage_type ~= "buff"
	
	local full_human_count = 0
	local sisterhood_star_count = 0
	local self_has_star = false
	for _,owner in pairs(Managers.player:players()) do
		if not owner.bot_player then
			full_human_count = full_human_count+1
		end
		
		local loop_unit = owner.player_unit
		local loop_buff_extension = loop_unit and ScriptUnit.has_extension(loop_unit, "buff_system")
		local has_star = loop_buff_extension and loop_buff_extension:has_buff_type("shared_health_pool")
		if has_star then
			sisterhood_star_count = sisterhood_star_count+1
			if loop_unit == self_unit then
				self_has_star = true
			end
		end
	end
	
	if attacker_is_valid and self_has_star then
		self_effective_damage = self_effective_damage * sisterhood_star_count
	end
	
	local bot_count, human_count	= get_able_bot_human_data()	
	
	local last_one_standing = (bot_count + human_count) == 1
	
	if self_health_extension and self_is_alive then
		if self_owner then	-- players / bots
			if attacker_is_valid and not self_is_disabled and not last_one_standing then
				if self_owner.bot_player then	-- enemies damage players
					-- bot is being damaged
					local scaler_damage = (attacker_is_boss and (self_effective_damage * scaler_data.damage_taken_boss_factor)) or self_effective_damage
					
					local d = get_d_data(self_unit)
					if d and d.token.take_damage then
						local normalized_damage	= scaler_damage / (37.5 * scaler_data:get_difficulty_modifier_damage())
						local cooldown_scaler	= 0.25 + 0.75 * normalized_damage
						local cooldown_min		= 5 * cooldown_scaler
						local cooldown_max		= 15 * cooldown_scaler
						local cooldown_value	= math.random()*(cooldown_max - cooldown_min) + cooldown_min
						
						scaler_data.damage_taken_token_available		= scaler_data.damage_taken_token_available + 1
						scaler_data.damage_taken_token_table[d.unit]	= nil
						d.token.take_damage		= false
						d.take_damage_cooldown	= d.current_time + cooldown_value
						
					end
					scaler_data.damage_taken_bot_average = scaler_data.damage_taken_bot_average + (self_effective_damage / bot_count)	-- this is collected for statistics only
					scaler_data.damage_taken_debt = scaler_data.damage_taken_debt - (scaler_damage / bot_count)
				else
					-- human is being damaged
					if self_is_server then -- server only is intentional
						scaler_data.damage_taken_human_average = scaler_data.damage_taken_human_average + self_effective_damage	-- this is collected for statistics only
						local scaler_damage = (attacker_is_boss and (self_effective_damage * scaler_data.damage_taken_boss_factor)) or self_effective_damage
						local buffer_overflow = math.max(scaler_data.damage_taken_buffer + scaler_damage - scaler_data.damage_taken_buffer_size, 0)
						local absorbed = scaler_damage - buffer_overflow
						local debt_increment = (absorbed * scaler_data.damage_taken_buffer_debt_leak_factor + buffer_overflow) / scaler_data.damage_taken_human_bot_ratio / (full_human_count ^ 0.25)
						scaler_data.damage_taken_debt_buffer		= scaler_data.damage_taken_debt_buffer + debt_increment
						scaler_data.damage_taken_debt_cumulative	= scaler_data.damage_taken_debt_cumulative + debt_increment
						scaler_data.damage_taken_buffer				= math.min(scaler_data.damage_taken_buffer + scaler_damage, scaler_data.damage_taken_buffer_size)
					end
				end
				
				if attacker_breed and attacker_breed.special then
					-- a special enemy is dealing damage
					scaler_data.specials_lookup.has_dealt_damage[attacker_unit] = true
				end
				--
			end
			
			if attacker_is_valid then
				--attacker_is_valid check removes FF / fall / poison floor / etc..
				tracker_data:add_to_unit_tracker(self_unit, "damage_taken", self_effective_damage)
				if attacker_breed then
					if attacker_breed.special then
						tracker_data:add_to_unit_tracker(self_unit, "damage_taken_specials", self_effective_damage)
						tracker_data:add_to_unit_tracker(self_unit, "damage_taken_specials_" .. attacker_breed.name, self_effective_damage)
					elseif attacker_breed.boss then
						tracker_data:add_to_unit_tracker(self_unit, "damage_taken_bosses", self_effective_damage)
					else
						tracker_data:add_to_unit_tracker(self_unit, "damage_taken_trash", self_effective_damage)
					end
				end
			end
			
		elseif self_breed then	-- players damage enemies
			local attacker_type				= (attacker_owner and ((attacker_owner.bot_player and "bot") or "human")) or (attacker_breed and "enemy") or "unknown"
			local offense_scaler_damage		= (self_breed.name == "skaven_rat_ogre" and self_effective_damage * 0.333) or (self_breed.name == "skaven_storm_vermin_champion" and self_effective_damage * 0.78) or self_effective_damage
			local damage_weight				= (grenade_damage and scaler_data.grenade_damage_weight) or scaler_data.damage_weight
			
			-- check if the damaged enemy is affected by off-balance and determine if the "buff" was given by a human or a bot
			local self_buff_extension = ScriptUnit.has_extension(self_unit, "buff_system")
			local ob_giver_unit = false
			if self_buff_extension then
				for _,value in pairs(self_buff_extension._buffs) do
					if value.buff_type == "increase_incoming_damage" then	-- = off-balance
						ob_giver_unit = value.attacker_unit
						break
					end
				end
			end
			
			local ob_giver_owner	= ob_giver_unit and Managers.player:unit_owner(ob_giver_unit)
			local ob_from_bot		= ob_giver_owner and ob_giver_owner.bot_player
			local ob_from_human		= ob_giver_owner and not ob_from_bot
			
			if attacker_type == "human" and human_count > 0 then
				if not add_damage_weapon_factor[attacker_unit] then
					local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(attacker_unit)
					add_damage_weapon_factor[attacker_unit] = bot_settings.lookup.token_damage_balancing[weapon_type] or bot_settings.lookup.token_damage_balancing.default
				end
				local weapon_factor = add_damage_weapon_factor[attacker_unit]
				
				if self_breed.special then
					scaler_data.specials_damaged_by_human[self_unit] = true
				end
				
				if human_count > 0 then
					debug_data.damage_tracker_humans = debug_data.damage_tracker_humans + (self_effective_damage / human_count)
				end
				
				scaler_data:add_offense_tokens((damage_weight / human_count) * offense_scaler_damage * weapon_factor)
			elseif attacker_type == "bot" and bot_count > 0 then
				local d = get_d_data(attacker_unit)
				if d then
					if not add_damage_weapon_factor[attacker_unit] then
						local weapon_type = d.equipped.weapon_id
						add_damage_weapon_factor[attacker_unit] = bot_settings.lookup.token_damage_balancing[weapon_type] or bot_settings.lookup.token_damage_balancing.default
					end
					local weapon_factor = add_damage_weapon_factor[attacker_unit]
					local token_usage_boost = (d.offense_scaler_ranged_multiplier > 0.999 and 1) or 1
					
					if bot_count > 0 then
						debug_data.damage_tracker_bots = debug_data.damage_tracker_bots + (self_effective_damage / bot_count)
					end
					
					if ob_from_human then
						scaler_data:add_offense_tokens((damage_weight / human_count) * offense_scaler_damage * weapon_factor)
					else
						scaler_data:use_offense_tokens((damage_weight / bot_count) * offense_scaler_damage * weapon_factor * token_usage_boost)
					end
					
					if d.equipped.melee and d.melee.target_unit then
						if self_unit == d.melee.target_unit then
							local target_position = POSITION_LOOKUP[self_unit]
							local target_distance = d.position and target_position and Vector3.length(d.position - target_position)
							if target_distance and target_distance > d.melee_reach_tracker then
								d.melee_reach_tracker = target_distance
							end
						end
					end
				end
			end
			
			if self_breed.special and not scaler_data.specials_lookup.initiative[self_unit] and (attacker_type == "human" or attacker_type == "bot") then
				scaler_data.specials_lookup.initiative[self_unit] = attacker_type
			end
			--
			local inventory_extension = ScriptUnit.has_extension(attacker_unit, "inventory_system")
			local equipped_slot	= (inventory_extension and inventory_extension:get_wielded_slot_name()) or false
			tracker_data:add_to_unit_tracker(attacker_unit, "damage_dealt", self_effective_damage)
			if equipped_slot == "slot_melee" then
				tracker_data:add_to_unit_tracker(attacker_unit, "damage_dealt_melee", self_effective_damage)
			elseif equipped_slot == "slot_ranged" then
				tracker_data:add_to_unit_tracker(attacker_unit, "damage_dealt_ranged", self_effective_damage)
			end
			
			if self_breed.special then
				tracker_data:add_to_unit_tracker(attacker_unit, "damage_dealt_specials", self_effective_damage)
			elseif self_breed.boss then
				tracker_data:add_to_unit_tracker(attacker_unit, "damage_dealt_bosses", self_effective_damage)
			else
				tracker_data:add_to_unit_tracker(attacker_unit, "damage_dealt_trash", self_effective_damage)
			end
			--
		else
			-- player / bot damages something else
			if Unit.alive(self_unit) and attacker_unit == self_unit and not attacker_owner and not ScriptUnit.has_extension(self_unit, "door_system") and self_effective_damage > 0 and bot_settings.menu_settings.help_with_breakables_objectives then
				local target_health_extension = ScriptUnit.extension(self_unit, "health_system")
				if target_health_extension then
					if target_health_extension:is_alive() and target_health_extension:current_health_percent() >= bot_settings.menu_settings.breakables_objectives_threshold then
						-- fist check that the object is not already in the list
						local new_object = true;
						for _,data in pairs(bot_settings.breakable_objectives) do
							if data.unit == self_unit then
								new_object = false
								break
							end
						end
						
						-- if the object is a new one >> add it to the list
						if new_object then
							local target_position = Unit.world_position(self_unit, 0)
							local table_data =
							{
								unit				= self_unit,
								health_extension	= target_health_extension,
								position			= Vector3Box(target_position),
								area				= new_area_check_sphere(target_position,4),
							}
							table.insert(bot_settings.breakable_objectives, table_data)
							-- debug_print_variables("Added new brakable objective", table_data.unit, table_data.position:unbox(), table_data.area)
						end
					end
				end
			end
		end
	end
	
	-- some garbage collectors
	for unit,_ in pairs(scaler_data.specials_lookup.has_dealt_damage) do
		if not Unit.alive(unit) then
			scaler_data.specials_lookup.has_dealt_damage[unit] = nil
		end
	end
	
	for unit,_ in pairs(scaler_data.specials_lookup.initiative) do
		if not Unit.alive(unit) then
			scaler_data.specials_lookup.initiative[unit] = nil
		end
	end
	
	-- done
	return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit)
end)

-- Xq: track heals gained via procs and update damage_buffer as needed
Mods.hook.set(mod_name, "DamageUtils.heal_network", function (func, healed_unit, healer_unit, heal_amount, heal_type)
	local local_player_unit	= Managers.player:local_player().player_unit
	local health_extension = ScriptUnit.has_extension(healed_unit, "health_system")
	local current_damage = (health_extension and health_extension.damage) or 0
	
	-- block healed manual heal target from getting healed again immediately
	local current_time = Managers.time:time("game")
	local primary_heal_types = 
	{
		healing_draught = true,	-- draught
		bandage			= true,	-- medkit
		bandage_trinket	= true,	-- healshare or dove
	}
	if healed_unit == last_manual_heal_target and primary_heal_types[heal_type] then
		invalid_manual_heal_targets[healed_unit] = current_time + 1
	end
	
	if healed_unit == local_player_unit and current_damage and heal_type == "proc" then
		local effective_heal_amount = math.min(heal_amount, current_damage)
		bot_settings.scaler_data.damage_taken_buffer = math.max(bot_settings.scaler_data.damage_taken_buffer - effective_heal_amount, 0)
		-- EchoConsole("Local player healed by proc")
	end
	
	if heal_type == "proc" then
		local effective_heal_amount = math.min(heal_amount, current_damage)
		local inventory_extension = ScriptUnit.has_extension(healed_unit, "inventory_system")
		local equipped_slot	= (inventory_extension and inventory_extension:get_wielded_slot_name()) or false
		tracker_data:add_to_unit_tracker(healed_unit, "proc_effective_heal", effective_heal_amount)
		tracker_data:add_to_unit_tracker(healed_unit, "proc_heal", heal_amount)
		if equipped_slot == "slot_melee" then
			tracker_data:add_to_unit_tracker(healed_unit, "proc_effective_heal_melee", effective_heal_amount)
			tracker_data:add_to_unit_tracker(healed_unit, "proc_heal_melee", heal_amount)
		elseif equipped_slot == "slot_ranged" then
			tracker_data:add_to_unit_tracker(healed_unit, "proc_effective_heal_ranged", effective_heal_amount)
			tracker_data:add_to_unit_tracker(healed_unit, "proc_heal_ranged", heal_amount)
		end
	end
	
	return func(healed_unit, healer_unit, heal_amount, heal_type)
end)

-- Xq: track scavenger procs (only works for local player / bots)
Mods.hook.set(mod_name, "GenericAmmoUserExtension.add_ammo_to_reserve", function (func, self, amount)
	local self_unit = self.owner_unit
	local pre_proc_ammo = self:total_remaining_ammo()
	func(self, amount)
	local post_proc_ammo = self:total_remaining_ammo()
	local ammo_gain = math.max(post_proc_ammo - pre_proc_ammo, 0)
	
	if self_unit and ammo_gain > 0 then
		local inventory_extension = ScriptUnit.has_extension(self_unit, "inventory_system")
		local equipped_slot	= (inventory_extension and inventory_extension:get_wielded_slot_name()) or false
		tracker_data:add_to_unit_tracker(self_unit, "proc_ammo", ammo_gain)
		if equipped_slot == "slot_melee" then
			tracker_data:add_to_unit_tracker(self_unit, "proc_ammo_melee", ammo_gain)
		elseif equipped_slot == "slot_ranged" then
			tracker_data:add_to_unit_tracker(self_unit, "proc_ammo_ranged", ammo_gain)
		end
	end
	
	return
end)

-- Xq: Track down all staggers and generate / consume offense tokens based on the appropriate weight factor
local stagger_frame_checker = new_frame_checker()
local stagger_weapon_factor = {}
Mods.hook.set(mod_name, "Staggers.ai_stagger", function (func, attack_template, attacker_unit, hit_unit, hit_zone_name, attack_direction, t)
	func(attack_template, attacker_unit, hit_unit, hit_zone_name, attack_direction, t)
	
	if stagger_frame_checker:is_new_frame() then
		stagger_frame_checker:update()
		stagger_weapon_factor = {}
	end
		
	local self_unit					= attacker_unit
	local self_owner				= Managers.player:unit_owner(self_unit)
	local target_unit				= hit_unit
	local target_alive				= is_unit_alive(target_unit)
	local target_breed				= Unit.get_data(target_unit, "breed")
	local attack_is_push			= attack_template and attack_template.is_push
	
	local bot_count, human_count = get_able_bot_human_data()
	
	if target_breed and target_alive and self_owner then
		if not stagger_weapon_factor[self_unit] then
			local weapon_type, weapon_unit, weapon_template = get_equipped_weapon_info(self_unit)
			local lookup_table = (attack_is_push and bot_settings.lookup.token_push_balancing) or bot_settings.lookup.token_stagger_balancing
			stagger_weapon_factor[self_unit] = lookup_table[weapon_type] or lookup_table.default
		end
		
		local difficulty_factor		= bot_settings.scaler_data:get_difficulty_modifier_life()
		local weapon_factor			= stagger_weapon_factor[self_unit]
		
		if self_owner.bot_player and bot_count > 0 then
			if attack_is_push then
				-- bot staggered an enemy by pushing
				-- bot_settings.scaler_data.offense_tokens = bot_settings.scaler_data.offense_tokens - (bot_settings.scaler_data.stagger_bot_push_weight / bot_count) * difficulty_factor * weapon_factor
				bot_settings.scaler_data:use_offense_tokens((bot_settings.scaler_data.stagger_bot_push_weight / bot_count) * difficulty_factor * weapon_factor)
			else
				-- bot staggered an enemy by hitting it
				-- bot_settings.scaler_data.offense_tokens = bot_settings.scaler_data.offense_tokens - (bot_settings.scaler_data.stagger_weight / bot_count) * difficulty_factor * weapon_factor
				bot_settings.scaler_data:use_offense_tokens((bot_settings.scaler_data.stagger_weight / bot_count) * difficulty_factor * weapon_factor)
			end
			
			if bot_count > 0 then
				debug_data.stagger_tracker_bots = debug_data.stagger_tracker_bots + (1 / bot_count)
			end
			
			if target_breed.special and not bot_settings.scaler_data.specials_lookup.initiative[target_unit] then
				bot_settings.scaler_data.specials_lookup.initiative[target_unit] = "bot"
			end
		elseif human_count > 0 then
			-- human staggered an enemy
			-- bot_settings.scaler_data.offense_tokens = bot_settings.scaler_data.offense_tokens + (bot_settings.scaler_data.stagger_weight / human_count) * difficulty_factor * weapon_factor
			bot_settings.scaler_data:add_offense_tokens((bot_settings.scaler_data.stagger_weight / human_count) * difficulty_factor * weapon_factor)
			if human_count > 0 then
				debug_data.stagger_tracker_humans = debug_data.stagger_tracker_humans + (1 / human_count)
			end
			
			if target_breed.special and not bot_settings.scaler_data.specials_lookup.initiative[target_unit] then
				bot_settings.scaler_data.specials_lookup.initiative[target_unit] = "human"
			end
		end
	end
	
	return
end)

-- Xq: Track down all kills and generate / consume offense tokens based on the appropriate weight factor
Mods.hook.set(mod_name, "ConflictDirector.register_unit_killed", function (func, self, unit, blackboard, killer_unit, killing_blow)
	func(self, unit, blackboard, killer_unit, killing_blow)
	
	local self_unit		= killer_unit
	local self_owner	= Managers.player:unit_owner(self_unit)
	local killed_unit	= unit
	local killed_breed	= Unit.get_data(killed_unit, "breed")
	local initiative	= bot_settings.scaler_data.specials_lookup.initiative
	
	local bot_count, human_count = get_able_bot_human_data()
	
	-- only count enemy kills, not barricades / doors / ..
	if killed_breed and self_owner then
		local difficulty_factor = bot_settings.scaler_data:get_difficulty_modifier_life()
		local special_kill	= killed_breed.special
		
		if self_owner.bot_player then
			-- bot killed an enemy
			local d = get_d_data(self_unit)
			
			if d then
				if d.equipped.ranged then
					d.last_ranged_kill = d.current_time
				end
			end
			
			if special_kill then
				local assist_by_human = bot_settings.scaler_data.specials_pinged_by_human[killed_unit] or bot_settings.scaler_data.specials_damaged_by_human[killed_unit]
				
				if killed_breed.special and not initiative[killed_unit] then
					initiative[killed_unit] = "bot"
				end
				
				if initiative[killed_unit] == "human" then
					-- human has initiative, but bot kills >> humans get half score
					local human_score = bot_settings.scaler_data.specials_lookup.human_count_factor[human_count+1] * 0.5
					bot_settings.scaler_data.bot_specials_balance = bot_settings.scaler_data.bot_specials_balance - human_score
				elseif initiative[killed_unit] == "bot" then
					-- bot has initiative & kill.. 
					local bot_score = (assist_by_human and 0.5) or 1	-- if human assisted in the kill then the bot only get half score, otherwise full score to bots
					bot_settings.scaler_data.bot_specials_balance = bot_settings.scaler_data.bot_specials_balance + bot_score
				elseif not initiative[killed_unit] then
					-- this should never execute
					EchoConsole("Error: no initiative found " .. tostring(killed_breed.name))
				end
			end
			
			if bot_count > 0 then
				-- bot_settings.scaler_data.offense_tokens = bot_settings.scaler_data.offense_tokens - (bot_settings.scaler_data.kill_weight / bot_count) * difficulty_factor
				bot_settings.scaler_data:use_offense_tokens((bot_settings.scaler_data.kill_weight / bot_count) * difficulty_factor)
			end
		else
			-- human killed an enemy
			if special_kill then
				if killed_breed.special and not initiative[killed_unit] then
					initiative[killed_unit] = "human"
				end
				
				if initiative[killed_unit] == "human" then
					-- human has initiative & kill
					local human_score = bot_settings.scaler_data.specials_lookup.human_count_factor[human_count+1]
					-- no assist points for bots due to how easy it is for them to do *some* damage to the special once it has been detected
					bot_settings.scaler_data.bot_specials_balance = bot_settings.scaler_data.bot_specials_balance - human_score
				elseif initiative[killed_unit] == "bot" then
					-- bot has initiative, but human kills (and thereby automatically assists) >> bots get half score 
					local bot_score = 0.5
					bot_settings.scaler_data.bot_specials_balance = bot_settings.scaler_data.bot_specials_balance + bot_score
				elseif not initiative[killed_unit] then
					-- this should never execute
					EchoConsole("Error: no initiative found " .. tostring(killed_breed.name))
				end
			end
			
			if human_count > 0 then
				bot_settings.scaler_data:add_offense_tokens((bot_settings.scaler_data.kill_weight / human_count) * difficulty_factor)
			end
		end
	end
	
	return
end)

local when_level_starts = function()
	
	local current_difficulty	= Managers.state.difficulty.difficulty
	local below_cata			= not(current_difficulty == "hardest" or current_difficulty == "survival_hardest")
	
	local scaler_data								= bot_settings.scaler_data
	local offense_token_passive_cap					= bot_settings.scaler_data.offense_token_passive_cap * bot_settings.scaler_data:get_difficulty_modifier_life()	
	
	scaler_data.next_taken_drain_tick				= 3
	scaler_data.damage_taken_bot_average			= 0
	scaler_data.damage_taken_human_average			= 0
	scaler_data.damage_taken_buffer_size			= scaler_data:get_difficulty_modifier_damage() * 37.5 * 1.0
	scaler_data.damage_taken_buffer					= 0
	scaler_data.damage_taken_debt					= 0
	scaler_data.damage_taken_debt_buffer			= 0
	scaler_data.damage_taken_debt_cumulative		= scaler_data.damage_taken_debt
	scaler_data.damage_taken_debt_trasfer_min		= 37.5 * 0.5 * scaler_data.damage_taken_debt_trasfer_factor * scaler_data:get_difficulty_modifier_damage()
	scaler_data.damage_taken_debt_trasfer_max		= 37.5 * 2.0 * scaler_data.damage_taken_debt_trasfer_factor * scaler_data:get_difficulty_modifier_damage()
	scaler_data.damage_taken_debt_trasfer_next_tick	= 0
	scaler_data.damage_taken_token_available		= (below_cata and 2) or 2
	scaler_data.damage_taken_token_table			= {}
	scaler_data.damage_taken_roll_count				= 0
	scaler_data.damage_taken_last_check				= 0
	scaler_data.offense_tokens						= offense_token_passive_cap
	scaler_data.next_offense_token_tick				= 1
	
	bot_settings.scaler_data.offense_time_pool_timer	= 0
	bot_settings.scaler_data.bot_specials_balance		= 3
	bot_settings.scaler_data.specials_pinged_by_human	= {}
	bot_settings.scaler_data.specials_damaged_by_human	= {}
	bot_settings.scaler_data.specials_release_denied	= {}
	bot_settings.breakable_objectives = {}
	bot_settings.trading.active_trades = 
	{
		can_accept_heal_item = {},
		can_accept_potion = {},
		can_accept_grenade = {},
	}
	
	--edit start--
	bot_settings.lookup.path_preload.loading_done = false
	--edit end--
	
	tracker_data.stat_trackers			= {}
	debug_data.damage_tracker_humans	= 0
	debug_data.damage_tracker_bots		= 0
	debug_data.stagger_tracker_humans	= 0
	debug_data.stagger_tracker_bots		= 0
end

Mods.hook.set(mod_name, "GameModeManager.init", function(func, self, ...)
    func(self, ...)
	when_level_starts()
    return
end)

local when_level_ends = function()
	local is_server	= Managers.player.is_server
	local level_id	= LevelHelper:current_level_settings().level_id
	
	if ENABLE_DEBUG_FEEDS and is_server and level_id ~= "inn_level" then
--edit--
		-- EchoConsole(">>")
		EchoConsole("Average damage dealt by humans: " .. number_to_string(debug_data.damage_tracker_humans, 2))
		EchoConsole("Average damage dealt by bots: " .. number_to_string(debug_data.damage_tracker_bots, 2))
		-- EchoConsole(">>")
		EchoConsole("Average stagger dealt by humans: " .. number_to_string(debug_data.stagger_tracker_humans, 2))
		EchoConsole("Average stagger dealt by bots: " .. number_to_string(debug_data.stagger_tracker_bots, 2))
		-- EchoConsole(">>")
		-- EchoConsole("Proc. data: name | dmg in | dmg out | heal | scav.")
		EchoConsole("Proc. data: name | heal M | heal R || scav M | scav R")
		for _,data in pairs(tracker_data.stat_trackers) do
			-- EchoConsole(
				-- data:get_value("name") .. " | " ..
				-- number_to_string(data:get_value("damage_taken"),2) .. " | " ..
				-- number_to_string(data:get_value("damage_dealt"),2) .. " | " ..
				-- number_to_string(data:get_value("proc_heal"),2) .. " | " ..
				-- number_to_string(data:get_value("proc_ammo"),2)
			-- )
			EchoConsole(
				data:get_value("name") .. " | " ..
				number_to_string(data:get_value("proc_heal_melee"),2) .. " | " ..
				number_to_string(data:get_value("proc_heal_ranged"),2) .. " || " ..
				number_to_string(data:get_value("proc_ammo_melee"),2) .. " | " ..
				number_to_string(data:get_value("proc_ammo_ranged"),2)
			)
			-- debug_print_table(data)	-- get_unit_tracker
		end
		
		-- EchoConsole(">>")
--edit--
	end
	
	bot_settings.scaler_data.init_token = true
	return
end

Mods.hook.set(mod_name, "GameModeManager.trigger_event", function(func, self, event, ...)
	if event == "end_conditions_met" then
		when_level_ends()
	end
    func(self, event, ...)
    return
end)

-- Vernon: Poison globe landing prediction
Mods.hook.set(mod_name, "BTAdvanceTowardsPlayersAction._calculate_trajectory_to_target", function(func, self, unit, world, blackboard, action)
	local curr_pos = Vector3.copy(POSITION_LOOKUP[unit])
	local rot = LocomotionUtils.rotation_towards_unit_flat(unit, blackboard.target_unit)
	local x, y, z = unpack(action.attack_throw_offset)
	local pos = Vector3(x, y, z)
	local throw_offset = Quaternion.rotate(rot, pos)
	local throw_pos = curr_pos + throw_offset
	curr_pos.z = throw_pos.z
	local root_to_throw = throw_pos - curr_pos
	local direction = Vector3.normalize(root_to_throw)
	local length = Vector3.length(root_to_throw)
	local physics_world = World.get_data(world, "physics_world")
	local result = PhysicsWorld.immediate_raycast(physics_world, curr_pos, direction, length, "closest", "collision_filter", "filter_enemy_ray_projectile")

	if result then
		return false
	end

	local radius = action.radius - 1
	local max_distance = action.range
	local target_position = PerceptionUtils.pick_area_target(unit, blackboard, nil, radius, max_distance)
	local target_vector = Vector3.normalize(target_position - throw_pos)
	local hit, angle, speed = WeaponHelper:calculate_trajectory(world, throw_pos, target_position, ProjectileGravitySettings.default, blackboard.breed.max_globe_throw_speed)

	if target_position == nil then
		Mods.debug.write_log(Mods.debug.debug_message)
	end

	if hit then
		blackboard.throw_globe_data = blackboard.throw_globe_data or {
			--edit--
			throw_pos = Vector3Box(),
			-- target_direction = Vector3Box()
			target_direction = Vector3Box(),
			-- target_position = Vector3Box(),
			--edit--
		}
		blackboard.throw_globe_data.angle = angle
		blackboard.throw_globe_data.speed = speed

		blackboard.throw_globe_data.throw_pos:store(throw_pos)
		blackboard.throw_globe_data.target_direction:store(target_vector)
		--edit--
		-- EchoConsole("A " .. tostring(target_position))
		blackboard.throw_globe_data.target_position = blackboard.throw_globe_data.target_position or Vector3Box()
		blackboard.throw_globe_data.target_position:store(target_position)
		blackboard.throw_globe_data.target_distance = Vector3.distance(throw_pos, target_position)
		--edit--
	end

	return hit
end)

local bot_poison_wind_prediction_ids = {}

Mods.hook.set(mod_name, "BTThrowPoisonGlobeAction.launch_projectile", function(func, self, blackboard, action, initial_position, target_vector, angle, speed, owner_unit)
	local difficulty_rank = Managers.state.difficulty:get_difficulty_rank()
	local aoe_dot_damage_table = action.aoe_dot_damage[difficulty_rank]
	local aoe_dot_damage = DamageUtils.calculate_damage(aoe_dot_damage_table)
	local aoe_init_damage_table = action.aoe_init_damage[difficulty_rank]
	local aoe_init_damage = DamageUtils.calculate_damage(aoe_init_damage_table)
	local aoe_dot_damage_interval = action.aoe_dot_damage_interval
	local radius = action.radius
	local duration = action.duration
	local damage_source = blackboard.breed.name
	local create_nav_tag_volume = action.create_nav_tag_volume
	local nav_tag_volume_layer = action.nav_tag_volume_layer
	local extension_init_data = {
		projectile_locomotion_system = {
			trajectory_template_name = "throw_trajectory",
			angle = angle,
			speed = speed,
			target_vector = target_vector,
			initial_position = initial_position
		},
		projectile_impact_system = {
			server_side_raycast = true,
			collision_filter = "filter_enemy_ray_projectile",
			owner_unit = owner_unit
		},
		projectile_system = {
			impact_template_name = "explosion_impact",
			damage_source = damage_source,
			owner_unit = owner_unit
		},
		area_damage_system = {
			dot_effect_name = "fx/wpnfx_poison_wind_globe_impact",
			area_damage_template = "area_dot_damage",
			invisible_unit = false,
			player_screen_effect_name = "fx/screenspace_poison_globe_impact",
			area_ai_random_death_template = "area_poison_ai_random_death",
			damage_players = true,
			aoe_dot_damage = aoe_dot_damage,
			aoe_init_damage = aoe_init_damage,
			aoe_dot_damage_interval = aoe_dot_damage_interval,
			radius = radius,
			life_time = duration,
			damage_source = damage_source,
			create_nav_tag_volume = create_nav_tag_volume,
			nav_tag_volume_layer = nav_tag_volume_layer
		}
	}
	local projectile_unit_name = "units/weapons/projectile/poison_wind_globe/poison_wind_globe"
	local projectile_unit = Managers.state.unit_spawner:spawn_network_unit(projectile_unit_name, "aoe_projectile_unit", extension_init_data, initial_position)
	
	if Managers.player.is_server then
		local special_balance_passed = false
		
		for _, loop_owner in pairs(Managers.player:bots()) do
			local loop_unit = loop_owner.player_unit
			local d	= get_d_data(loop_unit)
			if d and d.settings.better_melee and d.settings.bot_file_enabled then
				-- if bot_settings.scaler_data.bot_specials_balance and bot_settings.scaler_data.bot_specials_balance < 5 then
					special_balance_passed = true
					break
				-- end
			end
		end
		
		if special_balance_passed then
			local volume_system = Managers.state.entity:system("volume_system")
			local target_position = blackboard.throw_globe_data and blackboard.throw_globe_data.target_position and blackboard.throw_globe_data.target_position:unbox()
			if target_position and volume_system then
				bot_poison_wind_prediction_ids[projectile_unit] = {
					-- id = volume_system:create_nav_tag_volume_from_data(target_position, radius, "bot_poison_wind"),
					expires_at = Managers.time:time("game") + 5,
				}
				bot_poison_wind_prediction_ids[projectile_unit].id = volume_system:create_nav_tag_volume_from_data(target_position, radius, "bot_poison_wind")
			end
		end
	end
end)

-- Vernon: enlarge poison cloud nav tag volume
Mods.hook.set(mod_name, "VolumeSystem.create_nav_tag_volume_from_data", function(func, self, pos, size, layer_name)
	if layer_name == "bot_poison_wind" and size then
		size = size + 0.6
	end

	return func(self, pos, size, layer_name)
end)

Mods.hook.set(mod_name, "AreaDamageExtension.start", function(func, self)
	func(self)
	
	if self.unit and bot_poison_wind_prediction_ids[self.unit] then
		local volume_system = Managers.state.entity:system("volume_system")

		if bot_poison_wind_prediction_ids[self.unit].id then
			volume_system:destroy_nav_tag_volume(bot_poison_wind_prediction_ids[self.unit].id)
		end
		bot_poison_wind_prediction_ids[self.unit] = nil
	end
end)

-- Vernon: remove bot_poison_wind nav tag volume when expired, not sure which function is good to hook...
Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, ...)
	func(self, ...)

	for projectile_unit, data in pairs(bot_poison_wind_prediction_ids) do
		local volume_system = Managers and Managers.state and Managers.state.entity and Managers.state.entity.system and Managers.state.entity:system("volume_system")
		if volume_system and bot_poison_wind_prediction_ids[projectile_unit] and bot_poison_wind_prediction_ids[projectile_unit].expires_at and bot_poison_wind_prediction_ids[projectile_unit].expires_at < Managers.time:time("game") then
			if bot_poison_wind_prediction_ids[projectile_unit].id then
				volume_system:destroy_nav_tag_volume(bot_poison_wind_prediction_ids[projectile_unit].id)
			end
			bot_poison_wind_prediction_ids[self.unit] = nil
		end
	end
end)

--for testing the effect
-- Mods.hook.set(mod_name, "AreaDamageExtension.init", function(func, self, extension_init_context, unit, extension_init_data)
	-- func(self, extension_init_context, unit, extension_init_data)
	
	-- self.create_nav_tag_volume = nil
-- end)

--Includes memory leak fix
Mods.hook.set(mod_name, "AIBotGroupSystem._selected_unit_is_in_disallowed_nav_tag_volume", function(func, self, nav_world, selected_unit_pos)
	local tag_volumes_query = GwNavQueries.tag_volumes_from_position(nav_world, selected_unit_pos, 2, 2)

	if tag_volumes_query then
		local volume_system = Managers.state.entity:system("volume_system")
		local volume_count = GwNavQueries.nav_tag_volume_count(tag_volumes_query)

		for i = 1, volume_count, 1 do
			local nav_tag_volume = GwNavQueries.nav_tag_volume(tag_volumes_query, i)
			local is_exclusive, color, layer_id, smart_object_id, user_data_id = GwNavTagVolume.navtag(nav_tag_volume)
			local layer_name = LAYER_ID_MAPPING[layer_id]
			local current_mapping = volume_system:get_volume_mapping_from_lookup_id(user_data_id)

			if current_mapping and self._disallowed_tag_layers[layer_name] then
				return true, current_mapping
			end
		end

		GwNavQueries.destroy_query_dynamic_output(tag_volumes_query)

		return false
	else
		return false
	end
end)

-- Fix to memory leak issue caused by this bunction in base game
Mods.hook.set(mod_name, "NavTagVolumeUtils.nav_tags_from_position", function(func, nav_world, position, above, below, layer_name_optional)
	local layer_id_optional = layer_name_optional and LAYER_ID_MAPPING[layer_name_optional]
	local query_output = GwNavQueries.tag_volumes_from_position(nav_world, position, above, below)
	local nav_tags = nil

	if query_output then
		local tag_volume_n = GwNavQueries.nav_tag_volume_count(query_output)

		for i = 1, tag_volume_n, 1 do
			local tag_volume = GwNavQueries.nav_tag_volume(query_output, i)
			local is_exclusive, color, layer_id, smart_object_id, user_data_id = GwNavTagVolume.navtag(tag_volume)

			if not layer_id_optional or layer_id_optional == layer_id then
				nav_tags = nav_tags or {}
				nav_tags[#nav_tags + 1] = {
					is_exclusive = is_exclusive,
					color = color,
					layer_id = layer_id,
					smart_object_id = smart_object_id,
					user_data_id = user_data_id
				}
			end
		end
		GwNavQueries.destroy_query_dynamic_output(query_output)
	end
	
	return nav_tags
	
end)

Mods.hook.set(mod_name, "NavTagVolumeUtils.inside_nav_tag_layer", function(func, nav_world, position, above, below, layer_name)
	local layer = LAYER_ID_MAPPING[layer_name]
	local query_output = GwNavQueries.tag_volumes_from_position(nav_world, position, above, below)

	if query_output then
		local tag_volume_n = GwNavQueries.nav_tag_volume_count(query_output)

		for i = 1, tag_volume_n, 1 do
			local tag_volume = GwNavQueries.nav_tag_volume(query_output, i)
			local is_exclusive, color, layer_id, smart_object_id, user_data_id = GwNavTagVolume.navtag(tag_volume)

			if layer == layer_id then
				GwNavQueries.destroy_query_dynamic_output(query_output)
				return true
			end
		end
		
		GwNavQueries.destroy_query_dynamic_output(query_output)
	end
end)

--edit--
-- Vernon: possibly disable the threat box system below, though calculating escape point is useful (tested for ogres only)
Mods.hook.set(mod_name, "AIBotGroupSystem.aoe_threat_created", function(func, self, position, shape, size, rotation, duration)
	return
end)
--edit--

-- Vernon: add threat zone to ogre jump attack
Mods.hook.set(mod_name, "BTJumpSlamAction.enter", function(func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	
	if Managers.player.is_server then
		local create_threat_zone = false
		
		for _, loop_owner in pairs(Managers.player:bots()) do
			local loop_unit = loop_owner.player_unit
			local d	= get_d_data(loop_unit)
			if d and d.settings.better_melee and d.settings.bot_file_enabled then
				create_threat_zone = true
				break
			end
		end
		
		if create_threat_zone and Managers.player.is_server then
			local data = blackboard.jump_slam_data
			local target_pos = data and data.target_pos and data.target_pos:unbox()
			local volume_system = Managers.state.entity:system("volume_system")
			
			if target_pos and volume_system then
				bot_poison_wind_prediction_ids[unit] = {
					-- id = volume_system:create_nav_tag_volume_from_data(target_pos, 7, "bot_poison_wind"),
					expires_at = Managers.time:time("game") + 5,
				}
				bot_poison_wind_prediction_ids[unit].id = volume_system:create_nav_tag_volume_from_data(target_pos, 7, "bot_poison_wind")
			end
		end
	end
end)

Mods.hook.set(mod_name, "BTJumpSlamAction.leave", function(func, self, unit, blackboard, t, reason)
	func(self, unit, blackboard, t, reason)
	
	if unit and bot_poison_wind_prediction_ids[unit] then
		local volume_system = Managers.state.entity:system("volume_system")

		if bot_poison_wind_prediction_ids[unit].id then
			volume_system:destroy_nav_tag_volume(bot_poison_wind_prediction_ids[unit].id)
		end
		bot_poison_wind_prediction_ids[unit] = nil
	end
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
me.create_options()
