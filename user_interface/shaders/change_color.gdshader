shader_type canvas_item;
render_mode unshaded;

uniform vec4 old_color: hint_color = vec4(1.0);
uniform vec4 new_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if(COLOR == old_color) {
		COLOR = new_color;
	}
}
