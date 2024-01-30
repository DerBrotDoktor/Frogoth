extends CharacterBody2D

signal entered_orb(orb_position)
signal player_died()

#region Variables
@export var normal_speed = 100.0 ##Walking speed
@export var jump_velocity = -300.0 ##Initial jump velocity
@export_range(0,200) var acceleration = 20.0 ##Acceleration
@export_range(0,200) var deceleration = 0.2 ##Deceleration
@export var max_jump_time =  0.15 ##Maximum time the player can hold the jump button to influence the jump height
@export var dash_speed = 400 ##Speed for the dash
@export_range(0,200) var dash_acceleration = 20.0 ##Acceleration for the dash
@export_range(0,200) var dash_deceleration = 20.0 ##Deceleration for the dash
@export var ghost_node : PackedScene ##Ghost sprite, placed while dashing
@export var max_health = 3 ##Maximum player health
@export var gravity = 1000 ##Gravity
@export var max_y_velocity = 1800 ##Maximum fall velocity
@export var temporary_orb_prefab :PackedScene ##Temporary Orb Scene

var can_jump = false
var can_double_jump = false
var can_tripple_jump = false
var jump_time = 0.0
var is_disabled = false
var can_move = true
var current_health
var dash_direction
var current_orb
#endregion

func _ready():
	reset()
	disable()

func _physics_process(delta):
	if is_disabled:
		return
	
	add_gravity(delta)
	try_jump()
	handle_movement(delta)
	var was_on_floor = is_on_floor()
	move_and_slide()
	check_coyote(was_on_floor)
	handle_jump(delta)

func add_gravity(delta):
	if not is_on_floor() and can_move and velocity.y < max_y_velocity:
		velocity.y += gravity * delta

func handle_movement(delta):
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
	elif not $DashDelay.is_stopped():
		print(velocity)
		velocity.x = lerpf(velocity.x, normal_speed, dash_deceleration*delta)
		velocity.y = lerpf(velocity.y, 0, dash_deceleration*delta*2)
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
	pass

func enable():
	$Animation.visible = true
	$Camera.enabled = true
	await get_tree().create_timer(0.1).timeout
	is_disabled = false

func disable():
	$Camera.enabled = false
	$Animation.visible = false
	is_disabled = true

func reset():
	current_health = max_health
	velocity = Vector2.ZERO

func try_jump():
	var can_dash = $DashTimer.is_stopped() and $DashCooldown.is_stopped() and can_move
	if Input.is_action_just_pressed("dash") and can_dash:
		dash()
	if Input.is_action_just_pressed("jump"):
		$JumpBufferTimer.start()

func handle_jump(delta):
	if not $JumpBufferTimer.is_stopped() and can_jump:
		$JumpBufferTimer.stop()
		$CoyoteTimer.stop()
		if can_tripple_jump:
			can_tripple_jump = false
			can_jump = true
			can_double_jump = true
			start_jump()
		elif can_double_jump:
			can_jump = true
			can_double_jump = false
			start_jump()
		else:
			can_jump = false
			start_jump()
	if Input.is_action_pressed("jump") and jump_time < max_jump_time:
		velocity.y = jump_velocity
		jump_time += delta

func start_jump():
	velocity.y = jump_velocity
	jump_time = 0.0
	try_place_orb()

func check_coyote(was_on_floor):
	if was_on_floor and (not is_on_floor()) and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()
	elif is_on_floor():
		reset_jump()

func _on_coyote_timer_timeout():
	can_jump = true
	can_double_jump = true
	can_tripple_jump = false

func reset_jump():
	can_jump = true
	can_double_jump = true
	can_tripple_jump = true

func _on_trigger_area_area_entered(area):
	if area.is_in_group("jump_point"):
		reset_jump()
		area.use_point()
		current_orb = area
	elif area.is_in_group("temporary_orb"):
		current_orb = area

func _on_trigger_area_area_exited(area):
	if area.is_in_group("jump_point"):
		current_orb = null
	elif area.is_in_group("temporary_orb"):
		current_orb = null

func _on_trigger_area_body_entered(body):
	if body.is_in_group("bullet"):
		take_damage(1)
	if body.is_in_group("spikes"):
		die()

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
	$DashDelay.start()

func _on_dash_delay_timeout():
	$DashCooldown.start()
	can_move = true
	try_place_orb()

func take_damage(damage):
	if current_health > 1:
		$Camera.shake()
		$PlayerAnimation.play("hit_player_animation")
		current_health -= damage
	else:
		die()

func die():
	player_died.emit()

func try_place_orb():
	if is_on_floor():
		return
	elif not current_orb:
		place_temporary_orb(position)
	elif current_orb:
		entered_orb.emit(current_orb)

func place_temporary_orb(pos):
	var orb = temporary_orb_prefab.instantiate()
	orb.position = pos
	get_parent().add_child(orb)
	entered_orb.emit(orb)
