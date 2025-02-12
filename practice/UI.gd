extends Control
"""
Prototype for overarching encounter UI.
"""


signal mode_changed()

var current_phase: String = PlayerCharacterState.MOVE

onready var _move_button: Button = $Move
onready var _technique_button: Button = $Technique


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_move_button.disabled = true
	_technique_button.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	# Hide and reveal the UI when a player character starts and ends their
	# turn respectively.
	match StateMachineBus.encounter_states[FSM.Encounter.PLAYER_CHARACTER]:
		PlayerCharacterState.STANDBY:
			show()
		PlayerCharacterState.WAIT:
			hide()
			current_phase = PlayerCharacterState.MOVE
			StateMachineBus.encounter_states[FSM.Encounter.UI] = current_phase
			_move_button.disabled = true
			_technique_button.disabled = false
		_:
			pass


func _on_Move_pressed() -> void:
	_technique_button.disabled = false
	current_phase = PlayerCharacterState.MOVE
	StateMachineBus.encounter_states[FSM.Encounter.UI] = current_phase
	_move_button.disabled = true
	emit_signal("mode_changed")


func _on_Technique_pressed() -> void:
	_move_button.disabled = false
	current_phase = PlayerCharacterState.ATTACK
	StateMachineBus.encounter_states[FSM.Encounter.UI] = current_phase
	_technique_button.disabled = true
	emit_signal("mode_changed")
