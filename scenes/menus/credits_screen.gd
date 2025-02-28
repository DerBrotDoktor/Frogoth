extends Control

func _on_visibility_changed():
	if visible:
		$BackButton.grab_focus()
		$AnimationPlayer.play("RESET")
		$AnimationPlayer.play("scroll")
	else:
		$AnimationPlayer.stop()

func _on_animation_player_animation_finished(anim_name):
		get_parent().switch_to_child("MainMenu")

func _on_back_button_button_up():
	get_parent().switch_to_child("MainMenu")
