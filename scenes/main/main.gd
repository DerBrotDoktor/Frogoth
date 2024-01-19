extends Node

@export var main_menu :PackedScene
@export var level_select_menu :PackedScene
@export var level = []
@export var player :CharacterBody2D

var current_level = -1
var current_scene

func _ready():
	player.disable()
	current_scene = main_menu.instantiate()
	add_child(current_scene)

func load_scene(scene:PackedScene):
	current_scene.queue_free()
	current_scene = scene.instantiate()
	call_deferred("add_child",current_scene)
	pass

func load_level(id:int):
	if id < level.size():
		load_scene(level[id])
		player.enable()
		current_level = id
	pass

func load_main_menu():
	player.disable()
	load_scene(main_menu)
	pass

func load_level_select():
	player.disable()
	load_scene(level_select_menu)

func _on_player_player_died():
	if current_level >= 0:
		load_level(current_level)
		player.reset()
	pass # Replace with function body.
