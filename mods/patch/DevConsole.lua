--[[
	Development Console Window:
		Pop up a console window with debugging information

	DevConsole v1.0.0
	Author: IamLupo

	Opens a command line window that the game prints some debug information into.
	print() function can be used to display text on the console via lua scripts.
	Go to Mod Settings -> System -> Development Console Window to toggle.
	Off by default.

	Changelog
		1.0.0 - Release
--]]

local mod_name = "DevConsole"
DevConsole = {}
local mod = DevConsole

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_dev_console_window",
		["widget_type"] = "stepper",
		["text"] = "Development Console Window",
		["tooltip"] =  "Development Console Window\n" ..
			"Toggle development console window on / off.\n\n" ..
			"Pop up a console window with debugging information.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
}

mod.enabled = false

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("system", "System")

	Mods.option_menu:add_item("system", mod.widget_settings.ACTIVE, true)
end

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "print", function(func, ...)
	if mod.get(mod.widget_settings.ACTIVE) then
		CommandWindow.print(...)
		-- Managers.chat:add_local_system_message(1, ..., true)
	else
		func(...)
	end
end)

local log = {}
Mods.hook.set(mod_name, "Localize", function(func, text_id)
	local text_value = func(text_id)

	if mod.get(mod.widget_settings.ACTIVE) then
		local log_message  = "[Localization] text_id:" .. text_id .. " -> text_value:" .. text_value

		if not log[text_id] then
			log[text_id] = log_message
			CommandWindow.print(log_message)
		end
	end

	return text_value
end)

Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, ...)
	safe_pcall(function()
		-- Open Command Window
		if mod.get(mod.widget_settings.ACTIVE) == true and mod.enabled == false then
			CommandWindow.open("Development command window")
			
			-- GameSettingsDevelopment.show_fps = true
			-- Development._hardcoded_dev_params.hide_fps = false
			-- GameSettingsDevelopment.help_screen_enabled = false
			-- GameSettingsDevelopment.network_revision_check_enabled = true
			-- GameSettingsDevelopment.simple_first_person = true
			-- GameSettingsDevelopment.disable_shadow_lights_system = false
			-- GameSettingsDevelopment.beta = false
			-- Development._hardcoded_dev_params.debug_enabled = true
			-- Development._hardcoded_dev_params.navigation_visual_debug_enabled = true
			-- Development._hardcoded_dev_params.navigation_thread_disabled = false
			-- Development._hardcoded_dev_params.networked_flow_state_debug = true
			-- Development._hardcoded_dev_params.network_debug = false
			-- Development._hardcoded_dev_params.network_debug_connections = true
			-- script_data.debug_interactions = true
			-- Development._hardcoded_dev_params.package_debug = false
			-- script_data.debug_behaviour_trees = true
			-- Development._hardcoded_dev_params.matchmaking_debug = false
			-- script_data.use_tech_telemetry = true
			-- script_data.use_telemetry = true
			-- script_data.extrapolation_debug = true
			-- script_data.debug_voip = true

			mod.enabled = true
		end

		-- Close Command Window
		if mod.get(mod.widget_settings.ACTIVE) == false and mod.enabled == true then
			CommandWindow.close()

			mod.enabled = false
		end
	end)

	func(...)
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
