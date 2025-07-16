extends Node

enum States {Dialogue, Combat, Begin, Menu, Settings, World}
signal state_changed(old_state, new_state)

var current_state: States = States.Menu
var previous_state: States = States.Menu

var current_scene: Node = null
var IsTalked:Dictionary={
	"BlueEnemy":false,
	"LeftAirWall":false,
}
var IsCombatted:Dictionary={
	"BlueEnemy":false,
}

# Scene paths for each state
const STATE_SCENES: Dictionary = {
	States.World: "res://scenes/World.tscn",
	States.Combat: "res://scenes/Combat.tscn",
	States.Begin: "res://scenes/StartAnim.tscn",
	States.Menu: "res://scenes/Loading.tscn",
	States.Settings: "res://scenes/Settings.tscn"
}

# State transition rules - which states can transition to which
const VALID_TRANSITIONS: Dictionary = {
	States.Dialogue: [States.Combat, States.World],
	States.Combat: [States.World],
	States.Menu: [States.Begin, States.Settings, States.Combat],
	States.Settings: [States.Menu],
	States.World: [States.Combat, States.Dialogue],
	States.Begin: [States.World]
}

func _ready():
	var current_scene_name = get_tree().current_scene.name
	current_scene = get_tree().current_scene
	# Ensure the state matches the initial scene
	if current_scene_name == "Menu":
		current_state = States.Menu
	elif current_scene_name == "World":
		current_state = States.World
	elif current_scene_name == "Combat":
		current_state = States.Combat
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
		States.World:
			if previous_state == States.Begin:
				goto_scene(STATE_SCENES[new_state])
			print("Entering World state")
			
		States.Dialogue:
			print("Entering Dialogue state")
		States.Combat:
			print("Entering Combat state")
			goto_scene(STATE_SCENES[new_state])
		States.Menu:
			print("Entering Menu state")
			goto_scene(STATE_SCENES[new_state])
		States.Settings:
			print("Entering Settings state")
			goto_scene(STATE_SCENES[new_state])
		States.Begin:
			print("Entering Begin state")
			goto_scene(STATE_SCENES[new_state])

@warning_ignore("unused_parameter")
func _on_state_exit(old_state: States, new_state: States):
	match old_state:
		States.Dialogue:
			print("Exiting Dialogue state")
		States.Combat:
			print("Exiting Combat state")
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
