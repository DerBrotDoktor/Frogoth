extends "res://scenes/enemies/enemy_grounded.gd"

var is_player_in_range = false

func shoot():
	var b_direction =  (target.global_position - global_position).normalized()
	super.new_bullet(b_direction)
