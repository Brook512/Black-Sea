@tool
extends BTCondition

# Task parameters.
@export var action: String

## Note: Each method declaration is optional.
## At minimum, you only need to define the "_tick" method.

var input_window=0.5
var input_stay_time = 0.
var start_timer = false
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "If Pressed " + LimboUtility.decorate_var(action)


# Called to initialize the task.
func _setup() -> void:
	pass


# Called when the task is entered.
func _enter() -> void:
	pass


# Called when the task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if start_timer == true:
		input_stay_time += delta
	if input_stay_time >= input_window:
		start_timer = false
		input_stay_time = 0.
	
	if Input.is_action_pressed(action):
		start_timer = true
		
	if start_timer == true:
		return SUCCESS
	else:
		return FAILURE
