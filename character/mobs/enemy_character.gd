class_name EnemyCharacter
extends Character
"""
Handles actions specific to enemy characters.
"""


export(NodePath) var movement = null
export(NodePath) var health = null
export(NodePath) var attack = null
export(NodePath) var defense = null
export(NodePath) var agility = null
export(NodePath) var magic_earth = null
export(NodePath) var magic_fire = null
export(NodePath) var magic_water = null
export(NodePath) var magic_wind = null
export(NodePath) var res_earth = null
export(NodePath) var res_fire = null
export(NodePath) var res_water = null
export(NodePath) var res_wind = null


# Returns the type of the character, ENEMY.
func get_type() -> int:
	return Constants.MapOccupants.ENEMY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
