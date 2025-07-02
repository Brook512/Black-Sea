@tool
extends BTCheckTrigger
@export var TargetState:String

func _tick(float):
	if TargetState==self.variable:
		return SUCCESS
	else:
		return FAILURE
