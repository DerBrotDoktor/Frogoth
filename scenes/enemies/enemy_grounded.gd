extends CharacterBody2D


@export var speed :int = 20
@export var direction :int = 1

@export var flip_cooldown_time :float = 0.3
@onready var flip_cooldown_time_timer :Timer = $FlipCooldownTimer
@onready var horizontal_ray_cast :RayCast2D = $HorizontalRayCast
@onready var vertical_ray_cast_l :RayCast2D = $VerticalRayCastL
@onready var vertical_ray_cast_r :RayCast2D = $VerticalRayCastR

@onready var sprite :AnimatedSprite2D = $Animation


func _physics_process(_delta):
	velocity.x = speed * direction
	move_and_slide()
	if (horizontal_ray_cast.is_colliding() or not vertical_ray_cast_l.is_colliding() or not vertical_ray_cast_r.is_colliding()) and flip_cooldown_time_timer.is_stopped():
		flip()


func flip():
	flip_cooldown_time_timer.start(flip_cooldown_time)
	sprite.flip_h = !sprite.flip_h
	direction *= -1
	horizontal_ray_cast.target_position.x *= -1
	pass
