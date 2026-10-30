shader_type spatial;
render_mode cull_disabled;
uniform vec4 soil : source_color = vec4(0.6,0.3,0.2,1.0);
uniform vec4 cover : source_color = vec4(0.4,0.5,0.3,1.0);
uniform sampler2D ground_noise : repeat_enable, filter_linear;
uniform sampler2D painted_detail : repeat_enable, filter_linear_mipmap;
varying vec2 world_uv;
varying float slope;
varying float elevation;
void vertex() {
 world_uv = (MODEL_MATRIX * vec4(VERTEX,1.0)).xz;
 slope = 1.0-NORMAL.y;
 elevation = VERTEX.y;
}
void fragment() {
 float patch = texture(ground_noise,world_uv*0.07).r;
 float paint = texture(painted_detail,world_uv*0.42).r;
 float mask = smoothstep(0.38,0.72,patch)*0.30;
 vec3 land = mix(soil.rgb,cover.rgb,mask);
 // Pale exposed shoulders distinguish elevation from resource-bearing outcrops.
 vec3 stone = mix(soil.rgb,vec3(0.62,0.58,0.49),0.72);
 float strata = smoothstep(0.40,0.63,sin(elevation*19.0+world_uv.x*6.0+world_uv.y*4.0+paint*3.0)*0.5+0.5);
 land = mix(land,cover.rgb,smoothstep(0.20,0.65,elevation)*0.35);
 float exposure = smoothstep(-0.25,0.35,sin(world_uv.x*2.0+world_uv.y*1.4)+paint*0.4);
 land = mix(land,stone,smoothstep(0.13,0.36,slope)*exposure*(0.45+0.30*strata));
 ALBEDO = land*(0.86+paint*0.30);
 ROUGHNESS = 0.95;
}
