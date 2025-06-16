class_name Encounter
extends Node
"""
Manages the events of an encounter.
"""


# Reference to the encounter hex_map. This is to allow for differently named
# hex map scene to be used.
export(NodePath) var hex_map_path = null

var hex_map: HexMap = null

var initiative_tracker: Array
var cur_init: int = 0

onready var players: Array = $Players.get_children()
onready var enemies: Array = $Enemies.get_children()
onready var selector: Selector = $Selector
onready var move_path: HexMapMovementPath = $MovementPath
onready var ui: EncounterUI = $EncounterUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()
	"""
	TODO: implement logic to load the HexMap, based on some details determined
	out of scene.
	"""
	hex_map = get_node(hex_map_path)
	_connect_map_to_selector()
	
	"""
	TODO: implement logic to load the players and enemies, placing them at
	appropriate spots on the HexMap.
	"""
	
	for p in players:
		"""
		TODO: Implement logic to load player stats from out of scene details.
		"""
		p.stats.max_cur_health()
		ui.track_party_member(p)
	
	for e in enemies:
		ui.track_enemy(e)


# Move the initiative counter to the next index or reset it back to the start.
func progress_initiative() -> void:
	cur_init = _determine_init_index(cur_init + 1)
	ui.initiative_tracker.update_initiative(cur_init)


# Gets the next character in the intiative track.
func get_next_character() -> Character:
	var next_init: int = _determine_init_index(cur_init + 1)
	return initiative_tracker[next_init]


# Gets the character currently in initiative.
func get_current_character() -> Character:
	return initiative_tracker[cur_init]


# Determines which index in the initiative array that a given value corresponds
# to. Numbers that are larger than the size of the array wrap around to index zero
# before resuming count. Numbers that are smaller than zero wrap around to the
# end of the array before resuming count.
func _determine_init_index(init_value: int) -> int:
	return wrapi(init_value, 0, initiative_tracker.size())


# Connects all map tile "mouse_hovered" signals to the selector.
func _connect_map_to_selector() -> void:
	for mt in hex_map.get_map_tiles():
		ErrorUtil.connect_signal(
				mt,
				"mouse_hovered",
				selector,
				"_on_MapTile_mouse_hovered"
		)


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
		hex_map_path != null,
		"Encounter has not set the path for the hex_map."
	)
	assert(players.size() > 0, "No players are present.")
	assert(enemies.size() > 0, "No enemies are present.")
	assert(
		selector != null,
		ErrorUtil.missing_required_parameter(name, selector.name)
	)
	assert(ui != null, ErrorUtil.missing_required_parameter(name, ui.name))
