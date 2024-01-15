extends Control


func load_level(number:int):
	get_parent().load_level(number-1)
