extends SelectorState
"""
The logic for what happens when the Selector is in the 'Select' state.
The Selector is able to pass over map tiles and highlight said tiles.
When the input for selecting a tile is given, the Selector moves to the
'Pause' state and a signal is emitted indicating which tile was selected.
"""


# Reveal the selector shape and enable to ability to snap to tile positions.
func enter(_msg: Dictionary = {}) -> void:
	_set_state_machine_bus(SELECT)
	selector.snap_to_position = true
	selector.animation_player.play("RESET")
	selector.selector_shape.show()
	
	ErrorUtil.connect_signal(
		selector,
		"area_entered",
		self,
		"_on_Selector_area_entered"
	)


func update(_delta: float) -> void:
	# Move the Selector to the mouse position.
	selector.translation = selector.mouse_position.get_mouse_position()
	
	# Snap the position of the Selector shape mesh to the last hovered over tile.
	var new_position: Vector3 = selector.snap_position - selector.translation
	selector.selector_shape.translation = Vector3(
		new_position.x,
		0.125,
		new_position.z
	)


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.disconnect("area_entered", self, "_on_Selector_area_entered")


# Handles input events
func _input(event: InputEvent) -> void:
	# Signal that the currently highlighted map tile was selected
	# and move to the 'Pause' state.
	if event.is_action_pressed("ui_selector_select"):
		selector.animation_player.play("selected")
		selector.emit_signal("tile_selected", selector.tile)
		yield(selector.animation_player, "animation_finished")
		state_machine.transition_to(PAUSE)


func _on_Selector_area_entered(map_tile: Area) -> void:
	# Don't snap to position if map_tile is disabled or inactive.
	if (
		selector.player_action_change 
		or selector.snap_to_position 
		and map_tile.is_active() 
		and map_tile.get_is_selectable()
	):
		selector.snap_position = map_tile.translation
		selector.tile = map_tile
		selector.player_action_change = false


func _on_UI_mode_changed() -> void:
	# Snap the selector to the position of the current player when shifting
	# between different actions.
	selector.player_action_change = true
	selector.snap_to_character()
