class_name Summon
extends Character
## Manages the creation and using of summons.
##
## Tracks which summons are selectable in an encounter scene. Represents an
## active summon when the user executes the "Summon" action. Handles the
## swapping of summon details. That stat variable is considered of type
## SummonStatModifiers.


## Indicates that the summon has been activated and has been placed in
## the encounter.
signal activated()
## Indicates that the summon has been deactivated and has left the encounter.
signal deactivated()

## Path to the folder that contains all summon data.
const SUMMON_DATA_PATH: String = "res://character/summons/summon_data/"
## Name of resource file for summon data.
const SUMMON_DATA_RESOURCE_PATH: String = (
	SUMMON_DATA_PATH \
	+ "{0}/summon_data.tres"
)
## The string format for retrieving actions given a name.
const ACTION_PATH_FORMAT: String = "res://actions/action_nodes/{0}/{0}.tscn"
## Formatted String for the error message indicating that an action is not
## valid as a spawn action.
const INVALID_ACTION_ERROR_FORMAT: String = (
	"Action {0} is not a valid option for a summon spawn action as its " \
	+ "effect is emitted from the summoner."
)
## Position the summon is placed when not active.
const STANDBY_POSITION: Vector3 = Vector3(0.0, -10.0, 0.0)


## The character that conjured the active summon.
var summoner: PlayerCharacter = null:
	set(value):
		if _active or value == null:
			return
		summoner = value
		stats.summoner_stats = summoner.stats
		for action: Action in spawn_actions.values():
			action.source_stats = summoner.stats
## The summons that are able to be conjured by the current player party in the
## encounter.
var available_summons: Dictionary[String, SummonData] = {}
## The actions summons use when conjured.
var spawn_actions: Dictionary[String, Action] = {}
## The actions the summon can use on their turn.
var turn_actions: Array[Action] = []

## The spawn action of the currently active summon. 
var _current_spawn_action: Action = null
## Flag that indicates the summon is active.
var _active: bool = false
## Name of the currently active summon.
var _active_summon: String = ""

## The wisp pool for the active summon.
@onready var summon_wisp_pool: SummonWispPool = $SummonWispPool


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = $SummonStatModifiers as SummonStatModifiers
	_connect_stats_to_effects_tracker()
	_cache_available_summons()
	# Ensure that the summon node is set to inactive at the start of an encounter.
	dismiss_summon()


## Checks if there is an active summon that has been loaded. An active summon
## always has a summoner specified.
func is_active() -> bool:
	return _active


## Gets the name of the currently active summon. Returns empty string if no
## summon is active.
func get_active_summon_name() -> String:
	if is_active():
		return ""
	return _active_summon


## Sets the wisp cost of the spawn action for the given summon.
func set_cost_for_spawn_action(summon_name: String) -> void:
	var spawn_action: Action = spawn_actions[summon_name]
	var wisp_cost: WispCost = spawn_action.get_node("WispCost")
	var summon_cost_summary: Dictionary[Element.Type, int] = (
		available_summons[summon_name].cost_summary()
	)
	wisp_cost.update_requirements(summon_cost_summary)
	wisp_cost.update_costs(summon_cost_summary)


## Sets the specified summon to be active and places them at the specified
## position.
func load_summon(summon_name: String, spawn_position: Vector3) -> void:
	summoner.character_label.hide_all()
	stats.summon_data = available_summons[summon_name]
	_current_spawn_action = spawn_actions[summon_name]
	_active_summon = summon_name
	WispController.pay_cost_for_summon(
			summon_wisp_pool,
			_current_spawn_action.get_node("WispCost")
	)
	visible = true
	character_label.show_all()
	character_label.set_max_health(summoner.stats.get_stat(Stat.Type.MAX_HEALTH))
	character_label.set_cur_health(summoner.stats.get_stat(Stat.Type.CUR_HEALTH))
	summoner.stats.connect(
			"health_changed",
			Callable(character_label, "_on_CharacterStatModifiers_health_changed")
	)
	position = spawn_position
	_load_actions()
	_active = true


## Sets the summon to be inactive, placing them out of the map and resetting the
## specific summon details in preparation for the next summon.
func dismiss_summon() -> void:
	emit_signal("deactivated")
	_active = false
	visible = false
	if summoner != null:
		summoner.character_label.show_all()
		summoner.stats.disconnect(
				"health_changed",
				Callable(
					character_label,
					"_on_CharacterStatModifiers_health_changed"
				)
		)
	character_label.hide_all()
	for action: Action in turn_actions:
		$Actions/TurnActions.remove_child(action)
		action.queue_free()
	position = STANDBY_POSITION
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
		var data: SummonData = (
			load(SUMMON_DATA_RESOURCE_PATH.format([summon_name]))
		)
		if data.core_elements_meet_requirements(core_elems_count):
			available_summons[summon_name] = data
			_create_spawn_action_node(summon_name, data.spawn_action)


## Creates an action node that represents an action that is used when a summon
## is spawned. Adds them to the scene tree for future reference.
func _create_spawn_action_node(
	summon_name: String,
	action_stats: ActionStats
) -> void:
	assert(
			not action_stats.emit_from_caster,
			INVALID_ACTION_ERROR_FORMAT.format([action_stats.name])
	)
	var action_node: Action
	if $Actions/SpawnActions.has_node(action_stats.name):
		action_node = $Actions/SpawnActions.get_node(action_stats.name)
	else:
		action_node = _create_action_node(action_stats.name)
		action_node.name = action_stats.name
		$Actions/SpawnActions.add_child(action_node)
		var wisp_cost_node: WispCost = WispCost.new(
				available_summons[summon_name].cost_summary(),
				available_summons[summon_name].cost_summary()
		)
		wisp_cost_node.wisp_pool = WispController.standby_pool
		action_node.add_child(wisp_cost_node)
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
		var wisp_cost := WispCost.new(
				action_data.get_requirements(),
				action_data.get_costs()
		)
		wisp_cost.wisp_pool = summon_wisp_pool
		action_node.add_child(wisp_cost)
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


## Activates the specified summon and places it at the listed emission position
## of the spawn action.
func _on_Selector_spawn_action_confirmed(
	summon_name: String,
	emission_position: Vector3
) -> void:
	load_summon(summon_name, emission_position)
	emit_signal("activated")
