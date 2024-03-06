extends Control

@export var green_heart :Texture2D
@export var yellow_heart :Texture2D
@export var red_heart :Texture2D
@export var gray_heart :Texture2D
@export var dash :Texture2D
@export var dash_used :Texture2D
@export var orbs_left :Array[Texture2D]
@export var badges :SpriteFrames

enum InputMethods {KEYBOARD, CONTROLLER}

var last_input_method :InputMethods = InputMethods.KEYBOARD
var time = 0.0
var timer_allowed = false
var badge_times
var current_badge = 0
var current_enemy_count = -5

func _ready():
	update_key_prompts()

func _process(delta):
	if timer_allowed:
		time += delta
		$MarginContainer/HBoxContainer/TimeText.text = str(int(time))
		check_badge()

func reset_timer():
	time = 0.0
	$MarginContainer/HBoxContainer/TimeText.text = str(int(time))

func _on_visibility_changed():
	timer_allowed = visible
	if visible:
		get_tree().paused = false
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_health(health):
	$HealthBar.set_health(health)

func reset_stats():
	time = 0.0

func set_orb_left_amount(amount):
	$OrbsLeft.texture = orbs_left[amount]
	pass

func set_dash_used(can_dash):
	$DashCooldown.texture = dash if can_dash else dash_used

func set_current_enemy_count(value):
	if value < current_enemy_count:
		$CurrentEnemyCountBack/EnemyCounterVFX.restart()
	current_enemy_count =  value
	$CurrentEnemyCountBack/CurrentEnemyCountLabel.text = str(value)

func check_badge():
	var badge = 0
	var seconds = int(time)
	if badge_times.size()  == 4:
		if seconds < badge_times[0]:
			badge = 4
		elif seconds < badge_times[1]:
			badge = 3
		elif seconds < badge_times[2]:
			badge = 2
		elif seconds < badge_times[3]:
			badge = 1
		elif seconds > badge_times[3]:
			badge = 0
	
	if badge != current_badge:
		update_badge(badge)

func update_badge(badge):
	current_badge = badge
	$MarginContainer/HBoxContainer/CurrentBadge.texture = badges.get_frame_texture("default",badge)


func _input(event):
	var event_is_controller = event is InputEventJoypadButton or event is InputEventJoypadMotion
	var event_is_keyboard = event is InputEventKey or event is InputEventMouseButton
	
	if event_is_controller and last_input_method == InputMethods.KEYBOARD:
		if event is InputEventJoypadMotion:
			if (event.axis_value < 0.2) and (event.axis_value > -0.2):
				return
		last_input_method = InputMethods.CONTROLLER
		update_key_prompts()
		
	elif event_is_keyboard and last_input_method == InputMethods.CONTROLLER:
		last_input_method = InputMethods.KEYBOARD
		update_key_prompts()

func update_key_prompts():
	if last_input_method == InputMethods.KEYBOARD:
		$Help/HelpKeyboard.visible = true
		$Help/HelpController.visible = false
	elif last_input_method == InputMethods.CONTROLLER:
		$Help/HelpKeyboard.visible = false
		$Help/HelpController.visible = true
