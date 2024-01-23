extends CharacterBody2D

signal enter_bash_point(bash_point)
signal player_died()

#region Variables
@export var normal_speed = 100.0
@export var jump_velocity = -300.0
@export var max_jump_time =  0.15
@export var double_jump_velocity = -300.0
@export var jump_buffer_time = 0.15
@export var dash_speed = 400
@export var bash_speed = 300
@export var ghost_node : PackedScene
@export var ghost_length = 1.5
@export var ghost_time = 0.35
@export var max_health = 3
@export var gravity = 1000
@export var block_speed = 0.9

var can_jump = false
var can_double_jump = false
var jump_time = 0.0
var is_disabled = false
var is_in_bash_point = false
var can_move = true
var ready_for_bash = false
var is_bashing = false
var bash_target_position
var current_bash_point
var current_health
var is_blocking = false
var block_strength = 100

#endregion
func _ready():
	current_health = max_health
	disable()
	stop_block()
	pass

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
	pass

func add_gravity(delta):
	if not is_on_floor() and can_move:
		velocity.y += gravity * delta

var last_direction

func handle_movement():
	var direction = Input.get_axis("left", "right")
	var speed = normal_speed if $DashTimer.is_stopped() else dash_speed
	if last_direction != direction and last_direction != 0:
		$TurnDelay.start()
	if direction and can_move and $TurnDelay.is_stopped():
		velocity.x = direction * speed
		if direction > 0:
			$Animation.flip_h = false
		elif direction < 0:
			$Animation.flip_h = true
	elif can_move:
		velocity.x = move_toward(velocity.x, 0, speed)
	last_direction = direction

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
	pass

var last_mouse_position

func get_look_position() -> Vector2:
	var look_point = Input.get_vector("aim_left","aim_right","aim_up","aim_down") + position
	if last_mouse_position != get_global_mouse_position() or look_point == position:
		look_point = get_global_mouse_position()
	last_mouse_position = get_global_mouse_position()
	bash_target_position = look_point
	return look_point
	pass

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
	var _direction :Vector2 = (bash_target_position - global_position).normalized()
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

func _on_trigger_area_body_entered(body):
	if body.is_in_group("bullet"):
		take_damage(1)
	pass

func dash():
	$DashTimer.start()
	$GhostTimer.start()

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, scale)
	ghost.flip_h = $Animation.flip_h
	get_tree().current_scene.add_child(ghost)
	pass

func _on_ghost_timer_timeout():
	add_ghost()
	pass

func _on_dash_timer_timeout():
	$GhostTimer.stop()
	$DashCooldown.start()
	pass

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
		$Block/BlockCollisionShape.scale.y = block_strength/100
	elif not is_blocking and block_strength < 99:
		block_strength = lerpf(block_strength, 100, block_speed * delta * 2)
		$Block/BlockCollisionShape.scale.y = block_strength/100
	elif block_strength >= 99:
		block_strength = 100
		$Block/BlockCollisionShape.scale.y = block_strength/100
	print (block_strength)

func start_block():
	$Block.visible = true
	$Block/BlockCollisionShape.disabled = false
	is_blocking = true

func stop_block():
	$Block.visible = false
	$Block/BlockCollisionShape.disabled = true
	is_blocking = false
