extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the `Move` state.
The Player Character moves from tile to tile along a preset path.
"""


# Array of the positions to be traveled to in order.
var travel_path: PoolVector3Array
# The start position for the current movement step.
var start_point: Vector3
# The end point for the current movement step.
var next_point: Vector3
# The index of the end point in the travel path.
var next_point_index: int = 1
# The current interpolation weight.
var weight: float = 0.0

var completed_path: bool = false
var selector_paused: bool = false


# Set the starting point for the path.
func enter(_msg := {}) -> void:
	travel_path = _msg["travel_path"]
	
	ErrorUtil.connect_signal(
		SignalBus,
		"selector_paused",
		self, 
		"_on_SignalBus_selector_paused"
	)
	
	# Move to the 'Standby' state if the travel path only has one point.
	# This indicates that the player character's current position was 
	# selected as the destination.
	if travel_path.size() > 1:
		start_point = pc.translation
		next_point = travel_path[next_point_index]
	elif selector_paused:
		next_point = travel_path[0]
		state_machine.transition_to(STANDBY)
	else:
		completed_path = true


# Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	if not completed_path:
		# Move the player character towards the next tile.
		weight += delta * pc.stats.get_mvmt_speed()
		weight = 1.0 if weight > 1.0 else weight
		pc.translation = start_point.linear_interpolate(next_point, weight)
		
		# When finished moving to next tile, check to see if path has been fully
		# traversed. Move to the 'Standby' state when path has been fully traversed.
		if weight >= 1.0:
			next_point_index += 1
			if next_point_index < travel_path.size():
				weight = 0.0
				start_point = pc.translation
				next_point = travel_path[next_point_index]
			else:
				next_point = travel_path[-1]
				completed_path = true
	elif selector_paused:
		state_machine.transition_to(STANDBY)


# Called by the state machine before changing the active state.
# Resets the interpolation weight and next_point_index.
func exit() -> void:
	weight = 0.0
	next_point_index = 1
	completed_path = false
	selector_paused = false
	SignalBus.disconnect("selector_paused", self, "_on_SignalBus_selector_paused")
	SignalBus.emit_signal("selector_required", next_point)


func _on_SignalBus_selector_paused() -> void:
	selector_paused = true
