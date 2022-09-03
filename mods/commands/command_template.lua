-- todos
-- 1.
-- 2. add the following line to CommandList.lua:
-- { "/<command_name>", true, "commands", "<command_name>" },
--

local args = { ... }
local params = {}
--give a non-negative amount of parameters
local expected_number_of_parameters = 0

for value in string.gmatch(args[1], "%S+") do
    table.insert(params, value)
end

---generates and returns a help message
---@return string
local get_help = function()
    local help_message = "\n-START-OF-HELP-MESSAGE-\n"

    if expected_number_of_parameters == 1 then
        help_message = help_message .. "You need to pass atleast 1 argument.\n"
    else
        help_message = help_message .. "You need to pass " .. expected_number_of_parameters .. " arguments.\n"
    end

    --replace command below with your own one
    help_message = help_message .. "/<command_name> <parameter_1> <parameter_2> <parameter_n>\n\n"

    --add more context to the user here

    help_message = help_message .. "-END-OF-HELP-MESSAGE-\n"

    return help_message
end

local command_function = function()
    -- insert your penis here
end

local error_function = function(...)
    -- inform the user about the error that happened

    -- replace <command_name> below with your command name
    EchoConsole("Refer to the following help command for more information:\n/<command_name> help")
end

if params[1] == "help" then
    EchoConsole(get_help())
elseif #params == expected_number_of_parameters then
    command_function()
else
    error_function()
end
