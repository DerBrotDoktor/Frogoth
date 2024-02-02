extends "res://scenes/enemies/enemy_grounded.gd"

var is_player_in_range = false


func shoot():
	is_attacking = true
	play_animation("attack")
	await $Animation.animation_finished
	var b_direction =  (target.global_position - global_position).normalized()
	super.new_bullet(b_direction)
	is_attacking = false

func play_animation(animation):
	$Animation.play(animation)

func trigger_area_entererd(area):
	if area.is_in_group("killing_area"):
		play_animation("death")
		await $Animation.animation_finished
		super.die()
