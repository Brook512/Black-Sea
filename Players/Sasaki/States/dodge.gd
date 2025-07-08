extends BasicPlayerState
# 关联ShaderMaterial
@onready var hsm_blackboard = get_parent().blackboard

func _enter() -> void:
	play_animation("Dodge")
	play_sound("Dodge")
	
func take_damage():
	# 开启闪烁：设置强度为1（最大）
	agent.get_node("SasakiSprite2D").material = load_shader_resource("Hurt")

func _update(delta: float) -> void:
	_handle_input(hsm_blackboard, 0.)
	if !agent.anim_player.is_playing():
		dispatch(EVENT_FINISHED)
	
func _exit() -> void:
	agent.get_node("SasakiSprite2D").material = null
	
