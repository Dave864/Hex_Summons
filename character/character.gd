class_name Character
extends Area
"""
Base class for players, mobs, and bosses. Contains a character's stats and map
position details.
"""


# The stats of the character. Uses the CoreStats resource.
export(Resource) var stats

# Flag that indicates whether the creature has been set to its starting location.
var _start_set: bool = false setget , get_is_start_set
var _current_index: int = -1 setget , get_index_at

# References to the various attacks and spells the character has access to.
onready var _techniques: Array = $Techniques.get_children() setget , get_techniques
onready var _spells: Array = $Spells.get_children() setget , get_spells


# Get the index of the tile the character is currently at.
func get_index_at() -> int:
	return _current_index


# Get whether or not the starting location of the character has been set.
func get_is_start_set() -> bool:
	return _start_set


# Get the techniques associated with the character
func get_techniques() -> Array:
	return _techniques


# Get the spells associated with the character
func get_spells() -> Array:
	return _spells


# Virtual function. Returns the type of the character.
func get_type() -> int:
	return Constants.MapOccupants.EMPTY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	"""
	TODO: Temporarily sets current hp to max for testing purposes
	"""
	stats.set_current_hp(stats.get_max_hp())


func _on_Creature_area_entered(map_tile) -> void:
	_current_index = map_tile.get_index()
	# If the creature's start position has not been set, move it to the position
	# of the tile it in the area of.
	if !_start_set:
		_start_set = true
		translation = map_tile.translation
