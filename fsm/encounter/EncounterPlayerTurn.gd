extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `PlayerTurn` state.
Handles the encounter logic needed to allow the player character to properly
run during their turn. Goes to the `PlayerTurn` state if the next character
in initiative is also a player character. Goes to the `EnemyTurn` state if an
enemy character is next in intiative. Goes to the `End` state if either all
player characters or all enemy characters are defeated. 
"""


# The player character currently active
var _active_char: PlayerCharacter = null
# Flag that tracks if the UI is waiting. Used when changing to another player's
# turn.
var _ui_waiting: bool = false


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	# UI is active when player turn starts.
	_ui_waiting = false
	_active_char = enc.get_current_character()
	SignalBus.emit_player_turn_started(_active_char)


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Move to the `End` State when all enemies are defeated.
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)
	"""
	TODO: Add logic to check if all players are defeated
	"""


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	pass


# Connect signals that will persist throughout the life of this state.
func _ready_connect_signals() -> void:
	ErrorUtil.connect_signal(
			SignalBus,
			"player_turn_ended",
			self,
			"_on_SignalBus_player_turn_ended"
	)
	ErrorUtil.connect_signal(
			enc.ui,
			"is_waiting",
			self,
			"_on_EncounterUI_is_waiting"
	)


# Marks the UI as waiting.
func _on_EncounterUI_is_waiting() -> void:
	_ui_waiting = true


# Clear the tile movement highlights, update the initiative tracker and
# transition to either the PlayerTurn state or the EnemyTurn state depending 
# on the next character.
func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	enc.hex_map.selection_tracker.clear_highlights()
	enc.hex_map.selection_tracker.clear_selector_highlights()
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		if not _ui_waiting:
			yield(enc.ui, "is_waiting")
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
