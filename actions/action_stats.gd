class_name ActionStats
extends Resource
"""
Describes some core details about an action, specifically the potency and various
ranges.
"""


@export var name: String = ""
@export var potency: Potency = null
@export var source_range: AreaRange = null
@export var dead_range: AreaRange = null
@export var effect_range: AreaRange = null
# Flag that denotes if the emission is fixed to the center of the area.
@export var emit_from_center: bool = true
# Flag that denotes if the effect should include the casting character tile.
@export var effect_ignores_caster: bool = true
# Flag that denotes if the possible source of the emmision is affected by tile heights.
@export var source_ignore_heights: bool = false
# Flag that denotes if the emission area is affected by tile heights.
@export var effect_ignore_heights: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			potency != null,
			"ActionStats missing defined potency."
	)
	assert(
			source_range != null,
			"ActionStats source range not set."
	)
	assert(
			source_range is CardinalArea or source_range is RingArea,
			"ActionStats source range is neither a CardinalArea or RingArea."
	)
	assert(
			dead_range != null,
			"ActionStats dead range not set."
	)
	assert(
			dead_range is CardinalArea or dead_range is RingArea,
			"ActionStats dead range is neither a CardinalArea or RingArea."
	)
	assert(
			effect_range != null,
			"ActionStats effect range not set."
	)
