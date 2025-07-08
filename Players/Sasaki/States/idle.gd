extends BasicPlayerState
var health
var energy
@onready var hsm_blackboard = get_parent().blackboard
var recover_time = 0.

func _enter() -> void:
	health = hsm_blackboard.get_var("health")
	energy = hsm_blackboard.get_var("energy")

func _update(delta: float) -> void:
	play_animation("Idle")
	agent.velocity.x = 0
	agent.velocity.y = 0
	recover_time += delta
	if recover_time>1.:
		_recover()
		recover_time =0.
		#print(energy)
	
	
func _recover():
	health += hsm_blackboard.get_var("health_recover_speed")
	energy += hsm_blackboard.get_var("energy_recover_speed")

	health = clamp(health, 0.0, hsm_blackboard.get_var("max_health"))
	energy = clamp(energy, 0.0, hsm_blackboard.get_var("max_energy"))
	
	hsm_blackboard.set_var("health", health)
	hsm_blackboard.set_var("energy", energy)
	
