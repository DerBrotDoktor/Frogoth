extends Control

func _ready():
	if visible:
		$TeamLogo.visible = false
		$VideoStreamPlayer.visible = false
		$WarningScreen.visible = true

func warning_finished():
	$WarningScreen.visible = false
	$VideoStreamPlayer.visible = true
	$VideoStreamPlayer.play()

func _on_video_stream_player_finished():
	$AnimationPlayer.play("team_logo")


func load_main_menu():
	$"../../SceneTransition/SceneTransitionAnimationPlayer".play("fade_in")
	await $"../../SceneTransition/SceneTransitionAnimationPlayer".animation_finished
	$"../../Canvas".switch_to_child("MainMenu")
	visible = false
	$"../../SceneTransition/SceneTransitionAnimationPlayer".play_backwards("fade_in")
