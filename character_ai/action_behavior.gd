class_name ActionBehavior
extends Node
## Collection of flags and conditions that defines how an action should be used.


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

## The classification of characters this action targets.
@export var target: Target = Target.OPPONENTS
## How a specific target is determined.
@export var target_focus: TargetFocus = TargetFocus.THREAT
## The movement direction prioritized when repositioning to hit a target.
@export var movement_behavior: Movement = Movement.STAND
## Whether the amount of spaced moved is randomized. By default, the minimum
## required spaces is used.
@export var randomize_move_dist: bool = false

var _cooldown: Cooldown = null
var _conditions: Array[ActionCondition] = []
var _target_group: bool = false: get = target_group
var _group_condition: GroupCondition = null: get = get_group_condition


## Called when the node enters the scene tree for the first time.
func _ready():
	_target_group = false
	for n: Node in get_children():
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


## Evaluates if all conditions have been met.
func conditions_met(
	character: Character,
	targets: Array[Character],
	distance_map: DistanceMap
) -> bool:
	if _cooldown != null and _cooldown.is_active():
		return false
	if _conditions.size() == 0:
		return true
	for c: ActionCondition in _conditions:
		if not c.is_met(character, targets, distance_map):
			return false
	return true


## Returns if the action should target a group.
func target_group() -> bool:
	return _target_group


## Returns the GroupCondition node reference.
func get_group_condition() -> GroupCondition:
	return _group_condition
