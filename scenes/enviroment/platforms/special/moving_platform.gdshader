shader_type canvas_item;

uniform float speed;
uniform float direction;
uniform bool paused;

void fragment() {
	if (!paused){
	COLOR = texture(TEXTURE, vec2(UV.x +TIME*speed*direction, UV.y));
	}
}