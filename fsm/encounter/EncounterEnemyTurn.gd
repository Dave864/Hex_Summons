extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `EnemyTurn` state.
Handles the encounter logic needed to allow the enemy character to properly
run during their turn. Remains in the `EnemyTurn` state if the next character
in initiative is also an enemy character. Goes to the `PlayerTurn` state if an
player character is next in intiative. Goes to the `End` state if either all
player characters or all enemy characters are defeated. 
"""


# The enemy character currently active
var _active_char: EnemyCharacter = null
# Flag that tracks if the UI is waiting. Used when changing to another player's
# turn.
var _ui_waiting: bool = false


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_ui_waiting = false
	_active_char = enc.get_current_character()
	_connect_signals()
	SignalBus.emit_enemy_turn_started(_active_char)


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	_disconnect_signals()


# Connect signals that will persist throughout the life of this state.
func _ready_connect_signals() -> void:
	ErrorUtil.connect_signal(
			enc.ui,
			"is_waiting",
			self,
			"_on_EncounterUI_is_waiting"
	)


# Connect the relevant signals to this state.
# These signals are used by other states and will be disconnected to avoid
# unintended behavior.
func _connect_signals() -> void:
	ErrorUtil.connect_signal(
			_active_char,
			"enemy_turn_ended",
			self,
			"_on_EnemyCharacter_enemy_turn_ended"
	)


# Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	_active_char.disconnect(
			"enemy_turn_ended",
			self,
			"_on_EnemyCharacter_enemy_turn_ended"
	)


# Marks the UI as waiting.
func _on_EncounterUI_is_waiting() -> void:
	_ui_waiting = true


# Update the initiative tracker and transition to either the PlayerTurn state
# or the EnemyTurn state depending on the next character.
func _on_EnemyCharacter_enemy_turn_ended() -> void:
	yield(_active_char, "is_waiting")
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		if not _ui_waiting:
			yield(enc.ui, "is_waiting")
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
