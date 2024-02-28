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

func _on_button_down():
	$"../../../..".play_click_sound()

func _on_focus_entered():
	$"../../../..".play_hover_sound()

func _on_mouse_entered():
	$"../../../..".play_hover_sound()
