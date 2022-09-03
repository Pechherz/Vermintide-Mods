local player = Managers.player

if player.is_server then
    local locomotion_extension = ScriptUnit.extension(player:local_player().player_unit, "locomotion_system")
    local last_position_on_navmesh = locomotion_extension._latest_position_on_navmesh:unbox()
    locomotion_extension:teleport_to(last_position_on_navmesh)
    EchoConsole("unstuck command executed")
end
