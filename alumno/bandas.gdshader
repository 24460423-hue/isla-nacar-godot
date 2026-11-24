shader_type spatial;
uniform vec4 color : source_color = vec4(0.21,0.72,0.73,1.0);
uniform float bandas = 3.0;
void fragment(){ ALBEDO=color.rgb; ROUGHNESS=0.75; }
void light(){
	float n=max(dot(NORMAL,LIGHT),0.0);
	float nivel=floor(n*bandas)/max(bandas-1.0,1.0);
	DIFFUSE_LIGHT += ALBEDO*LIGHT_COLOR*ATTENUATION*(0.18+0.82*clamp(nivel,0.0,1.0));
}
