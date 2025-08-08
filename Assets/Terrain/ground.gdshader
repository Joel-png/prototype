shader_type spatial;

uniform sampler2D texture_up : source_color;
uniform sampler2D texture_side : source_color;
uniform float blend_sharpness : hint_range(0.0, 4.0) = 0.1;
uniform float texture_scale : hint_range(0.0, 4.0) = 0.1;
uniform float normal_range : hint_range(-1.0, 2.0) = 0.1;

void fragment() {
	vec3 normal_world = normalize(NORMAL);
	
	float up_factor = clamp(dot(normal_world, vec3(0.0, 1.0, 0.0)) + normal_range, 0.0, 1.0);
	float blend = pow(up_factor, blend_sharpness);
	vec2 uv = UV * texture_scale;
	vec4 tex_up = texture(texture_up, uv);
	vec4 tex_side = texture(texture_side, uv);
	
	vec4 final_color = mix(tex_up, tex_side, blend);
	
	ALBEDO = final_color.rgb;
}
