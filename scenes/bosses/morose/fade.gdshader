shader_type canvas_item;


uniform float alpha: hint_range(0.0, 255.0, 0.1);


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a > 0.0) {
		color.a = alpha;
	}
	COLOR = color;
}
