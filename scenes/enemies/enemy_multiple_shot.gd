extends "res://scenes/enemies/enemy_grounded.gd"

@export var angle :float = 135.0
@export var bullet_amount = 5

func attack():
	$AttackCooldown.start()
	is_attacking = true
	play_animation("attack")

func shoot():
	if is_instance_valid(target):
		var angle_per_bullet = angle / (bullet_amount - 1)
		var player_angle = rad_to_deg(get_angle_to(target.global_position))
		
		for i in range(bullet_amount):
			var bullet_angle = (-angle/2) + (angle_per_bullet * i)
			var bullet_direction = player_angle + bullet_angle
			super.new_bullet(Vector2.from_angle(deg_to_rad(bullet_direction)))
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

func _on_enemy_2_death_vfx_finished():
	die()
