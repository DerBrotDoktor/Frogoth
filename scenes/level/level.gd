extends Node2D

@export var player_spawn_point :Sprite2D
@export var level_name :String
@export var can_player_jump_points = true ##if false the player cant place jump points at the beginning of the level
@export var badge_times :Array[int]
@export var camera_limits :Vector4i

func _ready():
	player_spawn_point.visible = false

func get_player_spawn_position():
	var returnValue
	returnValue = player_spawn_point.position
	return returnValue

func get_enemy_count():
	var returnValue = 0
	for child in $Enemies.get_children():
		if child.has_method("die") and child.is_dead == false:
			returnValue += 1
	return returnValue

func get_enemies():
	var returnValue = []
	for child in $Enemies.get_children():
		if child.has_method("die") and child.is_dead == false:
			returnValue.append(child)
	return returnValue

func get_badge(seconds):
	var returnValue = 0
	if badge_times.size()  == 4:
		if seconds < badge_times[0]:
			returnValue = 4
		elif seconds < badge_times[1]:
			returnValue = 3
		elif seconds < badge_times[2]:
			returnValue = 2
		elif seconds < badge_times[3]:
			returnValue = 1
		elif seconds > badge_times[3]:
			returnValue = 0
	return returnValue

func get_camera_limits():
	return camera_limits
