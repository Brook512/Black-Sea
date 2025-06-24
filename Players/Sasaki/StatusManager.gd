class_name StatusManager
extends Node2D
enum State {
	Normal,Invicible
}
var current_state:State = State.Normal
#var last_state:State = State.IDLE

var max_stamina = 10.
var max_health = 5.

var _health = max_health 
var _stamina = max_stamina
var health_recover_speed = 0.01
var stamina_recover_speed = 0.1
var character
@export var attack_cost = 2.
@export var dodge_cost = 1.
@export var statmina_recover_speed = 1.
@export var attack_damage = 2.

var invicible_timer = Timer.new()


func add_health(heal_num):
	_health+=heal_num

func hurt_health(heal_num):
	_health-=heal_num

func _ready() -> void:
	character = get_parent()
	add_child(invicible_timer)
	invicible_timer.one_shot = true
	
	invicible_timer.timeout.connect(_on_invincibility_timeout)
	if character:
		#character.idle_signal.connect(_on_idle)
		character.attack_signal.connect(_on_attack)
		character.hurt_signal.connect(_on_hurt)
		character.dodge_signal.connect(_on_dodge)
	else:
		push_error("Parent is not a PlayerCharacter")
		return

func _on_attack(dir):
	_stamina -= attack_cost
	_stamina = clamp(_stamina, 0.0, max_stamina)

func _on_dodge(dir):
	_stamina -= dodge_cost
	_stamina = clamp(_stamina, 0.0, max_stamina)
	activate_invicible(0.3)
	
func _on_hurt(damage):
	_health -= damage
	_health = clamp(_health, 0.0, max_health)
	activate_invicible(1.0)
	
func _recover():
	_health += health_recover_speed
	_stamina += stamina_recover_speed
	_health = clamp(_health, 0.0, max_health)
	_stamina = clamp(_stamina, 0.0, max_stamina)
	
	
func _process(delta: float) -> void:
	_recover()
		

func activate_invicible(invicible_time):
	if current_state==State.Normal:
		invicible_timer.start(invicible_time)
	if character.hurt_signal.is_connected(_on_hurt):
		character.hurt_signal.disconnect(_on_hurt)

# === 计时器回调 ===
func _on_invincibility_timeout():
	# 无敌状态结束
	current_state = State.Normal
	# 重新连接伤害信号
	character.hurt_signal.connect(_on_hurt)
