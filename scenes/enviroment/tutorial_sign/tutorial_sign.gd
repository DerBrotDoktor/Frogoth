extends Node2D


func _ready():
	hide_text()

func show_text():
	$LeaveTimer.stop()
	$TextContainer.visible = true

func hide_text():
	$TextContainer.visible = false

func _on_trigger_area_area_entered(area):
	if area.is_in_group("player"):
		show_text()


func _on_trigger_area_area_exited(area):
	if area.is_in_group("player") and $LeaveTimer.is_inside_tree():
		$LeaveTimer.start()


func _on_leave_timer_timeout():
	hide_text()
