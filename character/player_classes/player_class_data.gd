class_name PlayerClassData
extends Resource
"""
Describes the data for a player class.
"""


@export var name: String = ""
@export var stats: Resource = null
@export var techniques: Array = []
@export var spells: Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


# Checks that all required parameters are set and/or valid.
func _check_for_required_parameters() -> void:
	assert(stats != null, "Stats have not been set.")
	assert(stats is BaseStats, "Stats is not of type BaseStats.")
	for technique in techniques:
		assert(
				technique is TechniqueStats,
				"Not all techniques are of type TechniqueStats."
		)
	for spell in spells:
		assert(
				spell is SpellStats,
				"Not all spells are of type SpellStats."
		)
