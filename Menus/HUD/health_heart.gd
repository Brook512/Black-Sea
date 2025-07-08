class_name Shaker
extends AnimatedSprite2D

@export var player:Sasaki
var _elapsed_time: float = 10.0
var _original_position: Vector2
var _noise = FastNoiseLite.new()  # Godot内置柏林噪声生成器
var heart_beat_duration =2.
var heartbeat_time = 2.
var energy
var max_energy

func _ready():
	# 初始化柏林噪声
	_noise.seed = randi()
	_noise.frequency = 15.0  # 控制震动频率
	_original_position = position
	max_energy = player.hsm.blackboard.get_var("max_energy")
	
	
func _process(delta):
	#apply_shake()
	energy = player.hsm.blackboard.get_var("energy")
	heart_beat_duration = _update_heartbeat_duration(energy,max_energy)
	heartbeat_time+=delta
	if heartbeat_time >= heart_beat_duration:
		heartbeat_effect(1.2,1.0,heart_beat_duration,0.9)
		heartbeat_time=0.

	#_shake(delta,2.)
	
func _update_heartbeat_duration(energy,max_energy):
	return lerp(0.5, 2.0, energy/max_energy)
	

func apply_shake():
	_elapsed_time = 0
	

# ─── 核心：震动实现 ──────────────────
func _shake(delta: float,_shake_duration=2.) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	tween.tween_method(
		_update_shake_position,  # 回调方法
		0.0,                    # 起始值 (伪进度)
		1.0,                    # 结束值 (伪进度)
		_shake_duration               # 持续时间
	).set_delay(0)              # 立即开始
 	# 震动结束后复位
	tween.finished.connect(func(): 
		position = _original_position
		tween.kill()
	)


func _update_shake_position(progress: float,_shake_strength=2.) -> void:
	var target_node = get_parent() as Node2D
	if not target_node: return
	
	# 计算当前强度 (线性衰减)
	var current_strength = (1.0 - progress) * _shake_strength
	
	# 基于噪声生成平滑随机偏移
	# 使用进度值*50确保在持续时间内有足够采样点
	var noise_offset = progress * 50.0
	var noise_x = _noise.get_noise_1d(noise_offset)
	var noise_y = _noise.get_noise_1d(noise_offset + 100.0)
	
	# 应用偏移量
	target_node.position = _original_position + Vector2(noise_x, noise_y) * current_strength

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
	tween.finished.connect(func(): tween.kill())
