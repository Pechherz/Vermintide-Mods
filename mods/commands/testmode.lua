if script_data.disable_ai == nil then
    script_data.disable_ai = false
end

local conflict_director = Managers.state.conflict
conflict_director.disabled = not conflict_director.disabled
script_data.player_invincible = not script_data.player_invincible
script_data.infinite_ammo = not script_data.infinite_ammo
script_data.use_super_jumps = not script_data.use_super_jumps
script_data.disable_ai = not script_data.disable_ai 

local message = ""
message = message .. "\n-TEST-MODE-\n"
message = message .. "conflict_director.disabled: " .. tostring(conflict_director.disabled) .. "\n"
message = message .. "script_data.player_invincible: " .. tostring(script_data.player_invincible) .. "\n"
message = message .. "script_data.infinite_ammo: " .. tostring(script_data.infinite_ammo) .. "\n"
message = message .. "script_data.use_super_jumps: " .. tostring(script_data.use_super_jumps) .. "\n"
message = message .. "script_data.disable_ai: " .. tostring(script_data.disable_ai) .. "\n"
message = message .. "-TEST-MODE-\n"
EchoConsole(message)

-- local conflict_director = Managers.state.conflict

-- local scripts = {
--     conflict_director.disabled,
--     script_data.player_invincible,
--     script_data.use_super_jumps,
--     script_data.infinite_ammo,
-- }

-- local message = "\n-TEST-MODE-\n"
-- for _, script in pairs(scripts) do
--     script = not script
--     message = message .. tostring(script) .. ": " .. tostring(script) .. "\n"
-- end
-- message = message .. "-TEST-MODE-\n"

-- EchoConsole(message)

Mods.hook.set("testmode", "AISystem.update_brains", function (func, self, t, dt)
    if not script_data.disable_ai then
        func(self, t, dt)
    end
end)