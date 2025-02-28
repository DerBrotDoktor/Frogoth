extends Control

func _ready():
	visible = true
	$AnimationPlayer.play("logos")

func warning_finished():
	$WarningScreen.visible = false
	load_main_menu()

func _on_video_stream_player_finished():
	$WarningScreen.visible = true

func load_main_menu():
	$"../../SceneTransition/SceneTransitionAnimationPlayer".play("fade_in")
	await $"../../SceneTransition/SceneTransitionAnimationPlayer".animation_finished
	$"../../Canvas".switch_to_child("MainMenu")
	visible = false
	$"../../SceneTransition/SceneTransitionAnimationPlayer".play_backwards("fade_in")
