extends Control

func set_statistics(time, badge, air_time, jumps, connected_orbs, total_shapes):
	$ColorRect2/Time.text = str(time) + " s"
	$ColorRect2/ColorRect/MarginContainer/Statistics/AirtimeLabel.text = "Air time: " + str(air_time) + " s"
	$ColorRect2/ColorRect/MarginContainer/Statistics/JumpsLabel.text = "Jumps: " + str(jumps)
	$ColorRect2/ColorRect/MarginContainer/Statistics/ConnectedOrbsLabel.text = "Connected Orbs: " + str(connected_orbs)
	$ColorRect2/ColorRect/MarginContainer/Statistics/TotalShapesLabel.text = "Total shapes: " + str(total_shapes)


func _on_next_level_button_button_down():
	get_parent().next_level()

func _on_restart_button_button_down():
	get_parent().restart_level()

func _on_main_menu_button_button_down():
	get_parent().switch_to_child("MainMenu")