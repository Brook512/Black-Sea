extends BasicPlayerState
@onready var hsm_blackboard = get_parent().blackboard

#@onready var hurt_material:Material = preload("res://Players/Shaders/HitMaterial.tres")
var rng := RandomNumberGenerator.new()
var new_pos = Vector2(
		rng.randf_range(-5,5),
		rng.randf_range(-10,10)
	)
func _enter() -> void:
	play_animation("Hurt")
	play_sound("Hurt")
	
	agent.blood_spark.position += new_pos
	agent.blood_spark.emitting = true
	agent.invincible()
	

func _update(delta: float) -> void:
	_handle_input(hsm_blackboard, 0.)
	if !agent.anim_player.is_playing():
		dispatch(EVENT_FINISHED)
	if !agent.shadow_player.is_playing():
		agent.shadow.visible=false

func _exit() -> void:
	agent.blood_spark.position -= new_pos
