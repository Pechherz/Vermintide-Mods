--[[
	Name:       Script Panel
	Version:    1.0.0 (2022-06-20)
	Author(s):     
        -Pechherz
    
    Description: 
        This is a alternative Item Spawner that is similar to the item spawner from Vermintide 2.
        It features predefined item groups (e.g. healing, bombs, potions ..) and a custom group, which can be changed by 
        the users wish.

    Required File Location:
        -ScriptPanel.lua                               goes into "\Warhammer End Times Vermintide\binaries\mods\patch\"
        -alternative_item_spawner_next_item.lua        goes into "\Warhammer End Times Vermintide\binaries\mods\patch\action\"
        -alternative_item_spawner_previous_item.lua    goes into "\Warhammer End Times Vermintide\binaries\mods\patch\action\"
        -alternative_item_spawner_spawn_item.lua       goes into "\Warhammer End Times Vermintide\binaries\mods\patch\action\"

    Version History:    
	    -1.0.0 (2022-06-20): Release
            Features:
                -none
            Bugs:
                -none

    Upcoming Features:
        -none
--]]

local mod_name = "ScriptPanel"
local oi = OptionsInjector

ScriptPanel = {}
ScriptPanel.scripts = {
    script_data.use_super_jumps,
    script_data.infinite_ammo

}

ScriptPanel.widget_settings = {
    ITEM_SPAWNER_ENABLED = {
        ["save"] = "cb_script_panel_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Enable Alternative Items Spawner",
        ["tooltip"] = "Enable Alternative Items Spawner\n" ..
            "Adds keyboard shortcuts to cycle through a set of items to spawn them.",
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
                    "cb_script_panel_",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_script_panel_",
                }
            },
        },
    },
}

---Updates the item group according to the chosen item group from the mod settings.
---@param self table
ScriptPanel.update_items_pool_current_list = function(self)
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
ScriptPanel.get = function(data)
    if data then
        return Application.user_setting(data.save)
    end
end

---Creates dynamicly the widgets for the custom items group
---@return table
ScriptPanel.widget_settings.create_items_pool_category_custom_widgets = function()
    local items_pool_category_custom_widgets = {}

    for index, item in ipairs(ScriptPanel.items_pool_category_all) do
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
ScriptPanel.widget_settings.create_items_pool_category_custom_hide_options = function()
    local items_pool_category_custom_hide_options = {}

    for index, item in ipairs(ScriptPanel.items_pool_category_all) do
        table.insert(items_pool_category_custom_hide_options, "cb_item_spawner_item_" .. item.value)
    end

    return items_pool_category_custom_hide_options
end

---Creates widgets under mod settings
---@param self table
ScriptPanel.create_options = function(self)
    local group = "cheats"
    Mods.option_menu:add_group(group, "Gameplay Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_ENABLED, true)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_NEXT_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_PREVIOUS_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_SPAWN_ITEM)
    Mods.option_menu:add_item(group, self.widget_settings.ITEM_SPAWNER_ALLOW_ON_MISSIONS)

end

-- ScriptPanel:create_options()
