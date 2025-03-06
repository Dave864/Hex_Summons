extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the `Move` state.
The Enemy Character moves from tile to tile along a preset path and then 
proceeds to the next command in the given chain. Goes to the 'Wait' 
state if movement is the last command.
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
# The list of commands the enemy will execute.
var command_chain: Array = []


# Set the starting point for the path.
func enter(_msg := {}) -> void:
	command_chain = _msg["command_chain"]
	travel_path = command_chain.pop_back()[1]
	
	# Move to the `Wait` state if the travel path only has one point.
	# This indicates that the enemy character's current position is the target destination.
	if travel_path.size() > 1:
		start_point = ec.translation
		next_point = travel_path[next_point_index]
	else:
		_move_to_next_state()


# Corresponds to the `_process()` callback.
func update(delta: float) -> void:
	# Move the enemy character towards the next tile.
	weight += delta * ec.stats.get_mvmt_speed()
	weight = 1.0 if weight > 1.0 else weight
	var li: Vector3 = start_point.linear_interpolate(
		next_point,
		weight
	)
	ec.move_collisions(li)
	
	# When finished moving to next tile, check to see if path has been fully
	# traversed. Move to the `Wait` state when path has been fully traversed.
	if weight >= 1.0:
		next_point_index += 1
		if next_point_index < travel_path.size():
			weight = 0.0
			start_point = ec.translation
			next_point = travel_path[next_point_index]
		else:
			_move_to_next_state()


# Called by the state machine before changing the active state.
# Resets the interpolation weight an next_point_index.
func exit() -> void:
	weight = 0.0
	next_point_index = 1


# Checks the command chain to determine what state to go to next.
func _move_to_next_state() -> void:
	if command_chain.size() > 0:
		if command_chain.back()[0] == MOVE:
			print("Go to move")
#			state_machine.transition_to(MOVE, {"command_chain": command_chain})
		elif command_chain.back()[0] == ACTION:
			print("Go to action")
#			state_machine.transition_to(ACTION, {"command_chain": command_chain})
	else:
		SignalBus.emit_signal("enemy_turn_ended", ec)
		state_machine.transition_to(WAIT)
