PlayerTeleporter = {}
PlayerTeleporter.widget_settings = {
    PLAYER_TELEPORTER_ENABLED = {
        ["save"] = "cb_player_teleporter.enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable Player Teleporter",
        ["tooltip"] = "",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1, -- Default second option is enabled. In this case Off
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = {
                    "cb_player_teleporter_teleport_to",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_player_teleporter_teleport_to",
                }
            },
        },
    },
    TELEPORT_TO = {
        ["save"] = "cb_player_teleporter_teleport_to",
        ["widget_type"] = "keybind",
        ["text"] = "Teleport To",
        ["default"] = {
            "space",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/player_teleporter", "teleport" },
    },
}

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
PlayerTeleporter.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Creates widgets under mod settings
---@param self table
PlayerTeleporter.create_options = function(self)
    local group = "cheats"
    Mods.option_menu:add_group(group, "Gameplay Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.PLAYER_TELEPORTER_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.TELEPORT_TO)
end

PlayerTeleporter:create_options()