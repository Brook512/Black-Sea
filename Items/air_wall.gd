extends Area2D
var resource
@onready var collision =$CollisionShape2D
@export var dialogue_id:int
var dialogue_dict = {1:"res://Dialogues/air_wall.dialogue",2:"res://Dialogues/air_wall2.dialogue"}

func _ready() -> void:
	area_entered.connect(_on_collision)
	resource = load(dialogue_dict[dialogue_id])
	
func _on_collision(area:Area2D):
	if area.is_in_group("player"):
		DialogueManager.show_dialogue_balloon(resource)
	pass

func _process(_delta: float) -> void:
	if GlobalSceneManager.IsTalked["LeftAirWall"] == true:
		collision.disabled = true
		
