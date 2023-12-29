class_name Character
extends Area
"""
Base class for players, mobs, and bosses. Contains a character's stats and map
position details.
"""


# The stats of the character
export(Resource) var stats

# Flag that indicates whether the creature has been set to its starting location.
var _start_set: bool = false
var _current_index: int = -1 setget , get_index_at

# References to the various attacks and spells the character has access to.
onready var _techniques: Array = $Techniques.get_children()
onready var _spells: Array = $Spells.get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_Creature_area_entered(map_tile):
	_current_index = map_tile.get_index()
	# If the creature's start position has not been set, move it to the position
	# of the tile it in the area of.
	if !_start_set:
		_start_set = true
		translation = map_tile.translation


# Get the index of the tile the character is currently at.
func get_index_at() -> int:
	return _current_index
