extends Control

func _input(event):
	if visible and (event is InputEventKey) and $PressKeyDelay.is_stopped():
		if event.is_released():
			get_parent().switch_to_child("MainMenu")

func _on_press_key_delay_timeout():
	$PressKeyText/AnimationPlayer.play("press_key_text")

func start_press_key_text_animation():
	$PressKeyText/AnimationPlayer.play("pulsating")