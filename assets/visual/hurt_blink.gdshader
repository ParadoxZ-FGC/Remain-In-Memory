shader_type canvas_item;


uniform vec4 blink_color: source_color;
uniform float blink_intensity = 0;


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color = mix(color, blink_color, blink_intensity * color.a);
	COLOR = color;
}
