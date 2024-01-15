extends Node

@export var main_menu :PackedScene
@export var level_select_menu :PackedScene
@export var level :Array[PackedScene] = []
@export var player :CharacterBody2D
var current_scene

func _ready():
	player.disable()
	current_scene = main_menu.instantiate()
	add_child(current_scene)

func load_scene(scene:PackedScene):
	current_scene.queue_free()
	current_scene = scene.instantiate()
	add_child(current_scene)
	pass

func load_level(id:int):
	if id < level.size():
		load_scene(level[id])
		player.enable()
	pass

func load_main_menu():
	player.disable()
	load_scene(main_menu)
	pass

func load_level_select():
	player.disable()
	load_scene(level_select_menu)
