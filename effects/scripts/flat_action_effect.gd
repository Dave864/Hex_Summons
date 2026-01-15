class_name FlatActionEffect
extends ActionEffect
## Class that describes an effect of an action. Uses the FlatValueCalculation
## when modifying target stats.
##
## An ActionEffect specifies how a specific character stat is to be modified.
## Also specifies what category of character this effect impacts (self, allies,
## enemies). Derived classes specify specific calculation methods for how the
## stats are to be adjusted.


## Defines the flat value to use for calculations.
@export_range(0, 1000) var flat_change_value = 0


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_calculation_method = FlatValueCalculation.new(flat_change_value)
