extends Control
@onready var anim_player = $Camera2D/AnimationPlayer

func _ready() -> void:
	anim_player.play("background")
	
func _on_animation_finished():
	GlobalSceneManager.goto_scene("res://Scenes/World.tscn")
