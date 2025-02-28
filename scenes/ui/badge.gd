extends Control

@export var sprites :SpriteFrames
@export var rank_names :Array[String]
@export var dark_sprites :SpriteFrames

func set_sprite(index):
	$VBoxContainer/Sprite.texture = sprites.get_frame_texture("default",index)
	$VBoxContainer/RanktText.text = rank_names[index]
	
	var i = 4
	for child in $Banner/Badges.get_children():
		if i == index:
			i -= 1
		if i < 0:
			break
		child.texture = dark_sprites.get_frame_texture("default",i)
		i -= 1
	
	$AnimationPlayer.play("pop_up")
