extends CharacterBody2D
class_name BasicEnemy

# 配置玩家变量
@export var jump_speed: float = 270.0
@export var move_speed = 100


# 配置默认变量
@export var acceleration: float = 10.

@export var gravity: float = 1000.0  # 增加重力值，使跳跃感觉更自然
@export var terminal_velocity: float = 1000.0
@export var air_control_factor: float = 0.5  # 空中移动控制系数
@export var jump_buffer_time: float = 0.1  # 跳跃缓冲时间
@export var coyote_time: float = 0.1  # 离地边缘时间
var enable_move_siganl: bool = true
var facing_vec: float = 1.0  # 默认为朝右

@onready var anim_sprite = $EnemySprite
@onready var status = $Status

var in_attack_stage = false
var is_jumping = false
var last_on_floor_time: float = 0.0  # 记录最后在地面的时间
var jump_requested: bool = false
var jump_request_time: float = 0.0


var _dir: float = 0.  # 当前输入方向

# 状态枚举和变量
enum State { IDLE, MOVE, ATTACK, JUMP, FALL, HURT }
var current_state: State = State.IDLE
var previous_state: State = State.IDLE

# === 信号 ===
signal move_signal(facing_vec1: float)
signal attack_signal(facing_vec1: float)
signal idle_signal(facing_vec1: float)
signal hurt_signal(facing_vec1: float, damage: float)

signal jump_signal(facing_vec1: float)
signal fall_signal(facing_vec1: float)
signal dialogue_signal()

#signal landed()

func _ready():
	velocity = Vector2.ZERO
	_change_state(State.IDLE)

func _physics_process(delta):
	_dir = Input.get_axis("move_left", "move_right")
	if abs(_dir) > 0.01:
		facing_vec = sign(_dir)  # 确保方向为 -1 或 1
	
	# 更新时间相关变量
	last_on_floor_time += delta
	if is_on_floor():
		last_on_floor_time = 0.0  # 重置离地时间
	
	# 处理跳跃缓冲
	jump_request_time += delta
	if Input.is_action_just_pressed("jump"):
		jump_requested = true
		jump_request_time = 0.0
	
	# 基础功能
	_update_state()
	_update_movement(delta)
	_update_actions(delta)
	_apply_gravity(delta)
	
	# 移动并应用物理
	move_and_slide()
	


#region 移动功能

func _update_movement(delta):
	# 空中控制系数 (在地面时为1.0，空中时为较小的值)
	var control_factor = 1.0 if is_on_floor() else air_control_factor
	
	# 目标水平速度
	var target_velocity_x = 0.0
	
	# 应用输入
	if abs(_dir) > 0.1 and enable_move_siganl and !in_attack_stage:
		target_velocity_x = _dir * move_speed * control_factor
	

	# 攻击中减少移动能力
	elif in_attack_stage:
		target_velocity_x = target_velocity_x * 0.4
	
	# 插值平滑处理
	velocity.x = lerp(velocity.x, target_velocity_x, acceleration * delta)
	
	# 终端速度限制
	velocity.y = clamp(velocity.y, -terminal_velocity, terminal_velocity)

func _update_actions(delta):
	# 检测攻击输入
	if Input.is_action_just_pressed("attack"):
		in_attack_stage = true
		emit_signal("attack_signal", facing_vec)
	
	# 处理跳跃输入
	_handle_jump()


func _handle_jump():
	# 在地面或离地边缘时间内，且有跳跃请求
	if (is_on_floor() or last_on_floor_time < coyote_time) and jump_requested:
		# 普通跳跃
		if !is_jumping:
			velocity.y = -jump_speed
			is_jumping = true
			_change_state(State.JUMP)
		
		jump_requested = false

func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
#endregion

#region 管理记录当前状态
func _update_state():
	# 优先处理状态锁定情况
	
	if in_attack_stage:
		_change_state(State.ATTACK)
		return
	
	# 基于物理的状态检测
	if not is_on_floor():
		if velocity.y < 0:  # 上升中
			_change_state(State.JUMP)
		else:  # 下落中
			_change_state(State.FALL)
	else:
		if abs(_dir) > 0.1 and enable_move_siganl:
			_change_state(State.MOVE)
		else:
			_change_state(State.IDLE)
			
func _change_state(new_state: State):
	if new_state == current_state: 
		return
	
	previous_state = current_state
	current_state = new_state
	
	match new_state:
		State.IDLE:
			emit_signal("idle_signal", facing_vec)
		State.MOVE:
			emit_signal("move_signal", facing_vec)
		State.ATTACK:
			emit_signal("attack_signal", facing_vec)
		State.JUMP:
			emit_signal("jump_signal", facing_vec)
		State.FALL:
			emit_signal("fall_signal", facing_vec)
		State.HURT:
			emit_signal("hurt_signal", facing_vec, status.attack_damage)
#endregion

# 重置状态的回调
func _attack_end():
	in_attack_stage = false


func _on_attack_range_area_entered(hurtarea: Area2D) -> void:
	if hurtarea.owner == owner:
		return
	hurtarea.owner.take_damage(status.attack_damage)

func _on_dialogue_range_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
