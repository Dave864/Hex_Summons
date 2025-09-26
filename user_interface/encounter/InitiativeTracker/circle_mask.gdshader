// Reference: https://godotshaders.com/snippet/circle/
shader_type canvas_item;
render_mode unshaded;

uniform float radius : hint_range(0.0, 1.0) = 1.0;
uniform float center_x : hint_range(0.0, 1.0) = 0.5;
uniform float center_y : hint_range(0.0, 1.0) = 0.5;

float circle(vec2 pos, float r, float feather) {
	return smoothstep(r, r + feather, dot(pos, pos) * 4.0);
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.a = 1.0 - circle(UV - vec2(center_x, center_y), radius, 0.0);
}
