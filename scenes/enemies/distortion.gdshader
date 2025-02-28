shader_type canvas_item;

uniform vec2 center;
uniform float force;
uniform sampler2D SCREEN_TEXTURE :hint_screen_texture;
uniform float size;
uniform float thickness;

void fragment(){
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaledUV = (UV - vec2(0.5, 0.0)) /vec2(1.0, 1.0) + vec2(0.5, 0.0);
	float mask = (1.0 - smoothstep(size-0.1, size, length(scaledUV - center))) *
		smoothstep(size-thickness-0.1, size-thickness, length(scaledUV - center));
	vec2 disp = normalize(scaledUV- center) * force *mask;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV -disp);
	//COLOR.rgb = vec3(mask);
}