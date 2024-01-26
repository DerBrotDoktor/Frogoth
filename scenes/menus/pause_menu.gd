extends Control

signal pause_game
signal resume_game
signal restart_level
signal main_menu

var is_open = false
var is_allowed = false

func _ready():
	close_pause_menu()

func _process(delta):
	if Input.is_action_just_pressed("pause_menu") and is_allowed:
		if is_open:
			close_pause_menu()
		else :
			open_pause_menu()
	pass

func open_pause_menu():
	print("open")
	visible = true
	is_open = true
	pause_game.emit()
	pass

func close_pause_menu():
	print("close")
	visible = false
	is_open = false
	resume_game.emit()
	pass


func _on_main_allow_pause_menu():
	is_allowed = true

func _on_main_forbid_pause_menu():
	is_allowed = false
	close_pause_menu()


func _on_main_menu_button_button_down():
	main_menu.emit()

func _on_settings_button_button_down():
	pass # Replace with function body.

func _on_restart_button_button_down():
	restart_level.emit()
	close_pause_menu()

func _on_resume_button_button_down():
	close_pause_menu()
