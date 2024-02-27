extends Node

@export var player :CharacterBody2D

@onready var shape_prefab = preload("res://scenes/kill_shape/kill_shape.tscn")

var current_points = []
var current_shape
var stats_connected_orbs = 0
var stats_total_shapes = 0

func  _process(_delta):
	if Input.is_action_just_pressed("discrad_shape"):
		discard_shape()

func check_point(point):
	if current_points.size() >= 3:
		for p in range(current_points.size()):
			if point == current_points[p]:
				if current_points.size()-p >= 3:
					create_shape(p)
				return
		if not point.is_in_shape:
			add_point(point)
	else:
		if not point.is_in_shape:
			if current_points.size() == 0 or current_shape == null:
				new_shape()
			add_point(point)

func add_point(point):
	current_points.append(point)
	current_shape.add_point_object(point)
	point.is_in_shape = true
	stats_connected_orbs += 1
	if point.has_method("highlight_point"):
		point.highlight_point()
	if current_points.size() > 2:
		if current_points[current_points.size()-3].has_method("not_highlight_point"):
			current_points[current_points.size()-3].not_highlight_point()
func new_shape():
	current_shape = shape_prefab.instantiate()
	add_child(current_shape)

func create_shape(p):
	var points = []
	for i in range(p,current_points.size()):
		points.append(current_points[i])
	for point in current_points:
		if point == points[0]:
			break
		elif point and point.has_method("delete_point"):
				point.delete_point()
		if point:
			point.is_in_shape = false

	current_shape.finish_shape(points)
	$LightningEffect.play("lightning")
	clear_current()
	stats_total_shapes += 1
	player.show_enemy_indicators($"..".get_current_enemies())
	
	await get_tree().create_timer(0.1).timeout
	player.orbs_left = player.max_orbs
	player.update_user_interface()

func clear_current():
	current_shape = null
	current_points = []

func clear_shape():
	if current_shape:
		current_shape.delete_shape()
		current_shape.queue_free()
		clear_current()

func discard_shape():
	if current_shape:
		current_shape.discard_shape()
		clear_current()
		player.orbs_left = player.max_orbs
		player.update_user_interface()

func _on_player_player_died():
	if current_shape:
		clear_shape()

func _on_player_entered_orb(orb_position):
	check_point(orb_position)

func reset_stats():
	stats_connected_orbs = 0
	stats_total_shapes = 0
