class_name Summon
extends Character
## Manages the creation and using of summons.
##
## Tracks which summons are selectable in an encounter scene. Represents an active
## summon when the user executes the "Summon" action. Handles the swapping of
## summon details. The summon wisp pool is handled by the WispController.


## Path to the folder that contains all summon data.
const SUMMON_DATA_PATH: String = "res://character/summons/summon_data/"
## Name of resource file for summon data.
const SUMMON_DATA_RESOURCE_PATH: String = SUMMON_DATA_PATH + "{0}/summon_data.tres"

## The character that conjured the active summon.
var summoner: PlayerCharacter = null
## The summons that are able to be conjured by the current player party in the
## encounter.
var available_summons: Dictionary[String, SummonData] = {}


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = $SummonStatModifiers
	_cache_available_summons()


## Sets the selected summon to be active and places them at the specified map
## coordinate.
func load_summon(summon_name: String, spawn_coordinate: MapCoordinate) -> void:
	pass


## Loads the data for the summons that are able to be conjured based on the current
## wisps available to the party.
func _cache_available_summons() -> void:
	var summon_folders: PackedStringArray = (
			DirAccess.get_directories_at(SUMMON_DATA_PATH)
	)
	var core_elems_count: Dictionary[Element.Core, int] = WispTracker.get_usable_wisp_count()
	for folder_name in summon_folders:
		var data: SummonData = load(SUMMON_DATA_RESOURCE_PATH.format([folder_name]))
		if data.core_elements_meet_requirements(core_elems_count):
			available_summons[folder_name] = data


## Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(index: int) -> void:
	pass
