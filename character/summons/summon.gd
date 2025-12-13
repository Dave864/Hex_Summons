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
## The string format for retrieving actions given a name.
const ACTION_PATH_FORMAT: String = "res://actions/{0}/{0}.tscn"
## Position the summon is placed when not active.
const STANDBY_POSITION: Vector3 = Vector3(0.0, 0.0, -10.0)

## The character that conjured the active summon.
var summoner: PlayerCharacter = null
## The summons that are able to be conjured by the current player party in the
## encounter.
var available_summons: Dictionary[String, SummonData] = {}
## The action the summon uses when it is summoned.
var spawn_action: Action = null
## The actions the summon can use on their turn.
var actions: Array[Action] = []


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
	position = spawn_coordinate.position


## Sets the summon to be inactive, placing them out of the map and resetting the
## specific summon details in preparation for the next summon.
func dismiss_summon() -> void:
	position = STANDBY_POSITION
	visible = false
	$Actions.remove_child(spawn_action)
	spawn_action.queue_free()
	for action in actions:
		$Actions/TurnActions.remove_child(action)
		action.queue_free()
	actions.clear()
	stats.summon_data = null


## Loads the data for the summons that are able to be conjured based on the current
## wisps available to the party.
func _cache_available_summons() -> void:
	var summon_folders: PackedStringArray = (
			DirAccess.get_directories_at(SUMMON_DATA_PATH)
	)
	var core_elems_count: Dictionary[Element.Core, int]
	core_elems_count = WispTracker.get_usable_wisp_count()
	for folder_name in summon_folders:
		var data: SummonData = load(SUMMON_DATA_RESOURCE_PATH.format([folder_name]))
		if data.core_elements_meet_requirements(core_elems_count):
			available_summons[folder_name] = data


## Loads the action nodes relevant to this summon.
func _load_actions() -> void:
	spawn_action = _create_action_node(stats.summon_data.spawn_action)
	$Actions.add_child(spawn_action)
	for action_data in stats.summon_data.turn_actions:
		_create_action_node(action_data)


## Helper function for _load_actions. Creates a new instance of an action node
## based on the provided details.
func _create_action_node(action_stats: SpellStats) -> Action:
	var action_name: String = action_stats.action_stats.name
	var action_path: String = ACTION_PATH_FORMAT.format([action_name])
	var action_node: Action = load(action_path).instantiate()
	return action_node


## Helper function for _load_actions. Creates an action node that represents an
## action that can be used on a summon's turn. Adds 
func _create_turn_action_node(action_stats: SpellStats) -> void:
	var action_node: Action = _create_action_node(action_stats)
	var wisp_cost_node: WispCost = WispCost.new(action_stats)
	action_node.add_child(wisp_cost_node)
	$Actions/TurnActions.add_child(action_node)


## Virtual function. Updates emission points for all actions of the chracter.
func _update_emission_index(index: int) -> void:
	for action in actions:
		action.set_emission_map_index(index)
