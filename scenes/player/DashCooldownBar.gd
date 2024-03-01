extends Node2D

func _ready():
	$ProgressBar.visible = false

func enable():
	$ProgressBar.visible = true

func disable():
	$AnimationPlayer.play("full")

func _process(delta):
	if visible:
		$ProgressBar.value = 100 - ($"../DashCooldown".time_left * 100)
