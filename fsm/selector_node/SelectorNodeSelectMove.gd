extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectMove' state.
When the input for selecting a tile is given, the Selector moves to the
'Pause' state and a signal is emitted indicating which tile was selected.
If an action option is selected in the UI, the Selector moves to the 'SelectAction'
state. If a player turn ends, go to the 'Wait' state.
"""


# The starting index for the movement area.
var _move_origin_index: int = -1
# Tracks the travel and tile distances from the original character position
# to the tiles within movement range.
var _movement_ids: Array = []

# Reference to the function that will update the tile highlights.
@onready var _update_selection_ref: FuncRef = funcref(self, "_update_selection")


# Reveal the selector shape and enable the ability to update tile highlights.
func enter(_msg: Dictionary = {}) -> void:
	var player_index: int = selector.active_player.map_coordinate.get_index()
	if _move_origin_index < 0:
		_move_origin_index = player_index
	_determine_movement_ids()
	_highlight_movement_range(player_index)
	selector.set_update_selection_func(_update_selection_ref)
	_connect_signals()


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.set_update_selection_func(null)
	_disconnect_signals()


# Connect signals to this state.
func _connect_signals() -> void:
	_connect_player_turn_ended()
	ErrorUtil.connect_signal(
			SignalBus,
			"move_path_requested",
			self,
			"_on_SignalBus_move_path_requested"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"player_action_selected",
			self,
			"_on_SignalBus_player_action_selected"
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


# Need to keep connection to active player's turn_ended signal in order to
# clear out movement details when the turn is ended while in the SelectAction
# state.
func _connect_player_turn_ended():
	if selector.active_player.is_connected(
			"turn_ended",
			self,
			"_on_PlayerCharacter_turn_ended"
	):
		return
	ErrorUtil.connect_signal(
		selector.active_player,
		"turn_ended",
		self,
		"_on_PlayerCharacter_turn_ended"
	)


# Disconnect signals from this state.
func _disconnect_signals() -> void:
	SignalBus.disconnect(
			"move_path_requested",
			self,
			"_on_SignalBus_move_path_requested"
	)
	SignalBus.disconnect(
			"player_action_selected",
			self,
			"_on_SignalBus_player_action_selected"
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


# Gets the tile ids that are within a player's movement range. 
func _determine_movement_ids() -> void:
	# Reuse previously found ids if current player has not started a new
	# turn. Ids get cleared when the player ends their turn.
	if _movement_ids.size() > 0:
		return
	_movement_ids = selector.hex_map.range_finder.get_character_travesible_tiles(
			selector.active_player,
			selector.enemies_ref
	)


# Highlights the movement range for the active character.
func _highlight_movement_range(player_index: int) -> void:
	selector.hex_map.selection_tracker.highlight_player_movement(
			_movement_ids,
			selector.active_player,
			_move_origin_index
	)
	var start_tile: MapTile = selector.hex_map.get_tile_at(player_index)
	_update_selection(start_tile)


# Update the selector for a given tile. Also updates what the hovered tile is.
# Passed to the Selector node to be called when the mouse hovers over the tile.
func _update_selection(map_tile: MapTile) -> void:
	MouseHandler.update_mouse_tracker_3d(map_tile.get_character_position())
	if !map_tile.is_active():
		return

	# Turn off previous selector indicator to indicate a new tile is being
	# hovered over.
	if selector.tile_hovered != null:
		selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	selector.tile_hovered = map_tile

	var highlight: int = map_tile.get_highlight_type()
	if (
		highlight == HexHighlighter.Option.RANGE
		or highlight == HexHighlighter.Option.PLAYER
	):
		map_tile.set_selector_type(HexHighlighter.Option.MOVE)
	else:
		map_tile.set_selector_type(HexHighlighter.Option.GRAY)


# Determines if the selector is able to move to the adjacent tile in the
# given direction (0 - 5) and does so if able.
func _resolve_joystick_direction(direction: int) -> void:
	if direction >= 0 and direction <= 5:
		var adjacent_tile: MapTile = selector.tile_hovered.get_adjacent_tile(direction)
		if adjacent_tile != null:
			_update_selection(adjacent_tile)


# Go to the "WAIT" state when the UI has signaled that a player turn has ended.
func _on_PlayerCharacter_turn_ended() -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	_move_origin_index = -1
	_movement_ids.clear()
	selector.active_player.disconnect(
			"turn_ended",
			self,
			"_on_PlayerCharacter_turn_ended"
	)
	if _state_is_active():
		state_machine.transition_to(WAIT)


# Creates the movement path to the selected tile if said tile is valid.
func _on_SignalBus_move_path_requested() -> void:
	if selector.tile_hovered.get_selector_type() != HexHighlighter.Option.GRAY:
		var path_data: PackedVector3Array = (
			selector.hex_map.range_finder.get_character_point_path(
					selector.active_player,
					selector.tile_hovered.map_coordinate.get_index(),
					selector.enemies_ref,
					_movement_ids
			)
		)
		SignalBus.emit_move_path_created(path_data)
		state_machine.transition_to(PAUSE)


# Go to the "SelectAction" state when the UI signals that an action was selected.
func _on_SignalBus_player_action_selected(
	_player: PlayerCharacter,
	action: Action
) -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	state_machine.transition_to(SELECT_ACTION, {"action": action})


# Update the mouse tracker when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(_vertex: int) -> void:
	MouseHandler.update_mouse_tracker_3d(
			selector.tile_hovered.get_character_position()
	)


# Resolves the left joystick pulse input.
func _on_GamepadHandler_left_joystick_pulsed(joy_dir: Vector2) -> void:
	var hex_dir: int = HexUtil.get_hex_direction(joy_dir, selector.top_vertex)
	_resolve_joystick_direction(hex_dir)
