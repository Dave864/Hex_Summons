extends SelectorState
"""
The logic for what happens when the Selector is in the 'SelectAction' state.
Retrieves the tile ids of the effect area whenever the selector moves.
Goes to the 'SelectAction' state when a new action is hovered over.
Goes to the 'SelectMove' state when the UI signals that the action type has
been canceled.
"""


var mouse_active: bool = false
# The action to display the effect area for.
var action: Action = null


func enter(_msg: Dictionary = {}) -> void:
	action = _msg["action"]
	action.emission_pt.translation = action.area_pt.translation
	
	ErrorUtil.connect_signal(
		selector.collision_area,
		"area_entered",
		self,
		"_on_Selector_area_entered"
	)
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
	
	selector.emit_signal(
		"effect_selector_required",
		action.get_effect_tiles(),
		false
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


# Handles input events
func handle_input(_event: InputEvent) -> void:
	mouse_active = _event is InputEventMouse
	_resolve_joystick_direction(selector.joystick_to_hex_direction())


# Determines if the selector is able to move to the adjacent tile in the
# given direction (0 - 5) and does so if able.
func _resolve_joystick_direction(direction: int) -> void:
	if direction >= 0 and direction <= 5:
		"""
		TODO: Implement logic to handle joystick input.
		"""


# Activate the selector for the hovered tile.
func _on_Selector_area_entered(map_tile: Area) -> void:
	if (
		map_tile.is_active() 
		and (
			map_tile.get_highlight_type() == HexHighlighter.Option.RANGE
			or map_tile.get_highlight_type() == HexHighlighter.Option.TARGET
			or map_tile.get_highlight_type() == HexHighlighter.Option.PLAYER
		)
	):
		selector.tile_hovered = map_tile
		
		if action.emit_from_center:
			action.emission_pt.translation = action.area_pt.translation
		else:
			action.emission_pt.translation = map_tile.translation
		
		if action.get_is_cardinal():
			if action.emit_from_center:
				action.rotate_to_point(map_tile.translation)
			else:
				action.rotate_to_point(action.area_pt.translation, true)
		
		selector.emit_signal(
			"effect_selector_required",
			action.get_effect_tiles(),
			false
		)


# Go to the "SelectAction" state with the new action.
func _on_SignalBus_player_action_selected(new_action: Action) -> void:
	state_machine.transition_to(SELECT_ACTION, {"action": new_action})


# Go to the "SelectMove" state when the player action selection is canceled.
func _on_SignalBus_player_action_type_canceled() -> void:
	state_machine.transition_to(
		SELECT_MOVE,
		{"initial_position": action.area_pt.translation}
	)
