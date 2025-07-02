class_name FacePlayerAction
extends BTAction

func _tick(_delta: float) -> Status:
	var player_pos = get_blackboard().get_var("player_position")
	var enemy = get_agent()
	
	if player_pos.x < enemy.global_position.x:
		enemy.set_flip_h(true)  # 面向左
	else:
		enemy.set_flip_h(false) # 面向右
	
	return SUCCESS
