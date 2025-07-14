shader_type canvas_item;
	    /* 新建可调参数 —— Harmonic 比例 */

/* === 可调参数 / Adjustable uniforms === */
uniform float xPixels : hint_range(100, 1000) = 300.0;   // 水平像素格数 / horizontal pixel blocks
uniform float yPixels : hint_range(100, 500) = 225.0;   // 垂直像素格数 / vertical pixel blocks
uniform float xSpeed  : hint_range(0, 20) = 1.0;     // 水平波速 / horizontal speed
uniform float ySpeed  : hint_range(0.1, 100) = 1.0;    // 垂直速度(越小越快) / vertical speed
uniform float yRange  : hint_range(0, 500) = 100.0;   // 波高范围 / vertical range
    // 2. HSV → RGB 辅助函数（若已有可复用）
vec3 hsv2rgb(float h, float s, float v) {
        h = mod(h, 360.0);
        float c = v * s;
        float x = c * (1.0 - abs(mod(h / 60.0, 2.0) - 1.0));
        vec3 rgb;
        if (h < 60.0)      rgb = vec3(c, x, 0.0);
        else if (h < 120.0) rgb = vec3(x, c, 0.0);
        else if (h < 180.0) rgb = vec3(0.0, c, x);
        else if (h < 240.0) rgb = vec3(0.0, x, c);
        else if (h < 300.0) rgb = vec3(x, 0.0, c);
        else                rgb = vec3(c, 0.0, x);
        float m = v - c;
        return rgb + vec3(m);
}
    // 噪声函数（你也可以使用已有的噪声，如 Perlin / Simplex）
float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}
float smooth_edge(float t) {
    return t * t * (3.0 - 2.0 * t);
}
float special_sin(float t){
	return (3.*sin(t / ySpeed) + sin(3.*t/ySpeed))/4.;
}
/* === 片元着色 / Fragment === */
void fragment(){
    float time = TIME;
    vec2  uv   = UV;                       // 0–1 范围的纹理坐标 / normalized UV
     /* === 动态夜色海面 / Dynamic night ocean palette === */
    // 1. 基准色调（Hue）：210° ≈ 深蓝，随时间在 ±5° 内轻微摆动
    float base_hue = 203.0 + sin(time * 0.1) * 5.0;



    // 3. 深处 & 近水面颜色
    vec3 deep_night = hsv2rgb(base_hue, 0.95, 0.18);              // 深蓝‐靛
    // 近水面亮度/饱和度随时间 + uv.x 做轻微涌动，模拟月光反射
    float v_shift = 0.08 * sin(time * 0.4 + uv.x * 6.283);
    vec3 mid_night = hsv2rgb(base_hue + 10.0, 0.65, 0.35 + v_shift);

    // 4. 纵向插值得到当前像素基础色
    //vec3 col = mix(deep_night, mid_night, uv.y);
	vec2 cycled_uv = uv + vec2(1.0,0.) * 0.1 * TIME * 0.3;
    // 使用fract确保UV在[0,1)范围内循环（处理负值和>1的值）
    cycled_uv = fract(cycled_uv);
	vec3 col = texture(TEXTURE,cycled_uv).rgb;
  // 2. 生成像素化波浪高度 / Pixel-style sine waves
    float wave_amp = 75.0 + sin(time * 3.0 + 0.5* PI);



	/* 计算横向角度 */
	float ang = uv.x / 0.083 + time * xSpeed + 0.6 * PI;

	/* 主波 & 高阶谐波 */
	float main_wave = sin(ang);
	float second    = sin(2.0 * ang + 0.3);   // 2×频率，稍作相移
	float third     = sin(3.0 * ang - 1.2);   // 3×频率

	float HARMONIC1 = sin(TIME*0.55) ;   // 二次谐波振幅
	float HARMONIC2 = cos(TIME*0.55);   // 三次谐波振幅
	/* 合成更尖锐的波形 */
	float shaped = main_wave
	             + HARMONIC1 * second
	             + HARMONIC2 * third;

	/* 应用到原先公式 */
	float sine = ceil(uv.y * yPixels) / yPixels * wave_amp
	           - wave_amp * 0.5
	           + special_sin(time / ySpeed) * 3.0
	           - shaped;

    vec3 foamColor = vec3(1.0);



	// 添加扰动后计算 foamMask
	float foamNoise = noise(uv * 10.0 + time); // 根据 UV 和时间扰动
	float sineThreshold = mix(0.3, 0.5, 0.5 + 0.5 * sin(TIME * 1.3));
	float foamSharpness = mix(2.5, 4.0, 0.5 + 0.5 * sin(TIME * 2.1 + 1.0));
	float foamMask = smoothstep(sineThreshold + foamSharpness, sineThreshold - foamSharpness, sine + foamNoise * 0.2);

    // 3. 根据阈值将波峰染成白色 / Threshold to white ridges
    col = mix(col, foamColor,  foamMask);

	//vec4 final_col = vec4(col, 1.);

	// 模拟泡泡边缘的 soft mask
	float mask = smoothstep(0.5,-0.5, sine + 3.);

	// 混合颜色
	vec4 final_col = mix(vec4(col, 1.0), vec4(0.0), mask);

    float crest = special_sin(TIME);           // 跟“浪高”用的正弦完全一致

    float fade = 1.0;



	float edge_fade_width=0.3;
	float left_edge = smoothstep(0.0, edge_fade_width, uv.x);  // 左边缘：x从0到edge宽度时，值从1→0
	float right_edge = 1.0 - smoothstep(1.0 - edge_fade_width, 1.0, uv.x);  // 右边缘：x从1-edge宽度到1时，值从1→0
	float edge_fade = left_edge * right_edge;  // 两侧边缘共同作用的衰减系数（0-1）

	final_col.a *= fade * 1. * edge_fade;



	//vec4 ori_texture = texture(final_col,cycled_uv);

    COLOR = final_col;
}