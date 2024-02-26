extends Node2D


enum INPUT_METHODS {KEYBOARD, CONTROLLER}

var last_input_method :INPUT_METHODS

func _input(event):
	if event is InputEventJoypadButton and last_input_method == INPUT_METHODS.KEYBOARD:
		last_input_method = INPUT_METHODS.CONTROLLER
		update_key_prompts()
	elif (event is InputEventKey or event is InputEventMouseButton) and last_input_method == INPUT_METHODS.CONTROLLER:
		last_input_method = INPUT_METHODS.KEYBOARD
		update_key_prompts()

func update_key_prompts():
	if last_input_method == INPUT_METHODS.KEYBOARD:
		$TextContainer/KeyboardPrompts.visible = true
		$TextContainer/ControllerPrompts.visible = false
	elif last_input_method == INPUT_METHODS.CONTROLLER:
		$TextContainer/KeyboardPrompts.visible = false
		$TextContainer/ControllerPrompts.visible = true

func _ready():
	hide_text()

func show_text():
	$LeaveTimer.stop()
	$TextContainer.visible = true

func hide_text():
	$TextContainer.visible = false

func _on_trigger_area_area_entered(area):
	if area.is_in_group("player"):
		show_text()


func _on_trigger_area_area_exited(area):
	if area.is_in_group("player") and $LeaveTimer.is_inside_tree():
		$LeaveTimer.start()


func _on_leave_timer_timeout():
	hide_text()
