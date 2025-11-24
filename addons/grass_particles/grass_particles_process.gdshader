shader_type particles;

uniform float rows = 16;
uniform float spacing = 1.0;
uniform float grass_range = 500.0;

void start() {
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.y = float(INDEX);
	pos.x = mod(pos.y, rows);
	pos.y = (pos.y - pos.x) / rows;
	
	pos.x -= rows * 0.5;
	pos.y -= rows * 0.5;
	
	pos *= spacing;
	
	vec2 emission_pos = vec2(EMISSION_TRANSFORM[3][0], EMISSION_TRANSFORM[3][1]);
	pos.x += emission_pos.x - mod(emission_pos.x, spacing);
	pos.y += emission_pos.y - mod(emission_pos.y, spacing);
	
	vec2 offset = vec2(pos.x, pos.y) - emission_pos;
	float half_range = grass_range * 0.5;
	offset.x = clamp(offset.x, -half_range, half_range);
	offset.y = clamp(offset.y, -half_range, half_range);
	pos.xy = emission_pos + offset;
	
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	
	CUSTOM.xy = pos.xy;
}

