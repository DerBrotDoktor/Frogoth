extends CanvasLayer

@export var camera :Camera2D
@export var enemy_indicator :PackedScene

func show_indicators(targets):
	for target in targets:
		var indicator = enemy_indicator.instantiate()
		indicator.camera = camera
		indicator.target = target
		add_child(indicator)
