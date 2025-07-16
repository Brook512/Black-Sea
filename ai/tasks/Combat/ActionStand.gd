@tool
extends BTAction

func _enter() -> void:
	agent.velocity.x = 0

func _tick(delta: float) -> Status:
	return SUCCESS

	
