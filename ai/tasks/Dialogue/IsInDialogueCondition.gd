class_name IsInDialogueCondition
extends BTCondition

func _tick(_delta: float) -> Status:
	return SUCCESS if get_blackboard().get_var("is_in_dialogue") else FAILURE
