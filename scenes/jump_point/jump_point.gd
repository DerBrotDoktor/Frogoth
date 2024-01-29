extends Area2D


func use_point():
	$RefreshTimer.start()
	set_deferred("monitorable",false)
	$SpriteDeactivated.visible = true
	$SpriteActivated.visible = false

func refresh_point():
	set_deferred("monitorable",true)
	$SpriteDeactivated.visible = false
	$SpriteActivated.visible = true

func _on_refresh_timer_timeout():
	refresh_point()
