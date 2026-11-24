shader_type spatial;
render_mode cull_back, diffuse_lambert, specular_disabled;

// Phase 2 pillar: its sides fade into the void colour toward the base, so pillars look like
// they descend into a dark mist and holes read as dark gaps. Based on world height, so a pillar
// that is still rising or already sinking is darker too.

uniform vec3 albedo : source_color = vec3(0.77);
// Multiplier set by Placeholders.set_brightness (0 = black, as for a marked pillar).
uniform float brightness = 1.0;
uniform vec3 mist_color : source_color = vec3(0.02, 0.04, 0.03);
// World height of the pillar tops; the mist starts just below it.
uniform float surface_y = 0.0;
uniform float mist_top = -0.05;
// Metres below mist_top at which the side is fully dark.
uniform float mist_depth = 1.6;

varying float world_y;

void vertex() {
	world_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

void fragment() {
	float depth = clamp((surface_y + mist_top - world_y) / max(mist_depth, 0.001), 0.0, 1.0);
	float mist = depth * (2.0 - depth);
	ALBEDO = mix(albedo * brightness, mist_color, mist);
	ROUGHNESS = 0.9;
}
