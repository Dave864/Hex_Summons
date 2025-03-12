class_name EnemyCharacter
extends Character
"""
Handles actions specific to enemy characters.
"""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = $Stats
	stats.max_cur_health()


# Returns the type of the character, ENEMY.
func get_type() -> int:
	return Constants.MapOccupants.ENEMY


# Virtual function. Moves all collision objects, enemy position, movement node,
# and all action collisions.
func move_collisions(p: Vector3) -> void:
	translation = p
	var adjusted_p: Vector3 = Vector3(p.x, 0.0, p.z)
	for action in get_node("Actions").get_children():
		action.emission_pt.translation = adjusted_p
