shader_type canvas_item;

uniform float inner_radius : hint_range(0.0, 1.0) = 0.3;
uniform float outer_radius : hint_range(0.0, 2.0) = 0.7;
uniform vec4 vignette_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	// Get UV coordinates from center (0.0-1.0 -> -0.5-0.5)
	vec2 center_uv = UV - vec2(0.5);
	
	// Calculate distance from center (normalized)
	float dist = length(center_uv) * 2.0;
	
	// Calculate vignette intensity
	float vignette = smoothstep(inner_radius, outer_radius, dist);
	
	// Mix original color with vignette
	COLOR = vec4(vignette_color.rgb, vignette * vignette_color.a);
}
