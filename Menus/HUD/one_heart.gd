class_name Shaker
extends AnimatedSprite2D

# 震动参数
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0
var _elapsed_time: float = 0.0
var _original_position: Vector2
var _noise = FastNoiseLite.new()  # Godot内置柏林噪声生成器

func _ready():
	# 初始化柏林噪声
	_noise.seed = randi()
	_noise.frequency = 15.0  # 控制震动频率
	_original_position = position
	_on_hurt_animation(2)
	
	

# 启动震动效果（外部调用接口）
func _on_hurt_animation(health, duration: float=1.0, strength: float=2.0):
	_shake_duration = duration
	_shake_strength = strength
	_elapsed_time = 0.0
	#self.play("Hurt")
	
func _setframe_health(health:int):
	var max_health:int = 4
	frame = max_health-health
	
func _process(delta):
	if _elapsed_time < _shake_duration:
		_elapsed_time += delta
		
		# 计算当前衰减强度 (线性衰减)
		var current_strength = _shake_strength * (1 - _elapsed_time / _shake_duration)
		
		# 使用柏林噪声生成平滑偏移
		var noise_x = _noise.get_noise_1d(_elapsed_time * 50)
		var noise_y = _noise.get_noise_1d(_elapsed_time * 50 + 100)
		
		# 应用偏移 (限制在圆形区域内)
		position = _original_position + Vector2(noise_x, noise_y) * current_strength
	elif position != _original_position:
		# 恢复原始位置
		position = _original_position
	
