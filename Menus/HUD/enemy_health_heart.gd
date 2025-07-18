extends AnimatedSprite2D

@export var player:CharacterBody2D
var _elapsed_time: float = 10.0
var _original_position: Vector2
var _noise = FastNoiseLite.new()  # Godot内置柏林噪声生成器
var heart_beat_duration =1.5

var health
var max_health
var _shaking := false  # 震动状态标志
var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_loops()


func _ready():
	# 初始化柏林噪声
	_noise.seed = randi()
	_noise.frequency = 15.0  # 控制震动频率
	_original_position = position
	self.frame=5
	max_health = player.combat_state.blackboard.get_var("MaxHealth")

	heartbeat_effect(1.2, 1.0, heart_beat_duration,0.9)
	
func _process(delta):
	#apply_shake()
	health = player.combat_state.blackboard.get_var("Health")

	_update_heart_frame(health)
	if player.invincible_timer.time_left>0.01:
		shake_heart()

	
func _update_heart_frame(_health):
	#_health = clamp(_health, 0.0, 1.0)
	
	# 计算应该显示的心形帧数（0-4）
	# 使用线性插值将health值映射到帧范围
	#var _frame = 4
	var _frame = floor(lerp(0., 4., (float(_health)/float(max_health))))
	#_frame = floor(lerp(0, 4, 0.9))
	# 根据当前生命值设置相应的帧
	match _frame:
		4.:
			self.frame = 5  # 满心
		3.:
			self.frame = 6  # 4/5心a
		2.:
			self.frame = 7  # 3/5心
		1.:
			self.frame = 8  # 2/5心
		0.:
			self.frame = 9  # 空心
	
	# (可选)当生命值低于20%时添加闪烁效果
	#if _health < 0.2:
		## 创建闪烁动画
		#var _tween = create_tween()
		#_tween.tween_property(self, "modulate", Color(1, 0.5, 0.5), 0.3)
		#_tween.tween_property(self, "modulate", Color(1, 1, 1), 0.3)
		#_tween.set_loops()  # 无限循环直到低血量状态结束
	
# ─── 公开的震动接口 ──────────────────
func shake_heart(strength: float = 2.0, duration: float = 0.5) -> void:
	if _shaking: return  # 防止重复震动
	
	_shaking = true
	_original_position = position  # 保存当前位置作为原始位置
	_shake(strength, duration)

# ─── 核心震动逻辑 ──────────────────
func _shake(strength: float, duration: float) -> void:
	var _tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	_tween.tween_method(
		_update_shake_position.bind(strength),  # 绑定强度参数
		0.0,                # 起始值
		1.0,                # 结束值
		duration            # 持续时间
	)
	
	_tween.finished.connect(func():
		position = _original_position  # 恢复原始位置
		_shaking = false
	)

# ─── 更新震动位置 ──────────────────
func _update_shake_position(progress: float, strength: float) -> void:
	# 计算当前震动强度（随进度衰减）
	var current_strength = (1.0 - progress) * strength
	
	# 使用时间而不是进度值获取噪声
	var time = Time.get_ticks_msec() / 100.0
	var noise_x = _noise.get_noise_1d(time)
	var noise_y = _noise.get_noise_1d(time + 100.0)
	
	# 直接修改当前节点位置（不再尝试获取父节点）
	position = _original_position + Vector2(noise_x, noise_y) * current_strength
	
# 心跳特效函数（解耦设计）
func heartbeat_effect(
	peak_scale: float = 1.2, 
	base_scale: float = 1.0,
	duration: float = 1.6,
	fade_ratio: float = 0.7
) -> void:
	# 第一阶段：放大并变亮（模拟心跳膨胀）
	tween.tween_property(self, "scale", Vector2(peak_scale, peak_scale), duration * 0.3)
	
	# 第二阶段：缩小并恢复（模拟心跳收缩）
	tween.tween_property(self, "scale", Vector2(base_scale, base_scale), duration * 0.7)
