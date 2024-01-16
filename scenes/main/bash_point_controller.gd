extends Node
class_name BashPointController

@export var player :Player
var current_bash_points :Array = []

func add_point():
	pass

func create_area():
	pass

func clear_area():
	pass


func _on_player_enter_bash_point(bash_point :BashPoint):
	print(bash_point)
	pass # Replace with function body.
