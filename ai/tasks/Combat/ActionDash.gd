@tool
extends BTAction

var player_var:StringName = &"target"
var dash_timer = 0.
func _enter() -> void:
	dash_timer = 0.
	var target: Node2D = blackboard.get_var(player_var)
	var dir: float = target.global_position.x - agent.global_position.x
	
	agent.velocity.x = sign(dir) * blackboard.get_var("DashSpeed")
	var tween = agent.create_tween()
	tween.tween_property(
			agent,                  # 目标对象
			"velocity:x",           # 属性路径
			0,                      # 目标值
			0.8                   # 持续时间（秒，可按需调整）
	).set_trans(Tween.TRANS_QUART)  # 四次缓动曲线

func _tick(delta: float) -> Status:
	agent.shadow_sprite.visible = true
	agent.anim_player.play("Dash")
	agent.shadow_player.play("Dash")
	dash_timer+=delta
	if dash_timer>0.2:
		agent.shadow_player.stop()
		agent.shadow_sprite.visible = false
		return SUCCESS

	return RUNNING
	
