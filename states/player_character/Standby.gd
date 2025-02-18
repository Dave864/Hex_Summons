extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the 'Standby' state.
The Player Character waits for player input and then goes to the appropriate
state.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(STANDBY)
	# These signals is used by other PlayerCharacters and will be disconnected 
	# to avoid unintended behavior.
	ErrorUtil.connect_signal(
		SignalBus, 
		"tile_selected", 
		self, 
		"_on_SignalBus_tile_selected"
	)
	ErrorUtil.connect_signal(
		SignalBus,
		"player_turn_ended",
		self,
		"_on_SignalBus_player_turn_ended"
	)


# Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state. 
# Use this function to clean up the state.
func exit() -> void:
	SignalBus.disconnect("tile_selected", self, "_on_SignalBus_tile_selected")
	SignalBus.disconnect("player_turn_ended", self, "_on_SignalBus_player_turn_ended")


# Hit when the Selector selects a map tile destination.
func _on_SignalBus_tile_selected(info: Array) -> void:
	state_machine.transition_to(MOVE, {"travel_path": info})


# Hit when the EncounterUI indicates that a player has finished their turn.
func _on_SignalBus_player_turn_ended(player: PlayerCharacter) -> void:
	if pc.name == player.name:
		state_machine.transition_to(WAIT)
