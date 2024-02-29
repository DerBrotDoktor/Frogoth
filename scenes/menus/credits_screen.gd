extends Control

func _on_visibility_changed():
	if visible:
		$AnimationPlayer.play("RESET")
		$AnimationPlayer.play("scroll")
	else:
		$AnimationPlayer.stop()

func _on_animation_player_animation_finished(anim_name):
		get_parent().switch_to_child("MainMenu")
