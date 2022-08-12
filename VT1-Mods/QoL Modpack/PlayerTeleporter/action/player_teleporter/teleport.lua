local local_player = Managers.player:local_player()

local locomotion_extension = ScriptUnit.extension(local_player.player_unit, "locomotion_system")
local conflict_director = Managers.state.conflict
local position, distance, normal, actor = conflict_director:player_aim_raycast(conflict_director._world, false, "filter_ray_projectile")
locomotion_extension.teleport_to(locomotion_extension, position)
