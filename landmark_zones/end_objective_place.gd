class_name EndObjectivePlace
extends Node3D
## A location in a landmark zone that the player can interact with to end the
## game.
##
## Checks if the player has completed all the objectives to end the game. Places
## the player avatar at some point if the end game objective has not been met.


## Indicates which state this is in.
enum State{
	WAIT,
	OBJECTIVE_FAIL_FADE_IN,
	OBJECTIVE_FAIL_DIALOGUE,
	OBJECTIVE_FAIL_FADE_OUT,
	OBJECTIVE_SUCCESS_FADE_IN,
	OBJECTIVE_SUCCESS_DIALOGUE,
}

## The dialogue text to display when the objective is met.
@export_multiline var dialogue_objective_met := ""
## The dialogue text to display when the objective has not been met.
@export_multiline var dialogue_objective_failed := ""
## The time it takes in seconds to fade to black and back again.
@export_range(0.1, 10.0, 0.001, "suffix:s") var fade_time := 1.0
## The dialogue panel to send the text to.
@export var dialogue_panel: PanelDialogue = null
## The panel used to blackout the screen.
@export var blackout_panel: Panel = null
## The point the player is placed if objective is not met.
@export var reset_point: Marker3D = null

## Marks what state this node is in.
var _state := State.WAIT
## How far the blackout panel has transitioned.
var _transition_progress := 0.0
## Reference to the player that has entered the objective zone.
var _player_ref: OverworldAvatar = null


## Updates the objective step to final step.
func _ready() -> void:
	ObjectiveTracker.set_objective_step(4)


## Fades the blackout panel.
func _process(delta: float) -> void:
	match _state:
		State.OBJECTIVE_FAIL_FADE_IN:
			_transition_progress += delta / fade_time / fade_time
			blackout_panel.modulate.a = clampf(_transition_progress, 0.0, 1.0)
			if _transition_progress >= 1.0:
				dialogue_panel.display()
				_player_ref.global_position = reset_point.global_position
				_transition_progress = 1.0
				_state = State.OBJECTIVE_FAIL_DIALOGUE
		State.OBJECTIVE_FAIL_DIALOGUE:
			if not dialogue_panel.visible:
				_player_ref.ignore_input(false)
				_player_ref = null
				_state = State.OBJECTIVE_FAIL_FADE_OUT
		State.OBJECTIVE_FAIL_FADE_OUT:
			_transition_progress -= delta / fade_time / fade_time
			blackout_panel.modulate.a = clampf(_transition_progress, 0.0, 1.0)
			if _transition_progress <= 0.0:
				blackout_panel.hide()
				_state = State.WAIT
		State.OBJECTIVE_SUCCESS_FADE_IN:
			_transition_progress += delta / fade_time / fade_time
			blackout_panel.modulate.a = clampf(_transition_progress, 0.0, 1.0)
			if _transition_progress >= 1.0:
				dialogue_panel.display()
				_state = State.OBJECTIVE_SUCCESS_DIALOGUE
		State.OBJECTIVE_SUCCESS_DIALOGUE:
			if not dialogue_panel.visible:
				_state = State.WAIT
		_:
			return


## Checks if the full game objectives have been met. Places the player at the
## reset point if they have not.
func _on_entrance_body_entered(player: Node3D) -> void:
	_player_ref = player as OverworldAvatar
	_player_ref.ignore_input(true)
	_transition_progress = 0.0
	blackout_panel.show()
	if ObjectiveTracker.all_kill_objectives_met():
		dialogue_panel.set_text(dialogue_objective_met)
		_state = State.OBJECTIVE_SUCCESS_FADE_IN
	else:
		dialogue_panel.set_text(dialogue_objective_failed)
		_state = State.OBJECTIVE_FAIL_FADE_IN
