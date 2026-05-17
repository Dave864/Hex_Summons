class_name SelectionTrackerMove
extends SelectionTrackerState
## The logic for what happens when the SelectionTracker is in the 'Move' state.
##
## When the input for selecting a tile is given, the movement path is recorded.
## If an action option is selected in the UI, the Selector moves to the
## appropriate action state ('PositionalAction' or 'DirectionalAction'). If the
## turn is finalized, go to the 'Process' state.


## The starting index for the movement area.
var _move_origin_index: int = -1
## The pathbuilder for the path.
var _pathbuilder: MovePathBuilder = MovePathBuilder.new()

## Reference to the function that will update the tile highlights.
@onready var _update_selection_ref: Callable = Callable(
		self,
		"_update_selection"
)


## Reveal the selector shape and enable the ability to update tile highlights.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	selector.show()
	s_tracker.show_ghost_sprite(true)
	if _move_origin_index < 0:
		_move_origin_index = s_tracker.player_index
	var character_tile: MapTile = hex_map.get_tile_at(s_tracker.move_target_index)
	s_tracker.emit_new_focus_point(character_tile.get_character_position())
	s_tracker.highlight_player_movement(_move_origin_index)
	_pathbuilder.update_move_area_details(
			_move_origin_index,
			s_tracker.focused_character.stats.get_movement_range(),
			hex_map.get_tiles_from_ids(s_tracker.get_movement_area_ids()),
			hex_map.get_x_count()
	)
	_update_selection(hex_map.get_tile_at(s_tracker.move_target_index))
	s_tracker.set_selector_update(_update_selection_ref)
	_connect_signals()


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
func exit() -> void:
	s_tracker.set_selector_update(Callable())
	_disconnect_signals()


## Connect signals to this state.
func _connect_signals() -> void:
	_connect_character_turn_ended()
	SignalBus.connect(
			"player_turn_finalized",
			Callable(self, "_on_SignalBus_player_turn_finalized")
	)
	SignalBus.connect(
			"move_path_requested",
			Callable(self, "_on_SignalBus_move_path_requested")
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
			"top_vertex_changed",
			Callable(self, "_on_SignalBus_top_vertex_changed")
	)
	GamepadHandler.connect(
			"left_joystick_pulsed",
			Callable(self, "_on_GamepadHandler_left_joystick_pulsed")
	)


## Need to keep connection to active character's turn_ended signal in order to
## clear out movement details when the turn is ended while in the SelectAction
## state.
func _connect_character_turn_ended():
	if s_tracker.focused_character.is_connected(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	):
		return
	s_tracker.focused_character.connect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)


## Disconnect signals from this state that are reused by other states in this
## state machine.
func _disconnect_signals() -> void:
	SignalBus.disconnect(
			"player_turn_finalized",
			Callable(self, "_on_SignalBus_player_turn_finalized")
	)
	SignalBus.disconnect(
			"move_path_requested",
			Callable(self, "_on_SignalBus_move_path_requested")
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
			"top_vertex_changed",
			Callable(self, "_on_SignalBus_top_vertex_changed")
	)
	GamepadHandler.disconnect(
			"left_joystick_pulsed",
			Callable(self, "_on_GamepadHandler_left_joystick_pulsed")
	)


## Update the selector for a given tile. Also updates what the hovered tile is.
## Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(map_tile: MapTile) -> void:
	MouseHandler.update_mouse_tracker_3d(map_tile.get_character_position())
	if !map_tile.is_active():
		return

	# Turn off previous selector indicator to indicate a new tile is being
	# hovered over.
	if selector.tile_hovered != null:
		selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	selector.tile_hovered = map_tile
	
	if InputController.source_is_gamepad():
		s_tracker.emit_new_focus_point(map_tile.get_character_position())

	var highlight: int = map_tile.get_highlight_type()
	if (
		highlight == HexHighlighter.Option.RANGE_MOVE
		or highlight == HexHighlighter.Option.ORIGIN_PLAYER
	):
		map_tile.set_selector_type(HexHighlighter.Option.SELECT_MOVE)
	else:
		map_tile.set_selector_type(HexHighlighter.Option.SELECT_GRAY)


## Determines if the selector is able to move to the adjacent tile in the
## given direction (0 - 5) and does so if able.
func _resolve_joystick_direction(direction: HexUtil.HexDirection) -> void:
	var adjacent_tile: MapTile = (
		selector.tile_hovered.get_adjacent_tile(direction)
	)
	if adjacent_tile != null:
		_update_selection(adjacent_tile)


## Go to the "WAIT" state when the UI has signaled that a character turn has
## ended.
func _on_Character_turn_ended() -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	_move_origin_index = -1
	s_tracker.focused_character.disconnect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	if _state_is_active():
		state_machine.transition_to(WAIT)


## Go to the "PROCESS" state when the turn has been finalized.
func _on_SignalBus_player_turn_finalized() -> void:
	state_machine.transition_to(PROCESS)


## Creates the movement path to the selected tile if said tile is valid.
func _on_SignalBus_move_path_requested() -> void:
	var target_tile: MapTile = selector.tile_hovered
	if target_tile.get_selector_type() != HexHighlighter.Option.SELECT_GRAY:
		var target_index := target_tile.map_coordinate.get_tile_index()
		_pathbuilder.create_path_to_id(target_index)
		s_tracker.set_movement_path(_pathbuilder.get_point_path())
		s_tracker.move_target_index = target_index
		s_tracker.show_ghost_sprite(true)
		s_tracker.emit_new_focus_point(target_tile.get_character_position())


## Go to the "SelectAction" state when the UI signals that an action was selected.
func _on_SignalBus_character_action_selected(action: Action) -> void:
	_action_selected(action, "")


## Go to the "SelectAction" state when the UI signals that an action was selected,
## specifying that the action is a spawn action.
func _on_SignalBus_spawn_action_selected(summon: String, action: Action) -> void:
	_action_selected(action, summon)


## Clears the hovered selector highlights and goes to the "SelectAction" state,
## passing along an action and whether it's a spawn action or not.
func _action_selected(action: Action, summon: String) -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	var next_state: String = (
		DIRECTIONAL_ACTION if action.is_directional()
		else POSITIONAL_ACTION
	)
	state_machine.transition_to(
			next_state,
			{"action": action, "summon": summon}
	)


## Update the mouse tracker when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(_vertex: int) -> void:
	MouseHandler.update_mouse_tracker_3d(
			selector.tile_hovered.get_character_position()
	)


## Resolves the left joystick pulse input.
func _on_GamepadHandler_left_joystick_pulsed(joy_dir: Vector2) -> void:
	var hex_dir: int = HexUtil.get_hex_direction(joy_dir, selector.top_vertex)
	_resolve_joystick_direction(hex_dir)
