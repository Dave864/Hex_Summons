class_name SelectionTrackerAction
extends SelectionTrackerState
## Base class for the logic for what happens when the SelectionTracker is in a
## state intended to manage the selection of actions.
##
## Goes to the relevant action type state when a new action is chosen.
## Goes to the 'Move' state when the UI signals that the action type has
## been canceled. Goes to the 'Wait' state when the UI signals that the
## character turn has been terminated.


## The name of the summon that uses the action on spawn. If empty, the action is
## not used as a spawn action.
var _summon_name: String = ""


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
	s_tracker.set_focus_action(msg["action"], _summon_name != "")
	_highlight_source_range()
	selector.set_update_selection_func(_update_selection_ref)
	_connect_signals()


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
func exit() -> void:
	s_tracker.clear_highlights()
	s_tracker.clear_indicators()
	s_tracker.emit_camera_focus_unlocked()
	selector.set_update_selection_func(Callable())
	_disconnect_signals()


## Update the selection for a given tile.
## Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(_map_tile: MapTile) -> void:
	pass


## Gets an array of the targets sorted by distance from character. The closest
## target is at the first index. Each index contains the target character and
## distance.
func _get_target_distances() -> Array[Array]:
	var potential_targets: Array[Character] = []
	var target_types: Dictionary[ActionEffect.Target, bool] = (
		s_tracker.get_focus_action().get_target_types()
	)
	if target_types.has(ActionEffect.Target.OPPONENTS):
		potential_targets.append_array(s_tracker.get_enemies_reference())
	if target_types.has(ActionEffect.Target.ALLIES):
		potential_targets.append_array(s_tracker.get_players_referece())
	
	var target_distances: Array[Array] = []
	for option: Character in potential_targets:
		var dist: float = hex_map.range_finder.travel_distance(
				s_tracker.player_index,
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
		map_tile.map_coordinate.get_tile_index() == s_tracker.player_index
	)
	var target_types: Dictionary[ActionEffect.Target, bool] = (
		s_tracker.get_focus_action().get_target_types()
	)
	match map_tile.get_highlight_type():
		HexHighlighter.Option.RANGE:
			return true
		HexHighlighter.Option.TARGET:
			return target_types.has(ActionEffect.Target.OPPONENTS)
		HexHighlighter.Option.PLAYER:
			return (
				(
					target_types.has(ActionEffect.Target.SELF) 
					and is_caster
				)
				or target_types.has(ActionEffect.Target.ALLIES)
			)
		_:
			return false


## Updates the selection display to show the source area.
func _highlight_source_range() -> void:
	s_tracker.clear_highlights()
	s_tracker.highlight_action_source_area()


## Updates the selection display to show the effect area.
func _highlight_effect_range() -> void:
	s_tracker.clear_indicators()
	if s_tracker.get_focus_action().is_directional():
		s_tracker.indicate_directional_effect_range()
	else:
		s_tracker.indicate_positional_effect_range()


## Gets the character targets that are within the effect range.
func _get_targets_in_effect_range(effect_range: Array[int]) -> Array[Character]:
	var targets: Array[Character] = []
	var target_types: Dictionary[ActionEffect.Target, bool] = (
		s_tracker.get_focus_action().get_target_types()
	)
	var target_enemy: bool = target_types.has(ActionEffect.Target.OPPONENTS)
	var target_ally: bool = target_types.has(ActionEffect.Target.ALLIES)
	var target_self: bool = target_types.has(ActionEffect.Target.SELF)
	for index: int in effect_range:
		var tile: MapTile = s_tracker.hex_map.get_tile_at(index)
		var c: Character = tile.occupant.get_current_occupant()
		if c == null:
			continue
		if (
			target_ally
			or (target_enemy and c is EnemyCharacter)
			or (
				c.map_coordinate.get_tile_index() == s_tracker.player_index
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
	s_tracker.clear_highlights()
	s_tracker.clear_indicators()
	var action: Action = s_tracker.get_focus_action()
	if _summon_name != "":
		s_tracker.emit_spawn_action_confirmed(
				_summon_name,
				action.get_emission_pos()
		)
	SignalBus.emit_character_action_executed(
			s_tracker.focused_character,
			action,
			s_tracker.get_tracked_targets()
	)
	_reset()
	state_machine.transition_to(PAUSE)


## Clears out the caches and resets recorded details.
func _reset() -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	_summon_name = ""
	s_tracker.set_focus_action(null, false)


## Executes the action if it has been confirmed, otherwise resetting the
## "SelectAction" state with the new action, specifying if it is a spawn action
## or not.
func _action_selected(action: Action, summon_name: String) -> void:
	if not _state_is_active():
		return
	elif (
		action == s_tracker.get_focus_action()
		and summon_name == _summon_name
		and not s_tracker.get_tracked_targets().is_empty()
		and _can_execute()
	):
		_execute_action()
	else:
		var next_state: String = (
			DIRECTIONAL_ACTION if action.is_directional()
			else POSITIONAL_ACTION
		)
		state_machine.transition_to(
				next_state,
				{"action": action, "summon": summon_name}
		)


## Checks that the current action is in a state to be used, i.e. whether the
## action is off cooldown or there are enough wisps to use the action.
func _can_execute() -> bool:
	var action: Action = s_tracker.get_focus_action()
	var cooldown: Cooldown = action.get_node_or_null("Cooldown")
	var wisp_cost: WispCost = action.get_node_or_null("WispCost")
	if cooldown != null:
		return not cooldown.is_active()
	if wisp_cost != null:
		return wisp_cost.is_met()
	return true


## Connect signals to this state.
func _connect_signals() -> void:
	s_tracker.focused_character.connect(
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
	s_tracker.focused_character.disconnect(
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


## Go to the "MOVE" state when the character action selection is canceled.
func _on_SignalBus_character_action_type_canceled() -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(MOVE)


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
	if s_tracker.get_focus_action().is_centered_on_caster():
		return
	# Relative top needed as joystick direction does not account for camera
	# orientation.
	var hex_dir: int = HexUtil.get_hex_direction(joy_dir, selector.top_vertex)
	_resolve_joystick_for_area(hex_dir)
