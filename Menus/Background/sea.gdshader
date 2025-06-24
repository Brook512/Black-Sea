shader_type canvas_item;
float getWave(vec2 uv, float waveHeight, float waveSpeed, float waveFrequency, float waveAmplitude, float depth) {
    // 调整 UV 的 Y 轴（基于 TIME 和 depth）
    uv.y -= sin(TIME + depth * 12.0) / 60.0 * waveAmplitude;

    // 计算调整后的速度
    float adjustedSpeed = TIME / 4.0 * waveSpeed;

    // 生成波浪
    float wave = smoothstep(
        0.0 + waveHeight,
        0.003 + waveHeight * (depth + 1.0),
        uv.y + sin((uv.x + adjustedSpeed) * waveFrequency * 10.0 + sin(uv.x * 3.0)) * 0.03 * waveAmplitude
    );

    return 1.0 - wave;
}

void fragment() {
    // 翻转 UV Y 轴以适配左下角原点
    vec2 uv = UV;
    uv.y = 1.0 - uv.y;

    // 调用波浪函数（示例参数）
    float wave = getWave(uv, 0.1, 1.0, 2.0, 0.5, 1.0);

    // 输出颜色
    COLOR = vec4(vec3(wave), 1.0);
}
void vertex() {
	// Called for every vertex the material is visible on.
}



//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
