extends CharacterBody2D

signal enter_bash_point(bash_point)

#region Variables
@export var normal_speed = 100.0
@export var jump_velocity = -400.0
@export var double_jump_velocity = -400.0
@export var jump_buffer_time = 0.15
@export var dash_speed = 400
@export var bash_speed = 300

var can_jump = false
var can_double_jump = false
var is_disabled = false
var is_in_bash_point = false
var can_move = true
var ready_for_bash = false
var is_bashing = false
var current_bash_point
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#endregion

func _physics_process(delta):
	if is_disabled:
		return
	if ready_for_bash:
		$DirectionArrow. look_at(get_global_mouse_position())
	
	add_gravity(delta)
	try_jump()
	handle_movement()
	var was_on_floor = is_on_floor()
	move_and_slide()
	check_coyote(was_on_floor)
	handle_jump()

func add_gravity(delta):
	if not is_on_floor() and can_move:
		velocity.y += gravity * delta

func handle_movement():
	var direction = Input.get_axis("left", "right")
	var speed = normal_speed if $DashTimer.is_stopped() else dash_speed
	if direction and can_move:
		velocity.x = direction * speed
	elif can_move:
		velocity.x = move_toward(velocity.x, 0, speed)

func enable():
	$Camera.enabled = true
	is_disabled = false

func disable():
	$Camera.enabled = false
	is_disabled = true

func try_jump():
	if Input.is_action_pressed("jump") and is_in_bash_point and not ready_for_bash :
		bash_point()
	elif Input.is_action_just_released("jump") and ready_for_bash:
		bash()
	elif Input.is_action_just_pressed("dash") and $DashTimer.is_stopped() and can_move:
		$DashTimer.start()
	if Input.is_action_just_pressed("jump"):
		$JumpBufferTimer.start()

func handle_jump():
	if not $JumpBufferTimer.is_stopped() and can_jump:
		$JumpBufferTimer.stop()
		$CoyoteTimer.stop()
		if is_in_bash_point:
			return
		if can_double_jump:
			can_jump = true
			can_double_jump = false
			velocity.y = jump_velocity
		else:
			can_jump = false
			velocity.y = double_jump_velocity

func check_coyote(was_on_floor):
	if was_on_floor and not is_on_floor() and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()
	elif is_on_floor():
		can_jump = true
		can_double_jump = true

func _on_coyote_timer_timeout():
	can_jump = true
	can_double_jump = false
	pass

func bash_point():
	enter_bash_point.emit(current_bash_point)
	$DirectionArrow.visible = true
	can_move = false
	velocity = Vector2(0,0)
	position = current_bash_point.position
	ready_for_bash = true

func bash():
	var _direction :Vector2 = (get_global_mouse_position() - global_position).normalized()
	velocity = _direction * bash_speed
	$BashTimer.start()
	ready_for_bash = false
	$DirectionArrow.visible = false

func _on_bash_timer_timeout():
	if not ready_for_bash:
		can_move = true
	pass

func _on_trigger_area_area_entered(area):
	if area.is_in_group("bash_point"):
		current_bash_point = area
		is_in_bash_point = true
	pass

func _on_trigger_area_area_exited(area):
	if area.is_in_group("bash_point"):
		is_in_bash_point = false
		current_bash_point = null
	pass
