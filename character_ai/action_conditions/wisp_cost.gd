class_name WispCost
extends ActionCondition
"""
Defines the wisps that need to be set to the character in order for an action
to be usable.
"""


export var wisp_pool_ref: NodePath = NodePath("")
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

onready var _wisp_pool: WispPool = get_node(wisp_pool_ref)


# Virtual function. Checks if the condition has been met given the current
# state of the characters and map.
func is_met(
	_character: Character,
	_targets: Array,
	_distance_map: DistanceMap
) -> bool:
	return (
		_wisp_pool.active_earth_count() >= earth_req
		and _wisp_pool.active_fire_count() >= fire_req
		and _wisp_pool.active_water_count() >= water_req
		and _wisp_pool.active_wind_count() >= wind_req
		and _wisp_pool.active_light_count() >= light_req
		and _wisp_pool.active_dark_count() >= dark_req
	)


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


# Check that all required parameters are set and valid.
func _check_for_required_parameters() -> void:
	assert(earth_req >= earth_cost, "Earth requirement less than cost")
	assert(fire_req >= fire_cost, "Fire requirement less than cost")
	assert(water_req >= water_cost, "Water requirement less than cost")
	assert(wind_req >= wind_cost, "Wind requirement less than cost")
	assert(light_req >= light_cost, "Light requirement less than cost")
	assert(dark_req >= dark_cost, "Dark requirement less than cost")
