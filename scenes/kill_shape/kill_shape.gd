extends Node2D

var points = []
var point_positions = []

func add_point(point):
	points.append(point)
	point_positions.append(point.position)
	$Outline.points = point_positions
	pass

func finish_shape():
	$Outline.closed = true
	$PolygonSprite.polygon = point_positions
	$KillArea/KillAreaCollision.polygon = point_positions
	$DeleteTimer.start()
	pass

func delete_shape():
	for point in points:
		point.is_in_shape = false
	queue_free()
	pass

func _on_delete_timer_timeout():
	delete_shape()
	pass
