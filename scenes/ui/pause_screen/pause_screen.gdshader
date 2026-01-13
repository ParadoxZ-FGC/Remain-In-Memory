shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float lod = 0.0; // Blur intensity
uniform vec4 tint_color = vec4(0.0, 0.0, 0.0, 0.5); // Default grey tint

void fragment() {
    vec4 blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod); // Apply blur
    vec4 tinted = mix(blurred, tint_color, tint_color.a); // Blend blur with tint
    COLOR = tinted;
}