extends Node2D

@export var speed = 15.0

var is_falling
var platform
var start_position

func _ready():
	platform =  find_child("Platform")

func _physics_process(_delta):
	if is_falling:
		position.y = position.y + speed

func start_fall():
	if $AnimationTimer.is_stopped():
		$AnimationPlayer.play("fall_preperation")
		$FallingPlatformDust.start()
		$FalingPreperationPlayer.play()
		$AnimationTimer.start()

func fall():
	$FallingPlatformDust.stop()
	if platform:
		is_falling = true
		platform.process_mode = PROCESS_MODE_DISABLED
		start_position = position
		z_index = -2

func stop_fall():
	is_falling = false
	$RespawnTimer.start()
	pass

func respawn():
	z_index = 0
	visible = false
	position = start_position
	$AnimationPlayer.play("respawn")
	visible = true
	await  $AnimationPlayer.animation_finished
	platform.process_mode = PROCESS_MODE_INHERIT

func _on_animation_timer_timeout():
	$AnimationPlayer.stop()
	fall()

func _on_respawn_timer_timeout():
	respawn()

func _on_trigger_area_area_entered(area):
	if area.is_in_group("dead_zone"):
		stop_fall()
