extends Node

@export var level_select_menu :PackedScene
@export var level :Array[PackedScene] = []
@export var player :CharacterBody2D

var current_level = -1
var current_scene

func _ready():
	player.disable()
	$Canvas.switch_to_child("MainMenu")

func load_scene(scene:PackedScene):
	if current_scene:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	call_deferred("add_child",current_scene)

func load_level(id:int):
	if id < level.size():
		load_scene(level[id])
		set_player_position(current_scene.get_player_spawn_position())
		player.reset()
		player.enable()
		current_level = id
		$Canvas.switch_to_child("UserInterface")

func load_main_menu():
	player.disable()
	$Canvas.switch_to_child("MainMenu")

func load_level_select():
	player.disable()
	$Canvas.switch_to_child("LevelSelectMenu")

func restart_current_level():
	load_level(current_level)

func set_player_position(position):
	player.position = position

func _on_player_player_died():
	if current_level >= 0:
		restart_current_level()

func _on_pause_menu_pause_game():
	get_tree().paused = true

func _on_pause_menu_resume_game():
	get_tree().paused = false

func _on_pause_menu_restart_level():
	restart_current_level()

func _on_pause_menu_main_menu():
	load_main_menu()
