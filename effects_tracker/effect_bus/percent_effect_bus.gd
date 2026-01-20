class_name PercentEffectBus
extends EffectBus
## Data structure used to keep track of effects that adjust a stat by percentage
## amounts and their durations.
##
## Provides logic to evaluate the result of the effects.


## Checks that the effect is a PercentActionEffect that does not set the stat
## to some value.
func _is_tracked_strength_calculation(effect: ActionEffect) -> bool:
	return (
		effect.operation != Stat.Operation.SET
		and effect is PercentActionEffect
	)
