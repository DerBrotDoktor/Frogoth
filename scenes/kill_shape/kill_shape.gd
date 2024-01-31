extends Node2D

var point_objects = []
var point_positions = []

func add_point(point):
	point_objects.append(point)
	point_positions.append(point.position)
	$Outline.points = point_positions

func finish_shape(new_points):
	clear_points()
	for point in new_points:
		add_point(point)
	$Outline.closed = true
	
	var decomposed_points = Geometry2D.decompose_polygon_in_convex(point_positions)
	for point_array in decomposed_points:
		var point_numbers = []
		for point in point_array:
			point_numbers.append(point_positions.find(point))
		$PolygonSprite.polygons.append(point_numbers)
	
	
	$PolygonSprite.polygon = point_positions
	$KillArea/KillAreaCollision.polygon = point_positions
	$DeleteTimer.start()

func clear_points():
	$Outline.points = []
	point_positions = []
	point_objects = []

func delete_shape():
	for point in point_objects:
		if point and point.has_method("delete_point"):
			point.delete_point()
	queue_free()

func _on_delete_timer_timeout():
	delete_shape()
