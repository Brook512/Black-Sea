class_name BaseScene extends Node2D

#@onready var blue_enemy:BasicEnemy = $Enemy
@onready var current_cam:Camera2D = $Camera2D
@onready var player:Sasaki = $sasaki
@onready var enemy:CharacterBody2D = $Enemy
@onready var anim_player = $AnimationPlayer
@onready var win_label = $Camera2D/WinLabel
@onready var loss_label = $Camera2D/LossLabel
@onready var ending_timer = Timer.new()

var ori_cam_position = Vector2(0.,32.)
var up_cam_postion = Vector2(0,0)
var start_timer = 0. 


func _ready() -> void:
	anim_player.play("START")
	ending_timer.one_shot= true
	ending_timer.wait_time = 3.
	add_child(ending_timer)
	

func _process(delta: float) -> void:
	_check_death()

func _check_death():
	if player.hsm.get_active_state() == player.death_state:
		player.set_physics_process(false)
		enemy.set_physics_process(false)
		
		anim_player.play("ENDING")
		loss_label.visible = true
		win_label.visible = false
		if !anim_player.is_playing():
			GlobalSceneManager.change_state(GlobalSceneManager.States.Menu)
	
	if enemy.hsm.get_active_state() == enemy.death_state:
		player.set_physics_process(false)
		enemy.set_physics_process(false)
		anim_player.play("ENDING")
		win_label.visible = true
		loss_label.visible = false
		if ending_timer.time_left == 0:
			ending_timer.start()
		elif ending_timer.time_left <0.5:
			GlobalSceneManager.change_state(GlobalSceneManager.States.Menu)
	
