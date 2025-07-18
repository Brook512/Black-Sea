extends CheckBox
# FullscreenToggle.gd
## 勾选 → 全屏，取消 → 窗口化
## Tick = fullscreen, untick = windowed.

@export var save_key: String = "display/fullscreen_enabled"

func _ready() -> void:
	# ① 读取上次保存的状态（默认 false）
	var is_fullscreen: bool = ProjectSettings.get_setting(save_key, false)
	button_pressed = is_fullscreen
	_apply_fullscreen(is_fullscreen)

	# ② 监听勾选变化
	toggled.connect(_on_toggled)

func _on_toggled(pressed: bool) -> void:
	_apply_fullscreen(pressed)
	# 保存到 project.godot，方便下次启动加载
	ProjectSettings.set_setting(save_key, pressed)
	ProjectSettings.save()

func _apply_fullscreen(enable: bool) -> void:
	var win := get_window()
	win.mode = Window.MODE_FULLSCREEN if enable else Window.MODE_WINDOWED
