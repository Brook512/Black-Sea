extends Node2D

var leaf_bars = [
	Rect2(0, -30, 50, 2),   # 上边（较宽）xy width height
	Rect2(0, 30, 50, 2),    # 下边
	Rect2(30, 0, 2, 50),   # 左边（较长）
	Rect2(-30, 0, 2, 50)     # 右边
]

# 颜色状态（使用图片中的绿色）
var bar_colors = [
	Color(0.3, 0.8, 0.2, 0.7),  # 上边颜色
	Color(0.3, 0.8, 0.2, 0.7),  # 下边颜色
	Color(0.3, 0.8, 0.2, 0.7),  # 左边颜色
	Color(0.3, 0.8, 0.2, 0.7)   # 右边颜色
]

# 玩家引用和碰撞区域
var player
var collision_areas = []
var tint_factor = 1.0  # 碰撞颜色渐变控制
var collision_layer_num =4
var collision_mask_num =4

func _ready():
	# 获取玩家引用
	player = get_parent()
	
	# 创建四个碰撞区域
	for i in range(4):
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		
		shape.size = leaf_bars[i].size
		collision.shape = shape
		collision.position = leaf_bars[i].position + leaf_bars[i].size/2
		
		# 设置碰撞层级
		area.collision_layer = collision_layer_num
		area.collision_mask = collision_mask_num  # 只检测敌方子弹
		
		area.add_child(collision)
		#area.set_meta("leaf_index", i)
		area.connect("area_entered", Callable(self, "_on_collision"))
		player.add_child(area)
		collision_areas.append(area)
		
		# 添加渐变计时器
		#var timer = Timer.new()
		#timer.wait_time = 0.6
		#timer.one_shot = true
		#timer.connect("timeout", Callable(self, "_on_color_reset").bind(i))
		#player.add_child(timer)
	


# 碰撞处理函数
func _on_collision(area):
	if area.is_in_group("enemy_projectile"):
		var index = area.get_meta("leaf_index", 0)
		bar_colors[index] = Color(0.8, 0.2, 0.2, 0.9)  # 红色碰撞色
		
		# 启动着色器渐变
		var tween = create_tween()
		tween.tween_property(self, "tint_factor", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "tint_factor", 1.0, 0.7).set_trans(Tween.TRANS_QUAD)
		
		queue_redraw()

# 恢复颜色函数
func _on_color_reset(index):
	bar_colors[index] = Color(0.3, 0.8, 0.2, 0.7)  # 重置为绿色
	queue_redraw()

func _process(delta):
	# 确保始终跟随玩家
	global_position = player.global_position
	queue_redraw()

func _draw():
	# 围绕玩家绘制四条长边
	for i in range(4):
		# 添加圆角效果，使更像叶子
		var points = []
		var rect = leaf_bars[i]
		var rounded_radius = 5.0
		
		# 计算圆角矩形点
		for j in range(16):
			var angle = j * (PI * 0.5) / 4
			points.append(Vector2(
				sin(angle) * rounded_radius + rect.size.x * (0.5 - 0.5 * cos(angle)),
				cos(angle) * rounded_radius - rect.size.y * (0.5 - 0.5 * sin(angle))
			) + rect.position + rect.size * 0.5)
		
		 #绘制带圆角的长边
		draw_polygon(points,[bar_colors[i]])
		#draw_polygon(PoolVector2Array(points), [bar_colors[i]])
