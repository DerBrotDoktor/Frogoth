extends Node2D

@export var speed = 15.0

var is_falling
var platform
var start_position

func _ready():
	platform =  find_child("Platform")

func _physics_process(delta):
	if is_falling:
		position.y = position.y + speed

func start_fall():
	$AnimationPlayer.play("fall_preperation")
	$FalingPreperationPlayer.play()
	$AnimationTimer.start()
func fall():
	if platform:
		is_falling = true
		platform.process_mode = PROCESS_MODE_DISABLED
		start_position = position

func stop_fall():
	is_falling = false
	$RespawnTimer.start()
	pass

func respawn():
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
