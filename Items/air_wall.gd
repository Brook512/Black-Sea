extends Area2D
var resource
@onready var collision =$CollisionShape2D
func _ready() -> void:
	area_entered.connect(_on_collision)
	resource = load("res://Dialogues/air_wall.dialogue")
	
func _on_collision(area:Area2D):
	if area.is_in_group("player"):
		DialogueManager.show_dialogue_balloon(resource)
	pass

func _process(delta: float) -> void:
	if GlobalSceneManager.IsTalked["LeftAirWall"] == true:
		collision.disabled = true
		
