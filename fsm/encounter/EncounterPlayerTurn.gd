extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `PlayerTurn` state.
Handles the encounter logic needed to allow the player character to properly
run during their turn. Goes to the `PlayerTurn` state if the next character
in initiative is also a player character. Goes to the `EnemyTurn` state if an
enemy character is next in intiative. Goes to the `End` state if either all
player characters or all enemy characters are defeated. 
"""


# The player character currently active
var active_char: PlayerCharacter = null
# The index of tiles that the player can move to.
var movement_area: Array = []
# The index of the tile the player starts from.
var start_index: int = 0
# The index of tiles in reach of an action. 
var action_range: Dictionary = {"type": null, "tiles": null}


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	active_char = enc.get_current_character()
	start_index = active_char.get_map_index_at()
	movement_area = enc.hex_map.get_traversible_tiles_for_character(
		active_char,
		enc.enemies
	)
	enc.hex_map.highlight_player_movement(movement_area, active_char)
	
	_connect_signals_to_self()
	_connect_signals_to_UI()
	_connect_signals_to_selector()
	_connect_signals_to_character()
	enc.emit_player_turn_started()


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Move to the `End` State when all enemies are defeated.
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)
	"""
	TODO: Add logic to check if all players are defeated
	"""


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	_disconnect_signals_from_self()
	_disconnect_signals_from_UI()
	_disconnect_signals_from_selector()
	_disconnect_signals_from_character()


func _ready_connect_signals() -> void:
	ErrorUtil.connect_signal(
			enc.ui,
			"player_action_selected",
			self,
			"_on_EncounterUI_player_action_selected"
	)
	ErrorUtil.connect_signal(
			enc.ui,
			"player_action_type_canceled",
			self,
			"_on_EncounterUI_player_action_type_canceled"
	)
	ErrorUtil.connect_signal(
			enc.ui,
			"player_turn_ended",
			self,
			"_on_EncounterUI_player_turn_ended"
	)
	ErrorUtil.connect_signal(
			enc,
			"player_turn_started",
			enc.ui,
			"_on_Encounter_player_turn_started"
	)
	ErrorUtil.connect_signal(
			enc,
			"player_turn_started",
			enc.selector.fsm.state_nodes["Wait"],
			"_on_Encounter_player_turn_started"
	)
	ErrorUtil.connect_signal(
			enc,
			"move_tile_selected",
			enc.ui,
			"_on_Encounter_move_tile_selected"
	)


# Connect the relevant signals to this state.
# These signals are used by other states and will be disconnected to avoid
# unintended behavior.
func _connect_signals_to_self() -> void:
	ErrorUtil.connect_signal(
			enc.selector,
			"move_tile_selected",
			self,
			"_on_Selector_move_tile_selected"
	)
	ErrorUtil.connect_signal(
			enc.selector,
			"effect_selector_required",
			self,
			"_on_Selector_effect_selector_required"
	)


# Connect the relevant signals from other nodes to the FSM of the encounter UI node.
# These signals are used by other states and will be disconnected to avoid
# unintended behavior.
func _connect_signals_to_UI() -> void:
	# Connect current player to UI.
	ErrorUtil.connect_signal(
			active_char,
			"selector_required",
			enc.ui,
			"_on_PlayerCharacter_selector_required"
	)


# Connect the relevant signals from other nodes to the FSM of the selector node.
# These signals are used by other states and will be disconnected to avoid
# unintended behavior.
func _connect_signals_to_selector() -> void:
	# Connect encounter UI to selector 'SelectMove' state
	ErrorUtil.connect_signal(
			enc.ui,
			"player_action_selected",
			enc.selector.fsm.state_nodes["SelectMove"],
			"_on_EncounterUI_player_action_selected"
	)
	ErrorUtil.connect_signal(
			enc.ui,
			"player_turn_ended",
			enc.selector.fsm.state_nodes["SelectMove"],
			"_on_EncounterUI_player_turn_ended"
	)
	# Connect encounter UI to selector 'SelectAction' state
	ErrorUtil.connect_signal(
			enc.ui,
			"player_action_selected",
			enc.selector.fsm.state_nodes["SelectAction"],
			"_on_EncounterUI_player_action_selected"
	)
	ErrorUtil.connect_signal(
			enc.ui,
			"player_action_type_canceled",
			enc.selector.fsm.state_nodes["SelectAction"],
			"_on_EncounterUI_player_action_type_canceled"
	)
	ErrorUtil.connect_signal(
			enc.ui,
			"player_turn_ended",
			enc.selector.fsm.state_nodes["SelectAction"],
			"_on_EncounterUI_player_turn_ended"
	)
	# Connect encounterUI to selector 'Pause' state
	ErrorUtil.connect_signal(
			enc.ui,
			"player_turn_ended",
			enc.selector.fsm.state_nodes["Pause"],
			"_on_EncounterUI_player_turn_ended"
	)
	# Connect current player to selector 'Pause' state
	ErrorUtil.connect_signal(
			active_char,
			"selector_required",
			enc.selector.fsm.state_nodes["Pause"],
			"_on_PlayerCharacter_selector_required"
	)


# Connect the relevant signals from other nodes to the FSM of the active 
# character node. These signals are used by other states and will be 
# disconnected to avoid unintended behavior.
func _connect_signals_to_character() -> void:
	# Connect encounter to current player 'Wait' state
	ErrorUtil.connect_signal(
			enc,
			"player_turn_started",
			active_char.fsm.state_nodes["Wait"],
			"_on_Encounter_player_turn_started"
	)
	# Connect encounter to current player 'Standby' state
	ErrorUtil.connect_signal(
			enc,
			"move_tile_selected",
			active_char.fsm.state_nodes["Standby"],
			"_on_Encounter_move_tile_selected"
	)
	# Connect encounter UI to current player 'Standby' state
	ErrorUtil.connect_signal(
			enc.ui,
			"player_turn_ended",
			active_char.fsm.state_nodes["Standby"],
			"_on_EncounterUI_player_turn_ended"
	)
	# Connect selector to current player 'Move' state
	ErrorUtil.connect_signal(
			enc.selector,
			"selector_paused",
			active_char.fsm.state_nodes["Move"],
			"_on_Selector_selector_paused"
	)


# Disconnect the signals connected to this state.
func _disconnect_signals_from_self() -> void:
	enc.selector.disconnect(
			"move_tile_selected",
			self,
			"_on_Selector_move_tile_selected"
	)
	enc.selector.disconnect(
			"effect_selector_required",
			self,
			"_on_Selector_effect_selector_required"
	)


# Disconnect the signals connected to the UI FSM.
func _disconnect_signals_from_UI() -> void:
	# Disconnect current player from UI.
	active_char.disconnect(
			"selector_required",
			enc.ui,
			"_on_PlayerCharacter_selector_required"
	)


# Disconnect the signals connected to the selector FSM.
func _disconnect_signals_from_selector() -> void:
	# Disconnect encounter UI from selector 'SelectMove' state
	enc.ui.disconnect(
			"player_action_selected",
			enc.selector.fsm.state_nodes["SelectMove"],
			"_on_EncounterUI_player_action_selected"
	)
	enc.ui.disconnect(
			"player_turn_ended",
			enc.selector.fsm.state_nodes["SelectMove"],
			"_on_EncounterUI_player_turn_ended"
	)
	# Disconnect encounter UI from selector 'SelectAction' state
	enc.ui.disconnect(
			"player_action_selected",
			enc.selector.fsm.state_nodes["SelectAction"],
			"_on_EncounterUI_player_action_selected"
	)
	enc.ui.disconnect(
			"player_action_type_canceled",
			enc.selector.fsm.state_nodes["SelectAction"],
			"_on_EncounterUI_player_action_type_canceled"
	)
	enc.ui.disconnect(
			"player_turn_ended",
			enc.selector.fsm.state_nodes["SelectAction"],
			"_on_EncounterUI_player_turn_ended"
	)
	# Disconnect encounter UI from selector 'Pause' state
	enc.ui.disconnect(
			"player_turn_ended",
			enc.selector.fsm.state_nodes["Pause"],
			"_on_EncounterUI_player_turn_ended"
	)
	# Disconnect current player from selector 'Pause' state
	active_char.disconnect(
			"selector_required",
			enc.selector.fsm.state_nodes["Pause"],
			"_on_PlayerCharacter_selector_required"
	)


# Disconnect the signals connected to the active character FSM.
func _disconnect_signals_from_character() -> void:
	# Disconnect encounter from current player 'Wait' state
	enc.disconnect(
			"player_turn_started",
			active_char.fsm.state_nodes["Wait"],
			"_on_Encounter_player_turn_started"
	)
	# Disconnect encounter from current player 'Standby' state
	enc.disconnect(
			"move_tile_selected",
			active_char.fsm.state_nodes["Standby"],
			"_on_Encounter_move_tile_selected"
	)
	# Disconnect encounter UI from current player 'Standby' state
	enc.ui.disconnect(
			"player_turn_ended",
			active_char.fsm.state_nodes["Standby"],
			"_on_EncounterUI_player_turn_ended"
	)
	# Disconnect selector from current player 'Move' state
	enc.selector.disconnect(
			"selector_paused",
			active_char.fsm.state_nodes["Move"],
			"_on_Selector_selector_paused"
	)


# Determine the path to the selected tile for character movement and signal that
# the movement tile has been selected.
func _on_Selector_move_tile_selected(tile: MapTile) -> void:
	var path_data: PoolVector3Array = enc.hex_map.get_point_path_for_player(
		active_char,
		tile.get_map_index(),
		enc.enemies,
		movement_area
	)
	enc.emit_move_tile_selected(path_data)


# Clear the tile movement highlights, update the initiative tracker and
# transition to either the PlayerTurn state or the EnemyTurn state depending 
# on the next character.
func _on_EncounterUI_player_turn_ended(_player: PlayerCharacter) -> void:
	enc.hex_map.clear_highlights()
	enc.hex_map.clear_selector_highlights()
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		# Pause for a little bit to give the EncounterUI a chance to get ready.
		# Workaround for bug where the UI does not show up when the player did nothing prior.
		yield(get_tree().create_timer(0.1), "timeout")
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)


# Updates the tile highlights to show the area range of the action.
func _on_EncounterUI_player_action_selected(_p: PlayerCharacter, action: Action) -> void:
	var area_indexes: Array = enc.hex_map.determine_area_indexes(
		action.area_range,
		action.get_emission_map_index()
	)
	enc.hex_map.clear_highlights()
	enc.hex_map.highlight_player_action_area(area_indexes, active_char)


# Called when the user backs out from an action type menu. Resets the tile highlights
# to indicate player movement.
func _on_EncounterUI_player_action_type_canceled() -> void:
	enc.hex_map.clear_highlights()
	enc.hex_map.clear_selector_highlights()
	enc.hex_map.highlight_player_movement(movement_area, active_char, start_index)


# Updates the tile selectors to show the effect range of an action
func _on_Selector_effect_selector_required(action: Action) -> void:
	enc.hex_map.clear_selector_highlights()
	var effect_area_indexes: Array = enc.hex_map.determine_area_indexes(
		action.effect_range,
		action.get_emission_map_index(),
		action.get_emission_direction()
	)
	enc.hex_map.highlight_effect_area(effect_area_indexes, action.effect_ignore_heights)
