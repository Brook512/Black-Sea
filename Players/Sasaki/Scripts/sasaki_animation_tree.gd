extends AnimationTree

# ============================================================
#  Player Animation Controller (Godot 4)
# ============================================================

var state_machine : AnimationNodeStateMachinePlayback
var jump_machine : AnimationNodeStateMachinePlayback

var block_rules :Dictionary

# -----------------------------------------------------------------------------
#  自定义信号
# -----------------------------------------------------------------------------
signal attack_end_signal
signal dodge_end_signal

# -----------------------------------------------------------------------------
#  变量与常量
# -----------------------------------------------------------------------------
const SIGNAL_WINDOW := 1000         # 组合检测窗口 (ms)
var last_record_time = Time.get_ticks_msec()
var blend_position_value : float = 0.0
@onready var character: Sasaki
@export var dodge_duration = 1.
# 使用栈存储信号 (只保留最近的信号，如果类型相同则忽略)
#var signal_stack : Array = []      # 存储 SignalEvent 栈
var current_signal:String = "fall"

# -----------------------------------------------------------------------------
#  计时器系统
# -----------------------------------------------------------------------------
var attack_timer : Timer = Timer.new()
var attack_times: int = 0
var dodge_timer  : Timer = Timer.new()
var combo_window = [0.6,0.3]
# -----------------------------------------------------------------------------
#  _ready – 初始化
# -----------------------------------------------------------------------------
func _ready():
	# 初始化计时器
	attack_timer.wait_time = 0.8
	attack_timer.one_shot  = true
	add_child(attack_timer)

	dodge_timer.wait_time = dodge_duration
	dodge_timer.one_shot  = true
	add_child(dodge_timer)

	# 获取 AnimationTree & AnimationPlayer
	state_machine = get("parameters/StateMachine/playback")
	jump_machine = get("parameters/StateMachine/JumpStateMachine/playback")

	if !state_machine:
		push_error("Failed to get state machine playback")
		return

	# 连接父节点发射的动作信号
	character = get_parent()
	if character:
		character.attack_signal.connect(_on_attack_received)
		character.move_signal.connect(_on_move_received)
		character.dodge_signal.connect(_on_dodge_received)
		character.jump_signal.connect(_on_jump_received)
		character.idle_signal.connect(_on_idle_received)
		character.fall_signal.connect(_on_fall_received)
		character.hurt_signal.connect(_on_hurt_received)
	else:
		push_error("Parent is not a PlayerCharacter")
		return

	active = true
	state_machine.start("Idle")

# -----------------------------------------------------------------------------
#  信号记录系统 (栈实现)
# -----------------------------------------------------------------------------
func _record_signal(target_signal: String) -> void:
	current_signal = target_signal
	if current_signal == "attack" and attack_times % 3==0:
		attack_times += 1
	if attack_timer.time_left< combo_window[0] and attack_timer.time_left> combo_window[1] and attack_times%3 == 1:
		attack_times +=1
		
# -----------------------------------------------------------------------------
#  Blend-Position 控制
# -----------------------------------------------------------------------------
func set_blend_position(direction:float,state) -> void:
	blend_position_value = direction
	if state in ["Idle", "Run", "Attack1", "Attack2", "Dodge"]:
		var path := "parameters/StateMachine/%s/blend_position" % state
		set(path, direction)
		
	elif state == "Jump":
		for s in ["JumpStateMachine/Jump","JumpStateMachine/JumpAttack","JumpStateMachine/Fall","JumpStateMachine/JumpDodge"]:
			var path := "parameters/StateMachine/%s/blend_position" % s
			set(path, direction)
# -----------------------------------------------------------------------------
#  信号接收器
# -----------------------------------------------------------------------------
func _on_move_received(direction:float):
	set_blend_position(direction, "Run")
	_record_signal("move")

func _on_idle_received(direction:float):
	set_blend_position(direction, "Idle")
	_record_signal("idle")

func _on_jump_received(direction:float):
	set_blend_position(direction, "Jump")
	_record_signal("jump")

func _on_attack_received(direction:float):
	if attack_times%3==0:
		set_blend_position(direction, "Attack1")
		set_blend_position(direction, "Attack2")
	_record_signal("attack")

func _on_dodge_received(direction:float):
	set_blend_position(direction, "Dodge")
	_record_signal("dodge")
	
func _on_fall_received(direction:float):
	set_blend_position(direction, "Jump")
	_record_signal("fall")
	
func _on_hurt_received(direction:float, damage:float):
	set_blend_position(direction, "Hurt")
	_record_signal("hurt")
# -----------------------------------------------------------------------------
#  动画状态执行 (修复版)
# -----------------------------------------------------------------------------
func execute_animation_state() -> void:
	_handle_single_signal(current_signal)

# 处理单个信号
func _handle_single_signal(signal_name: String) -> void:
	match signal_name:
		"hurt":
			if _can_transition_to("Hurt"):
				state_machine.travel("Hurt")
		"attack":
			if _can_transition_to("Attack1"):
				print("触发Attack1动画")
				state_machine.travel("Attack1")
				attack_timer.start()
	
			elif _can_transition_to("Attack2"):
				print("触发Attack2动画")
				state_machine.travel("Attack2")
				attack_timer.start()
				
		"dodge":
			if _can_transition_to("Dodge"):
				print("触发Dodge动画")
				#set("parameters/TimeScale",3.0)
				
				state_machine.travel("Dodge")
				dodge_timer.start()
		"jump":
			if _can_transition_to("Jump"):
				print("触发Jump动画")
				state_machine.travel("JumpStateMachine")
				jump_machine.travel("Jump")
		"move":
			if _can_transition_to("Run"):
				#print("触发Run动画")
				state_machine.travel("Run")
		"idle":
			if _can_transition_to("Idle"):
				state_machine.travel("Idle")
		"fall":
			if _can_transition_to("Fall"):
				state_machine.travel("JumpStateMachine")
				jump_machine.travel("Fall")
		

# -----------------------------------------------------------------------------
#  状态过渡安全检查 (优化版)
# -----------------------------------------------------------------------------
func _can_transition_to(state:String) -> bool:
	var current := state_machine.get_current_node()
	var attack_combos = int(attack_times / 3)
	# 动态规则映射，便于扩展
	block_rules = {
		"Attack1": attack_combos%2==0 and attack_timer.time_left<0.3 and current !=state,
		"Attack2": attack_combos%2==1 and attack_timer.time_left<0.3 and current !=state,
		"JumpAttack": not character.is_on_floor() and attack_timer.time_left < 0.1,
		"Dodge": dodge_timer.is_stopped(),
		"JumpDodge": not character.is_on_floor() and dodge_timer.time_left < 0.1,
		"Jump": not character.is_on_floor(),
		"Fall": not character.is_on_floor(),
		"Idle": true,
		"Run": true,
		"Hurt": true
	}
	if attack_timer.time_left <0.3 and attack_timer.time_left >0.25:
		pass
	#var a = attack_combos%2

	
	# 添加调试输出
	if block_rules.has(state) and block_rules[state]:
		return true
	else:
		#print("禁止转换: ", current, " -> ", state)
		return false

# -----------------------------------------------------------------------------
#  结束信号发射
# -----------------------------------------------------------------------------
func handle_end_signals() -> void:
	#print(attack_times % 3)
	if attack_timer.time_left < 0.23 and (attack_times % 3)==2:
		attack_times+=1
	elif attack_timer.time_left < 0.2 and 0.01<attack_timer.time_left and (attack_times % 3)!=2:
		#print("发射攻击结束信号")
		emit_signal("attack_end_signal")
		attack_times=0


	if dodge_timer.time_left > 0 and dodge_timer.time_left < 0.05:
		#print("发射闪避结束信号")
		emit_signal("dodge_end_signal")
		set("parameters/TimeScale",2.0)
		

# -----------------------------------------------------------------------------
#  物理帧驱动
# -----------------------------------------------------------------------------
func _physics_process(delta:float) -> void:
	execute_animation_state()
	handle_end_signals()
