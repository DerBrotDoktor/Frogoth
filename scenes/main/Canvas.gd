extends CanvasLayer

func load_level_by_index(index :int):
	get_parent().load_level(index)

func switch_to_child(name):
	for child in get_children():
		child.visible = child.name == name
