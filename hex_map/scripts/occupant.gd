tool
extends Node
class_name Occupant
"""
Keeps track of the current occupant at a given map tile.
"""


# The current occupant of the tile.
var _occupant: Character = null setget , get_current_occupant


# Gets the current character occupying this tile.
func get_current_occupant() -> Character:
	return _occupant


# Check if the tile is able to be moved through by the specifed character type.
func can_character_pass(character_type: int) -> bool:
	match character_type:
		Constants.MapOccupants.PLAYER:
			return _occupant == null or _occupant.get_type() == Constants.MapOccupants.PLAYER
		Constants.MapOccupants.ENEMY:
			return _occupant == null or _occupant.get_type() == Constants.MapOccupants.ENEMY
		_:
			return true


# Updates the occupant when a new area enters the collision space.
func _on_MapTile_area_entered(area) -> void:
	# Add entered character as this tile's occupant.
	if (
		_occupant == null 
		and (area is PlayerCharacter or area is EnemyCharacter)
	):
		_occupant = area


# Removes the occupant if it leaves the collision space.
func _on_MapTile_area_exited(area) -> void:
	if _occupant != null and area.name == _occupant.name:
		_occupant = null
