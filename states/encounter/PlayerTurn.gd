extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `PlayerTurn` state.
Handles the encounter logic needed to allow the player character to properly
run during their turn. Remains in the `PlayerTurn` state if the next character
in initiative is also a player character. Goes to the `EnemyTurn` state if an
enemy character is next in intiative. Goes to the `End` state if either all
player characters or all enemy characters are defeated. 
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(PLAYER_TURN)
	enc.rf.set_char_type(Constants.MapOccupants.PLAYER)
	enc.rf.astar_for_range(enc.get_current_character())
	SignalBus.emit_signal("player_turn_started", enc.get_current_character())
	
	var e: int = enc.selector.connect(
		"tile_selected",
		self,"_on_Selector_tile_selected"
	)
	
	# Emit error message when issue is encountered when connecting the 
	# tile_selected Selector signal to the _on_Selector_tile_selected method.
	if e != OK:
		printerr(Constants.ERROR_SIGNAL_CONNECT_FAILED % [
			e, 
			"tile_selected", 
			"Selector", 
			"Encounter",
			"PlayerTurn", 
			"_on_Selector_tile_selected"
		])
	
	e = enc.ui.connect("mode_changed", self, "_on_UI_mode_changed")
	
	# Emit error message when issue is encountered when connecting the 
	# mode_changed UI signal to the _on_UI_mode_changed method.
	if e != OK:
		printerr(Constants.ERROR_SIGNAL_CONNECT_FAILED % [
			e,
			"mode_changed",
			"SignalBus",
			"Encounter",
			"PlayerTurn",
			"_on_UI_mode_changed"
		])
	
	e = enc.ui.connect(
		"mode_changed",
		enc.selector.get_node("StateMachine/Select"),
		"_on_UI_mode_changed"
	)
	
	# Emit error message when issue is encountered when connecting the 
	# mode_changed UI signal to the Selector's _on_UI_mode_changed method.
	if e != OK:
		printerr(Constants.ERROR_SIGNAL_CONNECT_FAILED % [
			e,
			"mode_changed",
			"SignalBus",
			"Selector",
			"Select",
			"_on_UI_mode_changed"
		])


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Determine which turn to go to when the current player ends their turn.
	if (
		StateMachineBus.encounter_states[FSM.Encounter.PLAYER_CHARACTER] == 
		PlayerCharacterState.WAIT
	):
		var next_character: Character = enc.get_next_character()
		if next_character is PlayerCharacter:
			state_machine.transition_to(PLAYER_TURN)
		elif next_character is EnemyCharacter:
			state_machine.transition_to(ENEMY_TURN)
	
	# Move to the `End` State when all enemies are defeated.
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	enc.progress_initiative()
	enc.rf.clear_movement_highlight()
	enc.selector.disconnect("tile_selected", self, "_on_Selector_tile_selected")
	enc.ui.disconnect("mode_changed", self, "_on_UI_mode_changed")
	enc.ui.disconnect(
		"mode_changed",
		enc.selector.get_node("StateMachine/Select"),
		"_on_UI_mode_changed"
	)


func _on_Selector_tile_selected(tile: MapTile):
	var data
	match StateMachineBus.encounter_states[FSM.Encounter.UI]:
		PlayerCharacterState.ATTACK:
			data = null
		_:
			data = enc.rf.get_point_path(
				enc.get_current_character().get_index_at(),
				tile.get_index()
			)
	SignalBus.emit_signal("tile_selected", data)


func _on_UI_mode_changed():
	match StateMachineBus.encounter_states[FSM.Encounter.UI]:
		PlayerCharacterState.MOVE:
			enc.rf.astar_for_range(enc.get_current_character())
		PlayerCharacterState.ATTACK:
			enc.rf.clear_movement_highlight()
		_:
			pass
