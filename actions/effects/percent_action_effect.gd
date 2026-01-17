class_name PercentActionEffect
extends ActionEffect
## Class that describes an effect of an action. Uses the PercentageCalculation
## when modifying target stats.
##
## An ActionEffect specifies how a specific character stat is to be modified.
## Also specifies what category of character this effect impacts (self, allies,
## enemies). Derived classes specify specific calculation methods for how the
## stats are to be adjusted.


## Defines the percent value (multiplier) to use for calculation.
@export_range(0.0, 5.0, 0.01) var percent_change_value = 1.0


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_calculation_method = PercentageCalculation.new(percent_change_value)
