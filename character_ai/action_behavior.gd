class_name ActionBehavior
extends Node
"""
Collection of flags that defines how an action should be used. Also contains any
conditions that must be met in order for the action to be used.
"""


enum Target {
	NONE,
	ALLIES,
	OPPONENTS
}
enum Movement {
	STAND,
	TOWARD,
	AWAY
}

export(Target) var target_behavior = Target.NONE
export(Movement) var movement_behavior = Movement.STAND

var _cooldown: Cooldown = null
var _conditions: Array = []


# Evaluates if all conditions have been met.
func conditions_met(
	character: Character,
	targets: Array,
	distance_map: Dictionary
) -> bool:
	if _cooldown != null and _cooldown.is_active():
		return false
	if _conditions.size() == 0:
		return true
	for c in _conditions:
		if not c.is_met(character, targets, distance_map):
			return false
	return true


# Called when the node enters the scene tree for the first time.
func _ready():
	for n in get_children():
		if n is ActionCondition:
			_conditions.append(n)
		elif n is Cooldown:
			assert(
					_cooldown == null,
					"Multiple Cooldowns assigned to ActionBehavior"
			)
			_cooldown = n
