local mod_name = "HomingBombs"

HomingBombs = {}
HomingBombs.widget_settings = {
    SUB_GROUP = {
        ["save"] = "cb_homing_bombs_subgroup",
        ["widget_type"] = "dropdown_checkbox",
        ["text"] = "Homing Bombs",
        ["tooltip"] = "Homing Explosive Bombs\n" ..
            "Turns explosive and incendiary bombs into ground-to-skaven missles",
        ["default"] = false,
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = {
                    "cb_homing_frag_grenade_t1_enabled",
                    "cb_homing_frag_grenade_t2_enabled",
                    "cb_homing_fire_grenade_t1_enabled",
                    "cb_homing_fire_grenade_t2_enabled",
                }
            },
            {
                true,
                mode = "show",
                options = {
                    "cb_homing_frag_grenade_t1_enabled",
                    "cb_homing_frag_grenade_t2_enabled",
                    "cb_homing_fire_grenade_t1_enabled",
                    "cb_homing_fire_grenade_t2_enabled",
                }
            },
        },
    },
    HOMING_FRAG_GRENADE_T1_ENABLED = {
        ["save"] = "cb_homing_frag_grenade_t1_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Homing Explosive Bombs",
        ["tooltip"] = "Homing Explosive Bombs\n" ..
            "Turns explosive bombs into ground-to-skaven missles",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On",  value = true },
        },
        ["default"] = 1,
    },
    HOMING_FRAG_GRENADE_T2_ENABLED = {
        ["save"] = "cb_homing_frag_grenade_t2_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Homing Improved Explosive Bombs",
        ["tooltip"] = "Homing Improved Explosive Bombs\n" ..
            "Turns improved explosive bombs into ground-to-skaven missles",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On",  value = true },
        },
        ["default"] = 1,
    },
    HOMING_FIRE_GRENADE_T1_ENABLED = {
        ["save"] = "cb_homing_fire_grenade_t1_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Homing Fire Bombs",
        ["tooltip"] = "Homing Fire Bombs\n" ..
            "Turns incendiary bombs into ground-to-skaven missles",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On",  value = true },
        },
        ["default"] = 1,
    },
    HOMING_FIRE_GRENADE_T2_ENABLED = {
        ["save"] = "cb_homing_fire_grenade_t2_enabled",
        ["widget_type"] = "stepper",
        ["text"] = "Homing Improved Fire Bombs",
        ["tooltip"] = "Homing Improved Fire Bombs\n" ..
            "Turns improved incendiary bombs into ground-to-skaven missles",
        ["value_type"] = "boolean",
        ["options"] = {
            { text = "Off", value = false },
            { text = "On",  value = true },
        },
        ["default"] = 1,
    },
}

---Toggle homing bombs on or off
---@param self table
HomingBombs.toggle_homing_bombs = function(self)
    local frag_grenade_t1 = Weapons.frag_grenade_t1
    local frag_grenade_t2 = Weapons.frag_grenade_t2
    local fire_grenade_t1 = Weapons.fire_grenade_t1
    local fire_grenade_t2 = Weapons.fire_grenade_t2

    local homing_default_kind = "true_flight_bow_aim"
    local homing_throw_kind = "true_flight_bow"
    local homing_true_flight_template = "sniper"
    local homing_charge_value = "light_attack"
    local homing_default_spread_template = "longbow"
    local homing_life_time = 25

    local default_kind = "charge"
    local throw_kind = "charged_projectile"
    local true_flight_template = "sniper"
    local charge_value = "light_attack"
    local default_spread_template = "longbow"
    local life_time = 3

    if self.get(self.widget_settings.HOMING_FRAG_GRENADE_T1_ENABLED) then
        frag_grenade_t1.actions.action_one.default.kind = homing_default_kind
        frag_grenade_t1.actions.action_one.default.true_flight_template = homing_true_flight_template
        frag_grenade_t1.actions.action_one.throw.kind = homing_throw_kind
        frag_grenade_t1.actions.action_one.throw.true_flight_template = homing_true_flight_template
        frag_grenade_t1.actions.action_one.throw.charge_value = homing_charge_value
        frag_grenade_t1.default_spread_template = homing_default_spread_template
        frag_grenade_t1.actions.action_one.throw.projectile_info.timed_data.life_time = homing_life_time
    else
        frag_grenade_t1.actions.action_one.default.kind = default_kind
        frag_grenade_t1.actions.action_one.default.true_flight_template = true_flight_template
        frag_grenade_t1.actions.action_one.throw.kind = throw_kind
        frag_grenade_t1.actions.action_one.throw.true_flight_template = true_flight_template
        frag_grenade_t1.actions.action_one.throw.charge_value = charge_value
        frag_grenade_t1.default_spread_template = default_spread_template
        frag_grenade_t1.actions.action_one.throw.projectile_info.timed_data.life_time = life_time
    end
    if self.get(self.widget_settings.HOMING_FRAG_GRENADE_T2_ENABLED) then
        frag_grenade_t2.actions.action_one.default.kind = homing_default_kind
        frag_grenade_t2.actions.action_one.default.true_flight_template = homing_true_flight_template
        frag_grenade_t2.actions.action_one.throw.kind = homing_throw_kind
        frag_grenade_t2.actions.action_one.throw.true_flight_template = homing_true_flight_template
        frag_grenade_t2.actions.action_one.throw.charge_value = homing_charge_value
        frag_grenade_t2.default_spread_template = homing_default_spread_template
        frag_grenade_t2.actions.action_one.throw.projectile_info.timed_data.life_time = homing_life_time
    else
        frag_grenade_t2.actions.action_one.default.kind = default_kind
        frag_grenade_t2.actions.action_one.default.true_flight_template = true_flight_template
        frag_grenade_t2.actions.action_one.throw.kind = throw_kind
        frag_grenade_t2.actions.action_one.throw.true_flight_template = true_flight_template
        frag_grenade_t2.actions.action_one.throw.charge_value = charge_value
        frag_grenade_t2.default_spread_template = default_spread_template
        frag_grenade_t2.actions.action_one.throw.projectile_info.timed_data.life_time = life_time
    end

    if self.get(self.widget_settings.HOMING_FIRE_GRENADE_T1_ENABLED) then
        fire_grenade_t1.actions.action_one.default.kind = homing_default_kind
        fire_grenade_t1.actions.action_one.default.true_flight_template = homing_true_flight_template
        fire_grenade_t1.actions.action_one.throw.kind = homing_throw_kind
        fire_grenade_t1.actions.action_one.throw.true_flight_template = homing_true_flight_template
        fire_grenade_t1.actions.action_one.throw.charge_value = homing_charge_value
        fire_grenade_t1.default_spread_template = homing_default_spread_template
        fire_grenade_t1.actions.action_one.throw.projectile_info.timed_data.life_time = homing_life_time
    else
        fire_grenade_t1.actions.action_one.default.kind = default_kind
        fire_grenade_t1.actions.action_one.default.true_flight_template = true_flight_template
        fire_grenade_t1.actions.action_one.throw.kind = throw_kind
        fire_grenade_t1.actions.action_one.throw.true_flight_template = true_flight_template
        fire_grenade_t1.actions.action_one.throw.charge_value = charge_value
        fire_grenade_t1.default_spread_template = default_spread_template
        fire_grenade_t1.actions.action_one.throw.projectile_info.timed_data.life_time = life_time
    end

    if self.get(self.widget_settings.HOMING_FIRE_GRENADE_T2_ENABLED) then
        fire_grenade_t2.actions.action_one.default.kind = homing_default_kind
        fire_grenade_t2.actions.action_one.default.true_flight_template = homing_true_flight_template
        fire_grenade_t2.actions.action_one.throw.kind = homing_throw_kind
        fire_grenade_t2.actions.action_one.throw.true_flight_template = homing_true_flight_template
        fire_grenade_t2.actions.action_one.throw.charge_value = homing_charge_value
        fire_grenade_t2.default_spread_template = homing_default_spread_template
        fire_grenade_t2.actions.action_one.throw.projectile_info.timed_data.life_time = homing_life_time
    else
        fire_grenade_t2.actions.action_one.default.kind = default_kind
        fire_grenade_t2.actions.action_one.default.true_flight_template = true_flight_template
        fire_grenade_t2.actions.action_one.throw.kind = throw_kind
        fire_grenade_t2.actions.action_one.throw.true_flight_template = true_flight_template
        fire_grenade_t2.actions.action_one.throw.charge_value = charge_value
        fire_grenade_t2.default_spread_template = default_spread_template
        fire_grenade_t2.actions.action_one.throw.projectile_info.timed_data.life_time = life_time
    end
end

---Gets the value of a widget
---@param data table predifined widgets object
---@return unknown
HomingBombs.get = function(data)
    if data then
        return Application.user_setting(data.save)
    else
        return false
    end
end

Mods.hook.set(mod_name, "OptionsView.apply_changes",
    function(func, self, user_settings, render_settings, pending_user_settings)
        func(self, user_settings, render_settings, pending_user_settings)

        HomingBombs:toggle_homing_bombs()
    end)

---Creates widgets under mod settings
---@param self table
HomingBombs.create_options = function(self)
    local group = "cheats"
    Mods.option_menu:add_group(group, "Cheats")
    Mods.option_menu:add_item(group, self.widget_settings.SUB_GROUP, true)
    Mods.option_menu:add_item(group, self.widget_settings.HOMING_FRAG_GRENADE_T1_ENABLED)
    Mods.option_menu:add_item(group, self.widget_settings.HOMING_FRAG_GRENADE_T2_ENABLED)
    Mods.option_menu:add_item(group, self.widget_settings.HOMING_FIRE_GRENADE_T1_ENABLED)
    Mods.option_menu:add_item(group, self.widget_settings.HOMING_FIRE_GRENADE_T2_ENABLED)
end

HomingBombs:create_options()
HomingBombs:toggle_homing_bombs()
