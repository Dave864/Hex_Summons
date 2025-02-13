extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the 'Standby' state.
The Player Character waits for player input and then goes to the appropriate
state.
"""


# Hit when the Selector selects a map tile destination.
func _on_SignalBus_tile_selected(info) -> void:
	state_machine.transition_to(MOVE, {"travel_path": info})


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(STANDBY)
	state_machine.connect_signal(
		SignalBus, 
		"tile_selected", 
		self, 
		"_on_SignalBus_tile_selected"
	)
	
	#var e: int = SignalBus.connect(
	#	"tile_selected", 
	#	self, 
	#	"_on_SignalBus_tile_selected"
	#)
	
	# Emit error message when issue is encountered when connecting the 
	# tile_selected SignalBus signal to the _on_SignalBus_tile_selected method.
	#if e != OK:
	#	ErrorMessage.signal_connect_failed(
	#		e,
	#		"tile_selected",
	#		"SignalBus autoload",
	#		"PlayerCharacter",
	#		"Standby",
	#		"_on_SignalBus_tile_selected"
	#	)


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
