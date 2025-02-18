class_name Encounter
extends Node
"""
Manages the events of an encounter.
"""


# Reference to the encounter hex_map. This is to allow for differently named
# hex map scene to be used.
export(NodePath) var hex_map_path = null

var hex_map: HexMap = null
var hm_astar: HexMapAStar

var initiative_tracker: Array
var cur_init: int = 0

onready var players: Array = $Players.get_children()
onready var enemies: Array = $Enemies.get_children()
onready var selector: Selector = $Selector
onready var ui: EncounterUI = $EncounterUI


# Move the initiative counter to the next index or reset it back to the start.
func progress_initiative() -> void:
	cur_init += 1
	cur_init = 0 if cur_init >= initiative_tracker.size() else cur_init
	ui.initiative_tracker.update_initiative(cur_init)


# Gets the next character in the intiative track.
func get_next_character() -> Character:
	var next_init: int = cur_init + 1
	next_init = 0 if next_init >= initiative_tracker.size() else next_init
	return initiative_tracker[next_init]


# Gets the character currently in initiative.
func get_current_character() -> Character:
	return initiative_tracker[cur_init]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hex_map = get_node(hex_map_path)
	hm_astar = HexMapAStar.new(
		hex_map.get_x_count(),
		hex_map.get_z_count(),
		hex_map.get_map_tiles(),
		players,
		enemies
	)
