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
@export var last_orb_vfx_prefab :PackedScene

var can_jump = false
var can_double_jump = false
var can_tripple_jump = false
var jump_time = 0.0
var is_disabled = false
var can_move = true
var current_health
var dash_direction
var can_dash = true
var current_orbs = []
var invincible_frames_left = 0
var can_place_jump_points = true
var max_orbs = 8
var orbs_left = 0
var is_dead = true
var knockback
var is_walking = false
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
	if is_disabled or is_dead:
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
	var can_play_fall = (not $Animation.animation == "death") or (not $Animation.animation == "damage")
	if velocity.y > 0 and can_play_fall:
		play_animation("fall")

func handle_movement(delta):
	if not $DashTimer.is_stopped():
		handle_dash_movement()
		return
	var direction = Input.get_axis("left", "right")
	if (not direction) or (not can_move) or (not is_on_floor()) and is_walking:
		is_walking = false
		check_walk_vfx()
	if direction and can_move:
		if not is_walking and is_on_floor():
			is_walking = true
			check_walk_vfx()
		if direction > 0:
			$Animation.flip_h = false
			$WalkVFX.flip_h = true
			if $WalkVFX.position.x > 0:
				$WalkVFX.position.x = -$WalkVFX.position.x
			velocity.x = min(velocity.x + acceleration, normal_speed)
			if is_on_floor():
				play_animation("walk")
				if not $SFXPlayer/WalkAudioPlayer.playing:
					$SFXPlayer/WalkAudioPlayer.play()
		elif direction < 0:
			velocity.x = max(velocity.x - acceleration, -normal_speed)
			$Animation.flip_h = true
			$WalkVFX.flip_h = false
			if $WalkVFX.position.x < 0:
				$WalkVFX.position.x = -$WalkVFX.position.x
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

func enable():
	$Animation.visible = true
	$EnemyIndicatorController.visible = true
	await get_tree().create_timer(0.1).timeout
	$Camera.position_smoothing_enabled = true
	is_disabled = false

func disable():
	$Camera.position_smoothing_enabled = false
	$Animation.visible = false
	$EnemyIndicatorController.visible = false
	is_disabled = true

func reset():
	for child in $EnemyIndicatorController.get_children():
		child.queue_free()
	current_health = max_health
	velocity = Vector2.ZERO
	can_move = true
	orbs_left = max_orbs
	update_user_interface()
	is_dead = false

func reset_stats():
	stats_air_time = 0.0
	stats_jumps = 0
	stats_connected_orbs = 0
	stats_total_shapes = 0

func try_jump():
	if is_dead: return
	if Input.is_action_just_pressed("dash") and can_dash:
		dash()
	if Input.is_action_just_pressed("jump"):
		$JumpBufferTimer.start()

func handle_jump(delta):
	if is_dead: return
	if not $JumpBufferTimer.is_stopped() and can_jump:
		$JumpBufferTimer.stop()
		$CoyoteTimer.stop()
		if can_tripple_jump:
			can_jump = true
			can_tripple_jump = false
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
	if not is_on_floor() and not $PlayerAnimation.current_animation == "hit_player_animation":
		if not can_jump:
			$PlayerAnimation.play("RESET")
			$LandingVfxAnimation.visible = false
			$PlayerAnimation.play("tripple_jump_vfx")
		else:
			$PlayerAnimation.play("RESET")
			$LandingVfxAnimation.visible = false
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
	if is_dead: return
	can_jump = true
	can_double_jump = true
	can_tripple_jump = true

func _on_trigger_area_area_entered(area):
	if area.is_in_group("jump_point"):
		if not area.used:
			reset_jump()
			$DashCooldown.stop()
			$DashCooldownBar.disable()
			area.use_point()
			can_dash = true
		current_orbs.append(area)
	elif area.is_in_group("temporary_orb"):
		current_orbs.append(area)
	elif area.is_in_group("enable_jump_points"):
		can_place_jump_points = true
	elif area.is_in_group("dead_zone"):
		die()

func _on_trigger_area_area_exited(area):
	if area.is_in_group("jump_point"):
		current_orbs.erase(area)
	elif area.is_in_group("temporary_orb"):
		current_orbs.erase(area)

func _on_trigger_area_body_entered(body):
	if body.is_in_group("bullet"):
		var knockabck_direction = (position - body.position).normalized()
		set_knockback(knockabck_direction, body.knockback_strength,0.2)
		take_damage(1)
		body.queue_free()
	elif body.is_in_group("spikes"):
		var knockabck_direction = (position - body.position).normalized()
		if abs(knockabck_direction.y) > abs(knockabck_direction.x):
			knockabck_direction.y = 0
		else:
			knockabck_direction.x = 0
		set_knockback(knockabck_direction, body.knockback_strength, 0.35)
		take_damage(1)
	elif body.is_in_group("platform") and (is_on_floor() or (not $DashTimer.is_stopped())):
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
		set_collision_layer_value(4,false)
		set_collision_mask_value(4,false)
		

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
	$DashCooldownBar.enable()
	can_move = true
	set_collision_layer_value(4,true)
	set_collision_mask_value(4,true)
	try_place_orb()

func _on_dash_cooldown_timeout():
	can_dash = true
	$DashCooldownBar.disable()
	update_user_interface()

func take_damage(damage):
	if invincible_frames_left > 0:
		return
	elif not $DashTimer.is_stopped() or not $DashDelay.is_stopped():
		return
	invincible_frames_left = invincible_frames
	if current_health > 1:
		$Camera.shake()
		$JumpVFXAnimation.visible = false
		$SFXPlayer/DamageAudioPlayer.play()
		$PlayerAnimation.play("RESET")
		$LandingVfxAnimation.visible = false
		$PlayerAnimation.play("hit_player_animation")
		play_animation("damage")
		current_health -= damage
		update_user_interface()
	else:
		$Camera.shake()
		update_user_interface()
		die()

func die():
	is_dead = true
	can_move = false
	can_jump = false
	can_double_jump = false
	can_tripple_jump = false
	velocity = Vector2.ZERO
	velocity = Vector2(0,gravity/2.0)
	play_animation("death")
	await  $Animation.animation_finished
	player_died.emit()

func try_place_orb():
	if is_on_floor() or (not can_place_jump_points):
		return
	elif (current_orbs.size() <= 0) and (orbs_left > 0):
		place_temporary_orb(position)
	elif current_orbs.size() > 0:
		var nearest_orb
		for orb in current_orbs:
			if not nearest_orb:
				nearest_orb = orb
			else:
				var distance = orb.position.distance_to(position)
				var nearest_distance = nearest_orb.position.distance_to(position)
				if distance < nearest_distance:
					nearest_orb = orb
		entered_orb.emit(nearest_orb)

func place_temporary_orb(pos):
	orbs_left -= 1
	update_user_interface()
	var orb = temporary_orb_prefab.instantiate()
	orb.position = pos
	get_parent().add_child(orb)
	entered_orb.emit(orb)
	if orbs_left == 0:
		$SFXPlayer/LastOrbPlacedPlayer.play()
		var last_orb_vfx = last_orb_vfx_prefab.instantiate()
		last_orb_vfx.global_position = global_position
		get_parent().add_child(last_orb_vfx)
		last_orb_vfx.emitting = true

func play_animation(animation):
	var animation_not_allowed = ($Animation.animation == "death" or $Animation.animation == "damage")
	if $Animation.is_playing() and animation_not_allowed:
		return
	if animation:
		$Animation.play(animation)
	elif not animation:
		$Animation.play("idle")

func squash_and_stretch(was_on_floor):
	if not was_on_floor and is_on_floor():
		$SquashTimer.start()
		if not $PlayerAnimation.current_animation == "hit_player_animation":
			$PlayerAnimation.play("landing_vfx")
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

func show_enemy_indicators(targets):
	$EnemyIndicatorController.show_indicators(targets)

func set_knockback(direction,strength,time):
	if invincible_frames_left > 0:
		return
	elif not $DashTimer.is_stopped() or not $DashDelay.is_stopped():
		return
	can_move = false
	velocity = direction * strength
	$KnockbackTime.start(time)

func _on_knockback_time_timeout():
	knockback = Vector2.ZERO
	can_move = true

func set_camera_limits(limits):
	$Camera.limit_left = limits.x
	$Camera.limit_top = limits.y
	$Camera.limit_right = limits.z
	$Camera.limit_bottom = limits.w

func check_walk_vfx():
	if $WalkVFX.animation == "running_start" and is_walking:
		$WalkVFX.play("running")
	elif $WalkVFX.animation == "running" and is_walking:
		$WalkVFX.play("running")
	elif $WalkVFX.animation == "running" and not is_walking:
		$WalkVFX.play("running_stop")
	elif $WalkVFX.animation == "running_stop" and is_walking:
		$WalkVFX.visible = true
		$WalkVFX.play("running_start")
	else:
		$WalkVFX.visible = false
		$WalkVFX.animation = "running_stop"
