extends SelectorState
"""
The logic for what happens when the Selector is in the 'Start' state.
The Selector sets its initial position before going to the `Wait` state.
"""


# Hit when the selector node enters a map tile.
func _on_Selector_area_entered(map_tile: Area) -> void:
	selector.snap_position = map_tile.translation
	selector.tile = map_tile


# Called by the state machine upon changing the active state. The `msg` 
# parameter is a dictionary with arbitrary data the state can use to 
# initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(START)
	ErrorUtil.connect_signal(
		selector,
		"area_entered",
		self,
		"_on_Selector_area_entered"
	)


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# If the starting position has been selected, move to the `Wait` state.
	if selector.snap_position != null:
		state_machine.transition_to(WAIT)


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.disconnect("area_entered", self, "_on_Selector_area_entered")
