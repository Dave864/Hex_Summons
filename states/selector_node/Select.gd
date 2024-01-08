extends SelectorState
"""
The logic for what happens when the Selector is in the 'Select' state.
The Selector is able to pass over map tiles and highlight said tiles.
When the input for selecting a tile is given, the Selector moves to the
'Wait' state and a signal is emitted indicating which tile was selected.
"""


# Reveal the selector shape and enable to ability to snap to tile positions.
func enter(_msg: Dictionary = {}):
	_set_state_machine_bus(SELECT)
	selector.snap_to_position = true
	selector.animation_player.play("RESET")
	selector.selector_shape.show()
	
	var e: int = selector.connect(
		"area_entered", 
		self, 
		"_on_Selector_area_entered"
	)
	
	# Emit error message when issue is encountered when connecting the 
	# area_entered Area signal to the _on_Selector_area_entered method.
	if e != OK:
		printerr(Constants.ERROR_SIGNAL_CONNECT_FAILED % [
			e,
			"area_entered",
			"Selector",
			"PlayerCharacter",
			"Start",
			"_on_Selector_area_entered"
		])


func update(_delta: float):
	# Move the Selector to the mouse position.
	selector.translation = selector.mouse_position.get_mouse_position()
	
	# Snap the position of the Selector shape mesh to the last hovered over tile.
	var new_position: Vector3 = selector.snap_position - selector.translation
	selector.selector_shape.translation = Vector3(
		new_position.x,
		0.125,
		new_position.z
	)


func handle_input(event: InputEvent):
	if event is InputEventMouseButton:
		# Signal that the currently highlighted map tile was selected
		# and move to the 'Wait' state.
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			selector.emit_signal("tile_selected", selector.tile)
			selector.animation_player.play("selected")
			yield(selector.animation_player, "animation_finished")
			state_machine.transition_to(WAIT)


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.disconnect("area_entered", self, "_on_Selector_area_entered")


func _on_Selector_area_entered(map_tile: Area):
	# Don't snap to position if map_tile is disabled or inactive.
	if (
		selector.snap_to_position and
		map_tile.is_active() and
		map_tile.get_movement_active()
	):
		selector.snap_position = map_tile.translation
		selector.tile = map_tile


func _on_UI_mode_changed():
	pass
