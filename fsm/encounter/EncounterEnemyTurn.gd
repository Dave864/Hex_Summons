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
# The index of tiles that the enemy can move to.
var _movement_range: Array = []


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_active_char = enc.get_current_character()
	_movement_range = enc.hex_map.range_finder.get_character_travesible_tiles(
		_active_char,
		enc.players
	)
	_connect_signals()
	SignalBus.emit_enemy_turn_started(_active_char)


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Move to the `End` State
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	_active_char.disconnect(
			"enemy_actions_required",
			self,
			"_on_EnemyCharacter_enemy_actions_required"
	)
	_active_char.disconnect(
			"enemy_turn_ended",
			self,
			"_on_EnemyCharacter_enemy_turn_ended"
	)


# Connect the relevant signals to this state.
# These signals are used by other states and will be disconnected to avoid
# unintended behavior.
func _connect_signals() -> void:
	ErrorUtil.connect_signal(
			_active_char,
			"enemy_actions_required",
			self,
			"_on_EnemyCharacter_enemy_actions_required"
	)
	ErrorUtil.connect_signal(
			_active_char,
			"enemy_turn_ended",
			self,
			"_on_EnemyCharacter_enemy_turn_ended"
	)


# Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	_active_char.disconnect(
			"enemy_actions_required",
			self,
			"_on_EnemyCharacter_enemy_actions_required"
	)
	_active_char.disconnect(
			"enemy_turn_ended",
			self,
			"_on_EnemyCharacter_enemy_turn_ended"
	)


# Determines the actions that the enemy character should take given the current
# state of the encounter. Emits the enemy_actions_confirmed.
func _determine_action_chain() -> void:
	"""
	TODO: Implement logic for determining what actions to take.
	For now, the enemy character moves as close as it can to the closest player
	character.
	"""
	var action_chain: Array = []
	var path: PoolVector3Array = (
			enc.hex_map.range_finder.get_character_point_path_toward(
				_active_char,
				_determine_closest_player_index(),
				enc.enemies,
				enc.players,
				_movement_range
			)
	)
#	enc.move_path.create_segmented_bezier_path(path)
	action_chain.push_front([EnemyCharacterState.MOVE, path])
#	# Pause for a little bit to give the EncounterUI a chance to get ready.
#	# Workaround for bug where not moving the player causes the UI to not appear.
#	yield(get_tree().create_timer(0.1), "timeout")
	SignalBus.emit_enemy_actions_confirmed(action_chain)


# Gets the map index of the player character closest to the active enemy.
func _determine_closest_player_index() -> int:
	var player_distances: Array = []
	for p in enc.players:
		var p_data: Array = [
			p, 
			enc.hex_map.range_finder.travel_distance(
					_active_char.map_coordinate.get_index(),
					p.map_coordinate.get_index()
			)
		]
		player_distances.append(p_data)
	
	player_distances.sort_custom(ArraySorters, "sort_distance_to_character_asc")
	return player_distances[0][0].map_coordinate.get_index()


func _on_EnemyCharacter_enemy_actions_required() -> void:
	_determine_action_chain()


func _on_EnemyCharacter_enemy_turn_ended() -> void:
	yield(_active_char, "is_waiting")
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
