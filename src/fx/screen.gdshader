shader_type canvas_item;

// Full-resolution post-process over the 3D view: pixelation, optional retro palette, fade to
// black, and the Phase 2 effects (vignette, grain, fisheye, white bloom). All values are
// uniforms driven at runtime by PixelationLayer / ScreenEffects.

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest, repeat_disable;
uniform float pixel_size : hint_range(1.0, 64.0) = 3.0;
uniform float pixel_boost : hint_range(0.0, 32.0) = 0.0;
uniform float fade : hint_range(0.0, 1.0) = 0.0;
uniform float palette_mix : hint_range(0.0, 1.0) = 1.0;
uniform float vignette : hint_range(0.0, 1.0) = 0.0;
uniform float grain : hint_range(0.0, 1.0) = 0.0;
// TV-style static: per-pixel-cell noise that changes every few frames, plus rare bright streaks.
uniform float static_amount : hint_range(0.0, 1.0) = 0.0;
uniform float fisheye : hint_range(0.0, 1.0) = 0.0;
uniform float bloom : hint_range(0.0, 1.0) = 0.0;
uniform vec3 color_dark : source_color = vec3(0.09, 0.10, 0.09);
uniform vec3 color_deep : source_color = vec3(0.17, 0.21, 0.18);
uniform vec3 color_mid : source_color = vec3(0.33, 0.42, 0.34);
uniform vec3 color_light : source_color = vec3(0.78, 0.90, 0.74);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	float px = max(1.0, pixel_size + pixel_boost);
	vec2 cell = floor(SCREEN_UV * resolution / px);
	vec2 uv = (cell + 0.5) * px / resolution;

	// Barrel (fisheye) distortion, normalised so the screen corners still map to the corners.
	vec2 centered = uv - 0.5;
	float k = fisheye * 2.0;
	uv = clamp(0.5 + centered * (1.0 + k * dot(centered, centered)) / (1.0 + k * 0.5), 0.0, 1.0);

	vec3 color = texture(screen_tex, uv).rgb;

	// White bloom: a capped wash toward white so the scene never goes fully blind.
	color = mix(color, vec3(1.0), bloom * 0.7);

	float luma = dot(color, vec3(0.299, 0.587, 0.114));
	float t = clamp(luma, 0.0, 1.0) * 3.0;
	vec3 mapped = mix(color_dark, color_deep, clamp(t, 0.0, 1.0));
	mapped = mix(mapped, color_mid, clamp(t - 1.0, 0.0, 1.0));
	mapped = mix(mapped, color_light, clamp(t - 2.0, 0.0, 1.0));
	color = mix(color, mapped, palette_mix);

	float edge = smoothstep(0.35, 0.95, length((SCREEN_UV - 0.5) * vec2(1.0, 0.85)));
	color *= 1.0 - vignette * edge;

	float frame = floor(TIME * 30.0);
	float noise = hash(cell + frame);
	color += (noise - 0.5) * grain;

	float snow = hash(cell * 1.7 + frame * 3.1);
	float streak = step(0.985, hash(vec2(floor(cell.y * 0.5), floor(TIME * 10.0)))) * hash(vec2(cell.x * 0.05, frame));
	color = mix(color, vec3(snow), static_amount * 0.45);
	color += vec3(streak) * static_amount * 0.6;

	COLOR = vec4(color * (1.0 - fade), 1.0);
}
