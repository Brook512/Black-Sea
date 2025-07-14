@tool 
extends BTAction

@export var target_var: StringName = &"target"

func _tick(delta: float) -> Status:
	var blackboard: Blackboard = get_blackboard()
	var enemy: CharacterBody2D = get_agent()  # 获取敌人物体
	
	# 获取参数值
	var patrol_speed = blackboard.get_var(patrol_speed_var, 50.0)
	var patrol_range = blackboard.get_var(patrol_range_var, 100.0)
	var direction = blackboard.get_var(patrol_direction_var, 1)  # 默认向右
	
	# 如果还没有设置巡逻起点，则初始化
	if not blackboard.has_var("patrol_start_x"):
		blackboard.set_var("patrol_start_x", enemy.global_position.x)
		blackboard.set_var("patrol_right_bound", enemy.global_position.x + patrol_range)
		blackboard.set_var("patrol_left_bound", enemy.global_position.x - patrol_range)
	
	# 计算当前巡逻方向
	var right_bound = blackboard.get_var("patrol_right_bound")
	var left_bound = blackboard.get_var("patrol_left_bound")
	
	# 检查是否到达边界
	if direction > 0 and enemy.global_position.x >= right_bound - tolerance:
		direction = -1
	elif direction < 0 and enemy.global_position.x <= left_bound + tolerance:
		direction = 1
	
	# 更新移动方向
	blackboard.set_var(patrol_direction_var, direction)
	
	# 应用移动
	enemy.velocity.x = direction * patrol_speed
	enemy.velocity.y = 0
	enemy.move_and_slide()
	
	# 翻转精灵朝向移动方向
	if direction != 0:
		enemy.get_node("Sprite2D").flip_h = direction < 0
	
	return RUNNING
