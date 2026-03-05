class_name EncounterPlayerTurn
extends EncounterState
## The logic for what happens when an Encounter scene is in the `PlayerTurn` state.
##
## Handles the encounter logic needed to allow the player character to properly
## run during their turn. Goes to the `PlayerTurn` state if the next character
## in initiative is also a player character. Goes to the `SummonTurn` state if
## the next player character is the summoner of an active summon. Goes to the
## `EnemyTurn` state if an enemy character is next in intiative. Goes to the
## `End` state if either all player characters or all enemy characters are
## defeated. 


## The player character currently active
var _active_char: PlayerCharacter = null
## Flag that tracks if the player is waiting. Used when changing to another
## character's turn.
var _player_waiting: bool = false


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_player_waiting = false
	_active_char = enc.get_current_character()
	_connect_signals()
	await enc.camera.move_focus_decay(_active_char.position)
	enc.camera.enable_edge_detection()
	SignalBus.emit_player_turn_started(_active_char)


## Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Move to the `End` State when all enemies are defeated.
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)
	## TODO: Add logic to check if all players are defeated


## Called by the state machine before changing the active state.
## Use this function to clean up the state.
func exit() -> void:
	_disconnect_signals()
	_active_char = null


## Connect the relevant signals to this state.
## These signals are used by other states and will be disconnected to avoid
## unintended behavior.
func _connect_signals() -> void:
	_active_char.connect(
			"is_waiting",
			Callable(self, "_on_PlayerCharacter_is_waiting")
	)
	_active_char.connect(
			"turn_ended",
			Callable(self, "_on_PlayerCharacter_turn_ended")
	)


## Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	_active_char.disconnect(
			"is_waiting",
			Callable(self, "_on_PlayerCharacter_is_waiting")
	)
	_active_char.disconnect(
			"turn_ended",
			Callable(self, "_on_PlayerCharacter_turn_ended")
	)



## Marks the player as waiting.
func _on_PlayerCharacter_is_waiting() -> void:
	_player_waiting = true


## Clear the tile movement highlights, update the initiative tracker and
## transition to either the PlayerTurn state, the SummonTurn state, or the
## EnemyTurn state depending on the next character.
func _on_PlayerCharacter_turn_ended() -> void:
	enc.selection_tracker.clear_highlights()
	enc.selection_tracker.clear_indicators()
	if not _player_waiting:
		await _active_char.is_waiting
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		if enc.summon.is_active() and enc.summon.summoner == next_character:
			state_machine.transition_to(SUMMON_TURN)
		else:
			state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
