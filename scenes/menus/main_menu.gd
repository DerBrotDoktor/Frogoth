extends Control

func _ready():
	$VerticalContainer/StartButton.grab_focus()

func _on_start_button_button_down():
	get_parent().load_level(0) 

func _on_level_select_button_button_down():
	get_parent().load_level_select()

func _on_quit_button_button_down():
	get_tree().quit()
