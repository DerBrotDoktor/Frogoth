extends CharacterBody2D

@export var knockback_strength = 2000

var direction
var speed

func set_properties(_speed, _scale, _position, _direction):
	scale = Vector2(_scale, _scale)
	speed = _speed
	position = _position
	direction = _direction
	look_at(position+_direction)

func _physics_process(_delta):
	if direction:
		velocity = direction * speed
	move_and_slide()

func _on_trigger_area_body_entered(body):
	if not body.is_in_group("player") and not body.is_in_group("bullet"):
		direction = null
		velocity = Vector2.ZERO
		$Collider.set_deferred("disabled",true)
		destroy_bullet()

func destroy_bullet():
	$Sprite.play("destroy")
	await $Sprite.animation_finished
	queue_free()
