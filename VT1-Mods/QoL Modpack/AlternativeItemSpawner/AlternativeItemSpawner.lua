--[[
	Name:       Alternative Item Spawner
	Author:     Pechherz
	Version:    1.0.1 (2022-05-29)
                1.0.0 (2022-05-27)
    
    This is a alternative Item Spawner that is similar to the item spawner from Vermintide 2.
    It features predefined item groups (e.g. healing, bombs, potions ..) and a custom group, which can be changed by 
    the users wish.

    Required File Location:
        -AlternativeItemSpawner.lua                    goes into "\Warhammer End Times Vermintide\binaries\mods\patch\"
        -alternative_item_spawner_next_item.lua        goes into "\Warhammer End Times Vermintide\binaries\mods\patch\action\"
        -alternative_item_spawner_previous_item.lua    goes into "\Warhammer End Times Vermintide\binaries\mods\patch\action\"
        -alternative_item_spawner_spawn_item.lua       goes into "\Warhammer End Times Vermintide\binaries\mods\patch\action\"

    Version history:
	    -1.0.0 (2022-05-27): Release
        Features:
            -predined groups (e.g. healing, bombs .) and a custom group, which can be set by the users wish
            -includes the fire grenade fix for the inn (Credit goes to uladz)
            -includes the smoke bomb fix from (Credit goes to uladz)
            -smaller set of keybinds to improve mod usability
            -remove/clean spawned items
--]]

--add other display for current items
--add imte group keybind
--include grenade fixes
--add more items
--put item group below below only inn
--rename item pool list and add proper tooltips
--maybe remove some groups

local mod_name = "AlternativeItemSpawner"
local oi = OptionsInjector

local all_items = {
    healing_draught = {
        value = "healing_draught",
        text = "Healing Draught"
    },
    first_aid_kit = {
        value = "first_aid_kit",
        text = "Medical Supplies"
    },
    speed_boost_potion = {
        value = "speed_boost_potion",
        text = "Potion of Speed"
    },
    damage_boost_potion = {
        value = "damage_boost_potion",
        text = "Potion of Strength"
    },
    frag_grenade_t1 = {
        value = "frag_grenade_t1",
        text = "Explosive Bomb"
    },
    frag_grenade_t2 = {
        value = "frag_grenade_t2",
        text = "Improved Explosive Bomb"
    },
    fire_grenade_t1 = {
        value = "fire_grenade_t1",
        text = "Incendiary Bomb"
    },
    fire_grenade_t2 = {
        value = "fire_grenade_t2",
        text = "Improved Incendiary Bomb"
    },
    smoke_grenade_t1 = {
        value = "smoke_grenade_t1",
        text = "Smoke Bomb",
        message = "Caution on difficulty hard and above without the bomb trinket!\nLarger AoE then incendiary grenade."
    },
    smoke_grenade_t2 = {
        value = "smoke_grenade_t2",
        text = "Improved Smoke Bomb",
        message = "Caution on difficulty hard and above without the bomb trinket!\nLarger AoE then incendiary grenade."
    },
    all_ammo_small = {
        value = "all_ammo_small",
        text = "Ammunition"
    },
    tome = {
        value = "tome",
        text = "Tome"
    },
    grimoire = {
        value = "grimoire",
        text = "Grimoire"
    },
    lorebook_page = {
        value = "lorebook_page",
        text = "Lore-Book Page"
    },
    torch = {
        value = "torch",
        text = "Torch"
    },
    explosive_barrel = {
        value = "explosive_barrel",
        text = "Explosive Barrel"
    },
    brawl_unarmed = {
        value = "brawl_unarmed",
        text = "Pub Brawl Barrel",
        message = ""
    },
    wooden_sword_01 = {
        value = "wooden_sword_01",
        text = "Wooden Sword 1"
    },
    wooden_sword_02 = {
        value = "wooden_sword_02",
        text = "Wooden Sword 2"
    },
    endurance_badge_01 = {
        value = "endurance_badge_01",
        text = "Endurance Badge 1"
    },
    endurance_badge_02 = {
        value = "endurance_badge_02",
        text = "Endurance Badge 2"
    },
    endurance_badge_03 = {
        value = "endurance_badge_03",
        text = "Endurance Badge 3"
    },
    endurance_badge_04 = {
        value = "endurance_badge_04",
        text = "Endurance Badge 4"
    },
    endurance_badge_05 = {
        value = "endurance_badge_05",
        text = "Endurance Badge 5"
    },
}

AlternativeItemSpawner = {}
AlternativeItemSpawner.items_pool_category_all = {
    all_items.healing_draught,
    all_items.first_aid_kit,
    all_items.speed_boost_potion,
    all_items.damage_boost_potion,
    all_items.frag_grenade_t1,
    all_items.frag_grenade_t2,
    all_items.fire_grenade_t1,
    all_items.fire_grenade_t2,
    all_items.smoke_grenade_t1,
    all_items.smoke_grenade_t2,
    all_items.all_ammo_small,
    all_items.tome,
    all_items.grimoire,
    all_items.lorebook_page,
    all_items.torch,
    all_items.explosive_barrel,
    all_items.brawl_unarmed,
    all_items.wooden_sword_01,
    all_items.wooden_sword_02,
    all_items.endurance_badge_01,
    all_items.endurance_badge_02,
    all_items.endurance_badge_03,
    all_items.endurance_badge_04,
    all_items.endurance_badge_05,
}
AlternativeItemSpawner.items_pool_category_custom = {

}
AlternativeItemSpawner.items_pool_category_consumable = {
    all_items.healing_draught,
    all_items.first_aid_kit,
    all_items.speed_boost_potion,
    all_items.damage_boost_potion,
    all_items.frag_grenade_t1,
    all_items.frag_grenade_t2,
    all_items.fire_grenade_t1,
    all_items.fire_grenade_t2,
    all_items.smoke_grenade_t1,
    all_items.smoke_grenade_t2,
    all_items.all_ammo_small,
}
AlternativeItemSpawner.items_pool_category_healing = {
    all_items.healing_draught,
    all_items.first_aid_kit,
}
AlternativeItemSpawner.items_pool_category_potions = {
    all_items.speed_boost_potion,
    all_items.damage_boost_potion,
}
AlternativeItemSpawner.items_pool_category_bombs = {
    all_items.frag_grenade_t1,
    all_items.frag_grenade_t2,
    all_items.fire_grenade_t1,
    all_items.fire_grenade_t2,
    all_items.smoke_grenade_t1,
    all_items.smoke_grenade_t2,
}
AlternativeItemSpawner.items_pool_category_objects = {
    all_items.tome,
    all_items.grimoire,
    all_items.lorebook_page,
    all_items.torch,
    all_items.explosive_barrel,
    all_items.brawl_unarmed,
    all_items.wooden_sword_01,
    all_items.wooden_sword_02,
}
AlternativeItemSpawner.items_pool_category_endurance_badges = {
    all_items.endurance_badge_01,
    all_items.endurance_badge_02,
    all_items.endurance_badge_03,
    all_items.endurance_badge_04,
    all_items.endurance_badge_05,
}

AlternativeItemSpawner.items_pool_current_category = ""
AlternativeItemSpawner.items_pool_current_list = {}
AlternativeItemSpawner.items_pool_current_index = 1
AlternativeItemSpawner.items_pool_current_size = 0

AlternativeItemSpawner.widget_settings = {
    ITEM_SPAWNER_ENABLED = {
        ["save"] = "cb_item_spawner_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable Items Spawner",
        ["tooltip"] = "Enable Items Spawner\n" ..
            "Adds keyboard shortcuts for spawning pickup items (medkits, tomes, etc.).",
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
                    "cb_item_spawner_only_inn",
                    "cb_item_spawner_index_increment",
                    "cb_item_spawner_index_decrement",
                    "cb_item_spawner_index_spawn",
                    "cb_item_spawner_current_category",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_item_spawner_only_inn",
                    "cb_item_spawner_index_increment",
                    "cb_item_spawner_index_decrement",
                    "cb_item_spawner_index_spawn",
                    "cb_item_spawner_current_category",
                }
            },
        },
    },
    ITEM_SPAWNER_ONLY_INN = {
        ["save"] = "cb_item_spawner_only_inn",
        ["widget_type"] = "stepper",
        ["text"] = "Allows item spawning only in the inn",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["default"] = 2,
    },
    ITEM_SPAWNER_NEXT_ITEM = {
        ["save"] = "cb_item_spawner_index_increment",
        ["widget_type"] = "keybind",
        ["text"] = "Next Item",
        ["default"] = {
            "numpad 3",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action", "alternative_item_spawner_next_item" },
    },
    ITEM_SPAWNER_PREVIOUS_ITEM = {
        ["save"] = "cb_item_spawner_index_decrement",
        ["widget_type"] = "keybind",
        ["text"] = "Previous Item",
        ["default"] = {
            "numpad 1",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action", "alternative_item_spawner_previous_item" },
    },
    ITEM_SPAWNER_SPAWN_ITEM = {
        ["save"] = "cb_item_spawner_index_spawn",
        ["widget_type"] = "keybind",
        ["text"] = "Spawn Item",
        ["default"] = {
            "numpad 2",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action", "alternative_item_spawner_spawn_item" },
    },
    ITEM_SPAWNER_CURRENT_CATEGORY = {
        ["save"] = "cb_item_spawner_current_category",
        ["widget_type"] = "stepper",
        ["text"] = "Item Pool List",
        ["value_type"] = "string",
        ["options"] = {
            { text = "All", value = "all" },
            { text = "Custom", value = "custom" },
            { text = "Consumables", value = "consumables" },
            { text = "Healing", value = "healing" },
            { text = "Potions", value = "potions" },
            { text = "Bombs", value = "bombs" },
            { text = "Objects", value = "objects" },
            { text = "Endurance Badges", value = "endurance_badges" },
        },
        ["default"] = 3,
        ["hide_options"] = {
            {
                "all",
                mode = "show",
                options = {
                }
            },
            {
                "all",
                mode = "hide",
                options = {

                }
            },

            {
                "custom",
                mode = "show",
                options = {
                }
            },
            {
                "custom",
                mode = "hide",
                options = {
                }
            },

            {
                "consumables",
                mode = "show",
                options = {
                }
            },
            {
                "consumables",
                mode = "hide",
                options = {
                }
            },

            {
                "healing",
                mode = "show",
                options = {
                }
            },
            {
                "healing",
                mode = "hide",
                options = {
                }
            },

            {
                "potions",
                mode = "show",
                options = {
                }
            },
            {
                "potions",
                mode = "hide",
                options = {
                }
            },

            {
                "bombs",
                mode = "show",
                options = {
                    "",
                }
            },
            {
                "bombs",
                mode = "hide",
                options = {
                    "",
                }
            },

            {
                "objects",
                mode = "show",
                options = {
                    "",
                }
            },
            {
                "objects",
                mode = "hide",
                options = {
                    "",
                }
            },

            {
                "endurance_badges",
                mode = "show",
                options = {
                    "",
                }
            },
            {
                "endurance_badges",
                mode = "hide",
                options = {
                    "",
                }
            },
        },
    },
}

---Updates the item group according to the chosen item group from the mod settings.
---@param self table
AlternativeItemSpawner.update_items_pool_current_list = function(self)
    local item_spawner_current_category = self.get(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY)

    if item_spawner_current_category == "all" then
        self.items_pool_current_category = "all"
        self.items_pool_current_list = self.items_pool_category_all

    elseif item_spawner_current_category == "custom" then
        self.items_pool_current_category = "custom"
        self.items_pool_current_list = {}
        for index, item in ipairs(self.items_pool_category_all) do
            if self.get(self.widget_settings[string.upper("cb_item_spawner_item_" .. item.value)]) then
                table.insert(self.items_pool_current_list, item)
            end
        end

    elseif item_spawner_current_category == "consumables" then
        self.items_pool_current_category = "consumables"
        self.items_pool_current_list = self.items_pool_category_consumable

    elseif item_spawner_current_category == "healing" then
        self.items_pool_current_category = "healing"
        self.items_pool_current_list = self.items_pool_category_healing

    elseif item_spawner_current_category == "potions" then
        self.items_pool_current_category = "potions"
        self.items_pool_current_list = self.items_pool_category_potions

    elseif item_spawner_current_category == "bombs" then
        self.items_pool_current_category = "bombs"
        self.items_pool_current_list = self.items_pool_category_bombs

    elseif item_spawner_current_category == "objects" then
        self.items_pool_current_category = "objects"
        self.items_pool_current_list = self.items_pool_category_objects

    elseif item_spawner_current_category == "endurance_badges" then
        self.items_pool_current_category = "endurance_badges"
        self.items_pool_current_list = self.items_pool_category_endurance_badges

    end

    self.items_pool_current_index = 1
    self.items_pool_current_size = #self.items_pool_current_list
end

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
AlternativeItemSpawner.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Change to the next item in the current item group
---@param self table
AlternativeItemSpawner.next_item = function(self)
    -- check if item group has been changed
    if self.items_pool_current_category ~= self.get(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY) then
        self:update_items_pool_current_list()
    end

    self.items_pool_current_index = self.items_pool_current_index + 1
    if self.items_pool_current_index > self.items_pool_current_size then
        self.items_pool_current_index = 1
    end

    EchoConsole("Current Item: " .. self.items_pool_current_list[self.items_pool_current_index].text)
end

---Change to the previous item in the current item group
---@param self table
AlternativeItemSpawner.previous_item = function(self)
    -- check if item group has been changed
    if self.items_pool_current_category ~= self.get(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY) then
        self:update_items_pool_current_list()
    end

    self.items_pool_current_index = self.items_pool_current_index - 1
    if self.items_pool_current_index < 1 then
        self.items_pool_current_index = self.items_pool_current_size
    end

    EchoConsole("Current Item: " .. self.items_pool_current_list[self.items_pool_current_index].text)
end

---Spawn the current item from the item group
---@param self table
AlternativeItemSpawner.spawn_item = function(self)
    -- check if item group has been changed
    if self.items_pool_current_category ~= self.get(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY) then
        self:update_items_pool_current_list()
    end

    if Managers.player.is_server then
        if Managers.state.game_mode._game_mode_key == "inn" and AlternativeItemSpawner.get(AlternativeItemSpawner.widget_settings.ITEM_SPAWNER_ONLY_INN)
            or not AlternativeItemSpawner.get(AlternativeItemSpawner.widget_settings.ITEM_SPAWNER_ONLY_INN) then
            local local_player_unit = Managers.player:local_player().player_unit

            local item = self.items_pool_current_list[self.items_pool_current_index].value

            safe_pcall(function()
                Managers.state.network.network_transmit:send_rpc_server(
                    'rpc_spawn_pickup_with_physics',
                    NetworkLookup.pickup_names[tostring(item)],
                    Unit.local_position(local_player_unit, 0),
                    Unit.local_rotation(local_player_unit, 0),
                    NetworkLookup.pickup_spawn_types['dropped']
                )
            end)
        end
    end
end

---Creates dynamicly the widgets for the custom items group
---@return table
AlternativeItemSpawner.widget_settings.create_items_pool_category_custom_widgets = function()
    local items_pool_category_custom_widgets = {}

    for index, item in ipairs(AlternativeItemSpawner.items_pool_category_all) do
        local newItem = {}
        newItem.save = "cb_item_spawner_item_" .. item.value
        newItem.widget_type = "checkbox"
        newItem.text = item.text
        newItem.default = false

        table.insert(items_pool_category_custom_widgets, newItem)
    end

    return items_pool_category_custom_widgets
end

---Creates dynamicly the hide options for the custom items group
---@return table
AlternativeItemSpawner.widget_settings.create_items_pool_category_custom_hide_options = function()
    local items_pool_category_custom_hide_options = {}

    for index, item in ipairs(AlternativeItemSpawner.items_pool_category_all) do
        table.insert(items_pool_category_custom_hide_options, "cb_item_spawner_item_" .. item.value)
    end

    return items_pool_category_custom_hide_options
end

---Creates widgets under mod settings
---@param self table
AlternativeItemSpawner.create_options = function(self)
    local group = "cheats"
    Mods.option_menu:add_group(group, "Gameplay Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_ONLY_INN)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_NEXT_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_PREVIOUS_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_SPAWN_ITEM)

    local hide_options = self.widget_settings.create_items_pool_category_custom_hide_options()

    for index, value in ipairs(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY.hide_options) do
        if value[1] == "custom" and value.mode == "show" then
            value.options = hide_options
        elseif value[1] ~= "custom" and value.mode == "hide" then
            value.options = hide_options
        end
    end

    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY)

    local custom_widgets = self.widget_settings.create_items_pool_category_custom_widgets()

    for index, checkbox_widget in ipairs(custom_widgets) do
        Mods.option_menu:add_item(group, checkbox_widget)
        self.widget_settings[string.upper(checkbox_widget.save)] = checkbox_widget
    end

    self:update_items_pool_current_list()
end

AlternativeItemSpawner:create_options()
