@tool
extends BTAction
@export var value:bool

func _enter() -> void:
	#var a =agent.shadow_sprite
	agent.shadow_sprite.visible = value
	
func _tick(delta: float) -> Status:
	return SUCCESS

	
