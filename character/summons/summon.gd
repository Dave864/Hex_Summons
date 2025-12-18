class_name Summon
extends Character
## Manages the creation and using of summons.
##
## Tracks which summons are selectable in an encounter scene. Represents an
## active summon when the user executes the "Summon" action. Handles the
## swapping of summon details.


## Path to the folder that contains all summon data.
const SUMMON_DATA_PATH: String = "res://character/summons/summon_data/"
## Name of resource file for summon data.
const SUMMON_DATA_RESOURCE_PATH: String = SUMMON_DATA_PATH + "{0}/summon_data.tres"
## The string format for retrieving actions given a name.
const ACTION_PATH_FORMAT: String = "res://actions/{0}/{0}.tscn"
## Position the summon is placed when not active.
const STANDBY_POSITION: Vector3 = Vector3(0.0, -10.0, 0.0)

## The character that conjured the active summon.
var summoner: PlayerCharacter = null
## The summons that are able to be conjured by the current player party in the
## encounter.
var available_summons: Dictionary[String, SummonData] = {}
## The actions summons use when conjured.
var spawn_actions: Dictionary[String, Action] = {}
## The actions the summon can use on their turn.
var turn_actions: Array[Action] = []

## The spawn action of the currently active summon. 
var _current_spawn_action: Action = null

## The wisp pool for the active summon.
@onready var wisp_pool: SummonWispPool = $SummonWispPool


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = $SummonStatModifiers
	_cache_available_summons()
	# Ensure that the summon node is set to inactive at the start of an encounter.
	dismiss_summon()


## Sets the selected summon to be active and places them at the specified map
## coordinate.
func load_summon(summon_name: String, spawn_coordinate: MapCoordinate) -> void:
	stats.summon_data = available_summons[summon_name]
	visible = true
	character_label.show()
	position = spawn_coordinate.position
	spawn_actions[summon_name].source_stats = stats
	_current_spawn_action = spawn_actions[summon_name]
	_load_actions()


## Sets the summon to be inactive, placing them out of the map and resetting the
## specific summon details in preparation for the next summon.
func dismiss_summon() -> void:
	position = STANDBY_POSITION
	visible = false
	character_label.hide()
	for action: Action in turn_actions:
		$Actions/TurnActions.remove_child(action)
		action.queue_free()
	turn_actions.clear()
	stats.summon_data = null
	_current_spawn_action = null


## Loads the data for the summons that are able to be conjured based on the
## current wisps available to the party.
func _cache_available_summons() -> void:
	var summon_folders: PackedStringArray = (
			DirAccess.get_directories_at(SUMMON_DATA_PATH)
	)
	var core_elems_count: Dictionary[Element.Core, int]
	core_elems_count = WispTracker.get_usable_wisp_count()
	for summon_name: String in summon_folders:
		var data: SummonData = load(SUMMON_DATA_RESOURCE_PATH.format([summon_name]))
		if data.core_elements_meet_requirements(core_elems_count):
			available_summons[summon_name] = data
			_create_spawn_action_node(summon_name, data.spawn_action)


## Creates an action node that represents an action that is used when a summon
## is spawned. Adds them to the scene tree for future reference.
func _create_spawn_action_node(
	summon_name: String,
	action_stats: ActionStats
) -> void:
	var action_node: Action
	if $Actions/SpawnActions.has_node(action_stats.name):
		action_node = $Actions/SpawnActions.get_node(action_stats.name)
	else:
		action_node = _create_action_node(action_stats.name)
		action_node.name = action_stats.name
		$Actions/SpawnActions.add_child(action_node)
	spawn_actions[summon_name] = action_node


## Loads the action nodes relevant to this summon.
func _load_actions() -> void:
	var action_count: int = stats.summon_data.turn_actions.size()
	turn_actions.resize(action_count)
	for i: int in action_count:
		var action_data: SpellStats = stats.summon_data.turn_actions[i]
		var action_name: String = action_data.action_stats.name
		var action_node: Action = _create_action_node(action_name)
		action_node.source_stats = stats
		$Actions/TurnActions.add_child(action_node)
		action_node.add_child(WispCost.new(action_data))
		turn_actions[i] = action_node


## Creates a new instance of an action node of the given name.
func _create_action_node(action_name: String) -> Action:
	var action_path: String = ACTION_PATH_FORMAT.format([action_name])
	var action_node: Action = load(action_path).instantiate()
	return action_node


## Virtual function. Updates emission points for all turn actions of the chracter.
func _update_emission_index(index: int) -> void:
	for action in turn_actions:
		action.set_emission_map_index(index)
