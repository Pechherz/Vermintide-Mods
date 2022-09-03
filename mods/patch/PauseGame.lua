PauseGame = {}
PauseGame.widget_settings = {
    PAUSE_GAME_ENABLED = {
        ["save"] = "cb_pause_game_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable Pause Game",
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
                    "cb_pause_game_pause_game",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_pause_game_pause_game",
                }
            },
        },
    },
    PAUSE_GAME = {
        ["save"] = "cb_pause_game_pause_game",
        ["widget_type"] = "keybind",
        ["text"] = "Pause Game",
        ["tooltip"] = "Pauses the game" ..
            "Don't press ESC, unless you want to break your game",
        ["default"] = {
            "p",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action", "pause_game" },
    },

}

---Teleports the local player to position where the cursor points to
---@param self table
PauseGame.pause_game = function(self)
    EchoConsole(PauseGame.get(PauseGame.widget_settings.PAUSE_GAME))
    if self.get(self.widget_settings.PAUSE_GAME) then
        EchoConsole("Test2")
        if not freezealltoken then
            freezealltoken = false
        end

        Managers.state.debug.time_paused = not Managers.state.debug.time_paused
        if Managers.state.debug.time_paused then
            freezealltoken = true

            Managers.state.debug:set_time_paused()
            Managers.chat:send_system_chat_message(1, "Paused game. Pressing ESC will freeze the game!", 0, true)
        else
            freezealltoken = false

            Managers.state.debug:set_time_scale(Managers.state.debug.time_scale_index)
            Managers.chat:send_system_chat_message(1, "Unpaused game.", 0, true)
        end
    end
end

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
PauseGame.get = function(data)
    Mods.debug.write_log(Mods.debug:table_to_string(data, 2, "data"))

    if data then
        return Application.user_setting(data.save)
    end
end

---Creates widgets under mod settings
---@param self table
PauseGame.create_options = function(self)
    local group = "cheats"
    Mods.option_menu:add_group(group, "Gameplay Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.PAUSE_GAME_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.PAUSE_GAME)
end

PauseGame:create_options()
