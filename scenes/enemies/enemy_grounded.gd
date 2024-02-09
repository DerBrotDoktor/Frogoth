extends CharacterBody2D

@export var speed = 100 ##Speed
@export var direction = 1 ##The direction the enemy is facing
@export var bullet_speed = 200## The speed of the bullet
@export var bullet_scale = 1.0##The scale of the bullet
@export var can_move = true
@export var is_attacking = false
@export var is_dead = false
var bullet_prefab = preload("res://scenes/enemies/bullet.tscn")

var target


func _physics_process(_delta):
	if can_move and not is_attacking and not is_dead:
		handle_movement()
		check_path()
	elif not is_attacking and not is_dead:
		play_animation("idle")

func handle_movement():
	velocity.x = speed * direction
	if velocity.x != 0:
		play_animation("walk")
	move_and_slide()

func check_path():
	if ($HorizontalRayCast.is_colliding() or not $VerticalRayCastL.is_colliding() or not $VerticalRayCastR.is_colliding()) and $FlipCooldownTimer.is_stopped():
		flip()

func flip():
	$FlipCooldownTimer.start()
	$Animation.flip_h = !$Animation.flip_h
	direction *= -1
	$HorizontalRayCast.target_position.x *= -1

func trigger_area_entererd(area):
	if area.is_in_group("killing_area"):
		die()
	
func attack_area_entererd(area):
	if area.is_in_group("player"):
		target = area
		if $AttackCooldown.is_stopped():
			attack()

func attack():
	$AttackCooldown.start()
	is_attacking = true
	play_animation("attack")

func shoot():
	if target:
		var b_direction =  (target.global_position - global_position).normalized()
		new_bullet(b_direction)

func new_bullet(b_direction):
	var bullet = bullet_prefab.instantiate()
	if is_instance_valid(self):
		bullet.set_properties(bullet_speed, bullet_scale, position, b_direction)
		get_parent().call_deferred("add_child",bullet)
	pass

func _on_trigger_area_area_entered(area):
	trigger_area_entererd(area)

func attack_area_exited(area):
	if area.is_in_group("player"):
		$AttackCooldown.stop()

func _on_attack_cooldown_timeout():
	if not is_attacking:
		attack()

func _on_attack_area_area_entered(area):
	attack_area_entererd(area)

func _on_attack_area_area_exited(area):
	attack_area_exited(area)

func play_animation(animation):
	$Animation.play(animation)

func die():
	is_dead = true
	var main = get_tree().get_root().get_node("Main")
	if main:
		main.check_for_win()
	queue_free()
