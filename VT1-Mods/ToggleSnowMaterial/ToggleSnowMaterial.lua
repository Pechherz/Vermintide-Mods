local mod_name = "ToggleSnowMaterial"

ToggleSnowMaterial = {}
ToggleSnowMaterial.widget_settings = {
    TOGGLE_SNOW_MATERIAL = {
        ["save"] = "cb_toggle_snow_material",
        ["widget_type"] = "stepper",
        ["text"] = "Snow Material Disabled",
        ["tooltip"] = "Snow Material Disabled\n" ..
            "Disable the snowy look on Skaven (only affects new spawned foes)",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On",  value = true },
        },
        ["default"] = 1,
    }
}

---Toggle snow material on or off
---@param self table
ToggleSnowMaterial.toggle_snow_material = function(self)
    if self.get(self.widget_settings.TOGGLE_SNOW_MATERIAL) then
        LevelSettings.dlc_dwarf_beacons.climate_type = nil
        LevelSettings.dlc_dwarf_exterior.climate_type = nil
    else
        LevelSettings.dlc_dwarf_beacons.climate_type = "snow"
        LevelSettings.dlc_dwarf_exterior.climate_type = "snow"
    end
end

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
ToggleSnowMaterial.get = function(data)
    if data then
        return Application.user_setting(data.save)
    else
        return false
    end
end

Mods.hook.set(mod_name, "OptionsView.apply_changes",
    function(func, self, user_settings, render_settings, pending_user_settings)
        func(self, user_settings, render_settings, pending_user_settings)

        ToggleSnowMaterial:toggle_snow_material()
    end)

---Creates widgets under mod settings
---@param self table
ToggleSnowMaterial.create_options = function(self)
    local group = "tweaks"
    Mods.option_menu:add_group(group, "Gameplay Tweaks")
    Mods.option_menu:add_item(group, self.widget_settings.TOGGLE_SNOW_MATERIAL, true)
end

ToggleSnowMaterial:create_options()
ToggleSnowMaterial:toggle_snow_material()
