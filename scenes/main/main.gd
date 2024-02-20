extends Node

@export var level :Array[PackedScene] = []
@export var player :CharacterBody2D

var current_level_index = -1
var current_scene

func _ready():
	player.disable()
	$Canvas.switch_to_child("MainMenu")

func _process(_delta):
	if Input.is_action_just_pressed("quick_restart"):
		if $Canvas.current_child_name == "UserInterface":
			restart_current_level()

func load_scene(scene:PackedScene):
	if current_scene:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	call_deferred("add_child",current_scene)

func load_level_by_index(index:int):
	delete_shapes()
	if index < level.size():
		$BashPointController.clear_shape()
		$SceneTransition/SceneTransitionAnimationPlayer.play("fade_in")
		await $SceneTransition/SceneTransitionAnimationPlayer.animation_finished
		load_scene(level[index])
		set_player_position(current_scene.get_player_spawn_position())
		player.can_place_jump_points = current_scene.can_player_jump_points
		player.reset()
		reset_stats()
		current_level_index = index
		$Canvas.switch_to_child("UserInterface")
		player.enable()
		$Canvas/PauseMenu.set_level(current_scene.level_name)
		$SceneTransition/SceneTransitionAnimationPlayer.play_backwards("fade_in")
		await $SceneTransition/SceneTransitionAnimationPlayer.animation_finished
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
	var badge = current_scene.get_badge(int($Canvas/UserInterface.time))
	var air_time = int(player.stats_air_time)
	var jumps = player.stats_jumps
	var connected_orbs = $BashPointController.stats_connected_orbs
	var total_shapes = $BashPointController.stats_total_shapes
	if total_shapes == 1:
		badge = 5
	$Canvas/LevelFinishScreen.set_statistics(time, badge, air_time, jumps, connected_orbs, total_shapes)
	pass

func get_current_enemy_count():
	var returnValue = -1
	if current_scene:
		if current_scene.has_method("get_enemy_count"):
			returnValue = current_scene.get_enemy_count()
	return returnValue

func delete_shapes():
	for child in $BashPointController.get_children():
		if child.has_method("delete_shape"):
			child.delete_shape()
