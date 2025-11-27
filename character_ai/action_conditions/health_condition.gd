class_name HealthCondition
extends ActionCondition
## ActionCondition that checks if a given character meets a given health threshold.


## The percentage of health that is compared to when checking if this
## condition is met.
@export var threshold = 1.0 # (float, 0.0, 1.0)
## Indicates if this condition checks if the health is above or below the
## specified threshold.
@export var below: bool = false


## Virtual function. Checks if the condition has been met given the current
## state of the characters and map.
func is_met(
	character: Character,
	_targets: Array,
	_distance_map: DistanceMap
) -> bool:
	var cur_health: int = character.stats.get_stat(Stat.Type.CUR_HEALTH)
	var max_health: int = character.stats.get_stat(Stat.Type.MAX_HEALTH)
	var t_health: int = max_health * threshold
	
	return cur_health <= t_health if below else cur_health >= t_health
