extends Area2D


@export var attack_damage := 1
@export var clash_window := 0.6        # 判定窗口（秒）

var _pending_enemy: Area2D = null      # 等待结算伤害的敌人
var _window_timer = Timer.new()
var _damage_timer = Timer.new()
var _slow_timer = Timer.new()


var enemy 
var _is_counter:bool = false
var _prepared_player=null
var _attacked:bool = false
var particlea:CPUParticles2D
var _ding:bool


@onready var self_collision = $AttackCollision
#var _emitted:bool = false
## --------------------------------------------------
## 初始化：连接进入 / 退出信号
## --------------------------------------------------
func _ready() -> void:
	enemy = get_parent()
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	_window_timer.one_shot = true
	_window_timer.wait_time = clash_window
	add_child(_window_timer)
	_damage_timer.one_shot = true
	_damage_timer.wait_time = 0.2
	add_child(_damage_timer)
	_slow_timer.one_shot = true
	_slow_timer.wait_time = 1.5
	add_child(_slow_timer)

	
func _physics_process(delta: float) -> void:
	if enemy.anim_player.current_animation.begins_with("Attack") or enemy.shadow_player.current_animation.begins_with("Attack"):
		if _window_timer.is_stopped():
			_window_timer.start()

	if !_attacked and _prepared_player and !_is_counter and _damage_timer.is_stopped():
		_prepared_player.take_damage(
			enemy.combat_state.blackboard.get_var("AttackDamage"),
			enemy.combat_state.blackboard.get_var("FacingVec")
		)
		_attacked = true
		
	if _window_timer.time_left>0 and _ding:
		enemy.spark.emitting=true
		_is_counter = true
		_attacked=false
		_slow_timer.start()
		enemy.cam.trigger_screen_shake()
	else:
		_is_counter  = false
	
	if _window_timer.time_left<0.2:
		_ding = false
		
	_is_slow()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		_prepared_player = area
		_damage_timer.start()
		
	if area.is_in_group("player_attack"):
		_ding = true
		
	
func _on_area_exited(area:Area2D) -> void:
	if area.is_in_group("player"):
		_prepared_player = null
		_attacked=false
		_is_counter=false

func _is_slow():
	if _slow_timer.time_left>0:
		enemy.anim_player.speed_scale = 0.3
		enemy.shadow_player.speed_scale = 0.3
		if enemy.Player:
			enemy.Player.attack_state.enable_cons_attack = true
		if enemy.slow_effect:
			enemy.slow_effect.visible = true
	else:
		enemy.anim_player.speed_scale = 1.
		enemy.shadow_player.speed_scale = 1.
		if enemy.Player:
			enemy.Player.attack_state.enable_cons_attack = false
		if enemy.slow_effect:
			enemy.slow_effect.visible = false
		
