extends Control

signal resume_game
signal restart_level
signal main_menu

func close_pause_menu():
	get_parent().toggle_pause_menu()

func _on_main_menu_button_button_down():
	get_parent().switch_to_child("MainMenu")

func _on_settings_button_button_down():
	pass # Replace with function body.

func _on_restart_button_button_down():
	get_parent().restart_level()

func _on_resume_button_button_down():
	close_pause_menu()
