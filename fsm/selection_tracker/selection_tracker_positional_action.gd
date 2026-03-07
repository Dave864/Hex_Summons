class_name SelectionTrackerPositionalAction
extends SelectionTrackerAction
## The logic for what happens when the Selector is in the
## 'SelectPositionalAction' state. Handles the selection display of ranges
## from actions that are cast on a position.
##
## Goes to 'SelectPositionalaction' or 'SelectDirectional' action if a different
## corresponding action is selected. Goes to the 'SelectMove' state when the UI
## signals that the action type has been canceled. Goes to the 'Wait' state when
## the UI signals that the character turn has ended.


## Checks that all state data has been provided and places the selector.
func enter(msg: Dictionary[Variant, Variant] = {}) -> void:
	super.enter(msg)
	var action: Action = s_tracker.get_focus_action()
	if action.is_centered_on_caster():
		s_tracker.emit_camera_focus_locked()
		selector.tile_hovered = hex_map.get_tile_at(s_tracker.player_index)
		_update_emission_tile(s_tracker.player_index)
	else:
		_place_closest_to_target()


## Updates the emission tile for the focused action.
func _update_emission_tile(tile_index: int) -> void:
	var action: Action = s_tracker.get_focus_action()
	var character_pos: Vector3 = selector.tile_hovered.get_character_position()
	action.set_emission_map_index(tile_index)
	action.set_emission_pos(character_pos)
	s_tracker.emit_new_focus_point(character_pos)
	_highlight_effect_range()


## Update the selection for a given tile.
## Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(map_tile: MapTile) -> void:
	assert(map_tile != null, "SelectAction given a null MapTile.")
	var action: Action = s_tracker.get_focus_action()
	MouseHandler.update_mouse_tracker_3d(map_tile.get_character_position())
	# Actions centered on caster should not update the selection.
	if action.is_centered_on_caster():
		return
	action.set_emission_map_index(map_tile.map_coordinate.get_tile_index())
	action.set_emission_pos(map_tile.get_character_position())
	if _is_target_tile(map_tile):
		selector.tile_hovered = map_tile
		if InputController.source_is_gamepad():
			s_tracker.emit_new_focus_point(map_tile.get_character_position())
		_highlight_effect_range()
	else:
		# Turn off previous selector indicators to indicate a new tile is being
		# hovered over.
		if _is_target_tile(selector.tile_hovered):
			s_tracker.clear_indicators()
		else:
			selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
		selector.tile_hovered = map_tile
		if InputController.source_is_gamepad():
			s_tracker.emit_new_focus_point(map_tile.get_character_position())
		map_tile.set_selector_type(HexHighlighter.Option.GRAY)


## Determines if the selector is able to move to the adjacent tile in the
## given direction and does so if able.
func _resolve_joystick_for_area(dir: HexUtil.HexDirection) -> void:
	var adjacent_tile: MapTile = selector.tile_hovered.get_adjacent_tile(dir)
	if adjacent_tile != null:
		_update_selection(adjacent_tile)


## Places the effect emission so that the effect area highlights the closest
## target. Emission is not placed if no valid tile could be found.
func _place_closest_to_target() -> void:
	var action: Action = s_tracker.get_focus_action()
	var target_details: Array[Variant] = _get_target_distances()[0]
	var target_index: int = target_details[0].map_coordinate.get_tile_index()
	var character_index_details: DistanceData = (
		s_tracker.source_d_map.all_dist_at(s_tracker.player_index)
	)
	# When processing a spawn action, all character indexes are removed from the
	# source range. We don't need to ignore the index if it is not present.
	var ignore_character_index: bool = (
		s_tracker.source_d_map.has(s_tracker.player_index)
		and action.stats.dead_range.get_reach() > 0
	)
	if ignore_character_index:
		s_tracker.source_d_map.remove(s_tracker.player_index)
	var closest_index: int = hex_map.range_finder.get_closest_in_area(
			target_index,
			s_tracker.source_d_map.tile_ids()
	)
	# Add back in character details if they were removed to preserve details.
	if ignore_character_index:
		s_tracker.source_d_map.add(
				s_tracker.player_index,
				character_index_details
		)
	if closest_index < 0:
		s_tracker.clear_indicators()
		return
	# Set selector to 'NONE' to account for instances where selector was
	# outside of source range.
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	selector.tile_hovered = hex_map.get_tile_at(closest_index)
	action.set_emission_map_index(closest_index)
	action.set_emission_pos(selector.tile_hovered.get_character_position())
	_highlight_effect_range()
	s_tracker.emit_new_focus_point(action.get_emission_pos())


## Places the effect emission so that it is on the source tile closest to the
## specified tile. Emission is not placed if no valid source tile could be found.
func _place_closest_to_tile(tile_index: int) -> void:
	var character_index_details: DistanceData = (
		s_tracker.source_d_map.all_dist_at(s_tracker.player_index)
	)
	var action: Action = s_tracker.get_focus_action()
	var ignore_character_index: bool = action.stats.dead_range.get_reach() > 0
	# Remove character index when looking at dead range to prevent character
	# position from being considered a valid placement spot.
	if ignore_character_index:
		s_tracker.source_d_map.remove(s_tracker.player_index)
	var closest_index: int = hex_map.range_finder.get_closest_in_area(
			tile_index,
			s_tracker.source_d_map.tile_ids()
	)
	# Add back in character details if they were removed to preserve distance
	# map.
	if ignore_character_index:
		s_tracker.source_d_map.add(
				s_tracker.player_index,
				character_index_details
		)
	if closest_index < 0:
		s_tracker.clear_indicators()
		return
	_update_emission_tile(closest_index)
