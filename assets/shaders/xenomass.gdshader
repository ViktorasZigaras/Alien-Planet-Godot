shader_type spatial;
render_mode blend_mix,depth_draw_never,cull_disabled;
varying vec2 world_uv;
void vertex(){world_uv=(MODEL_MATRIX*vec4(VERTEX,1.0)).xz;}
void fragment(){
 float flow=sin(world_uv.x*13.0+sin(world_uv.y*7.0)*2.0)*sin(world_uv.y*11.0+cos(world_uv.x*4.0));
 float vein=smoothstep(0.62,0.88,flow);
 ALBEDO=mix(vec3(0.035,0.115,0.075),vec3(0.14,0.30,0.17),vein);
 ROUGHNESS=0.80;
 ALPHA=0.74+vein*0.18;
}
