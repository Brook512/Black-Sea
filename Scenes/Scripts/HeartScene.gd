extends Node2D
# 信号声明：当特效在特定方向触发时发出
signal effect_triggered(direction: String)

# 节点引用
@export var effect_sprite: AnimatedSprite2D
# 控制参数
var timer: float = 0.0
const SPAWN_INTERVAL: float = 3  # 特效生成间隔(秒)
const EFFECT_RADIUS: float = 100.0 # 特效距离中心点的半径


func _draw() -> void:
	pass

func _ready() -> void:
	# 获取场景中的特效AnimatedSprite2D节点
	# 初始状态：隐藏特效
	effect_sprite.visible = false
	

	

func _physics_process(delta: float) -> void:
	timer += delta
	
	# 按固定间隔生成特效
	if timer >= SPAWN_INTERVAL:
		timer = 0.0
		_spawn_effect()

# 在随机方向上生成特效
func _spawn_effect() -> void:
	# 定义四个方向区域（上/右/下/左）
	const DIRECTIONS := ["up", "right", "down", "left"]
	# 随机选择一个方向
	var dir_index: int = randi() % DIRECTIONS.size()
	var direction: String = DIRECTIONS[dir_index]
	
	# 获取屏幕中心位置（全局坐标）
	var screen_center := get_viewport().get_visible_rect().size / 2
	
	# 根据方向计算偏移角度和位置
	var effect_position: Vector2
	match direction:
		"up":    effect_position = screen_center + Vector2(0, -EFFECT_RADIUS).rotated(deg_to_rad(randf_range(-45.0, 45.0)))
		"right": effect_position = screen_center + Vector2(EFFECT_RADIUS, 0).rotated(deg_to_rad(randf_range(-45.0, 45.0)))
		"down":  effect_position = screen_center + Vector2(0, EFFECT_RADIUS).rotated(deg_to_rad(randf_range(-45.0, 45.0)))
		"left":  effect_position = screen_center + Vector2(-EFFECT_RADIUS, 0).rotated(deg_to_rad(randf_range(-45.0, 45.0)))
	
	# 将全局坐标转换为相对于当前节点的局部坐标
	var local_position = to_local(effect_position)
	
	# 应用位置并显示特效
	effect_sprite.position = local_position
	effect_sprite.visible = true
	effect_sprite.play("leaf")
	
	# 发出信号并传递触发方向
	effect_triggered.emit(direction)


# 注意：需要在AnimatedSprite2D动画播放完成时调用此函数(通过动画player信号连接)
func _on_effect_sprite_animation_finished() -> void:
	# 隐藏特效
	effect_sprite.visible = false
