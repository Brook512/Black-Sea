extends BasicPlayerState
@onready var hsm_blackboard = get_parent().blackboard
	
#@onready var hsm_blackboard = get_parent().blackboard
func _enter() -> void:
	play_animation("Charging")
	play_sound("Charging")

func _update(delta: float) -> void:
	_handle_input(hsm_blackboard, 0.)
	if !agent.anim_player.is_playing():
		dispatch(EVENT_FINISHED)
