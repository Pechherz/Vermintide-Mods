PlayerTeleporter = {}
PlayerTeleporter.widget_settings = {
    SUB_GROUP = {
        ["save"] = "cb_player_teleporter_subgroup",
        ["widget_type"] = "dropdown_checkbox",
        ["text"] = "Player Teleporter",
        ["default"] = false,
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = {
                    "cb_player_teleporter_enabled",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_player_teleporter_enabled",
                }
            },
        },
    },
    PLAYER_TELEPORTER_ENABLED = {
        ["save"] = "cb_player_teleporter_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enabled",
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
                    "cb_player_teleporter_teleport_bots_to",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_player_teleporter_teleport_to",
                    "cb_player_teleporter_teleport_bots_to",
                }
            },
        },
    },
    TELEPORT_TO = {
        ["save"] = "cb_player_teleporter_teleport_to",
        ["widget_type"] = "keybind",
        ["text"] = "Teleport yourself ",
        ["tooltip"] = "Teleport yourself to your cursor position" ..
            "",
        ["default"] = {
            "f1",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/player_teleporter", "teleport_to" },
    },
    TELEPORT_BOTS_TO = {
        ["save"] = "cb_player_teleporter_teleport_bots_to",
        ["widget_type"] = "keybind",
        ["text"] = "Teleport all bots",
        ["tooltip"] = "Only for hosting players" ..
            "Cheat Protection blocks teleportation request except for bots of your own lobby.",
        ["default"] = {
            "f2",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/player_teleporter", "teleport_bots_to" },
    },
}

---Teleports the local player to position where the cursor points to
---@param self table
PlayerTeleporter.teleport_to = function(self)
    if self.get(self.widget_settings.PLAYER_TELEPORTER_ENABLED) then
        local local_player = Managers.player:local_player()
        local locomotion_extension = ScriptUnit.extension(local_player.player_unit, "locomotion_system")
        local conflict_director = Managers.state.conflict
        local position, distance, normal, actor = conflict_director:player_aim_raycast(conflict_director._world, false,
            "filter_ray_horde_spawn")

        if position ~= nil then
            locomotion_extension.teleport_to(locomotion_extension, position)
        end
    end
end

---Teleports alls players to position where the cursor points to
---@param self table
PlayerTeleporter.teleport_bots_to = function(self)
    if self.get(self.widget_settings.PLAYER_TELEPORTER_ENABLED) and Managers.player.is_server then
        local players = Managers.player._players

        for _, player in pairs(players) do
            if player.bot_player == true and player.player_unit ~= nil then
                local locomotion_extension = ScriptUnit.extension(player.player_unit, "locomotion_system")
                local conflict_director = Managers.state.conflict
                local position, distance, normal, actor =
                conflict_director:player_aim_raycast(conflict_director._world, false, "filter_ray_horde_spawn")

                if position ~= nil then
                    locomotion_extension:teleport_to(position)
                end
            end
        end
    end
end

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
    Mods.option_menu:add_group(group, "Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.SUB_GROUP, true)
    Mods.option_menu:add_item(group, self.widget_settings.PLAYER_TELEPORTER_ENABLED)
    Mods.option_menu:add_item(group, self.widget_settings.TELEPORT_TO)
    Mods.option_menu:add_item(group, self.widget_settings.TELEPORT_BOTS_TO)
end

PlayerTeleporter:create_options()
