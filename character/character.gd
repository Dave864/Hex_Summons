class_name Character
extends Spatial
"""
Base class for players, mobs, and bosses. Contains a character's stats and map
position details.
"""


var stats: CharacterStats
# Flag that indicates whether the creature has been set to its starting location.
var _start_set: bool = false setget , get_is_start_set
var _current_index: int = -1 setget , get_map_index_at

# Reference to the Character sprite.
onready var character_sprite: Sprite3D = $Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	"""
	TODO: Temporarily sets current hp to max for testing purposes
	"""
#	stats.set_current_hp(stats.get_max_hp())


# Get the index of the tile the character is currently at.
func get_map_index_at() -> int:
	return _current_index


# Get whether or not the starting location of the character has been set.
func get_is_start_set() -> bool:
	return _start_set


# Virtual function. Returns the type of the character.
func get_type() -> int:
	return Constants.MapOccupants.EMPTY


# Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(_index: int) -> void:
	pass


# Update the character's position index when passing over a MapTile.
func _on_Character_area_entered(map_tile: Area) -> void:
	_current_index = map_tile.get_map_index()
	_update_emission_index(map_tile.get_map_index())
	# If the creature's start position has not been set, move it to the position
	# of the tile it in the area of.
	if !_start_set:
		_start_set = true
