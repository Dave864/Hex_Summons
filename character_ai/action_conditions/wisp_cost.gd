class_name WispCost
extends ActionCondition
## Defines the wisps that need to be set to the character in order for an action
## to be usable.


@export_group("Required Wisps to Cast")
@export var earth_req = 0 # (int, 0, 4)
@export var fire_req = 0 # (int, 0, 4)
@export var water_req = 0 # (int, 0, 4)
@export var wind_req = 0 # (int, 0, 4)
@export var light_req = 0 # (int, 0, 4)
@export var dark_req = 0 # (int, 0, 4)

@export_group("Wisps Spent on Cast")
@export var earth_cost = 0 # (int, 0, 4)
@export var fire_cost = 0 # (int, 0, 4)
@export var water_cost = 0 # (int, 0, 4)
@export var wind_cost = 0 # (int, 0, 4)
@export var light_cost = 0 # (int, 0, 4)
@export var dark_cost = 0 # (int, 0, 4)

## The pool that the cost refers to when checking if requirements are met.
var wisp_pool: WispPool = null

## A collated summary of the costs.
@onready var cost_summary: Dictionary = _get_costs()


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


## Creates a new instance of this node with the given cost details.
func _init(spell_stats: SpellStats = null) -> void:
	name = "WispCost"
	earth_req = 0 if spell_stats == null else spell_stats.earth_req
	earth_cost = 0 if spell_stats == null else spell_stats.earth_cost
	fire_req = 0 if spell_stats == null else spell_stats.fire_req
	fire_cost = 0 if spell_stats == null else spell_stats.fire_cost
	water_req = 0 if spell_stats == null else spell_stats.water_req
	water_cost = 0 if spell_stats == null else spell_stats.water_cost
	wind_req = 0 if spell_stats == null else spell_stats.wind_req
	wind_cost = 0 if spell_stats == null else spell_stats.wind_cost
	light_req = 0 if spell_stats == null else spell_stats.light_req
	light_cost = 0 if spell_stats == null else spell_stats.light_cost
	dark_req = 0 if spell_stats == null else spell_stats.dark_req
	dark_cost = 0 if spell_stats == null else spell_stats.dark_cost
	cost_summary = _get_costs()


## Virtual function. Checks if the condition has been met given the current
## state of the characters and map.
func is_met(
	_character: Character = null,
	_targets: Array = [],
	_distance_map: DistanceMap = null
) -> bool:
	return (
		wisp_pool.active_earth_count() >= earth_req
		and wisp_pool.active_fire_count() >= fire_req
		and wisp_pool.active_water_count() >= water_req
		and wisp_pool.active_wind_count() >= wind_req
		and wisp_pool.active_light_count() >= light_req
		and wisp_pool.active_dark_count() >= dark_req
	)


## Gets the elements with cost values.
func _get_costs() -> Dictionary:
	var element_costs: Dictionary = {}
	if earth_cost > 0:
		element_costs[Constants.Element.EARTH] = earth_cost
	if fire_cost > 0:
			element_costs[Constants.Element.FIRE] = fire_cost
	if water_cost > 0:
			element_costs[Constants.Element.WATER] = water_cost
	if wind_cost > 0:
			element_costs[Constants.Element.WIND] = wind_cost
	if light_cost > 0:
			element_costs[Constants.Element.LIGHT] = light_cost
	if dark_cost > 0:
			element_costs[Constants.Element.DARK] = dark_cost
	return element_costs


## Check that all required parameters are set and valid.
func _check_for_required_parameters() -> void:
	assert(earth_req >= earth_cost, "Earth requirement less than cost")
	assert(fire_req >= fire_cost, "Fire requirement less than cost")
	assert(water_req >= water_cost, "Water requirement less than cost")
	assert(wind_req >= wind_cost, "Wind requirement less than cost")
	assert(light_req >= light_cost, "Light3D requirement less than cost")
	assert(dark_req >= dark_cost, "Dark requirement less than cost")
