extends "res://scenes/enemies/enemy_grounded.gd"

var is_player_in_range = false

func trigger_area_entererd(area):
	super.trigger_area_entererd(area)

func shoot():
	var b_direction =  (target.global_position - global_position).normalized()
	super.new_bullet(b_direction)
