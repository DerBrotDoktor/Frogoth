extends Control

var time = 0.0
var timer_allowed = false

func _process(delta):
	if timer_allowed:
		time += delta
		$TimeText.text = str(int(time))
	pass


func _on_main_start_timer():
	timer_allowed = true
	pass
