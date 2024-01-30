extends Control

var time = 0.0
var timer_allowed = false

func _process(delta):
	if timer_allowed:
		time += delta
		$TimeText.text = str(int(time))

func _on_main_start_timer():
	timer_allowed = true


func _on_main_restart_timer():
	time = 0.0
	$TimeText.text = str(int(time))
