extends CharacterBody2D


@export var speed :int = 100
@export var direction :int = 1

@onready var flip_cooldown_timer :Timer = $FlipCooldownTimer
@onready var horizontal_ray_cast :RayCast2D = $HorizontalRayCast
@onready var vertical_ray_cast_l :RayCast2D = $VerticalRayCastL
@onready var vertical_ray_cast_r :RayCast2D = $VerticalRayCastR

func _physics_process(delta):
	velocity.x = speed * direction * delta
	print(velocity.x)
	move_and_slide()
	if not horizontal_ray_cast.is_colliding() or not vertical_ray_cast_l.is_colliding() or not vertical_ray_cast_r.is_colliding():
		flip()

func flip():
	direction *= -1
	pass
