extends LimboState
@onready var anim_player:AnimationPlayer = agent.anim_player
func _enter():
	agent.set_physics_process(false)
	agent.anim_player.play("Hurt")
