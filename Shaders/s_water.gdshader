shader_type spatial;
render_mode cull_disabled;
//render_mode fog_disabled;
//render_mode unshaded;
//render_mode depth_prepass_alpha;
render_mode ambient_light_disabled;
//render_mode vertex_lighting;
render_mode depth_draw_always;

uniform vec4 primary_colour : source_color;
uniform vec4 secondary_colour : source_color;

uniform float roughness = 0.2;
uniform sampler2D normalmap_a : hint_normal;
uniform sampler2D normalmap_b : hint_normal;
uniform float normalmap_a_strength : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float normalmap_b_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform vec2 movement_direction = vec2(0.1, 0.1);
uniform float movement_strength = 0.1;
uniform float uv_scale = 1.0;

uniform sampler2D wave_offset_texture;
uniform float wave_offset_strength : hint_range(0.0, 1.0, 0.01) = 0.5;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture: hint_screen_texture, repeat_disable, filter_nearest;

uniform float depth_distance : hint_range(0.0, 20.0, 0.1) = 4.0;
uniform float beers_law : hint_range(0.0, 20.0, 0.1) = 12.0;
uniform float water_transparency : hint_range(0.0, 1.0, 0.01) = 0.05;


float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

vec2 fix_edge(vec2 uv_in) {
	float image_res = 1024.0;
	vec2 mirrored_uv = fract(uv_in);  // Scale the UV for tiling
	mirrored_uv.x = (mod(uv_in.x * 2.0, 2.0) > 1.0) ? 1.0 - mirrored_uv.x : mirrored_uv.x;
	mirrored_uv.y = (mod(uv_in.y * 2.0, 2.0) > 1.0) ? 1.0 - mirrored_uv.y : mirrored_uv.y;
	float one_more_image_res = 1.0 / image_res;
	if (mirrored_uv.x < one_more_image_res) {
		mirrored_uv.x = one_more_image_res;
	}
	if (mirrored_uv.y < one_more_image_res) {
		mirrored_uv.y = one_more_image_res;
	}
	return mirrored_uv;
}

void fragment() {
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 screen = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_texture_y = world.y / world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	
	float depth_blend = clamp((vertex_y - depth_texture_y) / depth_distance, 0.0, 1.0);
	depth_blend = exp(-depth_blend * beers_law);
	
	float basic_fresnel = fresnel(3.0, NORMAL, VIEW);
	vec2 uv = UV * uv_scale;
	vec2 wave_uv = UV;
	float wave_time = TIME * movement_strength;
	wave_uv.x += sin(wave_time * 5.0 + PI / 4.0 * cos(wave_time)) / 10.0;
	wave_uv.y += cos(wave_time * 5.0 + PI / 4.0 * sin(wave_time)) / 10.0;
	float wave_offset = textureLod(wave_offset_texture, wave_uv, 0.0).r;
	wave_offset *= wave_offset_strength;
	uv += wave_offset;
	vec2 uv_movement = movement_direction * TIME * movement_strength;
	vec3 normalmap = texture(normalmap_a, fix_edge(uv + uv_movement)).rgb * normalmap_a_strength;
	normalmap += texture(normalmap_b, fix_edge(uv - uv_movement)).rgb * normalmap_b_strength;
	
	float highlights = 0.0;
	if (normalmap.r / 2.0 < 0.6) {
		highlights = 0.0;
	}
	vec3 depth_colour = mix(secondary_colour, primary_colour, depth_blend).rgb;
	vec3 final_colour = mix(depth_colour, screen, water_transparency);
	ALBEDO = mix(final_colour, screen, depth_blend * (1.0 - basic_fresnel)) + highlights;
	ROUGHNESS = roughness * (1.0 - basic_fresnel);
	SPECULAR = 1.0;
	NORMAL_MAP = normalmap;
}



