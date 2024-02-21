extends TextureButton

signal load_level(number)
@export var level_number :int

func _ready():
	$Text.text = str(level_number)

func _on_pressed():
	load_level.emit(level_number)

func lock_button():
	disabled = true
	$LevelLock.visible = true

func unlock_button():
	disabled = false
	$LevelLock.visible = false
