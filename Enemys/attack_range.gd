extends Area2D

@export var enemy_damage=1
var current_collision_area: Area2D
var current_body
func _ready() -> void:
	area_entered.connect(_on_collision)
	area_exited.connect(_empty)

func _physics_process(delta: float) -> void:
	if current_collision_area:
		if current_collision_area.is_in_group("player"):
			current_collision_area.take_damage(enemy_damage, get_parent().last_sign)

func _on_collision(area:Area2D):
	current_collision_area = area


func _empty(area:Area2D):
	current_collision_area = null

	
