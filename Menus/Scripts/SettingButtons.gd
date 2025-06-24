# 挂到 TextureButton 节点（Godot 4.x）
extends TextureButton

var _hover_tint   : Color = Color(1.15, 1.15, 1.15)  # 悬停微亮
var _normal_tint  : Color = Color(1,    1,    1)     # 默认
var _press_scale  : Vector2 = Vector2(1.94, 1.94)    # 按下微缩
var _press_offset : Vector2 = Vector2(1, 1)
var _ori_scale : Vector2 = Vector2(2, 2)
func _ready() -> void:
	# 只给 NormalTexture，其余留空
	connect("mouse_entered",  self._on_hover)
	connect("mouse_exited",   self._on_leave)
	connect("button_down",    self._on_pressed)
	connect("button_up",      self._on_released)

func _on_hover() -> void:
	modulate = _hover_tint      # 变亮

func _on_leave() -> void:
	modulate = _normal_tint     # 还原

func _on_pressed() -> void:
	scale     = _press_scale    # 微缩
	position += _press_offset   # 稍稍下移，产生“压下”错觉

func _on_released() -> void:
	scale     = _ori_scale
	position -= _press_offset
