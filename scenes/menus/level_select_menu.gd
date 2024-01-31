extends Control


func load_level(number:int):
	get_parent().load_level_by_index(number-1)
