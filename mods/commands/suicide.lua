local local_player_unit = Managers.player:local_player().player_unit
EchoConsole(AiUtils.unit_alive(local_player_unit))
if AiUtils.unit_alive(local_player_unit) then
    local health_extension = ScriptUnit.extension(local_player_unit, "health_system")
    health_extension:die(nil)
end
