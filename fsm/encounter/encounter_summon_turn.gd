class_name EncounterSummonTurn
extends EncounterState
## The logic for what happens when an Encounter scene is in the `SummonTurn`
## state.
##
## Handles the encounter logic needed to allow the summon character to properly
## run during their turn. Goes to the `PlayerTurn` state if the next character
## in initiative is also a player character. Goes to the `EnemyTurn` state if an
## enemy character is next in intiative. Goes to the `End` state if either all
## player characters or all enemy characters are defeated.


## Flag that tracks if the summon is waiting. Used when changing to another
## character's turn.
var _summon_waiting: bool = false


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_summon_waiting = false
	enc.selection_tracker.focused_character = enc.summon
	await enc.camera.move_focus_decay(enc.summon.position)
	enc.camera.enable_edge_detection()
	SignalBus.emit_summon_turn_started()


## Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Move to the `End` State when all enemies are defeated.
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)
	## TODO: Add logic to check if all players are defeated


## Connect signals that will persist throughout the life of this state.
func _ready_connect_signals() -> void:
	enc.summon.is_waiting.connect(_on_SummonCharacter_is_waiting)
	enc.summon.turn_ended.connect(_on_Summon_turn_ended)


## Checks if the encounter has reached its end.
func _check_for_end() -> void:
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)


## Marks the player as waiting.
func _on_SummonCharacter_is_waiting() -> void:
	_summon_waiting = true


## Clear the tile movement highlights, update the initiative tracker and
## transition to either the PlayerTurn state, or the EnemyTurn state depending
## on the next character.
func _on_Summon_turn_ended() -> void:
	enc.selection_tracker.clear_highlights()
	enc.selection_tracker.clear_indicators()
	if not _summon_waiting:
		await enc.summon.is_waiting
	_check_for_end()
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
