--replace the default frag_grenade_t1 unit projectile with the unit of a improved explosive grenade
Weapons.frag_grenade_t2.actions.action_one.throw.projectile_info.projectile_unit_name = "units/weapons/player/wpn_emp_grenade_01_t2/wpn_emp_grenade_01_t2_3p"

--replace the default frag_grenade_t1 unit projectile with the unit of a incendiary grenade
Weapons.fire_grenade_t1.actions.action_one.throw.projectile_info = table.clone(Projectiles.grenade_fire)
Weapons.fire_grenade_t1.actions.action_one.throw.projectile_info.projectile_unit_name = "units/weapons/player/wpn_emp_grenade_03_t1/wpn_emp_grenade_03_t1_3p"

--replace the default frag_grenade_t1 unit projectile with the unit of a improved incendiary grenade
Weapons.fire_grenade_t2.actions.action_one.throw.projectile_info = table.clone(Projectiles.grenade_fire)
Weapons.fire_grenade_t2.actions.action_one.throw.projectile_info.projectile_unit_name = "units/weapons/player/wpn_emp_grenade_03_t2/wpn_emp_grenade_03_t2_3p"

-- ItemMasterList.dr_helmet_0012.inventory_icon = "icon_trophy_vial_of_fimir_tears_01_01"
--fix name, description and icon of dr_helmet_0012 (Bardin) 
--fix name, description and icon of bw_gate_0011 (Sienna)
--fix name, description and icon of ww_hood_0012 (Kerillian)
--fix name, description and icon of wh_hat_0013 (Victor)