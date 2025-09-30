shader_type canvas_item;
render_mode unshaded;

uniform vec4 region = vec4(0.0);
uniform float radius : hint_range(0.0, 1.0) = 1.0;
uniform float center_x : hint_range(0.0, 1.0) = 0.5;
uniform float center_y : hint_range(0.0, 1.0) = 0.5;

// Checks if the position is within the radius r.
// Reference: https://godotshaders.com/snippet/circle/
float circle(vec2 pos, float r, float feather) {
	return smoothstep(r, r + feather, dot(pos, pos) * 4.0);
}

// Convert UV of atlas region to UV of atlas map.
// Reference: https://github.com/godotengine/godot/issues/57401#issuecomment-1411865325
vec2 region_to_texture_uv(vec2 uv, vec2 tps) {
	return (region.xy*tps)+uv*(region.zw*tps);
}

// Convert UV of atlas map to UV of atlas region.
// Reference: https://github.com/godotengine/godot/issues/57401#issuecomment-1411865325
vec2 texture_to_region_uv(vec2 uv, vec2 tps) {
	return (uv-(region.xy*tps))/(region.zw*tps);
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec2 region_uv = texture_to_region_uv(UV, TEXTURE_PIXEL_SIZE);
	COLOR.a = 1.0 - circle(region_uv - vec2(center_x, center_y), radius, 0.0);
}
