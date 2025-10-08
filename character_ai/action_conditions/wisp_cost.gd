class_name WispCost
extends ActionCondition
"""
Defines the wisps that need to be set to the character in order for an action
to be usable.
"""


const SPENT_TYPE_ERROR = "The wisp cost of spent_type is zero."

export var wisp_pool_ref: NodePath = NodePath("")
export(int, 0, 4) var earth_count = 0
export(int, 0, 4) var fire_count = 0
export(int, 0, 4) var water_count = 0
export(int, 0, 4) var wind_count = 0
export(int, 0, 4) var light_count = 0
export(int, 0, 4) var dark_count = 0
# Currently, all actions that require wisps will always spend one wisp of the
# given type.
export(Constants.Element) var spent_type = Constants.Element.EARTH

onready var _wisp_pool: WispPool = get_node(wisp_pool_ref)


# Virtual function. Checks if the condition has been met given the current
# state of the characters and map.
func is_met(
	_character: Character,
	_targets: Array,
	_distance_map: DistanceMap
) -> bool:
	return (
		_wisp_pool.active_earth_count() >= earth_count
		and _wisp_pool.active_fire_count() >= fire_count
		and _wisp_pool.active_water_count() >= water_count
		and _wisp_pool.active_wind_count() >= wind_count
		and _wisp_pool.active_light_count() >= light_count
		and _wisp_pool.active_dark_count() >= dark_count
	)


# Called when the node enters the scene tree for the first time.
func _ready():
	match spent_type:
		Constants.Element.EARTH:
			assert(earth_count > 0, SPENT_TYPE_ERROR)
		Constants.Element.FIRE:
			assert(fire_count > 0, SPENT_TYPE_ERROR)
		Constants.Element.WATER:
			assert(water_count > 0, SPENT_TYPE_ERROR)
		Constants.Element.WIND:
			assert(wind_count > 0, SPENT_TYPE_ERROR)
		Constants.Element.LIGHT:
			assert(light_count > 0, SPENT_TYPE_ERROR)
		Constants.Element.DARK:
			assert(dark_count > 0, SPENT_TYPE_ERROR)
