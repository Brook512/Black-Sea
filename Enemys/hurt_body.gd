extends Area2D
var enemy

func take_damage(damage):
	enemy = get_parent()
	enemy.blood_spark.emit()
	var current_health = enemy.hsm.get_var("health")
	current_health -= damage
	enemy.hsm.set_var("health", current_health)
	var tween = create_tween()
	
	
