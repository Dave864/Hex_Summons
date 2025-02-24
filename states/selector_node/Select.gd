extends SelectorState
"""
The logic for what happens when the Selector is in the 'Select' state.
The Selector is able to pass over map tiles and highlight said tiles.
When the input for selecting a tile is given, the Selector moves to the
'Pause' state and a signal is emitted indicating which tile was selected.
If a player turn ends, go to the 'Wait' state.
"""


# Reveal the selector shape and enable to ability to snap to tile positions.
func enter(_msg: Dictionary = {}) -> void:
	_set_state_machine_bus(SELECT)
	selector.snap_to_position = true
	
	ErrorUtil.connect_signal(
		selector,
		"area_entered",
		self,
		"_on_Selector_area_entered"
	)
	
	ErrorUtil.connect_signal(
		SignalBus,
		"player_turn_ended",
		self,
		"_on_SignalBus_player_turn_ended"
	)
	
	selector.selector_shape.show()


func update(_delta: float) -> void:
	selector.move_to_mouse_position()
	selector.position_selector_shape()


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	selector.disconnect("area_entered", self, "_on_Selector_area_entered")
	SignalBus.disconnect("player_turn_ended", self, "_on_SignalBus_player_turn_ended")


# Handles input events
func handle_input(_event: InputEvent) -> void:
	# Signal that the currently highlighted map tile was selected
	# and move to the 'Pause' state.
	if _event.is_action_pressed("ui_selector_select"):
		selector.emit_signal("tile_selected", selector.tile)
		state_machine.transition_to(PAUSE)
	
	_handle_joystick_input()


func _handle_joystick_input() -> void:
	var dir_vel: Vector2 = Input.get_vector(
		"ui_selector_l",
		"ui_selector_r",
		"ui_selector_d",
		"ui_selector_u"
	)
	#  /\ 0
	# |  |
	#  \/
	# Move to the upper-right neighbor
	if (
		dir_vel.x > Constants.HV_0_COORD.x
		and dir_vel.x < Constants.HV_1_COORD.x
		and dir_vel.y > 0.0
	):
		print("move upper-right")
	#  /\
	# |  | 1
	#  \/
	# Move to the true-right neighbor
	elif (
		dir_vel.x > 0.0
		and dir_vel.y < Constants.HV_1_COORD.y
		and dir_vel.y > Constants.HV_2_COORD.y
	):
		print("move right")
	#  /\
	# |  |
	#  \/ 2
	# Move to the bottom-right neighbor
	elif(
		dir_vel.x > Constants.HV_3_COORD.x
		and dir_vel.x < Constants.HV_2_COORD.x
		and dir_vel.y < 0.0
	):
		print("move bottom-right")
	#   /\
	#  |  |
	# 3 \/
	# Move to the botton-left neighbor
	elif(
		dir_vel.x > Constants.HV_4_COORD.x
		and dir_vel.x < Constants.HV_3_COORD.x
		and dir_vel.y < 0.0
	):
		print("move bottom-left")
	#    /\
	# 4 |  |
	#    \/
	# Move to the true-left neighbor
	elif(
		dir_vel.x < 0.0
		and dir_vel.y > Constants.HV_4_COORD.y
		and dir_vel.y < Constants.HV_5_COORD.y
	):
		print("move left")
	# 5 /\
	#  |  |
	#   \/
	# Move to the upper-left neighbor
	elif(
		dir_vel.x < Constants.HV_0_COORD.x
		and dir_vel.x > Constants.HV_5_COORD.x
		and dir_vel.y > 0.0
	):
		print("move upper-left")


func _on_Selector_area_entered(map_tile: Area) -> void:
	# Don't snap to position if map_tile is disabled or inactive.
	if (
		selector.snap_to_position 
		and map_tile.is_active() 
		and (
			map_tile.get_selection_type() == MapTile.SelectionType.RANGE
			or map_tile.get_selection_type() == MapTile.SelectionType.PLAYER
		)
	):
		selector.snap_position = map_tile.translation
		selector.tile = map_tile


func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	state_machine.transition_to(WAIT)
