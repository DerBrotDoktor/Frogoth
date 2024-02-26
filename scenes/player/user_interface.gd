extends Control

@export var green_heart :Texture2D
@export var yellow_heart :Texture2D
@export var red_heart :Texture2D
@export var gray_heart :Texture2D

@export var dash :Texture2D
@export var dash_used :Texture2D

@export var orbs_left :Array[Texture2D]

@export var badges :SpriteFrames

var time = 0.0
var timer_allowed = false
var badge_times
var current_badge = 0

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
	$CurrentEnemyCountBack/CurrentEnemyCountLabel.text = str(value)

func check_badge():
	var badge = 0
	var seconds = int(time)
	print(seconds)
	if badge_times.size()  == 4:
		if seconds < badge_times[0]:
			print(badge_times[0])
			badge = 4
		elif seconds < badge_times[1]:
			print(badge_times[1])
			badge = 3
		elif seconds < badge_times[2]:
			print(badge_times[2])
			badge = 2
		elif seconds < badge_times[3]:
			print(badge_times[3])
			badge = 1
		elif seconds > badge_times[3]:
			badge = 0
	
	if badge != current_badge:
		update_badge(badge)

func update_badge(badge):
	current_badge = badge
	$MarginContainer/HBoxContainer/CurrentBadge.texture = badges.get_frame_texture("default",badge)
