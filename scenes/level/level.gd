extends Node2D

@export var player_spawn_point :Sprite2D

func _ready():
	player_spawn_point.visible = false

func get_player_spawn_position():
	var returnValue
	returnValue = player_spawn_point.position
	return returnValue

func get_enemy_count():
	var returnValue
	returnValue = $Enemies.get_child_count()
	return returnValue
