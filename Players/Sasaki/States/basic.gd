class_name BasicPlayerState
## 每个状态都有几个基本动作：播放动画、音乐、改变状态、
extends LimboState

func gravity(delta: float) -> void:
	"""基本物理效果"""
	# 基础物理更新示例：应用重力
	if agent and agent.is_on_floor() == false:
		agent.velocity.y += blackboard.get_var("Gravity") * delta

# 动画控制方法 -----------------------------------------------------
func play_animation(anim_name: String) -> void:
	"""播放指定动画"""
	#emit_signal("animation_triggered", anim_name)
	var anim_player = _find_animation_player("Basic")
	
	if anim_player and anim_player.has_animation(anim_name):
		if blackboard.get_var("facing_vec") == 1:
			anim_player.play(anim_name)
		else:
			anim_player.play("Left"+anim_name)

# 音频控制方法 -----------------------------------------------------
func play_sound(sound_id: String) -> void:
	"""播放音效/音乐"""
	#emit_signal("sound_triggered", sound_id)
	var audio_player = _find_audio_player()
	if audio_player:
		audio_player.stream = load_sound_resource(sound_id)
		audio_player.play()
		
func load_sound_resource(sound_id: String) -> Resource:
	"""加载音频资源（需在子类中实现资源映射）"""
	# 示例资源加载逻辑
	match sound_id:
		"Background": return preload("res://Sounds/8BIT/background theme.mp3")
		"Attack": return preload("res://Sounds/Attack.mp3")
		"Ding": return preload("res://Sounds/Ding.mp3")
		"Block": return preload("res://Sounds/8BIT/Block.wav")
		"Win": return preload("res://Sounds/8BIT/Success.wav")
		"Dodge": return preload("res://Sounds/8BIT/Dodge.wav")
		"Hurt": return preload("res://Sounds/8BIT/Hit.wav")
		"Jump": return preload("res://Sounds/8BIT/Jump.wav")
		"Select": return preload("res://Sounds/8BIT/select.wav")
		"GameOver": return preload("res://Sounds/8BIT/Game Over.wav")
		"CombatTheme": return preload("res://Sounds/8BIT/combat theme.mp3")
		"Run": return preload("res://Sounds/Run.mp3")
		"Charging": return preload("res://Sounds/8BIT/Charging.wav")
		"GameOver": return preload("res://Sounds/8BIT/Game Over.wav")
		_: return null
		
func load_shader_resource(shader_id: String):
	match shader_id:
		"Hurt": return preload("res://Players/Shaders/PlayerOutline.gdshader")

func _find_animation_player(player_name) -> AnimationPlayer:
	"""获取场景中的动画组件"""
	if agent:
		if player_name=="Basic":
			return agent.get_node("AnimationPlayer") 
		elif player_name == "Shadow":
			return agent.get_node("ShadowPlayer") 
	return null

func _find_audio_player() -> AudioStreamPlayer:
	"""获取场景中的音频组件"""
	return agent.get_node("EffectAudioPlayer") if agent else null


func _handle_input(hsm_blackboard, control_factor=1.):
	var _dir = Input.get_axis("move_left", "move_right")
	if abs(_dir) > 0.1:
		var facing_vec = sign(_dir)  # 确保方向为 -1 或 1
		hsm_blackboard.set_var("facing_vec",facing_vec)
		var speed = hsm_blackboard.get_var("speed")
		agent.velocity.x = speed * facing_vec * control_factor
	else:
		agent.velocity.x = 0

func _check_energy(energy_cost, hsm_blackboard):
	var current_energy = hsm_blackboard.get_var("energy")
	if  current_energy < energy_cost:
		return false
	else:
		current_energy -= energy_cost
		hsm_blackboard.set_var("energy",current_energy)
		return true

func _check_health(health_cost, hsm_blackboard):
	var current_health = hsm_blackboard.get_var("health")
	if  current_health< health_cost:
		return false
	else:
		current_health -= health_cost
		hsm_blackboard.set_var("health",current_health)
		return true

#func _setup() -> void:
	#pass
#func _enter() -> void:
	#pass
#func _update(delta: float) -> void:
	#pass
#func _exit() -> void:
	#pass
