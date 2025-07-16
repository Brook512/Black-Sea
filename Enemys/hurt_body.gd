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
	
	enemy.velocity.x = sign(dir) * hurt_speed
	var tween = create_tween()
	tween.tween_property(
			enemy,                  # 目标对象
			"velocity:x",           # 属性路径
			0,                      # 目标值
			0.4                  # 持续时间（秒，可按需调整）
	).set_trans(Tween.TRANS_QUART)  # 四次缓动曲线
	
	enemy.invincible_timer.start()
	
