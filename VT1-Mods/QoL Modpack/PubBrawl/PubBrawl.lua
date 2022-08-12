local mod_name = "PubBrawl"

local user_setting = Application.user_setting

local MOD_SETTINGS = {
    additional_items_swords = {
        ["save"] = "cb_additional_items_sword",
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
        ["save"] = "cb_additional_items",
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

local function create_options()
    Mods.option_menu:add_group("pubbrawl", "Pub Brawl")

    Mods.option_menu:add_item("pubbrawl", MOD_SETTINGS.additional_items_swords, true)
    Mods.option_menu:add_item("pubbrawl", MOD_SETTINGS.additional_items, true)
end

-- Mods.update_title_properties = function(is_brawl_enabled)
--     if Managers.backend and Managers.backend._interfaces and Managers.backend._interfaces.title_properties then
--         local title_properties = Managers.backend._interfaces.title_properties
--         if not title_properties._data then
--             title_properties._data = {
--                 brawl_enabled = is_brawl_enabled,
--             }
--         else
--             title_properties._data.brawl_enabled = is_brawl_enabled
--         end
--     end
-- end

-- Mods.spawn_brawl_swords_and_other_items = function()
--     pcall(function()
--         if Managers.player.is_server then

--             -- Wooden Pub Brawl swords on tables
--             Mods.spawn_inn_brawl_sword_01()
--             Mods.spawn_inn_brawl_sword_02()
--             Mods.spawn_inn_brawl_barrel()

--             -- Grenade near ammo box
--             Mods.spawn_inn_grenade()

--             -- Potions near forge and exit
--             Mods.spawn_inn_strength()
--             Mods.spawn_inn_speed()
--         end
--     end)
-- end

Mods.spawn_inn_brawl_sword_01 = function()
    -- Pickups.level_events.wooden_sword_01.hud_description = "Wooden Sword"
    Managers.state.network.network_transmit:send_rpc_server(
        'rpc_spawn_pickup',
        NetworkLookup.pickup_names["wooden_sword_01"],
        Vector3(0.3, -4.3, 2.1),
        Quaternion.axis_angle(Vector3(5, 2, 3), 0.5),
        NetworkLookup.pickup_spawn_types['dropped']
    )
end

Mods.spawn_inn_brawl_sword_02 = function()
    -- Pickups.level_events.wooden_sword_02.hud_description = "Wooden Sword"
    Managers.state.network.network_transmit:send_rpc_server(
        'rpc_spawn_pickup',
        NetworkLookup.pickup_names["wooden_sword_02"],
        Vector3(0.0, 0.4, 2),
        Quaternion.axis_angle(Vector3(5, 3, -8), .5),
        NetworkLookup.pickup_spawn_types['dropped']
    )
end

Mods.spawn_inn_brawl_barrel = function()
    -- Beer Barrel
    Managers.state.network.network_transmit:send_rpc_server(
        "rpc_spawn_pickup_with_physics",
        NetworkLookup.pickup_names["brawl_unarmed"],
        Vector3(3.8, -2.7, 0.98),
        Quaternion.axis_angle(Vector3(0, 0, 0), 0),
        NetworkLookup.pickup_spawn_types["dropped"]
    )
end

Mods.spawn_inn_grenade = function()
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
        Managers.state.network.network_transmit:send_rpc_server(
            'rpc_spawn_pickup',
            NetworkLookup.pickup_names[grenade_templates[math.random(1, 2)]],
            Vector3(value[1], value[2], value[3]),
            Quaternion.axis_angle(Vector3(0, 0, 0), 0),
            NetworkLookup.pickup_spawn_types['dropped']
        )
    end
end

Mods.spawn_inn_strength = function()
    Managers.state.network.network_transmit:send_rpc_server(
        'rpc_spawn_pickup',
        NetworkLookup.pickup_names["damage_boost_potion"],
        Vector3(6.41, -3.15, 1.3),
        Quaternion.axis_angle(Vector3(0, 0, 0), 0),
        NetworkLookup.pickup_spawn_types['dropped']
    )
end

Mods.spawn_inn_speed = function()
    local speed_boost_potion_location = {
        { 0.07, 4.49, 1.9 },
        { 0.12, 4.42, 1.9 },
        { 0.1, 4.35, 1.9 }
    }

    for index, value in ipairs(speed_boost_potion_location) do
        Managers.state.network.network_transmit:send_rpc_server(
            'rpc_spawn_pickup',
            NetworkLookup.pickup_names["speed_boost_potion"],
            Vector3(value[1], value[2], value[3]),
            Quaternion.axis_angle(Vector3(0, 0, math.random(-15, 25)), 0.5),
            NetworkLookup.pickup_spawn_types['dropped']
        )
    end
end

-- ##########################################################
-- #################### Hooks ###############################

-- Re-enables the flow event that causes Lohner to pour a drink when approached
Mods.hook.set(mod_name, "GameModeManager.pvp_enabled", function(func, self, ...)

    EchoConsole("GameModeManager.pvp_enabled")

    -- Changes here:
    if Managers.state.game_mode and Managers.state.game_mode._game_mode_key == "inn" then
        return true
    end
    -- Changes end.

    local result = func(self, ...)
    return result
end)

-- ##########################################################
-- ################### Callback #############################

-- Call when game state changes (e.g. StateLoading -> StateIngame)
-- Mods.on_game_state_changed = function(status, state)
--     EchoConsole("MOD_SETTINGS.additional_items: " .. tostring(get(MOD_SETTINGS.additional_items)))
--     if state == "StateIngame" and get(MOD_SETTINGS.additional_items) and Managers.player.is_server then
--         if Managers.state.game_mode and Managers.state.game_mode._game_mode_key == "inn" then

--             -- Spawn items
--             local pickup_system = Managers.state.entity:system("pickup_system")
--             if #pickup_system._spawned_pickups < 4 then
--                 Mods.spawn_brawl_swords_and_other_items()
--             end
--         end
--     end
-- end

Mods.hook.set(mod_name, "StateInGameRunning.on_enter", function(func, self, ...)
    func(self, ...)

    if Managers.player.is_server then
        if Managers.state.game_mode and Managers.state.game_mode._game_mode_key == "inn" then

            -- Spawn items
            local pickup_system = Managers.state.entity:system("pickup_system")
            if #pickup_system._spawned_pickups < 4 then
                if user_setting(MOD_SETTINGS.additional_items_swords.save) then
                    Mods.spawn_inn_brawl_sword_01()
                    Mods.spawn_inn_brawl_sword_02()
                    Mods.spawn_inn_brawl_barrel()
                end

                if user_setting(MOD_SETTINGS.additional_items.save) then
                    Pickups.potions.speed_boost_potion.only_once = false
                    Pickups.potions.damage_boost_potion.only_once = false
                    Pickups.grenades.frag_grenade_t1.only_once = false
                    Pickups.improved_grenades.frag_grenade_t2.only_once = false

                    -- Grenade near ammo box
                    Mods.spawn_inn_grenade()

                    -- Potions near forge and exit
                    Mods.spawn_inn_strength()
                    Mods.spawn_inn_speed()
                end
            end
        else
            Pickups.potions.speed_boost_potion.only_once = true
            Pickups.potions.damage_boost_potion.only_once = true
            Pickups.grenades.frag_grenade_t1.only_once = true
            Pickups.improved_grenades.frag_grenade_t2.only_once = true
        end
    end
end)

-- Call when governing settings checkbox is unchecked
-- Mods.on_disabled = function(initial_call)
--     EchoConsole(user_setting(MOD_SETTINGS.additional_items_swords.save))

--     if not initial_call then
--         Mods.update_title_properties(false)
--     end
-- end

-- -- Call when governing settings checkbox is checked
-- Mods.on_enabled = function(initial_call)
--     EchoConsole(user_setting(MOD_SETTINGS.additional_items_swords.save))

--     Mods.update_title_properties(true)
-- end

-- create_options()
local status, err = pcall(create_options)
if err ~= nil then
    EchoConsole(err)
end
