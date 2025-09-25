// https://godotshaders.com/shader/dither-gradient-shader/
shader_type canvas_item;
render_mode unshaded;

uniform vec4 override_color : hint_color = vec4(1.0);
uniform vec4 color_1 : hint_color = vec4(1.0);
uniform vec4 color_2 : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
// position of the colors
uniform float position : hint_range(-0.5, 0.5) = 0.0;
// size of the gradient effect
uniform float size : hint_range(0.5, 2) = 0.5;
// rotation angle of gradient
uniform float angle : hint_range(0.0, 360.0) = 0.0;

// Reference: https://maximmcnair.com/p/webgl-dithering
const float bayer_2x2[4] =  {
	0.0, 3.0,  
	2.0, 1.0
};

/*
Gets the interpolation value for the UV.
Reference: https://godotshaders.com/shader/linear-gradient/
*/
float get_pos(vec2 uv)
{
	float p = position + 0.5;
	vec2 p_uv = uv - p;
	float rot = p_uv.x * cos(radians(angle)) - p_uv.y * sin(radians(angle)); 
	return smoothstep((1.0 - size) + position, size + 0.0001 + position, rot + p);
}

/*
Gets the threshold data for a UV given the 4x4 bayer dither matrix.
Reference: https://maximmcnair.com/p/webgl-dithering
*/
vec4 dither4x4(vec2 uv, float g) {
	float dither_amount = 2.0;
	int x = int(mod(uv.x, dither_amount));
	int y = int(mod(uv.y, dither_amount));
	int index = x + y * int(dither_amount);
	float limit = (float(bayer_2x2[index]) + 1.0) / (1.0 + 4.0);
	return g < limit ? color_1 : color_2;
}

void fragment()
{
	vec4 p_color = texture(TEXTURE, UV);
	// Only apply gradient to override color.
	if(override_color == p_color) {
		COLOR = dither4x4(UV, get_pos(UV));
	} else {
		COLOR = p_color;
	}
}