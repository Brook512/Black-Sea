@tool
extends BTAction

@export var chase_speed_var: StringName = &"chase_speed"
#@export var player_position_var: StringName = &"player_position"
var player_var:StringName = &"target"

func _tick(delta: float) -> Status:
	var blackboard: Blackboard = get_blackboard()
	var enemy: CharacterBody2D = get_agent()
	var player = blackboard.get_var(player_var)
	# 获取玩家位置（需要其他任务/系统更新此值）
	var player_position: Vector2 = player.position
	
	if !player_position:
		return FAILURE  # 没有有效的玩家位置
	
	# 计算追击方向
	var chase_speed = blackboard.get_var("Speed")
	var direction_x = sign(player_position.x - enemy.global_position.x)

	# 应用移动
	enemy.velocity.x = direction_x * chase_speed
	enemy.velocity.y = 0
	enemy.move_and_slide()
	#print(enemy.velocity.x)
	
	# 简单检查玩家是否在攻击范围内
	var distance = abs(player_position.x - enemy.global_position.x)
	if distance < 80:  # 50像素为攻击范围
		blackboard.set_var("player_in_attack_range", true)
		return FAILURE
		
	else:
		blackboard.set_var("player_in_attack_range", false)
		return RUNNING
	
	
