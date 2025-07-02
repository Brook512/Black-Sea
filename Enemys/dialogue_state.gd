extends LimboState
var IsWantCombat = false
var resource 
var players 

### Called once, when state is initialized.
func _setup() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	resource = load("res://Dialogues/Teacher.dialogue")
	players = get_tree().get_nodes_in_group("player")
## Called when state is entered.
func _enter() -> void:
	DialogueManager.show_dialogue_balloon(resource)
	#var dialogue_line = await DialogueManager.get_next_dialogue_line(resource, "start")
	#print(dialogue_line.text)
	#暂停游戏
	for player in players:
		player.set_physics_process(false)
	
#func _update(delta: float) -> void:
	

	
func _on_dialogue_ended(resource):
	get_parent().dispadtch(EVENT_FINISHED)

### Called when state is exited.
func _exit() -> void:
	# 恢复游戏
	for player in players:
		player.set_physics_process(true)




## Called each frame when this state is active.
#func _update(delta: float) -> void:
	#agent
	#get_parent().dispatch(&"TriggerCombat")
	
