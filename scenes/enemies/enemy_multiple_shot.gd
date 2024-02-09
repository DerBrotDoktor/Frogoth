extends "res://scenes/enemies/enemy_grounded.gd"

@export var angle :float = 135.0
@export var bullet_amount = 5

func shoot():
	var angle_per_bullet = angle / (bullet_amount - 1)
	var player_angle = rad_to_deg(get_angle_to(target.global_position))
	
	for i in range(bullet_amount):
		var bullet_angle = (-angle/2) + (angle_per_bullet * i)
		var bullet_direction = player_angle + bullet_angle
		super.new_bullet(Vector2.from_angle(deg_to_rad(bullet_direction)))

func play_animation(animation):
	$AnimationPlayer.play(animation)
	
func trigger_area_entererd(area):
	if area.is_in_group("killing_area"):
		$AnimationPlayer.stop()
		play_animation("death")
