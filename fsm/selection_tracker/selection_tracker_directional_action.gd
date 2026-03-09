class_name SelectionTrackerDirectionalAction
extends SelectionTrackerAction
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
	s_tracker.emit_camera_focus_locked()
	_orient_to_closest_target()
	var emission_pos: Vector3 = s_tracker.get_focus_action().get_emission_pos()
	s_tracker.emit_new_focus_point(emission_pos)


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


## Orients the direction of an action cast from the character based on mouse
## position.
func _orient_emission_to_mouse() -> void:
	var action: Action = s_tracker.get_focus_action()
	var focus_character: Character = s_tracker.focused_character
	var focus_index: int = focus_character.map_coordinate.get_tile_index()
	var focus_pos: Vector3 = focus_character.position
	action.set_emission_map_index(focus_index)
	action.set_emission_pos(focus_pos)
	var character_pt := Vector2(focus_pos.x, focus_pos.z)
	var mouse_pt := Vector2(
		MouseHandler.get_3d_position().x,
		MouseHandler.get_3d_position().z
	)
	# Relative top not needed as mouse position translates to direct map
	# coordinates.
	var vector_to_mouse: Vector2 = (mouse_pt - character_pt).normalized()
	var dir: int = HexUtil.get_hex_direction(vector_to_mouse)
	var source_tile: MapTile = hex_map.get_tile_at(focus_index)
	var target_tile: MapTile = source_tile.get_adjacent_tile(dir)
	if _is_target_tile(target_tile):
		action.set_emission_direction(dir)
		_highlight_effect_range()


## Orients the direction of an action cast from the character based on tile
## position.
func _orient_emission_to_tile(map_tile: MapTile) -> void:
	var action: Action = s_tracker.get_focus_action()
	var character_pos: Vector3 = s_tracker.focused_character.position
	action.set_emission_map_index(s_tracker.player_index)
	action.set_emission_pos(character_pos)
	var character_pt: Vector2 = Vector2(character_pos.x, character_pos.z)
	var tile_pt: Vector2 = Vector2(map_tile.position.x, map_tile.position.z)
	var vector_dir: Vector2 = (tile_pt - character_pt).normalized()
	# Relative top not needed as we are using direct map coordinates.
	var emission_dir: int = HexUtil.get_hex_direction(vector_dir)
	action.set_emission_direction(emission_dir)
	if _fix_orientation():
		_highlight_effect_range()
	else:
		s_tracker.clear_indicators()


## Orients the action emission to the closest valid target.
func _orient_to_closest_target() -> void:
	var target_distances: Array[Array] = _get_target_distances()
	var target_index: int = target_distances[0][0].map_coordinate.get_tile_index()
	var target_tile: MapTile = hex_map.get_tile_at(target_index)
	_orient_emission_to_tile(target_tile)
	# Place the selector at the closest point to keep it within player focus.
	var action: Action = s_tracker.get_focus_action()
	var emission_tile: MapTile = hex_map.get_tile_at(
			action.get_emission_map_index()
	)
	selector.tile_hovered = emission_tile.get_adjacent_tile(
			action.get_emission_direction()
	)


## Adjusts the orientation of an effect emitted from caster to make sure it is
## in a direction the character can reach. Returns if the direction was set.
func _fix_orientation() -> bool:
	var cube_coord: Vector3 = HexUtil.index_to_cube(
			s_tracker.player_index,
			hex_map.get_x_count()
	)
	var action: Action = s_tracker.get_focus_action()
	for i in 6:
		var dir: int = posmod(action.get_emission_direction() + i, 6)
		# Get the cube coordinate of the adjacent tile in the given direction.
		var dir_cube: Vector3 = HexUtil.CUBE_DIRECTION_VECTORS[dir] + cube_coord
		var adjacent_index: int = HexUtil.cube_to_index(
				dir_cube,
				hex_map.get_x_count()
		)
		if (
			hex_map.is_valid_cube(dir_cube)
			and s_tracker.source_d_map.has(adjacent_index)
		):
			action.set_emission_direction(dir)
			return true
	return false


## Determines if the selector is able to move to the given direction and does
## so if able.
func _resolve_joystick_for_direction(dir: HexUtil.HexDirection) -> void:
	var character_tile: MapTile = hex_map.get_tile_at(
			s_tracker.player_index
	)
	var direction_tile: MapTile = character_tile.get_adjacent_tile(dir)
	if _is_target_tile(direction_tile):
		_update_selection(direction_tile)
