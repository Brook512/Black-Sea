extends HSlider
## VolumeSlider.gd
## Attach to an HSlider node placed anywhere in your UI.

@export var bus_name: String = "Master"   # 需要调节的音频总线名称
@export_range(-60.0, 0.0, 0.1) var min_db := -60.0   # 最小分贝（静音）
@export_range(-60.0, 0.0, 0.1) var max_db := 0.0     # 最大分贝（满音量）
@export var save_key: String = "audio/volume_db"      # 项目设置中的保存位置

func _ready() -> void:
	# 初始时把滑块范围映射到分贝范围
	min_value = min_db
	max_value = max_db

	# 读取上次保存的音量（若未保存则使用 max_db）
	value = ProjectSettings.get_setting(save_key, max_db)

	# 立即应用一次，保持 UI 与实际音量同步
	_apply_volume(value)

	# 当滑块值变化时触发回调
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_db: float) -> void:
	_apply_volume(new_db)
	# 保存到项目设置，方便下次启动自动加载
	ProjectSettings.set_setting(save_key, new_db)
	ProjectSettings.save()  # 立即写入 project.godot

func _apply_volume(db: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_error("Audio bus '%s' not found!" % bus_name)
		return
	AudioServer.set_bus_volume_db(idx, db)
	# 若分贝低到一定程度，最好同时静音开关，在 Godot 内部可节约运算
	AudioServer.set_bus_mute(idx, db <= min_db)
