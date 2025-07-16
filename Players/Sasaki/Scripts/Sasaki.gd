extends CharacterBody2D
class_name Sasaki



@onready var hsm: LimboHSM = $SasakiHSM
@onready var idle_state: LimboState = $SasakiHSM/Idle
@onready var dodge_state: LimboState = $SasakiHSM/Dodge

@onready var attack_state: LimboState = $SasakiHSM/Attack
@onready var charging_state: LimboState = $SasakiHSM/Charging
@onready var heavy_attack: LimboState = $SasakiHSM/HeavyAttack

@onready var block_state: LimboState = $SasakiHSM/Block
@onready var hurt_state: LimboState = $SasakiHSM/Hurt
@onready var move_state: LimboState = $SasakiHSM/Move
@onready var jump_state: LimboState = $SasakiHSM/Jump
@onready var death_state: LimboState = $SasakiHSM/Death
@onready var shadow = $SasakiShadow
@onready var shadow_player = $ShadowPlayer
@onready var anim_player = $AnimationPlayer
@onready var sound_player:AudioStreamPlayer2D = $EffectAudioPlayer
@onready var attack_timer = Timer.new()
@onready var invincible_timer = Timer.new()
@onready var hurt_box = $HurtBody/BodyCollision
@onready var blood_spark = $BloodSpark



var HurtMaterial = preload("res://Players/Shaders/HitMaterial.tres")

var attack_window = 0.7
var charging_window = 0.2

func _ready():
	initialization()
	shadow.visible=false
	attack_timer.one_shot = true
	attack_timer.wait_time = 1.
	add_child(attack_timer)
	invincible_timer.one_shot = true
	invincible_timer.wait_time = 0.3
	add_child(invincible_timer)
	
	# 基本移动转换
	

func _physics_process(delta):
	_update_state(delta)
	# 移动并应用物理
	_is_invincible()
	_is_health_empty()
	move_and_slide()

	

func initialization():
	hsm.initial_state = idle_state
	
	hsm.add_transition(charging_state, heavy_attack, charging_state.EVENT_FINISHED)
	hsm.add_transition(attack_state, dodge_state, &"ForceDodge")
	
	
	hsm.add_transition(idle_state, move_state, &"StartMoving")
	hsm.add_transition(idle_state, jump_state, &"JumpPressed")
	hsm.add_transition(idle_state, attack_state, &"Attack")
	hsm.add_transition(idle_state, charging_state, &"Charging")
	hsm.add_transition(idle_state, block_state, &"BlockPressed")
	hsm.add_transition(idle_state, dodge_state, &"DodgePressed")
	hsm.add_transition(idle_state, hurt_state, &"HurtReceived")
	
	
	hsm.add_transition(move_state, idle_state, move_state.EVENT_FINISHED)
	hsm.add_transition(move_state, jump_state, &"JumpPressed")
	hsm.add_transition(move_state, attack_state, &"Attack")
	hsm.add_transition(move_state, charging_state, &"Charging")
	hsm.add_transition(move_state, block_state, &"BlockPressed")
	hsm.add_transition(move_state, dodge_state, &"DodgePressed")
	hsm.add_transition(move_state, hurt_state, &"HurtReceived")
	
	
	hsm.add_transition(jump_state, hurt_state, &"HurtReceived")  # 空中受击
	hsm.add_transition(attack_state, hurt_state, &"HurtReceived")  # 空中受击
	hsm.add_transition(dodge_state, hurt_state, &"HurtReceived")  # 空中受击
	

	hsm.add_transition(jump_state, idle_state, jump_state.EVENT_FINISHED)
	hsm.add_transition(attack_state, idle_state, attack_state.EVENT_FINISHED)
	hsm.add_transition(heavy_attack, idle_state, heavy_attack.EVENT_FINISHED)
	hsm.add_transition(charging_state, idle_state, &"ChargingFailed")
	
	hsm.add_transition(block_state, idle_state, block_state.EVENT_FINISHED)
	hsm.add_transition(hurt_state, idle_state, hurt_state.EVENT_FINISHED)
	hsm.add_transition(dodge_state, idle_state, dodge_state.EVENT_FINISHED)
	
	hsm.add_transition(hsm.ANYSTATE, death_state, &"EmptyHealth")

	
	hsm.blackboard.set_var("speed",100)
	hsm.blackboard.set_var("facing_vec",1)
	hsm.blackboard.set_var("damage",1)
	hsm.blackboard.set_var("health",10)
	hsm.blackboard.set_var("energy",10)
	hsm.blackboard.set_var("max_health",10)
	hsm.blackboard.set_var("max_energy",10)
	
	hsm.blackboard.set_var("acceleration",200)
	hsm.blackboard.set_var("energy_recover_speed",0.4)
	hsm.blackboard.set_var("health_recover_speed",0.1)
	
	hsm.blackboard.set_var("attack_cost",1)
	hsm.blackboard.set_var("dodge_cost",1)
	hsm.blackboard.set_var("gravity",10)
	hsm.blackboard.set_var("jump_speed",200)
	
	hsm.add_event_handler("HurtReceived",_on_hurt_started)
	
	hsm.initialize(self)
	hsm.set_active(true)


func is_attributes_enough(attribute:StringName) -> bool:
	var cost_name = attribute+"_cost"
	if hsm.blackboard.get_var("energy") < hsm.blackboard.get_var(cost_name):
		return false
	else:
		return true

func _update_state(_delta):
	## 控制状态的转换
	if Input.is_action_just_pressed("dodge") and is_attributes_enough("dodge"):
		hsm.dispatch(&"DodgePressed")
	elif Input.is_action_just_pressed("attack") and is_attributes_enough("attack"):
		attack_timer.start()
	elif Input.is_action_just_released("attack") and attack_timer.time_left>attack_window:
		hsm.dispatch(&"Attack")
	elif Input.is_action_pressed("attack") and attack_timer.time_left<attack_window  and attack_timer.time_left > charging_window:
		hsm.dispatch(&"Charging")	
	elif Input.is_action_just_released("attack") and attack_timer.time_left > charging_window:
		hsm.dispatch(&"ChargingFailed")

	
	# 基于物理的状态检测
	if Input.is_action_just_pressed("jump") or !is_on_floor():
		hsm.dispatch(&"JumpPressed")
		#print(is_on_floor())

	else:
		if abs(Input.get_axis("move_left", "move_right")) > 0.1 :
			hsm.dispatch(&"StartMoving")
	
func invincible(wait_time=0.3):
	invincible_timer.start(wait_time)

func _is_invincible():
	if invincible_timer.time_left>0:
		material= HurtMaterial
		hurt_box.disabled = true
	else:
		material= null
		hurt_box.disabled = false
		
		
#func _gravity():
	#velocity.y += hsm.blackboard.get_var("gravity")
	#pass

func _on_hurt_started(cargo = null) -> bool:
	var health = hsm.blackboard.get_var("health")
	health -= cargo
	hsm.blackboard.set_var("health",health)
	return false

func _is_health_empty():
	if hsm.blackboard.get_var("health") <=0:
		hsm.dispatch(&"EmptyHealth")
