@tool
extends Node
class_name Occupant
## The current occupant at a given map tile.


## The current occupant of the tile.
var _occupant: Character = null: get = get_current_occupant


## Gets the current character occupying this tile.
func get_current_occupant() -> Character:
	return _occupant


## Check if the tile is able to be moved through by the specifed character type.
func can_character_pass(character_type: int) -> bool:
	match character_type:
		Character.Type.PLAYER:
			return _occupant == null or _occupant.get_type() == Character.Type.PLAYER
		Character.Type.ENEMY:
			return _occupant == null or _occupant.get_type() == Character.Type.ENEMY
		_:
			return true


## Updates the occupant when a new area enters the collision space.
func _on_MapTile_area_entered(area: Character) -> void:
	# Add entered character as this tile's occupant.
	if _occupant == null:
		_occupant = area


## Removes the occupant if it leaves the collision space.
func _on_MapTile_area_exited(area: Character) -> void:
	if _occupant != null and area.name == _occupant.name:
		_occupant = null
