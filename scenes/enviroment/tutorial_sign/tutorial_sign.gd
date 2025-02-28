extends Node2D

enum InputMethods {KEYBOARD, CONTROLLER}

var last_input_method :InputMethods = InputMethods.KEYBOARD

func _ready():
	hide_text()
	update_key_prompts()

func _input(event):
	var event_is_controller = event is InputEventJoypadButton or event is InputEventJoypadMotion
	var event_is_keyboard = event is InputEventKey or event is InputEventMouseButton
	
	if event_is_controller and last_input_method == InputMethods.KEYBOARD:
		if event is InputEventJoypadMotion:
			if (event.axis_value < 0.2) and (event.axis_value > -0.2):
				return
		last_input_method = InputMethods.CONTROLLER
		update_key_prompts()
		
	elif event_is_keyboard and last_input_method == InputMethods.CONTROLLER:
		last_input_method = InputMethods.KEYBOARD
		update_key_prompts()

func update_key_prompts():
	if last_input_method == InputMethods.KEYBOARD:
		$TextContainer/KeyboardPrompts.visible = true
		$TextContainer/ControllerPrompts.visible = false
	elif last_input_method == InputMethods.CONTROLLER:
		$TextContainer/KeyboardPrompts.visible = false
		$TextContainer/ControllerPrompts.visible = true

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
