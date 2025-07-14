@tool
extends BTCondition

@export var distance_min: float
@export var distance_max: float


# Called to generate a display name for the task.
func _generate_name() -> String:
	return "Is Energy Empty?" 


# Called when the task is executed.
func _tick(_delta: float) -> Status:
	var energy = blackboard.get_var("Energy", null)
	if energy > 0:
		return FAILURE
	else:
		return SUCCESS
