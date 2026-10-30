shader_type spatial;
render_mode cull_disabled;
uniform vec4 soil : source_color = vec4(0.6,0.3,0.2,1.0);
uniform vec4 cover : source_color = vec4(0.4,0.5,0.3,1.0);
uniform sampler2D ground_noise : repeat_enable, filter_linear;
varying vec2 world_uv;
void vertex() { world_uv = (MODEL_MATRIX * vec4(VERTEX,1.0)).xz; }
void fragment() {
 float patch = texture(ground_noise,world_uv*0.07).r;
 float grain = texture(ground_noise,world_uv*0.85).r;
 float mask = smoothstep(0.47,0.70,patch)*0.60;
 ALBEDO = mix(soil.rgb,cover.rgb,mask)*(0.93+grain*0.14);
 // A shallow surface normal, not displacement: occupants and picking keep their real height.
 NORMAL = normalize(NORMAL+vec3((grain-0.5)*0.06,0.0,(patch-0.5)*0.06));
 ROUGHNESS = 0.95;
}
