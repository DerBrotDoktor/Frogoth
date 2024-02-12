extends "res://scenes/enemies/enemy_grounded.gd"

var is_player_in_range = false

func attack():
	$AttackCooldown.start()
	is_attacking = true
	play_animation("attack")

func play_animation(animation):
	if not is_dead:
		$AnimationPlayer.play(animation)

func trigger_area_entererd(area):
	if area.is_in_group("killing_area"):
		$AnimationPlayer.clear_queue()
		$AnimationPlayer.stop()
		is_dead = true
		$AnimationPlayer.play("death")

