shader_type spatial;
render_mode cull_disabled;

uniform sampler2D palette : source_color, filter_nearest, repeat_disable;
uniform sampler2D paint : repeat_enable, filter_linear_mipmap;
varying vec2 ground_position;
varying float rise;
varying float slope;

void vertex() {
	ground_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	rise = VERTEX.y;
	slope = 1.0 - NORMAL.y;
}

void fragment() {
	const float hex_width = 1.7320508;
	float r = ground_position.y / 1.5;
	vec2 axial = vec2(ground_position.x / hex_width - r * 0.5, r);
	ivec2 cell = ivec2(floor(axial));
	ivec2 size = textureSize(palette, 0);
	vec3 pigments = vec3(0.0);
	float total = 0.0;
	for (int y = 0; y < 2; y++) {
		for (int x = 0; x < 2; x++) {
			ivec2 at = cell + ivec2(x, y);
			if (any(lessThan(at, ivec2(0))) || any(greaterThanEqual(at, size))) continue;
			vec4 soil = texelFetch(palette, at, 0);
			vec2 center = vec2(hex_width * (float(at.x) + float(at.y) * 0.5), 1.5 * float(at.y));
			float weight = (1.0 - smoothstep(0.48, 1.23, distance(ground_position, center))) * soil.a;
			pigments += soil.rgb * weight;
			total += weight;
		}
	}
	vec3 ground = pigments / max(total, 0.001);
	float grain = texture(paint, ground_position * 0.72).r;
	float patches = texture(paint, ground_position * 0.16 + vec2(0.19, 0.47)).r;
	float strata = sin(rise * 23.0 + grain * 2.6 + ground_position.x * 0.8);
	vec3 stone = mix(ground, vec3(0.46, 0.43, 0.36), 0.62);
	ground = mix(ground, stone, smoothstep(0.12, 0.48, slope) * (0.40 + 0.14 * strata));
	ALBEDO = ground * (0.78 + patches * 0.34 + grain * 0.19);
	ROUGHNESS = 0.95;
}
