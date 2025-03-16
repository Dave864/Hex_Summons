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
	SignalBusEncounter.emit_signal("player_turn_started", active_char)
	
	# These signals are used by other states and will be disconnected to avoid
	# unintended behavior.
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
	ErrorUtil.connect_signal(
		SignalBusEncounter,
		"player_action_selected",
		self,
		"_on_SignalBusEncounter_player_action_selected"
	)
	ErrorUtil.connect_signal(
		SignalBusEncounter,
		"player_action_type_canceled",
		self,
		"_on_SignalBusEncounter_player_action_type_canceled"
	)


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
	SignalBusEncounter.disconnect(
		"player_action_selected",
		self,
		"_on_SignalBusEncounter_player_action_selected"
	)
	SignalBusEncounter.disconnect(
		"player_action_type_canceled",
		self,
		"_on_SignalBusEncounter_player_action_type_canceled"
	)


func _ready_connect_signals() -> void:
	ErrorUtil.connect_signal(
		SignalBusEncounter,
		"player_turn_ended",
		self,
		"_on_SignalBusEncounter_player_turn_ended"
	)


# Determine the path to the selected tile for character movement and signal that
# the movement tile has been selected.
func _on_Selector_move_tile_selected(tile: MapTile) -> void:
	var data: PoolVector3Array = enc.hex_map.get_point_path_for_player(
		active_char,
		tile.get_map_index(),
		enc.enemies,
		movement_area
	)
	SignalBusEncounter.emit_signal("move_tile_selected", data)


# Clear the tile movement highlights, update the initiative tracker and
# transition to either the PlayerTurn state or the EnemyTurn state depending 
# on the next character.
func _on_SignalBusEncounter_player_turn_ended(_player: PlayerCharacter) -> void:
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
func _on_SignalBusEncounter_player_action_selected(_p: PlayerCharacter, action: Action) -> void:
	var area_indexes: Array = enc.hex_map.determine_area_indexes(
		action.area_range,
		action.get_emission_map_index()
	)
	enc.hex_map.clear_highlights()
	enc.hex_map.highlight_player_action_area(area_indexes, active_char)


# Updates the tile selectors to show the effect range of an action
func _on_Selector_effect_selector_required(
	action: Action,
	ignore_heights: bool
) -> void:
	enc.hex_map.clear_selector_highlights()
	var effect_area_indexes: Array = enc.hex_map.determine_area_indexes(
		action.effect_range,
		action.get_emission_map_index(),
		action.get_emission_direction()
	)
	enc.hex_map.highlight_effect_area(effect_area_indexes, ignore_heights)


# Called when the user backs out from an action type menu. Resets the tile highlights
# to indicate player movement.
func _on_SignalBusEncounter_player_action_type_canceled() -> void:
	enc.hex_map.clear_highlights()
	enc.hex_map.clear_selector_highlights()
	enc.hex_map.highlight_player_movement(movement_area, active_char, start_index)
