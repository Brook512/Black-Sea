extends BasicPlayerState
@onready var hsm_blackboard = get_parent().blackboard

func _enter() -> void:
	if agent.is_on_floor():
		play_animation("Jump")
		play_sound("Jump")
		var jump_speed = hsm_blackboard.get_var("jump_speed")
		agent.velocity.y -= jump_speed

func _update(delta: float) -> void:
	
	if agent.is_on_floor():
		dispatch(EVENT_FINISHED)
	elif agent.velocity.y >= 0: 
		play_animation("Fall")
		_gravity()
	else:
		_gravity()



func _gravity():
	agent.velocity.y +=hsm_blackboard.get_var("gravity")
