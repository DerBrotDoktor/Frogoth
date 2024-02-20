extends Control

@export var sprites :SpriteFrames
@export var rank_names :Array[String]

func set_sprite(index):
	$VBoxContainer/Sprite.texture = sprites.get_frame_texture("default",index)
	$VBoxContainer/RanktText.text = rank_names[index]
