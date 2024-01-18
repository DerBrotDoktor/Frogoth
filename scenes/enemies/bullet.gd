extends CharacterBody2D

var direction
var speed

func _physics_process(delta):
	if direction:
		velocity = direction * speed
	move_and_slide()
