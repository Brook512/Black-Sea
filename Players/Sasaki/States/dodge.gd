extends BasicPlayerState
# 关联ShaderMaterial
@onready var hsm_blackboard = get_parent().blackboard
var dodge_speed=100
var most_dodge_time
func _enter() -> void:
	play_animation("Dodge")
	play_sound("Dodge")
	agent.invincible(0.6)
	most_dodge_time=0.
	agent.velocity.x = -hsm_blackboard.get_var("facing_vec")*dodge_speed
	var tween := get_tree().create_tween()
	tween.tween_property(
			agent,                  # 目标对象
			"velocity:x",           # 属性路径
			0,                      # 目标值
			0.8                   # 持续时间（秒，可按需调整）
	).set_trans(Tween.TRANS_QUART)  # 四次缓动曲线

	
func _update(delta: float) -> void:
	most_dodge_time+=delta
	if !agent.shadow_player.is_playing():
		agent.shadow.visible=false
		
	if !agent.anim_player.is_playing() or most_dodge_time>0.8:
		dispatch(EVENT_FINISHED)
	
func _exit() -> void:
	agent.get_node("SasakiSprite2D").material = null
	
