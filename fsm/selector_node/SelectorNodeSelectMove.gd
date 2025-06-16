extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectMove' state.
The Selector is able to pass over map tiles and highlight said tiles.
When the input for selecting a tile is given, the Selector moves to the
'Pause' state and a signal is emitted indicating which tile was selected.
If an action is hovered over in the UI, the Selector moves to the 'SelectAction'
state. If a player turn ends, go to the 'Wait' state.
"""


# Flag that indicates that the mouse is active.
var _mouse_active: bool = false

# Reference to the function that will update the tile highlights.
onready var _update_highlights_ref: FuncRef = funcref(self, "_update_highlights")


# Reveal the selector shape and enable the ability to update tile highlights.
func enter(msg: Dictionary = {}) -> void:
	_update_highlights(msg["start_tile"])
	selector.set_update_highlights_func(_update_highlights_ref)
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


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.set_update_highlights_func(null)
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


# Handles input events
func handle_input(event: InputEvent) -> void:
	_mouse_active = event is InputEventMouse
	if event.is_action_pressed("ui_selector_select"):
		if selector.tile_hovered.get_selector_type() != HexHighlighter.Option.GRAY:
			selector.emit_move_tile_selected(selector.tile_hovered)
			state_machine.transition_to(PAUSE)
	
	if not _mouse_active:
		_resolve_joystick_direction(HexUtil.joystick_to_hex_direction(selector.top_vertex))


# Update the highlights for a given tile. Also updates what the hovered tile is.
func _update_highlights(map_tile: MapTile) -> void:
	JoystickHandler.update_mouse_tracker_3d(map_tile.get_character_position())
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
			_update_highlights(adjacent_tile)


# Go to the "SelectAction" state when the UI signals that an action was selected.
func _on_SignalBus_player_action_selected(
	player: PlayerCharacter,
	action: Action
) -> void:
	if not _state_is_active():
		return
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	state_machine.transition_to(
			SELECT_ACTION,
			{
				"action": action,
				"player_pos": player.translation,
				"player_map_index": player.get_map_index_at()
			}
	)


# Go to the "WAIT" state when the UI has signaled that a player turn has ended.
func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	if not _state_is_active():
		return
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	state_machine.transition_to(WAIT)
