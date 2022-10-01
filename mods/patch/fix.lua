--replace the default frag_grenade_t1 unit projectile with the unit of a improved explosive grenade
Weapons.frag_grenade_t2.actions.action_one.throw.projectile_info.projectile_unit_name = "units/weapons/player/wpn_emp_grenade_01_t2/wpn_emp_grenade_01_t2_3p"

--replace the default frag_grenade_t1 unit projectile with the unit of a incendiary grenade
Weapons.fire_grenade_t1.actions.action_one.throw.projectile_info = table.clone(Projectiles.grenade_fire)
Weapons.fire_grenade_t1.actions.action_one.throw.projectile_info.projectile_unit_name = "units/weapons/player/wpn_emp_grenade_03_t1/wpn_emp_grenade_03_t1_3p"

--replace the default frag_grenade_t1 unit projectile with the unit of a improved incendiary grenade
Weapons.fire_grenade_t2.actions.action_one.throw.projectile_info = table.clone(Projectiles.grenade_fire)
Weapons.fire_grenade_t2.actions.action_one.throw.projectile_info.projectile_unit_name = "units/weapons/player/wpn_emp_grenade_03_t2/wpn_emp_grenade_03_t2_3p"

