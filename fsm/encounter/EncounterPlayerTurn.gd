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
var _active_char: PlayerCharacter = null
# The index of tiles that the player can move to.
var _movement_area: Array = []
# The index of the tile the player starts from.
var _start_index: int = 0
# The index of tiles in reach of an action. 
var _action_range: Dictionary = {"type": null, "tiles": null}


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_active_char = enc.get_current_character()
	_start_index = _active_char.get_map_index_at()
	_movement_area = enc.hex_map.range_finder.get_character_travesible_tiles(
			_active_char,
			enc.enemies
	)
	enc.hex_map.selection_tracker.highlight_player_movement(
			_movement_area,
			_active_char
	)
	
	_connect_signals()
	SignalBus.emit_player_turn_started(_active_char)


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
	_disconnect_signals()


# Connect signals that will persist throughout the life of this state.
func _ready_connect_signals() -> void:
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


# Connect the relevant signals to this state.
# These signals are used by other states and will be disconnected to avoid
# unintended behavior.
func _connect_signals() -> void:
	ErrorUtil.connect_signal(
			enc.selector,
			"move_tile_selected",
			self,
			"_on_Selector_move_tile_selected"
	)
	ErrorUtil.connect_signal(
			enc.selector,
			"effect_area_required",
			self,
			"_on_Selector_effect_area_required"
	)


# Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	enc.selector.disconnect(
			"move_tile_selected",
			self,
			"_on_Selector_move_tile_selected"
	)
	enc.selector.disconnect(
			"effect_area_required",
			self,
			"_on_Selector_effect_area_required"
	)


# Determine the path to the selected tile for character movement and signal that
# the movement tile has been selected.
func _on_Selector_move_tile_selected(tile: MapTile) -> void:
	var path_data: PoolVector3Array = enc.hex_map.range_finder.get_player_point_path(
			_active_char,
			tile.map_coordinate.get_map_index(),
			enc.enemies,
			_movement_area
	)
	enc.move_path.create_segmented_bezier_path(path_data)
	SignalBus.emit_move_path_created(enc.move_path)


# Updates the tile selectors to show the effect range of an action
func _on_Selector_effect_area_required(action: Action) -> void:
	enc.hex_map.selection_tracker.clear_selector_highlights()
	var effect_area_indexes: Array = enc.hex_map.range_finder.get_effect_range_indexes(
			action.effect_range,
			action.get_emission_map_index(),
			action.get_emission_direction(),
			action.effect_ignore_heights
	)
	enc.hex_map.selection_tracker.select_effect_range(
			effect_area_indexes,
			_active_char.get_map_index_at(),
			action.effect_ignores_caster,
			action.get_is_cardinal()
	)


# Clear the tile movement highlights, update the initiative tracker and
# transition to either the PlayerTurn state or the EnemyTurn state depending 
# on the next character.
func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	enc.hex_map.selection_tracker.clear_highlights()
	enc.hex_map.selection_tracker.clear_selector_highlights()
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		# Pause for a little bit to give the EncounterUI a chance to get ready.
		# Workaround for bug where the UI does not show up when the player did nothing prior.
		yield(get_tree().create_timer(0.1), "timeout")
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)


# Updates the tile highlights to show the source range of the action.
func _on_SignalBus_player_action_selected(_p: PlayerCharacter, action: Action) -> void:
	var source_indexes: Array = enc.hex_map.range_finder.get_source_range_indexes(
			action.source_range,
			action.dead_range,
			_p.map_coordinate.get_map_index(),
			action.source_ignore_heights
	)
	enc.hex_map.selection_tracker.clear_highlights()
	enc.hex_map.selection_tracker.highlight_action_source_area(
			source_indexes,
			_active_char
	)


# Called when the user backs out from an action type menu. Resets the tile highlights
# to indicate player movement.
func _on_SignalBus_player_action_type_canceled() -> void:
	enc.hex_map.selection_tracker.clear_highlights()
	enc.hex_map.selection_tracker.clear_selector_highlights()
	enc.hex_map.selection_tracker.highlight_player_movement(
			_movement_area,
			_active_char,
			_start_index
	)
