@tool
extends BTAction

var max_energy = null

# Called to generate a display name for the task.
func _generate_name() -> String:
	return "Recover Energy" 

func _enter() -> void:
	max_energy = blackboard.get_var("MaxEnergy")
	blackboard.set_var("Energy", max_energy)

func _tick(_delta: float) -> Status:
	if max_energy:
		return SUCCESS
	else:
		return FAILURE
