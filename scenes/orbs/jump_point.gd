extends Area2D

var is_in_shape = false
var used = false
var will_be_in_shape = false

func use_point():
	$UsePointPlayer.play()
	$RefreshTimer.start()
	used = true
	$AnimationPlayer.play("use")

func refresh_point():
	used = false
	$SpriteDeactivated.visible = false
	$SpriteActivated.visible = true

func _on_refresh_timer_timeout():
	refresh_point()
