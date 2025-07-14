extends Area2D

@onready var dialogue_icon = $DialogueIcon
var _is_player_near = false

func _ready() -> void:
	area_entered.connect(_on_dialogue_range_area_entered)
	area_exited.connect(_on_dialogue_range_area_exited)


func _on_dialogue_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and GlobalSceneManager.current_state == GlobalSceneManager.States.Normal:
		dialogue_icon.visible = true
		_is_player_near = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dialogue") and _is_player_near:
		get_parent().hsm.dispatch(&"TriggerDialogue")	

func _on_dialogue_range_area_exited(area: Area2D) -> void:
	if area.is_in_group("player") and GlobalSceneManager.current_state == GlobalSceneManager.States.Normal:
		dialogue_icon.visible = false
		_is_player_near = false
		
