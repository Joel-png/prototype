shader_type spatial;
render_mode cull_disabled, depth_draw_always, alpha_to_coverage_and_one;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D alpha_texture : source_color;
uniform float alpha_cutoff : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 tex_color = texture(albedo_texture, UV);
	vec4 tex_alpha = texture(alpha_texture, UV);
    if (tex_alpha.r > alpha_cutoff) {
        ALPHA = round(tex_alpha.r);
		BACKLIGHT = tex_color.rgb;
    } else {
		ALPHA = 0.0;
	}
	
	SPECULAR = 0.0;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
    ALBEDO = tex_color.rgb;
	

    // Sharp alpha cutout
    
}
