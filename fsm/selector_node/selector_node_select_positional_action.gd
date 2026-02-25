class_name SelectorNodeSelectPositionalAction
extends SelectorNodeSelectAction
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
	if _action.is_centered_on_caster():
		_update_hovered_tile(_character_map_index)
	else:
		_place_closest_to_target()
	selector.emit_new_focus_point(_action.get_emission_pos())


## Updates the hovered tile tracked by the selector.
func _update_hovered_tile(tile_index: int) -> void:
	selector.tile_hovered = selector.hex_map.get_tile_at(tile_index)
	_action.set_emission_map_index(tile_index)
	_action.set_emission_pos(selector.tile_hovered.get_character_position())
	selector.emit_new_focus_point(selector.tile_hovered.get_character_position())
	_highlight_effect_range()


## Update the selection for a given tile.
## Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(map_tile: MapTile) -> void:
	assert(map_tile != null, "SelectAction given a null MapTile.")
	MouseHandler.update_mouse_tracker_3d(map_tile.get_character_position())
	# Actions centered on caster should not update the selection. Also, actions
	# with dead range need to display the character tile highlight, but not
	# allow emission from character position.
	if (
		_action.is_centered_on_caster()
		or !map_tile.is_active()
		or (
			_action.stats.dead_range.get_reach() > 0
			and map_tile.map_coordinate.get_tile_index() == _character_map_index
		)
	):
		return
	if _is_target_tile(map_tile):
		selector.tile_hovered = map_tile
		_action.set_emission_map_index(map_tile.map_coordinate.get_tile_index())
		_action.set_emission_pos(map_tile.get_character_position())
		_highlight_effect_range()
	else:
		_place_closest_to_tile(map_tile.map_coordinate.get_tile_index())


## Gets the tile ids of all tiles within the effect range.
func _get_effect_range() -> Array[int]:
	var e_index: int = _action.get_emission_map_index()
	var effect_indexes: Array[int]
	effect_indexes = _action.stats.effect_range.get_area_indexes(
			e_index,
			selector.hex_map
	)
	if _action.stats.effect_ignore_heights:
		# Updates the range cache.
		_ranges_cache[e_index] = effect_indexes
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
	_ranges_cache[e_index] = valid_effect_indexes
	return valid_effect_indexes


## Gets the targets for the current emission area.
func _get_targets() -> Array[Character]:
	return _targets_cache[_action.get_emission_map_index()]


## Update the targets cache to track targets within the effect range.
func _update_targets_cache(effect_range: Array[int]) -> void:
	var e_index: int = _action.get_emission_map_index()
	if _targets_cache.has(e_index):
		return
	var targets: Array[Character] = _get_targets_in_effect_range(effect_range)
	_targets_cache[e_index] = targets


## Places the effect emission so that the effect area highlights the closest
## target. Emission is not placed if no valid tile could be found.
func _place_closest_to_target() -> void:
	var target_details: Array[Variant] = _get_target_distances()[0]
	var target_index: int = target_details[0].map_coordinate.get_tile_index()
	var character_index_details: DistanceData = (
		_source_d_map.all_dist_at(_character_map_index)
	)
	# When processing a spawn action, all character indexes are removed from the
	# source range. We don't need to ignore the index if it is not present.
	var ignore_character_index: bool = (
		_source_d_map.has(_character_map_index)
		and _action.stats.dead_range.get_reach() > 0
	)
	if ignore_character_index:
		_source_d_map.remove(_character_map_index)
	var closest_index: int = selector.hex_map.range_finder.get_closest_in_area(
			target_index,
			_source_d_map.tile_ids()
	)
	# Add back in character details if they were removed to preserve details.
	if ignore_character_index:
		_source_d_map.add(_character_map_index, character_index_details)
	if closest_index < 0:
		selector.hex_map.selection_tracker.clear_selector_highlights()
		return
	selector.tile_hovered = selector.hex_map.get_tile_at(closest_index)
	_action.set_emission_map_index(closest_index)
	_action.set_emission_pos(selector.tile_hovered.get_character_position())
	_highlight_effect_range()


## Places the effect emission so that it is on the source tile closest to the
## specified tile. Emission is not placed if no valid source tile could be found.
func _place_closest_to_tile(tile_index: int) -> void:
	var character_index_details: DistanceData = (
		_source_d_map.all_dist_at(_character_map_index)
	)
	var ignore_character_index: bool = _action.stats.dead_range.get_reach() > 0
	# Remove character index when looking at dead range to prevent character
	# position from being considered a valid placement spot.
	if ignore_character_index:
		_source_d_map.remove(_character_map_index)
	var closest_index: int = selector.hex_map.range_finder.get_closest_in_area(
			tile_index,
			_source_d_map.tile_ids()
	)
	# Add back in character details if they were removed to preserve distance
	# map.
	if ignore_character_index:
		_source_d_map.add(_character_map_index, character_index_details)
	if closest_index < 0:
		selector.hex_map.selection_tracker.clear_selector_highlights()
		return
	_update_hovered_tile(closest_index)
