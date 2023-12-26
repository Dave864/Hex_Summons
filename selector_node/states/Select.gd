extends SelectorState
"""
The logic for what happens when the Selector is in the 'Select' state.
The Selector is able to pass over map tiles and highlight said tiles.
When the input for selecting a tile is given, the Selector moves to the
'Wait' state and a signal is emitted indicating which tile was selected.
"""


# Reveal the selector shape and enable to ability to snap to tile positions
func enter(_msg: Dictionary = {}):
	selector.snap_to_position = true
	selector.animation_player.play("selected")
	selector.selector_shape.show()


func update(_delta: float):
	# Move the Selector to the mouse position
	selector.translation = selector.mouse_position.get_mouse_position()
	var new_position: Vector3 = selector.snap_position - selector.translation
	selector.selector_shape.translation = Vector3(
		new_position.x,
		0.125,
		new_position.z
	)


func handle_input(event: InputEvent):
	if event is InputEventMouseButton:
		# Indicate that the currently highlighted map tile was selected
		# and move to the 'Wait' state
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			selector.emit_signal("tile_selected", selector.tile)
			selector.animation_player.play("selected")
			yield(selector.animation_player, "animation_finished")
			state_machine.transition_to("Wait")
