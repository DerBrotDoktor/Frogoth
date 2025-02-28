shader_type canvas_item;

uniform vec2 repeat;

void fragment() {
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 uv = FRAGCOORD.xy / tex_size;
    vec2 repeated_uv = vec2(fract(uv.x), UV.y);
    COLOR = texture(TEXTURE, repeated_uv);
}