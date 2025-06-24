# camera_controller.gd
extends Camera2D

# 暴露在编辑器中的可调节参数
@export var target: Node2D    # 追踪的目标节点
@export var smooth_speed: float = 0.15  # 跟随平滑度 (0:即时, 1:最平滑)
@export var enable_screen_shake: bool = true  # 是否启用屏幕震动
@export var y_offset: float = 70.0  # 相机在目标上方的垂直距离
# 私有变量
var _screen_shake_intensity: float = 0.0
var _noise = FastNoiseLite.new()  # 用于屏幕震动的噪声

func _ready():
	# 初始化噪声生成器
	_noise.seed = randi()
	_noise.frequency = 0.5
	
	# 确保摄像机在启动时启用
	make_current()
	
	# 设置初始位置避免第一帧卡顿
	if target:
		global_position = target.global_position
	else:
		push_error("角色摄影机无追踪对象")

func _physics_process(delta):
	if !target:
		return
	
	# 核心跟随逻辑（使用线性插值平滑移动）
	# 计算相机目标位置：在目标上方指定距离处
	var target_position = Vector2(
		target.global_position.x,  # 保持X轴相同
		target.global_position.y - y_offset  # Y轴上方偏移
	)
	
	global_position = global_position.lerp(target_position, smooth_speed)
	
	# 边界限制
	_apply_boundary_limits()
	
	# 屏幕震动处理
	if enable_screen_shake && _screen_shake_intensity > 0:
		_apply_screen_shake(delta)

# 限制摄像机不超过地图边界
func _apply_boundary_limits():
	position = Vector2(
		clamp(position.x, limit_left, limit_right),
		clamp(position.y, limit_top, limit_bottom)
	)

# 应用屏幕震动效果
func _apply_screen_shake(delta):
	var shake_offset = Vector2(
		_noise.get_noise_1d(Time.get_ticks_msec() * 0.1),
		_noise.get_noise_1d(Time.get_ticks_msec() * 0.1 + 1000)
	) * _screen_shake_intensity * 16.0
	#offset_h = offset.x
	#offset_v = offset.y
	offset = shake_offset
	# 震动强度衰减
	_screen_shake_intensity = lerp(_screen_shake_intensity, 0.0, 5.0 * delta)
	if _screen_shake_intensity < 0.01:
		_screen_shake_intensity = 0.0
		reset_screen_offset()
		
func reset_screen_offset():
	offset=Vector2(0,0)

# 外部触发屏幕震动
func trigger_screen_shake(intensity: float = 0.5, duration: float = 0.4):
	_screen_shake_intensity = intensity
