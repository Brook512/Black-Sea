extends BasicPlayerState
var target_velocity_x:float
var _dir = 0.
var facing_vec: float = 1.0  # 默认为朝右
@onready var hsm_blackboard = get_parent().blackboard

func _enter() -> void:
	play_sound("Run")
	
	

func _update(delta: float) -> void:
	moving()
	play_animation("Run")
	
func moving():
	_handle_input(hsm_blackboard)
	if agent.velocity.x==0:
		dispatch(EVENT_FINISHED)
	#agent.velocity.x = lerp(agent.velocity.x, target_velocity_x, 100)



	
