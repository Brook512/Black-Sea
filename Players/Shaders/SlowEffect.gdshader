shader_type canvas_item;

/* ---------- 可调参数 / Tunables ---------- */
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
/* ——— 新增：可调暗角颜色（RGB）和强度（A 作为混合权重） ——— */
uniform vec4 vignette_color = vec4(0.1, 0.2, 0.4, 0.7);
/* 其 alpha 用来控制颜色混合的整体力度，1 = 完全覆盖边缘 */
uniform float radius_begin : hint_range(0.0, 1.0) = 0.45;   // 开始模糊的半径
uniform float radius_end   : hint_range(0.0, 1.0) = 0.95;   // 全模糊的半径
uniform float intensity    : hint_range(0.0, 2.0) = 0.4;    // 模糊强度(权重)
uniform int   samples      : hint_range(2, 16, 1) = 10;      // 采样次数(越大越细腻)
uniform float vignette_pow : hint_range(0.0, 4.0) = 2.0;    // 暗角指数
uniform float desaturate   : hint_range(0.0, 1.0) = 0.35;   // 去饱和权重(0=不变,1=全灰)

/* ---------- 工具函数 / Helpers ---------- */
vec3 to_gray(vec3 c) {                     // 简单亮度灰度
    return vec3(dot(c, vec3(0.299, 0.587, 0.114)));
}

/* ---------- 主函数 / main ---------- */
void fragment() {
    vec2  uv      = SCREEN_UV;
    vec2  center  = vec2(0.5);             // 视口中心
    float dist    = distance(uv, center);  // 极坐标半径

    /* -------- 1. 计算模糊权重 / blur factor -------- */
    // 在 radius_begin 之后渐入，在 radius_end 处达到 1
    float t = smoothstep(radius_begin, radius_end, dist);
    t *= intensity;                        // 用户强度

    /* -------- 2. 径向模糊采样 / radial samples -------- */
    vec4 col = texture(SCREEN_TEXTURE, uv);  // 原像素
    for (int i = 1; i <= samples; i++) {
        // 将 UV 朝中心插值：mix(uv, center, factor)
        float f = t * (float(i) / float(samples)); // 由外到内
        col += texture(SCREEN_TEXTURE, mix(uv, center, f));
    }
    col /= float(samples + 1);             // 取平均

    /* -------- 3. 去饱和 / optional desaturation -------- */
    vec3 gray = to_gray(col.rgb);
    col.rgb   = mix(gray, col.rgb, 1.0 - desaturate * t);

    /* -------- 4. 暗角 / vignette -------- */
    float edge = 1.0 - pow(1.0 - dist, vignette_pow);   // 0 = center, 1 = edge
    col.rgb = mix(col.rgb, vignette_color.rgb,
                  vignette_color.a * edge);             // 用 alpha 控力度

    COLOR = col;

    //COLOR = col;
}
