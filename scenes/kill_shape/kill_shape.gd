extends Node2D

@export var outline_tile :PackedScene
@export var backgound :PackedScene
@export var sprites :Array[Texture2D]
@export var lightning_particle :PackedScene

var point_objects = []
var point_positions = []
var last_length = 128
var shape_finished = false
var last_point

func add_point_object(obj):
	point_objects.append(obj)
	add_point(obj.position)

func add_point(point):
	point_positions.append(point)
	$KillShapePath.curve.add_point(point)
	$OrbConnectPlayer.position = point
	if point_positions.size() > 0:
		place_lightning()
	if not shape_finished:
		$OrbConnectPlayer.play()
	$Outline.points = point_positions

func place_lightning():
	var length = $KillShapePath.curve.get_baked_length()
	var points = $KillShapePath.curve.get_baked_points()
	var corners = []
	for point in points:
		corners.append($KillShapePath.curve.get_closest_point(point))
	for i in range(last_length+10, length, 128):
		var new_path_follow = outline_tile.instantiate()
		new_path_follow.scale.y = 0.5
		new_path_follow.progress = i
		$KillShapePath.add_child(new_path_follow)
		var distance = corners[corners.size()-1].distance_to(new_path_follow.position)
		if distance <= 128 and distance > 0.01:
			var new_length = (i - (128-distance))
			new_path_follow.progress = new_length
		new_path_follow.start()
	last_length = length

func place_lightning_particle(point):
	var particle = lightning_particle.instantiate()
	particle.position = point
	add_child(particle)

func finish_shape(new_points):
	shape_finished = true
	last_point = null
	clear_points()
	for child in $KillShapePath.get_children():
		child.queue_free()
	
	$KillShapePath.curve = Curve2D.new()
	last_length = 0
	
	var positions = []
	for point in new_points:
		positions.append(point.position)
	var polygons = get_polygons(positions)
	
	for poly in polygons:
		var convex = Geometry2D.convex_hull(poly)
		for point in convex:
			var is_object = false
			for obj in new_points:
				if obj.position == point:
					add_point_object(obj)
					is_object = true
					obj.will_be_in_shape = true
					place_lightning_particle(point)
			if not is_object:
				add_point(point)
		
		for obj in new_points:
			if not obj.will_be_in_shape:
				obj.queue_free()
		
		var sprite = backgound.instantiate()
		sprite.polygon = convex
		$Polygons.add_child(sprite)
		
		var collider = CollisionPolygon2D.new()
		collider.polygon = convex
		$KillArea.add_child(collider)
	
	for child in $KillShapePath.get_children():
		child.scale.y = 1.0
	$Outline.closed = true
	$FinishShapePlayer.play()
	_on_sprite_switch_timer_timeout()
	$SpriteSwitchTimer.start()
	$DeleteTimer.start()

func clear_points():
	$Outline.points = []
	point_positions = []
	point_objects = []

func delete_shape():
	delete_points()
	queue_free()

func delete_points():
	for point in point_objects:
		if is_instance_valid(point) and point.has_method("delete_point"):
			point.delete_point()
		elif is_instance_valid(point) and point.has_method("use_point"):
			point.is_in_shape = false

func discard_shape():
	$DiscardShapePlayer.play()
	await  $DiscardShapePlayer.finished
	delete_shape()

func _on_delete_timer_timeout():
	delete_shape()

func _on_kill_shape_path_tree_entered():
	$KillShapePath.curve = Curve2D.new()

func get_polygons(polygon):
	
	var points = []
	for pol in polygon:
		points.append(pol)
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

var last_sprite_idx

func _on_sprite_switch_timer_timeout():
	var sprite_idx = randi_range(0,sprites.size()-1)
	if last_sprite_idx == sprite_idx:
		sprite_idx += 1 if sprite_idx < (sprites.size()-1) else sprite_idx -1
	for child in $Polygons.get_children():
		child.texture = sprites[sprite_idx]
