class_name Character
extends Spatial
"""
Base class for players, mobs, and bosses. Contains a character's stats and map
position details.
"""


enum Type {
	ENEMY,
	PLAYER,
	NONE
}

var stats: CharacterStats
# Flag that indicates whether the creature has been set to its starting location.
var _start_set: bool = false setget , get_is_start_set

# Reference to the Character sprite.
onready var character_sprite: Sprite3D = $Sprite3D
onready var map_coordinate: MapCoordinate = $MapCoordinate
onready var hit_box: Area = $HitBox


# Get whether or not the starting location of the character has been set.
func get_is_start_set() -> bool:
	return _start_set


# Virtual function. Returns the type of the character.
func get_type() -> int:
	return Type.NONE


# Exposes the hitbox to action collisions.
func activate_hit_box() -> void:
	hit_box.monitoring = true


# Hides the hitbox from all collisions.
func deactivate_hit_box() -> void:
	hit_box.monitoring = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	"""
	TODO: Temporarily sets current hp to max for testing purposes
	"""
#	stats.set_current_hp(stats.get_max_hp())


# Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(_index: int) -> void:
	pass


# Update the character's position index when passing over a MapTile.
func _on_Character_area_entered(map_tile: Area) -> void:
	_update_emission_index(map_tile.map_coordinate.get_index())
	map_coordinate.set_index(map_tile.map_coordinate.get_index())
	map_coordinate.set_cube_coord(map_tile.map_coordinate.get_cube_coord())
	# If the creature's start position has not been set, move it to the position
	# of the tile it in the area of.
	if !_start_set:
		_start_set = true
