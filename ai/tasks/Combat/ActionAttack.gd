@tool
extends BTAction

@export var attack_damage_var: StringName = &"attack_damage"
@export var attack_cooldown_var: StringName = &"attack_cooldown"
@export var player_position_var: StringName = &"player_position"

var attack_timer: float = 0

func _tick(delta: float) -> Status:
	agent.velocity.x = 0
	
	return SUCCESS
