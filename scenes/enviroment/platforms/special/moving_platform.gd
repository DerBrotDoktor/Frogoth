extends Path2D

@export var speed:float
@export var chain_speed:float
@export var direction = 1

var platform

func _ready():
	$PathSprite.points = curve.get_baked_points()
	$PathSprite.material.set_shader_parameter("speed", chain_speed)
	if $PathSprite.points.size() > 0:
		$ChainEnd1.position = $PathSprite.points[0]
		$ChainEnd2.position = $PathSprite.points[$PathSprite.points.size()-1]
	for child in get_children():
		if child.name == "Platform":
			platform = child


func _process(delta):
	if platform and (not get_tree().paused):
		
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
		
	if get_tree().paused and not $PathSprite.material.get_shader_parameter("paused"):
		$PathSprite.material.set_shader_parameter("paused", true)
		print("PAUSE",$".")
	elif not get_tree().paused and $PathSprite.material.get_shader_parameter("paused"):
		$PathSprite.material.set_shader_parameter("paused", false)
		print("NO PAUSE",$".")
