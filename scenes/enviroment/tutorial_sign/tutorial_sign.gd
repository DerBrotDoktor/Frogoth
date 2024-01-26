extends Node2D


func _ready():
	hide_text()

func show_text():
	$Text.visible = true

func hide_text():
	$Text.visible = false

func _on_trigger_area_area_entered(area):
	if area.is_in_group("player"):
		show_text()


func _on_trigger_area_area_exited(area):
	$LeaveTimer.start()


func _on_leave_timer_timeout():
	hide_text()
