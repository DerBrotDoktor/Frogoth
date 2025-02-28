extends "res://scenes/level/level.gd"

func _ready():
	super._ready()
	get_tree().current_scene.remove_ui()
	get_tree().paused = false

func _process(_delta):
	if Input.is_action_just_pressed("discrad_shape"):
		get_tree().paused = true
		get_tree().current_scene.play_credits()
