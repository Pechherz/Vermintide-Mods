local mod, mod_name, oi = Mods.new_mod("NoSilentAssasins")
--[[
	
--]]

mod.widget_settings = {
	ACTIVE = {
		["save"] = "vmf_no_silent_assasins_active",
		["widget_type"] = "stepper",
		["text"] = Localize("vmf_text_no_silent_assasins_active_text"),
		["tooltip"] =  Localize("vmf_text_no_silent_assasins_active_text") .. "\n" ..
			Localize("vmf_text_no_silent_assasins_active_tooltip"),
		["value_type"] = "boolean",
		["options"] = {
			{text = Localize("vmf_text_core_off"), value = false},
			{text = Localize("vmf_text_core_on"), value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
}

-- Create new Terror event
TerrorEventBlueprints.custom_gutter_warning = {
	{
		"play_stinger",
		stinger_name = "Play_enemy_stormvermin_champion_electric_floor"
	},
}

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("enemy", "Enemy")
	
	Mods.option_menu:add_item("enemy", mod.widget_settings.ACTIVE, true)
end

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "ConflictDirector.spawn_unit", function (func, self, breed, ...)
	if breed.name == "skaven_gutter_runner" then
		if mod.get(mod.widget_settings.ACTIVE.save) then
			-- Disable orginal sound
			Breeds.skaven_gutter_runner.combat_spawn_stinger = nil
			
			-- Trigger terror event
			Managers.state.conflict:start_terror_event("custom_gutter_warning")
		else
			-- use orginal sound
			Breeds.skaven_gutter_runner.combat_spawn_stinger = "enemy_gutterrunner_stinger"
		end
	end
	
    return func(self, breed, ...)
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()