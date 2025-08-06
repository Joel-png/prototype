shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D gradient_tex : source_color, filter_linear; // Gradient texture (e.g. radial)
uniform sampler2D noise_tex : source_color, filter_linear; // Noise texture (grayscale preferred)
uniform float time_speed = 1.0;
uniform float swirl_strength = 1.0;
uniform float noise_scale = 3.0;
uniform float emission_strength = 16.0;

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
	vec2 uv = UV * 2.0 - 1.0; // Centered UV from -1 to 1
	float radius = length(uv);
	float angle = atan(uv.y, uv.x);

	// Animate swirl
	vec2 noise_uv = UV * noise_scale;
	float noise_val = texture(noise_tex, noise_uv).r;

	// Add swirl distortion to angle
	angle += noise_val * swirl_strength;

	// Convert polar back to UV
	vec2 swirl_uv = vec2(cos(angle), sin(angle)) * radius * 0.7 + 0.5;

	// Sample gradient texture with swirl
	vec4 color = texture(gradient_tex, swirl_uv);
	vec3 mixed_noise

	// Final output
	EMISSION = color.rgb * emission_strength;
	ALBEDO = color.rgb;
	ALPHA = color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
