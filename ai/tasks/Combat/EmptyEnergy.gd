@tool
extends BTAction

# Called to generate a display name for the task.
func _generate_name() -> String:
	return "Empty Energy" 

func _enter() -> void:
	blackboard.set_var("Energy", 0)
func _tick(delta: float) -> Status:
	return SUCCESS
