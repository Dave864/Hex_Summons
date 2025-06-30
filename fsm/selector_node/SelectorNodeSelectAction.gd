extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectAction' state.
Retrieves the tile ids of the effect area whenever the selector moves.
Goes to the 'SelectAction' state when a new action is hovered over.
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
# Caches the tile ids of the effect area at different emission points.
var _effect_ranges: Dictionary = {}

# Reference to the function that will update the tile highlights.
onready var _update_selection_ref: FuncRef = funcref(self, "_update_selection")


func enter(msg: Dictionary = {}) -> void:
	_determine_changes(msg["action"])
	_highlight_source_range()
	selector.set_update_selection_func(_update_selection_ref)
	_connect_signals()
	if _action.emit_from_center:
		_orient_to_closest_target()
	else:
		_place_on_closest_target()


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
	# Mouse input handled by Selector via _update_selection.
	if InputController.get_source() == InputController.Source.GAMEPAD:
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
		need_new_ranges = true
	var player_map_index: int = selector.active_player.map_coordinate.get_index()
	if _player_map_index != player_map_index:
		_player_map_index = player_map_index
		_player_pos = selector.active_player.translation
		need_new_ranges = true
	if need_new_ranges:
		_effect_ranges.clear()


# Update the selection for a given tile.
# Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(map_tile: MapTile) -> void:
	MouseHandler.update_mouse_tracker_3d(map_tile.get_character_position())
	if !map_tile.is_active():
		return
	if _action.emit_from_center:
		selector.tile_hovered = map_tile
		if InputController.get_source() == InputController.Source.KEYBOARD_AND_MOUSE:
			_orient_emission_to_mouse()
		elif InputController.get_source() == InputController.Source.GAMEPAD:
			_orient_emission_to_tile(map_tile)
	elif _is_target_tile(map_tile):
		selector.tile_hovered = map_tile
		_action.set_emission_map_index(map_tile.map_coordinate.get_index())
		_highlight_effect_range()


# Orients the direction of an action cast from the player based on mouse position.
func _orient_emission_to_mouse() -> void:
	_action.set_emission_map_index(_player_map_index)
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
	var player_pt: Vector2 = Vector2(_player_pos.x, _player_pos.z)
	var tile_pt: Vector2 = Vector2(map_tile.translation.x, map_tile.translation.z)
	var vector_dir: Vector2 = (tile_pt - player_pt).normalized()
	# Relative top not needed as we are using direct map coordinates.
	var emission_dir: int = HexUtil.get_hex_direction(vector_dir)
	_action.set_emission_direction(emission_dir)
	_highlight_effect_range()


# Orients the action emission to the closest valid target.
func _orient_to_closest_target() -> void:
	var target_distances: Array = _get_target_distances()
	# Get the map tile the target is at.
	var target_index: int = target_distances[0][0].map_coordinate.get_index()
	var target_tile: MapTile = selector.hex_map.get_tile_at(target_index)
	_orient_emission_to_tile(target_tile)


# Places the effect emission so that the effect area highlights the closest
# target. Effect is positioned on player otherwise.
func _place_on_closest_target() -> void:
	var target_details: Array = _get_target_distances()[0]
	var target_index: int = target_details[0].map_coordinate.get_index()
	# Get the full range of the action.
	var outer_action_range: float = (
			_action.effect_range.get_reach() \
			+ _action.source_range.get_reach()
	)
	var inner_action_range: float = clamp(
			_action.dead_range.get_reach() \
			- _action.effect_range.get_reach(),
			0.0,
			_action.dead_range.get_reach()
	)
	# Set emission point if target is within source range.
	if (
		target_details[1] <= _action.source_range.get_reach()
		and target_details[1] > _action.dead_range.get_reach()
	):
		selector.tile_hovered = selector.hex_map.get_tile_at(target_index)
		_action.set_emission_map_index(target_index)
	# Set the emission point to the tile closest to the target.
	elif (
		target_details[1] <= outer_action_range
		and target_details[1] >= inner_action_range
	):
		var closest_index: int = selector.hex_map.range_finder.get_closest_index_toward(
				_player_map_index,
				target_index,
				_get_source_range()
		)
		selector.tile_hovered = selector.hex_map.get_tile_at(closest_index)
		_action.set_emission_map_index(closest_index)
	# Set to player position if target is out of range.
	else:
		selector.tile_hovered = selector.hex_map.get_tile_at(_player_map_index)
		_action.set_emission_map_index(_player_map_index)
	_highlight_effect_range()


# Gets an array of the targets sorted by distance from player. The closest
# target is at the first index. Each index contains the target character and distance.
func _get_target_distances() -> Array:
	"""
	TODO: Update to determine if players, enemies, or both are valid targets.
	Currently only looks for enemies.
	"""
	var potential_targets: Array = selector.enemies_ref
	var target_distances: Array = []
	for option in potential_targets:
		var dist: float = selector.hex_map.range_finder.calculate_distance(
				_player_map_index,
				option.map_coordinate.get_index()
		)
		target_distances.append([option, dist])
	target_distances.sort_custom(ArraySorters, "sort_distance_to_character_asc")
	return target_distances


# Checks if a given map tile is a valid target for an action.
func _is_target_tile(map_tile: MapTile) -> bool:
	"""
	TODO: Update action to get the effect target details
	"""
	return (
		map_tile != null
		and (
			map_tile.get_highlight_type() == HexHighlighter.Option.RANGE
			or map_tile.get_highlight_type() == HexHighlighter.Option.TARGET
			or map_tile.get_highlight_type() == HexHighlighter.Option.PLAYER
		)
	)


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
	selector.hex_map.selection_tracker.select_effect_range(
			_get_effect_range(),
			_player_map_index,
			_action.effect_ignores_caster,
			_action.get_is_cardinal()
	)


# Gets the tile ids of all tiles within the source range. Accounts for dead range.
func _get_source_range() -> Array:
	var source_range: Dictionary = selector.hex_map.range_finder.get_distance_map(
			_player_map_index,
			_action.source_ignore_heights,
			_action.source_range.get_reach()
	)
	var dead_indexes: Array = _action.dead_range.determine_area_indexes(
			_player_map_index,
			selector.hex_map
	)
	for index in dead_indexes:
		if source_range.has(index):
			source_range.erase(index)
	return source_range.keys()


# Gets the tile ids of all tiles within the effect range.
func _get_effect_range() -> Array:
	var emission_index: int = _action.get_emission_map_index()
	if _effect_ranges.has(emission_index):
		return _effect_ranges[emission_index]
	var effect_indexes: Array = _action.effect_range.determine_directional_area_indexes(
			emission_index,
			_action.get_emission_direction(),
			selector.hex_map
	)
	if _action.effect_ignore_heights:
		_effect_ranges[emission_index] = effect_indexes
		return effect_indexes
	var effect_d_map: Dictionary = selector.hex_map.range_finder.get_distance_map(
			emission_index,
			false,
			_action.effect_range.get_reach()
	)
	var valid_effect_indexes: Array = []
	for index in effect_indexes:
		if effect_d_map.has(index):
			valid_effect_indexes.append(index)
	_effect_ranges[emission_index] = valid_effect_indexes
	return valid_effect_indexes


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
	state_machine.transition_to(SELECT_ACTION, {"action": new_action})


# Go to the "SelectMove" state when the player action selection is canceled.
func _on_SignalBus_player_action_type_canceled() -> void:
	if not _state_is_active():
		return
	selector.hex_map.selection_tracker.clear_highlights()
	selector.hex_map.selection_tracker.clear_selector_highlights()
	state_machine.transition_to(SELECT_MOVE)


# Go to the "WAIT" state when a player has signaled that their turn is ended.
func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	_player_map_index = -1
	_player_pos = Vector3.ZERO
	_effect_ranges.clear()
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
