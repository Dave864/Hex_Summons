class_name SelectorNodeSelectAction
extends SelectorState
## Base class for the logic for what happens when the Selector is in a state
## intended to manage the selection of actions.
##
## Goes to the relevant action type state when a new action is chosen.
## Goes to the 'SelectMove' state when the UI signals that the action type has
## been canceled. Goes to the 'Wait' state when the UI signals that the
## character turn has been terminated.


## The action to display the effect area for.
var _action: Action = null
## The name of the summon that uses the action on spawn. If empty, the action is
## not used as a spawn action.
var _summon_name: String = ""
## The translation of the character that is using the action.
var _character_pos: Vector3 = Vector3.ZERO
## The tile index of the character that is using the action.
var _character_map_index: int = -1
## Stores the distance map of the source range.
var _source_d_map: DistanceMap = null
## The type of targets the action will hit.
var _action_targets: Dictionary[ActionEffect.Target, bool] = {}
## Caches the tile ids of the effect area at different emission points.
var _ranges_cache: Dictionary[int, Array] = {}
## Caches the characters that the action will hit at different emission points.
var _targets_cache: Dictionary[int, Array] = {}

## Reference to the function that will update the tile highlights.
@onready var _update_selection_ref: Callable = Callable(
		self,
		"_update_selection"
)


## Checks that all state data has been provided and places the selector.
func enter(msg: Dictionary[Variant, Variant] = {}) -> void:
	assert(msg.has("action"), "Missing 'action' key data in SelectAction")
	assert(
			msg["action"] is Action,
			"Data at 'action' key is not an Action in SelectAction."
	)
	assert(
			msg.has("summon"),
			"Missing 'summon' key data in SelectAction"
	)
	assert(
			msg["summon"] is String,
			"Data at 'summon' key is not of type String in SelectAction."
	)
	_summon_name = msg["summon"]
	_determine_range_changes(msg["action"])
	_highlight_source_range()
	selector.set_update_selection_func(_update_selection_ref)
	_connect_signals()


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
func exit() -> void:
	selector.emit_camera_focus_unlocked()
	selector.set_update_selection_func(Callable())
	_disconnect_signals()


## Checks if the action being processed is the same as last time and if the
## cached effect ranges can be reused
func _determine_range_changes(action: Action) -> void:
	var need_new_ranges: bool = false
	if action != _action:
		_action = action
		_action_targets = _action.get_targets()
		need_new_ranges = true
	var character_map_index: int = (
		selector.active_character.map_coordinate.get_tile_index()
	)
	if _character_map_index != character_map_index:
		_character_map_index = character_map_index
		_character_pos = selector.active_character.position
		need_new_ranges = true
	if need_new_ranges:
		if _source_d_map != null:
			_source_d_map.free()
		_ranges_cache.clear()
		_targets_cache.clear()


## Update the selection for a given tile.
## Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(_map_tile: MapTile) -> void:
	pass


## Gets an array of the targets sorted by distance from character. The closest
## target is at the first index. Each index contains the target character and
## distance.
func _get_target_distances() -> Array[Array]:
	var potential_targets: Array[Character] = []
	if _action_targets.has(ActionEffect.Target.OPPONENTS):
		potential_targets.append_array(selector.enemies_ref)
	if _action_targets.has(ActionEffect.Target.ALLIES):
		potential_targets.append_array(selector.players_ref)
	
	var target_distances: Array[Array] = []
	for option: Character in potential_targets:
		var dist: float = selector.hex_map.range_finder.travel_distance(
				_character_map_index,
				option.map_coordinate.get_tile_index()
		)
		target_distances.append([option, dist])
	target_distances.sort_custom(
			Callable(ArraySorters, "sort_distance_to_character_asc")
	)
	return target_distances


## Checks if a given map tile is a valid target for an action.
func _is_target_tile(map_tile: MapTile) -> bool:
	if map_tile == null:
		return false
	var is_caster: bool = (
		map_tile.map_coordinate.get_tile_index() == _character_map_index
	)
	match map_tile.get_highlight_type():
		HexHighlighter.Option.RANGE:
			return true
		HexHighlighter.Option.TARGET:
			return _action_targets.has(ActionEffect.Target.OPPONENTS)
		HexHighlighter.Option.PLAYER:
			return (
				(
					_action_targets.has(ActionEffect.Target.SELF) 
					and is_caster
				)
				or _action_targets.has(ActionEffect.Target.ALLIES)
			)
		_:
			return false


## Updates the selection display to show the source area.
func _highlight_source_range() -> void:
	selector.hex_map.selection_tracker.clear_highlights()
	selector.hex_map.selection_tracker.highlight_action_source_area(
			_get_source_range(),
			selector.active_character
	)


## Updates the selection display to show the effect area.
func _highlight_effect_range() -> void:
	selector.hex_map.selection_tracker.clear_selector_highlights()
	var effect_range: Array[int] = _get_effect_range()
	_update_targets_cache(effect_range)
	selector.hex_map.selection_tracker.select_effect_range(
			effect_range,
			_character_map_index,
			_action.get_emission_map_index(),
			_action.stats.effect_ignores_caster,
			_action.is_directional()
	)


## Gets the tile ids of all tiles within the source range. Accounts for dead
## range.
func _get_source_range() -> Array[int]:
	var d_map: DistanceMap = (
			selector.hex_map.range_finder \
			.dist_maps.at(_character_map_index)
	)
	var source_reach: int = _action.stats.source_range.get_reach()
	_source_d_map = (
			d_map.map_from_tile_dist(source_reach)
			if _action.stats.source_ignore_heights
			else d_map.map_from_travel_dist(source_reach)
	)
	var dead_indexes: Array[int] = _action.stats.dead_range.get_area_indexes(
			_character_map_index,
			selector.hex_map
	)
	var dead_reach: int = _action.stats.dead_range.get_reach()
	for index in dead_indexes:
		if (
			index != _character_map_index 
			and _source_d_map.has(index)
			and (
				_action.stats.source_ignore_heights or
				_source_d_map.travel_dist_at(index) <= dead_reach
			)
		):
			_source_d_map.remove(index)
	if not _summon_name.is_empty():
		_remove_characters_from_source_range()
	return _source_d_map.tile_ids()


## Removes tile indices that contain a character from the current source range.
## Used for spawn actions to prevent their emission point from being placed on
## tiles with characters.
func _remove_characters_from_source_range() -> void:
	for tile_id: int in _source_d_map.tile_ids():
		var map_tile: MapTile = selector.hex_map.get_tile_at(tile_id)
		if map_tile.occupant.get_current_occupant() != null:
			_source_d_map.remove(tile_id)


## Gets the tile ids of all tiles within the effect range.
func _get_effect_range() -> Array[int]:
	return []


## Gets the targets for the current emission area.
func _get_targets() -> Array[Character]:
	return []


## Update the targets cache to track targets within the effect range.
func _update_targets_cache(_effect_range: Array[int]) -> void:
	pass


## Gets the character targets that are within the effect range.
func _get_targets_in_effect_range(effect_range: Array[int]) -> Array[Character]:
	var targets: Array[Character] = []
	var target_enemy: bool = _action_targets.has(ActionEffect.Target.OPPONENTS)
	var target_ally: bool = _action_targets.has(ActionEffect.Target.ALLIES)
	var target_self: bool = _action_targets.has(ActionEffect.Target.SELF)
	for index: int in effect_range:
		var tile: MapTile = selector.hex_map.get_tile_at(index)
		var c: Character = tile.occupant.get_current_occupant()
		if c == null:
			continue
		if (
			target_ally
			or (target_enemy and c is EnemyCharacter)
			or (
				c.map_coordinate.get_tile_index() == _character_map_index
				and target_self
			)
		):
			targets.append(c)
	return targets


## Determines if the selector is able to move to the adjacent tile in the
## given direction and does so if able.
func _resolve_joystick_for_area(dir: HexUtil.HexDirection) -> void:
	var adjacent_tile: MapTile = selector.tile_hovered.get_adjacent_tile(dir)
	if adjacent_tile != null and _is_target_tile(adjacent_tile):
		_update_selection(adjacent_tile)


## Activates the targets and prompts the action to be executed.
func _execute_action() -> void:
	selector.hex_map.selection_tracker.clear_highlights()
	selector.hex_map.selection_tracker.clear_selector_highlights()
	if _summon_name != "":
		selector.emit_spawn_action_confirmed(
				_summon_name,
				_action.get_emission_pos()
		)
	SignalBus.emit_character_action_executed(
			selector.active_character,
			_action,
			_get_targets()
	)
	_reset()
	state_machine.transition_to(PAUSE)


## Clears out the caches and resets recorded details.
func _reset() -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	_character_map_index = -1
	_character_pos = Vector3.ZERO
	_ranges_cache.clear()
	_targets_cache.clear()
	_summon_name = ""
	_action = null


## Executes the action if it has been confirmed, otherwise resetting the
## "SelectAction" state with the new action, specifying if it is a spawn action
## or not.
func _action_selected(action: Action, summon_name: String) -> void:
	if not _state_is_active():
		return
	elif (
		action == _action
		and summon_name == _summon_name
		and not _get_targets().is_empty()
		and _can_execute()
	):
		_execute_action()
	else:
		var next_state: String = (
			SELECT_DIRECTIONAL_ACTION if action.is_directional()
			else SELECT_POSITIONAL_ACTION
		)
		state_machine.transition_to(
				next_state,
				{"action": action, "summon": summon_name}
		)


## Checks that the current action is in a state to be used, i.e. whether the
## action is off cooldown or there are enough wisps to use the action.
func _can_execute() -> bool:
	var cooldown: Cooldown = _action.get_node_or_null("Cooldown")
	var wisp_cost: WispCost = _action.get_node_or_null("WispCost")
	if cooldown != null:
		return not cooldown.is_active()
	if wisp_cost != null:
		return wisp_cost.is_met()
	return true


## Connect signals to this state.
func _connect_signals() -> void:
	selector.active_character.connect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.connect(
			"character_action_selected",
			Callable(self, "_on_SignalBus_character_action_selected")
	)
	SignalBus.connect(
			"spawn_action_selected",
			Callable(self, "_on_SignalBus_spawn_action_selected")
	)
	SignalBus.connect(
			"character_action_type_canceled",
			Callable(self, "_on_SignalBus_character_action_type_canceled")
	)
	SignalBus.connect(
			"top_vertex_changed",
			Callable(self, "_on_SignalBus_top_vertex_changed")
	)
	GamepadHandler.connect(
			"left_joystick_pulsed",
			Callable(self, "_on_GamepadHandler_left_joystick_pulsed")
	)


## Disconnect signals from this state.
func _disconnect_signals() -> void:
	selector.active_character.disconnect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.disconnect(
			"character_action_selected",
			Callable(self, "_on_SignalBus_character_action_selected")
	)
	SignalBus.disconnect(
			"spawn_action_selected",
			Callable(self, "_on_SignalBus_spawn_action_selected")
	)
	SignalBus.disconnect(
			"character_action_type_canceled",
			Callable(self, "_on_SignalBus_character_action_type_canceled")
	)
	SignalBus.disconnect(
			"top_vertex_changed",
			Callable(self, "_on_SignalBus_top_vertex_changed")
	)
	GamepadHandler.disconnect(
			"left_joystick_pulsed",
			Callable(self, "_on_GamepadHandler_left_joystick_pulsed")
	)


## Go to the "SelectAction" state with the new action.
func _on_SignalBus_character_action_selected(new_action: Action) -> void:
	_action_selected(new_action, "")


## Go to the "SelectAction" state with the new action, specifying that it is a
## spawn action.
func _on_SignalBus_spawn_action_selected(
	summon: String,
	spawn_action: Action
) -> void:
	_action_selected(spawn_action, summon)


## Go to the "SelectMove" state when the character action selection is canceled.
func _on_SignalBus_character_action_type_canceled() -> void:
	if not _state_is_active():
		return
	selector.hex_map.selection_tracker.clear_highlights()
	selector.hex_map.selection_tracker.clear_selector_highlights()
	state_machine.transition_to(SELECT_MOVE)


## Go to the "WAIT" state when a character has signaled that their turn is ended.
func _on_Character_turn_ended() -> void:
	_reset()
	state_machine.transition_to(WAIT)


## Update the mouse tracker when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(_vertex: int) -> void:
	var position: Vector3 = selector.tile_hovered.get_character_position()
	MouseHandler.update_mouse_tracker_3d(position)


## Resolves the left joystick pulse input. Pulses should only be used when the
## effect is not bound to the caster's position.
func _on_GamepadHandler_left_joystick_pulsed(joy_dir: Vector2) -> void:
	if _action.is_centered_on_caster():
		return
	# Relative top needed as joystick direction does not account for camera
	# orientation.
	var hex_dir: int = HexUtil.get_hex_direction(joy_dir, selector.top_vertex)
	_resolve_joystick_for_area(hex_dir)
