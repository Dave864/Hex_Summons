/*
TODO: Come back to this shader when more help is obtained. There are still issues
with getting the dither effect to match the screen resolution and currently has
to be manually set. There is also an issue where this shader does not work well
with StyleBoxTextures as the pattern gets compressed within the texture margins.
*/
shader_type canvas_item;
render_mode unshaded;

uniform vec2 u_pix_size = vec2(1.0, 1.0);
uniform vec4 override_color : source_color = vec4(1.0);
uniform vec4 color_1 : source_color = vec4(1.0);
uniform vec4 color_2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
// position of the colors
uniform float position : hint_range(-0.5, 0.5) = 0.0;
// size of the gradient effect
uniform float size : hint_range(0.5, 2) = 0.5;
// rotation angle of gradient
uniform float angle : hint_range(0.0, 360.0) = 0.0;

const vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
const vec4 white = vec4(1.0);
// Bayer Matrix
const float bm2x2[4] = float[4] (0.0, 2.0, 3.0, 1.0);

/*
Gets the interpolation value for the UV.
Reference: https://godotshaders.com/shader/linear-gradient/
*/
float get_pos(vec2 uv) {
	float p = position + 0.5;
	vec2 p_uv = uv - p;
	float rot = p_uv.x * cos(radians(angle)) - p_uv.y * sin(radians(angle)); 
	return smoothstep((1.0 - size) + position, size + 0.0001 + position, rot + p);
}

/*
Gets the gradient color.
Reference: https://godotshaders.com/shader/dither-gradient-shader/
*/
vec4 dither_gradient(vec2 uv, sampler2D t) {
	// Set the pixel size by dividing the texture size by a defined scale
	vec2 t_size = vec2(textureSize(t, 0)) / u_pix_size;
	vec2 t_uv = floor(uv * t_size) / t_size;
	vec4 g_col = mix(black, white, get_pos(t_uv));

	/*
	calculate pixel luminosity
	(https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color)
	*/
	float lum = (g_col.r * 0.299) + (g_col.g * 0.587) + (g_col.b * 0.114);
	lum = clamp(lum, 0.0, 1.0);
	
	/*
	map the dither texture.
	https://blog.maximeheckel.com/posts/the-art-of-dithering-and-retro-shading-web/
	*/
	int x = int(uv.x * t_size.x) % 2;
	int y = int(uv.y * t_size.y) % 2;
	float threshold = bm2x2[y * 2 + x] / 4.0;
	
	/*
	adjust the dither slightly so min and max aren't quite at 0.0 and 1.0
	otherwise we wouldn't get fullly dark and fully light dither patterns
	at lum 0.0 and 1.0
	*/
	threshold = threshold * 0.99 + 0.005;
	
	/*
	The lower lum is, the fewer pixels will be below the dither threshold,
	 and thus will use color_1, and vice-versa.
	*/
	return lum < threshold ? color_1 : color_2;
}

void fragment() {
//	vec4 p_color = texture(TEXTURE, UV);
//	if (override_color == p_color) {
		COLOR = dither_gradient(UV, TEXTURE);
//	} else {
//		COLOR = p_color;
//	}
}