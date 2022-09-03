local mod_name = "SkipCutscenesIntro"

local user_setting = Application.user_setting
local set_user_setting = Application.set_user_setting

local MOD_SETTINGS = {
	ACTIVE = {
		["save"] = "cb_skip_level_cutscenes",
		["widget_type"] = "stepper",
		["text"] = "Skip Level Cutscenes",
		["tooltip"] =  "Skip Level Cutscenes\n" ..
			"Toggle skip level cutscenes on / off.\n\n" ..
			"Lets you skip the cutscenes at the beginning of a map by pressing [Space].",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
	MODE = {
		["save"] = "cb_skip_level_cutscenes_automatic",
		["widget_type"] = "stepper",
		["text"] = "Mode",
		["tooltip"] = "Toggle method of skipping cutscenes.\n" ..
			"Automatic will skip cutscenes by default; Manual uses ESC / Space.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Manual", value = false},
			{text = "Automatic", value = true}
		},
		["default"] = 1, -- Default first option is enabled. In this case Manual
	},
	NO_INTRO = {
		["save"] = "cb_skip_level_cutscenes_no_intro",
		["widget_type"] = "stepper",
		["text"] = "No Loading Screen Audio",
		["tooltip"] = "Skip Loading Screen Intro.\n" ..
			"Disable loading screen audio and subtitles.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
}

-- Variable to track the need to skip the fade effect
local skip_next_fade = false

-- Enable skippable cutscene development setting
script_data.skippable_cutscenes = true

--[[
	HOOKS
--]]
-- Automatically skip cutscenes if necessary
Mods.hook.set(mod_name, "CutsceneSystem.flow_cb_activate_cutscene_camera", function(func, self, camera_unit, transition_data, ingame_hud_enabled, letterbox_enabled)
	-- Skip cutscene if set to 'automatic'
	if user_setting(MOD_SETTINGS.MODE.save) then
		skip_next_fade = true
	else
		func(self, camera_unit, transition_data, ingame_hud_enabled, letterbox_enabled)
	end
end)

local do_not_play_event_on_skip = {
	dlc_challenge_wizard = true,		-- Trial of the Foolhardy
	dlc_survival_magnus = true,			-- Town Meeting
	dlc_survival_ruins = true,			-- The Fall
}

-- Automatically skip cutscenes if necessary
Mods.hook.set(mod_name, "CutsceneSystem.flow_cb_activate_cutscene_logic", function(func, self, player_input_enabled, event_on_activate, event_on_skip)
	-- Skip cutscene if set to 'automatic'
	if user_setting(MOD_SETTINGS.MODE.save) then
		if event_on_activate then
			local level = LevelHelper:current_level(self.world)
			Level.trigger_event(level, event_on_activate)
			-- EchoConsole("event_on_activate: " .. event_on_activate)
		end

		local level_key = nil
		local game_mode = Managers.state.game_mode

		if game_mode then
			level_key = game_mode:level_key()
		end
		
		-- if event_on_skip then
			-- local level = LevelHelper:current_level(self.world)
			-- Level.trigger_event(level, event_on_skip)
		-- end
		
		skip_next_fade = true
		
		if event_on_skip and level_key and not do_not_play_event_on_skip[level_key] then
			local level = LevelHelper:current_level(self.world)
			Level.trigger_event(level, event_on_skip)
			-- EchoConsole("event_on_skip: " .. event_on_skip)
		else
			local wwise_world = Managers.world:wwise_world(self.world)
			
			-- WwiseWorld.trigger_event(wwise_world, "hud_in_inventory_state_on")
			WwiseWorld.trigger_event(wwise_world, "hud_in_inventory_state_off")
		end
	else
		func(self, player_input_enabled, event_on_activate, event_on_skip)
	end
end)

-- Mods.hook.set(mod_name, "flow_callback_activate_cutscene_logic", function(func, params)
	-- local player_input_enabled = not not params.player_input_enabled
	-- local event_on_activate = params.event_on_activate
	-- local event_on_skip = params.event_on_skip
	
	-- if event_on_activate then
		-- EchoConsole("event_on_activate: " .. event_on_activate)
	-- else
		-- EchoConsole("no event_on_activate")
	-- end
	-- if event_on_skip then
		-- EchoConsole("event_on_skip: " .. event_on_skip)
	-- else
		-- EchoConsole("no event_on_skip")
	-- end
	
	-- local event_on_deactivate = params.event_on_deactivate
	-- if event_on_deactivate then
		-- EchoConsole("event_on_deactivate: " .. event_on_deactivate)
	-- else
		-- EchoConsole("no event_on_deactivate")
	-- end
	
	-- local cutscene_system = Managers.state.entity:system("cutscene_system")

	-- cutscene_system:flow_cb_activate_cutscene_logic(player_input_enabled, event_on_activate, event_on_skip)
-- end)

-- Mods.hook.set(mod_name, "flow_callback_deactivate_cutscene_logic", function(func, params)
	-- local event_on_deactivate = params.event_on_deactivate
	-- local cutscene_system = Managers.state.entity:system("cutscene_system")

	-- if event_on_deactivate then
		-- EchoConsole("event_on_deactivate: " .. event_on_deactivate)
	-- else
		-- EchoConsole("no event_on_deactivate")
	-- end
	
	-- cutscene_system:flow_cb_deactivate_cutscene_logic(event_on_deactivate)
-- end)

-- Set up skip for fade effect
Mods.hook.set(mod_name, "CutsceneSystem.skip_pressed", function(func, self)
	-- skip_next_fade = true
    -- if user_setting(MOD_SETTINGS.ACTIVE.save) then
        -- func(self)							  
    -- end
	
	if not user_setting(MOD_SETTINGS.MODE.save) then
		skip_next_fade = true
		if user_setting(MOD_SETTINGS.ACTIVE.save) then
			func(self)
			
			local level_key = nil
			local game_mode = Managers.state.game_mode

			if game_mode then
				level_key = game_mode:level_key()
			end
			
			if self.event_on_skip and level_key and not do_not_play_event_on_skip[level_key] then
				local level = LevelHelper:current_level(self.world)
				Level.trigger_event(level, self.event_on_skip)
			else
				local wwise_world = Managers.world:wwise_world(self.world)
				
				-- WwiseWorld.trigger_event(wwise_world, "hud_in_inventory_state_on")
				WwiseWorld.trigger_event(wwise_world, "hud_in_inventory_state_off")
			end
		end
	end
end)

-- Skip fade when applicable
Mods.hook.set(mod_name, "CutsceneSystem.flow_cb_cutscene_effect", function(func, self, name, flow_params)
	if name == "fx_fade" and skip_next_fade then
		skip_next_fade = false
	else
        func(self, name, flow_params)
	end
end)

-- Don't restore player input if player already has active input
Mods.hook.set(mod_name, "CutsceneSystem.flow_cb_deactivate_cutscene_logic", function(func, self, event_on_deactivate)
	-- If a popup is open or cursor present, skip the input restore
	if ShowCursorStack.stack_depth > 0 or Managers.popup:has_popup() then
		if event_on_deactivate then
			local level = LevelHelper:current_level(self.world)
			Level.trigger_event(level, event_on_deactivate)
		end

		self.event_on_skip = nil
		
		local wwise_world = Managers.world:wwise_world(self.world)
		WwiseWorld.trigger_event(wwise_world, "hud_in_inventory_state_off")
	else
        func(self, event_on_deactivate)
	end
end)

-- Prevent invalid cursor pop crash if another mod interferes
Mods.hook.set(mod_name, "ShowCursorStack.pop", function(func)
	-- Catch a starting depth of 0 or negative cursors before pop
	if ShowCursorStack.stack_depth <= 0 then
		EchoConsole("[Warning]: Attempt to remove non-existent cursor.")
	else
        func()
	end
end)

-- Disable level intro audio
Mods.hook.set(mod_name, "StateLoading._trigger_sound_events", function(func, self, level_key)
	if user_setting(MOD_SETTINGS.NO_INTRO.save) then
		return
	end

	return func(self, level_key)
end)

-- Attempt to disable map start cutscene sound effect and silent effect
--[[
local cutscene_sound = {
	play_calm_city_docks = true,
	merchant_welcome_to_back_city_streets = true,
	play_tunnels_1_realm_of_the_skaven_introduction_v2 = true,
	backstreets_complex = true,
	-- play_threat_sneaking_city_streets = true,
	-- Play_skaven_camp = true,
	play_welcome_to_the_bridge = true,
}

Mods.hook.set(mod_name, "WwiseWorld.trigger_event", function (func, self, event_name, ...)
	if user_setting(MOD_SETTINGS.MODE.save) and not cutscene_sound[event_name] then
		func(self, event_name, ...)
	end
end)
--]]

--Hotkey for temporary sound fix

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

Mods.hook.set(mod_name, "DialogueSystem.update", function(func, self, ...)
	func(self, ...)
	
	if self.wwise_world and get_hotkey_state("0") then
		-- WwiseWorld.trigger_event(self.wwise_world, "hud_in_inventory_state_on")
		WwiseWorld.trigger_event(self.wwise_world, "hud_in_inventory_state_off")
	end
end)

--[[
	Add options for this module to the Options UI.
--]]
local function create_options()
	Mods.option_menu:add_group("cut_group", "Cutscenes")
	Mods.option_menu:add_item("cut_group", MOD_SETTINGS.ACTIVE, true)
	Mods.option_menu:add_item("cut_group", MOD_SETTINGS.MODE, true)
	Mods.option_menu:add_item("cut_group", MOD_SETTINGS.NO_INTRO, true)
end

local status, err = pcall(create_options)
if err ~= nil then
	EchoConsole(err)
end