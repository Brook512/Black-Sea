@tool
extends BTAction
var dodge_speed = 20
var player_var: StringName = &"target"
var attack_timer: float = 0

func _tick(delta: float) -> Status:
	agent.velocity.x = 0
	var player = blackboard.get_var(player_var)
	
	if !player:
		return FAILURE
	
	var player_pos = player.global_position
	var direction_x = sign(player_pos.x - agent.global_position.x)
	agent.velocity.x = -direction_x * dodge_speed
	
	return SUCCESS
