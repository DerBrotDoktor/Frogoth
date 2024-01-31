extends Node

@export var player :CharacterBody2D

@onready var shape_prefab = preload("res://scenes/kill_shape/kill_shape.tscn")

var current_points = []
var current_shape

func  _process(delta):
	if Input.is_action_just_pressed("discrad_shape"):
		clear_shape()

func check_point(point):
	
	if current_points.size() >= 3:
		for p in range(current_points.size()):
			if point == current_points[p]:
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
	current_shape.add_point(point)
	point.is_in_shape = true

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
	clear_current()

func clear_current():
	current_shape = null
	current_points = []

func clear_shape():
	if current_shape:
		current_shape.delete_shape()
		current_shape.queue_free()
		clear_current()

func _on_player_player_died():
	if current_shape:
		clear_shape()

func _on_player_entered_orb(orb_position):
	check_point(orb_position)
