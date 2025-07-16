extends LimboState
@onready var anim_player:AnimationPlayer 

func _setup() -> void:
	anim_player = agent.anim_player

func _enter():
	agent.set_physics_process(false)
	agent.anim_player.play("Death")
