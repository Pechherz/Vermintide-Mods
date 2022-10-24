local token_name_list = {
    {
        value = "iron_tokens",
        text = "White Tokens"
    },
    {
        value = "bronze_tokens",
        text = "Green Tokens"
    },
    {
        value = "silver_tokens",
        text = "Blue Tokens"
    },
    {
        value = "gold_tokens",
        text = "Orange Tokens"
    },
}

local args = { ... }
local params = {}
local expected_number_of_parameters = 2

for value in string.gmatch(args[1], "%S+") do
    table.insert(params, value)
end

local get_help = function()
    EchoConsole("\n-START-OF-HELP-MESSAGE-")

    if expected_number_of_parameters == 1 then
        EchoConsole("You need to pass 1 argument.")
    else
        EchoConsole("You need to pass " .. expected_number_of_parameters .. " arguments.")
    end

    EchoConsole("/givetokens <token name> <non-zero number>")
    EchoConsole("\n")

    EchoConsole("There are only 4 available tokens you can award yourself with.")

    for index, token in ipairs(token_name_list) do
        EchoConsole(index .. ". " .. token.value .. " (" .. token.text .. ")")
    end

    EchoConsole("\nThe following example would add 30 white tokens to your inventory:\n /givetokens iron_tokens 30")

    EchoConsole("-END-OF-HELP-MESSAGE-\n")
end

if params[1] == "help" then
    get_help()
elseif #params == expected_number_of_parameters then
    local token_name = params[1]
    local number_of_tokens = tonumber(params[2])

    for index, token in ipairs(token_name_list) do
        if token_name == token.value then
            if number_of_tokens < 0 then
                EchoConsole("No tokens were added to your inventory.")
            elseif number_of_tokens == 1 then
                BackendUtils.add_tokens(number_of_tokens, token_name)
                Managers.backend:commit()

                EchoConsole("A single " .. token.text .. " was added to your inventory.")
            else
                BackendUtils.add_tokens(number_of_tokens, token_name)
                Managers.backend:commit()

                EchoConsole(number_of_tokens .. "x " .. token.text .. " were successfully added to your inventory.")
            end
            return
        end
    end
    EchoConsole("The token '" .. token_name .. "' doesn't exist.")
else
    EchoConsole("Refer to the following help command for more information: \n/givetokens help")
end
