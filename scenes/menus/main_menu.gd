extends Control

func _ready():
	$VerticalContainer/StartButton.grab_focus()
	get_tree().paused = true

func _on_start_button_button_down():
	get_parent().load_level_by_index(0) 

func _on_level_select_button_button_down():
	get_parent().switch_to_child("LevelSelectMenu")

func _on_quit_button_button_down():
	get_tree().quit()


func _on_visibility_changed():
	if $VerticalContainer/StartButton.is_inside_tree() and visible:
		get_tree().paused = true
		$VerticalContainer/StartButton.grab_focus()


func _on_settings_button_button_down():
	get_parent().switch_to_child("SettingsMenu")
	pass # Replace with function body.
