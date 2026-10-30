shader_type spatial;
render_mode cull_disabled;
uniform vec4 base_color : source_color = vec4(0.4,0.6,0.4,1.0);
uniform bool animated = true;
uniform bool water = false;
uniform float frozen_clock = 0.0;
varying vec3 world_pos;
void vertex() {
 float t = animated ? TIME : frozen_clock;
 world_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
 if (!water) VERTEX.x += sin(t*1.1+world_pos.x*0.8+world_pos.z)*0.035*max(VERTEX.y,0.0);
}
void fragment() {
 float t = animated ? TIME : frozen_clock;
 float pattern = sin(world_pos.x*8.0+world_pos.z*6.0+t*1.3);
 ALBEDO = base_color.rgb * (water ? 1.0+0.10*pattern : 1.0);
 ROUGHNESS = water ? 0.5 : 0.9;
}
