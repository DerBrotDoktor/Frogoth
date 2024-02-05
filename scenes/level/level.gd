extends Node2D

@export var player_spawn_point :Sprite2D

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

func get_badge():
	var returnValue
	return
