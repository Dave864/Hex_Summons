extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectAction' state.
Goes to the 'SelectAction' state when a new action is chosen.
Goes to the 'SelectMove' state when the UI signals that the action type has
been canceled. Goes to the 'Wait' state when the UI signals that the player
turn has been terminated.
"""


# The action to display the effect area for.
var _action: Action = null
# The translation of the player that is using the action.
var _player_pos: Vector3 = Vector3.ZERO
# The tile index of the player that is using the action.
var _player_map_index: int = -1
# Stores the distance map of the source range.
var _source_d_map: Dictionary = {}
# The type of targets the action will hit.
var _action_targets: Dictionary = {}
# Caches the tile ids of the effect area at different emission points.
var _ranges_cache: Dictionary = {}
# Caches the characters that the action will hit at different emission points.
var _targets_cache: Dictionary = {}

# Reference to the function that will update the tile highlights.
onready var _update_selection_ref: FuncRef = funcref(self, "_update_selection")


func enter(msg: Dictionary = {}) -> void:
	assert(msg.has("action"), "Missing action key data in SelectAction")
	assert(
			msg["action"] is Action,
			"Data at action key is not an Action in SelectAction."
	)
	_determine_changes(msg["action"])
	_highlight_source_range()
	selector.set_update_selection_func(_update_selection_ref)
	_connect_signals()
	if _action.emit_from_center:
		_orient_to_closest_target()
	else:
		_place_closest_to_target()


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.set_update_selection_func(null)
	SignalBus.disconnect(
			"player_action_selected",
			self,
			"_on_SignalBus_player_action_selected"
	)
	SignalBus.disconnect(
			"player_action_type_canceled",
			self,
			"_on_SignalBus_player_action_type_canceled"
	)
	SignalBus.disconnect(
			"player_turn_ended",
			self,
			"_on_SignalBus_player_turn_ended"
	)
	SignalBus.disconnect(
			"top_vertex_changed",
			self,
			"_on_SignalBus_top_vertex_changed"
	)
	GamepadHandler.disconnect(
			"left_joystick_pulsed",
			self,
			"_on_GamepadHandler_left_joystick_pulsed"
	)


# Handles input events.
func handle_input(_event: InputEvent) -> void:
	# Handles the instances where the mouse goes over an area without a map tile.
	if InputController.get_source() == InputController.Source.KEYBOARD_AND_MOUSE:
		if _action.emit_from_center:
			_orient_emission_to_mouse()
	elif InputController.get_source() == InputController.Source.GAMEPAD:
		var joy_dir: Vector2 = GamepadHandler.left_joystick_dir()
		if _action.emit_from_center and not joy_dir.is_zero_approx():
			var dir: int = HexUtil.get_hex_direction(joy_dir, selector.top_vertex)
			_resolve_joystick_for_cardinal(dir)


# Checks if the action being processed is the same as last time and if the
# cached effect ranges can be reused
func _determine_changes(action: Action) -> void:
	var need_new_ranges: bool = false
	if action != _action:
		_action = action
		_action_targets = _action.get_targets()
		need_new_ranges = true
	var player_map_index: int = selector.active_player.map_coordinate.get_index()
	if _player_map_index != player_map_index:
		_player_map_index = player_map_index
		_player_pos = selector.active_player.translation
		need_new_ranges = true
	if need_new_ranges:
		_source_d_map.clear()
		_ranges_cache.clear()
		_targets_cache.clear()


# Update the selection for a given tile.
# Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(map_tile: MapTile) -> void:
	assert(map_tile != null, "SelectAction given a null MapTile.")
	MouseHandler.update_mouse_tracker_3d(map_tile.get_character_position())
	# Actions with dead range need to display the player tile highlight, but
	# not allow emission from player position.
	if (
		!map_tile.is_active()
		or (
			_action.dead_range.get_reach() > 0
			and map_tile.map_coordinate.get_index() == _player_map_index
		)
	):
		return
	if _action.emit_from_center:
		selector.tile_hovered = map_tile
		# Orienting to mouse position is handled by handle_input.
		if InputController.get_source() == InputController.Source.GAMEPAD:
			_orient_emission_to_tile(map_tile)
	elif _is_target_tile(map_tile):
		selector.tile_hovered = map_tile
		_action.set_emission_map_index(map_tile.map_coordinate.get_index())
		_action.set_emission_pos(map_tile.get_character_position())
		_highlight_effect_range()
	else:
		_place_closest_to_tile(map_tile.map_coordinate.get_index())


# Orients the direction of an action cast from the player based on mouse position.
func _orient_emission_to_mouse() -> void:
	_action.set_emission_map_index(_player_map_index)
	_action.set_emission_pos(_player_pos)
	var player_pt: Vector2 = Vector2(_player_pos.x, _player_pos.z)
	var mouse_pt: Vector2 = Vector2(
		MouseHandler.get_3d_position().x,
		MouseHandler.get_3d_position().z
	)
	# Relative top not needed as mouse position translates to direct map coordinates.
	var dir: int = HexUtil.get_hex_direction((mouse_pt - player_pt).normalized())
	var source_tile: MapTile = selector.hex_map.get_tile_at(_player_map_index)
	var target_tile: MapTile = source_tile.get_adjacent_tile(dir)
	if _is_target_tile(target_tile):
		_action.set_emission_direction(dir)
		_highlight_effect_range()


# Orients the direction of an action cast from the player based on tile position.
func _orient_emission_to_tile(map_tile: MapTile) -> void:
	_action.set_emission_map_index(_player_map_index)
	_action.set_emission_pos(_player_pos)
	var player_pt: Vector2 = Vector2(_player_pos.x, _player_pos.z)
	var tile_pt: Vector2 = Vector2(map_tile.translation.x, map_tile.translation.z)
	var vector_dir: Vector2 = (tile_pt - player_pt).normalized()
	# Relative top not needed as we are using direct map coordinates.
	var emission_dir: int = HexUtil.get_hex_direction(vector_dir)
	_action.set_emission_direction(emission_dir)
	# No need to fix orientation for non-cardinal effect ranges.
	if not _action.get_is_cardinal() or _fix_orientation():
		_highlight_effect_range()
	else:
		selector.hex_map.selection_tracker.clear_selector_highlights()


# Orients the action emission to the closest valid target.
func _orient_to_closest_target() -> void:
	var target_distances: Array = _get_target_distances()
	var target_index: int = target_distances[0][0].map_coordinate.get_index()
	var target_tile: MapTile = selector.hex_map.get_tile_at(target_index)
	_orient_emission_to_tile(target_tile)


# Adjusts the orientation of an effect emitted from caster to make sure it is
# in a direction the player can reach. Returns if the direction was set.
func _fix_orientation() -> bool:
	var p_cube: Vector3 = HexUtil.index_to_cube(
			_player_map_index,
			selector.hex_map.get_x_count()
	)
	for i in 6:
		var dir: int = posmod(_action.get_emission_direction() + i, 6)
		var dir_cube: Vector3 = HexUtil.CUBE_DIRECTION_VECTORS[dir] + p_cube
		var dir_index: int = HexUtil.cube_to_index(
				dir_cube,
				selector.hex_map.get_x_count()
		)
		if selector.hex_map.is_valid_cube(dir_cube) and _source_d_map.has(dir_index):
			_action.set_emission_direction(dir)
			return true
	return false


# Places the effect emission so that the effect area highlights the closest
# target. Emission is not placed if no valid tile could be found.
func _place_closest_to_target() -> void:
	var target_details: Array = _get_target_distances()[0]
	var target_index: int = target_details[0].map_coordinate.get_index()
	var player_index_details: Dictionary = _source_d_map[_player_map_index]
	var ignore_player_index: bool = _action.dead_range.get_reach() > 0
	if ignore_player_index:
		_source_d_map.erase(_player_map_index)
	var closest_index: int = selector.hex_map.range_finder.get_closest_in_area(
			target_index,
			_source_d_map
	)
	# Add back in player details if they were removed to preserve details.
	if ignore_player_index:
		_source_d_map[_player_map_index] = player_index_details
	if closest_index < 0:
		selector.hex_map.selection_tracker.clear_selector_highlights()
		return
	selector.tile_hovered = selector.hex_map.get_tile_at(closest_index)
	_action.set_emission_map_index(closest_index)
	_action.set_emission_pos(selector.tile_hovered.get_character_position())
	_highlight_effect_range()


# Places the effect emission so that it is on the source tile closest to the
# specified tile. Emission is not placed if no valid source tile could be found.
func _place_closest_to_tile(tile_index: int) -> void:
	var player_index_details: Dictionary = _source_d_map[_player_map_index]
	var ignore_player_index: bool = _action.dead_range.get_reach() > 0
	if ignore_player_index:
		_source_d_map.erase(_player_map_index)
	var closest_index: int = selector.hex_map.range_finder.get_closest_in_area(
			tile_index,
			_source_d_map
	)
	# Add back in player details if they were removed to preserve distance map.
	if ignore_player_index:
		_source_d_map[_player_map_index] = player_index_details
	if closest_index < 0:
		selector.hex_map.selection_tracker.clear_selector_highlights()
		return
	selector.tile_hovered = selector.hex_map.get_tile_at(closest_index)
	_action.set_emission_map_index(closest_index)
	_action.set_emission_pos(selector.tile_hovered.get_character_position())
	_highlight_effect_range()


# Gets an array of the targets sorted by distance from player. The closest
# target is at the first index. Each index contains the target character and distance.
func _get_target_distances() -> Array:
	var potential_targets: Array = []
	if _action_targets.has(EffectAspect.Target.OPPONENTS):
		potential_targets.append_array(selector.enemies_ref)
	if _action_targets.has(EffectAspect.Target.ALLIES):
		potential_targets.append_array(selector.players_ref)
	
	var target_distances: Array = []
	for option in potential_targets:
		var dist: float = selector.hex_map.range_finder.travel_distance(
				_player_map_index,
				option.map_coordinate.get_index()
		)
		target_distances.append([option, dist])
	target_distances.sort_custom(ArraySorters, "sort_distance_to_character_asc")
	return target_distances


# Checks if a given map tile is a valid target for an action.
func _is_target_tile(map_tile: MapTile) -> bool:
	if map_tile == null:
		return false
	var is_caster: bool = map_tile.map_coordinate.get_index() == _player_map_index
	match map_tile.get_highlight_type():
		HexHighlighter.Option.RANGE:
			return true
		HexHighlighter.Option.TARGET:
			return _action_targets.has(EffectAspect.Target.OPPONENTS)
		HexHighlighter.Option.PLAYER:
			return (
				(
					_action_targets.has(EffectAspect.Target.SELF) 
					and is_caster
				)
				or _action_targets.has(EffectAspect.Target.ALLIES)
			)
		_:
			return false


# Updates the selection display to show the source area.
func _highlight_source_range() -> void:
	selector.hex_map.selection_tracker.clear_highlights()
	selector.hex_map.selection_tracker.highlight_action_source_area(
			_get_source_range(),
			selector.active_player
	)


# Updates the selection display to show the effect area.
func _highlight_effect_range() -> void:
	selector.hex_map.selection_tracker.clear_selector_highlights()
	var effect_range: Array = _get_effect_range()
	_update_targets(effect_range)
	selector.hex_map.selection_tracker.select_effect_range(
			effect_range,
			_player_map_index,
			_action.get_emission_map_index(),
			_action.effect_ignores_caster,
			_action.get_is_cardinal()
	)


# Gets the tile ids of all tiles within the source range. Accounts for dead range.
func _get_source_range() -> Array:
	_source_d_map = selector.hex_map.range_finder.get_distance_map(
			_player_map_index,
			_action.source_ignore_heights,
			_action.source_range.get_reach()
	)
	var dead_indexes: Array = _action.dead_range.get_area_indexes(
			_player_map_index,
			selector.hex_map
	)
	for index in dead_indexes:
		if index != _player_map_index and _source_d_map.has(index):
			_source_d_map.erase(index)
	return _source_d_map.keys()


# Gets the tile ids of all tiles within the effect range.
func _get_effect_range() -> Array:
	var e_index: int = _action.get_emission_map_index()
	var e_dir: int = _action.get_emission_direction()
	if _action.emit_from_center and _ranges_cache.has(e_dir):
		return _ranges_cache[e_dir]
	elif _ranges_cache.has(e_index):
		return _ranges_cache[e_index]
	var effect_indexes: Array = _action.effect_range.get_dir_area_indexes(
			e_index,
			e_dir,
			selector.hex_map
	)
	if _action.effect_ignore_heights:
		_update_effect_ranges(e_index, e_dir, effect_indexes)
		return effect_indexes
	var effect_d_map: Dictionary = selector.hex_map.range_finder.get_distance_map(
			e_index,
			false,
			_action.effect_range.get_reach()
	)
	var valid_effect_indexes: Array = []
	for index in effect_indexes:
		if effect_d_map.has(index):
			valid_effect_indexes.append(index)
	_update_effect_ranges(e_index, e_dir, valid_effect_indexes)
	return valid_effect_indexes


# Gets the targets for the current emission area.
func _get_targets() -> Array:
	if _action.emit_from_center:
		return _targets_cache[_action.get_emission_direction()]
	else:
		return _targets_cache[_action.get_emission_map_index()]


# Updates the _effect_ranges dictionary to store the listed effect indexes
# under either the emission point or direction.
func _update_effect_ranges(e_pt: int, e_dir: int, indexes: Array) -> void:
	if _action.emit_from_center:
		_ranges_cache[e_dir] = indexes
	else:
		_ranges_cache[e_pt] = indexes


# Gets the characters that will be hit by the action.
func _update_targets(effect_range: Array) -> void:
	var e_index: int = _action.get_emission_map_index()
	var e_dir: int = _action.get_emission_direction()
	if (
		(_action.emit_from_center and _targets_cache.has(e_dir))
		or _targets_cache.has(e_index)
	):
		return
	var targets: Array = []
	for index in effect_range:
		var tile: MapTile = selector.hex_map.get_tile_at(index)
		var c: Character = tile.occupant.get_current_occupant()
		if (
			c != null
			and (
				(
					c is EnemyCharacter 
					and _action_targets.has(EffectAspect.Target.OPPONENTS)
				) or (
					c.map_coordinate.get_index() == _player_map_index
					and _action_targets.has(EffectAspect.Target.SELF)
				) or _action_targets.has(EffectAspect.Target.ALLIES)
			)
		):
			targets.append(c)
	if _action.emit_from_center:
		_targets_cache[e_dir] = targets
	else:
		_targets_cache[e_index] = targets


# Changes the state of the targets.
func _change_target_state(active: bool) -> void:
	var targets: Array = _get_targets()
	for t in targets:
		if active:
			t.activate_hit_box()
		else:
			t.deactivate_hit_box()


# Determines if the selector is able to move to the adjacent tile in the
# given direction (0 - 5) and does so if able.
func _resolve_joystick_for_area(dir: int) -> void:
	if dir >= 0 and dir <= 5:
		var adjacent_tile: MapTile = selector.tile_hovered.get_adjacent_tile(dir)
		if adjacent_tile != null and _is_target_tile(adjacent_tile):
			_update_selection(adjacent_tile)


# Determines if the selector is able to move to the given direction (0 - 5)
# and does so if able.
func _resolve_joystick_for_cardinal(dir: int) -> void:
	if dir >= 0 and dir <= 5:
		var player_tile: MapTile = selector.hex_map.get_tile_at(_player_map_index)
		var direction_tile: MapTile = player_tile.get_adjacent_tile(dir)
		if _is_target_tile(direction_tile):
			_update_selection(direction_tile)


# Activates the targets and prompts the action to be executed.
func _execute_action() -> void:
	SignalBus.emit_player_action_executed(selector.active_player, _action)
	_change_target_state(true)
	selector.hex_map.selection_tracker.clear_highlights()
	selector.hex_map.selection_tracker.clear_selector_highlights()
	_action.execute_action()
	SignalBus.emit_player_turn_ended(selector.active_player)


# Connect signals to this state.
func _connect_signals() -> void:
	ErrorUtil.connect_signal(
			SignalBus,
			"player_action_selected",
			self,
			"_on_SignalBus_player_action_selected"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"player_action_type_canceled",
			self,
			"_on_SignalBus_player_action_type_canceled"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"player_turn_ended",
			self,
			"_on_SignalBus_player_turn_ended"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"top_vertex_changed",
			self,
			"_on_SignalBus_top_vertex_changed"
	)
	ErrorUtil.connect_signal(
			GamepadHandler,
			"left_joystick_pulsed",
			self,
			"_on_GamepadHandler_left_joystick_pulsed"
	)


# Go to the "SelectAction" state with the new action.
func _on_SignalBus_player_action_selected(
	_player: PlayerCharacter,
	new_action: Action
) -> void:
	if not _state_is_active():
		return
	elif new_action == _action and not _get_targets().empty():
		_execute_action()
	else:
		state_machine.transition_to(SELECT_ACTION, {"action": new_action})


# Go to the "SelectMove" state when the player action selection is canceled.
func _on_SignalBus_player_action_type_canceled() -> void:
	if not _state_is_active():
		return
	selector.hex_map.selection_tracker.clear_highlights()
	selector.hex_map.selection_tracker.clear_selector_highlights()
	state_machine.transition_to(SELECT_MOVE)


# Go to the "WAIT" state when a player has signaled that their turn is ended.
func _on_SignalBus_player_turn_ended(player: PlayerCharacter) -> void:
	if player != selector.active_player:
		return
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	_change_target_state(false)
	_player_map_index = -1
	_player_pos = Vector3.ZERO
	_ranges_cache.clear()
	_targets_cache.clear()
	_action = null
	state_machine.transition_to(WAIT)


# Update the mouse tracker when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(_vertex: int) -> void:
	MouseHandler.update_mouse_tracker_3d(selector.tile_hovered.get_character_position())


# Resolves the left joystick pulse input. Pulses should only be used when the
# effect is not bound to the caster's position.
func _on_GamepadHandler_left_joystick_pulsed(joy_dir: Vector2) -> void:
	if _action.emit_from_center:
		return
	# Relative top needed as joystick direction does not account for camera orientation.
	var hex_dir: int = HexUtil.get_hex_direction(joy_dir, selector.top_vertex)
	_resolve_joystick_for_area(hex_dir)
