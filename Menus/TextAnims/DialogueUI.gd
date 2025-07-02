extends Control
@onready var label = $Label
@onready var options_container = $VBoxContainer

var dialogue_manager = preload("res://DialogueManager.gd").new()

func _ready():
	dialogue_manager.dialogue = [
		# 这里填充你的对话数据
	]
	start_dialogue()

func start_dialogue():
	dialogue_manager.start_dialogue()
	update_ui()

func update_ui():
	var entry = dialogue_manager.find_dialogue_entry(dialogue_manager.current_dialogue_id)
	if entry:
		label.text = entry["speaker"] + ": " + entry["text"]
		if entry.has("options"):
			show_options(entry["options"])
		else:
			options_container.hide()

func show_options(options):
	options_container.show()
	for child in options_container.get_children():
		child.queue_free()  # 清除旧选项
	for i in range(options.size()):
		var button = Button.new()
		button.text = options[i]["text"]
		button.connect("pressed", Callable(self, "on_option_selected").bind(i))
		options_container.add_child(button)

func on_option_selected(option_index):
	dialogue_manager.choose_option(option_index)
	update_ui()
