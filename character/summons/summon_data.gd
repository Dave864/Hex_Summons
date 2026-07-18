class_name SummonData
extends Resource
## Stores data relevant to a character summon.
##
## Has references to various files and tracks data describing a summon. Records
## image data, stat multipliers, wisp requirements, and available actions.


## The default value for a stat multiplier. Corresponds to 100% of the
## summoner's stat.
const DEFAULT: float = 1.0
## The maximum value for a stat multiplier.
const MAX: float = 5.0
## The amount a stat multiplier can be adjusted by. Corresponds to 10%.
const STEP: float = 0.1
## The minimum possible number of wisps needed for a summon.
const MIN_WISP: int = 0
## The maximum possible number of wisps needed for a summon.
const MAX_WISP: int = 4

@export var name: String = ""
@export_group("Images")
@export var portrait: Texture2D = null
@export var sprite_sheet: Texture2D = null
@export var sprite_frames: SpriteFrames = null
@export_group("Summoner Stat Multipliers")
@export_range(0, 10) var movement: int = 1
@export_range(DEFAULT, MAX, STEP) var attack: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var defense: float = DEFAULT
@export_subgroup("Magic", "magic_")
@export_range(DEFAULT, MAX, STEP) var magic_earth: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var magic_fire: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var magic_water: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var magic_wind: float = DEFAULT
@export_subgroup("Resistance", "res_")
@export_range(DEFAULT, MAX, STEP) var res_earth: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var res_fire: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var res_water: float = DEFAULT
@export_range(DEFAULT, MAX, STEP) var res_wind: float = DEFAULT
@export_group("Wisp Requirement and Cost")
@export_range(MIN_WISP, MAX_WISP) var earth_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var fire_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var water_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var wind_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var light_req: int = MIN_WISP
@export_range(MIN_WISP, MAX_WISP) var dark_req: int = MIN_WISP
@export_group("Actions")
@export var spawn_action: ActionStats = null
@export var turn_actions: Array[SpellStats] = []


## Returns the multiplier value for the given stat.
func multiplier_for_stat(stat: Stat.Type) -> float:
	match stat:
		Stat.Type.ATTACK:
			return attack
		Stat.Type.DEFENSE:
			return defense
		Stat.Type.MOVEMENT:
			return movement
		Stat.Type.MAGIC_EARTH:
			return magic_earth
		Stat.Type.MAGIC_FIRE:
			return magic_fire
		Stat.Type.MAGIC_WATER:
			return magic_water
		Stat.Type.MAGIC_WIND:
			return magic_wind
		Stat.Type.MAGIC_LIGHT:
			var light_elems: Array[Stat.Type] = Stat.get_light_aligned_magic()
			var mult_1: float = multiplier_for_stat(light_elems[0])
			var mult_2: float = multiplier_for_stat(light_elems[1])
			return mult_1 + mult_2
		Stat.Type.MAGIC_DARK:
			var dark_elems: Array[Stat.Type] = Stat.get_dark_aligned_magic()
			var mult_1: float = multiplier_for_stat(dark_elems[0])
			var mult_2: float = multiplier_for_stat(dark_elems[1])
			return mult_1 + mult_2
		Stat.Type.RES_EARTH:
			return res_earth
		Stat.Type.RES_FIRE:
			return res_fire
		Stat.Type.RES_WATER:
			return res_water
		Stat.Type.RES_WIND:
			return res_wind
		Stat.Type.RES_LIGHT:
			var light_elems: Array[Stat.Type] = Stat.get_light_aligned_res()
			var mult_1: float = multiplier_for_stat(light_elems[0])
			var mult_2: float = multiplier_for_stat(light_elems[1])
			return mult_1 + mult_2
		Stat.Type.RES_DARK:
			var dark_elems: Array[Stat.Type] = Stat.get_dark_aligned_res()
			var mult_1: float = multiplier_for_stat(dark_elems[0])
			var mult_2: float = multiplier_for_stat(dark_elems[1])
			return mult_1 + mult_2
		_:
			return DEFAULT


## Checks if the provided wisp pool matches the requirements for this summon.
func wisp_pool_meets_requirements(pool: WispPool) -> bool:
	return (
		pool.active_earth_count() >= earth_req
		and pool.active_fire_count() >= fire_req
		and pool.active_water_count() >= water_req
		and pool.active_wind_count() >= wind_req
		and pool.active_light_count() >= light_req
		and pool.active_dark_count() >= dark_req
	)


## Checks if the provided core element counts match the requirements for this
## summon.
func core_elements_meet_requirements(
	counts: Dictionary[Element.Core, int]
) -> bool:
	return (
		counts[Element.Core.EARTH] >= earth_req
		and counts[Element.Core.FIRE] >= fire_req
		and counts[Element.Core.WATER] >= water_req
		and counts[Element.Core.WIND] >= wind_req
		and _alignment_requirements_met(counts)
	)


## Gets the summary of the wisp cost for the summon.
func cost_summary() -> Dictionary[Element.Type, int]:
	var element_costs: Dictionary[Element.Type, int] = {}
	if earth_req > 0:
		element_costs[Element.Type.EARTH] = earth_req
	if fire_req > 0:
			element_costs[Element.Type.FIRE] = fire_req
	if water_req > 0:
			element_costs[Element.Type.WATER] = water_req
	if wind_req > 0:
			element_costs[Element.Type.WIND] = wind_req
	if light_req > 0:
			element_costs[Element.Type.LIGHT] = light_req
	if dark_req > 0:
			element_costs[Element.Type.DARK] = dark_req
	return element_costs


## Helper function for core_requirements_met. Checks if it is possible for the
## given core counts to meet the requirements for light and dark.
func _alignment_requirements_met(counts: Dictionary[Element.Core, int]) -> bool:
	var max_alignment_req: int = max(light_req, dark_req)
	var meet_count: int = 0
	for count in counts.values():
		meet_count += 1 if count >= max_alignment_req else 0
	# At least two core element counts need to meet the maximum alignment count
	# as two core elements always fuel alignemt elements.
	return meet_count >= 2
