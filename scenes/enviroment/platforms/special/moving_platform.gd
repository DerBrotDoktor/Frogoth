extends Path2D

@export var speed:float
@export var chain_speed:float
@export var direction = 1

var platform

func _ready():
	$PathSprite.points = curve.get_baked_points()
	$PathSprite.material.set_shader_parameter("speed", chain_speed)
	for child in get_children():
		if child.name == "Platform":
			platform = child


func _process(delta):
	if platform:
		
		if platform.progress_ratio -delta*speed <= 0:
			direction *= -1
			$PathSprite.material.set_shader_parameter("direction", -direction)
		elif platform.progress_ratio +delta*speed >= 1:
			direction *= -1
			$PathSprite.material.set_shader_parameter("direction", -direction)
		
		if direction == 1:
			platform.progress_ratio += delta*speed
		elif direction == -1:
			platform.progress_ratio -= delta*speed
