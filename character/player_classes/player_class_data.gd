class_name PlayerClassData
extends Resource
## Describes the data for a player class.


## The name of the class. Used when instanciating class nodes.
@export var name: String = ""
## The base stats for the player character.
@export var stats: BaseStats = null
## The list of technique actions associated with this class.
@export var techniques: Array[TechniqueStats] = []
## The list of spell actions assiciated with this class.
@export var spells: Array[SpellStats] = []


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


## Checks that all required parameters are set and/or valid.
func _check_for_required_parameters() -> void:
	assert(stats != null, "Stats have not been set.")
