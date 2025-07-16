extends Area2D

@export var trap_damage=1
var current_collision_area: Area2D
var current_body
func _ready() -> void:
	area_entered.connect(_on_collision)
	area_exited.connect(_empty)

func _physics_process(_delta: float) -> void:
	if current_collision_area:
		if current_collision_area.is_in_group("player"):
			current_collision_area.take_damage(trap_damage)

func _on_collision(area:Area2D):
	current_collision_area = area


func _empty(_area:Area2D):
	current_collision_area = null
#func _physics_process(delta: float) -> void:
	
