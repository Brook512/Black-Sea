extends CharacterBody2D
#class_name BasicEnemy
@onready var hsm: LimboHSM = $EnemyHSM
@onready var anim_player = $EnemyAnimationPlayer
@onready var normal_state: BTState = $EnemyHSM/NormalState
@onready var dialogue_state: LimboState = $EnemyHSM/DialogueState
@onready var combat_state: BTState = $EnemyHSM/CombatState
@onready var hurt_state: LimboState = $EnemyHSM/HurtState
@onready var death_state: LimboState = $EnemyHSM/DeathState

@onready var attack_collision = $AttackRange/AttackCollision

@export var Player:Sasaki
var last_sign =-1.

func _ready() -> void:
	_init_state_machine()
	
func _init_state_machine() -> void:
	hsm.add_transition(normal_state, dialogue_state, &"TriggerDialogue")
	hsm.add_transition(dialogue_state, normal_state, dialogue_state.EVENT_FINISHED)
	hsm.add_transition(combat_state, normal_state, combat_state.EVENT_FINISHED)
	hsm.add_transition(dialogue_state, combat_state, &"TriggerCombat")
	
	hsm.add_transition(dialogue_state, combat_state, &"TriggerCombat")
	# TODO
	hsm.add_transition(normal_state, combat_state, &"TriggerCombat")
	
	hsm.initial_state = combat_state
	hsm.initialize(self)
	hsm.set_active(true)

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		_gravity()
	move_and_slide()
	if GlobalSceneManager.current_state == GlobalSceneManager.States.Combat:
		hsm.dispatch(&"TriggerCombat")
		
func face_dir(dir: float) -> void:
	# 如果没有方向输入，直接返回
	if abs(dir) < 0.001:
		return

	var target_sign = sign(dir)          # -1  or  +1
	# 仅在朝向需要改变时执行
	if target_sign != last_sign:
		self.scale.x = -self.scale.x               # 翻转角色

		last_sign = target_sign
	#else:
		


	
func _on_player_want_fight():
	hsm.dispatch(&"TriggerCombat")


func _gravity():
	velocity.y += 20
