local mod_name = "ChatGuiSettings"
local oi = OptionsInjector

ChatGuiSettings = {}
ChatGuiSettings.widget_settings = {
    CHAT_GUI_SETTINGS_ENABLED = {
        ["save"] = "cb_chat_gui_settings_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable Chat GUI Settings",
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
                    "cb_chat_gui_settings_set_history_max_size",
                    "cb_chat_gui_settings_set_font_size",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_chat_gui_settings_set_history_max_size",
                    "cb_chat_gui_settings_set_font_size",
                }
            },
        },
    },
    SET_HISTORY_MAX_SIZE = {
        ["save"]        = "cb_chat_gui_settings_set_history_max_size",
        ["widget_type"] = "slider",
        ["text"]        = "Set chat history size",
        ["tooltip"]     = "Defines the amount of messages that get shown before replaced by newer messages",
        ["range"]       = { 1, 250 },
        ["default"]     = 30,
    },
    SET_FONT_SIZE = {
        ["save"]        = "cb_chat_gui_settings_set_font_size",
        ["widget_type"] = "slider",
        ["text"]        = "Set chat history size",
        ["tooltip"]     = "Defines the amount of messages that get shown before replaced by newer messages",
        ["range"]       = { 6, 100 },
        ["default"]     = 30,
    },
}

Mods.hook.set(mod_name, "ChatGui._update_chat_messages", function(func, self)
    EchoConsole(ChatGuiSettings.get(ChatGuiSettings.widget_settings.CHAT_GUI_SETTINGS_ENABLED))
    if ChatGuiSettings.get(ChatGuiSettings.widget_settings.CHAT_GUI_SETTINGS_ENABLED) then

        local added_chat_messages = FrameTable.alloc_table()

        self.chat_manager:get_chat_messages(added_chat_messages)
        EchoConsole("Current Size: " .. ChatGuiSettings.get(ChatGuiSettings.widget_settings.SET_HISTORY_MAX_SIZE))
        local history_max_size = ChatGuiSettings.get(ChatGuiSettings.widget_settings.SET_HISTORY_MAX_SIZE)
        local num_new = #added_chat_messages
        local show_new_messages = false

        if num_new > 0 then
            local message_tables = self.chat_output_widget.content.message_tables
            local num_current = #message_tables

            if history_max_size < num_new + num_current then
                local num_to_remove = (num_new + num_current) - history_max_size

                for i = 1, num_to_remove, 1 do
                    table.remove(message_tables, 1)
                end
            end

            local font_material, font_size, font_name = unpack(Fonts.arial)
            num_current = #message_tables

            for i = 1, num_new, 1 do
                local new_message = added_chat_messages[i]
                local new_message_table = {}

                if new_message.is_system_message then
                    local message = string.format("%s", tostring(new_message.message))
                    new_message_table.is_dev = new_message.is_dev
                    new_message_table.is_system = true
                    new_message_table.message = message
                    show_new_messages = new_message.pop_chat
                else
                    local player = Managers.player:player_from_peer_id(new_message.message_sender)
                    local ingame_display_name, sender = nil

                    if player then
                        local profile_index = self.profile_synchronizer:profile_by_peer(player.peer_id,
                            player:local_player_id())
                        ingame_display_name = (
                            SPProfiles[profile_index] and SPProfiles[profile_index].ingame_short_display_name) or nil
                        sender = player:name()
                    end

                    local localized_display_name = ingame_display_name and Localize(ingame_display_name)
                    local sender = sender or (rawget(_G, "Steam") and Steam.user_name(new_message.message_sender)) or
                        tostring(new_message.message_sender)
                    local message = string.format("%s", tostring(new_message.message))
                    new_message_table.is_dev = new_message.is_dev
                    new_message_table.is_system = false
                    new_message_table.sender = (
                        ingame_display_name and string.format("%s (%s): ", sender, localized_display_name)) or
                        string.format("%s: ", sender)
                    new_message_table.message = message
                    show_new_messages = true
                end

                message_tables[num_current + i] = new_message_table
            end
        end

        return show_new_messages
    else
        return func(self)
    end
end)

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
ChatGuiSettings.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Creates widgets under mod settings
---@param self table
ChatGuiSettings.create_options = function(self)
    local group = "chatguisettings"
    Mods.option_menu:add_group(group, "Chat GUI Setting")
    Mods.option_menu:add_item(group, self.widget_settings.CHAT_GUI_SETTINGS_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.SET_HISTORY_MAX_SIZE)
    Mods.option_menu:add_item(group, self.widget_settings.SET_FONT_SIZE)
end

ChatGuiSettings:create_options()
