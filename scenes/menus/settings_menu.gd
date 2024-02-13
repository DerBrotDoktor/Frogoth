extends Control


func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value < 0.05)


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), value < 0.05)


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SoundEffects"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SoundEffects"), value < 0.05)

func _on_back_button_pressed():
	get_parent().switch_to_last_child()
