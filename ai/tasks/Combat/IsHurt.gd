@tool
extends BTCondition


# Called when the task is executed.
func _tick(_delta: float) -> Status:
	if agent.invincible_timer.time_left > 0:
		return SUCCESS
	else: 
		return FAILURE
