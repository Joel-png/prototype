shader_type spatial;

uniform vec4 texture_up : source_color;
uniform vec4 texture_side : source_color;
uniform sampler2D normal_texture : source_color;
uniform sampler2D merge_texture : source_color;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float normal_scale : hint_range(0.0, 100.0) = 0.1;
uniform float blend_sharpness : hint_range(0.001, 4.0) = 0.01;
uniform float merge_scale : hint_range(0.0, 100.0) = 0.1;
uniform float normal_range : hint_range(-1.0, 2.0) = 0.1;
uniform float blend_range : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float merge_amount : hint_range(0.0, 10.0, 0.1) = 0.5;

void fragment() {
	vec3 normal_world = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	
	float up_factor = clamp(dot(normal_world, vec3(0.0, 1.0, 0.0)) + normal_range, 0.0, 1.0);
	float blend = pow(up_factor, blend_sharpness);
	
	float merge_color = texture(merge_texture, UV * merge_scale).r;
	merge_color = clamp((up_factor + merge_color) * merge_amount, 0.0, 1.0);
	vec4 tex_up = texture_up;
	vec4 tex_side = texture_side;
	
	float blend_amount = round(blend * merge_color);
	vec4 final_color = mix(tex_side, tex_up, blend_amount);
	
	ALBEDO = final_color.rgb;
	vec4 normal_tex = texture(normal_texture, UV * normal_scale);
	NORMAL_MAP = normal_tex.rgb * 0.5;
	NORMAL_MAP_DEPTH = 0.2 + 0.5 * (1.0 - blend_amount);
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
