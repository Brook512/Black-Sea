@tool
extends BTAction
var tired_timer = 0.

func _enter() -> void:
	agent.velocity.x = 0
	agent.tired_spark.emitting=true

func _tick(delta: float) -> Status:
	return SUCCESS
