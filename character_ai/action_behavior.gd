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
enum TargetFocus {
	THREAT,
	CLOSEST,
	FARTHEST
}
enum Movement {
	STAND,
	TOWARD,
	AWAY
}

export(Target) var target = Target.NONE
export(TargetFocus) var target_focus = TargetFocus.THREAT
export(Movement) var movement_behavior = Movement.STAND

var _cooldown: Cooldown = null
var _conditions: Array = []
var _target_group: bool = false setget , target_group


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


# Returns if the action should target a group
func target_group() -> bool:
	return _target_group


# Called when the node enters the scene tree for the first time.
func _ready():
	for n in get_children():
		if n is ActionCondition:
			_conditions.append(n)
			if n is GroupCondition:
				_target_group = true
		elif n is Cooldown:
			assert(
					_cooldown == null,
					"Multiple Cooldowns assigned to ActionBehavior"
			)
			_cooldown = n
