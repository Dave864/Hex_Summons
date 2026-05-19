class_name EncounterEnemyTurn
extends EncounterState
## The logic for what happens when an Encounter scene is in the `EnemyTurn` state.
## 
## Handles the encounter logic needed to allow the enemy character to properly
## run during their turn. Remains in the `EnemyTurn` state if the next character
## in initiative is also an enemy character. Goes to the `PlayerTurn` state if
## a player character is next in intiative. Goes to the `SummonTurn` state if
## the next player character is the summoner of an active summon. Goes to the
## `End` state if either all player characters or all enemy characters are
## defeated. 


## The enemy character currently active
var _active_char: EnemyCharacter = null


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	enc.camera.disable_edge_detection()
	_active_char = enc.get_current_character()
	_connect_signals()
	await enc.camera.move_focus_decay(_active_char.position)
	SignalBus.emit_enemy_turn_started(_active_char)


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
			"turn_ended",
			Callable(self, "_on_EnemyCharacter_turn_ended")
	)


## Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	_active_char.disconnect(
			"turn_ended",
			Callable(self, "_on_EnemyCharacter_turn_ended")
	)


## Checks if the encounter has reached its end.
func _check_for_end() -> void:
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)


## Update the initiative tracker and transition to either the PlayerTurn state,
## the SummonTurn state, or the EnemyTurn state depending on the next character.
func _on_EnemyCharacter_turn_ended() -> void:
	await _active_char.is_waiting
	_check_for_end()
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		if enc.summon.is_active() and enc.summon.summoner == next_character:
			state_machine.transition_to(SUMMON_TURN)
		else:
			state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
