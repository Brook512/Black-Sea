shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);
uniform float outline_size : hint_range(1, 3) = 1.0; 
uniform vec4 hurt_color = vec4(0.9, 0.1, 0.1, 0.9);
//uniform float hurt_intensity = 0.0; // 初始强度0（无效果）

void fragment() {
	vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_size;
	vec4 tex_color = texture(TEXTURE, UV);
	float loop_time = fract(TIME/0.5);
	// 边缘检测（8方向采样）
	float alpha = 0.0;
	for (float x = -1.0; x <= 1.0; ) {
		for (float y = -1.0; y <= 1.0; ) {
			vec2 offset = vec2(x, y) * pixel_size;
			alpha = max(alpha, texture(TEXTURE, UV + offset).a);
			y+=2.;
		}
		x+=2.;
	}
	
	// 组合输出
	if (tex_color.a > 0.1 && loop_time>0.5) {
		COLOR = hurt_color; // 原始像素
	}
	else if (tex_color.a > 0.1 && loop_time<=0.5) {
		COLOR = tex_color; // 描边像素
	} 
	else if (alpha > 0.1) {
		COLOR = outline_color; // 描边像素
	} else {
		COLOR = vec4(0.0); // 透明
	}
}