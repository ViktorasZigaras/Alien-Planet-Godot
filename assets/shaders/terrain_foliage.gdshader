shader_type spatial;
uniform vec4 base_color : source_color = vec4(0.3,0.5,0.3,1.0);
uniform float clock = 0.0;
uniform float phase = 0.0;
uniform float half_height = 0.2;
uniform float amplitude = 0.025;
void vertex() {
    float tip = clamp((VERTEX.y + half_height) / max(half_height * 2.0, 0.01), 0.0, 1.0);
    VERTEX.x += sin(clock * 1.2 + phase) * amplitude * tip;
    VERTEX.z += cos(clock * 0.8 + phase) * amplitude * tip * 0.45;
}
void fragment() {
    ALBEDO = base_color.rgb;
    ROUGHNESS = 0.88;
}
