extends Camera2D

@export var max_shake_strength = 20.0
@export var shake_fade = 5.0
var shake_strength = 0.0

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shake_fade*delta)
		do_shake()

func do_shake():
	offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func shake():
	shake_strength = max_shake_strength
