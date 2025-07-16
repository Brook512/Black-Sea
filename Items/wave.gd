extends Sprite2D
@export var target:Sasaki

@onready var reposition_timer = Timer.new()

# 淡入淡出动画时间（秒）
const FADE_DURATION = 5.5
# X轴位置随机范围
const X_RANGE = 150
const wave_y_range = 30
func _ready():
	# 启动计时器
	reposition_timer.wait_time = 2.
	reposition_timer.one_shot = true
	reposition_timer.timeout.connect(_on_reposition_timeout)
	add_child(reposition_timer)
	reposition_timer.start()

# 计时器触发时执行位置更新流程
func _on_reposition_timeout():
	# 创建淡出动画序列
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(self, "position", Vector2(position.x,position.y+ wave_y_range), FADE_DURATION).set_trans(Tween.TRANS_SPRING)
	fade_out_tween.tween_property(self, "modulate:a", 0., FADE_DURATION)
	fade_out_tween.finished.connect(_on_fade_out_completed.bind())

# 淡出动画完成后执行
func _on_fade_out_completed():
	# 更新X轴位置
	position.x = randf_range(target.position.x -X_RANGE, target.position.x +X_RANGE)
	
	# 创建淡入动画序列
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(self, "position", Vector2(position.x,position.y- wave_y_range), FADE_DURATION).set_trans(Tween.TRANS_SPRING)
	fade_in_tween.tween_property(self, "modulate:a", 1., FADE_DURATION)
	fade_in_tween.finished.connect(_on_reposition_timeout.bind())
	#fade_in_tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)
