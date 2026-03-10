/*
* Draws the specified sprite. Used as the second pass of a shader for adding
* x-ray visiblity to sprites. Should have a higher render priority than the
* first pass. 
* Reference: https://www.youtube.com/shorts/jaVnz-PvG3o
*/
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_disable;

void fragment() {
	vec4 tex_color = texture(albedo_texture, UV);
	ALBEDO = tex_color.rgb;
	ALPHA = tex_color.a;
}
