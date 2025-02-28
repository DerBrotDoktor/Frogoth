extends Node2D

func start():
	$DustCloud.visible = true
	$DustFalling.visible = true
	$DustFalling.restart()
	$DustCloud.restart()

func stop():
	$DustCloud.emitting = false
	$DustFalling.emitting = false
	$DustCloud.visible = false
	$DustFalling.visible = false
