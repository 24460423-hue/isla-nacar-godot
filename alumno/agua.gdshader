shader_type spatial;
render_mode cull_disabled;
uniform vec4 color_profundo : source_color = vec4(0.035,0.30,0.39,1.0);
uniform vec4 color_claro : source_color = vec4(0.13,0.65,0.67,1.0);
uniform float amplitud = 0.09;
uniform float velocidad = 1.2;
varying vec3 mundo;
void vertex(){
	VERTEX.y += amplitud*(sin(VERTEX.x*0.65+TIME*velocidad)+cos(VERTEX.z*0.7-TIME*0.8));
	NORMAL = normalize(vec3(-amplitud*0.65*cos(VERTEX.x*0.65+TIME*velocidad),1.0,amplitud*0.7*sin(VERTEX.z*0.7-TIME*0.8)));
	mundo = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment(){
	float ola=sin(mundo.x*2.0+sin(mundo.z*1.7)+TIME*1.1);
	float bandas=smoothstep(0.88,1.0,ola)*0.34;
	ALBEDO=mix(color_profundo.rgb,color_claro.rgb,0.38+bandas);
	ROUGHNESS=0.24;
	METALLIC=0.12;
}
