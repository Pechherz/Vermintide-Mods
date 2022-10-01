-- if not table.contains(NetworkLookup.inventory_packages, "units/weapons/projectile/poison_wind_globe/poison_wind_globe") then
--   table.insert(NetworkLookup.inventory_packages, "units/weapons/projectile/poison_wind_globe/poison_wind_globe")
--   NetworkLookup.inventory_packages["units/weapons/projectile/poison_wind_globe/poison_wind_globe"] = #NetworkLookup.inventory_packages
-- end



-- local volley_bow = Weapons.repeating_crossbow_template_1_t3
-- volley_bow.actions.action_one.default.projectile_info.projectile_unit_name = "units/weapons/player/drakegun_projectile/drakegun_projectile_3ps"
-- -- volley_bow.actions.action_one.default.projectile_info.dummy_linker_unit_name = nil
-- volley_bow.actions.action_one.default.projectile_info.dummy_linker_unit_name = "units/weapons/player/drakegun_projectile/drakegun_projectile_3ps"
-- volley_bow.actions.action_one.default.projectile_info.impact_data.damage.enemy_unit_hit.default_target.attack_template = "boomer"
-- volley_bow.actions.action_one.default.projectile_info.impact_data.damage.enemy_unit_hit.default_target.attack_template_damage_type = "boomer"
-- volley_bow.actions.action_one.default.projectile_info.impact_data.damage.damagable_prop_hit.attack_template = "boomer"
-- volley_bow.actions.action_one.default.projectile_info.impact_data.damage.damagable_prop_hit.attack_template_damage_type = "boomer"
-- volley_bow.actions.action_one.default.projectile_info.impact_data.aoe = ExplosionTemplates.fireball_charged
-- volley_bow.actions.action_one.default.projectile_info.impact_data.projectile_spawn = {
--     spawner_function = "split_bounce",
--     sub_action_name = "bouncing_fireball_2"
-- }
-- volley_bow.actions.action_one.default.projectile_info.muzzle_name = "fx_01"

-- Mods.debug.clear_log()
-- Mods.debug.write_log(Mods.debug:table_to_string(volley_bow, "volley_bow", 7))
-- Mods.debug.write_log(Mods.debug:table_to_string(NetworkLookup.attack_damage_values, "NetworkLookup.attack_damage_values", 1))



-- local repeater = Weapons.repeating_handgun_template_1_t3
-- repeater.ammo_data.ammo_per_clip = 64
-- repeater.actions.action_one.default.projectile_info = volley_bow.actions.action_one.default.projectile_info