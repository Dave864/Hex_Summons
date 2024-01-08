class_name Encounter
extends Node
"""
Manages the events of an encounter.
"""


# Reference to the encounter hex_map. This is to allow for differently named
# hex map scene to be used.
export(NodePath) var hex_map_path = null

var rf: RangeFinder

var _initiative_tracker: Array
var _cur_init: int = 0
"""
TODO: Currently here to enable the EnemyCharacter to work. EnemyCharacter will
eventually need logic for AI.
"""
var _p: PlayerCharacter =  null

onready var players: Array = $Players.get_children()
onready var enemies: Array = $Enemies.get_children()
onready var selector: Selector = $Selector
onready var ui: Control = $UI


# Called when the node enters the scene tree for the first time.
func _ready():
	var hex_map: HexMap = get_node(hex_map_path)
<<<<<<< HEAD
	_rf = RangeFinder.new(
		hex_map.get_x_count(),
		hex_map.get_z_count(),
=======
	rf = RangeFinder.new(
		hex_map.x_count,
		hex_map.z_count,
>>>>>>> 6506953 (character-technique: Added prototye UI to allow for swapping between)
		Constants.MapOccupants.EMPTY,
		hex_map.get_map_tiles()
	)
	
	_p = players[0]


# Move the initiative counter to the next index or reset it back to the start.
func progress_initiative():
	_cur_init += 1
	_cur_init = 0 if _cur_init == _initiative_tracker.size() else _cur_init


# Gets the next character in the intiative track.
func get_next_character() -> Character:
	var next_init: int = (
		_cur_init + 1 if _cur_init + 1 < _initiative_tracker.size() 
		else 0
	)
	return _initiative_tracker[next_init]


# Gets the character currently in initiative.
func get_current_character() -> Character:
	return _initiative_tracker[_cur_init]
