shader_type canvas_item;

void fragment() {
    // Wackelnde Intensität
    float intensity = 1.5; // Ändern Sie diesen Wert nach Bedarf

    // Berechnen Sie die Verschiebung mithilfe der Sinusfunktion basierend auf der Zeit
    float offset_x = sin(TIME * 10.0) * intensity; // Die Multiplikation mit einer größeren Zahl erhöht die Geschwindigkeit des Wackelns
    float offset_y = cos(TIME * 10.0) * intensity;

    // Wenden Sie die Verschiebung auf die UV-Koordinaten an
    vec2 uv = FRAGCOORD.xy / vec2(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y);
    uv = UV + vec2(offset_x, offset_y);

    // Texturkoordinaten begrenzen, um sicherzustellen, dass das Wackeln das Sprite nicht verlässt
    //uv = clamp(uv, vec2(0.0), vec2(1.0));

    // Färben Sie das Sprite basierend auf den verschobenen UV-Koordinaten
    vec4 col = texture(TEXTURE, uv);
	col.a = 0.8;
    // Ausgabe des Farbwerts
    COLOR = col;
}