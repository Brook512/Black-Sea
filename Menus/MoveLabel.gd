extends Label

# 浮动动画参数
var float_amplitude: float = 5.0  # 浮动幅度（像素）
var float_speed: float = 0.2      # 浮动速度（频率）
var base_position: Vector2         # 文本初始位置
var time: float = 0.0             # 时间计数器

func _ready() -> void:
	# 保存初始位置作为浮动基准点
	base_position = position
	# 设置处理模式为不暂停
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta: float) -> void:
	# 更新时间计数器
	time += delta
	
	# 计算平滑的正弦波浮动值
	# 使用 sin(angular_speed * time) 实现平滑的上下运动
	#var offset = float_amplitude * sin(time * float_speed * 2.0 * PI)
	var smooth_offset = float_amplitude * (
		sin(time * float_speed * 2.0 * PI) * 0.7 +
		sin(time * float_speed * 0.8 * PI) * 0.3
	)
	# 应用垂直方向的浮动效果
	position.y = base_position.y + smooth_offset
