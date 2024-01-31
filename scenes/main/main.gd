extends Node

@export var level :Array[PackedScene] = []
@export var player :CharacterBody2D

var current_level_index = -1
var current_scene

func _ready():
	player.disable()
	$Canvas.switch_to_child("MainMenu")

func load_scene(scene:PackedScene):
	if current_scene:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	call_deferred("add_child",current_scene)

func load_level_by_index(index:int):
	if index < level.size():
		load_scene(level[index])
		set_player_position(current_scene.get_player_spawn_position())
		player.reset()
		player.enable()
		current_level_index = index
		$Canvas.switch_to_child("UserInterface")

func load_level_select():
	player.disable()
	$Canvas.switch_to_child("LevelSelectMenu")

func restart_current_level():
	load_level_by_index(current_level_index)

func set_player_position(position):
	player.position = position

func _on_player_player_died():
	if current_level_index >= 0:
		restart_current_level()
