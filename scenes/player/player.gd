extends CharacterBody2D
class_name Player

signal enter_bash_point(bash_point :BashPoint)

@export var normal_speed :float = 100.0

#Jump
@export var jump_velocity :float = -400.0
@export var double_jump_velocity :float = -400.0

var can_jump :bool = false
var can_double_jump :bool = false

@onready var coyote_timer :Timer = $CoyoteTimer
@export var coyote_time :float = 0.2

@onready var jump_buffer_timer = $JumpBufferTimer
@export var jump_buffer_time = 0.15

#Dash
@onready var dash_timer :Timer = $DashTimer
@export var dash_speed :int = 400
@export var dash_time :float = 0.2

@export var camera :Camera2D
var is_disabled = false

#Bash
var is_in_bash_point :bool = false #no jumping
var can_move :bool = true # no moving
var ready_for_bash :bool = false # no bash point trigger
var is_bashing :bool = false # bash movement

var current_bash_point :BashPoint

@onready var bash_timer = $BashTimer
@export var bash_time :float = 0.2
@export var bash_speed :int = 300

@onready var direction_arrow_sprite : Sprite2D = $DirectionArrow


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	
	if is_disabled:
		return
	
	# Add the gravity.
	if not is_on_floor() and can_move:
		velocity.y += gravity * delta
	
	if ready_for_bash:
		direction_arrow_sprite. look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("jump") and is_in_bash_point and not ready_for_bash :
		bash_point()
	elif Input.is_action_just_released("jump") and ready_for_bash:
		bash()
	elif Input.is_action_just_pressed("dash") and dash_timer.is_stopped() and can_move:
		dash_timer.start(dash_time)
	
	var speed = normal_speed if dash_timer.is_stopped() else dash_speed
	
	#Handle the movement
	var direction = Input.get_axis("left", "right")
	if direction and can_move:
		velocity.x = direction * speed
	elif can_move:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	#Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start(jump_buffer_time)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	#Coyte Time
	if was_on_floor and not is_on_floor() and coyote_timer.is_stopped():
		coyote_timer.start(coyote_time)
	elif is_on_floor():
		can_jump = true
		can_double_jump = true
	
	#Handle Jump
	if not jump_buffer_timer.is_stopped() and can_jump:
		jump_buffer_timer.stop()
		coyote_timer.stop()
		if is_in_bash_point:
			return
		if can_double_jump:
			can_jump = true
			can_double_jump = false
			velocity.y = jump_velocity
		else:
			can_jump = false
			velocity.y = double_jump_velocity

func _on_coyote_timer_timeout():
	can_jump = true
	can_double_jump = false
	pass

func disable():
	camera.enabled = false
	is_disabled = true

func enable():
	camera.enabled = true
	is_disabled = false

func bash_point():
	enter_bash_point.emit(current_bash_point)
	direction_arrow_sprite.visible = true
	can_move = false
	velocity = Vector2(0,0)
	position = current_bash_point.position
	ready_for_bash = true

func bash():
	var _direction :Vector2 = (get_global_mouse_position() - global_position).normalized()
	velocity = _direction * bash_speed
	bash_timer.start(bash_time)
	ready_for_bash = false
	direction_arrow_sprite.visible = false

func _on_bash_timer_timeout():
	if not ready_for_bash:
		can_move = true
	pass

func _on_trigger_area_area_entered(area):
	if area.is_in_group("bash_point"):
		current_bash_point = area
		is_in_bash_point = true
	pass

func _on_trigger_area_area_exited(area):
	if area.is_in_group("bash_point"):
		is_in_bash_point = false
		current_bash_point = null
	pass
