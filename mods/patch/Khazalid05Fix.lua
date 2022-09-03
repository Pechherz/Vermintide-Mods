local mod_name = "Khazalid05Fix"

Mods.hook.set(mod_name, "Localize", function(func, text_id)
	if (text_id == "loading_screen_khazalid_05") then
		return "Introduction to Khazalid, lesson #5 | Dawr = 'As good as something can get without it being proven over time and hard use'. Also dwarfen slang for \"comrade\"."
	end

	return func(text_id)
end)

--EchoConsole(Localize("loading_screen_khazalid_05"))