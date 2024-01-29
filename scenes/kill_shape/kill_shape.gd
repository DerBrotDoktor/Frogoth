extends Node2D

var points = []
var point_positions = []

func add_point(point):
	points.append(point)
	point_positions.append(point.position)
	$Outline.points = point_positions

func finish_shape(new_points):
	$Outline.points = []
	point_positions = []
	points = []
	for point in new_points:
		add_point(point)
	$Outline.closed = true
	$PolygonSprite.polygon = point_positions
	$KillArea/KillAreaCollision.polygon = point_positions
	$DeleteTimer.start()

func delete_shape():
	for point in points:
		if point.has_method("delete_point"):
			point.delete_point()
	queue_free()

func _on_delete_timer_timeout():
	delete_shape()
