class_name WispCost
extends ActionCondition
"""
Defines the wisps that need to be set to the character in order for an action
to be usable.
"""


export(int, 0, 4) var earth_req = 0
export(int, 0, 4) var earth_cost = 0
export(int, 0, 4) var fire_req = 0
export(int, 0, 4) var fire_cost = 0
export(int, 0, 4) var water_req = 0
export(int, 0, 4) var water_cost = 0
export(int, 0, 4) var wind_req = 0
export(int, 0, 4) var wind_cost = 0
export(int, 0, 4) var light_req = 0
export(int, 0, 4) var light_cost = 0
export(int, 0, 4) var dark_req = 0
export(int, 0, 4) var dark_cost = 0

var summary: Dictionary = _get_costs()
var wisp_pool: WispPool = null


# Virtual function. Checks if the condition has been met given the current
# state of the characters and map.
func is_met(
	_character: Character,
	_targets: Array,
	_distance_map: DistanceMap
) -> bool:
	return (
		wisp_pool.active_earth_count() >= earth_req
		and wisp_pool.active_fire_count() >= fire_req
		and wisp_pool.active_water_count() >= water_req
		and wisp_pool.active_wind_count() >= wind_req
		and wisp_pool.active_light_count() >= light_req
		and wisp_pool.active_dark_count() >= dark_req
	)


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


# Creates a new instance of this node with the given cost details.
func _init(spell_stats: SpellStats) -> void:
	earth_req = spell_stats.earth_req
	earth_cost = spell_stats.earth_cost
	fire_req = spell_stats.fire_req
	fire_cost = spell_stats.fire_cost
	water_req = spell_stats.water_req
	water_cost = spell_stats.water_cost
	wind_req = spell_stats.wind_req
	wind_cost = spell_stats.wind_cost
	light_req = spell_stats.light_req
	light_cost = spell_stats.light_cost
	dark_req = spell_stats.dark_req
	dark_cost = spell_stats.dark_cost


# Gets the elements with cost values.
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


# Check that all required parameters are set and valid.
func _check_for_required_parameters() -> void:
	assert(earth_req >= earth_cost, "Earth requirement less than cost")
	assert(fire_req >= fire_cost, "Fire requirement less than cost")
	assert(water_req >= water_cost, "Water requirement less than cost")
	assert(wind_req >= wind_cost, "Wind requirement less than cost")
	assert(light_req >= light_cost, "Light requirement less than cost")
	assert(dark_req >= dark_cost, "Dark requirement less than cost")
