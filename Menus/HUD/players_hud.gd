extends Node2D
@export var player:Sasaki
var hsm_blackboard
#func _ready() -> void:
	#if player.hsm.blackboard:
		#hsm_blackboard = player.hsm.blackboard
	#
#func _physics_process(delta: float) -> void:
	#var health = hsm_blackboard.get_var("health")
	#var energy = hsm_blackboard.get_var("energy")
	
