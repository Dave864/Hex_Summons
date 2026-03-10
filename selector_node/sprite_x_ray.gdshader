/*
* Draws a shape defined by a sprite in a single color. Also allows for a dither
* transparency to be defined. Used as the first pass of a shader for adding
* x-ray visiblity to sprites. Should have a lower render priority than the
* second pass.
* References:
* https://www.youtube.com/shorts/jaVnz-PvG3o
* https://godotshaders.com/shader/dithering-screen-door-transparency/
*/
shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform sampler2D sprite_texture: source_color, filter_nearest, repeat_disable;
uniform vec4 x_ray_color: source_color = vec4(1.0);
uniform float dither_intensity: hint_range(0.0, 1.0, 0.05) = 0.0;
uniform float dither_pixel_size: hint_range(1.0, 20.0, 1.0) = 1.0;

const mat4 THRESHOLD_MATRIX = mat4(
	vec4(1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0),
	vec4(13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0),
	vec4(4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0),
	vec4(16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0)
);

void fragment() {
	// Sample color from texture.
	vec4 texture_color = texture(sprite_texture, UV);
	
	// Get alpha from default texture.
	ALPHA = texture_color.a;
	
	if (ALPHA > 0.0) {
		ALBEDO = x_ray_color.rgb;
		vec2 pixel_size = dither_pixel_size / vec2(textureSize(sprite_texture, 0));
		vec2 uv = UV / pixel_size;
		ALPHA *= step(0.0, THRESHOLD_MATRIX[int(uv.x) % 4][int(uv.y) % 4] - dither_intensity);
	}
}