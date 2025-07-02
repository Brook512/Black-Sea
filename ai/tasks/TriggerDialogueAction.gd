# Action: TriggerDialogueAction
class_name TriggerDialogueAction
extends BTAction

func _tick(_delta: float) -> Status:
	var dialogue_id = get_blackboard().get_var("dialogue_id", "enemy_default")
	DialogueManager.start_dialogue(dialogue_id)
	
	# 暂停AI行为
	get_tree().paused = true
	
	# 监听对话结束事件
	if not DialogueManager.is_connected("dialogue_finished", self, "_on_dialogue_finished"):
		DialogueManager.connect("dialogue_finished", self, "_on_dialogue_finished")
	
	return RUNNING

func _on_dialogue_finished():
	get_tree().paused = false
	get_blackboard().set_var("is_in_dialogue", false)
	succeed()
