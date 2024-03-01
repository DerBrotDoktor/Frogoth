extends TextureButton

signal load_level(number)
@export var level_number :int
@export var difficulty = 0
@export var difficulty_sprites :SpriteFrames

func _ready():
	$Text.text = str(level_number)
	if difficulty > 0:
		$Difficulty.texture = difficulty_sprites.get_frame_texture("default", difficulty-1)

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
