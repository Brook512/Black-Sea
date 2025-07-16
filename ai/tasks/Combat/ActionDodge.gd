@tool
extends BTAction

var player_var:StringName = &"target"

func _enter() -> void:
	var target: Node2D = blackboard.get_var(player_var)
	var dir: float = target.global_position.x - agent.global_position.x
	
	agent.velocity.x = -sign(dir) * blackboard.get_var("DodgeSpeed")

	var tween = agent.create_tween()
	tween.tween_property(
			agent,                  # 目标对象
			"velocity:x",           # 属性路径
			0,                      # 目标值
			0.8                   # 持续时间（秒，可按需调整）
	).set_trans(Tween.TRANS_QUART)  # 四次缓动曲线

func _tick(delta: float) -> Status:
	return SUCCESS
