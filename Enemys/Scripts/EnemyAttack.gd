extends Node2D

# 场景类型枚举
enum SceneType {COMBAT, NORMAL}

# 配置参数
@export var current_scene:SceneType = SceneType.NORMAL
@export var min_attack_delay:float = 1.0
@export var max_attack_delay:float = 3.0
@export var facing_threshold:float = 0.7  # 面向检测阈值(cos(45°))

# 节点引用
@onready var attack_timer = $AttackTimer
@onready var interaction_area:CollisionShape2D = $InteractionArea

# 场景切换接口
func set_scene_type(new_scene: int) -> void:
	current_scene = new_scene
	if current_scene == SceneType.COMBAT:
		# 战斗场景激活攻击计时器
	
		attack_timer.start(randf_range(min_attack_delay, max_attack_delay))
	else:
		# 普通场景停止攻击计时器
		attack_timer.stop()

# 信号定义
signal enemy_attack_triggered
signal dialogue_requested

func _ready():
	# 配置交互区域
	attack_timer.one_shot = true


# 攻击超时回调
func _on_attack_timeout():
	if current_scene == SceneType.COMBAT:
		emit_signal("enemy_attack_triggered")
		# 重置随机攻击计时器
		attack_timer.start(randf_range(min_attack_delay, max_attack_delay))

# 玩家进入交互区域
func _on_player_entered(player):
	if current_scene != SceneType.NORMAL:
		emit_signal("dialogue_requested")



# 玩家退出交互区域
func _on_player_exited(_player):
	# 清理逻辑按需添加
	pass
