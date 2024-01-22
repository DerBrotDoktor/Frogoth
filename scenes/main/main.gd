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
	pass

func load_level(id:int):
	if id < level.size():
		load_scene(level[id])
		player.enable()
		current_level = id
		start_timer.emit()
		$Canvas.visible = true
	pass

func load_main_menu():
	player.disable()
	$Canvas.visible = false
	load_scene(main_menu)
	pass

func load_level_select():
	player.disable()
	$Canvas.visible = false
	load_scene(level_select_menu)

func _on_player_player_died():
	if current_level >= 0:
		load_level(current_level)
		player.reset()
	pass # Replace with function body.
