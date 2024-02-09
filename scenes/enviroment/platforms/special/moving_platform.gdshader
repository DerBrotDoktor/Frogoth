shader_type canvas_item;

uniform float speed;
uniform float direction;

void fragment() {
	COLOR = texture(TEXTURE, vec2(UV.x +TIME*speed*direction, UV.y));
}