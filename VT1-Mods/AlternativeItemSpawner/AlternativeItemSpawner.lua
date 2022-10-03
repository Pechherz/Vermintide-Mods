--add other display for current items
--add more items e.g grain sacks
--add warning for spawning badges and other stuff that can interfere with CheatProtect

local mod_name = "AlternativeItemSpawner"
local oi = OptionsInjector

local all_items = {
    healing_draught = {
        key = "healing_draught",
        value = "Healing Draught",
    },
    first_aid_kit = {
        key = "first_aid_kit",
        value = "Medical Supplies",
    },
    speed_boost_potion = {
        key = "speed_boost_potion",
        value = "Potion of Speed",
    },
    damage_boost_potion = {
        key = "damage_boost_potion",
        value = "Potion of Strength",
    },
    frag_grenade_t1 = {
        key = "frag_grenade_t1",
        value = "Explosive Bomb",
    },
    frag_grenade_t2 = {
        key = "frag_grenade_t2",
        value = "Improved Explosive Bomb",
    },
    fire_grenade_t1 = {
        key = "fire_grenade_t1",
        value = "Incendiary Bomb",
    },
    fire_grenade_t2 = {
        key = "fire_grenade_t2",
        value = "Improved Incendiary Bomb",
    },
    all_ammo_small = {
        key = "all_ammo_small",
        value = "Ammunition",
    },
    all_ammo = {
        key = "all_ammo",
        value = "Ammunition Box",
        physics_off = true,
    },
    tome = {
        key = "tome",
        value = "Tome",
    },
    grimoire = {
        key = "grimoire",
        value = "Grimoire",
    },
    loot_die = {
        key = "loot_die",
        value = "Loot Die",
    },
    lorebook_page = {
        key = "lorebook_page",
        value = "Lore-Book Page",
        physics_off = true,
    },
    torch = {
        key = "torch",
        value = "Torch",
    },
    grain_sack = {
        key = "grain_sack",
        value = "Grain Sack",
    },
    explosive_barrel = {
        key = "explosive_barrel",
        value = "Explosive Barrel",
    },
    brawl_unarmed = {
        key = "brawl_unarmed",
        value = "Pub Brawl Barrel",
        message = ""
    },
    wooden_sword_01 = {
        key = "wooden_sword_01",
        value = "Wooden Sword 1",
    },
    wooden_sword_02 = {
        key = "wooden_sword_02",
        value = "Wooden Sword 2",
    },
    endurance_badge_01 = {
        key = "endurance_badge_01",
        value = "Endurance Badge 1",
    },
    endurance_badge_02 = {
        key = "endurance_badge_02",
        value = "Endurance Badge 2",
    },
    endurance_badge_03 = {
        key = "endurance_badge_03",
        value = "Endurance Badge 3",
    },
    endurance_badge_04 = {
        key = "endurance_badge_04",
        value = "Endurance Badge 4",
    },
    endurance_badge_05 = {
        key = "endurance_badge_05",
        value = "Endurance Badge 5",
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
    all_items.all_ammo_small,
    all_items.all_ammo,
    all_items.tome,
    all_items.grimoire,
    all_items.loot_die,
    all_items.lorebook_page,
    all_items.torch,
    -- all_items.grain_sack,
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
AlternativeItemSpawner.items_pool_category_custom = {}
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
AlternativeItemSpawner.items_pool_category_objects = {
    all_items.all_ammo,
    all_items.tome,
    all_items.grimoire,
    all_items.loot_die,
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
AlternativeItemSpawner.spawned_item = {}

AlternativeItemSpawner.widget_settings = {
    ITEM_SPAWNER_ENABLED = {
        ["save"] = "cb_item_spawner_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable Alternative Item Spawner",
        ["tooltip"] = "Information:\n" ..
            "Adds keyboard shortcuts to cycle through a set of items to spawn them.\n\n" ..
            "Caution:\n" ..
            "Spawning to many loot items like to 4x grimoires, loot dices or badges may be blocked by Cheat Protection.",
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
                    "cb_item_spawner_next_item",
                    "cb_item_spawner_previous_item",
                    "cb_item_spawner_spawn_item",
                    "cb_item_spawner_delete_last_item",
                    "cb_item_spawner_allow_on_missions",
                    "cb_item_spawner_current_category",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_item_spawner_next_item",
                    "cb_item_spawner_previous_item",
                    "cb_item_spawner_spawn_item",
                    "cb_item_spawner_delete_last_item",
                    "cb_item_spawner_allow_on_missions",
                    "cb_item_spawner_current_category",
                }
            },
        },
    },
    ITEM_SPAWNER_NEXT_ITEM = {
        ["save"] = "cb_item_spawner_next_item",
        ["widget_type"] = "keybind",
        ["text"] = "Next Item",
        ["default"] = {
            "numpad 3",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_item_spawner_action", "next_item" },
    },
    ITEM_SPAWNER_PREVIOUS_ITEM = {
        ["save"] = "cb_item_spawner_previous_item",
        ["widget_type"] = "keybind",
        ["text"] = "Previous Item",
        ["default"] = {
            "numpad 1",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_item_spawner_action", "previous_item" },
    },
    ITEM_SPAWNER_SPAWN_ITEM = {
        ["save"] = "cb_item_spawner_spawn_item",
        ["widget_type"] = "keybind",
        ["text"] = "Spawn Item",
        ["tooltip"] = "Information\n" ..
            "Only items which have been spawned and not picked up by a player can be removed",
        ["default"] = {
            "numpad 2",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_item_spawner_action", "spawn_item" },
    },
    ITEM_SPAWNER_DELETE_LAST_ITEM = {
        ["save"] = "cb_item_spawner_delete_last_item",
        ["widget_type"] = "keybind",
        ["text"] = "Delete Last Item",
        ["tooltip"] = "Information\n" ..
            "Only items which have been spawned and not picked up by a player can be removed",
        ["default"] = {
            "numpad /",
            oi.key_modifiers.NONE,
        },
        ["exec"] = { "patch/action/alternative_item_spawner_action", "delete_last_item" },
    },
    ITEM_SPAWNER_ALLOW_ON_MISSIONS = {
        ["save"] = "cb_item_spawner_allow_on_missions",
        ["widget_type"] = "stepper",
        ["text"] = "Allows item spawning on missions",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On", value = true },
        },
        ["disabled_outside_inn"] = true, --only allows to change the settings in the tavern
        ["default"] = 1,
    },
    ITEM_SPAWNER_CURRENT_CATEGORY = {
        ["save"] = "cb_item_spawner_current_category",
        ["widget_type"] = "stepper",
        ["text"] = "Item Category",
        ["tooltip"] = "Limits the Item Spawner to certain set of items\n" ..
            "All: items that can be spawned without crashing the game\n" ..
            "Custom: user defined set of items\n" ..
            "Consumables: healing items, potions, bombs and ammuniation\n" ..
            "Objects: Endurance Badges, Barrels, event items\n" ..
            "Endurance Badges: Badges usually found on survival missions\n",
        ["value_type"] = "string",
        ["options"] = {
            { text = "All", value = "all" },
            { text = "Custom", value = "custom" },
            { text = "Consumables", value = "consumables" },
            { text = "Objects", value = "objects" },
            { text = "Endurance Badges", value = "endurance_badges" },
        },
        ["default"] = 1,
        ["hide_options"] = {
            {
                "all",
                mode = "show",
                options = {}
            },
            {
                "all",
                mode = "hide",
                options = {}
            },
            {
                "custom",
                mode = "show",
                options = {}
            },
            {
                "custom",
                mode = "hide",
                options = {}
            },
            {
                "consumables",
                mode = "show",
                options = {}
            },
            {
                "consumables",
                mode = "hide",
                options = {}
            },
            {
                "objects",
                mode = "show",
                options = {}
            },
            {
                "objects",
                mode = "hide",
                options = {}
            },
            {
                "endurance_badges",
                mode = "show",
                options = {}
            },
            {
                "endurance_badges",
                mode = "hide",
                options = {}
            },
        },
    },
}

---Change to the next item in the current item group
---@param self table
AlternativeItemSpawner.next_item = function(self)
    if self.get(self.widget_settings.ITEM_SPAWNER_ENABLED) then
        if Managers.state.game_mode._game_mode_key == "inn" or
            self.get(self.widget_settings.ITEM_SPAWNER_ALLOW_ON_MISSIONS) then
            -- check if item group has been changed
            if self.items_pool_current_category ~= self.get(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY) then
                self:update_items_pool_current_list()
            end

            --check if the current index is beyond the item pool
            self.items_pool_current_index = self.items_pool_current_index + 1
            if self.items_pool_current_index > self.items_pool_current_size then
                self.items_pool_current_index = 1
            end

            local message = ""
            local item = self.items_pool_current_list[self.items_pool_current_index]

            if item then
                message = "Current Item: " .. item.value
            else
                message = "[There are no available items in current item pool]"
            end

            Managers.chat:add_local_system_message(1, message, true)
            Managers.chat.chat_gui:show_chat()
        end
    end
end

---Change to the previous item in the current item group
---@param self table
AlternativeItemSpawner.previous_item = function(self)
    if AlternativeItemSpawner.get(AlternativeItemSpawner.widget_settings.ITEM_SPAWNER_ENABLED) then
        if Managers.state.game_mode._game_mode_key == "inn" or
            AlternativeItemSpawner.get(AlternativeItemSpawner.widget_settings.ITEM_SPAWNER_ALLOW_ON_MISSIONS) then
            -- check if item group has been changed
            if self.items_pool_current_category ~= self.get(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY) then
                self:update_items_pool_current_list()
            end

            --check if the current index is beyond the item pool
            self.items_pool_current_index = self.items_pool_current_index - 1
            if self.items_pool_current_index < 1 then
                self.items_pool_current_index = self.items_pool_current_size
            end

            local message = ""
            local item = self.items_pool_current_list[self.items_pool_current_index]           
            
            if item then
                message = "Current Item: " .. item.value
            else
                message = "[There are no available items in current item pool]"
            end

            Managers.chat:add_local_system_message(1, message, true)
            Managers.chat.chat_gui:show_chat()
        end
    end
end

---Spawn the current item from the item group
---@param self table
AlternativeItemSpawner.spawn_item = function(self)
    if AlternativeItemSpawner.get(AlternativeItemSpawner.widget_settings.ITEM_SPAWNER_ENABLED) then
        if Managers.state.game_mode._game_mode_key == "inn" or
            AlternativeItemSpawner.get(AlternativeItemSpawner.widget_settings.ITEM_SPAWNER_ALLOW_ON_MISSIONS) then
            -- check if item group has been changed
            if self.items_pool_current_category ~= self.get(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY) then
                self:update_items_pool_current_list()
            end

            local message = ""
            local item = self.items_pool_current_list[self.items_pool_current_index]
            if item then
                
                local spawn_pickup_function = "rpc_spawn_pickup_with_physics"
                local conflict_director = Managers.state.conflict
                local position, distance, normal, actor = conflict_director:player_aim_raycast(conflict_director._world, false, "filter_ray_horde_spawn")

                if position == nil then
                    local local_player_unit = Managers.player:local_player().player_unit
                    position = Unit.local_position(local_player_unit, 0)
                end            

                --ammo boxes are really bouncy with physics
                if item.physics_off then
                    spawn_pickup_function = "rpc_spawn_pickup"
                end

                Managers.state.network.network_transmit:send_rpc_server(
                    spawn_pickup_function,
                    NetworkLookup.pickup_names[tostring(item.key)],
                    position,
                    Quaternion.axis_angle(Vector3(0, 0, 0), 0),
                    NetworkLookup.pickup_spawn_types["debug"]
                )
                
                message = item.value .. " spawned"
            else
                message = "[There are no available items in current item pool]"
            end

            Managers.chat:add_local_system_message(1, message, true)
            Managers.chat.chat_gui:show_chat()
        end
    end
end

---Delete the last spawned item
---@param self table
AlternativeItemSpawner.delete_last_item = function(self)
    local last_item = AlternativeItemSpawner.spawned_item[#AlternativeItemSpawner.spawned_item]

    local message = ""
    if last_item then
        local last_item_name = last_item.item_name
        message = last_item_name .. " despawned"

        table.remove(AlternativeItemSpawner.spawned_item, #AlternativeItemSpawner.spawned_item)
        if Unit.alive(last_item.unit) then
            Managers.state.unit_spawner:mark_for_deletion(last_item.unit)
            
            Managers.chat:add_local_system_message(1, message, true)
            Managers.chat.chat_gui:show_chat()
        else
            self:delete_last_item()
        end
    else
        message = "There are no player-spawned items available"
    end

    Managers.chat:add_local_system_message(1, message, true)
    Managers.chat.chat_gui:show_chat()
end

---Updates the item group according to the chosen item group from the mod settings
---@param self table
AlternativeItemSpawner.update_items_pool_current_list = function(self)
    local item_spawner_current_category = self.get(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY)

    if item_spawner_current_category == "all" then
        self.items_pool_current_category = "all"
        self.items_pool_current_list = self.items_pool_category_all
    elseif item_spawner_current_category == "custom" then
        self.items_pool_current_category = "custom"
        self.items_pool_current_list = {}
        for _, item in ipairs(self.items_pool_category_all) do
            if self.get(self.widget_settings[string.upper("cb_item_spawner_item_" .. item.key)]) then
                table.insert(self.items_pool_current_list, item)
            end
        end
    elseif item_spawner_current_category == "consumables" then
        self.items_pool_current_category = "consumables"
        self.items_pool_current_list = self.items_pool_category_consumable
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

---Creates dynamicly the widgets and hide options for the custom items group
---@param self table
---@return table widgets 
---@return table hide_options 
AlternativeItemSpawner.widget_settings.create_custom_category_widgets = function (self)
    local items_pool_category_custom_checkbox_widgets = {}
    local items_pool_category_custom_hide_options = {}

    for _, item in ipairs(AlternativeItemSpawner.items_pool_category_all) do
        local newItem = {}
        newItem.save = "cb_item_spawner_item_" .. item.key
        newItem.widget_type = "checkbox"
        newItem.text = item.value
        newItem.default = false
        newItem.item_key = item.key

        table.insert(items_pool_category_custom_checkbox_widgets, newItem)
        table.insert(items_pool_category_custom_hide_options, newItem.save)      
    end

    return items_pool_category_custom_checkbox_widgets, items_pool_category_custom_hide_options
end

Mods.hook.set(mod_name, "PickupSystem._spawn_pickup", function(func, self, pickup_settings, pickup_name, position, rotation, with_physics, spawn_type)
    ---Allow loot die to be spawned without crashing the game
    if spawn_type == "debug" then
        pickup_settings.can_spawn_func = function () return true end
    end
    
    local pickup_unit = func(self, pickup_settings, pickup_name, position, rotation, with_physics, spawn_type)

    --in order to delete items, it is required to track the items
    if spawn_type == "debug" then
        local item = {
            item_name = AlternativeItemSpawner.items_pool_current_list[AlternativeItemSpawner.items_pool_current_index].value,
            unit = pickup_unit
        }

        table.insert(AlternativeItemSpawner.spawned_item, item)
    end
    
    return pickup_unit
end)

Mods.hook.set(mod_name, "VolumeSystem.create_nav_tag_volume_from_data", function(func, self, pos, size, layer_name)
    if self.nav_tag_volume_handler then
        return func(self, pos, size, layer_name)
    end

    return ""
end)

Mods.hook.set(mod_name, "VolumeSystem.destroy_nav_tag_volume", function(func, self, volume_name)
    if self.nav_tag_volume_handler then
        func(self, volume_name)
    end
end)

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
AlternativeItemSpawner.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Creates widgets under mod settings
---@param self table
AlternativeItemSpawner.create_options = function(self)
    local group = "cheats"
    Mods.option_menu:add_group(group, "Gameplay Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_NEXT_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_PREVIOUS_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_SPAWN_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_DELETE_LAST_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_ALLOW_ON_MISSIONS)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY)
    
    local widgets, hide_options = AlternativeItemSpawner.widget_settings:create_custom_category_widgets()

    --add checkboxes to the "Custom" item category
    for _, checkbox in ipairs(widgets) do
        Mods.option_menu:add_item(group, checkbox)
        self.widget_settings[string.upper(checkbox.save)] = checkbox
    end

    --add checkbox to track it easily
    self.widget_settings.checkboxes = widgets

    --fill automatically the show and hide options for the "Custom" item category
    for _, value in ipairs(self.widget_settings.ITEM_SPAWNER_CURRENT_CATEGORY.hide_options) do
        if value[1] == "custom" and value.mode == "show" then
            value.options = hide_options
        elseif value[1] ~= "custom" and value.mode == "hide" then
            value.options = hide_options
        end
    end

    --initially update the current item list
    self:update_items_pool_current_list()
end

AlternativeItemSpawner:create_options()
