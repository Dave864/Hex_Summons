class_name WispCost
extends ActionCondition
## Defines the wisps that need to be set to the character in order for an action
## to be usable.


@export_group("Required Wisps to Cast", "req_")
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

## The pool that the cost refers to when checking if requirements are met.
var wisp_pool: WispPool = null

## A collated summary of the required number of wisps.
@onready var req_summary: Dictionary[Element.Type, int] = _get_requirements()
## A collated summary of the costs.
@onready var cost_summary: Dictionary[Element.Type, int] = _get_costs()


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()


## Creates a new instance of this node with the given cost details.
func _init(
	requirements: Dictionary[Element.Type, int],
	costs: Dictionary[Element.Type, int]
) -> void:
	name = "WispCost"
	for element: Element.Type in Element.Type.values():
		_req_for_element(element, requirements)
		_cost_for_element(element, costs)
	req_summary = requirements
	cost_summary = costs


## Virtual function. Checks if the condition has been met given the current
## state of the characters and map.
func is_met(
	_character: Character = null,
	_targets: Array[Character] = [],
	_distance_map: DistanceMap = null
) -> bool:
	return (
		wisp_pool.active_earth_count() >= req_earth
		and wisp_pool.active_fire_count() >= req_fire
		and wisp_pool.active_water_count() >= req_water
		and wisp_pool.active_wind_count() >= req_wind
		and wisp_pool.active_light_count() >= req_light
		and wisp_pool.active_dark_count() >= req_dark
	)


## Updates the requirement values to the specified elements.
func update_requirements(new_requirements: Dictionary[Element.Type, int]) -> void:
	for element: Element.Type in Element.Type.values():
		_req_for_element(element, new_requirements)
	req_summary = new_requirements


## Updates the cost values to the specified elements.
func update_costs(new_costs: Dictionary[Element.Type, int]) -> void:
	for element: Element.Type in Element.Type.values():
		_cost_for_element(element, new_costs)
	cost_summary = new_costs


## Sets the requirement value for the given element based on the details
## provided.
func _req_for_element(
	element: Element.Type,
	requirements: Dictionary[Element.Type, int]
) -> void:
	var req_value: int = (
		0 if not requirements.has(element)
		else requirements[element]
	)
	match element:
		Element.Type.EARTH:
			req_earth = req_value
		Element.Type.FIRE:
			req_fire = req_value
		Element.Type.WATER:
			req_water = req_value
		Element.Type.WIND:
			req_wind = req_value
		Element.Type.LIGHT:
			req_light = req_value
		Element.Type.DARK:
			req_dark = req_value


## Sets the cost value for the given element based on the details provided.
func _cost_for_element(
	element: Element.Type,
	costs: Dictionary[Element.Type, int]
) -> void:
	var cost_value: int = 0 if not costs.has(element) else costs[element]
	match element:
		Element.Type.EARTH:
			cost_earth = cost_value
		Element.Type.FIRE:
			cost_fire = cost_value
		Element.Type.WATER:
			cost_water = cost_value
		Element.Type.WIND:
			cost_wind = cost_value
		Element.Type.LIGHT:
			cost_light = cost_value
		Element.Type.DARK:
			cost_dark = cost_value


## Gets the required element quantities.
func _get_requirements() -> Dictionary[Element.Type, int]:
	var element_reqs: Dictionary[Element.Type, int] = {}
	if req_earth > 0:
		element_reqs[Element.Type.EARTH] = req_earth
	if req_fire > 0:
		element_reqs[Element.Type.FIRE] = req_fire
	if req_water > 0:
		element_reqs[Element.Type.WATER] = req_water
	if req_wind > 0:
		element_reqs[Element.Type.WIND] = req_wind
	if req_light > 0:
		element_reqs[Element.Type.LIGHT] = req_light
	if req_dark > 0:
		element_reqs[Element.Type.DARK] = req_dark
	return element_reqs


## Gets the elements with cost values.
func _get_costs() -> Dictionary[Element.Type, int]:
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
	assert(req_earth >= cost_earth, "Earth requirement less than cost")
	assert(req_fire >= cost_fire, "Fire requirement less than cost")
	assert(req_water >= cost_water, "Water requirement less than cost")
	assert(req_wind >= cost_wind, "Wind requirement less than cost")
	assert(req_light >= cost_light, "Light3D requirement less than cost")
	assert(req_dark >= cost_dark, "Dark requirement less than cost")
