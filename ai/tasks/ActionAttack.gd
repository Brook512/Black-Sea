@tool
extends BTAction

@export var attack_damage_var: StringName = &"attack_damage"
@export var attack_cooldown_var: StringName = &"attack_cooldown"
@export var player_position_var: StringName = &"player_position"

var attack_timer: float = 0

func _tick(delta: float) -> Status:
	var blackboard: Blackboard = get_blackboard()
	var enemy: CharacterBody2D = get_agent()
	
	# 攻击冷却时间处理
	attack_timer -= delta
	if attack_timer > 0:
		return RUNNING  # 冷却中
	
	# 检查玩家是否在攻击范围内
	var player_position: Vector2 = blackboard.get_var(player_position_var, Vector2.ZERO)
	if player_position == Vector2.ZERO:
		return FAILURE
	
	# 计算距离
	var distance = abs(player_position.x - enemy.global_position.x)
	
	# 确保玩家在攻击范围内
	if distance > 50:
		return FAILURE
	
	# 执行攻击
	var attack_damage = blackboard.get_var(attack_damage_var, 10)
	
	# 这里应该调用实际攻击逻辑，例如：
	# player.take_damage(attack_damage)
	print("敌人攻击! 造成伤害: ", attack_damage)
	
	# 播放攻击动画
	# enemy.get_node("AnimationPlayer").play("attack")
	
	# 重置攻击冷却（根据装备/敌人类型调整）
	var cooldown = blackboard.get_var(attack_cooldown_var, 1.0)
	attack_timer = cooldown
	
	return SUCCESS
