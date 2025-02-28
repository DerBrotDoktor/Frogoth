extends Control

signal resume_game
signal restart_level
signal main_menu

func close_pause_menu():
	get_parent().toggle_pause_menu()

func _on_resume_button_button_up():
	close_pause_menu()

func _on_restart_button_button_up():
	get_parent().restart_level()

func _on_settings_button_button_up():
	get_parent().switch_to_child("SettingsMenu")

func _on_main_menu_button_button_up():
	$"../../SceneTransition/SceneTransitionAnimationPlayer".play("fade_in")
	await $"../../SceneTransition/SceneTransitionAnimationPlayer".animation_finished
	get_parent().switch_to_child("MainMenu")
	$"../../SceneTransition/SceneTransitionAnimationPlayer".play_backwards("fade_in")

func _on_visibility_changed():
	if $VBoxContainer/ResumeButton.is_inside_tree() and visible:
		$VBoxContainer/ResumeButton.grab_focus()

func set_level(level_name):
	$LevelText.text = level_name

func play_hover_sound():
	$HoverSoundPlayer.play()

func play_click_sound():
	if visible:
		$ClickSoundPlayer.play()

func _on_level_select_button_up():
	get_parent().switch_to_child("LevelSelectMenu")
