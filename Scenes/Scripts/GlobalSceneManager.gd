extends Node

enum States {Dialogue, Combat, Menu, Settings}
signal state_changed(old_state, new_state)

var current_state: States = States.Menu
var previous_state: States = States.Menu
var current_scene: Node = null

# Scene paths for each state
const STATE_SCENES: Dictionary = {
	States.Dialogue: "res://scenes/World.tscn",
	States.Combat: "res://scenes/World.tscn",
	States.Menu: "res://scenes/Menu.tscn",
	States.Settings: "res://scenes/Settings.tscn"
}

# State transition rules - which states can transition to which
const VALID_TRANSITIONS: Dictionary = {
	States.Dialogue: [States.Combat, States.Settings],
	States.Combat: [States.Dialogue, States.Menu],
	States.Menu: [States.Dialogue],
	States.Settings: [States.Menu]
}

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(-1)
	# Ensure the state matches the initial scene
	if current_scene.scene_file_path == STATE_SCENES[States.Menu]:
		current_state = States.Menu
	else:
		push_warning("Initial scene doesn't match initial state. Consider starting from menu scene.")

# Public method to request a state change
func change_state(new_state: States) -> bool:
	# Check if transition is valid
	if can_transition_to(new_state):
		# Store previous state before changing
		previous_state = current_state
		
		# Perform state exit actions
		_on_state_exit(previous_state, new_state)
		
		# Change state
		current_state = new_state
		
		# Load corresponding scene
		var scene_path = STATE_SCENES.get(new_state)
		if scene_path:
			goto_scene(scene_path)
		
		# Perform state enter actions
		_on_state_enter(new_state)
		
		# Emit signal
		emit_signal("state_changed", previous_state, new_state)
		
		return true
	push_warning("Invalid state transition requested: %s → %s" % [States.keys()[current_state], States.keys()[new_state]])
	return false

# Transition back to the previous state
func revert_to_previous_state() -> bool:
	return change_state(previous_state)

# Check if a transition to the new state is valid
func can_transition_to(new_state: States) -> bool:
	return new_state in VALID_TRANSITIONS.get(current_state, [])

# Get the current state as string
func get_current_state_name() -> String:
	return States.keys()[current_state]

# State transition handlers (can be overridden in inherited scripts)
func _on_state_enter(new_state: States):
	match new_state:
		States.Dialogue:
			print("Entering Dialogue state")
			# Pause world simulation
			get_tree().paused = true
		States.Combat:
			print("Entering Combat state")
			get_tree().paused = false
		States.Menu:
			print("Entering Menu state")
			# Pause game when in menu
			get_tree().paused = true
		States.Settings:
			print("Entering Settings state")

@warning_ignore("unused_parameter")
func _on_state_exit(old_state: States, new_state: States):
	match old_state:
		States.Dialogue:
			print("Exiting Dialogue state")
			# Cleanup dialogue resources
		States.Combat:
			print("Exiting Combat state")
			# Save combat results
		States.Menu:
			print("Exiting Menu state")
		States.Settings:
			print("Exiting Settings state")
			# Save settings changes

# Scene management functions remain similar to your original
func goto_scene(path: String):
	_deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path: String):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
