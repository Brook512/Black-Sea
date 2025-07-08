extends BasicPlayerState
@onready var hsm_blackboard = get_parent().blackboard

func _enter() -> void:
	play_animation("Hurt")
	play_sound("Hurt")
	_handle_input(hsm_blackboard, 0.)

	
	
func _exit() -> void:
	_handle_input(hsm_blackboard, 0.)
