shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {
	float f = fract(
		0.1 * (SCREEN_UV.x / SCREEN_PIXEL_SIZE.x + SCREEN_UV.y / SCREEN_PIXEL_SIZE.y)
		 +
		2.0 * TIME);

	if (f < 0.5) {
		discard;
	}

	COLOR = vec4(1,0,0,1);
}
