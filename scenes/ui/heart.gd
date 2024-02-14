extends TextureRect

@export var sprites :SpriteFrames

func  set_sprite(index):
	texture = sprites.get_frame_texture("default",index)
