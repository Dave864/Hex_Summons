@abstract
class_name StatModifiers
extends Node
## Base class for all nodes that manage and track stat changes in an encounter
## scene.
## 
## Requires the defining of functions for accessing stats, both specific
## and groups.


func _ready() -> void:
	_check_for_required_parameters()


## Returns the values for all stats. Can specify if the base values should be
## returned or the values with current modifiers.
@abstract func get_all(modified: bool = true) -> Dictionary


## Returns the values of all offensive related stats. Can specify if the base
## values should be returned or the values with current modifiers.
@abstract func get_offensive(modified: bool = true) -> Dictionary


## Returns the values of all defensive related stats. Can specify if the base
## values should be returned or the values with current modifiers.
@abstract func get_defensive(modified: bool = true) -> Dictionary


## Returns the value for a specific stat. Can specify if the base value should
## be returned or the value with current modifiers.
@abstract func get_stat(stat: int, modified: bool = true) -> int


## Updates the modifier for the specified stat so that it results in the new
## value when added to the base value of the stat.
@abstract func update_modifier(stat: int, value: int) -> void


## Sets the values of all the modifiers to zero.
@abstract func clear_modifiers() -> void


## Check that all required parameters are set.
@abstract func _check_for_required_parameters() -> void
