extends Area2D

var enemy          # 敌人主体（父节点）

const NORMAL_COLOR := Color.WHITE             # 恢复为纯白
var hurt_speed = 30

func take_damage(damage: int, dir) -> void:
	enemy = get_parent()                      # 敌人主体
	enemy.blood_spark.emitting = true                # 撒血粒子

	# 更新血量
	var hp = enemy.combat_state.blackboard.get_var("Health")
	hp -= damage
	enemy.combat_state.blackboard.set_var("Health", hp)
	
	enemy.invincible_timer.start()
	
