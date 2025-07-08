class_name AttackState extends BasicPlayerState

@onready var attack_timer = Timer.new()
@onready var hsm_blackboard = get_parent().blackboard

func _setup() -> void:
	attack_timer.wait_time = 0.2
	attack_timer.one_shot = true
	add_child(attack_timer)

func _enter() -> void:
	var result = _check_energy(hsm_blackboard.get_var("attack_cost"),hsm_blackboard)
	if result:
		play_animation("Attack1")
		play_sound("Attack")
		attack_timer.start()
	else:
		dispatch(EVENT_FINISHED)
	
	
func _update(delta: float) -> void:
	_handle_input(hsm_blackboard, 0.)
	if !agent.shadow_player.is_playing():
		agent.shadow.visible=false
		

	if Input.is_action_just_pressed("attack") and attack_timer.is_stopped():
		var result = _check_energy(hsm_blackboard.get_var("attack_cost"),hsm_blackboard)
		attack_timer.start()
		if agent.anim_player.is_playing() and result:
			var current_anim = agent.anim_player.current_animation
			agent.shadow.visible=true
			agent.shadow_player.play(current_anim)
			if current_anim.ends_with("Attack1"):
				play_animation("Attack2")
				play_sound("Attack")
			else:
				play_animation("Attack1")
				play_sound("Attack")

	elif attack_timer.is_stopped() and !agent.anim_player.is_playing():
		dispatch(EVENT_FINISHED)
		

	
