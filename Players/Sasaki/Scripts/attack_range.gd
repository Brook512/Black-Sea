extends Area2D
@onready var player: Sasaki = get_parent()

@export var attack_damage := 1
@export var clash_window := 0.2        # 判定窗口（秒）


var _window_timer: SceneTreeTimer = null
var _prepare_enemy = null
var _attacked:bool = false
## --------------------------------------------------
## 初始化：连接进入 / 退出信号
## --------------------------------------------------
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _physics_process(delta: float) -> void:
	if !_attacked and _prepare_enemy:
		_prepare_enemy.take_damage(attack_damage, player.hsm.blackboard.get_var("facing_vec"))
		_attacked=true

## --------------------------------------------------
## 进入碰撞体：区分敌人与敌方攻击
## --------------------------------------------------
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		_prepare_enemy = area

func _on_area_exited(area:Area2D) -> void:
	if area.is_in_group("enemy"):
		_prepare_enemy = null
		_attacked=false
		
