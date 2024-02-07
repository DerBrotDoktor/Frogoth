extends Node2D

@export var outline_tile :PackedScene

var point_objects = []
var point_positions = []
var last_length = 128

func add_point(point):
	point_objects.append(point)
	point_positions.append(point.position)
	$KillShapePath.curve.add_point(point.position)
	if point_positions.size() > 0:
		place_lightning()
	$Outline.points = point_positions

func place_lightning():
	var length = $KillShapePath.curve.get_baked_length()
	for i in range(last_length, length, 128):
		var new_path_follow = outline_tile.instantiate()
		$KillShapePath.add_child(new_path_follow)
		new_path_follow.progress = i
		new_path_follow.start()
	last_length = length

func finish_shape(new_points):
	clear_points()
	for point in new_points:
		add_point(point)
	$Outline.closed = true
	var polygons = get_polygons(new_points)

	for point_array in polygons:
		var coll = CollisionPolygon2D.new()
		coll.polygon = point_array
		$KillArea.add_child(coll)
	
	$DeleteTimer.start()

func clear_points():
	$Outline.points = []
	point_positions = []
	point_objects = []

func delete_shape():
	for point in point_objects:
		if is_instance_valid(point) and point.has_method("delete_point"):
			point.delete_point()
	queue_free()

func _on_delete_timer_timeout():
	delete_shape()

func get_polygons(polygon):
	
	var points = []
	for pol in polygon:
		points.append(pol.position)
	var point_list = []
	var result_list = []
	var end_index = points.size()
	
	for i in range(0, end_index):
		point_list.append(points[i])
		if i+1 < points.size():
			var a1 = points[i]
			var a2 = points[i+1]
			
			for j in range(i+2,end_index-1):
				var b1 = points[j]
				var b2 = points[j+1] if j+1 < points.size() else points[0]
				var intersection = get_intersection(a1,a2,b1,b2)
				if intersection == a1:
					intersection = null
				
				if intersection:
					point_list.append(intersection)
					for h in range(j+1, end_index):
						point_list.append(points[h])
					result_list.append(point_list)
					point_list = []
					point_list.append(intersection)
					end_index = j+2
					i = j
	
	result_list.append(point_list)
	return result_list

func get_intersection(a1, a2, b1, b2):
	var dir_a = a2-a1
	var dir_a_perpendicular = Vector2(dir_a.y, -dir_a.x).normalized()
	var to_b1 = b1-a1
	var to_b2 = b2-a1
	
	if sign(dir_a_perpendicular.dot(to_b1)) == sign(dir_a_perpendicular.dot(to_b2)):
		return null
	
	var dir_b = b2-b1
	var dir_b_perpendicular = Vector2(dir_b.y, -dir_b.x).normalized()
	var to_a1 = a1-b1
	var to_a2 = a2-b1
	
	if sign(dir_b_perpendicular.dot(to_a1)) == sign(dir_b_perpendicular.dot(to_a2)):
		return null
	
	var dist_b1 = abs(dir_a_perpendicular.dot(to_b1))
	var dist_b2 = abs(dir_a_perpendicular.dot(to_b2))
	return (dist_b2 * b1 + dist_b1 * b2) / (dist_b1 + dist_b2)


func _on_kill_shape_path_tree_entered():
	$KillShapePath.curve = Curve2D.new()
	pass # Replace with function body.
