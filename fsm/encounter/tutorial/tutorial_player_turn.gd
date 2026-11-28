class_name TutorialPlayerTurn
extends TutorialState
## The logic for what happens when a Tutorial scene is in the `PlayerTurn` state.
##
## Handles the tutorial logic needed to allow the player character to properly
## run during their turn. Goes to the `PlayerTurn` state if the next character
## in initiative is also a player character. Goes to the `SummonTurn` state if
## the next player character is the summoner of an active summon. Goes to the
## `EnemyTurn` state if an enemy character is next in intiative. Goes to the
## `End` state if all player characters are defeated. When all enemy characters
## are defeated, it will prompt the map selector to highlight the transition
## zone. When all tutorial steps are finished, defeating all enemy characters
## will trigger a transition to the `End` state.


## The player character currently active
var _active_char: PlayerCharacter = null
## Flag that tracks if the player is waiting. Used when changing to another
## character's turn.
var _player_waiting: bool = false


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_player_waiting = false
	_active_char = tutorial.get_current_character()
	_connect_signals()
	await tutorial.camera.move_focus_decay(_active_char.position)
	tutorial.camera.enable_edge_detection()
	if tutorial.enemies_defeated():
		# Objective needs to indicate that the player should move to the area.
		tutorial.dialogue_panel.set_text(tutorial.tooltip_objective_movement)
		tutorial.set_notification_area()
	SignalBus.emit_player_turn_started(_active_char)


## Called by the state machine before changing the active state.
## Use this function to clean up the state.
func exit() -> void:
	_disconnect_signals()
	_active_char = null


## Connect the relevant signals to this state.
## These signals are used by other states and will be disconnected to avoid
## unintended behavior.
func _connect_signals() -> void:
	_active_char.is_waiting.connect(_on_PlayerCharacter_is_waiting)
	_active_char.turn_ended.connect(_on_PlayerCharacter_turn_ended)


## Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	_active_char.is_waiting.disconnect(_on_PlayerCharacter_is_waiting)
	_active_char.turn_ended.disconnect(_on_PlayerCharacter_turn_ended)


## Returns if the tutorial has reached its end. Triggers a state change if
## it has.
func _reached_end() -> bool:
	if (
			tutorial.players_defeated() or
			(
				tutorial.enemies_defeated()
				and tutorial.tutorial_step == Tutorial.Step.SUMMON
			)
	):
		state_machine.transition_to(END)
		return true
	return false


## Marks the player as waiting.
func _on_PlayerCharacter_is_waiting() -> void:
	_player_waiting = true


## Clear the tile movement highlights, update the initiative tracker and
## transition to either the PlayerTurn state, the SummonTurn state, or the
## EnemyTurn state depending on the next character.
func _on_PlayerCharacter_turn_ended() -> void:
	tutorial.selection_tracker.clear_highlights()
	tutorial.selection_tracker.clear_indicators()
	if not _player_waiting:
		await _active_char.is_waiting
	if _reached_end():
		return
	if tutorial.players_in_transition_area():
		tutorial.selection_tracker.notification_indexes.clear()
		state_machine.transition_to(INSTRUCTION)
		return
	var next_character: Character = tutorial.get_next_character()
	tutorial.progress_initiative()
	if next_character is PlayerCharacter:
		if (
				tutorial.summon.is_active()
				and tutorial.summon.summoner == next_character
		):
			state_machine.transition_to(SUMMON_TURN)
		else:
			state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
