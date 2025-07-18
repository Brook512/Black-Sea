@tool
extends BTAction
class_name BTChasePlayer

# ---------- 可调参数 / Tunables ----------
var player_var  : StringName = &"target"
const SLOW_RANGE    := 110.0      # 进入缓速区的阈值 / begin slow zone
const ATTACK_RANGE  := 92.0       # 攻击距离 / attack range
const MOVE_TIME     := 0.8        # 每次前进持续 / move duration (s)
const STOP_TIME     := 0.8        # 每次停顿持续 / pause duration (s)
const SLOW_FACTOR   := 0.4        # 缓速系数 / slow speed factor (40 %)

# ---------- 内部状态 / Internal state ----------
var _timer   : float = 0.0        # 定时器 / timer
var _moving  : bool  = true       # 当前是否在移动 / currently moving

func _enter() -> void:
	# 当节点首次运行时重置状态 (called by LimboAI)
	_timer  = 0.0
	_moving = true

func _tick(delta: float) -> Status:
	var enemy : CharacterBody2D = get_agent()
	var player = blackboard.get_var(player_var)
	if !player:                         # 没有玩家对象
		return FAILURE
	
	var player_pos : Vector2 = player.position
	var dist_x     : float   = player_pos.x - enemy.global_position.x
	var distance   : float   = abs(dist_x)
	
	# ------------ 1️⃣ 进入攻击距离 → SUCCESS ------------
	if distance < ATTACK_RANGE:
		blackboard.set_var("player_in_attack_range", true)
		enemy.velocity.x = 0
		enemy.move_and_slide()
		enemy.anim_player.play("Idle")
		return FAILURE
	
	# ------------ 2️⃣ 追击逻辑 ------------
	blackboard.set_var("player_in_attack_range", false)
	
	var base_speed : float = blackboard.get_var("Speed", 120.0)
	var dir_x      : float = sign(dist_x)
	
	# 2a. 距离 > 110 px —— 正常追击
	if distance > SLOW_RANGE:
		enemy.velocity.x = dir_x * base_speed
		enemy.velocity.y = 0
		enemy.anim_player.play("Run")
		
		enemy.move_and_slide()
		return RUNNING
	
	# 2b. 92–110 px —— 缓速 + 走停节奏
	_timer += delta
	
	if _moving:
		enemy.velocity.x = dir_x * base_speed * SLOW_FACTOR
		if _timer >= MOVE_TIME:
			_moving = false
			enemy.anim_player.play("Idle")
			_timer  = 0.0
	else:    # 停顿阶段
		enemy.velocity.x = 0
		if _timer >= STOP_TIME:
			enemy.anim_player.play("Run")
			
			_moving = true
			_timer  = 0.0
	
	enemy.velocity.y = 0
	enemy.move_and_slide()
	return RUNNING
