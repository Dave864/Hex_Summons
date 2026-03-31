class_name ActionEffect
extends Node
## Base class for an effect of an action. Uses the base StrengthCalculation
## when modifying target stats.
##
## An ActionEffect specifies how a specific character stat is to be modified.
## Also specifies what category of character this effect impacts (self, allies,
## enemies). Derived classes specify specific calculation methods for how the
## stats are to be adjusted.


## Describes what the aspect targets.
enum Target {
	SELF, ## The character who used the action.
	ALLIES, ## Characters who are allies to the action's owner.
	OPPONENTS, ## Characters who are enemies to the action's owner.
}
## Describes how this effect is impacted by resistances.
enum ResEffect {
	NONE, ## This effect is not affected.
	STRENGTH, ## The strength of this effect is reduced.
	DURATION, ## The duration of this effect is reduced.
}

## The target of this effect.
@export var target: Target = Target.SELF
## The stat impacted by this effect.
@export var stat_affected: Stat.Type = Stat.Type.CUR_HEALTH
## How the targeted stat is modified.
@export var operation: Stat.Operation = Stat.Operation.SET
## Indicates how resistance will impact this effect.
@export var resistance_effect: ResEffect = ResEffect.NONE
## The maximum number of turns this effect can last after application. A value
## of zero means the effect is applied immediately.
@export_range(0, 100) var max_turn_duration: int = 0

## How many turns does this effect last after application when adjusted for
## resistances.
var turn_duration: int = max_turn_duration
## The id of the character that cast this action.
var caster_id: int:
	get:
		if _source_stats == null:
			return -1
		return _source_stats.character_id
## The type of the character that cast this action.
var caster_type: Character.Type:
	get:
		if _source_stats == null:
			return Character.Type.NONE
		return _source_stats.character_type

## The method that determines the strength of this effect.
var _calculation_method: StrengthCalculation = null
## The stats of the character that will apply this effect.
var _source_stats: StatModifiers = null
## A recording of the values of the character stats.
var _stats_snapshot: AllStats = null
## The potency of the action the parent effect is assigned to.
var _action_potency: Potency = null


## Called when the node enters the scene tree for the first time.
func _ready():
	_calculation_method = StrengthCalculation.new()


## Updates the source character stats of this effect aspect.
func set_source_stats(new_source: StatModifiers) -> void:
	_source_stats = new_source
	update_stats_snapshot()


## Updates the action potency data.
func set_action_potency(new_potency: Potency) -> void:
	_action_potency = new_potency


## Updates the recorded values of the source stats.
func update_stats_snapshot() -> void:
	_stats_snapshot = _source_stats.get_all()
