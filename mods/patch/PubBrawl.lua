local mod_name = "PubBrawl"

PubBrawl = {}
PubBrawl.widget_settings = {
    pub_brawl_enabled = {
        ["save"] = "cb_pub_brawl_additional_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable Pub Brawl",
        ["tooltip"] = "",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1,
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = {
                    "cb_pub_brawl_additional_items_sword",
                    "cb_pub_brawl_additional_items",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_pub_brawl_additional_items_sword",
                    "cb_pub_brawl_additional_items",
                }
            },
        },
    },
    additional_items_swords = {
        ["save"] = "cb_pub_brawl_additional_items_sword",
        ["widget_type"] = "stepper",
        ["text"] = "Add wooden swords to the inn.",
        ["tooltip"] = "Toggle additional extras on / off.\n\n" ..
            "Adds two wooden swords for PvP to the inn.",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1,
    },
    additional_items = {
        ["save"] = "cb_pub_brawl_additional_items",
        ["widget_type"] = "stepper",
        ["text"] = "Add bombs and potions to the inn.",
        ["tooltip"] = "Toggle additional extras on / off.\n\n" ..
            "Adds seven frag grenades and five potions to the inn.",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 1, -- Default second option is enabled. In this case Off
    },
}

---Spawn a sword_01 on a fixed position (meant for the inn)
---@param self table
PubBrawl.spawn_brawl_sword_01 = function(self)
    -- Pickups.level_events.wooden_sword_01.hud_description = "Wooden Sword"
    self.spawn_item_rpc("wooden_sword_01", 0.3, -4.3, 2.1, 5, 2, 3)
    
end

---Spawn a sword_02 on a fixed position (meant for the inn)
---@param self table
PubBrawl.spawn_brawl_sword_02 = function(self)
    self.spawn_item_rpc("wooden_sword_02", 0.0, 0.4, 2, 5, 3, -8)
end

---Spawn a brawl barrel on a fixed position (meant for the inn)
---@param self table
PubBrawl.spawn_brawl_barrel = function(self)
    self.spawn_item_rpc("brawl_unarmed", 3.8, -2.7, 0.98, 0, 0, 0)
end

---Spawn greneades on a fixed position (meant for the inn)
---@param self table
PubBrawl.spawn_grenades = function(self)
    local grenade_locations = {
        { -2.4, 4.1, 0.9 },
        { -2.2, 4.1, 0.9 },
        { -2.3, 3.925, 0.9 },
    }

    local grenade_templates = {
        "frag_grenade_t1",
        "frag_grenade_t2"
    }

    for index, value in ipairs(grenade_locations) do
        local random_item_name = grenade_templates[math.random(1, 2)]
        self.spawn_item_rpc(random_item_name, value[1], value[2], value[3], 0, 0, 0)
    end
end

---Spawn strength potions on a fixed position (meant for the inn)
---@param self table
PubBrawl.spawn_strength_potions = function(self)
    local strength_potion_location = {
        { 6.41, -3.15, 1.3 },
    }

    for index, value in ipairs(strength_potion_location) do
        self.spawn_item_rpc("damage_boost_potion", value[1], value[2], value[3], 0, 0, math.random(-15, 25))

    end
end

---Spawn speed potions on a fixed position (meant for the inn)
---@param self table
PubBrawl.spawn_speed_potions = function(self)
    local speed_boost_potion_location = {
        { 0.07, 4.49, 1.9 },
        { 0.12, 4.42, 1.9 },
        { 0.1, 4.35, 1.9 }
    }

    for index, value in ipairs(speed_boost_potion_location) do
        self.spawn_item_rpc("speed_boost_potion", value[1], value[2], value[3], 0, 0, math.random(-15, 25))
    end
end

---Enable items to be picked up infinitely
---@param self table
---@param enabled boolean
PubBrawl.infinite_bombs_and_potions_pickups_enabled = function (self, enabled)
    Pickups.potions.speed_boost_potion.only_once = not enabled
    Pickups.potions.damage_boost_potion.only_once = not enabled
    Pickups.grenades.frag_grenade_t1.only_once = not enabled
    Pickups.improved_grenades.frag_grenade_t2.only_once = not enabled
end

-- Re-enables the flow event that causes Lohner to pour a drink when approached
Mods.hook.set(mod_name, "GameModeManager.pvp_enabled", function(func, self, ...)
    if PubBrawl.get(PubBrawl.widget_settings.pub_brawl_enabled) then
        EchoConsole("Someone wants a beating..")
        
        if Managers.state.game_mode and Managers.state.game_mode._game_mode_key == "inn" then
            return true
        end
    end

    local result = func(self, ...)
    return result
end)

Mods.hook.set(mod_name, "StateInGameRunning.on_enter", function(func, self, ...)
    func(self, ...)

    if Managers.player.is_server then
        if Managers.state.game_mode and Managers.state.game_mode._game_mode_key == "inn" then

            -- Spawn items
            local pickup_system = Managers.state.entity:system("pickup_system")
            if #pickup_system._spawned_pickups < 4 then
                if PubBrawl.get(PubBrawl.widget_settings.additional_items_swords) then
                    PubBrawl:spawn_brawl_barrel()
                    PubBrawl:spawn_brawl_sword_01()
                    PubBrawl:spawn_brawl_sword_02()
                end

                if PubBrawl.get(PubBrawl.widget_settings.additional_items) then
                    PubBrawl:infinite_bombs_and_potions_pickups_enabled(true)

                    -- Grenades in basket near inventory storage
                    PubBrawl:spawn_grenades()
                    
                    -- Potions near forge and exit
                    PubBrawl:spawn_strength_potions()
                    PubBrawl:spawn_speed_potions()
                end
            end
        else
            PubBrawl:infinite_bombs_and_potions_pickups_enabled(false)
        end
    end
end)

---RPC request to spawn an item 
---@param item_name string name available
---@param x_pos float position on the X axis
---@param y_pos float position on the Y axis
---@param z_pos float position on the Z axis
PubBrawl.spawn_item_rpc = function (item_name, x_pos, y_pos, z_pos, x_angle, y_angle, z_angle)
    Managers.state.network.network_transmit:send_rpc_server(
        'rpc_spawn_pickup',
        NetworkLookup.pickup_names[item_name],
        Vector3(x_pos, y_pos, z_pos),
        Quaternion.axis_angle(Vector3(x_angle, y_angle, z_angle), 0.5),
        NetworkLookup.pickup_spawn_types['dropped']
    )
end

---Gets the value of a widget
---@param data table predifined widgets object
---@return any
PubBrawl.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Create the option entries in the mod settings
PubBrawl.create_options = function (self)  
    local group = "pubbrawl"

    Mods.option_menu:add_group(group, "Pub Brawl")

    Mods.option_menu:add_item(group, self.widget_settings.pub_brawl_enabled, true)
    Mods.option_menu:add_item(group, self.widget_settings.additional_items_swords)
    Mods.option_menu:add_item(group, self.widget_settings.additional_items)
end

PubBrawl:create_options()