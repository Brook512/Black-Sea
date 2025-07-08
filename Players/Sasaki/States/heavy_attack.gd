extends BasicPlayerState
@onready var hsm_blackboard = get_parent().blackboard
	
#@onready var hsm_blackboard = get_parent().blackboard

func _enter() -> void:
	var result = _check_energy(hsm_blackboard.get_var("attack_cost"),hsm_blackboard)
	if result:
		play_animation("HeavyAttack")
		play_sound("Attack")
	else:
		dispatch(EVENT_FINISHED)

func _update(delta: float) -> void:
	_handle_input(hsm_blackboard, 0.)
	if !agent.anim_player.is_playing():
		dispatch(EVENT_FINISHED)
