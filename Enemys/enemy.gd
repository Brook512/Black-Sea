extends CharacterBody2D
#class_name BasicEnemy
@onready var hsm: LimboHSM = $EnemyHSM
@onready var anim_player:AnimationPlayer = $EnemyAnimationPlayer
@onready var shadow_player:AnimationPlayer = $ShadowPlayer

@onready var shadow_sprite = $ShadowSprite
@onready var normal_state: BTState = $EnemyHSM/NormalState
@onready var dialogue_state: LimboState = $EnemyHSM/DialogueState
@onready var combat_state: BTState = $EnemyHSM/CombatState
@onready var death_state: LimboState = $EnemyHSM/DeathState

@onready var attack_collision = $AttackRange/AttackCollision
@onready var hurt_body = $HurtBody/CollisionShape2D
@onready var blood_spark:CPUParticles2D = $BloodSpark
@onready var tired_spark:CPUParticles2D = $TiredSpark
@onready var spark:CPUParticles2D = $Spark
@onready var perfect_spark:CPUParticles2D = $PerfectSpark

@onready var invincible_timer = Timer.new()

@export var Player:Sasaki
var last_sign =-1.

func _ready() -> void:
	_init_state_machine()
	invincible_timer.wait_time=0.1
	invincible_timer.one_shot = true
	add_child(invincible_timer)
	
	if GlobalSceneManager.current_state == GlobalSceneManager.States.Combat:
		hurt_body.disabled = true
		hsm.dispatch(&"TriggerCombat")
	else:
		hurt_body.disabled = false
		combat_state.EVENT_FINISHED
	# TODO
	hurt_body.disabled = true
	
func _init_state_machine() -> void:
	hsm.add_transition(normal_state, dialogue_state, &"TriggerDialogue")
	hsm.add_transition(dialogue_state, normal_state, dialogue_state.EVENT_FINISHED)
	hsm.add_transition(hsm.ANYSTATE, combat_state, &"TriggerCombat")
	hsm.add_transition(hsm.ANYSTATE, death_state, &"TriggerDeath")

	hsm.initial_state = normal_state
	hsm.initialize(self)
	hsm.set_active(true)

func _physics_process(_delta: float) -> void:
	if !is_on_floor():
		_gravity()
	move_and_slide()

	_is_death()
	_is_invincible()
	if hsm.get_active_state()!=combat_state:
		invincible_timer.start()

func face_dir(dir: float) -> void:
	# 如果没有方向输入，直接返回
	if abs(dir) < 0.01:
		return

	var target_sign = sign(dir)          # -1  or  +1
	# 仅在朝向需要改变时执行
	combat_state.blackboard.set_var("FacingVec", target_sign)
	if target_sign != last_sign:
		self.scale.x = -self.scale.x               # 翻转角色
		tired_spark.position.x = -tired_spark.position.x
		blood_spark.position.x = -tired_spark.position.x
		spark.position.x = -tired_spark.position.x
		spark.direction.x = -tired_spark.direction.x
		last_sign = target_sign


func _on_player_want_fight():
	hsm.dispatch(&"TriggerCombat")


func _gravity():
	velocity.y += 20

func _is_death():
	if combat_state.blackboard.get_var("Health") == 0:
		hsm.dispatch(&"TriggerDeath")
		
func _is_invincible():
	if invincible_timer.time_left>0:
		hurt_body.disabled = true
	else:
		hurt_body.disabled = false	
