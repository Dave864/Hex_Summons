class_name EffectAspect
extends Node
## Defines an aspect of an effect. This applies some kind of modifier to a
## specified character stat.


## Describes what the aspect targets.
enum Target {
	SELF,
	ALLIES,
	OPPONENTS,
	NONE,
}
## The different calculation options. Corresponds to the respective strength
## calculators.
enum CalculationType {
	STRENGTH,
	FLAT,
	PERCENT
}
## Describes how this effect is impacted by resistances.
enum ResEffect {
	NONE, ## This effect is not affected.
	STRENGTH, ## The strength of this effect is reduced.
	DURATION, ## The duration of this effect is reduced.
}

## The target of this effect.
@export var target: Target = Target.NONE
## The stat impacted by this effect.
@export var stat_affected: Stat.Type = Stat.Type.CUR_HEALTH
## The method that determines the strength of this effect.
@export var calculation_type: CalculationType = CalculationType.STRENGTH
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
## The method that determines the strength of this effect.
var calculation_method: StrengthCalculation = null:
	set = _set_calculation_method

## The stats of the character that will apply this effect.
var _source_stats: StatModifiers = null
## The current values of the character stats.
var _current_stats: AllStats = null
## The potency of the action the parent effect is assigned to.
var _action_potency: Potency = null


## Called when a new instance of this object is created.
func _init() -> void:
	_initialize_calculation_method()


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


## Updates the source character stats of this effect aspect.
func set_source_stats(new_source: StatModifiers) -> void:
	_source_stats = new_source
	update_current_stats()


## Updates the action potency data.
func set_action_potency(new_potency: Potency) -> void:
	_action_potency = new_potency


## Gets the current values of the source stats.
func update_current_stats() -> void:
	_current_stats = _source_stats.get_all()


## Determines the numerical result of the effect on a target set of character
## stats.
func effect_on_target(target_stats: StatModifiers) -> int:
	var base_str: float = calculation_method.base_strength(
			_current_stats,
			_action_potency
	)
	var efficacy: float = 1.0
	if resistance_effect != ResEffect.NONE:
		efficacy = calculation_method.efficacy(
				_current_stats,
				target_stats,
				_action_potency
		)
	match resistance_effect:
		ResEffect.DURATION:
			turn_duration = int(round(max_turn_duration * efficacy))
			return int(base_str)
		ResEffect.STRENGTH:
			turn_duration = max_turn_duration
			return calculation_method.process_operation(
					base_str,
					efficacy,
					stat_affected,
					operation
			)
		_:
			turn_duration = max_turn_duration
			return 0


## Sets the calculation method to match the set type. Called during initialization.
func _initialize_calculation_method() -> void:
	match calculation_type:
		CalculationType.STRENGTH:
			calculation_method = StrengthCalculation.new()
		CalculationType.FLAT:
			calculation_method = FlatValueCalculation.new()
		CalculationType.PERCENT:
			calculation_method = PercentageCalculation.new()


## Sets the calculation method and updates the calculation type flag to match.
func _set_calculation_method(new_method: StrengthCalculation) -> void:
	calculation_method = new_method
	if calculation_method is FlatValueCalculation:
		calculation_type = CalculationType.FLAT
	elif calculation_method is PercentageCalculation:
		calculation_type = CalculationType.PERCENT
	else:
		calculation_type = CalculationType.STRENGTH


## Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			calculation_method != null,
			ErrorUtil.missing_required_parameter(name, "strength_calculation")
	)
	assert(
			calculation_method is StrengthCalculation,
			"Effect %s strength_calculation is not a StrengthCalculation resource." % [name]
	)
