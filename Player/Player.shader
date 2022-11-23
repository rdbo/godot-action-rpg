shader_type canvas_item;

uniform bool active = false;

/* Runs on every single pixel individually */
void fragment() {
	vec4 orig_color = texture(TEXTURE, UV);
	vec4 new_color = orig_color;
	/* Disable green and blue colors, only show red */
	if (active)
		new_color.g = new_color.b = 0.0;
	COLOR = new_color;
}