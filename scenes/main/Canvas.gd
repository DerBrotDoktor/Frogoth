extends CanvasLayer

func _process(delta):
	if Input.is_action_just_pressed("pause_menu"):
		toggle_pause_menu()

func toggle_pause_menu():
	if $PauseMenu.visible:
		switch_to_child("UserInterface")
		get_tree().paused = false
	else:
		switch_to_child("PauseMenu")
		get_tree().paused = true

func load_level_by_index(index):
	get_parent().load_level_by_index(index)
	$UserInterface.reset_timer()

func next_level():
	get_parent().next_level()
	$UserInterface.reset_timer()

func restart_level():
	get_parent().restart_current_level()
	$UserInterface.reset_timer()

func switch_to_child(name):
	for child in get_children():
		child.visible = child.name == name
