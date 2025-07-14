extends Area2D

var hsm:LimboHSM
var hit_speed=400
	
func take_damage(damage, dir=null):
	
	if hsm:
		hsm.dispatch(&"HurtReceived",damage)
	else:
		hsm = get_parent().hsm
		hsm.dispatch(&"HurtReceived",damage)
	
	if dir:
		get_parent().velocity.x += sign(dir)*hit_speed
		#get_parent().velocity.x -= hit_speed
