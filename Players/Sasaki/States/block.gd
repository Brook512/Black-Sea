extends BasicPlayerState
@onready var hsm_blackboard = get_parent().blackboard

func _enter() -> void:
	play_animation("Block")
	play_sound("Block")

func _update(delta: float) -> void:
	_handle_input(hsm_blackboard, 0.)

	if !agent.anim_player.is_playing():
		dispatch(EVENT_FINISHED)
	
