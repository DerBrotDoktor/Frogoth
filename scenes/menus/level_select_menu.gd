extends Control

@export var level_amount :int
@export var level_buttons :Array[TextureButton]

var save_path = "user://leveldata.save"
var level_locked = []

func _ready():
	load_data()

func load_level(number:int):
	get_parent().load_level_by_index(number)

func _on_visibility_changed():
	if $VerticalContainer/LevelMargin/LevelGrid/LevelButton0.is_inside_tree() and visible:
		set_button_locks()
		get_tree().paused = true
		$VerticalContainer/LevelMargin/LevelGrid/LevelButton0.grab_focus()

func _on_back_button_pressed():
	get_parent().switch_to_child("MainMenu")

func unlock_level(number):
	if number < level_locked.size():
		level_locked[number] = false
		save()

func set_button_locks():
	for i in range(level_amount):
		if level_locked[i]:
			level_buttons[i].lock_button()
		else:
			level_buttons[i].unlock_button()

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		level_locked = file.get_var()
	else:
		new_data()
	print("LOAD: ", level_locked)

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(level_locked)

func new_data():
	level_locked.clear()
	level_locked.append(false)
	level_locked.append(false)
	for i in range (2,level_amount):
		level_locked.append(true)
	print("save: ", level_locked)

func play_click_sound():
	$ClickSoundPlayer.play()

func play_hover_sound():
	if visible:
		$HoverSoundPlayer.play()
