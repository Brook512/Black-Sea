extends Node2D
@onready var anim_player = $AnimationPlayer
@onready var setting_layer = $SettingLayer
func _ready() -> void:
	anim_player.play("START")
	

		
