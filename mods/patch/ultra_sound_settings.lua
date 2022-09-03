-- Xq 2019
-- Zaphio, SlashKex, VernonKun 2021
-- This adjustment is intended to work with QoL modpack
-- To "install" copy the file to "steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch"

local mod_name = "ultra_sound_settings"

Mods.hook.set(mod_name, "SoundQualitySettings.set_sound_quality", function(func, wwise_world, sound_quality)
	local quality_template = SoundQualitySettings.get_quality_template(sound_quality)
	local save_max_num_voices = quality_template.max_num_voices
	local save_occlusion = quality_template.occlusion
	if quality_template.max_num_voices >= 80 then
		quality_template.max_num_voices = 5000
		quality_template.occlusion = false
	end
	
	func(wwise_world, sound_quality)
	
	quality_template.max_num_voices = save_max_num_voices
	quality_template.occlusion = save_occlusion
end)

Mods.hook.set(mod_name, "ProximitySystem._update_nearby_enemies", function(func, self)
	local save_max_allowed_proximity_fx = script_data.max_allowed_proximity_fx
	script_data.max_allowed_proximity_fx = 60

	func(self)
	
	script_data.max_allowed_proximity_fx = save_max_allowed_proximity_fx
end)

Mods.hook.set(mod_name, "Music.set_group_state", function(func, self, state, value)
	local save_game_state_voice_thresholds_default = nil
	local save_game_state_voice_thresholds_value = nil
	
	if self._game_state_voice_thresholds then
		save_game_state_voice_thresholds_default = self._game_state_voice_thresholds.default
		self._game_state_voice_thresholds.default = -96.3
		
		if value and self._game_state_voice_thresholds[value] then
			save_game_state_voice_thresholds_value = self._game_state_voice_thresholds[value]
			self._game_state_voice_thresholds[value] = -96.3
		end
	end
		
	func(self, state, value)
	
	if self._game_state_voice_thresholds then
		self._game_state_voice_thresholds.default = save_game_state_voice_thresholds_default
		
		if value and self._game_state_voice_thresholds[value] then
			self._game_state_voice_thresholds[value] = save_game_state_voice_thresholds_value
		end
	end
end)

SoundQualitySettings.templates.high.max_num_voices = 5000
SoundQualitySettings.templates.high.occlusion = false

MusicSettings.combat_music.game_state_voice_thresholds.default = -96.3
MusicSettings.combat_music.game_state_voice_thresholds.horde = -96.3

Wwise.set_max_num_voices(5000)
Wwise.set_occlusion_enabled(false)
Wwise.set_volume_threshold(-96.3)
