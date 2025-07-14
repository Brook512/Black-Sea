extends LimboState
var IsWantCombat = false
var resource 
var players 

### Called once, when state is initialized.
func _setup() -> void:
	resource = load("res://Dialogues/first_enemy.dialogue")
	players = get_tree().get_nodes_in_group("player")
	
## Called when state is entered.
func _enter() -> void:
	GlobalSceneManager.change_state(GlobalSceneManager.States.Dialogue)
	DialogueManager.show_dialogue_balloon(resource)
	#暂停游戏
	for player in players:
		player.set_physics_process(false)
	
func _update(delta: float) -> void:
	if GlobalSceneManager.current_state != GlobalSceneManager.States.Dialogue:
		dispatch(EVENT_FINISHED)

### Called when state is exited.
func _exit() -> void:
	print("退出对话状态")
	for player in players:
		player.set_physics_process(true)

	

## Called each frame when this state is active.
#func _update(delta: float) -> void:
	#agent
	#get_parent().dispatch(&"TriggerCombat")
	
