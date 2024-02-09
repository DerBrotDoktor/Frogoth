extends "res://scenes/enemies/enemy_grounded.gd"

var is_player_in_range = false

func play_animation(animation):
	$AnimationPlayer.play(animation)

func trigger_area_entererd(area):
	if area.is_in_group("killing_area"):
		$AnimationPlayer.stop()
		play_animation("death")
