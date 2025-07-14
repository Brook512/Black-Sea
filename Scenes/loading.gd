extends Control
@onready var anim_player = $AnimationPlayer 

func _ready() -> void:
	anim_player.play("logo")
	
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		_on_animation_finished()

func _on_animation_finished():
	GlobalSceneManager.goto_scene("res://Scenes/Menu.tscn")
