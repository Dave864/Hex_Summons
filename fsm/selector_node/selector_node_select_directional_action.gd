class_name SelectorNodeSelectDirectionalAction
extends SelectorNodeSelectAction
## The logic for what happens when the Selector is in the
## 'SelectDirectionalAction' state. Handles the selection display of ranges
## that are emitted from the caster's position in a specific direction.
##
## Goes to 'SelectPositionalaction' or 'SelectDirectional' action if a different
## corresponding action is selected. Goes to the 'SelectMove' state when the UI
## signals that the action type has been canceled. Goes to the 'Wait' state when
## the UI signals that the character turn has ended.


## Checks that all state data has been provided and places the selector.
func enter(msg: Dictionary[Variant, Variant] = {}) -> void:
	super.enter(msg)
	selector.emit_camera_focus_locked()
	_orient_to_closest_target()
	selector.emit_new_focus_point(_action.get_emission_pos())


## Handles input events.
func handle_input(_event: InputEvent) -> void:
	# Handles the instances where the mouse goes over an area without a map tile.
	if InputController.source_is_keymouse():
		_orient_emission_to_mouse()
	if InputController.source_is_gamepad():
		var joy_dir: Vector2 = GamepadHandler.left_joystick_dir()
		if not joy_dir.is_zero_approx():
			var dir: int = HexUtil.get_hex_direction(
					joy_dir,
					selector.top_vertex
			)
			_resolve_joystick_for_direction(dir)


## Update the selection for a given tile.
## Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(map_tile: MapTile) -> void:
	assert(map_tile != null, "SelectAction given a null MapTile.")
	MouseHandler.update_mouse_tracker_3d(map_tile.get_character_position())
	selector.tile_hovered = map_tile
	# Orienting to mouse position is handled by handle_input.
	if InputController.get_source() == InputController.Source.GAMEPAD:
		_orient_emission_to_tile(map_tile)


## Gets the tile ids of all tiles within the effect range.
func _get_effect_range() -> Array[int]:
	var e_index: int = _action.get_emission_map_index()
	var e_dir: int = _action.get_emission_direction()
	if _ranges_cache.has(e_dir):
		return _ranges_cache[e_dir]
	var effect_indexes: Array[int]
	effect_indexes = _action.stats.effect_range.get_dir_area_indexes(
			e_index,
			e_dir,
			selector.hex_map
	)
	if _action.stats.effect_ignore_heights:
		# Updates the range cache.
		_ranges_cache[e_dir] = effect_indexes
		return effect_indexes
	var d_map: DistanceMap = selector.hex_map.range_finder.dist_maps.at(e_index)
	var effect_d_map: DistanceMap = (
			d_map.map_from_travel_dist(_action.stats.effect_range.get_reach())
	)
	var valid_effect_indexes: Array[int] = []
	for index: int in effect_indexes:
		if effect_d_map.has(index):
			valid_effect_indexes.append(index)
	# Updates the range cache.
	_ranges_cache[e_dir] = valid_effect_indexes
	return valid_effect_indexes


## Gets the targets for the current emission area.
func _get_targets() -> Array[Character]:
	return _targets_cache[_action.get_emission_direction()]


## Gets the characters that will be hit by the action.
func _update_targets_cache(effect_range: Array[int]) -> void:
	var e_dir: int = _action.get_emission_direction()
	# Don't update if cache is already tracking the direction.
	if _targets_cache.has(e_dir):
		return
	var targets: Array[Character] = _get_targets_in_effect_range(effect_range)
	_targets_cache[e_dir] = targets


## Orients the direction of an action cast from the character based on mouse
## position.
func _orient_emission_to_mouse() -> void:
	_action.set_emission_map_index(_character_map_index)
	_action.set_emission_pos(_character_pos)
	var character_pt: Vector2 = Vector2(_character_pos.x, _character_pos.z)
	var mouse_pt: Vector2 = Vector2(
		MouseHandler.get_3d_position().x,
		MouseHandler.get_3d_position().z
	)
	# Relative top not needed as mouse position translates to direct map
	# coordinates.
	var vector_to_mouse: Vector2 = (mouse_pt - character_pt).normalized()
	var dir: int = HexUtil.get_hex_direction(vector_to_mouse)
	var source_tile: MapTile = selector.hex_map.get_tile_at(_character_map_index)
	var target_tile: MapTile = source_tile.get_adjacent_tile(dir)
	if _is_target_tile(target_tile):
		_action.set_emission_direction(dir)
		_highlight_effect_range()


## Orients the direction of an action cast from the character based on tile
## position.
func _orient_emission_to_tile(map_tile: MapTile) -> void:
	_action.set_emission_map_index(_character_map_index)
	_action.set_emission_pos(_character_pos)
	var character_pt: Vector2 = Vector2(_character_pos.x, _character_pos.z)
	var tile_pt: Vector2 = Vector2(map_tile.position.x, map_tile.position.z)
	var vector_dir: Vector2 = (tile_pt - character_pt).normalized()
	# Relative top not needed as we are using direct map coordinates.
	var emission_dir: int = HexUtil.get_hex_direction(vector_dir)
	_action.set_emission_direction(emission_dir)
	# No need to fix orientation for radial effect ranges.
	if _action.stats.effect_range is RadialAreaRange or _fix_orientation():
		_highlight_effect_range()
	else:
		selector.hex_map.selection_tracker.clear_selector_highlights()


## Orients the action emission to the closest valid target.
func _orient_to_closest_target() -> void:
	var target_distances: Array[Array] = _get_target_distances()
	var target_index: int = target_distances[0][0].map_coordinate.get_tile_index()
	var target_tile: MapTile = selector.hex_map.get_tile_at(target_index)
	_orient_emission_to_tile(target_tile)


## Adjusts the orientation of an effect emitted from caster to make sure it is
## in a direction the character can reach. Returns if the direction was set.
func _fix_orientation() -> bool:
	var p_cube: Vector3 = HexUtil.index_to_cube(
			_character_map_index,
			selector.hex_map.get_x_count()
	)
	for i in 6:
		var dir: int = posmod(_action.get_emission_direction() + i, 6)
		var dir_cube: Vector3 = HexUtil.CUBE_DIRECTION_VECTORS[dir] + p_cube
		var dir_index: int = HexUtil.cube_to_index(
				dir_cube,
				selector.hex_map.get_x_count()
		)
		if (
			selector.hex_map.is_valid_cube(dir_cube)
			and _source_d_map.has(dir_index)
		):
			_action.set_emission_direction(dir)
			return true
	return false


## Determines if the selector is able to move to the given direction and does
## so if able.
func _resolve_joystick_for_direction(dir: HexUtil.HexDirection) -> void:
	var character_tile: MapTile = selector.hex_map.get_tile_at(
			_character_map_index
	)
	var direction_tile: MapTile = character_tile.get_adjacent_tile(dir)
	if _is_target_tile(direction_tile):
		_update_selection(direction_tile)
