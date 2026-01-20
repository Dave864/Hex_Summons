class_name SetEffectBus
extends EffectBus
## Data structure used to keep track of effects that adjust a stat by setting it
## to some value and their durations.
##
## Provides logic to evaluate the result of the effects.


## Checks that the effect sets the stat to some value.
func _is_tracked_strength_calculation(effect: ActionEffect) -> bool:
	return effect.operation == Stat.Operation.SET
