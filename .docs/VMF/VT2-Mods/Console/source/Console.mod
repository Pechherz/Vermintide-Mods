return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Console must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Console", {
			mod_script       = "scripts/mods/Console/Console",
			mod_data         = "scripts/mods/Console/Console_data",
			mod_localization = "scripts/mods/Console/Console_localization"
		})
	end,
	packages = {
		"resource_packages/Console/Console"
	}
}
