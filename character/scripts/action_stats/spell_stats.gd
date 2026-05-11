class_name SpellStats
extends Resource
## Describes a spell. Spells are actions with a wisp requirement and cost.


@export var action_stats: ActionStats = null

@export_group("Wisps Required to Cast", "req_")
@export_range(0, 4) var req_earth: int = 0
@export_range(0, 4) var req_fire: int = 0
@export_range(0, 4) var req_water: int = 0
@export_range(0, 4) var req_wind: int = 0
@export_range(0, 4) var req_light: int = 0
@export_range(0, 4) var req_dark: int = 0

@export_group("Wisps Spent on Cast", "cost_")
@export_range(0, 4) var cost_earth: int = 0
@export_range(0, 4) var cost_fire: int = 0
@export_range(0, 4) var cost_water: int = 0
@export_range(0, 4) var cost_wind: int = 0
@export_range(0, 4) var cost_light: int = 0
@export_range(0, 4) var cost_dark: int = 0


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


## Checks if the wisp pool meets the requirements described by these stats.
func is_met(wisp_pool: WispPool) -> bool:
	return (
		wisp_pool.active_earth_count() >= req_earth
		and wisp_pool.active_fire_count() >= req_fire
		and wisp_pool.active_water_count() >= req_water
		and wisp_pool.active_wind_count() >= req_wind
		and wisp_pool.active_light_count() >= req_light
		and wisp_pool.active_dark_count() >= req_dark
	)


## Gets the elements with requirment values.
func get_requirements() -> Dictionary[Element.Type, int]:
	var element_requirements: Dictionary[Element.Type, int] = {}
	if req_earth > 0:
		element_requirements[Element.Type.EARTH] = req_earth
	if req_fire > 0:
			element_requirements[Element.Type.FIRE] = req_fire
	if req_water > 0:
			element_requirements[Element.Type.WATER] = req_water
	if req_wind > 0:
			element_requirements[Element.Type.WIND] = req_wind
	if req_light > 0:
			element_requirements[Element.Type.LIGHT] = req_light
	if req_dark > 0:
			element_requirements[Element.Type.DARK] = req_dark
	return element_requirements


## Gets the elements with cost values.
func get_costs() -> Dictionary[Element.Type, int]:
	var element_costs: Dictionary[Element.Type, int] = {}
	if cost_earth > 0:
		element_costs[Element.Type.EARTH] = cost_earth
	if cost_fire > 0:
			element_costs[Element.Type.FIRE] = cost_fire
	if cost_water > 0:
			element_costs[Element.Type.WATER] = cost_water
	if cost_wind > 0:
			element_costs[Element.Type.WIND] = cost_wind
	if cost_light > 0:
			element_costs[Element.Type.LIGHT] = cost_light
	if cost_dark > 0:
			element_costs[Element.Type.DARK] = cost_dark
	return element_costs


## Check that all required parameters are set and valid.
func _check_for_required_parameters() -> void:
	assert(
			action_stats is ActionStats,
			"Parameter action_stats is not of type ActionStats."
	)
	assert(req_earth >= cost_earth, "Earth requirement less than cost")
	assert(req_fire >= cost_fire, "Fire requirement less than cost")
	assert(req_water >= cost_water, "Water requirement less than cost")
	assert(req_wind >= cost_wind, "Wind requirement less than cost")
	assert(req_light >= cost_light, "Light3D requirement less than cost")
	assert(req_dark >= cost_dark, "Dark requirement less than cost")
