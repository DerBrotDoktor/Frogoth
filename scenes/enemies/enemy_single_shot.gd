extends "res://scenes/enemies/enemy_grounded.gd"

@export var bullet_speed = 200
@export var bullet_prefab :PackedScene
var target

var is_player_in_range = false

func trigger_area_entererd(area):
	super.trigger_area_entererd(area)
	if area.is_in_group("player"):
		$AttackCooldown.start()
		target = area
		shoot()
	pass

func shoot():
	var bullet = bullet_prefab.instantiate()
	bullet.direction =  (target.global_position - global_position).normalized()
	bullet.speed = bullet_speed
	bullet.position = position
	get_parent().call_deferred("add_child",bullet)# .add_child(bullet)
	pass

func _on_attack_cooldown_timeout():
	shoot()
	pass

func trigger_area_exited(area):
	if area.is_in_group("player"):
		$AttackCooldown.stop()
	pass
