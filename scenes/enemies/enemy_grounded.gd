extends CharacterBody2D

@export var speed = 20
@export var direction = 1
@export var flip_cooldown_time = 0.3

func _physics_process(_delta):
	handle_movement()
	check_path()

func handle_movement():
	velocity.x = speed * direction
	move_and_slide()

func check_path():
	if ($HorizontalRayCast.is_colliding() or not $VerticalRayCastL.is_colliding() or not $VerticalRayCastR.is_colliding()) and $FlipCooldownTimer.is_stopped():
		flip()

func flip():
	$FlipCooldownTimer.start(flip_cooldown_time)
	$Animation.flip_h = !$Animation.flip_h
	direction *= -1
	$HorizontalRayCast.target_position.x *= -1
	pass

func trigger_area_entererd(area):
	if area.is_in_group("killing_area"):
		queue_free()
	pass

func _on_trigger_area_area_entered(area):
	trigger_area_entererd(area)
	pass

func trigger_area_exited(area):
	pass

func _on_trigger_area_area_exited(area):
	trigger_area_exited(area)
	pass
