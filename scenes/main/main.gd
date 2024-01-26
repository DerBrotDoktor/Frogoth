extends Node

signal start_timer

@export var main_menu :PackedScene
@export var level_select_menu :PackedScene
@export var level :Array[PackedScene] = []
@export var player :CharacterBody2D

var current_level = -1
var current_scene

func _ready():
	$Canvas.visible = false
	player.disable()
	load_scene(main_menu)

func load_scene(scene:PackedScene):
	if current_scene:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	call_deferred("add_child",current_scene)

func load_level(id:int):
	if id < level.size():
		load_scene(level[id])
		set_player_position(current_scene.get_player_spawn_position())
		player.enable()
		current_level = id
		start_timer.emit()
		$Canvas.visible = true

func load_main_menu():
	player.disable()
	$Canvas.visible = false
	load_scene(main_menu)

func load_level_select():
	player.disable()
	$Canvas.visible = false
	load_scene(level_select_menu)

func _on_player_player_died():
	if current_level >= 0:
		load_level(current_level)
		player.reset()

func set_player_position(position):
	player.position = position
