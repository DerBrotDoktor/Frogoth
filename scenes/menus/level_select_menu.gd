extends Control



func load_level(number:int):
	get_parent().load_level_by_index(number-1)


func _on_visibility_changed():
	if $VerticalContainer/LevelMargin/LevelGrid/Level1Button.is_inside_tree() and visible:
		$VerticalContainer/LevelMargin/LevelGrid/Level1Button.grab_focus()
