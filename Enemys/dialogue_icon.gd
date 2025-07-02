extends Sprite2D


# 浮动参数配置
@export var float_height: float = 4.0   # 浮动幅度(像素)
@export var float_speed: float = 2.0     # 浮动速度(频率)

var base_y: float = 0.0       # 初始Y坐标
var time: float = 0.0         # 时间累积器

# 初始化记录原始位置
func _ready() -> void:
	base_y = position.y  # 记录初始Y坐标作为浮动基准

# 物理过程更新浮动位置
func _physics_process(delta: float) -> void:
	time += delta  # 累积经过的时间
	
	# 使用正弦函数计算垂直偏移量
	# 正弦波产生平滑周期性变化，值域[-1,1]
	var vertical_offset = sin(time * float_speed) * float_height
	
	# 更新节点位置，保持X不变只修改Y
	position.y = base_y + vertical_offset
