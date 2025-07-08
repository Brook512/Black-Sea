@tool
extends BTAction
func _setup() -> void:
	agent.attack_area.body_entered.connect(_on_attack_range_body_entered)

func _on_attack_range_body_entered(body: Node2D) -> void:
	  # 验证是否为玩家
	if body.is_in_group("player"):
		# 向玩家发送伤害信号并传递伤害值
		body.emit_signal("hurt_signal", blackboard.get_var("AttackDamage"))
