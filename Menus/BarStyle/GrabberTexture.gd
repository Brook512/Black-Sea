extends CanvasTexture

# 导出颜色属性（在编辑器可见）
@export var diffuse_color: Color = Color.WHITE:
	set(value):
		diffuse_color = value
		# 更新材质颜色
		_update_color()

# 内部方法：应用颜色到材质
func _update_color():
	if self.diffuse_texture:  # 确保有纹理存在
		var mat = self.diffuse_texture.get_material()
		if mat == null:  # 若无材质则创建
			mat = ShaderMaterial.new()
			self.diffuse_texture.material = mat
		
		# 创建简单颜色叠加着色器
		mat.shader = Shader.new()
		mat.shader.code = """
		shader_type canvas_item;
		uniform vec4 color_tint : source_color = vec4(1.0);
		void fragment() {
			vec4 tex_color = texture(TEXTURE, UV);
			COLOR = tex_color * color_tint;
		}
		"""
		mat.set_shader_param("color_tint", diffuse_color)
