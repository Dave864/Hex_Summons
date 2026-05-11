@abstract
class_name StatModifiers
extends Node
## Base class for all nodes that manage and track stat changes in an encounter
## scene.
## 
## Requires the defining of functions for accessing stats, both specific
## and groups.


## Indicates that the health has changed from one value to another.
signal health_changed(new_value, old_value)

## Reference to the character that the stats describe.
var character_id: int = -1
## Reference to the type of character the stats describe.
var character_type: Character.Type = Character.Type.NONE


func _ready() -> void:
	_check_for_required_parameters()


## Returns the movement stat. Can specify if the base value should be returned
## or the value with current modifiers.
@abstract func get_movement_range(modified: bool = true) -> int


## Updates the current health by the given delta. The delta amount can be
## positive or negative. Returns the new value of the current health.
func set_cur_health(delta: int) -> int:
	var new_health: int = get_stat(Stat.Type.CUR_HEALTH) + delta
	var max_health: int = get_stat(Stat.Type.MAX_HEALTH)
	new_health = int(clamp(new_health, 0, max_health))
	emit_signal("health_changed", new_health, max_health)
	return new_health


## Set current health to the maximum value. Always uses the modified max health
## as the maximum value.
@abstract func max_cur_health() -> void


## Returns the values for all stats. Can specify if the base values should be
## returned or the values with current modifiers.
@abstract func get_all(modified: bool = true) -> AllStats


## Returns the values of all offensive related stats. Can specify if the base
## values should be returned or the values with current modifiers.
@abstract func get_offensive(modified: bool = true) -> OffensiveStats


## Returns the values of all defensive related stats. Can specify if the base
## values should be returned or the values with current modifiers.
@abstract func get_defensive(modified: bool = true) -> DefensiveStats


## Returns the value for a specific stat. Can specify if the base value should
## be returned or the value with current modifiers.
@abstract func get_stat(stat: Stat.Type, modified: bool = true) -> int


## Updates the modifier for the specified stat so that it results in the new
## value when added to the base value of the stat.
@abstract func update_modifier(stat: Stat.Type, value: int) -> void


## Sets the values of all the modifiers to zero.
@abstract func clear_modifiers() -> void


## Check that all required parameters are set.
@abstract func _check_for_required_parameters() -> void
