local mod_name = "PlayerDialogue"

PlayerDialogue = {}
PlayerDialogue.widget_settings = {
    PLAYER_DIALOGUE_ENABLED = {
        ["save"] = "cb_player_dialogue_enabled",
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
                    "cb_player_dialogue_say",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_player_dialogue_say",
                }
            },
        },
    },
    SAY = {
        ["save"] = "cb_player_dialogue_say",
        ["widget_type"] = "keybind",
        ["text"] = "Say",
        ["tooltip"] = "" ..
            "",
        ["default"] = {
            "t",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action", "say" },
    },
}

---Teleports the local player to position where the cursor points to
---@param self table
PlayerDialogue.say = function(self)
    EchoConsole("Say")
end

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
PlayerDialogue.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Creates widgets under mod settings
---@param self table
PlayerDialogue.create_options = function(self)
    local group = "shenanigans"
    Mods.option_menu:add_group(group, "Shenanigans")
    Mods.option_menu:add_item(group, self.widget_settings.PLAYER_DIALOGUE_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.SAY)
end

PlayerDialogue:create_options()