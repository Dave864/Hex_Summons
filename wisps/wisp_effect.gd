class_name WispEffect
extends Resource
## Defines a bonus effect a wisp has.
##
## This applies a percentage modifier to a specified character stat.


## The stat of the target that is affected by this effect.
@export var stat_affected: Stat.Type = Stat.Type.MAX_HEALTH
## How the targeted stat is modified.
@export var operation: Stat.Operation = Stat.Operation.SET
## The percentage amount the bonus affects the target stat by.
@export_range(0.0, 4.0, 0.1, "exp") var percent_bonus: float = 0.0


## Determines the numerical result of this effect on a target set of character stats.
func effect_on_character(target_stats: CharacterStatModifiers) -> int:
	var percentage_modifier = PercentageCalculation.new(percent_bonus)
	return percentage_modifier.process_operation(
			target_stats.get_stat(Stat.Type.ATTACK),
			1.0,
			stat_affected,
			operation
	)
