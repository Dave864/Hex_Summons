extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectAction' state.
Retrieves the tile ids of the effect area whenever the selector moves.
Goes to the 'SelectAction' state when a new action is hovered over.
Goes to the 'SelectMove' state when the UI signals that the action type has
been canceled. Goes to the 'Wait' state when the UI signals that the player
turn has been terminated.
"""


var _mouse_active: bool = false
# The action to display the effect area for.
var _action: Action = null
# The location of the player that is using the action.
var _player_pos: Vector3 = Vector3.ZERO
# The tile index of the player that is using the action.
var _player_map_index: int = -1

# Reference to the function that will update the tile highlights.
onready var _update_highlights_ref: FuncRef = funcref(self, "_update_highlights")


func enter(msg: Dictionary = {}) -> void:
	_action = msg["action"]
	_player_pos = msg["player_pos"]
	_player_map_index = msg["player_map_index"]
	selector.set_update_highlights_func(_update_highlights_ref)
	
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
	
	_action.set_emission_map_index(_player_map_index)
	selector.emit_effect_area_required(_action)


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
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


# Handles input events
func handle_input(_event: InputEvent) -> void:
	_mouse_active = _event is InputEventMouse
	if not _mouse_active:
		_resolve_joystick_direction(HexUtil.joystick_to_hex_direction(selector.top_vertex))


# Update the highlights for a given tile. Also updates what the hovered tile is.
func _update_highlights(map_tile: MapTile) -> void:
	if (
		map_tile.is_active() 
		and (
			map_tile.get_highlight_type() == HexHighlighter.Option.RANGE
			or map_tile.get_highlight_type() == HexHighlighter.Option.TARGET
			or map_tile.get_highlight_type() == HexHighlighter.Option.PLAYER
		)
	):
		selector.tile_hovered = map_tile

		_action.set_emission_map_index(
				_player_map_index if _action.emit_from_center 
				else map_tile.map_coordinate.get_map_index()
		)
		if _action.get_is_cardinal():
			var player_pt: Vector2 = Vector2(_player_pos.x, _player_pos.z)
			var tile_pt: Vector2 = Vector2(map_tile.translation.x, map_tile.translation.z)
			var dir: Vector2 = (tile_pt - player_pt).normalized()
			_action.set_emission_direction(HexUtil.get_hex_direction(dir))
		selector.emit_effect_area_required(_action)


# Determines if the selector is able to move to the adjacent tile in the
# given direction (0 - 5) and does so if able.
func _resolve_joystick_direction(direction: int) -> void:
	if direction >= 0 and direction <= 5:
		"""
		TODO: Implement logic to handle joystick input.
		"""


# Go to the "SelectAction" state with the new action.
func _on_SignalBus_player_action_selected(
	player: PlayerCharacter,
	new_action: Action
) -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(
			SELECT_ACTION,
			{
				"action": new_action,
				"player_pos": player.translation,
				"player_map_index": player.get_map_index_at()
			}
	)


# Go to the "SelectMove" state when the player action selection is canceled.
func _on_SignalBus_player_action_type_canceled() -> void:
	if not _state_is_active():
		return
	var start_tile: MapTile = selector.get_map_tiles_ref()[_player_map_index]
	state_machine.transition_to(SELECT_MOVE, {"start_tile": start_tile})


# Go to the "WAIT" state when a player has signaled that their turn is ended.
func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	selector.tile_hovered.set_selector_type(HexHighlighter.Option.NONE)
	state_machine.transition_to(WAIT)
