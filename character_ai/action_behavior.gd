class_name ActionBehavior
extends Node
"""
Collection of flags that defines how an action should be used. Also contains any
conditions that must be met in order for the action to be used.
"""


enum Target {
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

@export var target: Target = Target.OPPONENTS
@export var target_focus: TargetFocus = TargetFocus.THREAT
@export var movement_behavior: Movement = Movement.STAND
@export var randomize_move_dist: bool = false

var _cooldown: Cooldown = null
var _conditions: Array = []
var _target_group: bool = false: get = target_group
var _group_condition: GroupCondition = null: get = get_group_condition


# Evaluates if all conditions have been met.
func conditions_met(
	character: Character,
	targets: Array,
	distance_map: DistanceMap
) -> bool:
	if _cooldown != null and _cooldown.is_active():
		return false
	if _conditions.size() == 0:
		return true
	for c in _conditions:
		if not c.is_met(character, targets, distance_map):
			return false
	return true


# Returns if the action should target a group.
func target_group() -> bool:
	return _target_group


# Returns the GroupCondition node reference.
func get_group_condition() -> GroupCondition:
	return _group_condition


# Called when the node enters the scene tree for the first time.
func _ready():
	_target_group = false
	for n in get_children():
		if n is ActionCondition:
			_conditions.append(n)
			if n is GroupCondition:
				assert(
						_target_group == false,
						"Multiple GroupCondition nodes assigned to ActionBehavior"
				)
				_target_group = true
				_group_condition = n
		elif n is Cooldown:
			assert(
					_cooldown == null,
					"Multiple Cooldowns assigned to ActionBehavior"
			)
			_cooldown = n
