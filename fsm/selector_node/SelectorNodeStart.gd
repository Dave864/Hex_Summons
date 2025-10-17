extends SelectorState
"""
The logic for what happens when the Selector is in the 'Start' state.
The Selector sets its initial position before going to the `Wait` state.
"""


# Called by the state machine upon changing the active state. The `msg` 
# parameter is a dictionary with arbitrary data the state can use to 
# initialize itself.
func enter(_msg := {}) -> void:
	ErrorUtil.connect_signal(
			selector,
			"area_entered",
			self,
			"_on_Selector_area_entered"
	)


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.disconnect("area_entered", Callable(self, "_on_Selector_area_entered"))


# Hit when the selector node enters a map tile.
func _on_Selector_area_entered(map_tile: Area3D) -> void:
	selector.snap_position = map_tile.position
	selector.tile = map_tile
