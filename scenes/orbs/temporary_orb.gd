extends Area2D

var is_in_shape = false
var will_be_in_shape = false

func delete_point():
	queue_free()
