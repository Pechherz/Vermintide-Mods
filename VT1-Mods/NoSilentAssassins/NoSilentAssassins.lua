-- all credits to Jsat & Prop joe & IamLupo

local mod_name = "NoSilentAssassins"

NoSilentAssassins = {}
NoSilentAssassins.widget_settings = {
    NO_SILENT_ASSASSINS_ENABLED = {
        ["save"] = "cb_no_silent_assassins_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable No Silent Assassins",
        ["tooltip"] = "changes the Gutter Runner spawning sound",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1, -- Default second option is enabled. In this case Off
    },
}

-- Create new Terror event
TerrorEventBlueprints.custom_gutter_warning = {
    {
        "play_stinger",
        stinger_name = "Play_enemy_stormvermin_champion_electric_floor"
    },
}

Mods.hook.set(mod_name, "ConflictDirector.spawn_unit", function(func, self, breed, ...)
    if breed.name == "skaven_gutter_runner" then
        if NoSilentAssassins.get(NoSilentAssassins.widget_settings.NO_SILENT_ASSASSINS_ENABLED) then
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

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
NoSilentAssassins.get = function(data)
    if data then
        return Application.user_setting(data.save)
    else
        return false
    end
end

---Creates widgets under mod settings
---@param self table
NoSilentAssassins.create_options = function(self)
    local group = "GutterRunner"
    Mods.option_menu:add_group(group, "NoSilentAssassins")
    Mods.option_menu:add_item(group, self.widget_settings.NO_SILENT_ASSASSINS_ENABLED, true)

end

NoSilentAssassins:create_options()
