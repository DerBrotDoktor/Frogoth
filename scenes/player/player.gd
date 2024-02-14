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
@export var squash = 0.2
@export var stretch = 0.1
@export var invincible_frames = 30

var can_jump = false
var can_double_jump = false
var can_tripple_jump = false
var jump_time = 0.0
var is_disabled = false
var can_move = true
var current_health
var dash_direction
var can_dash = true
var current_orb
var invincible_frames_left = 0
var can_place_jump_points = true
var max_orbs = 8
var orbs_left = 0
#endregion

#region stats
var stats_air_time = 0.0
var stats_jumps = 0
var stats_connected_orbs = 0
var stats_total_shapes = 0
#endregion

func _ready():
	reset()
	disable()

func _process(delta):
	if not is_on_floor():
		stats_air_time += delta
	if invincible_frames_left > 0:
		invincible_frames_left -= 1

func _physics_process(delta):
	if is_disabled:
		return
	
	add_gravity(delta)
	try_jump()
	handle_movement(delta)
	var was_on_floor = is_on_floor()
	move_and_slide()
	check_coyote(was_on_floor)
	squash_and_stretch(was_on_floor)
	handle_jump(delta)

func add_gravity(delta):
	if not is_on_floor() and can_move and velocity.y < max_y_velocity:
		velocity.y += gravity * delta
	if velocity.y > 0 and not $Animation.animation == "death":
		play_animation("fall")

func handle_movement(delta):
	if not $DashTimer.is_stopped():
		handle_dash_movement()
		return
	var direction = Input.get_axis("left", "right")
	if direction and can_move:
		if direction > 0:
			$Animation.flip_h = false
			velocity.x = min(velocity.x + acceleration, normal_speed)
			if is_on_floor():
				play_animation("walk")
				if not $SFXPlayer/WalkAudioPlayer.playing:
					$SFXPlayer/WalkAudioPlayer.play()
		elif direction < 0:
			velocity.x = max(velocity.x - acceleration, -normal_speed)
			$Animation.flip_h = true
			if is_on_floor():
				play_animation("walk")
				if not $SFXPlayer/WalkAudioPlayer.playing:
					$SFXPlayer/WalkAudioPlayer.play()
	elif (not $DashDelay.is_stopped()):
		if not dash_direction.x == 0:
			velocity.x = lerpf(velocity.x, normal_speed, dash_deceleration*delta)
		velocity.y = lerpf(velocity.y, 0, dash_deceleration*delta*2)
	elif can_move:
			velocity.x = lerpf(velocity.x, 0, deceleration)
			var is_falling_on_floor = $Animation.animation == "fall" and is_on_floor()
			var stopped_walking = $Animation.is_playing() and $Animation.animation == "walk"
			if (not $Animation.is_playing()) or is_falling_on_floor or stopped_walking:
				play_animation("idle")

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
	can_move = true
	orbs_left = max_orbs
	update_user_interface()

func reset_stats():
	stats_air_time = 0.0
	stats_jumps = 0
	stats_connected_orbs = 0
	stats_total_shapes = 0

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
	if can_jump:
		play_animation("double_jump")
	else:
		play_animation("jump")
	if not is_on_floor() and not $PlayerAnimation.is_playing():
		$PlayerAnimation.play("jump_vfx")
		$SFXPlayer/AirJumpAudioPlayer.play()
	else:
		$SFXPlayer/GroundJumpAudioPlayer.play()
	$StretchTimer.start()
	stats_jumps += 1

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
		if not area.used:
			reset_jump()
			$DashCooldown.stop()
			area.use_point()
		current_orb = area
	elif area.is_in_group("temporary_orb"):
		current_orb = area
	elif area.is_in_group("enable_jump_points"):
		can_place_jump_points = true
	elif area.is_in_group("dead_zone"):
		die()

func _on_trigger_area_area_exited(area):
	if area.is_in_group("jump_point"):
		current_orb = null
	elif area.is_in_group("temporary_orb"):
		current_orb = null

func _on_trigger_area_body_entered(body):
	if body.is_in_group("bullet"):
		take_damage(1)
		body.queue_free()
	elif body.is_in_group("spikes"):
		die()
	elif body.is_in_group("platform") and is_on_floor():
		if body.get_parent().has_method("start_fall"):
			body.get_parent().start_fall()

func dash():
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up","down"))
	
	if direction and can_move:
		var input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
		var input_y = Input.get_action_strength("down") - Input.get_action_strength("up")
		velocity = Vector2(input_x * 3000.0, input_y * 3000.0)
		dash_direction = Vector2(input_x, input_y).normalized()
		can_move = false
		can_dash = false
		update_user_interface()
		play_animation("dash")
		$SFXPlayer/DashAudioPlayer.play()
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

func _on_dash_cooldown_timeout():
	can_dash = true
	update_user_interface()

func take_damage(damage):
	if invincible_frames_left > 0:
		return
	invincible_frames_left = invincible_frames
	if current_health > 1:
		$Camera.shake()
		$JumpVFXAnimation.visible = false
		$SFXPlayer/DamageAudioPlayer.play()
		$PlayerAnimation.play("hit_player_animation")
		play_animation("damage")
		current_health -= damage
		update_user_interface()
	else:
		$Camera.shake()
		update_user_interface()
		die()

func die():
	can_move = false
	can_jump = false
	can_double_jump = false
	can_tripple_jump = false
	velocity = Vector2(0,gravity/2)
	play_animation("death")
	await  $Animation.animation_finished
	player_died.emit()

func try_place_orb():
	if is_on_floor() or not can_place_jump_points:
		return
	elif not current_orb and orbs_left > 0:
		place_temporary_orb(position)
	elif current_orb:
		entered_orb.emit(current_orb)

func place_temporary_orb(pos):
	orbs_left -= 1
	update_user_interface()
	var orb = temporary_orb_prefab.instantiate()
	orb.position = pos
	get_parent().add_child(orb)
	entered_orb.emit(orb)

func play_animation(animation):
	if animation:
		$Animation.play(animation)
	elif not animation:
		$Animation.play("idle")

func squash_and_stretch(was_on_floor):
	if not was_on_floor and is_on_floor():
		$SquashTimer.start()
	var current_deformation = $Animation.material.get_shader_parameter("deformation")
	if not $StretchTimer.is_stopped():
		$Animation.material.set_shader_parameter("deformation", Vector2(lerpf(current_deformation.x, stretch, 0.1), 0))
	elif not $SquashTimer.is_stopped():
		$Animation.material.set_shader_parameter("deformation", Vector2(0, lerpf(current_deformation.y, squash, 0.1)))
	else:
		$Animation.material.set_shader_parameter("deformation", lerp(current_deformation, Vector2.ZERO, 0.1))

func update_user_interface():
	$"../Canvas/UserInterface".set_health(current_health)
	$"../Canvas/UserInterface".set_orb_left_amount(orbs_left)
	$"../Canvas/UserInterface".set_dash_used(can_dash)
	var enemy_count = $"..".get_current_enemy_count()
	$"../Canvas/UserInterface".set_current_enemy_count(enemy_count)
