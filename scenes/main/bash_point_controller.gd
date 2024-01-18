extends Node

@export var player :CharacterBody2D

@onready var shape_prefab = preload("res://scenes/kill_shape/kill_shape.tscn")

var current_bash_points = []
var current_shape

func check_point(point):
	if current_bash_points.size() >= 3 and  current_bash_points[0] == point:
		create_shape()
	elif not point.is_in_shape:
		if current_bash_points.size() == 0:
			new_shape()
		add_point(point)
	else:
		clear_shape()
	pass

func add_point(point):
	current_bash_points.append(point)
	current_shape.add_point(point)
	point.is_in_shape = true
	pass

func new_shape():
	current_shape = shape_prefab.instantiate()
	add_child(current_shape)
	pass

func create_shape():
	current_shape.finish_shape()
	current_shape = null
	current_bash_points = []
	pass

func clear_shape():
	if current_shape:
		current_shape.delete_shape()
		current_shape = null
		current_bash_points = []
	pass

func _on_player_enter_bash_point(bash_point):
	print(bash_point)
	check_point(bash_point)
	pass
