extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectMove' state.
The Selector is able to pass over map tiles and highlight said tiles.
When the input for selecting a tile is given, the Selector moves to the
'Pause' state and a signal is emitted indicating which tile was selected.
If an action is hovered over in the UI, the Selector moves to the 'SelectAction'
state. If a player turn ends, go to the 'Wait' state.
"""


var mouse_active: bool = false


# Reveal the selector shape and enable to ability to snap to tile positions.
func enter(_msg: Dictionary = {}) -> void:
	selector.move_to_position(_msg["initial_position"])
	ErrorUtil.connect_signal(
			selector.collision_area,
			"area_entered",
			self,
			"_on_Selector_area_entered"
	)


func update(_delta: float) -> void:
	if mouse_active:
		selector.move_to_mouse_position()


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.collision_area.disconnect(
			"area_entered",
			self,
			"_on_Selector_area_entered"
	)


# Handles input events
func handle_input(_event: InputEvent) -> void:
	mouse_active = _event is InputEventMouse
	if _event.is_action_pressed("ui_selector_select"):
		if selector.tile_hovered.get_selector_type() != HexHighlighter.Option.GRAY:
			selector.emit_move_tile_selected(selector.tile_hovered)
			state_machine.transition_to(PAUSE)
	
	_resolve_joystick_direction(HexUtil.joystick_to_hex_direction())


# Determines if the selector is able to move to the adjacent tile in the
# given direction (0 - 5) and does so if able.
func _resolve_joystick_direction(direction: int) -> void:
	if direction >= 0 and direction <= 5:
		var adjacent_tile: MapTile = selector.tile_hovered.get_adjacent_tile(direction)
		if adjacent_tile != null:
			selector.move_to_position(adjacent_tile.character_position())


# Activate the selector for the hovered tile.
func _on_Selector_area_entered(map_tile: Area) -> void:
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


# Go to the "SelectAction" state when the UI signals that an action was selected.
func _on_EncounterUI_player_action_selected(
	player: PlayerCharacter,
	action: Action
) -> void:
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
func _on_EncounterUI_player_turn_ended(_player: PlayerCharacter) -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	state_machine.transition_to(WAIT)
