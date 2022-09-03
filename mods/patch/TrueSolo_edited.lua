local mod_name = "TrueSolo"

local user_setting = Application.user_setting

local MOD_SETTINGS = {
	ENABLED = {
		["save"] = "cb_true_solo",
		["widget_type"] = "stepper",
		["text"] = "True Solo Mode",
		["tooltip"] = "True Solo Mode\n" ..
			"Gameplay modifications aimed at solo play.\n" ..
			"Also works for no-bot duo etc.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
					"cb_true_solo_hide_frames",
					"cb_true_solo_assassin_spawn_sound",
					"cb_true_solo_assassin_sound_2d",
					"cb_true_solo_assassin_hero_warning",
					"cb_true_solo_no_hordes_when_ogre_alive",
					"cb_true_solo_orge_dmg_taken",
					"cb_true_solo_specials_ratio",
					"cb_true_solo_horde_size",
					"cb_true_solo_damage_intensity",
					"cb_true_solo_assassin_intensity",
					"cb_true_solo_skip_cutscenes",
					"cb_true_solo_non_disabling",
					"cb_true_solo_no_loot_dice",
					"cb_true_solo_no_lore_page",
					"cb_true_solo_objective_defense_damage_divisor",
					"cb_true_solo_krench_dmg_taken",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_true_solo_hide_frames",
					"cb_true_solo_assassin_spawn_sound",
					"cb_true_solo_assassin_sound_2d",
					"cb_true_solo_assassin_hero_warning",
					"cb_true_solo_no_hordes_when_ogre_alive",
					"cb_true_solo_orge_dmg_taken",
					"cb_true_solo_specials_ratio",
					"cb_true_solo_horde_size",
					"cb_true_solo_damage_intensity",
					"cb_true_solo_assassin_intensity",
					"cb_true_solo_skip_cutscenes",
					"cb_true_solo_non_disabling",
					"cb_true_solo_no_loot_dice",
					"cb_true_solo_no_lore_page",
					"cb_true_solo_objective_defense_damage_divisor",
					"cb_true_solo_krench_dmg_taken",
				}
			},
		},
	},
	HIDE_OTHER_FRAMES = {
		["save"] = "cb_true_solo_hide_frames",
		["widget_type"] = "stepper",
		text = "Remove Other Player/Bot UI",
		tooltip = "Remove Other Player/Bot UI\n" ..
				"Hide the UI elements of other players or bots",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	ASSASSIN_SPAWN_SOUND = {
		["save"] = "cb_true_solo_assassin_spawn_sound",
		["widget_type"] = "stepper",
		text = "Assassin Spawn Sound",
		tooltip = "Assassin Spawn Sound\n" ..
				"Use different assassin spawn sound to prevent silent spawns.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	NO_HORDES_WHEN_OGRE_ALIVE = {
		["save"] = "cb_true_solo_no_hordes_when_ogre_alive",
		["widget_type"] = "stepper",
		["text"] = "No Hordes When Ogre Alive",
		["tooltip"] = "No Hordes When Ogre Alive\n" ..
			"Delay horde while an orge alive.\n",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	ORGE_DMG_TAKEN = {
		["save"] = "cb_true_solo_orge_dmg_taken",
		["widget_type"] = "dropdown",
		["text"] = "Ogre Damage Taken Multiplier",
		["tooltip"] =  "Ogre Damage Taken Multiplier\n" ..
			"Ogre will take damage multiplied by a value.",
		["value_type"] = "number",
		["options"] = {
			{text = "1x", value = 1},
			{text = "1.75x", value = 2},
			{text = "2.5x", value = 3},
		},
		["default"] = 1, -- 1x
	},
	SPECIALS_RATIO = {
		["save"] = "cb_true_solo_specials_ratio",
		["widget_type"] = "dropdown",
		["text"] = "Specials Ratio",
		["tooltip"] =  "Specials Ratio\n" ..
			"Change ratio of spawned specials:\n" ..
			"Default: Don't change anything\n" ..
			"Less disablers: 35%, 35%, 15%, 15%\n" ..
			"Least disablers: 40%, 40%, 10%, 10%\n" ..
			"No disablers: 50%, 50%, 0%, 0%\n",
		["value_type"] = "number",
		["options"] = {
			{text = "Default", value = 1},
			{text = "Less disablers", value = 4},
			{text = "Least disablers", value = 2},
			{text = "No disablers", value = 3},
		},
		["default"] = 1, -- Default
	},
	HORDE_SIZE = {
		["save"] = "cb_true_solo_horde_size",
		["widget_type"] = "slider",
		["text"] = "Horde Size",
		["tooltip"] =  "Horde Size\n" ..
			"Adjust horde size. 200 = 2x",
		-- ["range"] = {10, 200},
		["range"] = {0, 200},
		["default"] = 100,
	},
	DAMAGE_INTENSITY = {
		["save"] = "cb_true_solo_damage_intensity",
		["widget_type"] = "dropdown",
		["text"] = "Damage Taken Intensity",
		["tooltip"] =  "Damage Taken Intensity\n" ..
			"By default damage taken affects conflict director intensity,\n" ..
			"choose other options to alter the dependence.",
		["value_type"] = "number",
		["options"] = {
			{text = "Default", value = 1},
			{text = "Half", value = 2},
			{text = "None", value = 3},
		},
		["default"] = 1, -- Default
	},
	ASSASSIN_INTENSITY = {
		["save"] = "cb_true_solo_assassin_intensity",
		["widget_type"] = "dropdown",
		["text"] = "Assassin Intensity",
		["tooltip"] =  "Assassin Intensity\n" ..
			"Freeze conflict director intensity decay for assassinss.",
		["value_type"] = "number",
		["options"] = {
			{text = "Default", value = 1},
			{text = "Enabled", value = 2},
		},
		["default"] = 1, -- Default
	},
--[[
	SKIP_CUTSCENES = {
		["save"] = "cb_true_solo_skip_cutscenes",
		["widget_type"] = "stepper",
		text = "Skip Cutscenes",
		tooltip = "Skip Cutscenes\n" ..
				"Allows you to skip cutscenes by pressing space.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
--]]
	ASSASSIN_HERO_WARNING = {
		["save"] = "cb_true_solo_assassin_hero_warning",
		["widget_type"] = "stepper",
		text = "Assassin/Packmaster Hero Warning",
		tooltip = "Assassin/Packmaster Hero Warning\n" ..
				"Play hero warning dialogue on assassin and packmaster spawns.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	ASSASSIN_SOUND_2D = {
		["save"] = "cb_true_solo_assassin_sound_2d",
		["widget_type"] = "stepper",
		text = "Assassin 2D Sound",
		tooltip = "Assassin 2D Sound\n" ..
				"Bypass Music Manager to prevent silent assassin spawns. Uses original sound cue.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	NON_DISABLING = {
		["save"] = "cb_true_solo_non_disabling",
		["widget_type"] = "stepper",
		text = "Disablers Don't Disable",
		tooltip = "Disablers Don't Disable\n" ..
				"Allow player to attack or push while being disabled.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	NO_LOOT_DICE = {
		["save"] = "cb_true_solo_no_loot_dice",
		["widget_type"] = "stepper",
		text = "No Loot Dice",
		tooltip = "No Loot Dice\n" ..
				"Spawn no loot dice in true solo mode.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	NO_LORE_PAGE = {
		["save"] = "cb_true_solo_no_lore_page",
		["widget_type"] = "stepper",
		text = "No Lore Page",
		tooltip = "No Lore Page\n" ..
				"Spawn no lore page in true solo mode.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	OBJECTIVE_DEFENSE_DAMAGE_DIVISOR = {
		["save"] = "cb_true_solo_objective_defense_damage_divisor",
		["widget_type"] = "slider",
		["text"] = "Objective Defense Damage Divisor",
		["tooltip"] =  "Objective Defense Damage Divisor\n" ..
			"Reduces damage to wards / wells / generators by rats.",
		["range"] = {1, 20},
		["default"] = 1,
	},
	KRENCH_DMG_TAKEN = {
		["save"] = "cb_true_solo_krench_dmg_taken",
		["widget_type"] = "dropdown",
		["text"] = "Krench Damage Taken Multiplier",
		["tooltip"] =  "Krench Damage Taken Multiplier\n" ..
			"Krench will take damage multiplied by a value.",
		["value_type"] = "number",
		["options"] = {
			{text = "1x", value = 1},
			{text = "1.75x", value = 2},
			{text = "2.5x", value = 3},
		},
		["default"] = 1, -- 1x
	},
}

TrueSolo = TrueSolo or {}
TrueSolo.ogres = TrueSolo.ogres or {}

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

--- shrink or increase horde size
local function adjust_horde_sizes(horde_ratio)
	if not Mods.CurrentHordeSettings_compositions_backup then
	    Mods.CurrentHordeSettings_compositions_backup = {}
	end

	if not CurrentHordeSettings.compositions then
		return
		--CurrentHordeSettings.compositions = HordeSettings.default.compositions
	end

	for event_name, event_table in pairs(CurrentHordeSettings.compositions) do
	    local event_table_length = tablelength(event_table)
	    local index = 0
	    for event_table_index, event_table_value in pairs(event_table) do
	        index = index + 1
	        if index < event_table_length then
	            for table_with_breeds_index, table_with_breeds in pairs(event_table_value) do
	                if type(table_with_breeds) == "table" then
	                    for breed_index, breed_value in pairs(table_with_breeds) do
	                        if type(breed_value) == "table" then
	                            for breed_name, breed_num in pairs(breed_value) do
	                                if type(breed_num) == "number" then
	                                    local key = "CurrentHordeSettings.compositions['"..event_name.."']["..event_table_index.."]['"..table_with_breeds_index.."']["..breed_index.."]["..breed_name.."]"
	                                    if not Mods.CurrentHordeSettings_compositions_backup[key] then
	                                        Mods.CurrentHordeSettings_compositions_backup[key] = CurrentHordeSettings.compositions[event_name][event_table_index][table_with_breeds_index][breed_index][breed_name]
	                                    end
	                                    local new_breed_num = math.ceil(Mods.CurrentHordeSettings_compositions_backup[key] * horde_ratio)
	                                    loadstring(key.." = "..tostring(new_breed_num))()
	                                end
	                            end
	                        elseif type(breed_value) == "number" then
	                            local key = "CurrentHordeSettings.compositions['"..event_name.."']["..event_table_index.."]['"..table_with_breeds_index.."']["..breed_index.."]"
	                            if not Mods.CurrentHordeSettings_compositions_backup[key] then
	                                Mods.CurrentHordeSettings_compositions_backup[key] = CurrentHordeSettings.compositions[event_name][event_table_index][table_with_breeds_index][breed_index]
	                            end
	                            local new_breed_num = math.ceil(Mods.CurrentHordeSettings_compositions_backup[key] * horde_ratio)
	                            loadstring(key.." = "..tostring(new_breed_num))()
	                        end
	                    end
	                end
	            end
	        end
	    end
	end
end

--- mod logic, mod menu options changes tracking and autokill bots on round start
Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, ...)
	func(self, ...)

	for i, ogre in ipairs(TrueSolo.ogres) do
		if not Unit.alive(ogre) then
			table.remove(TrueSolo.ogres, i)
		end
	end

	local true_solo_enabled = user_setting(MOD_SETTINGS.ENABLED.save)
	--local skip_cutscenes_enabled = user_setting(MOD_SETTINGS.SKIP_CUTSCENES.save)

	local horde_size_ratio = user_setting(MOD_SETTINGS.HORDE_SIZE.save)
	local ratio = true_solo_enabled and horde_size_ratio / 100 or 1

	-- adjust hordes when true solo mode gets toggled
	if true_solo_enabled ~= rawget(_G, "_true_solo_mode_enabled") then
		adjust_horde_sizes(ratio)
		rawset(_G, "_true_solo_mode_enabled", true_solo_enabled)
	end
--[[
	-- adjust cutscene skip when true solo mode and skip cutscenes are changed in mod menu options
	if skip_cutscenes_enabled ~= rawget(_G, "_skip_cutscenes_enabled") then
		script_data.skippable_cutscenes = true_solo_enabled and skip_cutscenes_enabled or false
		rawset(_G, "_skip_cutscenes_enabled", skip_cutscenes_enabled)
	end
--]]
	if not self.last_horde_size_ratio then
		self.last_horde_size_ratio = horde_size_ratio
	end
	if true_solo_enabled and self.last_horde_size_ratio ~= horde_size_ratio then
		adjust_horde_sizes(horde_size_ratio / 100)
	end

	self.last_horde_size_ratio = horde_size_ratio
	if self.adjust_hordes_next_round_start == nil then
		self.adjust_hordes_next_round_start = true
	end

	if true_solo_enabled then
		local game_mode_manager = Managers.state.game_mode
		if game_mode_manager then
			local round_started = game_mode_manager.is_round_started(game_mode_manager)

			if not round_started then
				if self.adjust_hordes_next_round_start then
					adjust_horde_sizes(ratio)
					self.adjust_hordes_next_round_start = false
				end

				-- for _, player in pairs(Managers.player:bots()) do
					-- local status_extension = nil
					-- if player.player_unit then
						-- status_extension = ScriptUnit.extension(player.player_unit, "status_system")
					-- end
					-- if status_extension and not status_extension.is_ready_for_assisted_respawn(status_extension) then
						-- StatusUtils.set_dead_network(player.player_unit, true)
					-- end
				-- end
			else
				self.adjust_hordes_next_round_start = true
			end
		end
	end
end)

--edit--
-- Mods.hook.set(mod_name, "RespawnHandler.update", function(func, self, dt, t, player_statuses)
	-- if user_setting(MOD_SETTINGS.ENABLED.save) then
		-- for _, status in ipairs(player_statuses) do
			-- local peer_id = status.peer_id
			-- local local_player_id = status.local_player_id

			-- if peer_id or local_player_id then
				-- local player = Managers.player:player(peer_id, local_player_id)

				-- if status.health_state == "dead" and not status.ready_for_respawn and status.respawn_timer and status.respawn_timer < t and player.bot_player then
					-- status.respawn_timer = t + 1
				-- end
			-- end
		-- end
	-- end

	-- return func(self, dt, t, player_statuses)
-- end)
--edit--

--- delay horde while ogre alive
Mods.hook.set(mod_name, "ConflictDirector.update_horde_pacing", function (func, self, t, dt)
	if not user_setting(MOD_SETTINGS.ENABLED.save) or not user_setting(MOD_SETTINGS.NO_HORDES_WHEN_OGRE_ALIVE.save) then
		return func(self, t, dt)
	end

	if #TrueSolo.ogres > 0 and self._next_horde_time and self._next_horde_time < t then
		self._next_horde_time = t + 1
	end

	return func(self, t, dt)
end)

--- ogre damage taken modifier
local ORGE_DMG_TAKEN_1 = 1
local ORGE_DMG_TAKEN_2 = 2
local ORGE_DMG_TAKEN_3 = 3

--edit--
local KRENCH_DMG_TAKEN_1 = 1
local KRENCH_DMG_TAKEN_2 = 2
local KRENCH_DMG_TAKEN_3 = 3
--edit--

Mods.hook.set(mod_name, "DamageUtils.add_damage_network", function(func, attacked_unit, attacker_unit, original_damage_amount, ...)
	if not user_setting(MOD_SETTINGS.ENABLED.save) then
		return func(attacked_unit, attacker_unit, original_damage_amount, ...)
	end

	local breed = Unit.get_data(attacked_unit, "breed")
	if breed ~= nil then
		if breed.name == "skaven_rat_ogre" then
			local damage_amount = original_damage_amount
			local method_used = user_setting(MOD_SETTINGS.ORGE_DMG_TAKEN.save)
			if method_used == ORGE_DMG_TAKEN_2 then
				damage_amount = damage_amount * 1.75
			elseif method_used == ORGE_DMG_TAKEN_3 then
				damage_amount = damage_amount * 2.5
			end
			return func(attacked_unit, attacker_unit, damage_amount, ...)
		end
		
--edit--
		if breed.name == "skaven_storm_vermin_champion" then
			local damage_amount = original_damage_amount
			local method_used = user_setting(MOD_SETTINGS.KRENCH_DMG_TAKEN.save)
			if method_used == KRENCH_DMG_TAKEN_2 then
				damage_amount = damage_amount * 1.75
			elseif method_used == KRENCH_DMG_TAKEN_3 then
				damage_amount = damage_amount * 2.5
			end
			return func(attacked_unit, attacker_unit, damage_amount, ...)
		end
--edit--
	end

	return func(attacked_unit, attacker_unit, original_damage_amount, ...)
end)

--- specials ratio
local SPECIALS_RATIO_DEFAULT = 1
local SPECIALS_RATIO_LEAST_DISABLERS = 2
local SPECIALS_RATIO_NO_DISABLERS = 3
local SPECIALS_RATIO_LESS_DISABLERS = 4

local ai_utils_unit_alive = AiUtils.unit_alive
local player_and_bot_positions = PLAYER_AND_BOT_POSITIONS

--Xq's version 2
local function get_new_special(breeds, orig_breed)
	local specials_ratio_method = user_setting(MOD_SETTINGS.SPECIALS_RATIO.save)
	if not user_setting(MOD_SETTINGS.ENABLED.save) or specials_ratio_method == SPECIALS_RATIO_DEFAULT then
		return orig_breed
	end
	
	if not orig_breed then
		return orig_breed
	end
	
	if #breeds == 0 then
		return orig_breed
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
	
	local disablers =
	{
		skaven_pack_master				= true,
		skaven_gutter_runner			= true,
		skaven_poison_wind_globadier	= false,
		skaven_ratling_gunner			= false,
	}
	
	if disablers[orig_breed] == nil then
		return orig_breed	-- return original breed name if its a non-special
	end
	
	-- breed list divided into disablers / non disablers
	-- data is table {breed_name, allowed}
	local special_breeds =
	{
		disablers = {},
		not_disablers = {},
	}
	
	local MAX_COUNT_BREED			= 2
	local allowed_disablers			= {}
	local allowed_non_disablers		= {}
	local disabler_pool				= {}
	local non_disabler_pool			= {}
	local new_disabler_allowed		= false
	local new_non_disabler_allowed	= false
	
	for key,data in pairs(breeds) do
		local name = data
		local is_special = disablers[name] ~= nil
		if is_special then
			-- local count		= get_spawned_rats_by_breed(name)
			local spawned_units	= get_spawned_rats_by_breed(name)
			local count	= #spawned_units
			
			local allowed = count < MAX_COUNT_BREED
			if disablers[name] then
				if allowed then
					new_disabler_allowed	= true
					allowed_disablers[name]	= true
					table.insert(disabler_pool, name)
				end
				table.insert(special_breeds.disablers, name)
			else
				if allowed then
					-- new_disabler_allowed		= true
					new_non_disabler_allowed		= true
					allowed_non_disablers[name]	= true
					table.insert(non_disabler_pool, name)
				end
				table.insert(special_breeds.not_disablers, name)
			end
		end
	end
	
	
	-- local specials_ratio_method	= user_setting(MOD_SETTINGS.SPECIALS_RATIO.save)
	local orig_disabler_chance	= #special_breeds.disablers / (#special_breeds.disablers + #special_breeds.not_disablers)
	local disabler_chance		= orig_disabler_chance
	
	if specials_ratio_method == SPECIALS_RATIO_LESS_DISABLERS then
		disabler_chance = 0.15
	elseif specials_ratio_method == SPECIALS_RATIO_LEAST_DISABLERS then
		disabler_chance = 0.1
	elseif specials_ratio_method == SPECIALS_RATIO_NO_DISABLERS then
		disabler_chance = 0
	else -- default
		disabler_chance	= orig_disabler_chance
	end
	
	local requred_conversion_chance = 1 - (disabler_chance / orig_disabler_chance)
	
	local new_breed				= orig_breed
	local orig_breed_allowed	= allowed_disablers[orig_breed] or allowed_non_disablers[orig_breed]
	local any_special_allowed	= new_disabler_allowed or new_non_disabler_allowed
	
	-- original being not a special is handled before
	
	if not any_special_allowed then
		-- no new spedial is allowed (all breed slots full)
		return nil
	end
	
	if allowed_non_disablers[orig_breed] then
		-- original is not a disabler and is allowed
		return orig_breed
	end
	
	if not disablers[orig_breed] then
		-- original is not a disabler but not allowed
		if new_non_disabler_allowed then
			-- there is free slots for some other non-disablers >> convert
			local index	= math.ceil(math.random() * #non_disabler_pool)
			index		= (index == 0 and 1) or index
			return		non_disabler_pool[index]
			--
		elseif new_disabler_allowed then
			-- no slots available for non-disablers but disabler slots are avaialble >> convert
			local index	= math.ceil(math.random() * #disabler_pool)
			index		= (index == 0 and 1) or index
			return		disabler_pool[index]
			--
		else
			-- this shold never trigger
			EchoConsole("THIS SHOULD NOT TRIGGER")
			return nil
		end
	end
	
	-- at this point the original breed is a disabler special
	
	if not new_disabler_allowed then
		-- no new disablers allowed >> get a new non-disabler
		local index	= math.ceil(math.random() * #non_disabler_pool)
		index		= (index == 0 and 1) or index
		return		non_disabler_pool[index]
	elseif not new_non_disabler_allowed then
		-- no new non-disabler is allowed
		if allowed_disablers[orig_breed] then
			-- the original breed is ok >> return it
			return orig_breed
		else
			-- roll new disabler breed
			local index	= math.ceil(math.random() * #disabler_pool)
			index		= (index == 0 and 1) or index
			return		disabler_pool[index]
		end
	end
	
	-- at this point the original breed is a disabler and there should be both allowed disablers and non-disablers
	
	-- the special would be a disabler
	local rand = math.random()
	if rand < requred_conversion_chance then
		-- if conversion roll succeeded, convert it to non-disabler
		local index	= math.ceil(math.random() * #non_disabler_pool)
		index		= (index == 0 and 1) or index
		new_breed	= non_disabler_pool[index]
	end
	
	return new_breed
end

--Xq's version 1
--[[
local function get_new_special(breeds, orig_breed)
	local specials_ratio_method = user_setting(MOD_SETTINGS.SPECIALS_RATIO.save)
	if not user_setting(MOD_SETTINGS.ENABLED.save) or specials_ratio_method == SPECIALS_RATIO_DEFAULT then
		return orig_breed
	end

	if not orig_breed then
		return orig_breed
	end
	
	if #breeds == 0 then
		return orig_breed
	end
	
	local disablers =
	{
		skaven_pack_master				= true,
		skaven_gutter_runner			= true,
		skaven_poison_wind_globadier	= false,
		skaven_ratling_gunner			= false,
	}
	
	if disablers[orig_breed] == nil then
		return orig_breed
	end
	
	local special_breeds =
	{
		disablers = {},
		not_disablers = {},
	}
	
	for key,data in pairs(breeds) do
		local name = data
		local is_special = disablers[name] ~= nil
		if is_special then
			if disablers[name] then
				table.insert(special_breeds.disablers, name)
			else
				table.insert(special_breeds.not_disablers, name)
			end
		end
	end
	
	if #special_breeds.disablers == 0 then
		return orig_breed
	end
	
	local disabler_chance = 0.5
	
	if specials_ratio_method == SPECIALS_RATIO_LESS_DISABLERS then
		disabler_chance = 0.15
	elseif specials_ratio_method == SPECIALS_RATIO_LEAST_DISABLERS then
		disabler_chance = 0.1
	elseif specials_ratio_method == SPECIALS_RATIO_NO_DISABLERS then
		disabler_chance = 0
	else -- default
		return orig_breed
	end
	
	local orig_disabler_chance = #special_breeds.disablers / (#special_breeds.disablers + #special_breeds.not_disablers)
	local requred_conversion_chance = 1 - (disabler_chance / orig_disabler_chance)
	
	local new_breed = orig_breed
	if disablers[orig_breed] then
		-- the special would be a disabler
		local rand = math.random()
		if rand < requred_conversion_chance then
			-- if conversion roll succeeded, convert it to non-disabler
			local index	= math.ceil(math.random() * #special_breeds.not_disablers)
			index		= (index == 0 and 1) or index
			new_breed	= special_breeds.not_disablers[index]
		end
	end
	
	return new_breed
end
--]]

-- local function get_new_special(breeds, orig_breed)
	-- local specials_ratio_method = user_setting(MOD_SETTINGS.SPECIALS_RATIO.save)
	-- if not user_setting(MOD_SETTINGS.ENABLED.save) or specials_ratio_method == SPECIALS_RATIO_DEFAULT then
		-- return orig_breed
	-- end

	-- local orig_breed_chance = 0
	-- local orig_disabler_chance = 0
	-- local new_disabler_chance = 0
	
	-- if #breeds == 0 then
		-- return nil
	-- elseif #breeds > 0 then
		-- orig_breed_chance = (1 / #breeds) * 100
	-- end
	
	-- local count = 0
	-- for _, breed_name in pairs(breeds) do
		-- if breed_name == "skaven_pack_master" or breed_name == "skaven_gutter_runner" then
			-- count = count + 1
		-- end
	-- end

	-- orig_disabler_chance = (count / #breeds) * 100

	-- if orig_disabler_chance == 0 then
		-- return orig_breed
	-- end
	
	-- if specials_ratio_method == SPECIALS_RATIO_LESS_DISABLERS then
		-- new_disabler_chance = 15
	-- elseif specials_ratio_method == SPECIALS_RATIO_LEAST_DISABLERS then
		-- new_disabler_chance = 10
	-- elseif specials_ratio_method == SPECIALS_RATIO_NO_DISABLERS then
		-- new_disabler_chance = 0
	-- end
	
	-- local rand = math.random(100)	-- range is [1,100]
	-- local switch_chance = 0
	-- local new_breed = nil

	-- if orig_breed == "skaven_pack_master" or orig_breed == "skaven_gutter_runner" then
		-- switch_chance = math.ceil((orig_disabler_chance - new_disabler_chance) / orig_disabler_chance)
		
		-- if rand <= switch_chance then
			-- if rand < 51 then
				-- new_breed = "skaven_ratling_gunner"
			-- else
				-- new_breed = "skaven_poison_wind_globadier"
			-- end
		-- end
	-- end
	
	-- return new_breed
-- end

Mods.hook.set(mod_name, "SpecialsPacing.select_breed_functions.get_random_breed", function (func, slots, breeds, method_data)
	-- local specials_ratio_method = user_setting(MOD_SETTINGS.SPECIALS_RATIO.save)
	-- if not user_setting(MOD_SETTINGS.ENABLED.save) or specials_ratio_method == SPECIALS_RATIO_DEFAULT then
		-- return func(slots, breeds, method_data)
	-- end

	local orig_breed = func(slots, breeds, method_data)
	local new_breed = get_new_special(breeds, orig_breed)
	
	-- if specials_ratio_method == SPECIALS_RATIO_LESS_DISABLERS then
		-- if rand < 16 then
			-- breed = "skaven_pack_master"
		-- elseif rand < 31 then
			-- breed = "skaven_gutter_runner"
		-- elseif rand < 66 then
			-- breed = "skaven_ratling_gunner"
		-- else
			-- breed = "skaven_poison_wind_globadier"
		-- end
	-- elseif specials_ratio_method == SPECIALS_RATIO_LEAST_DISABLERS then
		-- if rand < 11 then
			-- breed = "skaven_pack_master"
		-- elseif rand < 21 then
			-- breed = "skaven_gutter_runner"
		-- elseif rand < 61 then
			-- breed = "skaven_ratling_gunner"
		-- else
			-- breed = "skaven_poison_wind_globadier"
		-- end
	-- elseif specials_ratio_method == SPECIALS_RATIO_NO_DISABLERS then
		-- if rand < 51 then
			-- breed = "skaven_ratling_gunner"
		-- else
			-- breed = "skaven_poison_wind_globadier"
		-- end
	-- end

	return new_breed or orig_breed
end)

Mods.hook.set(mod_name, "SpecialsPacing.specials_by_time_window", function (func, self, t, specials_settings, method_data, slots, spawn_queue, alive_specials)
	if self._specials_timer < t then
		local num_alive = #alive_specials
		local i = 1

		while num_alive >= i do
			local unit = alive_specials[i]

			if not Unit.alive(unit) then
				alive_specials[i] = alive_specials[num_alive]
				alive_specials[num_alive] = nil
				num_alive = num_alive - 1
			else
				i = i + 1
			end
		end

		local max_specials = specials_settings.max_specials

		if num_alive + #slots <= 0 then
			local lull_time = ConflictUtils.random_interval(method_data.lull_time)
			local breeds = specials_settings.breeds

			if method_data.even_out_breeds and max_specials > 1 then
				local breed_mix = table.clone(breeds)
				local j = 0

				for i = 1, max_specials, 1 do
					if j <= 0 then
						table.shuffle(breed_mix)

						j = #breed_mix
					end
--edit--
					-- slots[i] = {
						-- breed = breed_mix[j]
					-- }
					local orig_breed = breed_mix[j]
					local new_breed = get_new_special(breed_mix, orig_breed)
					slots[i] = {
						breed = new_breed or orig_breed
					}
--edit--
					j = j - 1
				end
			else
				for i = 1, max_specials, 1 do
--edit--
					-- slots[i].breed = breeds[Math.random(1, #breeds)]
					
					local orig_breed = breeds[Math.random(1, #breeds)]
					local new_breed = get_new_special(breeds, orig_breed)
					slots[i].breed = new_breed or orig_breed
--edit--
				end
			end

			local spawn_interval = ConflictUtils.random_interval(method_data.spawn_interval)
			local sum = 0
			local time_list = {}

			for i = 1, max_specials, 1 do
				local time = Math.random()
				sum = sum + time
				time_list[i] = sum
			end

			local last_time = nil

			for i = 1, max_specials, 1 do
				local index = max_specials - i + 1
				last_time = t + time_list[index] / sum * spawn_interval + lull_time
				slots[i].time = last_time
			end

			self._specials_timer = t + lull_time

			table.clear(spawn_queue)
		end

		local slot = slots[#slots]

		if slot and slot.time < t then
			slots[#slots] = nil
			spawn_queue[#spawn_queue + 1] = slot
		end

		self._specials_timer = t + 1
	end
end)

--- hide non-player ui frames
-- Mods.hook.set(mod_name, "UnitFrameUI.draw", function (func, self, dt)
	-- local true_solo_mode_enabled = user_setting(MOD_SETTINGS.ENABLED.save)
	-- if self.last_true_solo_mode_enabled == nil then
		-- self.last_true_solo_mode_enabled = true_solo_mode_enabled
	-- end
	-- if self.last_true_solo_mode_enabled ~= true_solo_mode_enabled then
		-- if not true_solo_mode_enabled and Managers.state.game_mode and Managers.state.game_mode._game_mode_key ~= "inn" then
			-- self.set_visible(self, true)
			-- self.set_dirty(self)
		-- end
	-- end

	-- self.last_true_solo_mode_enabled = true_solo_mode_enabled

	-- if not true_solo_mode_enabled then
		-- return func(self, dt)
	-- end

	-- local portait_static_widget = self._widgets["portait_static"]
	-- if self.peer_id and self.peer_id == Network.peer_id() and portait_static_widget.content.player_level and portait_static_widget.content.player_level ~= "BOT" then
		-- return func(self, dt)
	-- end

	-- local hide_other_frames = user_setting(MOD_SETTINGS.HIDE_OTHER_FRAMES.save)
	-- if self._is_visible ~= not hide_other_frames then
		-- self.set_visible(self, not hide_other_frames)
		-- self.set_dirty(self)
	-- end

	-- return func(self, dt)
-- end)
-- Mods.hook.front(mod_name, "UnitFrameUI.draw")

--- change assassin spawn sound
Mods.hook.set(mod_name, "ConflictDirector.spawn_unit", function (func, self, breed, ...)
	if breed.name == "skaven_rat_ogre" then
		local ogre = func(self, breed, ...)
		table.insert(TrueSolo.ogres, ogre)
		return ogre
	end

	local assassin_spawn_sound_enabled = user_setting(MOD_SETTINGS.ASSASSIN_SPAWN_SOUND.save)
	if not user_setting(MOD_SETTINGS.ENABLED.save) or not assassin_spawn_sound_enabled then
		Breeds.skaven_gutter_runner.combat_spawn_stinger = "enemy_gutterrunner_stinger"
		return func(self, breed, ...)
	end

	Breeds.skaven_gutter_runner.combat_spawn_stinger = nil

	if breed.name == "skaven_gutter_runner" and assassin_spawn_sound_enabled then
		TerrorEventBlueprints.custom_gutter_warning = {
			{
				"play_stinger",
				stinger_name = "Play_enemy_stormvermin_champion_electric_floor"
			},
		}
		Managers.state.conflict:start_terror_event("custom_gutter_warning")
	end

	return func(self, breed, ...)
end)

--- skip cutscenes, ported from the Mod Framework
--[[
Mods.hook.set(mod_name, "CutsceneSystem.skip_pressed", function (func, self)
	rawset(_G, "_skip_cutscenes_skip_next_fade", true)

	func(self)
end)


Mods.hook.set(mod_name, "CutsceneSystem.flow_cb_cutscene_effect", function (func, self, name, flow_params)
	if rawget(_G, "_skip_cutscenes_skip_next_fade") and name == "fx_fade" then
		rawset(_G, "_skip_cutscenes_skip_next_fade", false)
		return
	end

	func(self, name, flow_params)
end)

-- Don't restore player input if player already has active input
Mods.hook.set(mod_name, "CutsceneSystem.flow_cb_deactivate_cutscene_logic", function (func, self, event_on_deactivate)
	-- If a popup is open or cursor present, skip the input restore
	if ShowCursorStack.stack_depth > 0 or Managers.popup:has_popup() then
		if event_on_deactivate then
			local level = LevelHelper:current_level(self.world)
			Level.trigger_event(level, event_on_deactivate)
		end

		self.event_on_skip = nil
	else
		func(self, event_on_deactivate)
	end
end)

-- Prevent invalid cursor pop crash if another mod interferes
Mods.hook.set(mod_name, "ShowCursorStack.pop", function (func)
	-- Catch a starting depth of 0 or negative cursors before pop
	if ShowCursorStack.stack_depth <= 0 then
		EchoConsole("[Warning]: Attempt to remove non-existent cursor.")
	else
		func()
	end
end)
--]]

Mods.hook.set(mod_name, "HordeSpawner.spawn_unit", function (func, self, hidden_spawn, breed_name, goal_pos, horde, ...)
	if breed_name == nil then
		return
	end

	return func(self, hidden_spawn, breed_name, goal_pos, horde, ...)
end)

-- VMF way to get rid of bots

local function set_bots()
	local active = user_setting(MOD_SETTINGS.ENABLED.save)
	
	if not Managers.player.is_server then
		active = false
	end
	
	if active then
		script_data.cap_num_bots = 0
		script_data.ai_bots_disabled = true
	else
		script_data.cap_num_bots = nil
		script_data.ai_bots_disabled = nil
	end
end

Mods.hook.set(mod_name, "OptionsView.on_exit", function(func, ...)
	func(...)
	
	set_bots()
end)

Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, ...)
	func(...)
	
	set_bots()
end)

--Disable rush intervention

Mods.hook.set(mod_name, "ConflictDirector.handle_alone_player", function(func, self, t)
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players > 1 or not user_setting(MOD_SETTINGS.ENABLED.save) then
		return func(self, t)
	end
end)

--Defeat condition

Mods.hook.set(mod_name, "SpawnManager.all_humans_dead", function (func, self)
	local human_players = Managers.player:human_players()
	local num_players = 0
	
	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.ENABLED.save) then		
		local health_state = self._player_statuses[1].health_state

		return not (health_state ~= "dead" and health_state ~= "respawn" and health_state ~= "respawning")
	else
		return func(self)
	end
end)

Mods.hook.set(mod_name, "SpawnManager.all_players_disabled", function (func, self)
	local human_players = Managers.player:human_players()
	local num_players = 0
	
	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.ENABLED.save) then
		local health_state = self._player_statuses[1].health_state

		return not (health_state == "alive")
	else
		return func(self)
	end
end)

--Scoreboard show only humans (TO DO: fix scavenger data display) (Update: Fixed in Scordboard.lua)

Mods.hook.set(mod_name, "ScoreboardUI.create_ui_elements", function(func, self)
	func(self)
	
	local human_players = Managers.player:human_players()
	local num_players = 0
	
	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if Managers.player.is_server and user_setting(MOD_SETTINGS.ENABLED.save) then
		local widgets = self.player_entry_widgets
	
		for i, widget in pairs(widgets) do
			-- EchoConsole(widget.content.player_name)
			if i > num_players then
			-- if i > num_players and widget.content.player_name == "unknown_player" then
				-- Hide result
				
				--Record for attempt scavenger scorboard fix
				-- widget.style.title_text.text_color_orig = widget.style.title_text.text_color[1]
				-- widget.style.score_text.text_color_orig = widget.style.score_text.text_color[1]
				-- widget.style.icon.color_orig = widget.style.icon.color[1]
				-- widget.style.highlight.color_orig = widget.style.highlight.color[1]
				
				widget.style.title_text.text_color[1] = 0
				widget.style.score_text.text_color[1] = 0
				widget.style.icon.color[1] = 0
				widget.style.highlight.color[1] = 0
			end
		end
	end
end)

--Instant Defeat (and Instant Restart)
--[[
Mods.hook.set(mod_name, "GameModeAdventure.evaluate_end_conditions", function(func, self, round_started, dt, t)
	local human_players = Managers.player:human_players()
	local num_players = 0
	
	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if not user_setting(MOD_SETTINGS.ENABLED.save) or num_players > 1 then
		return func(self, round_started, dt, t)
	end

	if self.lost_condition_timer then
		self.lost_condition_timer = t - 1
	end
	
	local ended, reason = func(self, round_started, dt, t)
	
	-- if ended and reason == "lost" then
		-- return ended, "reload"
	-- end

	return ended, reason
end)
--]]

--Bypass Music Manager to play assassin sound cue

Mods.hook.set(mod_name, "MusicManager.music_trigger", function(func, self, music_player, event)	
	local human_players = Managers.player:human_players()
	local num_players = 0
	
	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	-- if event ~= "enemy_gutterrunner_stinger" or music_player ~= "combat_music" or not user_setting(MOD_SETTINGS.ENABLED.save) or not user_setting(MOD_SETTINGS.ASSASSIN_SOUND_2D.save) or num_players > 1 then
	if event ~= "enemy_gutterrunner_stinger" or music_player ~= "combat_music" or not user_setting(MOD_SETTINGS.ASSASSIN_SOUND_2D.save) or num_players > 1 then
		return func(self, music_player, event)
	else
		local wwise_world = self._wwise_world

		WwiseWorld.trigger_event(wwise_world, event)
		
		-- EchoConsole("wwise_world enemy_gutterrunner_stinger")
	end
end)

-- Mods.hook.set(mod_name, "MusicManager.music_trigger", function(func, self, music_player, event)	
	-- local human_players = Managers.player:human_players()
	-- local num_players = 0
	
	-- for peer_id, player in pairs(human_players) do
		-- num_players = num_players + 1
	-- end
	
	-- if event ~= "enemy_gutterrunner_stinger" or num_players > 1 then
		-- return func(self, music_player, event)
	-- else
		-- local wwise_world = self._wwise_world

		-- WwiseWorld.trigger_event(wwise_world, event)
	-- end
-- end)

--Play hero warning dialogue on assassin and packmaster spawns.

local breed_name_to_dialogue_lookup = {
	skaven_gutter_runner = "_gameplay_hearing_a_gutter_runner",
	skaven_pack_master = "_gameplay_seeing_a_skaven_slaver",
}

Mods.hook.set(mod_name, "BTSpawningAction.enter", function(func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	
	if not user_setting(MOD_SETTINGS.ASSASSIN_HERO_WARNING.save) or not user_setting(MOD_SETTINGS.ENABLED.save) then
		return
	end

	local dialogue = breed_name_to_dialogue_lookup[blackboard.breed.name]
	if dialogue then
		Managers.state.entity:system("dialogue_system"):force_play_hero_warning(dialogue)
	end
end)

Mods.hook.set(mod_name, "DialogueSystem.update_currently_playing_dialogues", function(func, self, dt)
	if not user_setting(MOD_SETTINGS.ASSASSIN_HERO_WARNING.save) or not user_setting(MOD_SETTINGS.ENABLED.save) then
		return func(self, dt)
	end

	pcall(func, self, dt)
end)

local profile_name_to_short_name = {
	empire_soldier = "pes",
	witch_hunter = "pwh",
	bright_wizard = "pbw",
	dwarf_ranger = "pdr",
	wood_elf = "pwe",
}

DialogueSystem.force_play_hero_warning = function(self, dialogue_part)
	pcall(function()
		if not self.is_server then
			return
		end

		-- EchoConsole("force_play_hero_warning")

		local unit = Managers.player:local_player().player_unit
		local profile_name = ScriptUnit.extension(unit, "dialogue_system").context.player_profile
		local short_name = profile_name_to_short_name[profile_name]
		local dialogue_key = short_name..dialogue_part
		if self.dialogues[dialogue_key] then
			local dialogue_id = DialogueLookup[dialogue_key]
			local network_manager = Managers.state.network

			local go_id, is_level_unit = network_manager:game_object_or_level_id(unit)
			local num_lines = self.dialogues[dialogue_key].sound_events_n
			local line_index = math.random(num_lines)
			self:rpc_interrupt_dialogue_event(nil, go_id, is_level_unit)
			self:rpc_play_dialogue_event(nil, go_id, is_level_unit, dialogue_id, line_index)
		end
	end)
end

--Non-disabling (EasierTruoSolo.lua)

-- Checks whether we are in 'true solo' mode (no human allies, all bots dead).
local function is_true_solo(player_unit)
	-- for _, player in pairs(Managers.player:players()) do
		-- local unit = player.player_unit
		-- if unit ~= player_unit then
			-- if not player.bot_player then
				-- return false
			-- end
			-- local status_extn = unit and ScriptUnit.extension(unit, "status_system")
			-- if status_extn and not (status_extn:is_dead() or status_extn:is_ready_for_assisted_respawn()) then
				-- return false
			-- end
		-- end
	-- end
	-- return true
	
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.NON_DISABLING.save) and user_setting(MOD_SETTINGS.ENABLED.save) then
		return true
	end
	
	return false
end

-- Performs the actions required on each update to allow use of player weapons

local function perform_weapon_actions(state, unit)
	local status_extension = state.status_extension
	if status_extension._eztruesolo_enabled then
		if CharacterStateHelper.is_overcharge_exploding(status_extension) then
			state.csm:change_state("overcharge_exploding")
			return true
		end
		if CharacterStateHelper.is_block_broken(status_extension) then
			status_extension:set_block_broken(false)
			local movement_settings_table = PlayerUnitMovementSettings.get_movement_settings_table(unit)
			state.csm:change_state("stunned", movement_settings_table.stun_settings.parry_broken)
			return true
		end
 
		local input_extension = state.input_extension
		local inventory_extension = state.inventory_extension
		CharacterStateHelper.update_weapon_actions(Managers.time:time("game"), unit, input_extension, inventory_extension, state.damage_extension)
		CharacterStateHelper.reload(input_extension, inventory_extension, status_extension)
	end
	return true
end
 
Mods.hook.set(mod_name, "GenericStatusExtension.is_disabled", function(orig_func, self)
	if self._eztruesolo_enabled then
		-- remove checks for is_grabbed_by_pack_master, is_pounced_down
		return self.is_dead(self) or self.is_knocked_down(self) or self.get_is_ledge_hanging(self) or
			self.is_hanging_from_hook(self) or self.is_ready_for_assisted_respawn(self)
	else
		return orig_func(self)
	end
end)
 
Mods.hook.set(mod_name, "PlayerCharacterStatePouncedDown.on_enter", function(orig_func, self, unit, ...)
	orig_func(self, unit, ...)
	self.status_extension._eztruesolo_enabled = is_true_solo(unit)
end)
 
Mods.hook.set(mod_name, "PlayerCharacterStatePouncedDown.on_exit", function(orig_func, self, unit, ...)
	orig_func(self, unit, ...)
	self.status_extension._eztruesolo_enabled = false
end)
 
Mods.hook.set(mod_name, "PlayerCharacterStatePouncedDown.update", function(orig_func, self, unit, input, dt, context, t)
	orig_func(self, unit, input, dt, context, t)
 
	local status_extension = self.status_extension
	if CharacterStateHelper.is_pounced_down(status_extension) and not self.liberated then
		perform_weapon_actions(self, unit)
	end
end)
 
PlayerCharacterStateGrabbedByPackMaster.states.pack_master_dragging = {
	enter = function (parent, unit)
		parent.locomotion_extension:enable_script_driven_no_mover_movement()
 
		local inventory_extension = parent.inventory_extension
		if is_true_solo(unit) then
			parent.status_extension._eztruesolo_enabled = true
			parent.locomotion_extension:enable_rotation_towards_velocity(true)
 
			if inventory_extension.get_wielded_slot_name(inventory_extension) == "slot_packmaster_claw" then
				parent.inventory_extension:wield_previous_weapon()
			else
				CharacterStateHelper.show_inventory_3p(unit, true, true, Managers.player.is_server)
			end
		else
			if inventory_extension.get_wielded_slot_name(inventory_extension) ~= "slot_packmaster_claw" then
				inventory_extension.wield(inventory_extension, "slot_packmaster_claw", true)
			else
				CharacterStateHelper.show_inventory_3p(unit, true, true, Managers.player.is_server)
			end
		end
 
		CharacterStateHelper.play_animation_event_first_person(parent.first_person_extension, "move_bwd")
	end,
 
	run = perform_weapon_actions,
 
	leave = function (parent, unit)
		if parent.status_extension._eztruesolo_enabled then
			parent.status_extension._eztruesolo_enabled = false
			parent.inventory_extension:wield("slot_packmaster_claw", true)
		end
	end,
}

--Remove all loot dice

Mods.hook.set(mod_name, "DiceKeeper.chest_loot_dice_chance", function(func, self)
	-- return self._chest_loot_dice_chance or 0.05
	
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.NO_LOOT_DICE.save) and user_setting(MOD_SETTINGS.ENABLED.save) then
		return 0
	end
	
	return func(self)
end)

--Hide lorebook pages

Mods.hook.set(mod_name, "Pickups.lorebook_pages.lorebook_page.hide_func", function (func, statistics_db)
	local ret = func(statistics_db)
	
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.NO_LORE_PAGE.save) and user_setting(MOD_SETTINGS.ENABLED.save) then
		return true
	end
	
	-- Return original result
	return ret
end)

--Intensity System tweaks

Mods.hook.set(mod_name, "GenericStatusExtension.add_damage_intensity", function (func, self, percent_health_lost, damage_type)
	-- self.intensity = math.clamp(self.intensity + percent_health_lost * CurrentIntensitySettings.intensity_add_per_percent_dmg_taken * 100, 0, 100)
	-- self.intensity_decay_delay = CurrentIntensitySettings.decay_delay
	
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.ENABLED.save) then
		if user_setting(MOD_SETTINGS.DAMAGE_INTENSITY.save) == 2 then
			self.intensity = math.clamp(self.intensity + percent_health_lost * CurrentIntensitySettings.intensity_add_per_percent_dmg_taken * 50, 0, 100)
			self.intensity_decay_delay = CurrentIntensitySettings.decay_delay
		elseif user_setting(MOD_SETTINGS.DAMAGE_INTENSITY.save) == 3 then
			self.intensity = math.clamp(self.intensity, 0, 100)
			self.intensity_decay_delay = CurrentIntensitySettings.decay_delay
		else	-- default
			return func(self, percent_health_lost, damage_type)
		end
	else
		return func(self, percent_health_lost, damage_type)
	end
end)

Mods.hook.set(mod_name, "GenericStatusExtension.get_intensity", function (func, self)
	-- return self.intensity
	
	local ret = func(self)
	
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.ENABLED.save) then
		if user_setting(MOD_SETTINGS.DAMAGE_INTENSITY.save) == 2 then
			ret = ret + 6.25
		elseif user_setting(MOD_SETTINGS.DAMAGE_INTENSITY.save) == 3 then
			ret = ret + 12.5
		end
	end
	
	return ret
end)

Breeds.skaven_gutter_runner.run_on_spawn = function (unit, blackboard)
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.ENABLED.save) then
		if user_setting(MOD_SETTINGS.ASSASSIN_INTENSITY.save) == 2 then
			Managers.state.conflict:freeze_intensity_decay(10)
		end
	end
end

Breeds.skaven_gutter_runner.run_on_death = function (unit, blackboard)
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.ENABLED.save) then
		if user_setting(MOD_SETTINGS.ASSASSIN_INTENSITY.save) == 2 then
			Managers.state.conflict:freeze_intensity_decay(1)
		end
	end
end

Mods.hook.set(mod_name, "BTCrazyJumpAction.enter", function (func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	
	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.ENABLED.save) then
		if user_setting(MOD_SETTINGS.ASSASSIN_INTENSITY.save) == 2 then
			Managers.state.conflict:freeze_intensity_decay(10)
		end
	end
end)

--Reduce ward / well / generator damage

Mods.hook.set(mod_name, "DamageUtils.calculate_damage", function (func, damage_table, target_unit, attacker_unit, hit_zone_name, headshot_multiplier, backstab_multiplier, hawkeye_multiplier)
	local damage = func(damage_table, target_unit, attacker_unit, hit_zone_name, headshot_multiplier, backstab_multiplier, hawkeye_multiplier)

	local human_players = Managers.player:human_players()
	local num_players = 0

	for peer_id, player in pairs(human_players) do
		num_players = num_players + 1
	end
	
	if num_players <= 1 and user_setting(MOD_SETTINGS.ENABLED.save) then
		local target_type = target_unit and Unit.get_data(target_unit, "target_type")
		
		if target_type == "poison_well" or target_type == "wizard_destructible" then
			-- EchoConsole("true; damage = " .. damage)
			
			local divisor = user_setting(MOD_SETTINGS.OBJECTIVE_DEFENSE_DAMAGE_DIVISOR.save)
			
			damage = damage / divisor
			damage = math.max(damage, 0.25)
		else
			-- EchoConsole("false")
		end
	end
	
	return damage
end)

--- options
local function create_options()
	Mods.option_menu:add_group("true_solo_group", "True Solo")
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ENABLED, true)

	-- Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.HIDE_OTHER_FRAMES)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ASSASSIN_SPAWN_SOUND)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ASSASSIN_SOUND_2D)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ASSASSIN_HERO_WARNING)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.NO_HORDES_WHEN_OGRE_ALIVE)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ORGE_DMG_TAKEN)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.KRENCH_DMG_TAKEN)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.SPECIALS_RATIO)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.HORDE_SIZE)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.OBJECTIVE_DEFENSE_DAMAGE_DIVISOR)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.DAMAGE_INTENSITY)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ASSASSIN_INTENSITY)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.NON_DISABLING)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.NO_LOOT_DICE)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.NO_LORE_PAGE)
	-- Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.SKIP_CUTSCENES)
end

safe_pcall(create_options)