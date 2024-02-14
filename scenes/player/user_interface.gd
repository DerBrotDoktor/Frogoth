extends Control

@export var green_heart :Texture2D
@export var yellow_heart :Texture2D
@export var red_heart :Texture2D
@export var gray_heart :Texture2D

@export var dash :Texture2D
@export var dash_used :Texture2D

@export var orbs_left :Array[Texture2D]

var time = 0.0
var timer_allowed = false

func _process(delta):
	if timer_allowed:
		time += delta
		$TimeText.text = str(int(time))

func reset_timer():
	time = 0.0
	$TimeText.text = str(int(time))

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
