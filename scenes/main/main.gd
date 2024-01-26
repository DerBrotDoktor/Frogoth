extends Node

signal start_timer
signal allow_pause_menu
signal forbid_pause_menu

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
		player.reset()
		player.enable()
		current_level = id
		start_timer.emit()
		$Canvas.visible = true
		allow_pause_menu.emit()

func load_main_menu():
	forbid_pause_menu.emit()
	player.disable()
	$Canvas.visible = false
	load_scene(main_menu)

func load_level_select():
	forbid_pause_menu.emit()
	player.disable()
	$Canvas.visible = false
	load_scene(level_select_menu)

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
