extends HBoxContainer

func set_health(value):
	var idx = 0
	for child in get_children():
		child.set_sprite(value if idx < value else 0)
		idx += 1
