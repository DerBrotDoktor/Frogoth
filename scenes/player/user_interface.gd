extends Control

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
