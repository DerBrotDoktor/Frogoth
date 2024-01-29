extends CharacterBody2D

var direction
var speed

func _physics_process(_delta):
	if direction:
		velocity = direction * speed
	move_and_slide()

func _on_trigger_area_body_entered(body):
	if not body.is_in_group("player") and not body.is_in_group("bullet"):
		queue_free()
