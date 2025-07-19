extends BasicPlayerState
var easy_time=0.
func _enter():
	agent.set_physics_process(false)
	play_animation("Death")
	play_sound("GameOver")
	
func _update(delta: float) -> void:
	easy_time+=delta
	if easy_time>=5.0:
		GlobalSceneManager.change_state(GlobalSceneManager.States.Menu)
