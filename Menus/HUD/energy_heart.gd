extends Sprite2D
@onready var heart_beat_timer = Timer.new()
var heartbeat_time=0.

	
func _physics_process(delta: float) -> void:
	heartbeat_time+=delta
	if heartbeat_time >= 2.:
		heartbeat_effect()
		heartbeat_time=0.

# 心跳特效函数（解耦设计）
func heartbeat_effect(
	peak_scale: float = 1.2, 
	base_scale: float = 1.0,
	duration: float = 1.6,
	fade_ratio: float = 0.7
) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	# 第一阶段：放大并变亮（模拟心跳膨胀）
	tween.tween_property(self, "scale", Vector2(peak_scale, peak_scale), duration * 0.3)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), duration * 0.3)
	
	# 第二阶段：缩小并恢复（模拟心跳收缩）
	tween.tween_property(self, "scale", Vector2(base_scale, base_scale), duration * 0.7)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, fade_ratio), duration * 0.7)
	
	# 特效完成后自动释放资源
	#tween.finished.connect(func(): tween.kill())
