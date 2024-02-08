extends Node

@export var level :Array[PackedScene] = []
@export var player :CharacterBody2D

var current_level_index = -1
var current_scene

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	player.disable()
	$Canvas.switch_to_child("MainMenu")

func load_scene(scene:PackedScene):
	if current_scene:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	call_deferred("add_child",current_scene)

func load_level_by_index(index:int):
	if index < level.size():
		$BashPointController.clear_shape()
		load_scene(level[index])
		set_player_position(current_scene.get_player_spawn_position())
		player.reset()
		player.enable()
		reset_stats()
		current_level_index = index
		$Canvas.switch_to_child("UserInterface")
	else:
		$Canvas.switch_to_child("MainMenu")

func reset_stats():
	player.reset_stats()
	$Canvas/UserInterface.reset_stats()
	$BashPointController.reset_stats()

func restart_current_level():
	load_level_by_index(current_level_index)

func set_player_position(position):
	player.position = position

func _on_player_player_died():
	if current_level_index >= 0:
		restart_current_level()

func check_for_win():
	if current_scene.has_method("get_enemy_count"):
		var current_enemy_count = current_scene.get_enemy_count()
		print(current_enemy_count)
		if (current_enemy_count) <= 0:
			finish_level()

func finish_level():
	$Canvas.switch_to_child("LevelFinishScreen")
	get_tree().paused = true
	set_level_statistics()
	pass

func next_level():
	if current_level_index < level.size():
		load_level_by_index(current_level_index+1)

func set_level_statistics():
	var time = int($Canvas/UserInterface.time)
	var badge = current_scene.get_badge()
	var air_time = int(player.stats_air_time)
	var jumps = player.stats_jumps
	var connected_orbs = $BashPointController.stats_connected_orbs
	var total_shapes = $BashPointController.stats_total_shapes
	$Canvas/LevelFinishScreen.set_statistics(time, badge, air_time, jumps, connected_orbs, total_shapes)
	pass
