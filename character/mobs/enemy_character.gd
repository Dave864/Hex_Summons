class_name EnemyCharacter
extends Character
"""
Handles actions specific to enemy characters.
"""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = $Stats
	_movement_node = $Stats/Movement
	_movement_node.translation = Vector3(translation.x, 0.0, translation.z)


# Returns the type of the character, ENEMY.
func get_type() -> int:
	return Constants.MapOccupants.ENEMY


# Virtual function. Moves all collision objects, enemy position, movement node,
# and all action collisions.
func move_collisions(p: Vector3) -> void:
	translation = p
	var adjusted_p: Vector3 = Vector3(p.x, 0.0, p.z)
	_movement_node.translation = adjusted_p
	for action in get_node("Actions").get_children():
		action.area_pt.translation = adjusted_p
