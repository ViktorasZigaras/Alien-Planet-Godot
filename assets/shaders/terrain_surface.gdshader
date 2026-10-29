shader_type spatial;
render_mode cull_disabled;
uniform vec4 base_color : source_color = vec4(0.4,0.5,0.3,1.0);
uniform sampler2D ground_noise : filter_linear_mipmap, repeat_enable;
uniform float detail_amount = 1.0;
uniform float clock = 0.0;
uniform float variation = 0.0;
uniform bool water = false;
varying vec2 ground_position;
void vertex() {
    ground_position = VERTEX.xz;
    NORMAL = vec3(0.0,1.0,0.0);
}
void fragment() {
    vec2 p = ground_position;
    vec2 offset = vec2(variation * 0.137, variation * 0.219);
    float broad = texture(ground_noise, p * 0.7 + offset).r;
    float grain = texture(ground_noise, p * 8.0 + offset).r;
    float speck = smoothstep(0.62, 0.77, grain);
    float tint = 0.92 + broad * 0.16 + (grain - 0.5) * 0.10 + speck * 0.06;
    vec3 color = base_color.rgb * mix(1.0, tint, detail_amount);
    if (water) {
        float ripple = sin(p.x * 16.0 + p.y * 9.0 - clock * 0.9)
                     + sin(p.y * 23.0 - p.x * 6.0 + clock * 0.55);
        float crest = smoothstep(1.25, 1.85, ripple);
        color = mix(color * (0.90 + broad * 0.22), vec3(0.63,0.87,0.86), crest * 0.36 * detail_amount);
        color += sin(p.x * 4.0 + p.y * 3.0 - clock * 0.4) * 0.025 * detail_amount;
    }
    ALBEDO = color;
    ROUGHNESS = water ? 0.42 : 0.93;
}
