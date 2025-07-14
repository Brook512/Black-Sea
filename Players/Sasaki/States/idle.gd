extends BasicPlayerState
var health
var energy
@onready var hsm_blackboard = get_parent().blackboard
var recover_time = 0.



func _update(delta: float) -> void:
	play_animation("Idle")
	agent.velocity.x = 0
	agent.velocity.y = 0
	recover_time += delta
	if recover_time>1.:
		_recover(hsm_blackboard)
		recover_time =0.
		#print(energy)
	
	

	
