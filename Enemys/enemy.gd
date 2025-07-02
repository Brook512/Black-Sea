extends CharacterBody2D
class_name BasicEnemy
@onready var hsm: LimboHSM = $EnemyHSM
@onready var normal_state: LimboState = $EnemyHSM/NormalState
@onready var dialogue_state: LimboState = $EnemyHSM/DialogueState
@onready var combat_state: BTState = $EnemyHSM/CombatState
@onready var dialogue_icon = $DialogueIcon

@export var Player:Sasaki
var ActivateDialogue:bool = false
var IsPlayerNearable:bool = false
var dialogue_duration = 0



func _ready() -> void:
	_init_state_machine()
	Player.dialogue_signal.connect(_on_player_want_dialogue)


func _init_state_machine() -> void:
	hsm.add_transition(normal_state, dialogue_state, &"TriggerDialogue")
	hsm.add_transition(dialogue_state, normal_state, dialogue_state.EVENT_FINISHED)
	hsm.add_transition(combat_state, normal_state, combat_state.EVENT_FINISHED)
	hsm.add_transition(dialogue_state, combat_state, &"TriggerCombat")

	hsm.initialize(self)
	hsm.set_active(true)

func _physics_process(delta: float) -> void:
	if ActivateDialogue==true:
		dialogue_duration+=delta
	
	if dialogue_duration >=0.2:
		ActivateDialogue=false
		dialogue_duration=0
		
	if ActivateDialogue and IsPlayerNearable:
		hsm.dispatch(&"TriggerDialogue")
		
func face_dir(dir: float) -> void:
	if dir > 0.0 and self.scale.x < 0.0:
		self.scale.x = 1.0;

	if dir < 0.0 and self.scale.x > 0.0:
		self.scale.x = -1.0;

	
func _on_player_want_dialogue():
	ActivateDialogue=true

func _on_dialogue_range_area_entered(area: Area2D) -> void:
	IsPlayerNearable=true
	dialogue_icon.visible = true
	

func _on_dialogue_range_area_exited(area: Area2D) -> void:
	IsPlayerNearable=false
	dialogue_icon.visible = false
	
