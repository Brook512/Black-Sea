@tool
extends BTAction

@export var chase_speed_var: StringName = &"chase_speed"
@export var player_position_var: StringName = &"player_position"

func _tick(delta: float) -> Status:
	var blackboard: Blackboard = get_blackboard()
	var enemy: CharacterBody2D = get_agent()
	
	# 获取玩家位置（需要其他任务/系统更新此值）
	var player_position: Vector2 = blackboard.get_var(player_position_var, Vector2.ZERO)
	var direction_x = sign(player_position.x - enemy.global_position.x)
	
	if player_position == Vector2.ZERO:
		return FAILURE  # 没有有效的玩家位置

	# 翻转精灵朝向目标
	enemy.get_node("EnemySprite").flip_h = direction_x < 0
	
	return RUNNING
