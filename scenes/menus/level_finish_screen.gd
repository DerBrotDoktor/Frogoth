extends Control

func set_statistics(time, badge, air_time, jumps, connected_orbs, total_shapes):
	$ColorRect2/StatsMargin/VBoxContainer/Time.text = str(time) + " s"
	$ColorRect2/StatsMargin/VBoxContainer/ColorRect/MarginContainer/Statistics/AirtimeLabel.text = "Air time: " + str(air_time) + " s"
	$ColorRect2/StatsMargin/VBoxContainer/ColorRect/MarginContainer/Statistics/JumpsLabel.text = "Jumps: " + str(jumps)
	$ColorRect2/StatsMargin/VBoxContainer/ColorRect/MarginContainer/Statistics/ConnectedOrbsLabel.text = "Connected Orbs: " + str(connected_orbs)
	$ColorRect2/StatsMargin/VBoxContainer/ColorRect/MarginContainer/Statistics/TotalShapesLabel.text = "Total shapes: " + str(total_shapes)
	$ColorRect2/MarginContainer2/Badge.set_sprite(badge)

func _on_next_level_button_button_down():
	if $InputBlockTimer.is_stopped:
		get_parent().next_level()

func _on_restart_button_button_down():
	if $InputBlockTimer.is_stopped:
		get_parent().restart_level()

func _on_main_menu_button_button_down():
	if $InputBlockTimer.is_stopped:
		get_parent().switch_to_child("MainMenu")

func _on_visibility_changed():
	if $ColorRect2/MarginContainer/Buttons/NextLevelButton.is_inside_tree() and visible:
		$ColorRect2/MarginContainer/Buttons/NextLevelButton.grab_focus()
		$InputBlockTimer.start()

func play_click_sound():
	$ClickSoundPlayer.play()

func play_hover_sound():
	if visible:
		$HoverSoundPlayer.play()
