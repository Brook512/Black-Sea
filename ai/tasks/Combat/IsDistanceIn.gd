@tool
extends BTCondition

## InRange condition checks if the agent is within a range of target,
## defined by distance_min and distance_max.
## Returns SUCCESS if the agent is within the defined range;
## otherwise, returns FAILURE.

@export var distance_min: float
@export var distance_max: float
@export var target_var: StringName = &"target"



# Called to generate a display name for the task.
func _generate_name() -> String:
	return "InRange (%d, %d) of %s" % [distance_min, distance_max,
		LimboUtility.decorate_var(target_var)]




# Called when the task is executed.
func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var dist_sq: float = abs(agent.global_position.x-target.global_position.x)
	if dist_sq >= distance_min and dist_sq <= distance_max:
		return SUCCESS
	else:
		return FAILURE
