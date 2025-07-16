extends LimboState
@onready var anim_player:AnimationPlayer 

func _setup() -> void:
	anim_player = agent.anim_player
func _enter():
	agent.set_physics_process(false)
	agent.anim_player.play("Hurt")
	agent.blood_spark.emitting = true

func _update(_delta: float) -> void:
	if !agent.anim_player.is_playing():
		dispatch(EVENT_FINISHED)
	
