shader_type canvas_item;

// 受击效果强度参数 (0.0-1.0)
uniform float hit_intensity : hint_range(0.0, 1.0) = 0.0;
// 受击边缘光颜色
uniform vec4 hit_color : source_color = vec4(1.0, 0.2, 0.2, 1.0);

void fragment() {
    // 原始颜色采样
    vec4 tex_color = texture(TEXTURE, UV);

    // 边缘检测算法 (使用亮度梯度)
    float edge = length(vec2(dFdx(UV.x), dFdy(UV.y)));
    edge = smoothstep(0.01, 0.05, edge);

    // 混合效果：原始颜色 + 边缘光
    vec3 final_color = mix(tex_color.rgb, hit_color.rgb, edge * hit_intensity);

    // 提升整体亮度
    final_color = mix(final_color, vec3(1.5), hit_intensity * 0.3);

    COLOR = vec4(final_color, tex_color.a);
}