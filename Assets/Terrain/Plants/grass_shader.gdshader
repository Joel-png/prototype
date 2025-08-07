shader_type spatial;
render_mode cull_disabled, depth_draw_always, alpha_to_coverage_and_one;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D alpha_texture : source_color;
uniform sampler2D wind_noise_texture : source_color;
uniform float alpha_cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float alpha_extra : hint_range(0.0, 20.0) = 0.5;
uniform float wind_strength = 0.1;
uniform float wind_nosie_strength = 0.1;
uniform float wind_speed = 1.0;

void vertex() {
	float distance_from_origin = length(VERTEX);
	float sway = TIME * wind_speed + VERTEX.y * 4.0;
	float wind_noise = texture(wind_noise_texture, vec2(VERTEX.x + TIME * wind_speed, VERTEX.y + TIME * wind_speed)).r;
	float sway_x = sin(sway + wind_noise * wind_nosie_strength) * wind_strength * pow(distance_from_origin, 2.0);
	float sway_y = cos(sway + wind_noise * wind_nosie_strength) * wind_strength * pow(distance_from_origin, 2.0);
	
    VERTEX.x += sway_x;
    VERTEX.z += sway_y;
}

void fragment() {
	vec4 tex_color = texture(albedo_texture, UV);
	vec4 tex_alpha = texture(alpha_texture, UV);
	
	if (FRONT_FACING == false) {
        NORMAL = -NORMAL;
    }
	
    if (tex_alpha.r > alpha_cutoff) {
        ALPHA = round(tex_alpha.r * alpha_extra);
    } else {
		ALPHA = 0.0;
	}
	
	SPECULAR = 0.025;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
    ALBEDO = tex_color.rgb;
	

    // Sharp alpha cutout
    
}
