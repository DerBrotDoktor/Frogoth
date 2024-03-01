extends Control

func _ready():
	$MarginContainer/VBoxContainer/VerticalContainer/StartButton.grab_focus()
	get_tree().paused = true

func _on_start_button_button_up():
	get_parent().load_level_by_index(0) 

func _on_level_select_button_button_up():
	get_parent().switch_to_child("LevelSelectMenu")

func _on_quit_button_button_up():
	get_tree().quit()

func _on_visibility_changed():
	if $MarginContainer/VBoxContainer/VerticalContainer/StartButton.is_inside_tree() and visible:
		get_tree().paused = true
		await get_tree().create_timer(0.1).timeout
		$MarginContainer/VBoxContainer/VerticalContainer/StartButton.grab_focus()

func _on_settings_button_button_up():
	get_parent().switch_to_child("SettingsMenu")

func play_click_sound():
	$ClickSoundPlayer.play()

func play_hover_sound():
	if visible:
		$HoverSoundPlayer.play()

func _on_credits_button_button_up():
	get_parent().switch_to_child("CreditsScreen")
