extends "res://scenes/enemies/enemy_grounded.gd"

var is_player_in_range = false

func flip():
	super.flip()
	$ChargeAnimation.position.x = -$ChargeAnimation.position.x

func attack():
	$AttackCooldown.start()
	is_attacking = true
	play_animation("attack")

func shoot():
	if is_instance_valid(target):
		super.shoot()
	else:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("RESET")

func play_animation(animation):
	if not is_dead:
		$AnimationPlayer.play(animation)

func trigger_area_entererd(area):
	if area.is_in_group("killing_area"):
		$AnimationPlayer.clear_queue()
		$AnimationPlayer.stop()
		is_dead = true
		$AnimationPlayer.play("death")


func _on_enemy_1_death_vfx_finished():
	die()
