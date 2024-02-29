extends Control

func _input(event):
	if visible and (event is InputEventKey or event is InputEventJoypadButton) and $PressKeyDelay.is_stopped():
		if event.is_released():
			$"..".warning_finished()

func _on_press_key_delay_timeout():
	$PressKeyText/AnimationPlayer.play("press_key_text")

func start_press_key_text_animation():
	$PressKeyText/AnimationPlayer.play("pulsating")
