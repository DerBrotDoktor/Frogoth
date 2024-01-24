extends CharacterBody2D

signal enter_bash_point(bash_point)
signal player_died()

#region Variables
@export var normal_speed = 100.0 ##Walking speed
@export var jump_velocity = -300.0 ##Initial jump velocity
@export_range(0,200) var acceleration = 20.0 ##Acceleration
@export_range(0,200) var deceleration = 0.2 ##Deceleration
@export var max_jump_time =  0.15 ##Maximum time the player can hold the jump button to influence the jump height
@export var double_jump_velocity = -300.0 ##Initial velocity for second jump
@export var dash_speed = 400 ##Speed for the dash
@export_range(0,200) var dash_acceleration = 20.0 ##Acceleration for the dash
@export var ghost_node : PackedScene ##Ghost sprite, placed while dashing
@export var bash_speed = 300 ##Speed for the bash
@export var max_health = 3 ##Maximum player health
@export var gravity = 1000 ##Gravity
@export var block_speed = 0.9 ##Block shrinking time
@export var knockback_strength = 500 ##Velocity of the knockback

var can_jump = false
var can_double_jump = false
var jump_time = 0.0
var is_disabled = false
var is_in_bash_point = false
var can_move = true
var ready_for_bash = false
var current_bash_point
var current_health
var is_blocking = false
var block_strength = 100
var dash_direction
#endregion

func _ready():
	current_health = max_health
	disable()
	stop_block()

func _physics_process(delta):
	if is_disabled:
		return
	if ready_for_bash:
		$DirectionArrow.look_at(get_look_position())
	if is_blocking:
		$Block.look_at(get_look_position())
	
	add_gravity(delta)
	try_bash()
	try_jump()
	try_block(delta)
	handle_movement()
	var was_on_floor = is_on_floor()
	move_and_slide()
	check_coyote(was_on_floor)
	handle_jump(delta)

func add_gravity(delta):
	if not is_on_floor() and can_move:
		velocity.y += gravity * delta

func handle_movement():
	if not $DashTimer.is_stopped():
		handle_dash_movement()
		return
	var direction = Input.get_axis("left", "right")
	if direction and can_move:
		if direction > 0:
			$Animation.flip_h = false
			velocity.x = min(velocity.x + acceleration, normal_speed)
		elif direction < 0:
			velocity.x = max(velocity.x - acceleration, -normal_speed)
			$Animation.flip_h = true
	elif can_move:
		velocity.x = lerpf(velocity.x, 0, deceleration)

func handle_dash_movement():
	if dash_direction.x > 0:
		velocity.x = min(velocity.x + dash_acceleration, dash_speed)
	elif dash_direction.x < 0:
		velocity.x = max(velocity.x - dash_acceleration, -dash_speed)
	if dash_direction.y > 0:
		velocity.y = min(velocity.y + dash_acceleration, dash_speed)
	elif dash_direction.y < 0:
		velocity.y = max(velocity.y - dash_acceleration, -dash_speed)
	print(velocity)
	pass

func enable():
	$Camera.enabled = true
	$Animation.visible = true
	await get_tree().create_timer(0.1).timeout
	is_disabled = false

func disable():
	$Camera.enabled = false
	$Animation.visible = false
	is_disabled = true

func reset():
	current_health = max_health
	position = Vector2.ZERO

func try_jump():
	if Input.is_action_just_pressed("dash") and $DashTimer.is_stopped() and $DashCooldown.is_stopped() and can_move:
		dash()
	if Input.is_action_just_pressed("jump"):
		$JumpBufferTimer.start()

func handle_jump(delta):
	if not $JumpBufferTimer.is_stopped() and can_jump:
		$JumpBufferTimer.stop()
		$CoyoteTimer.stop()
		if is_in_bash_point:
			return
		if can_double_jump:
			can_jump = true
			can_double_jump = false
			velocity.y = jump_velocity
			jump_time = 0.0
		else:
			can_jump = false
			jump_time = 0.0
			velocity.y = double_jump_velocity
	if Input.is_action_pressed("jump") and jump_time < max_jump_time and not is_in_bash_point:
		velocity.y = jump_velocity
		jump_time += delta

func check_coyote(was_on_floor):
	if was_on_floor and not is_on_floor() and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()
	elif is_on_floor():
		can_jump = true
		can_double_jump = true

func _on_coyote_timer_timeout():
	can_jump = true
	can_double_jump = false

var last_mouse_position

func get_look_position():
	var returnValue = Vector2.ZERO
	
	var input_direction = Input.get_vector("aim_left","aim_right","aim_up","aim_down")
	var no_direction_input = input_direction.length_squared() < 0.001
	var mouse_was_moved = last_mouse_position != get_global_mouse_position()
	print(last_mouse_position)
	if not no_direction_input:
		returnValue = position + input_direction
	else:
		returnValue = get_global_mouse_position()
	
	last_mouse_position = get_global_mouse_position()
	return returnValue

func try_bash():
	if Input.is_action_pressed("bash") and is_in_bash_point and not ready_for_bash :
		bash_point()
	elif Input.is_action_just_released("bash") and ready_for_bash:
		bash()

func bash_point():
	enter_bash_point.emit(current_bash_point)
	$DirectionArrow.visible = true
	can_move = false
	velocity = Vector2(0,0)
	position = current_bash_point.position
	ready_for_bash = true

func bash():
	var _direction :Vector2 = (get_look_position() - global_position).normalized()
	velocity = _direction * bash_speed
	$BashTimer.start()
	ready_for_bash = false
	$DirectionArrow.visible = false

func _on_bash_timer_timeout():
	if not ready_for_bash:
		can_move = true

func _on_trigger_area_area_entered(area):
	if area.is_in_group("bash_point"):
		current_bash_point = area
		is_in_bash_point = true

func _on_trigger_area_area_exited(area):
	if area.is_in_group("bash_point"):
		is_in_bash_point = false
		current_bash_point = null

func _on_trigger_area_body_entered(body):
	if body.is_in_group("bullet"):
		take_damage(1)

func dash():
	var input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var input_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	dash_direction = Vector2(input_x, input_y).normalized()
	can_move = false
	$DashTimer.start()
	$GhostTimer.start()

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, scale)
	ghost.flip_h = $Animation.flip_h
	get_tree().current_scene.add_child(ghost)

func _on_ghost_timer_timeout():
	add_ghost()

func _on_dash_timer_timeout():
	$GhostTimer.stop()
	$DashCooldown.start()
	can_move = true

func take_damage(damage):
	print("damage", current_health)
	if current_health > 1:
		$Camera.shake()
		$PlayerAnimation.play("hit_player_animation")
		current_health -= damage
	else:
		die()
	print(current_health)

func die():
	player_died.emit()

func try_block(delta):
	if Input.is_action_just_pressed("block"):
		start_block()
	elif Input.is_action_just_released("block"):
		stop_block()
	
	if is_blocking and block_strength <= 0.1:
		stop_block()
	elif is_blocking:
		block_strength = lerpf(block_strength,0,block_speed * delta)
		update_block_shape()
	elif not is_blocking and block_strength <= 99:
		block_strength = lerpf(block_strength, 100, block_speed * delta * 2)
		update_block_shape()
	elif block_strength > 99 and not block_strength == 100:
		block_strength = 100
		update_block_shape()

func update_block_shape():
	$Block/BlockCollisionShape.scale.y = block_strength/100
	$Block/BlockColliderSprite.scale.y = block_strength/100

func start_block():
	$Block.visible = true
	$Block/BlockCollisionShape.disabled = false
	is_blocking = true

func stop_block():
	$Block.visible = false
	$Block/BlockCollisionShape.disabled = true
	is_blocking = false

func knockback():
	var direction = ((get_look_position()-global_position) * -1).normalized()
	velocity = direction * knockback_strength
