extends PathFollow2D

var last_sprite_number = 0

func start():
	_on_sprite_switch_timer_timeout()
	$Sprite/SpriteSwitchTimer.start()

func _on_sprite_switch_timer_timeout():
	var sprite_number = randi_range(0, $Sprite.hframes-1)
	if sprite_number == last_sprite_number:
		sprite_number += 1 if sprite_number < ($Sprite.hframes-1) else -1
	$Sprite.flip_h = true if randi_range(0,1) == 1 else false
	$Sprite.frame = sprite_number
	last_sprite_number = sprite_number
