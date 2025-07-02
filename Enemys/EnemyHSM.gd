extends LimboHSM
@onready var hsm: LimboHSM = $LimboHSM
@onready var normal_state: LimboState = $LimboHSM/NormalState
@onready var dialogue_state: LimboState = $LimboHSM/DialogueState
@onready var combat_state: BTState = $LimboHSM/CombatState

# 

func _ready() -> void:
	_init_state_machine()


func _init_state_machine() -> void:
	hsm.add_transition(normal_state, dialogue_state, normal_state.EVENT_FINISHED)
	hsm.add_transition(dialogue_state, normal_state, dialogue_state.EVENT_FINISHED)

	hsm.initialize(self)
	hsm.set_active(true)
	
	#hsm.dispatch()
