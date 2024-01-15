extends CharacterBody2D

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

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("dash") and dash_timer.is_stopped():
		dash_timer.start(dash_time)
	
	var speed = dash_speed if not dash_timer.is_stopped() else normal_speed
	
	#Handle the movement
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	#Jump buffer
	if Input.is_action_just_pressed("jump"):
		print ("tttt")
		jump_buffer_timer.start(jump_buffer_time)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	#Coyte Time
	if was_on_floor and not is_on_floor() and coyote_timer.is_stopped():
		print("cooyte")
		coyote_timer.start(coyote_time)
	elif is_on_floor():
		can_jump = true
		can_double_jump = true
	
	#Handle Jump
	if not jump_buffer_timer.is_stopped() and can_jump:
		print("jump")
		jump_buffer_timer.stop()
		coyote_timer.stop()
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
