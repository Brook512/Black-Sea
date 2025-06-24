shader_type canvas_item;

/* ---------- Uniforms ---------- */
uniform float inner_radius : hint_range(0.0,1.0) = 0.2;
uniform float noise_scale  : hint_range(0.1,2.0) = 0.1;
uniform float transition_width : hint_range(0.01, 0.5) = 0.3;
uniform float arc_extent : hint_range(0.0, 3.14) = 1.0; 
uniform float pulse_speed : hint_range(0.1, 5.0) = 1.0;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.2;
uniform vec4 color_start : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_end : source_color = vec4(1.0, 1.0, 1.0, 1.0);
//uniform float color_transition_speed : hint_range(0.1, 5.0) = 5.0;
uniform float color_band_width : hint_range(0.01, 0.5) = 0.0;
uniform float u_transition_progress : hint_range(0.0, 1.0) = 1.;
//uniform float parts_angular_offset : hint_range(0.0, 6.28) = 5.0;
//uniform int parts_count : hint_range(1, 8) = 8;
uniform int selected_part : hint_range(0,4) = 3;

/* ---------- Utility Functions ---------- */
vec3 hash33(vec3 p3) {
	p3 = fract(p3 * vec3(.1031,.11369,.13787));
	p3 += dot(p3, p3.yxz + 19.19);
	return -1.0 + 2.0 * fract(vec3(p3.x+p3.y, p3.x+p3.z, p3.y+p3.z) * p3.zyx);
}

float snoise3(vec3 p) {
	const float K1 = 0.333333333;
	const float K2 = 0.166666667;
	vec3  i = floor(p + (p.x + p.y + p.z) * K1);
	vec3  d0 = p - (i - (i.x + i.y + i.z) * K2);

	vec3  e  = step(vec3(0.0), d0 - d0.yzx);
	vec3  i1 = e * (1.0 - e.zxy);
	vec3  i2 = 1.0 - e.zxy * (1.0 - e);

	vec3  d1 = d0 - (i1 - K2);
	vec3  d2 = d0 - (i2 - K1);
	vec3  d3 = d0 - 0.5;

	vec4  h  = max(0.6 - vec4(dot(d0,d0),dot(d1,d1),dot(d2,d2),dot(d3,d3)), 0.0);
	vec4  n  = h * h * h * h *
		    vec4(dot(d0, hash33(i)),
		         dot(d1, hash33(i + i1)),
		         dot(d2, hash33(i + i2)),
		         dot(d3, hash33(i + 1.0)));

	return dot(vec4(31.316), n);
}

vec4 extract_alpha(vec3 c) {
	float m = min(max(max(c.r, c.g), c.b), 1.0);
	return (m > 1e-5) ? vec4(c / m, m) : vec4(0.0);
}

float light1(float intensity, float attenuation, float dist) {
	return intensity / (1.0 + dist * attenuation);
}

float selected_portion(vec2 uv) {
    if (selected_part == 0) return 0.0;
    float ang = atan(uv.y, uv.x);
    if (ang < 0.0) ang += 6.28318530718;
    float start_angle = 0.0;
    if      (selected_part == 1) start_angle = 1.57079632679;
    else if (selected_part == 2) start_angle = 0.0;
    else if (selected_part == 3) start_angle = 4.71238898038;
    else if (selected_part == 4) start_angle = 3.14159265359;
    float diff = abs(ang - start_angle);
    if (diff > 3.14159265359) diff = 6.28318530718 - diff;
    return smoothstep(arc_extent, arc_extent - transition_width, diff);
}

vec3 applyColorTransition() {
    return mix(color_start.rgb, color_end.rgb, 
               smoothstep(0.0, 1.0, u_transition_progress));
}

vec4 ring_effect(vec2 uv) {
	float ang = atan(uv.y, uv.x);
	float len = length(uv);
	float n0 = snoise3(vec3(uv * noise_scale, TIME * 0.5)) * 0.5 + 0.5;
	float r0 = mix(mix(inner_radius, 1.0, 0.4), mix(inner_radius, 1.0, 0.6), n0);
	float d0 = distance(uv, r0 / len * uv);
	float v0 = light1(1.0, 10.0, d0) * smoothstep(r0 * 1.05, r0, len);
	float v2 = smoothstep(1.0, mix(inner_radius, 1.0, n0 * 0.5), len);
	float v3 = smoothstep(inner_radius, mix(inner_radius, 1.0, 0.5), len);
    float intensity = (v0) * v2 * v3 * (1.0 + pulse_strength * sin(TIME * pulse_speed));
    float portion = selected_portion(uv);
	vec3 base_color = applyColorTransition();
    vec3 final_color = base_color * intensity * portion;
    return extract_alpha(final_color);
}

void fragment() {
	vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 fragCoord = SCREEN_UV * res;
	vec2 uv = (fragCoord * 2.0 - res.xy) / res.y;
	COLOR = ring_effect(uv);
}