shader_type canvas_item;
uniform vec2 offset = vec2(1.0,0.);
uniform float speed = 0.1;
void fragment(){
	vec2 cycled_uv = UV + offset * 0.1 * TIME * speed;

    // 使用fract确保UV在[0,1)范围内循环（处理负值和>1的值）
    cycled_uv = fract(cycled_uv);

	vec4 ori_texture = texture(TEXTURE,cycled_uv);
	COLOR = ori_texture;
}