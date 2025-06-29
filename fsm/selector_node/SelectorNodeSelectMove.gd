extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectMove' state.
The Selector is able to pass over map tiles and highlight said tiles.
When the input for selecting a tile is given, the Selector moves to the
'Pause' state and a signal is emitted indicating which tile was selected.
If an action option is selected in the UI, the Selector moves to the 'SelectAction'
state. If a player turn ends, go to the 'Wait' state.
"""


# Tracks the travel and tile distances from the original character position
# to the tiles within movement range.
var _movement_ids: Array = []

# Reference to the function that will update the tile highlights.
onready var _update_selection_ref: FuncRef = funcref(self, "_update_selection")


# Reveal the selector shape and enable the ability to update tile highlights.
func enter(_msg: Dictionary = {}) -> void:
	var start_index : int = selector.active_player.map_coordinate.get_index()
	var start_tile: MapTile = selector.hex_map.get_tile_at(start_index)
	_determine_movement_ids()
	_update_selection(start_tile)
	selector.set_update_selection_func(_update_selection_ref)
	_connect_signals()


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


# Handles input events
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_selector_select"):
		if selector.tile_hovered.get_selector_type() != HexHighlighter.Option.GRAY:
			selector.emit_move_tile_selected(selector.tile_hovered)
			state_machine.transition_to(PAUSE)


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


# Go to the "SelectAction" state when the UI signals that an action was selected.
func _on_SignalBus_player_action_selected(
	_player: PlayerCharacter,
	action: Action
) -> void:
	if not _state_is_active():
		return
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	state_machine.transition_to(SELECT_ACTION, {"action": action})


# Go to the "WAIT" state when the UI has signaled that a player turn has ended.
func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	if not _state_is_active():
		return
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	_movement_ids.clear()
	state_machine.transition_to(WAIT)


# Update the mouse tracker when the camera changes orientation.
func _on_SignalBus_top_vertex_changed(_vertex: int) -> void:
	MouseHandler.update_mouse_tracker_3d(selector.tile_hovered.get_character_position())


# Resolves the left joystick pulse input.
func _on_GamepadHandler_left_joystick_pulsed(joy_dir: Vector2) -> void:
	var hex_dir: int = HexUtil.get_hex_direction(joy_dir, selector.top_vertex)
	_resolve_joystick_direction(hex_dir)
