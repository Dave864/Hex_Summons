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


## Flag that tracks if the UI is waiting. Used when changing to another
## character's turn.
var _ui_waiting: bool = false
## Flag that tracks if the summon is waiting. Used when changing to another
## character's turn.
var _summon_waiting: bool = false


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	# UI is active when summon turn starts.
	_ui_waiting = false
	_summon_waiting = false
	SignalBus.emit_summon_turn_started()


## Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Move to the `End` State when all enemies are defeated.
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)
	## TODO: Add logic to check if all players are defeated


## Connect signals that will persist throughout the life of this state.
func _ready_connect_signals() -> void:
	enc.ui.connect(
			"is_waiting",
			Callable(self, "_on_EncounterUI_is_waiting")
	)
	enc.summon.connect(
			"is_waiting",
			Callable(self, "_on_Summon_is_waiting")
	)
	enc.summon.connect(
			"turn_ended",
			Callable(self, "_on_Summon_turn_ended")
	)


## Marks the UI as waiting.
func _on_EncounterUI_is_waiting() -> void:
	_ui_waiting = true


## Marks the player as waiting.
func _on_SummonCharacter_is_waiting() -> void:
	_summon_waiting = true


## Clear the tile movement highlights, update the initiative tracker and
## transition to either the PlayerTurn state, or the EnemyTurn state depending
## on the next character.
func _on_Summon_turn_ended() -> void:
	enc.hex_map.selection_tracker.clear_highlights()
	enc.hex_map.selection_tracker.clear_selector_highlights()
	if not _ui_waiting:
		await enc.ui.is_waiting
	if not _summon_waiting:
		await enc.summon.is_waiting
	var next_character: Character = enc.get_next_character()
	await enc.progress_initiative()
	if next_character is PlayerCharacter:
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
