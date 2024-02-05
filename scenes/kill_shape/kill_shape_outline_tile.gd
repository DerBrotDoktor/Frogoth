extends Sprite2D

var last_sprite = 0

func _ready():
	$SpriteSwitchTimer.start()

func _on_sprite_switch_timer_timeout():
	var sprite_pos = region_rect.size.x +(region_rect.size.x  * randi_range(0, texture.get_width()/region_rect.size.x-1))
	if sprite_pos == last_sprite:
		sprite_pos += region_rect.size.x if not sprite_pos + region_rect.size.x > texture.get_width() else -region_rect.size.x
	region_rect.position.x = sprite_pos
	last_sprite = sprite_pos
