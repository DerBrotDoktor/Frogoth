extends CanvasLayer

var last_child

func _process(_delta):
	if Input.is_action_just_pressed("pause_menu"):
		toggle_pause_menu()
	if Input.is_action_pressed("controller_help") and not get_tree().paused:
		if not $ControllerSettingsUI.visible:
			get_tree().paused = true
			switch_to_child("ControllerSettingsUI")
	elif Input.is_action_just_released("controller_help"):
		if $ControllerSettingsUI.visible:
			get_tree().paused = false
			switch_to_child("UserInterface")

func toggle_pause_menu():
	if $PauseMenu.visible and $EscapeDelay.is_stopped():
		switch_to_child("UserInterface")
		get_tree().paused = false
	elif not get_tree().paused:
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

func switch_to_child(child_name):
	for child in get_children():
		if not child == $EscapeDelay:
			last_child = child if child.visible else last_child
			child.visible = child.name == child_name

func switch_to_last_child():
	$EscapeDelay.start()
	switch_to_child(last_child.name)
