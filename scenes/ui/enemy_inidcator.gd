extends Sprite2D

var camera :Camera2D
var target : CharacterBody2D
var margin = Vector2(50, 50)

func  _ready():
	update()
	visible = true

func _physics_process(delta):
	check_valid()
	update()

func check_valid():
	if not is_instance_valid(target):
		queue_free()

func update():
	if is_instance_valid(target):
		if target.has_method("is_on_screen") and (not target.is_on_screen()):
			visible = true
			look_at(target.position)
			var camera_pos = camera.get_screen_center_position()
			var screen_size = camera.get_viewport_rect().size
			

			var max_horizontal = camera_pos.x + screen_size.x / 2 - margin.x
			var min_horizontal = camera_pos.x - screen_size.x / 2 + margin.x
			var max_vertical = camera_pos.y + screen_size.y / 2 - margin.y
			var min_vertical = camera_pos.y - screen_size.y / 2 + margin.y
			
			global_position.x = clamp(target.global_position.x, min_horizontal, max_horizontal)
			global_position.y = clamp(target.global_position.y, min_vertical, max_vertical)
		else:
			visible = false
	else:
		check_valid()


func _on_delete_timer_timeout():
	queue_free()
