extends Area2D

var is_in_shape = false
var used = false

func use_point():
	$RefreshTimer.start()
	used = true
	$SpriteDeactivated.visible = true
	$SpriteActivated.visible = false

func refresh_point():
	used = false
	$SpriteDeactivated.visible = false
	$SpriteActivated.visible = true

func _on_refresh_timer_timeout():
	refresh_point()
