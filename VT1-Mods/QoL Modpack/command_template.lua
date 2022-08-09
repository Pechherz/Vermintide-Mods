local args = { ... }
local params = {}
--give a non-negative amount of parameters
local expected_number_of_parameters = 0

for value in string.gmatch(args[1], "%S+") do
    table.insert(params, value)
end

local get_help = function()
    EchoConsole("\n")
    EchoConsole("You need to pass " .. expected_number_of_parameters .. " arguments.")
    --replace command example below with your own one
    EchoConsole("/command_name <parameter_1> <parameter_2> parameter_n")

    --add more context to the user here

    EchoConsole("\n")
end

if params[1] == "help" then
    get_help()
elseif #params == expected_number_of_parameters then
    --insert your penis here
else
    --replace /command_name below with your command name
    EchoConsole("Refer to the help page. /command_name help")
end
