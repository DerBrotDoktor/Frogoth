extends Control

@export var green_heart :Texture2D
@export var yellow_heart :Texture2D
@export var red_heart :Texture2D
@export var gray_heart :Texture2D

var time = 0.0
var timer_allowed = false

func _process(delta):
	if timer_allowed:
		time += delta
		$TimeText.text = str(int(time))

func reset_timer():
	time = 0.0
	$TimeText.text = str(int(time))

func _on_visibility_changed():
	timer_allowed = visible
	if visible:
		get_tree().paused = false
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_health(health):
	if health >= 3:
		set_heart($HBoxContainer/Heart0,green_heart)
		set_heart($HBoxContainer/Heart1,green_heart)
		set_heart($HBoxContainer/Heart2,green_heart)
	elif health == 2:
		set_heart($HBoxContainer/Heart0,yellow_heart)
		set_heart($HBoxContainer/Heart1,yellow_heart)
		set_heart($HBoxContainer/Heart2,gray_heart)
	elif health == 1:
		set_heart($HBoxContainer/Heart0,red_heart)
		set_heart($HBoxContainer/Heart1,gray_heart)
		set_heart($HBoxContainer/Heart2,gray_heart)
	else:
		set_heart($HBoxContainer/Heart0,gray_heart)
		set_heart($HBoxContainer/Heart1,gray_heart)
		set_heart($HBoxContainer/Heart2,gray_heart)

func set_heart(heart, image):
	heart.texture = image

func reset_stats():
	print("reset stats")
	time = 0.0
