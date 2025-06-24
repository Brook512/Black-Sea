shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.7, 0.8, 0.9, 0.6);
uniform float outline_size : hint_range(1, 3) = 1.0; 
// 添加发光控制参数
uniform float glow_speed = 0.5;         // 发光循环速度
uniform float glow_intensity = 0.1;      // 发光强度基础值
uniform float glow_pulse_range = 0.8;    // 发光脉动范围

void fragment() {
	vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_size;
	vec4 tex_color = texture(TEXTURE, UV);
	
	// 边缘检测（8方向采样）
	float max_alpha = 0.0;
	// 包括对角线方向的完整8方向采样
	const float step = 1.0;  // 使用1.0步长确保8方向
	for (float x = -1.0; x <= 1.0; x += step) {
		for (float y = -1.0; y <= 1.0; y += step) {
			// 跳过中心点(0,0)，避免重复采样自身
			if (x == 0.0 && y == 0.0) continue;
			
			vec2 offset = vec2(x, y) * pixel_size;
			float texture_alpha = texture(TEXTURE, UV + offset).a;
			max_alpha = max(max_alpha, texture(TEXTURE, UV + offset).a);
		}
	}
	
	// 创建动态发光效果
	float pulse = abs(sin(TIME * glow_speed)); // 使用正弦函数创建脉动效果
	float glow_factor = glow_intensity + pulse * glow_pulse_range;  // 组合基础强度和脉动
	
	// 最终输出逻辑
	if (tex_color.a > 0.1) {
		// 主图像：添加自身发光效果
		vec3 glow = glow_factor * outline_color.rgb;
		COLOR = vec4(tex_color.rgb + glow *0.1, tex_color.a);
	} 
	else if (max_alpha > 0.1) {
		// 描边：增加动态发光强度
		vec4 glow_outline = outline_color;
		glow_outline.rgb *= glow_factor;
		glow_outline.a = 0.3;
		COLOR = glow_outline;
	} 
	else {
		COLOR = vec4(0.0);
	}
}