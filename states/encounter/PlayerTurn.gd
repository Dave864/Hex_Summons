extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `PlayerTurn` state.
Handles the encounter logic needed to allow the player character to properly
run during their turn. Goes to the `PlayerTurn` state if the next character
in initiative is also a player character. Goes to the `EnemyTurn` state if an
enemy character is next in intiative. Goes to the `End` state if either all
player characters or all enemy characters are defeated. 
"""


# The index of tiles that the player can move to.
var movement_range: Array = []
# The index of tiles in reach of an action. 
var action_range: Dictionary = {"type": null, "tiles": null}


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	movement_range = enc.get_current_character().stats.get_movement_area()
	enc.hex_map.highlight_player_movement(movement_range, enc.get_current_character())
	SignalBus.emit_signal("player_turn_started", enc.get_current_character())
	
	# This signal is used by other states and will be disconnected to avoid
	# unintended behavior.
	ErrorUtil.connect_signal(
		enc.selector,
		"move_tile_selected",
		self,
		"_on_Selector_move_tile_selected"
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
	enc.selector.disconnect("move_tile_selected", self, "_on_Selector_move_tile_selected")


func _ready_connect_signals() -> void:
	ErrorUtil.connect_signal(
		SignalBus,
		"player_turn_ended",
		self,
		"_on_SignalBus_player_turn_ended"
	)


func _on_Selector_move_tile_selected(tile: MapTile) -> void:
	var data: PoolVector3Array = enc.hex_map.get_point_path_toward_for_character(
		enc.get_current_character(),
		movement_range,
		tile.get_map_index(),
		enc.enemies,
		enc.players
	)
	SignalBus.emit_signal("tile_selected", data)


func _on_SignalBus_player_turn_ended(_player: PlayerCharacter) -> void:
	enc.hex_map.clear_highlights()
	var next_character: Character = enc.get_next_character()
	enc.progress_initiative()
	if next_character is PlayerCharacter:
		# Pause for a little bit to give the EncounterUI a chance to get ready.
		# Workaround for bug where the UI does not show up when the player did nothing prior.
		yield(get_tree().create_timer(0.1), "timeout")
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
