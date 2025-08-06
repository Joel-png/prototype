shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled, shadows_disabled, depth_draw_always;


uniform sampler2D noise_offset_texture : source_color, filter_linear;
uniform float ior : hint_range(0.0, 200.0) = 1.45; // Index of refraction
uniform float fresnel_power : hint_range(1.0, 128.0) = 5.0;
uniform float time_scale : hint_range(-200.0, 200.0) = 0.0;
uniform float rotation_scale : hint_range(-200.0, 200.0) = 0.0;
uniform sampler2D gradient_texture : source_color, filter_linear;
uniform sampler2D albedo_gradient_texture : source_color, filter_linear;
uniform sampler2D refraction_gradient_texture : source_color, filter_linear;
uniform sampler2D other_refraction_gradient_texture : source_color, filter_linear;
uniform sampler2D ior_gradient_texture : source_color, filter_linear;
uniform sampler2D other_ior_gradient_texture : source_color, filter_linear;
uniform sampler2D mix_gradient_texture : source_color, filter_linear;
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform sampler2D noise_texture : source_color, filter_linear;
uniform sampler2D noise_color_ramp_texture : source_color, filter_linear;
uniform sampler2D noise_gradient_texture : source_color, filter_linear;
uniform sampler2D curve_value : source_color, filter_linear;

vec2 rotate_uv(vec2 uv, float angle) {
	// Move UV origin to center (from [0,1] to [-0.5, 0.5])
	uv -= vec2(0.5);

	// Apply 2D rotation
	float cos_a = cos(angle);
	float sin_a = sin(angle);
	 uv = vec2(
		uv.x * cos_a - uv.y * sin_a,
		uv.x * sin_a + uv.y * cos_a
	);
	uv += vec2(0.5);
	return uv;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 vecToCenter = vec2(0.5, 0.5) - UV;
	float distToCenter = length(vecToCenter);
	float curveVal = texture(curve_value, vec2(distToCenter)).r;
	vec2 diff = normalize(vecToCenter) * 0.6 * curveVal;
	vec3 normal = normalize(NORMAL);
	vec3 view_dir = normalize(VIEW);
	float facing = 1.0 - dot(normal, view_dir) * (0.95 - 0.05 * sin(TIME * time_scale));
	float rotation = TIME * rotation_scale;
	vec2 screen_uv = SCREEN_UV;
	screen_uv = rotate_uv(screen_uv, rotation);
	float noise_offset = texture(noise_offset_texture, screen_uv).r;
	facing += noise_offset * 0.01;
	float fresnel_factor = pow((1.0 - dot(normalize(NORMAL), normalize(VIEW))), 32.0);
	float emission_mask = 1.0;
	if (fresnel_factor > 0.0) {
	    emission_mask = 0.0;
	}
	
	vec3 gradient_albedo = texture(gradient_texture, vec2(facing, 0.5)).rgb;
	float albedo_gradient = texture(albedo_gradient_texture, vec2(facing, 0.5)).r;
	float refraction_gradient = texture(refraction_gradient_texture, vec2(facing, 0.5)).r;
	float other_refraction_gradient = texture(other_refraction_gradient_texture, vec2(facing, 0.5)).r;
	float ior_gradient = texture(ior_gradient_texture, vec2(facing, 0.5)).r;
	float other_ior_gradient = texture(other_ior_gradient_texture, vec2(facing, 0.5)).r;
	float mix_gradient = texture(mix_gradient_texture, vec2(facing, 0.5)).r;
	
	vec2 refraction_offset = normal.xy * refraction_gradient * ior_gradient * ior;
	vec2 other_refraction_offset = normal.xy * other_refraction_gradient * other_ior_gradient * ior;
	vec2 mixed_refraction_offset = mix(refraction_offset, other_refraction_offset, mix_gradient);
	vec2 refracted_uv = screen_uv + mixed_refraction_offset;
	vec2 mirrored_uv = abs(fract(refracted_uv * 0.5) * 2.0 - 1.0);
	// Sample the screen texture using refracted UVs
	float refracted_noise = texture(noise_texture, refracted_uv).r;
	vec3 noise_color_ramp = texture(noise_color_ramp_texture, vec2(refracted_noise, 0.5)).rgb;
	float noise_gradient = texture(noise_gradient_texture, vec2(facing + noise_offset * 0.1, 0.5)).r;
	
	vec3 refracted_screen = texture(screen_texture, mirrored_uv).rgb;
	vec3 refracted_color = refracted_screen;//mix(refracted_screen, refracted_viewport, 0.5);
	
	ALBEDO = mix(gradient_albedo, refracted_color, albedo_gradient) * (1.0 - emission_mask);
	vec3 noise_color = noise_color_ramp * noise_gradient;
	ALBEDO = mix(ALBEDO, noise_color, min(1.0, noise_color.r * 100.0));
	EMISSION = ALBEDO * 10000.0;
}

