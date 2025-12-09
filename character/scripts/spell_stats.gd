class_name SpellStats
extends Resource
## Describes a spell. Spells are actions with a wisp requirement and cost.


@export var action_stats: ActionStats = null

@export_group("Wisps Required to Cast")
@export_range(0, 4) var earth_req: int = 0
@export_range(0, 4) var fire_req: int = 0
@export_range(0, 4) var water_req: int = 0
@export_range(0, 4) var wind_req: int = 0
@export_range(0, 4) var light_req: int = 0
@export_range(0, 4) var dark_req: int = 0

@export_group("Wisps Spent on Cast")
@export_range(0, 4) var earth_cost: int = 0
@export_range(0, 4) var fire_cost: int = 0
@export_range(0, 4) var water_cost: int = 0
@export_range(0, 4) var wind_cost: int = 0
@export_range(0, 4) var light_cost: int = 0
@export_range(0, 4) var dark_cost: int = 0

var summary: Dictionary = _get_costs()


## Checks if the wisp pool meets the requirements described by these stats.
func is_met(wisp_pool: WispPool) -> bool:
	return (
		wisp_pool.active_earth_count() >= earth_req
		and wisp_pool.active_fire_count() >= fire_req
		and wisp_pool.active_water_count() >= water_req
		and wisp_pool.active_wind_count() >= wind_req
		and wisp_pool.active_light_count() >= light_req
		and wisp_pool.active_dark_count() >= dark_req
	)


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


## Gets the elements with cost values.
func _get_costs() -> Dictionary:
	var element_costs: Dictionary = {}
	if earth_cost > 0:
		element_costs[Element.Type.EARTH] = earth_cost
	if fire_cost > 0:
			element_costs[Element.Type.FIRE] = fire_cost
	if water_cost > 0:
			element_costs[Element.Type.WATER] = water_cost
	if wind_cost > 0:
			element_costs[Element.Type.WIND] = wind_cost
	if light_cost > 0:
			element_costs[Element.Type.LIGHT] = light_cost
	if dark_cost > 0:
			element_costs[Element.Type.DARK] = dark_cost
	return element_costs


## Check that all required parameters are set and valid.
func _check_for_required_parameters() -> void:
	assert(
			action_stats is ActionStats,
			"Parameter action_stats is not of type ActionStats."
	)
	assert(earth_req >= earth_cost, "Earth requirement less than cost")
	assert(fire_req >= fire_cost, "Fire requirement less than cost")
	assert(water_req >= water_cost, "Water requirement less than cost")
	assert(wind_req >= wind_cost, "Wind requirement less than cost")
	assert(light_req >= light_cost, "Light3D requirement less than cost")
	assert(dark_req >= dark_cost, "Dark requirement less than cost")
